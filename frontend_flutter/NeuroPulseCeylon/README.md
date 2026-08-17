# NeuroPulse Ceylon — Flutter client

Streams camera frames to the Python service, which runs MediaPipe and returns
reps, form score and coaching cues.

```
camera (NV21, 320x240, ~10fps)
    └─> ws://host:8100/ws/session/frames ─> MediaPipe ─> angle rules ─> reps/cues
                                                └─> POST node /api/alerts on a fall
```

## Why Flutter for this

The React Native client could not get camera frames at all. `expo-camera` has no
frame-processor API, and the alternative (VisionCamera + TFLite) needs a
development build that fails on this machine's 260-character Windows path limit —
React Native's New Architecture generates C++ whose object paths run to ~384
characters.

Flutter's `camera` package exposes `startImageStream` directly, and Flutter's
Android build has no C++ codegen step, so the path limit never arises. The debug
APK builds in about 100 seconds.

## Run

The ML service must listen on all interfaces, not just loopback:

```bash
cd ../../ml-service && .venv/Scripts/python.exe -m uvicorn app.main:app --host 0.0.0.0 --port 8100
```

Then, on an emulator (10.0.2.2 is its alias for the host machine):

```bash
flutter run
```

On a physical device, pass the machine's LAN address:

```bash
flutter run --dart-define=NPC_HOST=192.168.1.169
```

### Emulator storage

A debug APK is ~144MB and Android needs roughly three times that free to install.
If you hit `INSTALL_FAILED_INSUFFICIENT_STORAGE`, build release instead — 17.8MB,
installs fine:

```bash
flutter build apk --release --target-platform android-x64
```

### Testing pose properly

**The emulator's camera is a synthetic scene with no person in it**, so MediaPipe
finds no pose and the app correctly shows "Move so your whole body is in view".
That verifies the whole pipeline except pose detection itself.

For real tracking use a physical phone, or point the emulator at your laptop
webcam (Extended controls, Camera, set the back camera to `webcam0`).

## Wire format

Defined in `ml-service/app/frames.py`, built in `lib/pose/frame_envelope.dart`.
`test/widget_test.dart` asserts the two agree, because a silent mismatch produces
a session that connects and then does nothing — the hardest kind of bug to spot
from the UI.

## Measured decisions

Against the reference clips, MediaPipe found a pose in:

| input | detection rate | form |
|---|---|---|
| colour 640x480 | 93% | 0.99 |
| colour 320x240 | **96%** | 0.99 |
| grey 640x480 | 80% | 0.98 |
| grey 320x240 | 81% | 0.97 |

Low resolution is essentially free, so stream small. Greyscale is **not** free, so
don't "save bandwidth" by sending only the Y plane.

NV21 versus JPEG at 320x240, ~10fps:

| format | bytes/frame | frames without pose | bandwidth |
|---|---|---|---|
| JPEG q60 | 6.4 KB | 8 / 59 | 64 KB/s |
| NV21 | 115 KB | **4 / 59** | 1.15 MB/s |

NV21 wins on accuracy and costs the phone nothing, since encoding JPEG in Dart is
far too slow to hold 10fps. The bandwidth is fine on a LAN and unsuitable over
mobile data — if that changes, move pose on-device with
`google_mlkit_pose_detection` and switch to the keypoint endpoint
(`/ws/session`). The engine behind both is identical, which is why `session.py`
takes keypoints rather than pixels.

## Status

Working: exercise list from the service, live session with camera streaming, rep
count, phase, form score, cues, fall dialog, frame throttling with drop counters.

Not ported yet: the other 32 screens from the React Native app
(`../../frontend/src/app`). `lib/ui/tokens.dart` already carries the design system
— colours with their measured contrast ratios, 56dp targets, 17px body text,
script-safe line heights — so those screens have a foundation to build on.
