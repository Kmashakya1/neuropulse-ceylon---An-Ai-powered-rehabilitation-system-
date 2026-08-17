"""Measure what every candidate metric actually does on a video.

Threshold tuning by guesswork doesn't work -- the useful range for a joint angle
depends on camera framing, which limb leads, and how the movement is performed.
This dumps the real distribution of every metric the engine can track, so
thresholds in exercises.yaml can be picked from data.

    # what moves in this clip?
    python tools/profile_video.py --video "path/to/clip.mp4"

    # propose thresholds for one metric and simulate the rep count
    python tools/profile_video.py --video "..." --suggest left_shoulder_elevation

`--stride N` samples every Nth frame (timestamps stay true to the video clock).
Metrics whose keypoints aren't reliably visible are omitted.
"""

from __future__ import annotations

import argparse
import statistics
import sys
from pathlib import Path

import cv2
import mediapipe as mp

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from app import angles, keypoints  # noqa: E402
from app.rep_counter import RepCounter  # noqa: E402
from app.schemas import Keypoint  # noqa: E402

I = keypoints.INDEX

# name -> (kind, *keypoint indices). Kinds match the YAML metric vocabulary so a
# profiled name maps straight onto a config block.
METRICS: dict[str, tuple[str, tuple[int, ...]]] = {
    # joint: interior angle at vertex between a and b
    "left_elbow": ("joint", (I["left_elbow"], I["left_shoulder"], I["left_wrist"])),
    "right_elbow": ("joint", (I["right_elbow"], I["right_shoulder"], I["right_wrist"])),
    "left_shoulder": ("joint", (I["left_shoulder"], I["left_hip"], I["left_elbow"])),
    "right_shoulder": ("joint", (I["right_shoulder"], I["right_hip"], I["right_elbow"])),
    "left_knee": ("joint", (I["left_knee"], I["left_hip"], I["left_ankle"])),
    "right_knee": ("joint", (I["right_knee"], I["right_hip"], I["right_ankle"])),
    "left_hip": ("joint", (I["left_hip"], I["left_shoulder"], I["left_knee"])),
    "right_hip": ("joint", (I["right_hip"], I["right_shoulder"], I["right_knee"])),
    # elevation: angle of origin->target above horizontal
    "left_shoulder_elevation": ("elevation", (I["left_shoulder"], I["left_wrist"])),
    "right_shoulder_elevation": ("elevation", (I["right_shoulder"], I["right_wrist"])),
    "left_leg_elevation": ("elevation", (I["left_hip"], I["left_ankle"])),
    "right_leg_elevation": ("elevation", (I["right_hip"], I["right_ankle"])),
    # tilt: deviation of top->bottom from vertical
    "left_torso_tilt": ("tilt", (I["left_shoulder"], I["left_hip"])),
    "right_torso_tilt": ("tilt", (I["right_shoulder"], I["right_hip"])),
}


def compute(kind: str, kps: list[Keypoint], idx: tuple[int, ...]) -> float:
    if kind == "joint":
        return angles.joint_angle(kps, idx[0], idx[1], idx[2])
    if kind == "elevation":
        return angles.elevation_angle(kps, idx[0], idx[1])
    return angles.tilt_from_vertical(kps, idx[0], idx[1])


def pct(values: list[float], q: float) -> float:
    ordered = sorted(values)
    pos = min(len(ordered) - 1, max(0, int(round(q / 100 * (len(ordered) - 1)))))
    return ordered[pos]


def suggest(values: list[float]) -> tuple[float, float]:
    """Propose (down_below, up_above) from the distribution's tails.

    p15/p85 rather than min/max, so a couple of tracking spikes can't define the
    thresholds, then pulled inwards to leave a dead band in the middle.
    """
    low, high = pct(values, 15), pct(values, 85)
    span = high - low
    return round(low + span * 0.15), round(high - span * 0.15)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--video", required=True)
    parser.add_argument(
        "--stride",
        type=int,
        help="sample every Nth frame; default spreads --max-frames across the "
        "WHOLE video, which matters because many of these clips open with a "
        "long talking-head intro",
    )
    parser.add_argument("--max-frames", type=int, default=1200)
    parser.add_argument(
        "--from",
        dest="from_s",
        type=float,
        help="only analyse from this timestamp, for compilation clips that "
        "demonstrate several exercises in sequence",
    )
    parser.add_argument("--to", dest="to_s", type=float)
    parser.add_argument("--min-visibility", type=float, default=0.4)
    parser.add_argument("--suggest", help="metric name to propose thresholds for")
    parser.add_argument(
        "--trace",
        help="metric name to print as a time series, so movement cycles can be "
        "counted by eye and compared against the simulated rep count",
    )
    args = parser.parse_args()

    capture = cv2.VideoCapture(args.video)
    if not capture.isOpened():
        print(f"ERROR: could not open {args.video!r}", file=sys.stderr)
        return 1

    fps = capture.get(cv2.CAP_PROP_FPS) or 30.0
    total = int(capture.get(cv2.CAP_PROP_FRAME_COUNT))

    stride = args.stride or max(1, total // args.max_frames)
    # With a computed stride we walk the whole file, so the frame cap must not
    # cut us off early.
    frame_cap = total if args.stride is None else args.max_frames

    print(f"{Path(args.video).name}")
    print(
        f"  {fps:.1f}fps  {total} frames  {total / fps:.1f}s  "
        f"stride={stride}  covering={'whole video' if args.stride is None else 'first %d frames' % frame_cap}"
    )

    pose = mp.solutions.pose.Pose(
        model_complexity=1,
        min_detection_confidence=0.5,
        min_tracking_confidence=0.5,
    )

    samples: dict[str, list[float]] = {name: [] for name in METRICS}
    stamps: dict[str, list[float]] = {name: [] for name in METRICS}
    read = tracked = processed = 0

    try:
        while read < frame_cap:
            ok, frame = capture.read()
            if not ok:
                break
            index = read
            read += 1
            if index % stride:
                continue

            t_s = index / fps
            if args.from_s is not None and t_s < args.from_s:
                continue
            if args.to_s is not None and t_s > args.to_s:
                break

            processed += 1
            result = pose.process(cv2.cvtColor(frame, cv2.COLOR_BGR2RGB))
            if not result.pose_landmarks:
                continue
            tracked += 1

            lm = result.pose_landmarks.landmark
            kps = [
                Keypoint(x=lm[s].x, y=lm[s].y, score=lm[s].visibility)
                for s in keypoints.MEDIAPIPE_TO_COCO
            ]
            t_s = index / fps

            for name, (kind, idx) in METRICS.items():
                if angles.mean_score(kps, list(idx)) < args.min_visibility:
                    continue
                samples[name].append(compute(kind, kps, idx))
                stamps[name].append(t_s)
    finally:
        capture.release()
        pose.close()

    # Report PROCESSED, not read. With a stride and/or a --from/--to window those
    # differ by a lot, and quoting "found / read" makes detection look far worse
    # than it is.
    rate = (100.0 * tracked / processed) if processed else 0.0
    print(
        f"  frames read={read}  processed={processed}  "
        f"pose_found={tracked} ({rate:.0f}%)\n"
    )
    header = f"  {'metric':26} {'n':>5} {'min':>7} {'p15':>7} {'p50':>7} {'p85':>7} {'max':>7} {'range':>7}"
    print(header)
    print("  " + "-" * (len(header) - 2))

    ranked = []
    for name, values in samples.items():
        if len(values) < 20:
            continue
        spread = pct(values, 85) - pct(values, 15)
        ranked.append((spread, name))
        print(
            f"  {name:26} {len(values):5d} {min(values):7.1f} {pct(values, 15):7.1f} "
            f"{statistics.median(values):7.1f} {pct(values, 85):7.1f} "
            f"{max(values):7.1f} {spread:7.1f}"
        )

    ranked.sort(reverse=True)
    if ranked:
        print("\n  most active metrics (widest p15-p85 spread):")
        for spread, name in ranked[:4]:
            print(f"    {name:26} spread={spread:6.1f}")

    if args.trace:
        values = samples.get(args.trace)
        if not values:
            print(f"\n  no samples for {args.trace!r}", file=sys.stderr)
            return 1
        times = stamps[args.trace]
        low, high = min(values), max(values)
        span = (high - low) or 1.0
        ramp = " .:-=+*#%@"
        print(f"\n  trace {args.trace}  ({low:.0f} .. {high:.0f})")
        # One row per second, so a full movement cycle is easy to spot.
        row: list[str] = []
        second = int(times[0])
        for value, t_s in zip(values, times):
            if int(t_s) != second:
                print(f"    {second:5d}s |{''.join(row)}")
                row, second = [], int(t_s)
            ramp_index = int((value - low) / span * (len(ramp) - 1))
            row.append(ramp[ramp_index])
        if row:
            print(f"    {second:5d}s |{''.join(row)}")

    if args.suggest:
        values = samples.get(args.suggest)
        if not values:
            print(f"\n  no samples for {args.suggest!r}", file=sys.stderr)
            return 1
        down, up = suggest(values)
        print(f"\n  suggested for {args.suggest}:")
        print(f"    down_below: {down}")
        print(f"    up_above:   {up}")

        counter = RepCounter(down, up, min_interval_s=0.6)
        for value, t_s in zip(values, stamps[args.suggest]):
            counter.update(value, t_s)
        print(f"    -> {counter.reps} reps over {stamps[args.suggest][-1]:.1f}s")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
