# My Model — Google Colab training plan

> **Purpose:** Copy-paste commands to train **your own** portrait background-removal models on **Google Colab (GPU)**.  
> **Product:** [Pixel Lift / MACKHAN](PLAN.md) Android app — live preview today uses **ML Kit**; this plan trains models you can **swap in later**.  
> **Long-term repo tasks:** [PLAN2.md](PLAN2.md) · [TASKS2.md](TASKS2.md) (Tasks 21–31, optional 29a–29b).  
> **Do not commit datasets or large weights to git.**

---

## 0. Read this first (scope)

| Track | Goal | Runs on | Output | FPS target |
|-------|------|---------|--------|------------|
| **A — Real-time (this doc’s main path)** | Custom **live** portrait matte | Phone via **TFLite** (optional primary later) | `selfie_segmentation.tflite` | Aim **15–30 FPS** @ 256×256 on mid-range ARM |
| **B — HQ stills (optional same Colab session)** | Sharper hair/edges on **Capture** | `ml-service` **MODNet** | TensorFlow **SavedModel** | Server **≥2 FPS** on CPU (PLAN2 §8) |

**Honest limits**

- **MODNet is too heavy** for typical real-time camera preview on a phone — use Track **A** for live, Track **B** for HQ capture (same as Phase 1 architecture).
- Training happens **only in Colab** (or your PC), **not** inside the Android app (PLAN.md §14).
- Before replacing ML Kit in production, complete **Task 29b** wiring in [TASKS2.md](TASKS2.md) and device FPS tests.

**Match MACKHAN serve/preprocess (HQ / MODNet)**

- Letterbox + normalize: `ml-service/preprocessing/frame.py` — **512×512**, mean **0.5**, std **0.5** on RGB ÷255.

**Match MACKHAN live fallback (TFLite)**

- Target asset path: `mobile/assets/models/selfie_segmentation.tflite`
- Mask contract: per-pixel confidence **0.0–1.0** (see `mobile/lib/core/services/ml_on_device_service.dart` → `MaskFrame`).
- **Recommended export size:** **256×256** (same as elliptical prior stub today).

---

## 1. One-time setup (Kaggle + Drive)

### 1.1 Kaggle API token (on your PC once)

1. Kaggle → Account → **Create New Token** → downloads `kaggle.json`.
2. Put `kaggle.json` on Drive at **`MyDrive/mackhan-ml/secrets/kaggle.json`** (Cell 3 picks it up), **or** upload in Colab via **Cell 4**. Never commit to GitHub.

### 1.2 Google Drive folders (create empty)

On Drive, create:

```text
MyDrive/mackhan-ml/
├── datasets/          # raw downloads
├── prepared/          # train/val images+masks
├── runs/              # checkpoints, tflite, savedmodel
└── secrets/           # kaggle.json (optional)
```

---

## 2. Colab notebook — copy each block into its own cell

**Runtime:** **Change runtime type → T4 GPU** (or better).  
**Order:** Run cells top to bottom.

---

### Cell 1 — GPU check

```python
!nvidia-smi
import tensorflow as tf
print("TF:", tf.__version__)
print("GPUs:", tf.config.list_physical_devices("GPU"))
assert len(tf.config.list_physical_devices("GPU")) > 0, "Enable GPU runtime"
```

---

### Cell 2 — Install deps (pin close to ml-service)

```python
!pip install -q "tensorflow>=2.15,<2.19" opencv-python-headless numpy Pillow tqdm kaggle
```

---

### Cell 3 — Mount Drive + paths

```python
from google.colab import drive
drive.mount("/content/drive")

import os
ROOT = "/content/drive/MyDrive/mackhan-ml"
for sub in ("datasets", "prepared", "runs", "secrets"):
    os.makedirs(f"{ROOT}/{sub}", exist_ok=True)

# Optional: copy kaggle.json from Drive
KAGGLE_JSON = f"{ROOT}/secrets/kaggle.json"
if os.path.isfile(KAGGLE_JSON):
    !mkdir -p ~/.kaggle
    !cp "{KAGGLE_JSON}" ~/.kaggle/kaggle.json
    !chmod 600 ~/.kaggle/kaggle.json
    print("Kaggle credentials OK")
else:
    print("Upload kaggle.json to", KAGGLE_JSON, "or use Cell 4 upload widget")
```

---

### Cell 4 — (Alternative) Upload `kaggle.json` in Colab

```python
from google.colab import files
import shutil, os
uploaded = files.upload()  # pick kaggle.json
os.makedirs("/root/.kaggle", exist_ok=True)
shutil.move("kaggle.json", "/root/.kaggle/kaggle.json")
!chmod 600 /root/.kaggle/kaggle.json
print("Kaggle ready")
```

---

### Cell 5 — Download a portrait matting dataset (example)

**You must verify license** (commercial use, attribution). Replace slug with your chosen dataset.

```python
# Example: search Kaggle for "human segmentation", "portrait matting", "alpha matte"
DATASET_SLUG = "your-username/your-portrait-matting-dataset"  # <-- EDIT

RAW = f"{ROOT}/datasets/kaggle_raw"
!kaggle datasets download -d {DATASET_SLUG} -p "{RAW}" --unzip
!find "{RAW}" -maxdepth 3 -type f | head -20
```

If you already have `images/` + `masks/` on Drive, skip Kaggle and point `RAW` to that folder.

---

### Cell 6 — Prepare `train/` and `val/` (80/20)

Expects paired files with **same basename**: `images/0001.jpg` ↔ `masks/0001.png` (mask = single-channel alpha 0–255).

**Edit** `IMAGE_DIR` and `MASK_DIR` to match your download layout.

```python
import os, random, shutil
from pathlib import Path

RAW = Path(f"{ROOT}/datasets/kaggle_raw")  # <-- adjust if needed
IMAGE_DIR = RAW / "images"   # <-- EDIT
MASK_DIR = RAW / "masks"     # <-- EDIT

OUT = Path(f"{ROOT}/prepared")
for split in ("train", "val"):
    (OUT / split / "images").mkdir(parents=True, exist_ok=True)
    (OUT / split / "masks").mkdir(parents=True, exist_ok=True)

pairs = []
for img_path in IMAGE_DIR.glob("*"):
    if img_path.suffix.lower() not in {".jpg", ".jpeg", ".png"}:
        continue
    m = MASK_DIR / (img_path.stem + ".png")
    if not m.exists():
        m = MASK_DIR / (img_path.stem + ".jpg")
    if m.exists():
        pairs.append((img_path, m))

random.seed(42)
random.shuffle(pairs)
n_val = max(1, int(len(pairs) * 0.2))
val_pairs, train_pairs = pairs[:n_val], pairs[n_val:]

def copy_pairs(items, split):
    for ip, mp in items:
        shutil.copy2(ip, OUT / split / "images" / ip.name)
        shutil.copy2(mp, OUT / split / "masks" / (ip.stem + ".png"))

copy_pairs(train_pairs, "train")
copy_pairs(val_pairs, "val")
print(f"train={len(train_pairs)} val={len(val_pairs)}")
```

---

## Track A — Real-time TFLite (256×256)

### Cell A1 — Hyperparameters

```python
IMG_SIZE = 256          # live model input (TFLite)
BATCH_SIZE = 16         # lower to 8 if OOM
EPOCHS = 25
LR = 1e-4
RUN_ID = "realtime_mobilenetv2_256"
RUN_DIR = f"{ROOT}/runs/{RUN_ID}"
os.makedirs(RUN_DIR, exist_ok=True)
```

---

### Cell A2 — Data pipeline

```python
import cv2
import numpy as np
import tensorflow as tf
from pathlib import Path

PREP = Path(f"{ROOT}/prepared")

def load_pair(img_path, mask_path):
    img = cv2.imread(str(img_path))
    img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    m = cv2.imread(str(mask_path), cv2.IMREAD_GRAYSCALE)
    img = cv2.resize(img, (IMG_SIZE, IMG_SIZE), interpolation=cv2.INTER_LINEAR)
    m = cv2.resize(m, (IMG_SIZE, IMG_SIZE), interpolation=cv2.INTER_LINEAR)
    img = img.astype(np.float32) / 255.0
    m = (m.astype(np.float32) / 255.0)[..., np.newaxis]
    return img, m

def list_pairs(split):
    imgs = sorted((PREP / split / "images").glob("*"))
    out = []
    for ip in imgs:
        mp = PREP / split / "masks" / (ip.stem + ".png")
        if mp.exists():
            out.append((ip, mp))
    return out

def make_ds(split, training):
    pairs = list_pairs(split)
    imgs = [str(p[0]) for p in pairs]
    masks = [str(p[1]) for p in pairs]
    ds = tf.data.Dataset.from_tensor_slices((imgs, masks))
    if training:
        ds = ds.shuffle(min(len(imgs), 512), seed=42)
    def _map(i, m):
        img, mask = tf.numpy_function(
            lambda a, b: load_pair(a.decode(), b.decode()),
            [i, m],
            [tf.float32, tf.float32],
        )
        img.set_shape((IMG_SIZE, IMG_SIZE, 3))
        mask.set_shape((IMG_SIZE, IMG_SIZE, 1))
        if training:
            if tf.random.uniform(()) > 0.5:
                img = tf.image.flip_left_right(img)
                mask = tf.image.flip_left_right(mask)
        return img, mask
    return ds.map(_map, num_parallel_calls=tf.data.AUTOTUNE).batch(BATCH_SIZE).prefetch(tf.data.AUTOTUNE)

train_ds = make_ds("train", True)
val_ds = make_ds("val", False)
```

---

### Cell A3 — Build lightweight model (MobileNetV2 encoder)

```python
from tensorflow.keras import layers, Model

def build_model(size=256):
    inp = layers.Input((size, size, 3))
    base = tf.keras.applications.MobileNetV2(
        input_tensor=inp, include_top=False, weights="imagenet", alpha=0.75,
    )
    x = base.output
    x = layers.Conv2D(128, 3, padding="same", activation="relu")(x)
    x = layers.UpSampling2D(2)(x)
    x = layers.Conv2D(64, 3, padding="same", activation="relu")(x)
    x = layers.UpSampling2D(2)(x)
    x = layers.Conv2D(32, 3, padding="same", activation="relu")(x)
    x = layers.UpSampling2D(2)(x)
    x = layers.Conv2D(16, 3, padding="same", activation="relu")(x)
    x = layers.UpSampling2D(2)(x)
    x = layers.Conv2D(1, 1, padding="same", activation="sigmoid")(x)
    return Model(inp, x)

model = build_model(IMG_SIZE)
model.compile(
    optimizer=tf.keras.optimizers.Adam(LR),
    loss="binary_crossentropy",
    metrics=["mae"],
)
model.summary()
```

---

### Cell A4 — Train + save best checkpoint

```python
ckpt = f"{RUN_DIR}/best.keras"
cbs = [
    tf.keras.callbacks.ModelCheckpoint(ckpt, save_best_only=True, monitor="val_loss"),
    tf.keras.callbacks.EarlyStopping(patience=5, restore_best_weights=True, monitor="val_loss"),
    tf.keras.callbacks.ReduceLROnPlateau(factor=0.5, patience=2, min_lr=1e-6),
]
history = model.fit(train_ds, validation_data=val_ds, epochs=EPOCHS, callbacks=cbs)
best = tf.keras.models.load_model(ckpt)
best.save(f"{RUN_DIR}/final.keras")
print("Saved:", ckpt)
```

---

### Cell A5 — Visual sanity check (val samples)

```python
import matplotlib.pyplot as plt

for img, mask in val_ds.take(1):
    pred = best.predict(img, verbose=0)
    for i in range(min(3, img.shape[0])):
        fig, ax = plt.subplots(1, 3, figsize=(9, 3))
        ax[0].imshow(img[i].numpy()); ax[0].set_title("input"); ax[0].axis("off")
        ax[1].imshow(mask[i].numpy().squeeze(), cmap="gray"); ax[1].set_title("GT"); ax[1].axis("off")
        ax[2].imshow(pred[i].squeeze(), cmap="gray"); ax[2].set_title("pred"); ax[2].axis("off")
        plt.show()
```

---

### Cell A6 — Export TFLite (float32 + optional float16)

```python
import numpy as np

def representative_dataset():
    for img, _ in train_ds.take(32):
        for i in range(img.shape[0]):
            yield [img[i:i+1].numpy().astype(np.float32)]

converter = tf.lite.TFLiteConverter.from_keras_model(best)
converter.optimizations = [tf.lite.Optimize.DEFAULT]
converter.representative_dataset = representative_dataset
converter.target_spec.supported_types = [tf.float16]

tflite_model = converter.convert()
tflite_path = f"{RUN_DIR}/selfie_segmentation.tflite"
with open(tflite_path, "wb") as f:
    f.write(tflite_model)
print("Wrote", tflite_path, "bytes", len(tflite_model))
```

---

### Cell A7 — Download TFLite to your PC

```python
from google.colab import files
files.download(tflite_path)
```

**On your PC (MACKHAN repo):**

```powershell
# Copy into Flutter assets (after Task 29b wiring)
Copy-Item -Path ".\selfie_segmentation.tflite" -Destination "D:\MACKHAN\mobile\assets\models\selfie_segmentation.tflite"
```

Then follow [TASKS2.md](TASKS2.md) **Task 29b** to connect `MlOnDeviceService` TFLite path (ML Kit stays default until you choose to switch).

---

## Track B — HQ MODNet fine-tune (optional, 512×512)

Use the **same** `prepared/` data. Full repo automation later: [TASKS2.md](TASKS2.md) Tasks 25–26.

### Cell B1 — Clone MODNet + download pretrained (MIT)

```python
!git clone --depth 1 https://github.com/ZHKKKe/MODNet.git /content/MODNet
# Manual: download official MODNet portrait ckpt from MODNet repo releases/README
# Place as: /content/modnet_pretrained.ckpt  (or .pth — convert per MODNet docs)
PRETRAINED = "/content/modnet_pretrained.ckpt"  # <-- EDIT path after download
```

MODNet training scripts vary by PyTorch version; **recommended path for MACKHAN:**

1. Finish Track **A** in Colab (proves your data pipeline).
2. Back on PC, run **Task 22–26** so `train_modnet.py` / `export_savedmodel.py` live in `ml-service/training/` and match `inference/engine.py`.

### Cell B2 — Quick TF sanity (same normalize as serve)

```python
# Verify letterbox+norm matches ml-service/preprocessing/frame.py
import numpy as np
MEAN, STD = 0.5, 0.5
SIZE = 512
x = np.random.randint(0, 255, (SIZE, SIZE, 3), dtype=np.uint8)
t = x.astype(np.float32) / 255.0
t = (t - MEAN) / STD
assert t.shape == (512, 512, 3)
print("Preprocess constants OK for MODNet export")
```

Export destination on PC: `ml-service/models/modnet/` → restart ml-service → `POST /inference/benchmark`.

---

## 3. After training — integrate with MACKHAN

| Step | Action |
|------|--------|
| 1 | Record baseline if not done: [TASKS2.md](TASKS2.md) **Task 21** |
| 2 | Copy TFLite → `mobile/assets/models/` (**Task 29a–29b**) |
| 3 | Copy SavedModel → `ml-service/models/modnet/` (**Task 28**) |
| 4 | A/B vs Phase 1: hair, glasses, dark skin, batch gallery (**Task 29**) |
| 5 | Log metrics + accept/rollback in [LOG.md](LOG.md) |

**Quality gates (PLAN2 §8):** server FPS ≥ 2; HQ avg latency &lt; 500 ms on 1080p input; manual edge review on 10+ portraits.

---

## 4. Troubleshooting

| Problem | Fix |
|---------|-----|
| Colab OOM | `BATCH_SIZE=8`, `alpha=0.5` on MobileNetV2, or IMG_SIZE=224 |
| Empty `pairs` in Cell 6 | Fix `IMAGE_DIR` / `MASK_DIR`; masks must match image stems |
| Kaggle 403 | Refresh `kaggle.json`; accept dataset rules on Kaggle website |
| TFLite slow on phone | Use float16 export; keep 256×256; test on arm64 APK |
| Fine-tune worse than pretrained | Roll back to `models/modnet_pretrained/`; more data / lower LR |

---

## 5. Checklist (printable)

- [ ] Phase 1 MVP runs on phone ([APK_PHONE_RUNBOOK.md](APK_PHONE_RUNBOOK.md))
- [ ] Colab GPU runtime enabled
- [ ] Dataset license verified
- [ ] `prepared/train` + `prepared/val` populated
- [ ] Track A: `selfie_segmentation.tflite` exported + downloaded
- [ ] Track B (optional): SavedModel in `ml-service/models/modnet/`
- [ ] Tasks 21 → 29 logged in [LOG.md](LOG.md) / [TASKS2.md](TASKS2.md)

---

## 6. References

- [PLAN2.md](PLAN2.md) — Phase 2 architecture
- [TASKS2.md](TASKS2.md) — Tasks 21–31
- [PIXEL_LIFT_PLAN.md](PIXEL_LIFT_PLAN.md) — Stream 5 / accuracy (optional model swap)
- MODNet: https://github.com/ZHKKKe/MODNet
- MACKHAN preprocess: `ml-service/preprocessing/frame.py`
- MACKHAN on-device mask: `mobile/lib/core/services/ml_on_device_service.dart`

*Created: 2026-09-29 — Colab copy-paste plan for custom real-time (TFLite) + optional HQ (MODNet).*
