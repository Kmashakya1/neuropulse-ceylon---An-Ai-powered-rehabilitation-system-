"""Loading and validation of the exercise angle-rule configs."""

from __future__ import annotations

from dataclasses import dataclass, field
from pathlib import Path
from typing import Any, Literal

import yaml

from . import keypoints

CONFIG_PATH = Path(__file__).parent / "config" / "exercises.yaml"

Lang = Literal["en", "si", "ta"]


@dataclass(frozen=True)
class RepMetric:
    """What drives the rep state machine."""

    metric: Literal["joint", "elevation"]
    down_below: float
    up_above: float
    # joint
    vertex: int | None = None
    a: int | None = None
    b: int | None = None
    # elevation
    origin: int | None = None
    target: int | None = None

    @property
    def required(self) -> list[int]:
        idx = [self.vertex, self.a, self.b, self.origin, self.target]
        return [i for i in idx if i is not None]


@dataclass(frozen=True)
class FormRule:
    """A measurable condition.

    Serves double duty: form rules checked during a rep, and the conditions that
    define "in position" for a hold.
    """

    id: str
    metric: Literal["joint", "tilt", "gap"]
    cues: dict[str, str]
    minimum: float | None = None
    maximum: float | None = None
    phase: Literal["up", "any"] = "up"
    # joint
    vertex: int | None = None
    a: int | None = None
    b: int | None = None
    # tilt
    top: int | None = None
    bottom: int | None = None

    @property
    def required(self) -> list[int]:
        idx = [self.vertex, self.a, self.b, self.top, self.bottom]
        return [i for i in idx if i is not None]

    def satisfied(self, value: float) -> bool:
        if self.minimum is not None and value < self.minimum:
            return False
        if self.maximum is not None and value > self.maximum:
            return False
        return True

    def cue(self, lang: Lang) -> str:
        return self.cues.get(lang) or self.cues["en"]


@dataclass(frozen=True)
class Exercise:
    """One exercise, in one of two modes.

    `reps` counts cycles of a movement. `hold` measures how long a position is
    maintained — balance work and postural holds have no up/down cycle, so a rep
    counter has nothing to count and would sit at zero forever.

    NOTE: hold mode verifies a measurable POSITION. It cannot verify a force-based
    isometric (e.g. "press your heel down"), because pressing harder does not move
    anything the camera can see. Those remain out of scope.
    """

    id: str
    names: dict[str, str]
    target_reps: int
    rep: RepMetric | None
    mode: Literal["reps", "hold"] = "reps"
    # Conditions that must all be satisfied for the hold timer to run.
    hold: list[FormRule] = field(default_factory=list)
    target_seconds: int = 20
    form: list[FormRule] = field(default_factory=list)
    min_visibility: float = 0.3
    min_rep_interval_s: float = 0.6
    # False means the thresholds are geometric guesses rather than measured from
    # footage. Reps will be roughly right; form_score is not trustworthy. Surfaced
    # over the API so the app can say so instead of implying equal confidence.
    calibrated: bool = False

    def name(self, lang: Lang) -> str:
        return self.names.get(lang) or self.names["en"]

    @property
    def required(self) -> list[int]:
        """Keypoints that must be visible for this exercise to be tracked."""
        if self.mode == "hold":
            return sorted({i for rule in self.hold for i in rule.required})
        assert self.rep is not None
        return sorted(set(self.rep.required))


def _localised(raw: dict[str, Any], base: str) -> dict[str, str]:
    out = {"en": raw[base]}
    for lang in ("si", "ta"):
        value = raw.get(f"{base}_{lang}")
        if value:
            out[lang] = value
    return out


def _parse_rep(raw: dict[str, Any]) -> RepMetric:
    metric = raw["metric"]
    common = {
        "metric": metric,
        "down_below": float(raw["down_below"]),
        "up_above": float(raw["up_above"]),
    }

    if float(raw["down_below"]) >= float(raw["up_above"]):
        raise ValueError(
            f"rep.down_below ({raw['down_below']}) must be below rep.up_above "
            f"({raw['up_above']}) for hysteresis to work"
        )

    if metric == "joint":
        return RepMetric(
            **common,
            vertex=keypoints.resolve(raw["vertex"]),
            a=keypoints.resolve(raw["a"]),
            b=keypoints.resolve(raw["b"]),
        )
    if metric == "elevation":
        return RepMetric(
            **common,
            origin=keypoints.resolve(raw["origin"]),
            target=keypoints.resolve(raw["target"]),
        )
    raise ValueError(f"unsupported rep.metric {metric!r}; use 'joint' or 'elevation'")


def _parse_form(raw: dict[str, Any]) -> FormRule:
    metric = raw["metric"]
    if raw.get("min") is None and raw.get("max") is None:
        raise ValueError(f"form rule {raw['id']!r} needs at least one of min/max")

    common = {
        "id": raw["id"],
        "metric": metric,
        "cues": _localised(raw, "cue"),
        "minimum": None if raw.get("min") is None else float(raw["min"]),
        "maximum": None if raw.get("max") is None else float(raw["max"]),
        "phase": raw.get("phase", "up"),
    }

    if metric == "joint":
        return FormRule(
            **common,
            vertex=keypoints.resolve(raw["vertex"]),
            a=keypoints.resolve(raw["a"]),
            b=keypoints.resolve(raw["b"]),
        )
    if metric == "tilt":
        return FormRule(
            **common,
            top=keypoints.resolve(raw["top"]),
            bottom=keypoints.resolve(raw["bottom"]),
        )
    if metric == "gap":
        return FormRule(
            **common,
            a=keypoints.resolve(raw["a"]),
            b=keypoints.resolve(raw["b"]),
        )
    raise ValueError(
        f"unsupported metric {metric!r}; use 'joint', 'tilt' or 'gap'"
    )


def load(path: Path | None = None) -> dict[str, Exercise]:
    raw = yaml.safe_load((path or CONFIG_PATH).read_text(encoding="utf-8"))
    defaults = raw.get("defaults") or {}

    out: dict[str, Exercise] = {}
    for item in raw["exercises"]:
        mode = item.get("mode", "reps")
        if mode not in ("reps", "hold"):
            raise ValueError(f"unsupported mode {mode!r}; use 'reps' or 'hold'")

        hold = [_parse_form(r) for r in item.get("hold", [])]
        if mode == "hold" and not hold:
            raise ValueError(
                f"{item['id']!r} is mode: hold but defines no hold conditions, "
                "so nothing would ever be timed"
            )
        if mode == "reps" and "rep" not in item:
            raise ValueError(f"{item['id']!r} is mode: reps but has no rep block")

        exercise = Exercise(
            id=item["id"],
            names=_localised(item, "name"),
            target_reps=int(item.get("target_reps", 10)),
            rep=_parse_rep(item["rep"]) if "rep" in item else None,
            mode=mode,
            hold=hold,
            target_seconds=int(item.get("target_seconds", 20)),
            form=[_parse_form(r) for r in item.get("form", [])],
            min_visibility=float(
                item.get("min_visibility", defaults.get("min_visibility", 0.3))
            ),
            min_rep_interval_s=float(
                item.get(
                    "min_rep_interval_s", defaults.get("min_rep_interval_s", 0.6)
                )
            ),
            calibrated=bool(
                item.get("calibrated", defaults.get("calibrated", False))
            ),
        )
        if exercise.id in out:
            raise ValueError(f"duplicate exercise id {exercise.id!r}")
        out[exercise.id] = exercise
    return out
