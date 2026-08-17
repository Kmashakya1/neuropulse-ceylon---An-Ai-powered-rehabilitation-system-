# NeuroPulse ML Service

Exercise form checking, rep counting and in-session fall detection.

The phone runs pose estimation **on-device** and streams the 17 resulting
keypoints here over a WebSocket. This service owns all the *logic* — joint-angle
rules, the rep state machine, fall detection — and forwards confirmed falls to
the Node backend so the existing caregiver dashboard keeps working unchanged.

```
VisionCamera 30fps → on-device MoveNet → 17 keypoints
    → WS /ws/session → reps + form cues + fall
    → POST /api/alerts (Node, port 5000)
```

**Keypoints, not pixels.** A pose frame is ~200 bytes versus ~15KB for a JPEG,
so a 30fps session is comfortable over WiFi and feedback stays under ~100ms.
Frames never leave the device as imagery, which also sidesteps the privacy
problem of streaming patient video.

## Setup

```bash
python -m venv .venv
.venv/Scripts/python.exe -m pip install -r requirements.txt
```

Requires Python 3.11 or 3.12 (MediaPipe has no 3.13 wheels yet). `numpy` is
pinned below 2.0 because MediaPipe requires it — don't bump it independently.

Note there is **no PyTorch here**. In-session fall detection works from keypoint
velocity (see below), so the 2.5GB torch stack is only needed by the ambient
YOLO monitor: `pip install -r requirements-yolo.txt`.

## Run

```bash
.venv/Scripts/python.exe -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8100
```

**`--host 0.0.0.0` is required for any device to connect.** Uvicorn binds
`127.0.0.1` by default, which a phone cannot reach. (An Android emulator can
still reach a loopback-bound service via its `10.0.2.2` alias, which makes this
mistake look like it works from `curl` on the host while failing from the app.)
Note this does expose the service to your local network.

Point it at a different Node backend with `ALERTS_URL`:

```bash
ALERTS_URL=http://127.0.0.1:5000/api/alerts
```

| Endpoint | Purpose |
|---|---|
| `GET /health` | liveness + exercise count |
| `GET /exercises?lang=si` | catalogue, localised (`en`/`si`/`ta`) |
| `WS /ws/session?exercise=<id>&patient=<name>&lang=si` | live session |

Send `{"t": <ms>, "keypoints": [{"x","y","score"} × 17]}`; receive
`{reps, phase, tracked_angle, form_score, cues[], fall, visible}`.

Coordinates are normalised to `[0,1]` with the origin **top-left**, so `y`
increases downwards. `t` only needs to be monotonic — only differences are used.

## Verify without a phone

```bash
.venv/Scripts/python.exe tools/selftest.py
```

35 assertions over the geometry and state machines using synthetic keypoints —
no camera, no model download, about a second. Safe for CI.

Against real footage, using the same engine the WebSocket uses:

```bash
.venv/Scripts/python.exe tools/replay_video.py --exercise shoulder_flexion_left --video "../frontend/assets/videos/exercise/5 Exercises for Stroke Recovery.mp4"
```

`--camera 0` for a webcam, `--headless` to skip the preview window. This is the
loop to use when tuning thresholds.

## Adding or tuning an exercise

Everything lives in `app/config/exercises.yaml` — no code change needed.

`rep` picks the metric driving the state machine: `joint` (interior angle at a
vertex, 0–180) or `elevation` (limb angle above horizontal, −90–90; use this
when a joint angle can't tell up from down). The value must drop below
`down_below` to arm a rep, then rise above `up_above` to count it. Keep those
thresholds well apart — the gap is what stops jitter double-counting.

`form` rules each contribute equally to `form_score` and emit their `cue` when
violated. They apply only at the top of the movement unless `phase: any`.
Cues carry `_si`/`_ta` variants so replies mirror the patient's language.

## Calibration status

Use `tools/profile_video.py` to measure what a clip actually does before touching
a threshold. It reports the p15/p50/p85 range of every trackable metric,
`--suggest <metric>` proposes thresholds and simulates the rep count, and
`--trace <metric>` prints the signal over time so you can count real movement
cycles by eye. By default it spreads its samples across the *whole* video, which
matters — several reference clips open with minutes of talking head.

Calibrated against the reference clips, each scoring on its own source video:

| Exercise | Metric | Thresholds | Reps | Form |
|---|---|---|---|---|
| `shoulder_flexion_left/right` | shoulder joint | 20 / 85 | 1 in 5.9s | 1.00 |
| `elbow_extension_left/right` | elbow joint | 95 / 152 | 3 in 20.7s | 0.88 |
| `straight_leg_raise_left/right` | leg elevation | −20 / 0 | 1 in 22.7s | 0.86 |

Thresholds are set so a competent *demonstration* scores near 1.0 — that's what
makes a patient's deviation visible. Don't loosen them to flatter a patient.

`knee_extension_left` and `sit_to_stand` are **uncalibrated**: no clip in the
library isolates those movements cleanly (the lower-limb compilations mix supine
and standing work across camera cuts, and only ~24% of their frames track). They
count roughly sensible reps; their form scores are not trustworthy.

`fall.py`'s thresholds are derived from geometry, not from recorded falls. See the
calibration note in that file.

### Known gaps

**Rep counting is the wrong model for some of these exercises.** Balance work
(Romberg test), isometric holds, and coordination drills (finger-to-nose,
heel-to-shin) have no up/down cycle — they need hold duration or trajectory
accuracy instead. The straight-leg-raise clip is itself a ~6s isometric hold,
which is why it yields 1 rep rather than a cadence.

## Why fall detection here doesn't use `best.pt`

The YOLO model classifies **posture** — FALL / STANDING / SITTING. During rehab,
lying on a mat *is* a normal posture, so a posture classifier fires constantly on
floor exercises; raising the frame threshold only delays that.

What separates a fall from lying down deliberately is **speed**. `app/fall.py`
looks for the hip centre descending faster than ~0.4 screen-heights/second, ending
low in frame with a near-horizontal torso, and *staying* there past a
confirmation window. A controlled lie-down over 3–4s is ~0.07 — roughly 5x
margin.

`best.pt` remains the right tool for **ambient** monitoring outside sessions,
where lying on the floor genuinely is the anomaly. `backend/detect_fall.py` is
that path; note it still posts to a stale hardcoded IP.
