"""Prep → MODNet → postprocess → PNG bytes."""
from __future__ import annotations

from inference.engine import is_model_loaded, predict
from postprocessing.mask import postprocess
from preprocessing.frame import preprocess


def run_segment(image_bytes: bytes, quality: str = "standard") -> bytes:
    if quality not in ("standard", "high"):
        raise ValueError("quality must be standard or high")
    if not is_model_loaded():
        raise RuntimeError("model not loaded")
    batch, rgb, meta = preprocess(image_bytes)
    alpha = predict(batch)
    return postprocess(alpha, rgb, meta, quality)
