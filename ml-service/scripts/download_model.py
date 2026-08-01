#!/usr/bin/env python3
"""Fetch or create MODNet SavedModel under models/modnet/.

Real MODNet weights: place official TF SavedModel in models/modnet/ (see
https://github.com/ZHKKKe/MODNet). If missing, writes a tiny placeholder
SavedModel so the API pipeline is runnable locally.
"""
from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
MODEL_DIR = ROOT / "models" / "modnet"


def _write_placeholder(path: Path) -> None:
    import tensorflow as tf

    path.mkdir(parents=True, exist_ok=True)

    class PlaceHolder(tf.Module):
        @tf.function(input_signature=[tf.TensorSpec([None, 512, 512, 3], tf.float32)])
        def __call__(self, x):
            # Soft center matte from luminance — not real MODNet
            # ponytail: placeholder until real MODNet SavedModel is dropped in models/modnet/
            gray = tf.reduce_mean((x + 1.0) * 0.5, axis=-1, keepdims=True)
            yy, xx = tf.meshgrid(
                tf.linspace(-1.0, 1.0, 512), tf.linspace(-1.0, 1.0, 512), indexing="ij"
            )
            dist = tf.sqrt(xx * xx + yy * yy)
            blob = tf.clip_by_value(1.0 - dist, 0.0, 1.0)[tf.newaxis, ..., tf.newaxis]
            return tf.clip_by_value(gray * 0.35 + blob * 0.65, 0.0, 1.0)

    mod = PlaceHolder()
    tf.saved_model.save(
        mod, str(path), signatures={"serving_default": mod.__call__.get_concrete_function()}
    )
    print(f"Wrote placeholder SavedModel: {path}")


def main() -> int:
    (ROOT / "models").mkdir(parents=True, exist_ok=True)
    if MODEL_DIR.is_dir() and (MODEL_DIR / "saved_model.pb").is_file():
        print(f"Model present: {MODEL_DIR}")
        return 0
    print("No MODNet weights found — creating local placeholder SavedModel.")
    print("Replace models/modnet/ with official MODNet TF export for production quality.")
    try:
        _write_placeholder(MODEL_DIR)
    except Exception as exc:
        print(f"Failed to create placeholder: {exc}")
        print(f"Place a TF SavedModel at: {MODEL_DIR}")
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
