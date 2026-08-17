"""Geometry helpers.

All functions take the flat keypoint list from a FrameIn and return degrees.
Remember y increases downwards (see keypoints module docstring).
"""

from __future__ import annotations

import math

from .schemas import Keypoint


def joint_angle(
    kps: list[Keypoint],
    vertex: int,
    a: int,
    b: int,
) -> float:
    """Interior angle at `vertex` formed by the rays vertex->a and vertex->b.

    Returns degrees in [0, 180]. A straight limb is ~180.
    """
    v = kps[vertex]
    ax, ay = kps[a].x - v.x, kps[a].y - v.y
    bx, by = kps[b].x - v.x, kps[b].y - v.y

    na = math.hypot(ax, ay)
    nb = math.hypot(bx, by)
    if na == 0.0 or nb == 0.0:
        return 0.0

    cos = (ax * bx + ay * by) / (na * nb)
    # Guard against tiny FP overshoot outside [-1, 1], which would raise.
    return math.degrees(math.acos(max(-1.0, min(1.0, cos))))


def elevation_angle(kps: list[Keypoint], origin: int, target: int) -> float:
    """Angle of the origin->target vector above horizontal, in [-90, 90].

    Positive means `target` sits ABOVE `origin` on screen. Useful for limb
    elevation, where a joint angle alone can't distinguish up from down.
    """
    dx = kps[target].x - kps[origin].x
    dy = kps[target].y - kps[origin].y
    if dx == 0.0 and dy == 0.0:
        return 0.0
    # Negate dy so that "up on screen" is positive.
    return math.degrees(math.atan2(-dy, abs(dx)))


def tilt_from_vertical(kps: list[Keypoint], top: int, bottom: int) -> float:
    """How far the top->bottom segment deviates from vertical, in [0, 90].

    0 means perfectly upright, 90 means horizontal. Used for torso posture and
    for fall detection.
    """
    dx = kps[top].x - kps[bottom].x
    dy = kps[top].y - kps[bottom].y
    if dx == 0.0 and dy == 0.0:
        return 0.0
    return abs(math.degrees(math.atan2(abs(dx), abs(dy))))


def midpoint_y(kps: list[Keypoint], a: int, b: int) -> float:
    return (kps[a].y + kps[b].y) / 2.0


def vertical_gap(kps: list[Keypoint], a: int, b: int) -> float:
    """Absolute vertical separation of two keypoints, as a percentage of frame height.

    Used for holds where the measurable thing is a position rather than an angle —
    single-leg stance is "one ankle well above the other", which no joint angle
    captures.

    Deliberately absolute, so one config serves both legs. Which foot is lifted
    doesn't change whether the patient is balancing, and it sidesteps MediaPipe's
    left/right assignment flipping with body orientation.
    """
    return abs(kps[a].y - kps[b].y) * 100.0


def mean_score(kps: list[Keypoint], indices: list[int]) -> float:
    if not indices:
        return 0.0
    return sum(kps[i].score for i in indices) / len(indices)
