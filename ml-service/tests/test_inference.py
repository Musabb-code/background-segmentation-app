"""PLAN §7.7 — load model, segment sample, assert PNG has alpha."""
from __future__ import annotations

import os
import runpy
from pathlib import Path

import cv2
import numpy as np
import pytest
from jose import jwt

os.environ.setdefault("JWT_SECRET", "test-secret-key-at-least-32-chars!!")

ROOT = Path(__file__).resolve().parent.parent


@pytest.fixture(scope="module")
def model_ready():
    from inference.engine import is_model_loaded, load_model

    try:
        import tensorflow  # noqa: F401
    except ImportError:
        pytest.skip("tensorflow not installed (need Python 3.11)")

    ns = runpy.run_path(str(ROOT / "scripts" / "download_model.py"))
    if ns["main"]() != 0:
        pytest.skip("could not create/load model")
    load_model()
    if not is_model_loaded():
        pytest.skip("model not loaded")


def _portrait_png() -> bytes:
    img = np.zeros((240, 180, 3), dtype=np.uint8)
    img[30:210, 40:140] = (80, 140, 200)
    ok, buf = cv2.imencode(".png", img)
    assert ok
    return buf.tobytes()


def test_inference_png_has_alpha(model_ready):
    from inference.segment import run_segment

    png = run_segment(_portrait_png(), "standard")
    assert png[:8] == b"\x89PNG\r\n\x1a\n"
    decoded = cv2.imdecode(np.frombuffer(png, np.uint8), cv2.IMREAD_UNCHANGED)
    assert decoded is not None
    assert decoded.ndim == 3 and decoded.shape[2] == 4


def test_benchmark_endpoint(model_ready):
    from fastapi.testclient import TestClient

    from main import app

    with TestClient(app) as client:
        r = client.post("/inference/benchmark", json={"iterations": 2})
        assert r.status_code == 200
        body = r.json()
        assert body["iterations"] == 2
        assert body["avg_latency_ms"] > 0
        assert body["fps"] > 0
        assert body["p95_latency_ms"] > 0


def test_segment_requires_jwt(model_ready):
    from fastapi.testclient import TestClient

    from main import app

    token = jwt.encode({"sub": "test"}, os.environ["JWT_SECRET"], algorithm="HS256")
    with TestClient(app) as client:
        assert (
            client.post(
                "/inference/segment", files={"file": ("x.png", _portrait_png(), "image/png")}
            ).status_code
            == 401
        )
        r = client.post(
            "/inference/segment",
            files={"file": ("x.png", _portrait_png(), "image/png")},
            headers={"Authorization": f"Bearer {token}"},
        )
        assert r.status_code == 200
        assert r.headers["content-type"].startswith("image/png")
        assert r.content[:8] == b"\x89PNG\r\n\x1a\n"
