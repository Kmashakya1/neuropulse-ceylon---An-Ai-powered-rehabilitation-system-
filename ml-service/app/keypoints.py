"""Canonical keypoint set shared by every producer.

The phone runs MoveNet (via react-native-fast-tflite), which emits COCO's 17
keypoints. MediaPipe -- used by tools/replay_video.py -- emits 33. We normalise
on the COCO 17 so the engine never has to care which model produced a frame.

Coordinates are normalised to [0, 1] with the origin at the TOP-LEFT, so y
INCREASES downwards. Every bit of geometry in this package assumes that.
"""

from __future__ import annotations

NAMES: tuple[str, ...] = (
    "nose",
    "left_eye",
    "right_eye",
    "left_ear",
    "right_ear",
    "left_shoulder",
    "right_shoulder",
    "left_elbow",
    "right_elbow",
    "left_wrist",
    "right_wrist",
    "left_hip",
    "right_hip",
    "left_knee",
    "right_knee",
    "left_ankle",
    "right_ankle",
)

INDEX: dict[str, int] = {name: i for i, name in enumerate(NAMES)}

COUNT = len(NAMES)

# MediaPipe Pose (33 landmarks) -> COCO 17. MediaPipe's indices are documented at
# https://ai.google.dev/edge/mediapipe/solutions/vision/pose_landmarker
MEDIAPIPE_TO_COCO: tuple[int, ...] = (
    0,   # nose
    2,   # left_eye (MediaPipe LEFT_EYE centre)
    5,   # right_eye
    7,   # left_ear
    8,   # right_ear
    11,  # left_shoulder
    12,  # right_shoulder
    13,  # left_elbow
    14,  # right_elbow
    15,  # left_wrist
    16,  # right_wrist
    23,  # left_hip
    24,  # right_hip
    25,  # left_knee
    26,  # right_knee
    27,  # left_ankle
    28,  # right_ankle
)


def resolve(name: str) -> int:
    """Map a keypoint name to its index, with a helpful error for typos in YAML."""
    try:
        return INDEX[name]
    except KeyError:
        raise KeyError(
            f"unknown keypoint {name!r}; expected one of {', '.join(NAMES)}"
        ) from None
