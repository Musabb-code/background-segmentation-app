"""Alpha matte → soft edges → RGBA PNG bytes."""
from __future__ import annotations

import cv2
import numpy as np

# ponytail: morphology+Gaussian instead of guided filter (ximgproc not in opencv-headless); swap if edges fail QA


def _unletterbox(alpha_512: np.ndarray, meta: dict) -> np.ndarray:
    """Crop padding then resize to original HxW."""
    top, left, nh, nw = meta["top"], meta["left"], meta["nh"], meta["nw"]
    crop = alpha_512[top : top + nh, left : left + nw]
    return cv2.resize(crop, (meta["orig_w"], meta["orig_h"]), interpolation=cv2.INTER_LINEAR)


def refine_alpha(alpha: np.ndarray, quality: str = "standard") -> np.ndarray:
    a = np.clip(alpha.astype(np.float32), 0.0, 1.0)
    # soft thresholds
    lo, hi = (0.2, 0.8) if quality == "high" else (0.3, 0.7)
    a = np.clip((a - lo) / (hi - lo + 1e-6), 0.0, 1.0)
    u8 = (a * 255).astype(np.uint8)
    kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (3, 3))
    u8 = cv2.morphologyEx(u8, cv2.MORPH_OPEN, kernel)
    u8 = cv2.morphologyEx(u8, cv2.MORPH_CLOSE, kernel)
    blur = 5 if quality == "high" else 3
    u8 = cv2.GaussianBlur(u8, (blur, blur), 0)
    return u8.astype(np.float32) / 255.0


def composite_rgba(rgb: np.ndarray, alpha: np.ndarray) -> np.ndarray:
    a = np.clip(alpha, 0.0, 1.0)[..., np.newaxis]
    rgba = np.concatenate([rgb.astype(np.float32) * a, a * 255.0], axis=-1)
    return np.clip(rgba, 0, 255).astype(np.uint8)


def encode_png(rgba: np.ndarray) -> bytes:
    bgra = cv2.cvtColor(rgba, cv2.COLOR_RGBA2BGRA)
    ok, buf = cv2.imencode(".png", bgra)
    if not ok:
        raise RuntimeError("png encode failed")
    return buf.tobytes()


def postprocess(alpha_512: np.ndarray, rgb: np.ndarray, meta: dict, quality: str = "standard") -> bytes:
    alpha = _unletterbox(alpha_512, meta)
    alpha = refine_alpha(alpha, quality)
    return encode_png(composite_rgba(rgb, alpha))


if __name__ == "__main__":
    rgb = np.full((40, 30, 3), 200, dtype=np.uint8)
    meta = {"orig_h": 40, "orig_w": 30, "top": 100, "left": 100, "nh": 312, "nw": 234, "size": 512}
    alpha = np.zeros((512, 512), dtype=np.float32)
    alpha[100:412, 100:334] = 1.0
    png = postprocess(alpha, rgb, meta, "standard")
    assert png[:8] == b"\x89PNG\r\n\x1a\n"
    decoded = cv2.imdecode(np.frombuffer(png, np.uint8), cv2.IMREAD_UNCHANGED)
    assert decoded is not None and decoded.shape[2] == 4
    print("postprocess OK")
