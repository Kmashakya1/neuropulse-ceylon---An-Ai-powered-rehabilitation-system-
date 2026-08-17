"""In-session fall detection from keypoint dynamics.

Why not the YOLO best.pt model here: its classes are FALL / STANDING / SITTING,
which describe a POSTURE. During rehab, lying on a mat is a normal posture, so a
posture classifier fires constantly on floor exercises. Raising
FALL_THRESHOLD (as the prototype does, to 120 frames) only delays that.

The discriminator between a fall and lying down deliberately is SPEED. A fall
drops the hips fast; lowering yourself onto a mat is slow and controlled. So we
look for:

  1. the hip centre descending faster than `drop_velocity` (screen-heights per
     second) AND actually travelling at least `min_drop` of the frame height, so
     a single noisy sample cannot stand in for a real drop,
  2. ending up low in frame AND with a near-horizontal torso,
  3. and STAYING there for `confirm_s` -- someone who gets straight back up
     didn't need a caregiver.

The YOLO model remains the right tool for ambient monitoring outside sessions,
where "lying on the floor" genuinely is the anomaly.
"""

from __future__ import annotations

from collections import deque
from dataclasses import dataclass

from . import angles, keypoints
from .schemas import Keypoint

_L_HIP = keypoints.INDEX["left_hip"]
_R_HIP = keypoints.INDEX["right_hip"]
_L_SHOULDER = keypoints.INDEX["left_shoulder"]


@dataclass(frozen=True)
class FallSignals:
    """Everything the decision was made from, for one frame.

    Exposed so tools/fall_probe.py can report exactly what the detector saw
    instead of recomputing it alongside and slowly drifting out of agreement.
    """

    t: float
    hip_y: float
    tilt: float
    drop: float
    velocity: float
    fell_fast: bool
    collapsed: bool
    fall: bool


class FallDetector:
    # CALIBRATION NOTE: these defaults are derived from the geometry, not from
    # real falls. A human fall moves the hips roughly 0.3 of the frame height in
    # 0.5-0.9s, i.e. ~0.35-0.6 screen-heights/second, whereas lowering yourself
    # onto a mat over 3-4s is ~0.07. 0.4 sits inside that gap with ~5x margin
    # over deliberate movement. Re-tune against real recorded footage with
    # tools/fall_probe.py before clinical use, and prefer false negatives here to
    # alarm fatigue.
    def __init__(
        self,
        drop_velocity: float = 0.4,
        min_drop: float = 0.15,
        min_hip_y: float = 0.65,
        min_tilt: float = 55.0,
        window_s: float = 0.4,
        confirm_s: float = 1.5,
        cooldown_s: float = 30.0,
        min_samples: int = 3,
    ):
        self._drop_velocity = drop_velocity
        self._min_drop = min_drop
        self._min_hip_y = min_hip_y
        self._min_tilt = min_tilt
        self._window_s = window_s
        self._confirm_s = confirm_s
        self._cooldown_s = cooldown_s
        self._min_samples = min_samples

        self._history: deque[tuple[float, float]] = deque()
        self._collapsed_since: float | None = None
        self._last_alert_t: float | None = None

        self.last: FallSignals | None = None

    def update(self, kps: list[Keypoint], t_s: float) -> bool:
        """Feed one frame. Returns True exactly once per confirmed fall."""
        hip_y = angles.midpoint_y(kps, _L_HIP, _R_HIP)
        tilt = angles.tilt_from_vertical(kps, _L_SHOULDER, _L_HIP)

        self._history.append((t_s, hip_y))
        while self._history and t_s - self._history[0][0] > self._window_s:
            self._history.popleft()

        drop, velocity = self._descent(t_s, hip_y)

        # Both the rate and the distance have to hold. Rate alone was enough to
        # latch on MediaPipe's first-frames convergence: on a prone clip the hip
        # estimate settled by 0.037 of frame height between frames one and two,
        # which over 67ms reads as 0.56 heights/second -- above the threshold, on
        # a patient who had not moved at all.
        fell_fast = velocity >= self._drop_velocity and drop >= self._min_drop
        collapsed = hip_y >= self._min_hip_y and tilt >= self._min_tilt

        fall = False
        if collapsed and (fell_fast or self._collapsed_since is not None):
            # Start the confirmation clock on the first frame that looks like a
            # fast collapse, and keep it running while they stay down.
            if self._collapsed_since is None:
                self._collapsed_since = t_s
            elif t_s - self._collapsed_since >= self._confirm_s:
                fall = self._raise(t_s)
        else:
            self._collapsed_since = None

        self.last = FallSignals(
            t=t_s,
            hip_y=hip_y,
            tilt=tilt,
            drop=drop,
            velocity=velocity,
            fell_fast=fell_fast,
            collapsed=collapsed,
            fall=fall,
        )
        return fall

    def _descent(self, t_s: float, hip_y: float) -> tuple[float, float]:
        """Downward hip travel and speed across the window.

        Returns (drop as a fraction of frame height, screen-heights per second),
        both zero if the hips are rising.

        `min_samples` guards the start of a session: with only two samples the
        window spans a single inter-frame gap, where the pose estimator is still
        converging and its jitter is indistinguishable from motion.
        """
        if len(self._history) < self._min_samples:
            return 0.0, 0.0
        t0, y0 = self._history[0]
        dt = t_s - t0
        if dt <= 0:
            return 0.0, 0.0
        drop = hip_y - y0
        if drop <= 0.0:
            return 0.0, 0.0
        return drop, drop / dt

    def _raise(self, t_s: float) -> bool:
        if (
            self._last_alert_t is not None
            and t_s - self._last_alert_t < self._cooldown_s
        ):
            return False
        self._last_alert_t = t_s
        self._collapsed_since = None
        return True
