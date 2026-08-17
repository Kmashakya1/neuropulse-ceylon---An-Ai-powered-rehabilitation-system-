"""Rep counting via a two-state machine with hysteresis.

This generalises the original prototype's `wrist.y < shoulder.y` / `arm_up` flag.
Two changes matter:

  * Separate down/up thresholds, so a value hovering on the boundary can't
    ratchet the counter.
  * A minimum interval between reps, which rejects tracking glitches that would
    otherwise register as impossibly fast movements.

A rep is counted on reaching the TOP of the movement (matching the prototype's
behaviour, and giving the patient immediate feedback), but only if the movement
was armed by passing through `down` first.
"""

from __future__ import annotations

from typing import Literal

Phase = Literal["down", "up", "unknown"]


class RepCounter:
    def __init__(self, down_below: float, up_above: float, min_interval_s: float):
        self._down_below = down_below
        self._up_above = up_above
        self._min_interval_s = min_interval_s

        self.reps = 0
        self.phase: Phase = "unknown"
        self._last_rep_t: float | None = None

    def update(self, value: float, t_s: float) -> bool:
        """Feed one metric sample. Returns True if this sample completed a rep."""
        if value <= self._down_below:
            self.phase = "down"
            return False

        if value >= self._up_above:
            # Only counts if we came up from a genuine `down`, so a session that
            # starts mid-movement doesn't award a free rep.
            if self.phase != "down":
                self.phase = "up"
                return False

            if (
                self._last_rep_t is not None
                and t_s - self._last_rep_t < self._min_interval_s
            ):
                # Too fast to be real -- treat as noise but still move to `up`
                # so we don't re-fire on the next frame.
                self.phase = "up"
                return False

            self.reps += 1
            self.phase = "up"
            self._last_rep_t = t_s
            return True

        # Between thresholds: mid-movement, hold the current phase.
        return False
