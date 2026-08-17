"""FastAPI service: pose-driven rep counting, form feedback and fall alerts.

The device streams keypoints (not pixels) over the WebSocket, so a 30fps session
costs roughly 200 bytes per frame instead of ~15KB.

Fall alerts are forwarded to the existing Node backend so the caregiver
dashboard keeps working unchanged.
"""

from __future__ import annotations

import asyncio
import logging
import os
from contextlib import asynccontextmanager

import httpx
from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware
from pydantic import ValidationError

from . import exercises as exercise_config
from .frames import FrameDecodeError, PoseEstimator, parse_envelope
from .schemas import FrameIn
from .session import Session

log = logging.getLogger("neuropulse.ml")

# The Node backend that owns alert fan-out. Override per environment; the
# emulator reaches the host machine at 10.0.2.2.
ALERTS_URL = os.environ.get("ALERTS_URL", "http://127.0.0.1:5000/api/alerts")

EXERCISES = exercise_config.load()


@asynccontextmanager
async def lifespan(app: FastAPI):
    app.state.http = httpx.AsyncClient(timeout=5.0)
    log.info("loaded %d exercises; alerts -> %s", len(EXERCISES), ALERTS_URL)
    try:
        yield
    finally:
        await app.state.http.aclose()


app = FastAPI(title="NeuroPulse ML Service", lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/health")
async def health() -> dict[str, object]:
    return {"ok": True, "exercises": len(EXERCISES)}


@app.get("/exercises")
async def list_exercises(lang: str = "en") -> list[dict[str, object]]:
    """Catalogue for the app, localised per request."""
    key = lang if lang in ("en", "si", "ta") else "en"
    return [
        {
            "id": ex.id,
            "name": ex.name(key),  # type: ignore[arg-type]
            "mode": ex.mode,
            "targetReps": ex.target_reps,
            "targetSeconds": ex.target_seconds,
            "calibrated": ex.calibrated,
            # For a hold, the conditions ARE the coaching cues.
            "cues": [
                r.cue(key)  # type: ignore[arg-type]
                for r in (ex.hold if ex.mode == "hold" else ex.form)
            ],
        }
        for ex in EXERCISES.values()
    ]


@app.websocket("/ws/session")
async def session_socket(
    ws: WebSocket,
    exercise: str,
    patient: str = "Unknown",
    lang: str = "en",
) -> None:
    await ws.accept()

    config = EXERCISES.get(exercise)
    if config is None:
        await ws.send_json(
            {"error": "unknown_exercise", "known": sorted(EXERCISES)}
        )
        await ws.close(code=1008)
        return

    key = lang if lang in ("en", "si", "ta") else "en"
    session = Session(config, lang=key)  # type: ignore[arg-type]
    await ws.send_json({"ready": True, "exercise": config.id})

    try:
        while True:
            payload = await ws.receive_json()
            try:
                frame = FrameIn.model_validate(payload)
            except ValidationError as exc:
                await ws.send_json({"error": "bad_frame", "detail": exc.errors(
                    include_url=False
                )[:3]})
                continue

            result = session.push(frame.t, frame.keypoints)
            await ws.send_json(result.model_dump())

            if result.fall:
                await _notify_fall(ws, patient)

    except WebSocketDisconnect:
        pass
    finally:
        summary = session.summary()
        log.info("session ended: %s", summary.model_dump())


@app.websocket("/ws/session/frames")
async def frames_socket(
    ws: WebSocket,
    exercise: str,
    patient: str = "Unknown",
    lang: str = "en",
) -> None:
    """Session driven by camera frames instead of device-side keypoints.

    See app/frames.py for the binary wire format and the measured reasoning behind
    it (stream small, stream in colour).

    The CLIENT must throttle. Frames are processed in order and MediaPipe is
    slower than a camera at 30fps, so an unthrottled sender builds a backlog and
    feedback drifts behind the patient. 10-12fps is the sweet spot.
    """
    await ws.accept()

    config = EXERCISES.get(exercise)
    if config is None:
        await ws.send_json({"error": "unknown_exercise", "known": sorted(EXERCISES)})
        await ws.close(code=1008)
        return

    key = lang if lang in ("en", "si", "ta") else "en"
    session = Session(config, lang=key)  # type: ignore[arg-type]
    estimator = PoseEstimator()
    await ws.send_json({"ready": True, "exercise": config.id, "source": "frames"})

    try:
        while True:
            message = await ws.receive()

            if message.get("type") == "websocket.disconnect":
                break

            payload = message.get("bytes")
            if payload is None:
                # A text frame is not part of this protocol; ignore rather than
                # tear down a live session over a stray message.
                continue

            try:
                frame = parse_envelope(payload)
            except FrameDecodeError as exc:
                await ws.send_json({"error": "bad_frame", "detail": str(exc)})
                continue

            # MediaPipe is blocking CPU work. Off the event loop, or the socket
            # stops reading while it runs.
            #
            # Decoding happens inside that thread, so a bad pixel format surfaces
            # here rather than at parse time. It must not tear down a live
            # session — a patient mid-exercise should not lose their reps because
            # one frame was malformed.
            try:
                kps = await asyncio.to_thread(
                    estimator.keypoints_from_frame, frame
                )
            except FrameDecodeError as exc:
                await ws.send_json({"error": "bad_frame", "detail": str(exc)})
                continue

            if kps is None:
                # No pose in this frame — usually the patient is out of shot.
                # Goes through the session so the reply carries the same fields as
                # every other frame, including the mode and hold state.
                await ws.send_json(
                    session.push_no_pose(frame.t_ms).model_dump()
                )
                continue

            result = session.push(frame.t_ms, kps)
            await ws.send_json(result.model_dump())

            if result.fall:
                await _notify_fall(ws, patient)

    except WebSocketDisconnect:
        pass
    finally:
        estimator.close()
        log.info("frame session ended: %s", session.summary().model_dump())


async def _notify_fall(ws: WebSocket, patient: str) -> None:
    """Forward a confirmed fall to the Node backend.

    Never lets a delivery failure kill the session -- the patient is mid-exercise
    and the socket carrying live feedback matters more than the alert round trip.
    """
    client: httpx.AsyncClient = ws.app.state.http
    try:
        response = await client.post(
            ALERTS_URL,
            json={"patient": patient, "status": "Fall Detected"},
        )
        response.raise_for_status()
        log.warning("fall alert delivered for %s", patient)
    except Exception as exc:  # noqa: BLE001 - degraded mode is intentional
        log.error("fall alert delivery failed: %s", exc)
