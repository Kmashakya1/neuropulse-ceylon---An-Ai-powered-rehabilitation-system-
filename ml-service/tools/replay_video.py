"""Feed a video (or webcam) through MediaPipe and into the real session engine.

This is how you tune the angle thresholds in app/config/exercises.yaml without
needing the phone or a dev build. The engine here is byte-for-byte the one the
WebSocket endpoint uses, so thresholds you tune are the thresholds you ship.

    python tools/replay_video.py --exercise shoulder_flexion_left \
        --video "../frontend/assets/videos/exercise/5 Exercises for Stroke Recovery.mp4"

    python tools/replay_video.py --exercise shoulder_flexion_left --camera 0

Press q to quit. --headless skips the preview window (useful over SSH/CI).
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

import cv2
import mediapipe as mp

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from app import exercises as exercise_config  # noqa: E402
from app import keypoints  # noqa: E402
from app.schemas import Keypoint  # noqa: E402
from app.session import Session  # noqa: E402


def to_coco(landmarks) -> list[Keypoint]:
    """MediaPipe's 33 landmarks -> the canonical COCO 17 the engine expects."""
    return [
        Keypoint(
            x=landmarks[src].x,
            y=landmarks[src].y,
            score=landmarks[src].visibility,
        )
        for src in keypoints.MEDIAPIPE_TO_COCO
    ]


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--exercise", required=True)
    parser.add_argument("--video")
    parser.add_argument("--camera", type=int)
    parser.add_argument("--headless", action="store_true")
    parser.add_argument("--max-frames", type=int)
    args = parser.parse_args()

    if (args.video is None) == (args.camera is None):
        parser.error("pass exactly one of --video or --camera")

    catalogue = exercise_config.load()
    config = catalogue.get(args.exercise)
    if config is None:
        parser.error(
            f"unknown exercise {args.exercise!r}; known: {', '.join(sorted(catalogue))}"
        )

    source = args.video if args.video is not None else args.camera
    capture = cv2.VideoCapture(source)
    if not capture.isOpened():
        print(f"ERROR: could not open {source!r}", file=sys.stderr)
        return 1

    fps = capture.get(cv2.CAP_PROP_FPS) or 30.0
    session = Session(config)

    pose = mp.solutions.pose.Pose(
        static_image_mode=False,
        model_complexity=1,
        min_detection_confidence=0.5,
        min_tracking_confidence=0.5,
    )

    frame_index = 0
    last_reps = 0
    try:
        while True:
            ok, frame = capture.read()
            if not ok:
                break
            if args.max_frames and frame_index >= args.max_frames:
                break

            result = pose.process(cv2.cvtColor(frame, cv2.COLOR_BGR2RGB))

            # Device timestamps are milliseconds; derive them from the video clock
            # so replayed timing matches a live session.
            t_ms = (frame_index / fps) * 1000.0
            frame_index += 1

            if not result.pose_landmarks:
                continue

            out = session.push(t_ms, to_coco(result.pose_landmarks.landmark))

            if out.reps != last_reps:
                print(
                    f"[{t_ms / 1000:6.2f}s] rep {out.reps}"
                    f"  angle={out.tracked_angle}"
                    f"  form={out.form_score}"
                )
                last_reps = out.reps
            if out.fall:
                print(f"[{t_ms / 1000:6.2f}s] FALL DETECTED")

            if not args.headless:
                mp.solutions.drawing_utils.draw_landmarks(
                    frame,
                    result.pose_landmarks,
                    mp.solutions.pose.POSE_CONNECTIONS,
                )
                banner = f"{config.name('en')}  reps={out.reps}  phase={out.phase}"
                cv2.putText(
                    frame, banner, (16, 34),
                    cv2.FONT_HERSHEY_SIMPLEX, 0.7, (255, 255, 255), 2,
                )
                for i, cue in enumerate(out.cues):
                    cv2.putText(
                        frame, cue.text, (16, 66 + i * 28),
                        cv2.FONT_HERSHEY_SIMPLEX, 0.6, (0, 200, 255), 2,
                    )
                cv2.imshow("NeuroPulse replay", frame)
                if cv2.waitKey(1) & 0xFF == ord("q"):
                    break
    finally:
        capture.release()
        pose.close()
        if not args.headless:
            cv2.destroyAllWindows()

    summary = session.summary()
    print("\n--- session summary ---")
    for key, value in summary.model_dump().items():
        print(f"{key:18} {value}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
