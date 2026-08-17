"""Pose estimation from camera frames sent by the app.

The keypoint endpoint (/ws/session) expects the device to have run pose
estimation itself. Flutter streams raw camera frames instead, which keeps the
phone simple and reuses the MediaPipe pipeline already validated by
tools/replay_video.py.

WIRE FORMAT (binary, per frame)

    [0:8]   uint64 big-endian  capture time in milliseconds
    [8]     uint8              pixel format
    [9:11]  uint16 big-endian  width
    [11:13] uint16 big-endian  height
    [13:]   pixel data

    format 0 = JPEG      (width/height ignored, read from the JPEG itself)
    format 2 = NV21      (single contiguous plane, width*height*3/2 bytes)

NV21 is what Android hands over when the camera plugin is asked for
`ImageFormatGroup.nv21`: one plane, no per-plane row/pixel strides to
reassemble, and OpenCV converts it in a single call. Asking for the default
YUV_420_888 instead means dealing with three planes whose strides vary by device,
which is a lot of fiddly Dart for no benefit.

The timestamp comes from the device rather than arrival time because fall
detection differentiates hip height over time — network jitter would otherwise
read as phantom acceleration. Only differences are used, so any monotonic device
clock works.

MEASURED TRADEOFFS

Against the reference clip, MediaPipe found a pose in:

    colour  640x480   93% of frames    form 0.99
    colour  320x240   96% of frames    form 0.99
    grey    640x480   80% of frames    form 0.98
    grey    320x240   81% of frames    form 0.97

Two conclusions worth keeping: low resolution is essentially free, so stream
small; and greyscale is NOT free, so do not "save bandwidth" by sending only the
Y plane. Rep counts happened to survive on this clip, but a 15-point drop in
detection rate means more dropped frames and jumpier feedback on a real patient.

At 320x240 NV21 a frame is ~115KB, so 10-12fps is roughly 1.2MB/s — fine on a
LAN, unsuitable over mobile data. If that becomes a problem, move pose on-device
(Flutter has google_mlkit_pose_detection) and switch to the keypoint endpoint;
the engine behind both is the same, which is why session.py takes keypoints
rather than pixels.
"""

from __future__ import annotations

from dataclasses import dataclass

import cv2
import mediapipe as mp
import numpy as np

from . import keypoints
from .schemas import Keypoint

FORMAT_JPEG = 0
FORMAT_NV21 = 2

HEADER_BYTES = 13


class FrameDecodeError(Exception):
    """Raised for a malformed frame envelope, as opposed to an undecodable image."""


@dataclass(frozen=True)
class IncomingFrame:
    t_ms: float
    pixel_format: int
    width: int
    height: int
    data: bytes


def parse_envelope(payload: bytes) -> IncomingFrame:
    if len(payload) <= HEADER_BYTES:
        raise FrameDecodeError("frame shorter than its header")

    return IncomingFrame(
        t_ms=float(int.from_bytes(payload[0:8], "big")),
        pixel_format=payload[8],
        width=int.from_bytes(payload[9:11], "big"),
        height=int.from_bytes(payload[11:13], "big"),
        data=payload[HEADER_BYTES:],
    )


def to_bgr(frame: IncomingFrame) -> np.ndarray | None:
    """Decode the payload to BGR, or None if it cannot be decoded."""
    if frame.pixel_format == FORMAT_JPEG:
        buffer = np.frombuffer(frame.data, dtype=np.uint8)
        return cv2.imdecode(buffer, cv2.IMREAD_COLOR)

    if frame.pixel_format == FORMAT_NV21:
        expected = frame.width * frame.height * 3 // 2
        if frame.width <= 0 or frame.height <= 0 or len(frame.data) < expected:
            return None
        # NV21 is a full-height Y plane followed by a half-height interleaved VU
        # plane, so the buffer reshapes to height*3/2 rows.
        yuv = np.frombuffer(frame.data[:expected], dtype=np.uint8).reshape(
            frame.height * 3 // 2, frame.width
        )
        return cv2.cvtColor(yuv, cv2.COLOR_YUV2BGR_NV21)

    raise FrameDecodeError(f"unsupported pixel format {frame.pixel_format}")


class PoseEstimator:
    """Wraps one MediaPipe Pose instance.

    MediaPipe's Pose object holds per-stream tracking state and is not safe to
    share between connections, so each session owns one. `model_complexity=1` is
    the middle model; complexity 0 is noticeably worse on partial-body and seated
    poses, which is most of this app's use.
    """

    def __init__(self, model_complexity: int = 1):
        self._pose = mp.solutions.pose.Pose(
            static_image_mode=False,
            model_complexity=model_complexity,
            min_detection_confidence=0.5,
            min_tracking_confidence=0.5,
        )

    def keypoints_from_frame(self, frame: IncomingFrame) -> list[Keypoint] | None:
        """Return the canonical COCO 17, or None if no pose was found.

        None rather than an exception for an undecodable frame: a corrupt frame
        mid-stream should drop, not end the session.
        """
        bgr = to_bgr(frame)
        if bgr is None:
            return None

        result = self._pose.process(cv2.cvtColor(bgr, cv2.COLOR_BGR2RGB))
        if not result.pose_landmarks:
            return None

        landmarks = result.pose_landmarks.landmark
        return [
            Keypoint(
                x=landmarks[src].x,
                y=landmarks[src].y,
                score=landmarks[src].visibility,
            )
            for src in keypoints.MEDIAPIPE_TO_COCO
        ]

    def close(self) -> None:
        self._pose.close()
