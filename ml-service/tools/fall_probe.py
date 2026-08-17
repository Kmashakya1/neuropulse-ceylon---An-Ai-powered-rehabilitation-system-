"""Measure what the fall detector actually sees in a video.

The thresholds in app/fall.py are the only ones in the service derived from
geometry rather than from footage, because there was no fall video to measure.
This tool closes that gap from both directions:

  1. FALSE POSITIVES -- run it over the existing exercise clips. Any alert there
     is a false alarm, and the floor exercises (supine and prone hamstring curls)
     are the highest risk because the patient really is lying down.

  2. TRUE POSITIVES -- run it over a recorded fall and read `peak descent` off
     the summary. That number is what `drop_velocity` should sit below.

    # is anything close to firing on a normal exercise clip?
    python tools/fall_probe.py --video "path/to/hamstring_curl_supine.mp4"

    # every clip in a folder, one line each
    python tools/fall_probe.py --dir ../frontend_flutter/NeuroPulseCeylon/assets/videos

    # frame-by-frame, to see exactly where a gate opens and closes
    python tools/fall_probe.py --video "path/to/fall.mp4" --trace

    # would a lower threshold have caught it? (does not change the config)
    python tools/fall_probe.py --video "path/to/fall.mp4" --drop-velocity 0.25

Reports the three gates separately, because "no alert" is not one fact: a clip
can drop fast enough and never end up horizontal, which is a very different
result from never dropping at all.
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

import cv2
import mediapipe as mp

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from app import angles, keypoints  # noqa: E402
from app.fall import FallDetector, FallSignals  # noqa: E402
from app.schemas import Keypoint  # noqa: E402

I = keypoints.INDEX
_L_HIP = I["left_hip"]
_R_HIP = I["right_hip"]
_L_SHOULDER = I["left_shoulder"]

VIDEO_SUFFIXES = {".mp4", ".mov", ".avi", ".mkv"}


# BGR, because OpenCV. Loosely matched to the app's tokens so annotated frames
# read as the same product when they end up in a report.
_INK = (75, 27, 8)
_WHITE = (255, 255, 255)
_MUTED = (139, 116, 100)
_BRAND = (125, 139, 15)
_DANGER = (38, 38, 220)
_WARN = (6, 118, 217)
_FONT = cv2.FONT_HERSHEY_SIMPLEX


def _panel(frame, x: int, y: int, w: int, h: int, alpha: float = 0.75) -> None:
    """Translucent card, so the readout stays legible over any footage."""
    region = frame[y : y + h, x : x + w]
    if region.size == 0:
        return
    card = region.copy()
    card[:] = (250, 247, 245)
    frame[y : y + h, x : x + w] = cv2.addWeighted(card, alpha, region, 1 - alpha, 0)


def _chip(frame, x: int, y: int, label: str, lit: bool, s: float = 1.0) -> int:
    """One gate indicator. Returns the x for the next chip."""
    scale = 0.5 * s
    (tw, th), _ = cv2.getTextSize(label, _FONT, scale, 1)
    w, h = tw + int(16 * s), th + int(12 * s)
    cv2.rectangle(frame, (x, y), (x + w, y + h), _BRAND if lit else (215, 215, 215), -1)
    cv2.putText(
        frame, label, (x + int(8 * s), y + h - int(6 * s)), _FONT, scale,
        _WHITE if lit else _MUTED, 1, cv2.LINE_AA,
    )
    return x + w + int(6 * s)


def _readout(frame, row, limits, trail) -> None:
    """Numbers, gate chips, velocity bar and the hip trail, for one tracked frame.

    Laid out against the frame width rather than fixed pixels: the reference clips
    are portrait 360x640, where a 340px panel clipped the threshold column off the
    right edge and the timestamp landed on top of the numbers.
    """
    h, w = frame.shape[:2]

    pad = 10
    panel_w = min(w - 2 * pad, 340)
    # Shrink text on a narrow frame, but never below readable.
    s = max(0.62, min(1.0, panel_w / 340))
    line_h = int(24 * s)
    panel_h = line_h * 5 + int(14 * s)

    _panel(frame, pad, pad, panel_w, panel_h)

    # The timestamp lives inside the panel, so it cannot collide with anything.
    cv2.putText(frame, f"t = {row.t:5.2f}s", (pad + 12, pad + int(20 * s)),
                _FONT, 0.5 * s, _INK, 1, cv2.LINE_AA)

    rows = [
        ("hip_y", f"{row.hip_y:.3f}", f">={limits['min_hip_y']}",
         row.hip_y >= limits["min_hip_y"]),
        ("tilt", f"{row.tilt:.0f}deg", f">={limits['min_tilt']:.0f}",
         row.tilt >= limits["min_tilt"]),
        ("drop", f"{row.drop:.3f}", f">={limits['min_drop']}",
         row.drop >= limits["min_drop"]),
        ("vel", f"{row.velocity:.3f}", f">={limits['drop_velocity']}",
         row.velocity >= limits["drop_velocity"]),
    ]
    col_name = pad + 12
    col_value = pad + int(panel_w * 0.30)
    col_want = pad + int(panel_w * 0.66)
    for i, (name, value, want, ok) in enumerate(rows):
        y = pad + int(20 * s) + (i + 1) * line_h
        cv2.putText(frame, name, (col_name, y), _FONT, 0.46 * s, _MUTED, 1, cv2.LINE_AA)
        cv2.putText(frame, value, (col_value, y), _FONT, 0.56 * s,
                    _BRAND if ok else _INK, 2, cv2.LINE_AA)
        cv2.putText(frame, want, (col_want, y), _FONT, 0.42 * s, _MUTED, 1, cv2.LINE_AA)

    chip_y = pad + panel_h + 8
    x = _chip(frame, pad, chip_y, "FAST", row.fell_fast, s)
    x = _chip(frame, x, chip_y, "LOW", row.hip_y >= limits["min_hip_y"], s)
    _chip(frame, x, chip_y, "HORIZ", row.tilt >= limits["min_tilt"], s)

    # Velocity against its threshold, which sits at mid-scale. Makes "how close
    # was that" readable without parsing the number.
    bar_w = panel_w
    bar_y = chip_y + int(34 * s)
    cv2.rectangle(frame, (pad, bar_y), (pad + bar_w, bar_y + 10), (225, 225, 225), -1)
    span = max(limits["drop_velocity"] * 2.0, 1e-6)
    filled = int(min(1.0, row.velocity / span) * bar_w)
    cv2.rectangle(frame, (pad, bar_y), (pad + filled, bar_y + 10),
                  _DANGER if row.fell_fast else _BRAND, -1)
    cv2.line(frame, (pad + bar_w // 2, bar_y - 5),
             (pad + bar_w // 2, bar_y + 15), _INK, 2)

    # Where the hips are, and where they have been.
    for i in range(1, len(trail)):
        cv2.line(frame, trail[i - 1], trail[i], (200, 190, 120), 2, cv2.LINE_AA)
    if trail:
        cv2.circle(frame, trail[-1], 9, _WHITE, -1, cv2.LINE_AA)
        cv2.circle(frame, trail[-1], 9,
                   _DANGER if row.collapsed else _BRAND, 3, cv2.LINE_AA)

    # The hip-height threshold as a line the eye can check the body against.
    y_low = int(limits["min_hip_y"] * h)
    cv2.line(frame, (0, y_low), (w, y_low), (185, 185, 185), 1, cv2.LINE_AA)
    cv2.putText(frame, "min_hip_y", (w - 120, y_low - 8), _FONT, 0.42,
                (155, 155, 155), 1, cv2.LINE_AA)


def _emit(frame, writer, show: bool) -> None:
    if writer is not None:
        writer.write(frame)
    if show:
        cv2.imshow("fall probe", frame)
        cv2.waitKey(1)


def _banner(frame, text: str, colour) -> None:
    h, w = frame.shape[:2]
    # Shrink to fit rather than running off the edge of a portrait frame.
    scale, thick = 1.0, 3
    (tw, th), _ = cv2.getTextSize(text, _FONT, scale, thick)
    while tw > w - 24 and scale > 0.4:
        scale -= 0.05
        thick = 2 if scale < 0.75 else 3
        (tw, th), _ = cv2.getTextSize(text, _FONT, scale, thick)
    y = h - int(30 * scale)
    cv2.rectangle(frame, (0, y - th - 18), (w, y + 14), colour, -1)
    cv2.putText(frame, text, ((w - tw) // 2, y), _FONT, scale, _WHITE, thick,
                cv2.LINE_AA)


class Probe:
    """Thin adapter over FallDetector.

    It reads the detector's own FallSignals rather than recomputing hip_y, tilt
    and velocity alongside it. An earlier version did recompute them and measured
    its window one frame stale, under-reporting every peak -- a probe that
    disagrees with the thing it measures is worse than no probe.
    """

    def __init__(self, **overrides: float):
        self.detector = FallDetector(**overrides)
        self.limits = {
            "drop_velocity": self.detector._drop_velocity,
            "min_drop": self.detector._min_drop,
            "min_hip_y": self.detector._min_hip_y,
            "min_tilt": self.detector._min_tilt,
            "confirm_s": self.detector._confirm_s,
        }

    def push(self, kps: list[Keypoint], t_s: float) -> FallSignals:
        self.detector.update(kps, t_s)
        assert self.detector.last is not None
        return self.detector.last


def probe_video(
    path: Path,
    *,
    stride: int,
    min_visibility: float,
    trace: bool,
    overrides: dict[str, float],
    render: Path | None = None,
    show: bool = False,
) -> dict[str, object]:
    capture = cv2.VideoCapture(str(path))
    if not capture.isOpened():
        raise RuntimeError(f"could not open {path}")

    fps = capture.get(cv2.CAP_PROP_FPS) or 30.0
    total = int(capture.get(cv2.CAP_PROP_FRAME_COUNT))

    pose = mp.solutions.pose.Pose(
        model_complexity=1,
        min_detection_confidence=0.5,
        min_tracking_confidence=0.5,
    )
    probe = Probe(**overrides)

    writer = None
    if render is not None:
        render.parent.mkdir(parents=True, exist_ok=True)
        size = (
            int(capture.get(cv2.CAP_PROP_FRAME_WIDTH)),
            int(capture.get(cv2.CAP_PROP_FRAME_HEIGHT)),
        )
        writer = cv2.VideoWriter(
            str(render), cv2.VideoWriter_fourcc(*"mp4v"), fps / max(1, stride), size
        )
        if not writer.isOpened():
            raise RuntimeError(f"could not open {render} for writing")

    trail: list[tuple[int, int]] = []
    # Holds the banner on screen long enough to read, rather than for the single
    # frame on which the detector returns True.
    alert_hold = 0

    read = processed = tracked = 0
    peak_velocity = 0.0
    peak_velocity_t = 0.0
    peak_drop = 0.0
    max_hip_y = 0.0
    max_tilt = 0.0
    frames_fast = frames_low = frames_horizontal = frames_collapsed = 0
    alerts: list[float] = []

    if trace:
        print("      t     hip_y   tilt   drop   vel    fast collapsed")

    try:
        while True:
            ok, frame = capture.read()
            if not ok:
                break
            index = read
            read += 1
            if index % stride:
                continue
            processed += 1

            drawing = frame.copy() if (writer is not None or show) else None

            result = pose.process(cv2.cvtColor(frame, cv2.COLOR_BGR2RGB))
            if not result.pose_landmarks:
                # Rendered rather than skipped: losing the pose mid-descent is the
                # detector's dominant failure mode, so it has to be visible.
                if drawing is not None:
                    _banner(drawing, "POSE LOST", _WARN)
                    _emit(drawing, writer, show)
                continue

            lm = result.pose_landmarks.landmark
            kps = [
                Keypoint(x=lm[s].x, y=lm[s].y, score=lm[s].visibility)
                for s in keypoints.MEDIAPIPE_TO_COCO
            ]
            # The detector only ever sees frames the session considers visible,
            # so skipping here matches production rather than being generous.
            if (
                angles.mean_score(kps, [_L_HIP, _R_HIP, _L_SHOULDER])
                < min_visibility
            ):
                if drawing is not None:
                    _banner(drawing, "LOW CONFIDENCE", _WARN)
                    _emit(drawing, writer, show)
                continue
            tracked += 1

            row = probe.push(kps, index / fps)

            if row.velocity > peak_velocity:
                peak_velocity = row.velocity
                peak_velocity_t = row.t
            peak_drop = max(peak_drop, row.drop)
            max_hip_y = max(max_hip_y, row.hip_y)
            max_tilt = max(max_tilt, row.tilt)
            frames_fast += row.fell_fast
            frames_low += row.hip_y >= probe.limits["min_hip_y"]
            frames_horizontal += row.tilt >= probe.limits["min_tilt"]
            frames_collapsed += row.collapsed
            if row.fall:
                alerts.append(row.t)

            if drawing is not None:
                mp.solutions.drawing_utils.draw_landmarks(
                    drawing,
                    result.pose_landmarks,
                    mp.solutions.pose.POSE_CONNECTIONS,
                )
                dh, dw = drawing.shape[:2]
                hip_x = (
                    lm[keypoints.MEDIAPIPE_TO_COCO[_L_HIP]].x
                    + lm[keypoints.MEDIAPIPE_TO_COCO[_R_HIP]].x
                ) / 2.0
                trail.append((int(hip_x * dw), int(row.hip_y * dh)))
                del trail[:-45]
                _readout(drawing, row, probe.limits, trail)
                if row.fall:
                    alert_hold = int(round(2.0 * fps / max(1, stride)))
                if alert_hold > 0:
                    _banner(drawing, "FALL DETECTED", _DANGER)
                    alert_hold -= 1
                elif row.collapsed:
                    _banner(drawing, "COLLAPSED - confirming", _WARN)
                _emit(drawing, writer, show)

            if trace:
                print(
                    f"  {row.t:7.2f}  {row.hip_y:.3f}  {row.tilt:5.1f}"
                    f"  {row.drop:.3f}  {row.velocity:.3f}  "
                    f"{'Y' if row.fell_fast else '.'}    "
                    f"{'Y' if row.collapsed else '.'}"
                    f"{'   <-- FALL' if row.fall else ''}"
                )
    finally:
        capture.release()
        pose.close()
        if writer is not None:
            writer.release()
        if show:
            cv2.destroyAllWindows()

    return {
        "name": path.name,
        "fps": fps,
        "total": total,
        "seconds": total / fps if fps else 0.0,
        "read": read,
        "processed": processed,
        "tracked": tracked,
        "peak_velocity": peak_velocity,
        "peak_velocity_t": peak_velocity_t,
        "peak_drop": peak_drop,
        "max_hip_y": max_hip_y,
        "max_tilt": max_tilt,
        "frames_fast": frames_fast,
        "frames_low": frames_low,
        "frames_horizontal": frames_horizontal,
        "frames_collapsed": frames_collapsed,
        "alerts": alerts,
        "limits": probe.limits,
        "render": str(render) if render else None,
    }


def report(r: dict[str, object]) -> None:
    limits = r["limits"]
    tracked = int(r["tracked"])
    processed = int(r["processed"])
    share = f"{100 * tracked / processed:.0f}%" if processed else "n/a"

    print(f"\n{r['name']}")
    print(
        f"  {r['fps']:.1f}fps  {r['total']} frames  {r['seconds']:.1f}s  "
        f"processed={processed}  pose found={tracked} ({share})"
    )
    print(
        f"  peak descent   {r['peak_velocity']:.3f} screen-heights/s "
        f"at {r['peak_velocity_t']:.2f}s   (threshold {limits['drop_velocity']})"
    )
    print(
        f"  peak drop      {r['peak_drop']:.3f} of frame height"
        f"              (threshold {limits['min_drop']})"
    )
    print(
        f"  lowest hips    {r['max_hip_y']:.3f}"
        f"                        (threshold {limits['min_hip_y']})"
    )
    print(
        f"  max torso tilt {r['max_tilt']:.1f}deg"
        f"                          (threshold {limits['min_tilt']})"
    )
    print(
        f"  frames  fast={r['frames_fast']}  low={r['frames_low']}  "
        f"horizontal={r['frames_horizontal']}  low+horizontal={r['frames_collapsed']}"
    )

    alerts = r["alerts"]
    if alerts:
        stamps = ", ".join(f"{t:.2f}s" for t in alerts)  # type: ignore[union-attr]
        print(f"  ALERT at {stamps}")
    else:
        # Say which gate held, because "no alert" for the right reason and for
        # the wrong reason look identical otherwise.
        if not r["frames_fast"]:
            why = "never descended fast enough, or far enough, to count"
        elif not r["frames_collapsed"]:
            why = "descended fast but never ended up low AND horizontal"
        else:
            why = (
                f"collapsed but not for the full {limits['confirm_s']}s "
                "confirmation window"
            )
        print(f"  no alert       ({why})")


def main() -> int:
    parser = argparse.ArgumentParser()
    source = parser.add_mutually_exclusive_group(required=True)
    source.add_argument("--video", help="one clip")
    source.add_argument("--dir", help="every video in this folder")
    parser.add_argument("--stride", type=int, default=1)
    parser.add_argument("--min-visibility", type=float, default=0.3)
    parser.add_argument("--trace", action="store_true", help="print every frame")
    parser.add_argument(
        "--render",
        help="write an annotated mp4 here; pass a folder when using --dir",
    )
    parser.add_argument("--show", action="store_true", help="live preview window")
    # Overrides are for asking "what would this threshold have done"; they do not
    # touch app/fall.py.
    parser.add_argument("--drop-velocity", type=float)
    parser.add_argument("--min-drop", type=float)
    parser.add_argument("--min-hip-y", type=float)
    parser.add_argument("--min-tilt", type=float)
    parser.add_argument("--confirm-s", type=float)
    args = parser.parse_args()

    overrides = {
        name: value
        for name, value in (
            ("drop_velocity", args.drop_velocity),
            ("min_drop", args.min_drop),
            ("min_hip_y", args.min_hip_y),
            ("min_tilt", args.min_tilt),
            ("confirm_s", args.confirm_s),
        )
        if value is not None
    }
    if overrides:
        print(f"OVERRIDES (not saved to config): {overrides}")

    if args.video:
        paths = [Path(args.video)]
    else:
        folder = Path(args.dir)
        paths = sorted(
            p for p in folder.iterdir() if p.suffix.lower() in VIDEO_SUFFIXES
        )
        if not paths:
            print(f"ERROR: no videos in {folder}", file=sys.stderr)
            return 1

    alerted: list[str] = []
    for path in paths:
        try:
            target = None
            if args.render:
                given = Path(args.render)
                # One clip -> that exact filename. A folder of clips, or a path
                # with no suffix -> a matching file inside the folder.
                target = (
                    given / f"{path.stem}_annotated.mp4"
                    if len(paths) > 1 or given.suffix == ""
                    else given
                )
            result = probe_video(
                path,
                stride=args.stride,
                min_visibility=args.min_visibility,
                trace=args.trace,
                overrides=overrides,
                render=target,
                show=args.show,
            )
        except RuntimeError as exc:
            print(f"\n{path.name}\n  ERROR: {exc}", file=sys.stderr)
            continue
        report(result)
        if result["render"]:
            print(f"  rendered       {result['render']}")
        if result["alerts"]:
            alerted.append(str(result["name"]))

    if len(paths) > 1:
        print(f"\n{'-' * 60}")
        if alerted:
            print(f"ALERTED on {len(alerted)}/{len(paths)}: {', '.join(alerted)}")
            print("On exercise footage every one of these is a false alarm.")
        else:
            print(f"No alerts on any of {len(paths)} clips.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
