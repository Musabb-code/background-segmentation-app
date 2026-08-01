import time
from pathlib import Path

import cv2
import numpy as np
from fastapi import APIRouter, File, Form, Header, HTTPException, UploadFile, status
from fastapi.responses import Response

from api.auth import verify_token
from api.schemas import BenchmarkRequest, BenchmarkResponse, HealthResponse
from config import settings
from inference.engine import is_model_loaded
from inference.segment import run_segment

router = APIRouter()

_ALLOWED = {"image/jpeg", "image/jpg", "image/png", "application/octet-stream"}


def _sample_png(path: str | None = None) -> bytes:
    if path:
        p = Path(path)
        if not p.is_file():
            raise FileNotFoundError(path)
        return p.read_bytes()
    img = np.zeros((256, 192, 3), dtype=np.uint8)
    img[40:220, 48:144] = (60, 160, 220)
    ok, buf = cv2.imencode(".png", img)
    if not ok:
        raise RuntimeError("sample encode failed")
    return buf.tobytes()


@router.get("/health", response_model=HealthResponse)
def health():
    return HealthResponse(
        status="healthy",
        model_loaded=is_model_loaded(),
        model_type=settings.model_type,
        version="1.0.0",
    )


@router.post("/inference/segment")
async def segment(
    file: UploadFile = File(...),
    quality: str = Form("standard"),
    authorization: str | None = Header(None),
):
    verify_token(authorization)

    if quality not in ("standard", "high"):
        raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY, detail="invalid quality")

    ctype = (file.content_type or "").lower()
    name = (file.filename or "").lower()
    ok_type = (not ctype or ctype in _ALLOWED) and (
        not name or name.endswith((".jpg", ".jpeg", ".png"))
    )
    if not ok_type:
        raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY, detail="invalid format")

    data = await file.read()
    if len(data) > settings.max_image_size_mb * 1024 * 1024:
        raise HTTPException(status_code=status.HTTP_413_REQUEST_ENTITY_TOO_LARGE, detail="file too large")
    if not data:
        raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY, detail="invalid format")

    try:
        png = run_segment(data, quality)
    except ValueError as exc:
        raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY, detail=str(exc)) from exc
    except RuntimeError as exc:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=str(exc)) from exc
    except Exception as exc:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="inference failure") from exc

    return Response(
        content=png,
        media_type="image/png",
        headers={"Content-Disposition": "attachment; filename=segmented.png"},
    )


@router.post("/inference/benchmark", response_model=BenchmarkResponse)
def benchmark(body: BenchmarkRequest):
    if not is_model_loaded():
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="model not loaded")
    try:
        data = _sample_png(body.image_path)
    except FileNotFoundError as exc:
        raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY, detail=str(exc)) from exc

    times: list[float] = []
    for _ in range(body.iterations):
        t0 = time.perf_counter()
        run_segment(data, "standard")
        times.append((time.perf_counter() - t0) * 1000.0)

    times.sort()
    avg = sum(times) / len(times)
    p95 = times[min(len(times) - 1, int(0.95 * (len(times) - 1)))]
    fps = 1000.0 / avg if avg > 0 else 0.0
    print(f"benchmark iterations={body.iterations} avg_ms={avg:.1f} fps={fps:.2f} p95_ms={p95:.1f} (target>=2 FPS)")
    return BenchmarkResponse(
        iterations=body.iterations,
        avg_latency_ms=round(avg, 2),
        fps=round(fps, 2),
        p95_latency_ms=round(p95, 2),
    )
