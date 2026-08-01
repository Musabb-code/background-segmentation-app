"""Decode → RGB → pad-resize 512 → normalize → batch float32."""
from __future__ import annotations

import cv2
import numpy as np

INPUT_SIZE = 512
_MEAN = np.array([0.5, 0.5, 0.5], dtype=np.float32)
_STD = np.array([0.5, 0.5, 0.5], dtype=np.float32)


def decode_image(data: bytes) -> np.ndarray:
    arr = np.frombuffer(data, dtype=np.uint8)
    bgr = cv2.imdecode(arr, cv2.IMREAD_COLOR)
    if bgr is None:
        raise ValueError("invalid image")
    return cv2.cvtColor(bgr, cv2.COLOR_BGR2RGB)


def letterbox(rgb: np.ndarray, size: int = INPUT_SIZE) -> tuple[np.ndarray, dict]:
    h, w = rgb.shape[:2]
    scale = min(size / h, size / w)
    nh, nw = int(round(h * scale)), int(round(w * scale))
    resized = cv2.resize(rgb, (nw, nh), interpolation=cv2.INTER_LINEAR)
    canvas = np.zeros((size, size, 3), dtype=np.uint8)
    top = (size - nh) // 2
    left = (size - nw) // 2
    canvas[top : top + nh, left : left + nw] = resized
    meta = {"orig_h": h, "orig_w": w, "top": top, "left": left, "nh": nh, "nw": nw, "size": size}
    return canvas, meta


def normalize(rgb_u8: np.ndarray) -> np.ndarray:
    x = rgb_u8.astype(np.float32) / 255.0
    return (x - _MEAN) / _STD


def preprocess(data: bytes) -> tuple[np.ndarray, np.ndarray, dict]:
    """Returns (batch[1,512,512,3], original_rgb, letterbox_meta)."""
    rgb = decode_image(data)
    boxed, meta = letterbox(rgb)
    batch = normalize(boxed)[np.newaxis, ...]
    return batch, rgb, meta


if __name__ == "__main__":
    # Tiny synthetic PNG via OpenCV
    img = np.zeros((120, 80, 3), dtype=np.uint8)
    img[20:100, 20:60] = (40, 180, 220)
    ok, buf = cv2.imencode(".png", cv2.cvtColor(img, cv2.COLOR_RGB2BGR))
    assert ok
    batch, rgb, meta = preprocess(buf.tobytes())
    assert batch.shape == (1, 512, 512, 3) and batch.dtype == np.float32
    assert rgb.shape == (120, 80, 3)
    assert meta["orig_h"] == 120 and meta["orig_w"] == 80
    print("preprocess OK")
