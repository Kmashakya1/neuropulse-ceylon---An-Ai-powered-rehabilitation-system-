"""Synthesise a fall clip from footage of someone standing.

WHAT THIS IS. There is no recorded fall in this project, so the true-positive path
has only ever been checked against hand-built keypoints. This makes a real video
file: a real person, tracked by the real MediaPipe pipeline, whose hips descend at
a velocity we choose. It closes the gap between "the maths works on synthetic
numbers" and "the service raises an alert from a camera feed".

WHAT THIS IS NOT. It is a geometric warp of standing footage, not a person
falling. The frame is rotated toward horizontal and slid down, which produces the
signal profile of a fall -- fast hip descent, ending low with a horizontal torso --
without the things that make real falls hard: flailing limbs, self-occlusion,
motion blur, camera shake, and the pose estimator losing the body part-way down.
Passing this proves the pipeline is wired up and the thresholds are reachable. It
does not prove the detector works on a real fall. For that, either record a
controlled collapse onto a crash mat, or use a published dataset (see README).

    # default: 2s standing, 0.25s collapse, 3s on the floor
    python tools/make_fall_clip.py --source ../frontend_flutter/.../shoulder_flexion.mp4

    # a slow controlled lie-down -- the negative control, must NOT alert
    python tools/make_fall_clip.py --source "..." --out slow_liedown.mp4 --fall-s 4.0

    # probe the boundary: how fast does it have to be?
    python tools/make_fall_clip.py --source "..." --out edge.mp4 --fall-s 1.2

Then measure what the detector makes of it:

    python tools/fall_probe.py --video out/fall_fast.mp4 --trace
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

import cv2
import mediapipe as mp

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from app import keypoints  # noqa: E402

_L_HIP = keypoints.INDEX["left_hip"]
_R_HIP = keypoints.INDEX["right_hip"]


def hip_centre(frame) -> tuple[float, float] | None:
    """Where the subject's hips are, in pixels.

    The warp has to rotate about this point rather than the frame centre. Rotating
    about the centre lifts a subject standing below it almost as much as the
    translation pushes them down -- the first version of this tool cancelled itself
    out that way and produced a clip whose hips travelled 0.054 of frame height
    when 0.30 was requested.
    """
    height, width = frame.shape[:2]
    with mp.solutions.pose.Pose(
        static_image_mode=True, model_complexity=1, min_detection_confidence=0.5
    ) as pose:
        result = pose.process(cv2.cvtColor(frame, cv2.COLOR_BGR2RGB))
    if not result.pose_landmarks:
        return None
    lm = result.pose_landmarks.landmark
    left = lm[keypoints.MEDIAPIPE_TO_COCO[_L_HIP]]
    right = lm[keypoints.MEDIAPIPE_TO_COCO[_R_HIP]]
    return (
        (left.x + right.x) / 2.0 * width,
        (left.y + right.y) / 2.0 * height,
    )


def build(
    source: Path,
    out: Path,
    *,
    stand_s: float,
    fall_s: float,
    floor_s: float,
    drop_fraction: float,
    end_angle: float,
) -> dict[str, float]:
    capture = cv2.VideoCapture(str(source))
    if not capture.isOpened():
        raise RuntimeError(f"could not open {source}")

    fps = capture.get(cv2.CAP_PROP_FPS) or 30.0
    width = int(capture.get(cv2.CAP_PROP_FRAME_WIDTH))
    height = int(capture.get(cv2.CAP_PROP_FRAME_HEIGHT))

    frames: list = []
    while True:
        ok, frame = capture.read()
        if not ok:
            break
        frames.append(frame)
    capture.release()

    if not frames:
        raise RuntimeError(f"{source} contained no readable frames")

    pivot = hip_centre(frames[0])
    if pivot is None:
        raise RuntimeError(
            f"no pose found in the first frame of {source.name}; "
            "pick a clip where the whole body is visible from the start"
        )

    out.parent.mkdir(parents=True, exist_ok=True)
    writer = cv2.VideoWriter(
        str(out), cv2.VideoWriter_fourcc(*"mp4v"), fps, (width, height)
    )
    if not writer.isOpened():
        raise RuntimeError(f"could not open {out} for writing")

    stand_n = max(1, round(stand_s * fps))
    fall_n = max(1, round(fall_s * fps))
    floor_n = max(1, round(floor_s * fps))

    # Pixels the subject travels down. Expressed as a fraction of frame height so
    # it lines up directly with what the detector measures.
    drop_px = drop_fraction * height

    def warped(frame, progress: float):
        """progress 0 = upright and in place, 1 = rotated and fully dropped."""
        # Ease nothing: a linear ramp keeps the velocity constant and therefore
        # predictable, which is the entire point of a calibration clip.
        angle = end_angle * progress
        # Pivot on the hips, so rotation contributes no vertical travel and the
        # descent is exactly the translation below.
        matrix = cv2.getRotationMatrix2D(pivot, angle, 1.0)
        matrix[1][2] += drop_px * progress
        return cv2.warpAffine(
            frame,
            matrix,
            (width, height),
            flags=cv2.INTER_LINEAR,
            borderMode=cv2.BORDER_REPLICATE,
        )

    written = 0

    # 1. Standing. Loops the source if it is shorter than the requested time, so
    #    the velocity window is fully settled before anything moves.
    for i in range(stand_n):
        writer.write(frames[i % len(frames)])
        written += 1

    # 2. The collapse.
    for i in range(fall_n):
        progress = (i + 1) / fall_n
        writer.write(warped(frames[(stand_n + i) % len(frames)], progress))
        written += 1

    # 3. On the floor, still fully warped.
    #
    #    Keeps advancing through the source rather than freezing one frame. An
    #    earlier version froze a single frame, and which frame it landed on was a
    #    lottery: for --fall-s 0.35 the chosen frame happened not to be trackable
    #    once rotated, so all 90 floor frames went undetected, the clip reported
    #    41% pose coverage, and it failed to alert while both 0.30 and 0.40
    #    alerted. A non-monotonic calibration tool is a misleading one.
    for i in range(floor_n):
        writer.write(warped(frames[(stand_n + fall_n + i) % len(frames)], 1.0))
        written += 1

    writer.release()

    return {
        "fps": fps,
        "frames": written,
        "seconds": written / fps,
        "expected_velocity": drop_fraction / fall_s,
        "expected_drop": drop_fraction,
        "hip_start": pivot[1] / height,
        "hip_end": pivot[1] / height + drop_fraction,
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--source",
        required=True,
        help="clip of someone standing, ideally tracked reliably by MediaPipe",
    )
    parser.add_argument("--out", default="out/fall_fast.mp4")
    parser.add_argument("--stand-s", type=float, default=2.0)
    parser.add_argument(
        "--fall-s",
        type=float,
        default=0.25,
        help="collapse duration. Raise it to make a slow lie-down negative control.",
    )
    parser.add_argument("--floor-s", type=float, default=3.0)
    parser.add_argument(
        "--drop-fraction",
        type=float,
        default=0.25,
        help="how far the subject travels down, as a fraction of frame height",
    )
    # 70 degrees clears the 55 degree tilt gate with margin while staying inside
    # what MediaPipe can still track. At 80 the pose was found in only 43% of
    # frames and the floor phase went entirely undetected, so nothing confirmed.
    parser.add_argument("--end-angle", type=float, default=70.0)
    args = parser.parse_args()

    try:
        info = build(
            Path(args.source),
            Path(args.out),
            stand_s=args.stand_s,
            fall_s=args.fall_s,
            floor_s=args.floor_s,
            drop_fraction=args.drop_fraction,
            end_angle=args.end_angle,
        )
    except RuntimeError as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return 1

    print(f"wrote {args.out}")
    print(
        f"  {info['fps']:.1f}fps  {int(info['frames'])} frames  "
        f"{info['seconds']:.1f}s"
    )
    print(
        f"  by construction: {info['expected_drop']:.2f} of frame height over "
        f"{args.fall_s}s = {info['expected_velocity']:.2f} heights/s"
    )
    print(
        f"  hips {info['hip_start']:.3f} -> {info['hip_end']:.3f} of frame height"
    )
    if info["hip_end"] > 0.98:
        print(
            "  WARNING: the hips end off the bottom of the frame. Lower\n"
            "           --drop-fraction, or use a source where the subject\n"
            "           stands higher in shot."
        )
    print(f"  measure it: python tools/fall_probe.py --video {args.out}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
