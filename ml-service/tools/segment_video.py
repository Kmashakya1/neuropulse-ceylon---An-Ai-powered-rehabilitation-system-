"""Find the exercise boundaries in a video that demonstrates several in a row.

Several reference clips are compilations — one clip, five exercises, no chapter
markers. Splitting them by eye and guessing thresholds is how you end up with a
config that never fires. This measures instead: for each short window it asks
which joint moved most, then merges neighbouring windows that agree.

    python tools/segment_video.py --video "path/to/clip.mp4"
    python tools/segment_video.py --video "..." --window 1.5 --min-segment 3

Output is one row per detected segment with its time bounds, the dominant metric,
and that metric's observed range — which is what the `rep` block of an entry in
exercises.yaml needs.
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
from app.schemas import Keypoint  # noqa: E402
from tools.profile_video import METRICS, compute, pct  # noqa: E402


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--video", required=True)
    parser.add_argument(
        "--window",
        type=float,
        default=1.5,
        help="seconds per analysis window; shorter finds more boundaries",
    )
    parser.add_argument(
        "--min-segment",
        type=float,
        default=3.0,
        help="discard segments shorter than this, as they are usually the "
        "transition between two exercises rather than an exercise",
    )
    parser.add_argument("--min-visibility", type=float, default=0.4)
    args = parser.parse_args()

    capture = cv2.VideoCapture(args.video)
    if not capture.isOpened():
        print(f"ERROR: could not open {args.video!r}", file=sys.stderr)
        return 1

    fps = capture.get(cv2.CAP_PROP_FPS) or 30.0
    total = int(capture.get(cv2.CAP_PROP_FRAME_COUNT))
    print(f"{Path(args.video).name}  {fps:.0f}fps  {total / fps:.1f}s")

    pose = mp.solutions.pose.Pose(
        model_complexity=1,
        min_detection_confidence=0.5,
        min_tracking_confidence=0.5,
    )

    # metric -> list of (t_seconds, value)
    series: dict[str, list[tuple[float, float]]] = {n: [] for n in METRICS}
    index = 0
    tracked = 0

    try:
        while True:
            ok, frame = capture.read()
            if not ok:
                break
            t_s = index / fps
            index += 1

            result = pose.process(cv2.cvtColor(frame, cv2.COLOR_BGR2RGB))
            if not result.pose_landmarks:
                continue
            tracked += 1

            lm = result.pose_landmarks.landmark
            kps = [
                Keypoint(x=lm[s].x, y=lm[s].y, score=lm[s].visibility)
                for s in keypoints.MEDIAPIPE_TO_COCO
            ]

            for name, (kind, idx) in METRICS.items():
                if angles.mean_score(kps, list(idx)) < args.min_visibility:
                    continue
                series[name].append((t_s, compute(kind, kps, idx)))
    finally:
        capture.release()
        pose.close()

    print(f"pose found in {tracked}/{index} frames\n")

    # Overall spread per metric, used to normalise: without this a joint whose
    # angle naturally swings 150 degrees always beats one that swings 30, even
    # when the second one is the exercise being performed.
    spread = {
        name: (pct([v for _, v in pts], 95) - pct([v for _, v in pts], 5))
        for name, pts in series.items()
        if len(pts) > 20
    }
    spread = {k: v for k, v in spread.items() if v > 5}
    if not spread:
        print("no metric moved enough to segment on", file=sys.stderr)
        return 1

    duration = index / fps
    windows: list[tuple[float, str, float]] = []
    t = 0.0
    while t < duration:
        end = t + args.window
        best_name, best_score = None, 0.0
        for name, overall in spread.items():
            values = [v for ts, v in series[name] if t <= ts < end]
            if len(values) < 5:
                continue
            local = max(values) - min(values)
            score = local / overall
            if score > best_score:
                best_name, best_score = name, score
        if best_name:
            windows.append((t, best_name, best_score))
        t = end

    # Merge neighbouring windows that agree on the dominant metric.
    segments: list[dict] = []
    for start, name, score in windows:
        if segments and segments[-1]["metric"] == name:
            segments[-1]["end"] = start + args.window
            segments[-1]["scores"].append(score)
        else:
            segments.append(
                {
                    "start": start,
                    "end": start + args.window,
                    "metric": name,
                    "scores": [score],
                }
            )

    kept = [s for s in segments if s["end"] - s["start"] >= args.min_segment]
    dropped = len(segments) - len(kept)

    header = f"  {'#':>2} {'from':>7} {'to':>7} {'metric':26} {'p15':>7} {'p85':>7} {'activity':>9}"
    print(header)
    print("  " + "-" * (len(header) - 2))

    for i, seg in enumerate(kept, start=1):
        values = [
            v for ts, v in series[seg["metric"]] if seg["start"] <= ts < seg["end"]
        ]
        if not values:
            continue
        print(
            f"  {i:2d} {seg['start']:6.1f}s {seg['end']:6.1f}s {seg['metric']:26} "
            f"{pct(values, 15):7.1f} {pct(values, 85):7.1f} "
            f"{statistics.mean(seg['scores']):9.2f}"
        )

    if dropped:
        print(
            f"\n  {dropped} short segment(s) below --min-segment were dropped "
            f"(usually transitions between exercises, not exercises)"
        )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
