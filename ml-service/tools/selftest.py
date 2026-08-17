"""Deterministic engine checks using synthetic keypoints.

No camera, no MediaPipe, no model download -- pure geometry and state machines,
so this runs in about a second and is safe to put in CI.

    python tools/selftest.py
"""

from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from app import exercises as exercise_config  # noqa: E402
from app.keypoints import COUNT, INDEX  # noqa: E402
from app.schemas import Keypoint  # noqa: E402
from app.session import Session  # noqa: E402

PASSED = 0
FAILED: list[str] = []


def check(label: str, condition: bool, detail: str = "") -> None:
    global PASSED
    if condition:
        PASSED += 1
        print(f"  ok    {label}")
    else:
        FAILED.append(label)
        print(f"  FAIL  {label} {detail}")


def frame(**overrides: tuple[float, float]) -> list[Keypoint]:
    """Build a neutral standing pose, then apply named joint overrides."""
    base = {
        "left_shoulder": (0.50, 0.40),
        "right_shoulder": (0.40, 0.40),
        "left_elbow": (0.52, 0.55),
        "right_elbow": (0.38, 0.55),
        "left_wrist": (0.54, 0.70),
        "right_wrist": (0.36, 0.70),
        "left_hip": (0.50, 0.62),
        "right_hip": (0.42, 0.62),
        "left_knee": (0.50, 0.80),
        "right_knee": (0.42, 0.80),
        "left_ankle": (0.50, 0.95),
        "right_ankle": (0.42, 0.95),
    }
    base.update(overrides)

    kps = [Keypoint(x=0.46, y=0.30, score=0.9) for _ in range(COUNT)]
    for name, (x, y) in base.items():
        kps[INDEX[name]] = Keypoint(x=x, y=y, score=0.9)
    return kps


# --- config -----------------------------------------------------------------

print("config")
CATALOGUE = exercise_config.load()
check("loads exercises", len(CATALOGUE) >= 4, f"got {len(CATALOGUE)}")
check("has shoulder_flexion_left", "shoulder_flexion_left" in CATALOGUE)
for ex in CATALOGUE.values():
    if ex.mode == "reps":
        check(
            f"{ex.id} hysteresis gap",
            ex.rep is not None and ex.rep.up_above > ex.rep.down_below,
        )
    else:
        # A hold with no conditions would time nothing, forever.
        check(f"{ex.id} has hold conditions", bool(ex.hold))
    check(f"{ex.id} has si+ta names", {"si", "ta"} <= set(ex.names))


# --- rep counting -----------------------------------------------------------

print("\nrep counting")
ARM = CATALOGUE["shoulder_flexion_left"]

# shoulder_flexion_left tracks the SHOULDER JOINT angle (hip-shoulder-elbow),
# so these poses are built around where the elbow sits relative to the trunk.
# Arm hanging down -> ~8 degrees; arm out to horizontal -> ~90.
DOWN = frame(left_wrist=(0.55, 0.70), left_elbow=(0.52, 0.55))
# Arm raised to horizontal, elbow straight (shoulder/elbow/wrist colinear).
UP = frame(left_elbow=(0.70, 0.40), left_wrist=(0.90, 0.40))
# Roughly 45 degrees: between the thresholds, so it must not advance the state.
MID = frame(left_elbow=(0.65, 0.52), left_wrist=(0.78, 0.60))

s = Session(ARM)
check("starts at 0 reps", s.push(0, DOWN).reps == 0)
r = s.push(500, UP)
check("down->up counts 1 rep", r.reps == 1, f"got {r.reps}")
check("phase is up", r.phase == "up", f"got {r.phase}")
check("form score is perfect on clean rep", r.form_score == 1.0, f"got {r.form_score}")

check("holding up does not re-count", s.push(700, UP).reps == 1)
check("returning down keeps count", s.push(1400, DOWN).reps == 1)
check("second cycle counts", s.push(2200, UP).reps == 2)

# Hysteresis: values between the thresholds must not advance anything.
s2 = Session(ARM)
s2.push(0, DOWN)
jitter = None
for i in range(10):
    jitter = s2.push(100 + i * 50, MID)
check("mid-range jitter counts nothing", jitter is not None and jitter.reps == 0)

# Starting mid-movement must not award a free rep.
s3 = Session(ARM)
check("starting at the top counts nothing", s3.push(0, UP).reps == 0)

# Too-fast reps are rejected as tracking noise (min_rep_interval_s = 0.6).
s4 = Session(ARM)
s4.push(0, DOWN)
check("first rep counts", s4.push(100, UP).reps == 1)
s4.push(150, DOWN)
check("impossibly fast second rep rejected", s4.push(200, UP).reps == 1)


# --- form scoring -----------------------------------------------------------

print("\nform scoring")
# Arm raised (shoulder ~90, so the rep still counts) but the elbow folded back,
# which violates elbow_straight (min 150) without touching torso_upright.
BENT = frame(left_elbow=(0.70, 0.40), left_wrist=(0.72, 0.25))
s5 = Session(ARM)
s5.push(0, DOWN)
r = s5.push(600, BENT)
check("bent elbow still counts the rep", r.reps == 1, f"got {r.reps}")
check("bent elbow lowers form score", (r.form_score or 1.0) < 1.0, f"got {r.form_score}")
check(
    "bent elbow emits the elbow cue",
    any(c.id == "elbow_straight" for c in r.cues),
    f"got {[c.id for c in r.cues]}",
)

# Leaning torso violates a phase:any rule, so it fires even at rest.
LEAN = frame(left_shoulder=(0.30, 0.40), left_hip=(0.50, 0.62))
s6 = Session(ARM)
r = s6.push(0, LEAN)
check(
    "torso rule fires while down (phase: any)",
    any(c.id == "torso_upright" for c in r.cues),
    f"got {[c.id for c in r.cues]}",
)

# Localisation
s7 = Session(ARM, lang="si")
r = s7.push(0, LEAN)
check(
    "cue is localised to Sinhala",
    any(c.text == "කෙළින් වාඩි වන්න, ඇල නොවන්න" for c in r.cues),
    f"got {[c.text for c in r.cues]}",
)


# --- visibility -------------------------------------------------------------

print("\nvisibility")
hidden = [Keypoint(x=0.5, y=0.5, score=0.05) for _ in range(COUNT)]
s8 = Session(ARM)
r = s8.push(0, hidden)
check("low-confidence frame marked not visible", r.visible is False)
check("not-visible frame counts no reps", r.reps == 0)


# --- fall detection ---------------------------------------------------------

print("\nfall detection")


def collapsed(t_ms: float) -> list[Keypoint]:
    """Horizontal torso, hips low in frame."""
    return frame(
        left_shoulder=(0.20, 0.82),
        right_shoulder=(0.20, 0.88),
        left_hip=(0.60, 0.88),
        right_hip=(0.60, 0.92),
    )


s9 = Session(ARM)
for t in (0, 100, 200, 300):
    s9.push(t, DOWN)

fired: list[float] = []
# Fast collapse, then stay down past the 1.5s confirmation window.
for t in range(400, 2600, 100):
    if s9.push(t, collapsed(t)).fall:
        fired.append(t)

check("fast collapse raises a fall", len(fired) == 1, f"fired at {fired}")
check("fall confirmed after ~1.5s", bool(fired) and fired[0] >= 1800, f"{fired}")
check("fall recorded in summary", s9.summary().fall_detected is True)

# The key discriminator: lowering yourself onto a mat slowly is NOT a fall.
s10 = Session(ARM)
slow: list[float] = []
for i in range(41):  # 4 seconds
    t = i * 100
    progress = i / 40
    kps = frame(
        left_shoulder=(0.50 - 0.30 * progress, 0.40 + 0.40 * progress),
        left_hip=(0.50 + 0.10 * progress, 0.62 + 0.28 * progress),
        right_hip=(0.42 + 0.18 * progress, 0.62 + 0.28 * progress),
    )
    if s10.push(t, kps).fall:
        slow.append(t)
check("slow controlled lie-down is not a fall", slow == [], f"fired at {slow}")

# REGRESSION: a patient already lying prone when the session starts.
# tools/fall_probe.py caught this on the real hamstring_curl_prone clip. The hip
# estimate settled by 0.037 of frame height between the first two frames, which
# over 67ms reads as 0.56 heights/second -- past the velocity threshold. That
# latched the confirmation clock, and simply lying still for 1.5s then confirmed a
# fall on someone who had not moved. Rate alone is not evidence of a drop.
s11 = Session(ARM)
prone_alerts: list[float] = []
for i in range(60):  # 4 seconds at 15fps
    t = i * 67
    # Tracker converges over the first frame, then the patient lies still.
    settle = 0.680 if i == 0 else 0.717 + 0.00005 * i
    kps = frame(
        left_shoulder=(0.20, settle - 0.001),
        left_hip=(0.60, settle),
        right_hip=(0.60, settle + 0.004),
    )
    if s11.push(t, kps).fall:
        prone_alerts.append(t)
check(
    "settling jitter while already prone is not a fall",
    prone_alerts == [],
    f"fired at {prone_alerts}",
)

# The distance gate must not swallow a real fall: a genuine collapse moves the
# hips far as well as fast.
s12 = Session(ARM)
real: list[float] = []
for t in (0, 100, 200, 300):
    s12.push(t, DOWN)
for t in range(400, 2600, 100):
    if s12.push(t, collapsed(t)).fall:
        real.append(t)
check("real collapse still fires with the distance gate", len(real) == 1, f"{real}")

# A fast drop that ends upright is not a fall -- sitting down heavily.
s13 = Session(ARM)
seated: list[float] = []
for t in (0, 100, 200, 300):
    s13.push(t, DOWN)
for t in range(400, 2600, 100):
    # Hips low, torso still vertical.
    kps = frame(
        left_shoulder=(0.50, 0.55),
        left_hip=(0.50, 0.90),
        right_hip=(0.42, 0.90),
    )
    if s13.push(t, kps).fall:
        seated.append(t)
check("dropping heavily into a chair is not a fall", seated == [], f"{seated}")

# Getting straight back up must cancel the confirmation clock.
s14 = Session(ARM)
recovered: list[float] = []
for t in (0, 100, 200, 300):
    s14.push(t, DOWN)
for t in range(400, 1200, 100):  # down for 0.8s, short of confirm_s
    s14.push(t, collapsed(t))
for t in range(1200, 3000, 100):  # back on their feet
    if s14.push(t, DOWN).fall:
        recovered.append(t)
check("getting straight back up raises nothing", recovered == [], f"{recovered}")


# --- summary ----------------------------------------------------------------

print("\nsession summary")
sm = s.summary()
check("summary reps match", sm.reps == 2, f"got {sm.reps}")
check("summary duration positive", sm.duration_s > 0)
check("summary carries exercise id", sm.exercise_id == "shoulder_flexion_left")


# --- hold mode ---------------------------------------------------------------

print("\nhold mode (single leg balance)")
BALANCE = CATALOGUE["single_leg_stance"]

# Conditions: ankle gap >= 8% of frame height, and trunk within 20 degrees of
# vertical. Base pose has both ankles level, so it fails the gap condition.
BALANCED = frame(right_ankle=(0.42, 0.82))          # gap = 13
FEET_DOWN = frame()                                  # gap = 0
LEANING = frame(right_ankle=(0.42, 0.82), left_shoulder=(0.30, 0.40))

h = Session(BALANCE)
r = h.push(0, BALANCED)
check("hold mode reported", r.mode == "hold", f"got {r.mode}")
check("holding once in position", r.holding is True)
check("counts no reps", r.reps == 0)

for t in range(100, 3100, 100):
    r = h.push(t, BALANCED)
check(
    "accumulates about 3 seconds",
    2.8 <= (r.hold_seconds or 0) <= 3.1,
    f"got {r.hold_seconds}",
)

r = h.push(3200, FEET_DOWN)
check("breaking position stops the hold", r.holding is False)
check("current hold resets to zero", r.hold_seconds == 0.0, f"got {r.hold_seconds}")
check(
    "best hold is retained",
    2.8 <= (r.best_hold_seconds or 0) <= 3.1,
    f"got {r.best_hold_seconds}",
)
check(
    "emits the foot-lifted cue",
    any(c.id == "foot_lifted" for c in r.cues),
    f"got {[c.id for c in r.cues]}",
)

# A shorter second attempt must not lower the recorded best.
for t in range(3300, 4400, 100):
    r = h.push(t, BALANCED)
check(
    "shorter attempt does not lower best",
    2.8 <= (r.best_hold_seconds or 0) <= 3.1,
    f"got {r.best_hold_seconds}",
)

# Leaning breaks the upright condition even though the foot is still lifted.
r = h.push(4500, LEANING)
check(
    "leaning emits the upright cue",
    any(c.id == "upright" for c in r.cues),
    f"got {[c.id for c in r.cues]}",
)

# Losing tracking must PAUSE rather than credit time the patient may not have held.
h2 = Session(BALANCE)
for t in range(0, 2100, 100):
    h2.push(t, BALANCED)
hidden_all = [Keypoint(x=0.5, y=0.5, score=0.05) for _ in range(COUNT)]
r = h2.push(2100, hidden_all)
check("not-visible frame is not holding", r.holding is False)
r = h2.push(5100, BALANCED)
check(
    "3s tracking gap awards no time",
    (r.hold_seconds or 0) <= 2.2,
    f"got {r.hold_seconds}",
)

sm = h2.summary()
check("summary reports hold mode", sm.mode == "hold")
check("summary carries best hold", (sm.best_hold_seconds or 0) >= 1.9)
check("summary reps stay zero for a hold", sm.reps == 0)


print(f"\n{PASSED} passed, {len(FAILED)} failed")
for name in FAILED:
    print(f"  failed: {name}")
sys.exit(1 if FAILED else 0)
