"""MODNet TF SavedModel singleton — load once, predict alpha matte."""
from __future__ import annotations

from pathlib import Path

import numpy as np

from config import settings

_model = None
_predict_fn = None


def load_model() -> None:
    global _model, _predict_fn
    path = Path(settings.model_path)
    if not path.is_dir() or not (path / "saved_model.pb").is_file():
        _model = None
        _predict_fn = None
        return
    import tensorflow as tf

    _model = tf.saved_model.load(str(path))
    if hasattr(_model, "signatures") and "serving_default" in _model.signatures:
        _predict_fn = _model.signatures["serving_default"]
    elif callable(_model):
        _predict_fn = _model
    else:
        _model = None
        _predict_fn = None


def is_model_loaded() -> bool:
    return _predict_fn is not None


def predict(batch: np.ndarray) -> np.ndarray:
    """batch [1,H,W,3] float32 → alpha [H,W] float32 in 0..1."""
    if _predict_fn is None:
        raise RuntimeError("model not loaded")
    import tensorflow as tf

    out = _predict_fn(tf.constant(batch))
    if isinstance(out, dict):
        out = next(iter(out.values()))
    arr = np.asarray(out)
    if arr.ndim == 4:
        arr = arr[0, :, :, 0]
    elif arr.ndim == 3:
        arr = arr[0]
    return np.clip(arr.astype(np.float32), 0.0, 1.0)
