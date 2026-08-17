"""Per-connection session state: rep counting, form scoring, fall detection.

Pure logic -- no I/O, no framework types beyond the pydantic schemas -- so the
same engine serves the WebSocket endpoint and tools/replay_video.py.
"""

from __future__ import annotations

from . import angles
from .exercises import Exercise, FormRule, Lang, RepMetric
from .fall import FallDetector
from .rep_counter import RepCounter
from .schemas import Cue, FrameOut, Keypoint, SessionSummary


class Session:
    def __init__(self, exercise: Exercise, lang: Lang = "en"):
        self.exercise = exercise
        self.lang = lang

        # Hold-mode exercises have no rep block, so there is nothing to count.
        self._counter: RepCounter | None = (
            None
            if exercise.rep is None
            else RepCounter(
                down_below=exercise.rep.down_below,
                up_above=exercise.rep.up_above,
                min_interval_s=exercise.min_rep_interval_s,
            )
        )
        self._fall = FallDetector()

        self._form_scores: list[float] = []
        self._fall_detected = False
        self._t_first: float | None = None
        self._t_last: float = 0.0

        # Hold mode state.
        self._hold_seconds = 0.0
        self._best_hold_seconds = 0.0
        self._t_prev: float | None = None

    @property
    def _reps(self) -> int:
        return 0 if self._counter is None else self._counter.reps

    @property
    def _phase(self) -> str:
        return "unknown" if self._counter is None else self._counter.phase

    # -- public API ---------------------------------------------------------

    def push(self, t_ms: float, kps: list[Keypoint]) -> FrameOut:
        t_s = t_ms / 1000.0
        if self._t_first is None:
            self._t_first = t_s
        self._t_last = t_s

        if not self._is_visible(kps):
            return self.push_no_pose(t_ms)

        if self.exercise.mode == "hold":
            return self._push_hold(t_ms, t_s, kps)

        value = self._rep_metric_value(kps, self.exercise.rep)
        assert self._counter is not None
        self._counter.update(value, t_s)

        cues, form_score = self._score_form(kps)
        if form_score is not None:
            self._form_scores.append(form_score)

        fall = self._fall.update(kps, t_s)
        if fall:
            self._fall_detected = True

        return FrameOut(
            t=t_ms,
            reps=self._reps,
            phase=self._phase,
            tracked_angle=round(value, 1),
            form_score=None if form_score is None else round(form_score, 3),
            cues=cues,
            fall=fall,
            visible=True,
        )

    def push_no_pose(self, t_ms: float) -> FrameOut:
        """Frame in which no pose was found, or the patient is out of shot.

        Public because the frames endpoint needs it: MediaPipe returning nothing
        happens before there are any keypoints to push. It previously hand-built
        that reply as a dict and silently omitted `mode`, so hold-mode sessions
        reported themselves as rep-counted for as long as tracking was lost.
        Routing it through here means the shape can't drift again.

        A hold PAUSES rather than resets — losing tracking is not the patient's
        fault — but it must not accumulate either, since we cannot verify they are
        still in position.
        """
        is_hold = self.exercise.mode == "hold"
        self._t_prev = None
        if self._t_first is None:
            self._t_first = t_ms / 1000.0
        self._t_last = t_ms / 1000.0

        return FrameOut(
            t=t_ms,
            reps=self._reps,
            phase=self._phase,
            visible=False,
            mode=self.exercise.mode,
            holding=False if is_hold else None,
            hold_seconds=round(self._hold_seconds, 1) if is_hold else None,
            best_hold_seconds=(
                round(self._best_hold_seconds, 1) if is_hold else None
            ),
            cues=[
                Cue(
                    id="not_visible",
                    text="Move so your whole body is in view",
                    severity="info",
                )
            ],
        )

    def _push_hold(
        self, t_ms: float, t_s: float, kps: list[Keypoint]
    ) -> FrameOut:
        """Time how long every hold condition stays satisfied.

        The timer accumulates real elapsed seconds between frames rather than
        counting frames, so a variable or dropped frame rate does not inflate or
        deflate the result.
        """
        cues: list[Cue] = []
        holding = True

        for rule in self.exercise.hold:
            if angles.mean_score(kps, rule.required) < self.exercise.min_visibility:
                holding = False
                continue
            if not rule.satisfied(self._form_rule_value(kps, rule)):
                holding = False
                cues.append(Cue(id=rule.id, text=rule.cue(self.lang)))

        if holding:
            if self._t_prev is not None:
                # Guard against a backwards or absurd timestamp gap, which would
                # otherwise award seconds the patient never held.
                delta = t_s - self._t_prev
                if 0 < delta < 1.0:
                    self._hold_seconds += delta
            self._t_prev = t_s
            self._best_hold_seconds = max(
                self._best_hold_seconds, self._hold_seconds
            )
        else:
            # Position broken: the attempt is over. Best is already recorded.
            self._hold_seconds = 0.0
            self._t_prev = None

        fall = self._fall.update(kps, t_s)
        if fall:
            self._fall_detected = True

        return FrameOut(
            t=t_ms,
            reps=0,
            phase="unknown",
            mode="hold",
            holding=holding,
            hold_seconds=round(self._hold_seconds, 1),
            best_hold_seconds=round(self._best_hold_seconds, 1),
            cues=cues,
            fall=fall,
            visible=True,
        )

    def summary(self) -> SessionSummary:
        duration = 0.0
        if self._t_first is not None:
            duration = max(0.0, self._t_last - self._t_first)
        mean = (
            sum(self._form_scores) / len(self._form_scores)
            if self._form_scores
            else None
        )
        return SessionSummary(
            exercise_id=self.exercise.id,
            reps=self._reps,
            mean_form_score=None if mean is None else round(mean, 3),
            duration_s=round(duration, 2),
            fall_detected=self._fall_detected,
            mode=self.exercise.mode,
            best_hold_seconds=(
                round(self._best_hold_seconds, 1)
                if self.exercise.mode == "hold"
                else None
            ),
        )

    # -- internals ---------------------------------------------------------

    def _is_visible(self, kps: list[Keypoint]) -> bool:
        score = angles.mean_score(kps, self.exercise.required)
        return score >= self.exercise.min_visibility

    @staticmethod
    def _rep_metric_value(kps: list[Keypoint], rep: RepMetric) -> float:
        if rep.metric == "joint":
            assert rep.vertex is not None and rep.a is not None and rep.b is not None
            return angles.joint_angle(kps, rep.vertex, rep.a, rep.b)
        assert rep.origin is not None and rep.target is not None
        return angles.elevation_angle(kps, rep.origin, rep.target)

    @staticmethod
    def _form_rule_value(kps: list[Keypoint], rule: FormRule) -> float:
        if rule.metric == "joint":
            assert (
                rule.vertex is not None and rule.a is not None and rule.b is not None
            )
            return angles.joint_angle(kps, rule.vertex, rule.a, rule.b)
        if rule.metric == "gap":
            assert rule.a is not None and rule.b is not None
            return angles.vertical_gap(kps, rule.a, rule.b)
        assert rule.top is not None and rule.bottom is not None
        return angles.tilt_from_vertical(kps, rule.top, rule.bottom)

    def _score_form(self, kps: list[Keypoint]) -> tuple[list[Cue], float | None]:
        """Evaluate the rules applicable to the current phase.

        Returns the cues for violated rules and the fraction satisfied. Score is
        None when no rule applies this frame, so resting frames don't drag the
        session average down.
        """
        applicable = [
            r
            for r in self.exercise.form
            if r.phase == "any" or self._phase == "up"
        ]
        if not applicable:
            return [], None

        cues: list[Cue] = []
        satisfied = 0
        for rule in applicable:
            if angles.mean_score(kps, rule.required) < self.exercise.min_visibility:
                # Can't judge a rule we can't see -- skip rather than penalise.
                continue
            if rule.satisfied(self._form_rule_value(kps, rule)):
                satisfied += 1
            else:
                cues.append(Cue(id=rule.id, text=rule.cue(self.lang)))

        judged = satisfied + len(cues)
        if judged == 0:
            return [], None
        return cues, satisfied / judged
