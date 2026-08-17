"""Wire format for the phone <-> service WebSocket."""

from __future__ import annotations

from typing import Literal

from pydantic import BaseModel, Field

from .keypoints import COUNT


class Keypoint(BaseModel):
    x: float
    y: float
    score: float = 1.0


class FrameIn(BaseModel):
    """One pose frame from the device.

    `t` is a millisecond timestamp from the device clock. We only ever use
    differences between consecutive `t` values, so it needs to be monotonic but
    does not need to agree with the server clock.
    """

    t: float
    keypoints: list[Keypoint] = Field(min_length=COUNT, max_length=COUNT)


class Cue(BaseModel):
    id: str
    text: str
    severity: Literal["info", "warn"] = "warn"


class FrameOut(BaseModel):
    """Per-frame feedback back to the device."""

    t: float
    reps: int
    phase: Literal["down", "up", "unknown"]
    tracked_angle: float | None = None
    form_score: float | None = None
    cues: list[Cue] = []
    fall: bool = False
    visible: bool = True

    # Hold-mode fields, absent for rep-counted exercises.
    mode: Literal["reps", "hold"] = "reps"
    holding: bool | None = None
    # Seconds held in the current unbroken attempt.
    hold_seconds: float | None = None
    best_hold_seconds: float | None = None


class SessionSummary(BaseModel):
    exercise_id: str
    reps: int
    mean_form_score: float | None
    duration_s: float
    fall_detected: bool
    mode: Literal["reps", "hold"] = "reps"
    # Longest unbroken hold, for hold-mode exercises.
    best_hold_seconds: float | None = None
