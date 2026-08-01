# MACKHAN — Phase 2 Task File (Custom Model Training)

> **Start here only after Phase 1 is complete** — all items in [TASKS.md](TASKS.md) checked (Tasks 0–20b).  
> **Blueprint:** [PLAN2.md](PLAN2.md) — custom training, model swap, optional TFLite.  
> **Phase 1 boundary:** [PLAN.md](PLAN.md) §0–§13 — do not mix Phase 2 work into MVP tasks.

---

## What Phase 2 builds

| Goal | Detail |
|------|--------|
| **Train** | Fine-tune MODNet on your data (Kaggle / portrait matting datasets) |
| **Export** | TensorFlow SavedModel → `ml-service/models/modnet/` |
| **Deploy** | Same API (`POST /inference/segment`) — swap weights, minimal code change |
| **Optional** | TFLite export → `mobile/assets/models/` for on-device fallback |
| **Do not build** | In-app training UI, Kaggle download from production, dataset upload in app (PLAN.md §14) |

**Build order:** Prerequisites → Data → Training code → Fine-tune → Export → Eval → Deploy → Docs → Review.

---

## Rules for Every Phase 2 Task

1. **PLAN2.md is the boundary** — only build what PLAN2.md defines.
2. **Phase 1 app must already work** — training improves HQ quality; it does not replace MVP delivery.
3. **One task at a time** — finish, test, log, next.
4. **Ponytail (Repo 1) is mandatory on EVERY task — no exceptions.**
5. **Training is offline** — scripts in `ml-service/training/` or Colab; never train inside the mobile app.
6. **Do not commit datasets** — `ml-service/training/data/` stays gitignored.
7. **Before marking done** — Ponytail YAGNI check; use `ponytail-review` after Task 30b.
8. Update **`docs/LOG.md`** and check off **`docs/TASKS2.md`** after every task.

### Four-repo read order (Phase 2)

| Repo | Path | When |
|------|------|------|
| **1 Ponytail** | `.cursor/skills/ponytail/SKILL.md` | **Every task — mandatory** |
| **1 Ponytail review** | `.cursor/skills/ponytail-review/SKILL.md` | Task 30b |
| **2 Anthropic** | `skills/skills/{skill}/SKILL.md` | Per task table |
| **3 Flutter** | `flutter-skills/skills/{skill}/SKILL.md` | Task 29 only (optional TFLite) |
| **4 Dart** | `dart-skills/skills/{skill}/SKILL.md` | Task 29 only (optional TFLite) |

### Prompt footer (every Phase 2 task)

```
Stay inside docs/PLAN2.md only. Phase 1 MVP must be complete. MANDATORY: read .cursor/skills/ponytail/SKILL.md (Repo 1). Also read docs/PLAN2.md, docs/LOG.md, skills/skills/{anthropic}/SKILL.md (Repo 2). Apply Ponytail YAGNI before done. Update docs/LOG.md. Mark complete in docs/TASKS2.md.
```

---

## Phase 0 — Prerequisites (gate)

> **Do not start Task 22+ until Task 21 is checked.** Confirms Phase 1 baseline exists for A/B comparison.

- [ ] **Task 21** — Phase 1 baseline + Phase 2 gate

**Deliverables:**
- Confirm [TASKS.md](TASKS.md) Tasks 0–20b all `[x]`
- Record baseline in `docs/LOG.md` or `ml-service/training/baseline.json`:
  - `POST /inference/benchmark` → `avg_latency_ms`, `fps`, `p95_latency_ms`
  - 20+ portrait HQ captures saved under `ml-service/training/baseline_samples/` (gitignored)
- Python **3.11** venv working: `pip install -r ml-service/requirements.txt`
- Real MODNet weights in `models/modnet/` (not placeholder) OR document placeholder + accept lower quality baseline
- GPU note: Colab or local NVIDIA documented in LOG

**Prompt:**
```
Task 21: Phase 2 gate per docs/PLAN2.md §2. Verify Phase 1 complete (TASKS.md 0–20b). Record ML benchmark baseline + save sample HQ outputs for later A/B. Confirm Python 3.11 + ml-service deps install. MANDATORY: read .cursor/skills/ponytail/SKILL.md (Repo 1). Also read docs/PLAN2.md, docs/LOG.md, skills/skills/doc-coauthoring/SKILL.md (Repo 2). Apply Ponytail YAGNI. Update docs/LOG.md. Mark Task 21 complete in docs/TASKS2.md.
```

---

## Phase 1 — Training scaffold + data

- [ ] **Task 22** — Training folder scaffold

**Deliverables:**
- `ml-service/training/README.md` — overview, folder layout, links to PLAN2 §3–§7
- `ml-service/training/requirements-train.txt` — only extras not in root `requirements.txt` (e.g. `tqdm`, `matplotlib` if needed)
- `.gitignore` entries: `training/data/`, `training/runs/`, `training/checkpoints/`, `training/baseline_samples/`
- Empty stubs or `__init__.py` as needed

**Prompt:**
```
Task 22: Scaffold ml-service/training/ per docs/PLAN2.md §5. README, requirements-train.txt, gitignore for data/runs. MANDATORY: read .cursor/skills/ponytail/SKILL.md (Repo 1). Also read docs/PLAN2.md, docs/LOG.md, skills/skills/doc-coauthoring/SKILL.md (Repo 2). Apply Ponytail YAGNI. Update docs/LOG.md. Mark Task 22 complete in docs/TASKS2.md.
```

- [ ] **Task 23** — Dataset prep script (Kaggle → train/val)

**Deliverables:**
- `ml-service/training/prepare_dataset.py`
  - Input: raw folder or Kaggle export path (CLI args)
  - Output: `training/data/train/{images,masks}/` + `training/data/val/{images,masks}/`
  - 80/20 split, paired filenames, mask = single-channel alpha 0–255
  - License reminder printed (user must verify Kaggle license)
- `ml-service/training/DATASETS.md` — example Kaggle search terms, Supervisely/AISegment notes, license checklist

**Prompt:**
```
Task 23: Dataset prep script per docs/PLAN2.md §3.4. prepare_dataset.py + DATASETS.md. No data committed to git. MANDATORY: read .cursor/skills/ponytail/SKILL.md (Repo 1). Also read docs/PLAN2.md, docs/LOG.md, skills/skills/doc-coauthoring/SKILL.md (Repo 2). Apply Ponytail YAGNI. Update docs/LOG.md. Mark Task 23 complete in docs/TASKS2.md.
```

- [ ] **Task 24** — Data loader + augmentations

**Deliverables:**
- `ml-service/training/dataset.py`
  - `PortraitMattingDataset` — load image/mask pairs
  - Augmentations: flip, color jitter, scale (train only)
  - **Reuse** normalize constants from `preprocessing/frame.py` (`INPUT_SIZE`, mean/std) so train/serve match
- Runnable self-check: `python training/dataset.py` loads one batch

**Prompt:**
```
Task 24: training/dataset.py per docs/PLAN2.md §5. Share preprocess constants with preprocessing/frame.py. MANDATORY: read .cursor/skills/ponytail/SKILL.md (Repo 1). Also read docs/PLAN2.md, docs/LOG.md. Apply Ponytail YAGNI. Update docs/LOG.md. Mark Task 24 complete in docs/TASKS2.md.
```

---

## Phase 2 — Fine-tune MODNet

- [ ] **Task 25** — Fine-tune training loop

**Deliverables:**
- `ml-service/training/train_modnet.py`
  - CLI: `--data`, `--pretrained`, `--epochs`, `--batch-size`, `--lr`, `--out`
  - Load official MODNet pretrained checkpoint from `training/checkpoints/pretrained/` (document download in README)
  - Loss: alpha matting loss (L1 or combo L1 + gradient — keep minimal)
  - Checkpoint best val loss → `training/runs/{run_id}/best/`
  - Early stopping optional (ponytail: skip if YAGNI says one fixed epoch count is enough for v1)

**Prompt:**
```
Task 25: training/train_modnet.py fine-tune loop per docs/PLAN2.md §4.1. Document where to place pretrained MODNet weights. MANDATORY: read .cursor/skills/ponytail/SKILL.md (Repo 1). Also read docs/PLAN2.md, docs/LOG.md. Apply Ponytail YAGNI. Update docs/LOG.md. Mark Task 25 complete in docs/TASKS2.md.
```

- [ ] **Task 26** — Export SavedModel

**Deliverables:**
- `ml-service/training/export_savedmodel.py`
  - CLI: `--checkpoint`, `--out` (default `models/modnet`)
  - Output: TF SavedModel with `serving_default` signature
  - Input `[None, 512, 512, 3]` float32, output alpha matte compatible with `inference/engine.py`
- Smoke: export → `pytest tests/test_inference.py -q` passes

**Prompt:**
```
Task 26: training/export_savedmodel.py per docs/PLAN2.md §4.1 step 5 + §6.1. Export must work with existing inference/engine.py without changes. MANDATORY: read .cursor/skills/ponytail/SKILL.md (Repo 1). Also read docs/PLAN2.md, docs/LOG.md, skills/skills/webapp-testing/SKILL.md (Repo 2). Run pytest if TF available. Update docs/LOG.md. Mark Task 26 complete in docs/TASKS2.md.
```

- [ ] **Task 27** — Evaluation + visual report

**Deliverables:**
- `ml-service/training/eval.py`
  - Metrics on val set: MSE, MAD, SAD on alpha
  - Side-by-side PNGs: input | GT mask | pred mask | composite → `training/runs/{run_id}/eval/`
  - Compare against Phase 1 baseline samples if present
- `training/runs/{run_id}/metrics.json` written

**Prompt:**
```
Task 27: training/eval.py per docs/PLAN2.md §4.1 + §8. Metrics + visual comparison PNGs. MANDATORY: read .cursor/skills/ponytail/SKILL.md (Repo 1). Also read docs/PLAN2.md, docs/LOG.md. Apply Ponytail YAGNI. Update docs/LOG.md. Mark Task 27 complete in docs/TASKS2.md.
```

---

## Phase 3 — Deploy fine-tuned model

- [ ] **Task 28** — Model swap + benchmark regression

**Deliverables:**
- Copy exported SavedModel to `models/modnet/` (or `models/modnet_v2/` + `.env` `MODEL_PATH`)
- Keep rollback copy: `models/modnet_pretrained/`
- Optional `.env`: `MODEL_TYPE=modnet-finetuned`
- Run `POST /inference/benchmark` — log new vs Task 21 baseline in LOG
- Quality gates (PLAN2 §8): FPS ≥ 2, manual edge review on 10 portraits
- Document accept/reject decision in LOG

**Files touched (expected):**
- `ml-service/.env` / `.env.example` (MODEL_TYPE only if needed)
- `ml-service/models/modnet/` (weights — not committed)
- `docs/LOG.md`

**Prompt:**
```
Task 28: Deploy fine-tuned model per docs/PLAN2.md §6.2 + §7 steps C–E. Swap weights, benchmark regression vs Task 21 baseline, rollback path documented. MANDATORY: read .cursor/skills/ponytail/SKILL.md (Repo 1). Also read docs/PLAN2.md, docs/LOG.md, skills/skills/webapp-testing/SKILL.md (Repo 2). Update docs/LOG.md. Mark Task 28 complete in docs/TASKS2.md.
```

- [ ] **Task 29** — Android HQ capture validation (no app rewrite)

**Deliverables:**
- Same `mobile/` HQ flow (PLAN §8.6) — `MlRepository.segmentImage()` unchanged
- Manual test checklist in LOG: capture → server PNG → save gallery
- Confirm JWT + ML service URL still work with new model
- If quality worse than baseline → rollback per Task 28

**Prompt:**
```
Task 29: End-to-end Android HQ capture test with fine-tuned server model per docs/PLAN2.md §6.3. No API contract changes. MANDATORY: read .cursor/skills/ponytail/SKILL.md (Repo 1). Also read docs/PLAN2.md, docs/LOG.md. Update docs/LOG.md with test results. Mark Task 29 complete in docs/TASKS2.md.
```

---

## Phase 4 — Optional on-device TFLite

> **Skip entire phase** if ML Kit live preview is good enough. Check tasks only if you need better fallback.

- [ ] **Task 29a** — TFLite export (optional)

**Deliverables:**
- `ml-service/training/export_tflite.py` — quantized `.tflite` from checkpoint or SavedModel
- Output: `mobile/assets/models/selfie_segmentation.tflite` (or new name + pubspec update)
- Document input size + normalization in `training/README.md`

**Prompt:**
```
Task 29a (optional): training/export_tflite.py per docs/PLAN2.md §4.2. Skip if not needed. MANDATORY: read .cursor/skills/ponytail/SKILL.md (Repo 1). Also read docs/PLAN2.md, docs/LOG.md. Apply Ponytail YAGNI. Update docs/LOG.md. Mark Task 29a complete or skip note in docs/TASKS2.md.
```

- [ ] **Task 29b** — Mobile TFLite fallback wiring (optional)

**Deliverables:**
- Update `mobile/lib/services/ml_on_device_service.dart` — `segmentTflite()` input/output to match export
- Widget test or manual note: fallback path still works when ML Kit unavailable
- **Do not** replace ML Kit as default unless explicitly decided

**Prompt:**
```
Task 29b (optional): Wire TFLite fallback in mobile/ per docs/PLAN2.md §4.2 + §6.3. MANDATORY: read .cursor/skills/ponytail/SKILL.md (Repo 1). Also read docs/PLAN2.md, docs/LOG.md, flutter-skills/skills/flutter-add-widget-test/SKILL.md (Repo 3), dart-skills/skills/dart-run-static-analysis/SKILL.md (Repo 4). Apply Ponytail YAGNI. Update docs/LOG.md. Mark Task 29b complete or skip in docs/TASKS2.md.
```

---

## Phase 5 — Docs + review

- [ ] **Task 30** — INSTALLATION.md Phase 2 section

**Deliverables:**
- Add **Phase 2 — Custom model training** section to `docs/INSTALLATION.md`:
  - Python 3.11, GPU/Colab, Kaggle download, `prepare_dataset.py`, train, export, deploy, rollback
  - Link to `ml-service/training/README.md` and `DATASETS.md`
- Optional: `docs/MODEL_TRAINING.md` if INSTALLATION gets too long (ponytail: prefer one doc unless split is clearer)

**Prompt:**
```
Task 30: Document Phase 2 training in docs/INSTALLATION.md per docs/PLAN2.md §7 + §11. MANDATORY: read .cursor/skills/ponytail/SKILL.md (Repo 1). Also read docs/PLAN2.md, docs/LOG.md, skills/skills/doc-coauthoring/SKILL.md (Repo 2). Apply Ponytail YAGNI. Update docs/LOG.md. Mark Task 30 complete in docs/TASKS2.md.
```

- [ ] **Task 30b** — ponytail-review training/

**Prompt:**
```
Review ml-service/training/ diff. MANDATORY: read .cursor/skills/ponytail/SKILL.md + .cursor/skills/ponytail-review/SKILL.md (Repo 1). Also read docs/PLAN2.md, docs/LOG.md. Trim bloat from training scripts. Update docs/LOG.md. Mark Task 30b complete in docs/TASKS2.md.
```

- [ ] **Task 31** — Phase 2 sign-off

**Deliverables:**
- All quality gates in PLAN2 §8 met or explicitly waived in LOG
- `docs/LOG.md` Phase 2 summary entry
- `docs/PLAN2.md` prerequisites section checkboxes updated if desired
- No Phase 1 regressions: `npm test`, `pytest`, `flutter test` still pass

**Prompt:**
```
Task 31: Phase 2 sign-off per docs/PLAN2.md §8. Run regression tests, document final model version + metrics vs baseline. MANDATORY: read .cursor/skills/ponytail/SKILL.md (Repo 1). Also read docs/PLAN2.md, docs/LOG.md, skills/skills/webapp-testing/SKILL.md (Repo 2). Update docs/LOG.md. Mark Task 31 complete in docs/TASKS2.md.
```

---

## Skill Reference — Phase 2

| Task | Repo 1 | Repo 2 | Repo 3 Flutter | Repo 4 Dart |
|------|--------|--------|----------------|-------------|
| 21–22, 25–27, 30 | ponytail | doc-coauthoring | — | — |
| 23–24 | ponytail | doc-coauthoring | — | — |
| 26, 28, 31 | ponytail | webapp-testing | — | — |
| 29 | ponytail | — | — | — |
| 29a | ponytail | — | — | — |
| 29b | ponytail | — | widget-test | static-analysis |
| 30b | ponytail + ponytail-review | — | — | — |

---

## Code touch map (quick reference)

| After training | File | Change |
|----------------|------|--------|
| Usually **none** | `inference/engine.py`, `segment.py`, `preprocessing/`, `postprocessing/`, `api/routes.py` | Same contract |
| **Swap weights** | `models/modnet/` | New SavedModel |
| **Config** | `ml-service/.env` | `MODEL_PATH`, optional `MODEL_TYPE` |
| **Rollback** | `models/modnet_pretrained/` | Keep Phase 1 weights |
| **App HQ** | `ml_repository.dart` | No change |
| **App live** | `ml_on_device_service.dart` | Only Task 29b (TFLite) |
| **Backend** | `backend/` | No change |

---

## Progress

| Phase | Done | Delivers |
|-------|------|----------|
| 0 Prerequisites | 0/1 | Baseline + gate |
| 1 Data + scaffold | 0/3 | `training/` + dataset pipeline |
| 2 Fine-tune | 0/3 | train → export → eval |
| 3 Deploy | 0/2 | Server swap + Android HQ test |
| 4 TFLite (optional) | 0/2 | On-device fallback |
| 5 Docs + sign-off | 0/3 | INSTALLATION + review + done |
| **Total** | **0/14** | (+ 2 optional) |

**Next:** Complete [TASKS.md](TASKS.md) first, then **Task 21 — Phase 2 gate**.

---

## Relationship to Phase 1

| Doc | Role |
|-----|------|
| [PLAN.md](PLAN.md) | Phase 1 MVP blueprint (§0–§13) |
| [TASKS.md](TASKS.md) | Phase 1 step prompts (Tasks 0–20b) |
| [PLAN2.md](PLAN2.md) | Phase 2 training blueprint |
| **TASKS2.md** | Phase 2 step prompts (Tasks 21–31) |
| [LOG.md](LOG.md) | Memory for both phases |

*Created: 2026-07-13 — Do not start until TASKS.md is 100% complete.*
