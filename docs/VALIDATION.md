# NeuroPulse Ceylon — exercise and validation report

What is implemented, how each threshold was derived, what was actually tested, and
every warning the app shows. Figures here are measured, not estimated; anything
unverified is marked as such.

---

## 1. Exercise catalogue

12 exercises are served by `GET /exercises`. All thresholds live in
`ml-service/app/config/exercises.yaml`.

### 1.1 Calibrated (10)

Thresholds measured from reference footage with `tools/profile_video.py`.

| # | id | Tracked metric | down / up | Source clip | Observed range (p15→p85) |
|---|---|---|---|---|---|
| 1 | `shoulder_flexion_left` | joint @ left shoulder | 20 / 85 | upper-limb flexion & extension.mp4 | 2.7 → 99.6 |
| 2 | `shoulder_flexion_right` | joint @ right shoulder | 20 / 85 | same clip | 1.8 → 106.2 |
| 3 | `elbow_extension_left` | joint @ left elbow | 95 / 152 | elbow extension - upperlimb.mp4 | 77.3 → 158.1 |
| 4 | `elbow_extension_right` | joint @ right elbow | 100 / 158 | same clip | 94.5 → 164.7 |
| 5 | `straight_leg_raise_left` | elevation hip→ankle | −20 / 0 | Straight Leg Raise with Weight.mp4 | mirrored from #6 |
| 6 | `straight_leg_raise_right` | elevation hip→ankle | −20 / 0 | same clip | −24.3 → +4.3 |
| 7 | `hamstring_curl_supine` | joint @ right knee | 89 / 133 | hamstring/2-curl-supine.mp4 | 89 → 133 |
| 8 | `hamstring_curl_prone` | joint @ left knee | 128 / 162 | hamstring/3-curl-prone.mp4 | 120.2 → 169.3 |
| 9 | `hamstring_curl_seated` | joint @ right knee | 92 / 128 | hamstring/4-curl-seated.mp4 | 84.2 → 135.3 |
| 10 | `romanian_deadlift_single_leg` | joint @ left hip | 103 / 143 | hamstring/5-romanian-deadlift.mp4 | 94.2 → 151.4 |

### 1.2 Uncalibrated (2)

**Not measured from footage — reasoned defaults.** Derived from joint anatomy plus
measurements taken on *other* clips in this project, and documented number by
number in `exercises.yaml` so the reasoning can be checked or overruled. Weaker
than measuring the exercise itself, which is why the flag stays false, but not
guesswork.

| Exercise | rep | form rule | Basis |
|---|---|---|---|
| `knee_extension_left/right` | 100 → 165 | trunk ≤ 45°, always | Seated knee reads 85–100 (measured 84 at p15). Full extension reads 175–180; 165 asks for within ~15° of full, a functional target that tolerates the extensor lag common after stroke. |
| `sit_to_stand` | 105 → 165 | trunk ≤ 30°, at top only | Standing reads 170–179 (measured 171 median, 178–179). 165 requires a genuine stand; 160 could be met by a half-rise. |

Two values were **wrong** before and have been corrected:

- Knee extension trunk limit was **25°**. Sitting in a chair *measures* 32–34°, so
  it would have fired continuously at a patient sitting correctly. Now 45°.
- Sit-to-stand trunk limit was **20°**. Standing measures 2–4° head-on but up to 26°
  at an angled camera, so a correctly standing patient would fail purely because of
  phone placement. Now 30°.

`knee_extension_right` was **added** — a single left-side entry is the wrong default
half the time in hemiparesis. `sit_to_stand` stays single-knee because the movement
extends both together, so either knee follows it.

No clip in the library isolates either movement:

- `knee_extension_left` — the lower-limb compilations track fine (81% and 62%) but
  they are *compilations*: trunk tilt swings from 6° to 59° across the clip as the
  subject moves between sitting and lying and the camera cuts between exercises. A
  single threshold pair can't be extracted until those clips are segmented the way
  `hamstring.mp4` was. The fix is segmentation, not better footage.
- `sit_to_stand` — there is no sit-to-stand clip at all. `Step up.mp4` was profiled
  as the nearest proxy (89% tracked) but its knee sits at a median of **171°**,
  i.e. standing, with only brief excursions, and stepping onto a box loads one leg
  where sit-to-stand loads both.

Both also key off the **left** knee only, which is the wrong default half the time
for hemiparesis.

> **Correction:** an earlier version of this report said the lower-limb clips
> tracked at ~24%. That was a measurement error — `profile_video.py` printed frames
> *read* rather than frames *processed*, which differ several-fold under a stride or
> a time window. The tool now prints both plus a percentage. The conclusion is
> unchanged; the stated reason was wrong.

| id | Tracked metric | down / up |
|---|---|---|
| `knee_extension_left` | joint @ left knee | 100 / 155 |
| `sit_to_stand` | joint @ left knee | 100 / 160 |

### 1.3 Present in footage but deliberately NOT added (1)

**Hamstring Isometrics** (`hamstring/1-isometrics.mp4`). Measured across that
segment, the widest-moving joint spans **2.5°** — it is an isometric hold. A rep
counter has nothing to count, and adding it would give a patient an exercise
permanently stuck at zero. It needs hold-duration scoring, which the engine does
not have.

---

## 2. Rep-counting validation

Each exercise replayed against its own source clip via `tools/replay_video.py`,
using the same engine the app talks to.

| Exercise | Reps counted | Duration | Mean form score |
|---|---|---|---|
| `shoulder_flexion_left` | 1 | 5.93s | **1.000** |
| `elbow_extension_left` | 3 | 20.69s | 0.884 |
| `straight_leg_raise_right` | 1 | 22.73s | 0.858 |
| `hamstring_curl_supine` | 1 | 5.97s | none (no form rules) |
| `hamstring_curl_prone` | 4 | 7.97s | **1.000** |
| `hamstring_curl_seated` | 2 | 6.97s | 0.957 |
| `romanian_deadlift_single_leg` | 2 | 7.07s | **1.000** |

Form scores cluster at 0.86–1.00 by design: thresholds are set so a competent
*demonstration* scores near 1.0, which is what makes a patient's deviation
visible. Loosening them to flatter a patient would defeat the purpose.

Low rep counts were checked rather than assumed. `--trace` showed the straight leg
raise clip is a single ~6-second isometric hold, not repeated reps, and the seated
curl shows exactly two flexion–extension cycles. The counts are correct for the
footage.

`shoulder_flexion_right` and `elbow_extension_right` were calibrated from the same
clips as their left counterparts but not replayed individually.

---

## 3. Engine validation

`tools/selftest.py` — **51 assertions, 0 failures.** Synthetic keypoints only: no
camera, no model download, ~1 second, safe for CI. Covers:

- config loading, hysteresis gap sanity, si/ta names present on every exercise
- rep counting: clean cycles, holding at the top not re-counting, mid-range jitter
  counting nothing, starting mid-movement not awarding a free rep, impossibly fast
  reps rejected as tracking noise
- form scoring: violations lower the score and emit the right cue, `phase: any`
  rules fire at rest, cues localise to Sinhala
- visibility: low-confidence frames marked not-visible and counting no reps
- fall detection: fast collapse raises a fall after ~1.5s confirmation, and a slow
  controlled lie-down does **not**
- session summary totals

---

## 4. Transport validation

### 4.1 Keypoint endpoint `WS /ws/session`

Verified end to end: handshake, 3 reps counted with form 1.0, malformed frame
rejected as `bad_frame` without dropping the socket, Sinhala cue delivered,
unknown exercise rejected, and a confirmed fall **POSTed to the Node backend** —
its stored alert timestamp advanced from `05:29:10` to `07:11:45`, proving
delivery rather than assuming it.

### 4.2 Frame endpoint `WS /ws/session/frames`

Both wire formats verified at 320×240, ~10fps, against a real clip:

| Format | Bytes/frame | Frames without pose | Bandwidth | Result |
|---|---|---|---|---|
| JPEG q60 | 6.4 KB | 8 / 59 | 64 KB/s | 1 rep, form 1.0 |
| NV21 raw | 115 KB | **4 / 59** | 1.15 MB/s | 1 rep, form 1.0 |

Malformed input handled: a short frame and an unsupported pixel format both
return `bad_frame` and the session survives.

### 4.3 Input quality experiment

MediaPipe detection rate on the same clip, which decided the streaming format:

| Input | Pose detected | Form |
|---|---|---|
| colour 640×480 | 93% | 0.99 |
| colour 320×240 | **96%** | 0.99 |
| grey 640×480 | 80% | 0.98 |
| grey 320×240 | 81% | 0.97 |

**Low resolution is essentially free; greyscale is not.** Sending only the Y plane
to save bandwidth would have cost ~15 points of detection rate.

---

## 5. Client validation

**Flutter** (`frontend_flutter/NeuroPulseCeylon`) — `flutter analyze` clean;
5 Dart tests pass (wire-format and parsing contract with the Python service);
debug APK built in **99s**; release APK 17.8 MB installed on emulator; live
session reached **sent 152 · dropped 0** with the server keeping up.

**React Native** (`frontend`) — `tsc --noEmit` clean; bundles 1713 modules; 33
screens refactored onto a shared design system and spot-checked on the emulator.
Camera frame access is **not possible** here: `expo-camera` has no frame-processor
API, and the VisionCamera alternative needs a dev build that fails on this
machine's 260-character Windows path limit (object paths reach ~384 chars).

---

## 6. Warnings and messages the app shows

### 6.1 Data-honesty warnings

| Message | Where | Why |
|---|---|---|
| "Form scoring not calibrated" | exercise list, on 2 exercises | thresholds are guesses, not measured |
| "Sample figures — not measured yet" | progress, history, myplan | placeholder numbers |
| "Sample report — figures are not measured" + "Not for clinical use" | report | reads as clinical output |
| "Illustrative only — not yet computed from your data" | insights | invented trend figures |
| "Not yet linked to your tracked sessions" | myplan | list is static |
| "Coming soon" | brain training | activities unimplemented |

### 6.2 State and error messages

| Message | Trigger |
|---|---|
| "PRACTICE MODE — Camera tracking isn't set up on this device yet, so these numbers are a demonstration" | native pose stack unavailable (RN) |
| "Practice mode only demonstrates Left Arm Raise, so this exercise will stay at zero" | simulated source, different exercise selected |
| "Move so your whole body is in view" | server returned `visible: false` |
| "Cannot reach the coach service" / "Coach service unavailable" | WebSocket or HTTP failure |
| `bad_frame`, `unknown_exercise`, `short_frame` | protocol errors, returned without ending the session |
| `[pose] falling back to practice mode: …` | console only, dev builds only |

### 6.3 Coaching cues (not warnings — normal feedback)

Emitted when a form rule is violated, with Sinhala and Tamil variants:
"Keep your elbow straight", "Sit tall, try not to lean", "Try to keep your body
still", "Keep your knee straight as you lift", "Keep your thigh flat on the bed",
"Sit back against the chair", "Keep your standing leg almost straight", "Keep your
back against the chair", "Stand up fully before sitting back down".

---

## 7. Known gaps

1. **Practice-mode reps are recorded as real progress.** `sessionLog` does not
   distinguish simulated from real, so simulated reps appear as green ticks in the
   library and totals in progress. The session banner is honest; the stored data
   is not. Fix pending: tag records as practice, or don't record them.
2. **No hold-duration scoring.** Isometric holds, balance tests (Romberg) and
   coordination drills (finger-to-nose, heel-to-shin) have no up/down cycle, so
   rep counting cannot represent them — roughly 6 of the 22 reference videos.
3. **Hamstring set has no left/right variants.** Each clip works one leg, and
   MediaPipe's left/right assignment flips with body orientation (the prone
   segment reads as `left_knee` where supine and seated read as `right_knee`).
   Sides were not asserted without evidence. This matters for hemiparesis, where
   the affected side is the point.
4. **`sit_to_stand` and `knee_extension` key off the left knee only.** Same
   hemiparesis concern; no right-side variant exists.
5. **Fall thresholds are geometric, not from recorded falls.** `fall.py` uses hip
   descent faster than 0.4 screen-heights/second with a 1.5s confirmation, derived
   from the geometry of a fall versus a controlled lie-down (~0.07). Validated
   against synthetic motion in both directions, never against a real fall.
6. **Form scores are relative to demonstrators, not patients.** Reference clips
   show therapists. A patient's reduced range will score lower by design; the
   absolute number needs clinical interpretation before a physio sees it.
7. **Flutter has 1 of 33 screens.** Exercise list and live session only.
8. **Split clips lost their audio.** ffmpeg is not installed, so the cuts were
   made with OpenCV, which writes video only.
