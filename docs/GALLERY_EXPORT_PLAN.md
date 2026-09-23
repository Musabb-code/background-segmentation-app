# Pixel Lift — Gallery, Export, Crop, E‑commerce & Batch Plan

> **Features:** 1 Gallery remove BG · 2 Export formats · 3 Auto-crop · 4 White-bg preset · 8 Batch mode  
> **Status:** G0–G7 done — run G8 APK QA on device  
> **Does not replace** [PLAN.md](PLAN.md). Follows same pattern as [PIXEL_LIFT_PLAN.md](PIXEL_LIFT_PLAN.md) → §8.4.10 adoption.  
> **APK testing:** [APK_PHONE_RUNBOOK.md](APK_PHONE_RUNBOOK.md) (proven arm64 debug path)

---

## 0. PLAN.md promotion (mandatory gate — do this first)

Add **§8.4.11 Gallery & export studio** to `docs/PLAN.md` (after §8.4.10):

```markdown
#### 8.4.11 Gallery & export studio (remove.bg-style stills)

- **Gallery import:** Pick one or more photos from device gallery → segment subject → preview → save.
- **Export formats:** PNG (transparent alpha), JPG (white background, no alpha), optional WebP (transparent).
- **Auto-crop:** Trim empty transparent margins after segmentation (toggle in Settings, default ON for gallery).
- **E-commerce preset:** One-tap “White background JPG” from Home or editor (segment + white composite + JPG save).
- **Batch mode:** Multi-select gallery (max 20 images) → sequential process → save all to gallery with progress UI.
- **ML path:** Same as §8.6 — `MlRepository.segmentImage` (Studio) with `MlOnDeviceService.segmentStillToPng` fallback.
- **No new backend routes.** No remove.bg API. No new dependencies unless `image` package already covers encode (it does).
- **Out of scope:** product/object model (person-only ML Kit), video batch, cloud batch API.
```

Update `docs/PLAN.md` §3 monorepo if new files listed:

| New file | Purpose |
|----------|---------|
| `mobile/lib/core/utils/crop_utils.dart` | Alpha bounding box + crop |
| `mobile/lib/core/utils/export_utils.dart` | PNG/JPG/WebP encode from RGBA |
| `mobile/lib/features/editor/presentation/editor_screen.dart` | Single + batch gallery UI |
| `mobile/lib/providers/editor_provider.dart` | Gallery segment queue state |
| `mobile/test/crop_utils_test.dart` | Crop bounds unit test |
| `mobile/test/export_utils_test.dart` | Encode round-trip test |

**Do not build** until §8.4.11 is merged into PLAN.md and `docs/LOG.md` notes adoption.

---

## 1. Feature definitions (what “done” means)

### Feature 1 — Gallery → remove background

| Item | Spec |
|------|------|
| Entry | Home: **“Edit from Gallery”** button → `/editor` |
| Flow | Pick image → loading → segment (ML server 30s, else on-device) → full-screen preview (reuse `_HqPreviewDialog` pattern) |
| Permissions | `READ_MEDIA_IMAGES` (already in manifest); `Gal.requestAccess()` before save |
| UX | Show “Studio” vs “Quick (on device)” snackbar (same as camera capture) |

### Feature 2 — Export format choice

| Format | When | Implementation |
|--------|------|----------------|
| **PNG** | Transparent cutout (default) | Existing `img.encodePng` / raw bytes from ML |
| **JPG** | White background, smaller file | Composite onto `#FFFFFF` then `img.encodeJpg(quality: 92)` |
| **WebP** | Optional transparent | `img.encodeWebP` if available in `image` ^4.x |

Preview dialog: segmented control or dropdown **PNG | JPG (white) | WebP** before Save.

### Feature 3 — Auto-crop to subject

| Item | Spec |
|------|------|
| Algorithm | Scan RGBA alpha > 10 → min/max x/y → pad 8px → crop |
| Where | Applied **after** segment, **before** export encode |
| Toggle | Settings → “Auto-crop after remove” (default **ON** for gallery; camera HQ optional same toggle) |
| Storage | `SharedPreferences` key `auto_crop` via `SettingsService` |

### Feature 4 — E-commerce white background preset

| Item | Spec |
|------|------|
| Entry | Home: **“Product white BG”** (secondary CTA, orange accent) |
| Flow | Pick 1 photo → segment → force white JPG → auto-crop ON → save dialog (Save / Discard) |
| Output | JPG filename `pixel_lift_product_{timestamp}.jpg` |
| Honesty | UI subtitle: “Best for portraits — not products yet” (ML Kit = person only) |

### Feature 8 — Batch mode

| Item | Spec |
|------|------|
| Entry | Editor screen toggle **“Batch mode”** or Home → **“Batch edit”** |
| Select | `ImagePicker.pickMultiImage()` max **20** images |
| Process | Sequential queue on device isolate or async loop; show `3 / 12` progress |
| ML | **On-device only for batch** (avoid 20× server load); optional setting “Studio quality batch” OFF by default |
| Save | Each result → `Gal.putImageBytes` with unique name; summary “Saved 12 images” |
| Cancel | Stop button clears queue; partial saves kept |

---

## 2. Architecture (do not break existing code)

```
HomeScreen
  ├─ Open Pixel Lift      → /camera     (UNCHANGED)
  ├─ Edit from Gallery    → /editor     (NEW)
  ├─ Product white BG     → /editor?preset=product_white  (NEW)
  └─ Batch edit           → /editor?batch=1               (NEW)

/editor
  EditorScreen + editorProvider
    ├─ pickImage / pickMultiImage
    ├─ segmentGalleryFile()  → reuses mlRepository + mlOnDevice fallback
    ├─ applyAutoCrop()       → crop_utils
    ├─ encodeExport()        → export_utils
    └─ preview + save        → shared widget (extract from camera_screen)

/camera
  UNCHANGED except:
    - optional: HQ preview uses shared ExportPreviewDialog
    - optional: auto-crop respects Settings toggle on capture save
```

### Reuse map (ponytail — no duplicate logic)

| Existing | Reuse for |
|----------|-----------|
| `MlRepository.segmentImage` | Gallery + batch (when studio enabled) |
| `MlOnDeviceService.segmentStillToPng` + `composite` | Fallback + batch default |
| `_HqPreviewDialog` in `camera_screen.dart` | Extract → `widgets/export_preview_dialog.dart` |
| `BackgroundMode.solid(white)` | JPG white composite color |
| `Gal.putImageBytes` | All saves |
| `SettingsService` | auto_crop + default export format |

### Must NOT change

| File | Rule |
|------|------|
| `router.dart` | Keep `ref.read` + `refreshListenable`; add routes only |
| `auth_provider.dart` | No changes unless editor needs auth guard (already global) |
| `api_client.dart` | JWT refresh logic untouched |
| `camera_provider.dart` | Live stream logic untouched; optional shared segment helper only |
| Firestore rules | No change |
| Backend / ML API | No new endpoints |

---

## 3. Build phases (order matters)

| Phase | Features | Est. files touched | Risk |
|-------|----------|-------------------|------|
| **0** | PLAN §8.4.11 + LOG | 2 docs | None |
| **1** | Shared utils (crop + export) + unit tests | 4 new, 0 breaking | Low |
| **2** | Extract preview dialog + `editor_provider` | 3 new, 1 refactor camera | Medium — test camera capture after |
| **3** | Feature 1 — single gallery editor + route + Home button | 3 files | Low |
| **4** | Feature 2 — export format in preview + Settings default | 3 files | Low |
| **5** | Feature 3 — auto-crop in pipeline + Settings toggle | 4 files | Low |
| **6** | Feature 4 — product white preset entry + flow | 2 files | Low |
| **7** | Feature 8 — batch queue UI + progress | 2 files | Medium — memory: dispose images |
| **8** | Widget tests + APK phone verify | tests + runbook | — |

**Total new Dart files:** ~6  
**Refactors:** 1 (preview dialog extract)  
**New dependencies:** 0 (`image`, `image_picker`, `gal` already in pubspec)

---

## 4. APK build & test after each phase

Use **only** the proven path from [APK_PHONE_RUNBOOK.md](APK_PHONE_RUNBOOK.md):

### 4.1 Environment (every new PowerShell window)

```powershell
$env:JAVA_HOME = (Get-ChildItem "C:\Program Files\Microsoft" -Directory -Filter "jdk-17*" | Select-Object -First 1).FullName
$env:ANDROID_HOME = "D:\Android\Sdk"
$env:Path = "$env:JAVA_HOME\bin;D:\flutter\bin;D:\Android\Sdk\platform-tools;D:\Android\Sdk\cmdline-tools\latest\bin;$env:Path"
$env:GIT_CONFIG_COUNT = "1"
$env:GIT_CONFIG_KEY_0 = "safe.directory"
$env:GIT_CONFIG_VALUE_0 = "*"
```

Low RAM: also set `$env:GRADLE_USER_HOME = "D:\mackhan-cache\gradle"` and `$env:PUB_CACHE = "D:\mackhan-cache\pub-cache"`.

### 4.2 Build APK (after code changes)

```powershell
cd D:\MACKHAN\mobile
flutter pub get
flutter analyze
flutter test
flutter build apk --debug --target-platform android-arm64
```

If **Java heap space**:

```powershell
Get-Process java -ErrorAction SilentlyContinue | ForEach-Object { Stop-Process -Id $_.Id -Force }
flutter build apk --debug --target-platform android-arm64
```

### 4.3 Install on phone

```powershell
adb devices
adb install -r "build\app\outputs\flutter-apk\app-debug.apk"
adb reverse tcp:3000 tcp:3000
adb reverse tcp:8000 tcp:8000
adb shell am start -n com.mackhan.mackhan/.MainActivity
```

Login: `pixel.lift.demo@gmail.com` / `Lift@12345` (backend running on PC).

### 4.4 Feature test checklist (Phase 8 / after all features)

| # | Test | Pass criteria |
|---|------|---------------|
| 1 | Camera still works | Start Lift → live cutout → Capture → Save PNG |
| 2 | Gallery single | Home → Edit from Gallery → pick → preview → Save PNG |
| 3 | Export JPG | Preview → JPG white → Save → file opens, white bg |
| 4 | Auto-crop | Settings ON → gallery save → no huge transparent margins |
| 5 | Product preset | Home → Product white BG → pick → JPG saved |
| 6 | Batch | Pick 5 photos → progress → 5 files in gallery |
| 7 | Auth unchanged | Logout → login still works |
| 8 | Offline batch | Airplane mode → batch uses on-device only |

---

## 5. Copy-paste agent prompts (use one per Cursor chat / phase)

Each prompt includes mandatory MACKHAN workflow. Run **in order**.

---

### PROMPT 0 — Adopt plan into PLAN.md (no product code yet)

```
Read docs/GALLERY_EXPORT_PLAN.md §0 fully.
Read docs/PLAN.md, docs/LOG.md, .cursor/skills/ponytail/SKILL.md.

Task: Promote Gallery & export studio into docs/PLAN.md as new §8.4.11 (copy spec from GALLERY_EXPORT_PLAN.md §0 and §1 summaries). Update §3 monorepo file list with new mobile files. Add one row to docs/TASKS.md as optional Phase 6 tasks G0–G7 (or append to end). Update docs/LOG.md with adoption entry.

Do NOT write Flutter code yet. Apply Ponytail YAGNI. Stay inside PLAN boundary.
```

---

### PROMPT 1 — Shared utils: crop + export (Phase 1)

```
Read docs/GALLERY_EXPORT_PLAN.md §2 architecture and §1 Features 2–3.
Read docs/PLAN.md §8.4.11 (must exist after Prompt 0).
Read .cursor/skills/ponytail/SKILL.md (mandatory).
Read mobile/lib/core/services/ml_on_device_service.dart (composite output format).

Task: Create minimal shared utilities:

1. mobile/lib/core/utils/crop_utils.dart
   - cropToAlphaBounds(img.Image rgba, {int alphaThreshold = 10, int padding = 8}) → img.Image
   - alphaBounds(img.Image rgba, ...) → Rect or record with left/top/right/bottom
   - Pure Dart, uses package:image only

2. mobile/lib/core/utils/export_utils.dart
   - enum ExportFormat { png, jpgWhite, webp }
   - encodeExport(img.Image rgba, ExportFormat format) → Uint8List
   - jpgWhite: flatten onto white background first (reuse composite logic pattern from ml_on_device_service)
   - fileExtension(ExportFormat) → String

3. mobile/test/crop_utils_test.dart — synthetic 100x100 image with 20x20 opaque center → cropped size ~36x36 with padding 8
4. mobile/test/export_utils_test.dart — encode PNG and JPG return non-empty; JPG has no alpha channel in decoded result

Do NOT touch camera_screen.dart or router yet.
Run: cd mobile && flutter test test/crop_utils_test.dart test/export_utils_test.dart
Update docs/LOG.md. Apply Ponytail YAGNI before done.
```

---

### PROMPT 2 — Extract preview dialog + editor provider skeleton (Phase 2)

```
Read docs/GALLERY_EXPORT_PLAN.md §2 reuse map.
Read mobile/lib/features/camera/presentation/camera_screen.dart (_HqPreviewDialog, _save, Gal.putImageBytes).
Read .cursor/skills/ponytail/SKILL.md.

Task:
1. Extract _HqPreviewDialog to mobile/lib/widgets/export_preview_dialog.dart
   - Accept Uint8List imageBytes (PNG RGBA for now)
   - Save / Discard buttons
   - Keep pixel_lift_ timestamp naming

2. Update camera_screen.dart to use ExportPreviewDialog — behavior identical to before (camera HQ capture must still work)

3. Create mobile/lib/providers/editor_provider.dart
   - EditorState: idle | processing | preview | error
   - segmentFile(File file) async → calls mlRepositoryProvider.segmentImage, fallback mlOnDeviceProvider.segmentStillToPng (same as camera_provider.captureHq logic but for arbitrary File)
   - Returns {bytes, onDevice}

4. flutter analyze + flutter test (existing tests must pass)

Do NOT add /editor route yet.
Update docs/LOG.md.
```

---

### PROMPT 3 — Feature 1: Gallery editor screen + Home entry (Phase 3)

```
Read docs/GALLERY_EXPORT_PLAN.md Feature 1.
Read mobile/lib/router.dart (do NOT use ref.watch in routerProvider).
Read mobile/lib/features/home/presentation/home_screen.dart.
Read mobile/lib/providers/editor_provider.dart.
Read .cursor/skills/ponytail/SKILL.md + flutter-add-widget-test if needed.

Task:
1. Create mobile/lib/features/editor/presentation/editor_screen.dart
   - On open: ImagePicker.pickImage(source: gallery)
   - If null → pop back
   - Show processing dialog → editorProvider.segmentFile → ExportPreviewDialog
   - AppBar title "Edit photo"

2. Add route /editor in router.dart (auth guarded like /camera)

3. HomeScreen: add OutlinedButton "Edit from Gallery" → context.push('/editor')

4. Optional widget test: editor shows picker (mock ImagePicker if too heavy — skip if YAGNI)

Verify camera still works manually. flutter analyze.
Update docs/LOG.md.
```

---

### PROMPT 4 — Feature 2: Export format picker (Phase 4)

```Read docs/GALLERY_EXPORT_PLAN.md Feature 2.
Read mobile/lib/widgets/export_preview_dialog.dart and export_utils.dart.
Read mobile/lib/core/services/settings_service.dart.
Read .cursor/skills/ponytail/SKILL.md.

Task:
1. Add ExportFormat default to SettingsService (key export_format, default png)

2. Settings screen: dropdown PNG / JPG (white) / WebP (optional hide if encode fails on device)

3. Upgrade ExportPreviewDialog:
   - SegmentedButton or Dropdown for format (initial value from settings)
   - On Save: decode png bytes to img.Image → encodeExport(selectedFormat) → Gal.putImageBytes with correct extension in name (.png / .jpg / .webp)

4. Wire same dialog from editor AND camera HQ capture (both get format picker)

5. test/export_utils_test.dart still passes; add test for jpgWhite non-transparent

Update docs/LOG.md.

```

---

### PROMPT 5 — Feature 3: Auto-crop (Phase 5)

```
Read docs/GALLERY_EXPORT_PLAN.md Feature 3.
Read crop_utils.dart, editor_provider.dart, export_preview_dialog.dart.
Read .cursor/skills/ponytail/SKILL.md.

Task:
1. SettingsService: auto_crop bool default true, getter/setter

2. Settings screen: Switch "Auto-crop after remove"

3. In editor_provider.segmentFile pipeline AFTER segment bytes received:
   - if settings.autoCrop: decode PNG → cropToAlphaBounds → re-encode PNG before preview

4. Same hook in camera_provider.captureHq before returning HqCaptureResult (respect setting)

5. Unit test already in crop_utils_test.dart — run flutter test

Update docs/LOG.md.
```

---

### PROMPT 6 — Feature 4: E-commerce white preset (Phase 6)

```
Read docs/GALLERY_EXPORT_PLAN.md Feature 4.
Read home_screen.dart, editor_screen.dart, export_utils.dart.
Read .cursor/skills/ponytail/SKILL.md.

Task:
1. HomeScreen: FilledButton.tonal or accent "Product white BG"
   - Subtitle text: "Portrait · saves JPG on white"
   - onPressed → context.push('/editor?preset=product_white')

2. EditorScreen: read query preset=product_white
   - After segment + auto-crop: skip format picker OR open dialog with JPG pre-selected and label "White background"
   - Default save as JPG white, filename pixel_lift_product_{ts}.jpg

3. Do not claim product detection — person-only ML unchanged

flutter analyze. Update docs/LOG.md.
```

---

### PROMPT 7 — Feature 8: Batch mode (Phase 7)

```
Read docs/GALLERY_EXPORT_PLAN.md Feature 8.
Read editor_provider.dart, export_utils.dart, crop_utils.dart.
Read .cursor/skills/ponytail/SKILL.md.

Task:
1. EditorScreen: if route query batch=1 OR toggle "Batch" on editor entry from Home "Batch edit" button

2. Use ImagePicker.pickMultiImage(limit: 20)

3. editor_provider: processBatch(List<XFile> files, {ExportFormat format, bool onDeviceOnly: true})
   - Sequential for loop, emit progress (index, total, currentFileName)
   - Each: segmentFile (onDeviceOnly skips ML server) → autoCrop if enabled → encodeExport → Gal.putImageBytes
   - Cancel via flag; dispose img.Image refs after each

4. UI: LinearProgressIndicator + "Processing 3 of 12" + Cancel button

5. Home: TextButton "Batch edit (up to 20)" → /editor?batch=1

6. ponytail: cap at 20 images; onDeviceOnly default true (document in UI subtitle)

flutter test. Update docs/LOG.md.
```

---

### PROMPT 8 — Final QA + APK + docs (Phase 8)

```Read docs/GALLERY_EXPORT_PLAN.md §4 APK steps and §4.4 checklist.
Read docs/APK_PHONE_RUNBOOK.md §3–§5.
Read .cursor/skills/ponytail/SKILL.md + ponytail-review/SKILL.md.

Task:
1. Run cd mobile && flutter analyze && flutter test — fix any failures

2. Delete or fix stale mobile/test/widget_test.dart (counter/MyApp template) if it fails

3. Execute APK build per runbook:
   flutter build apk --debug --target-platform android-arm64

4. Document results in docs/LOG.md — checklist §4.4 which items pass on device

5. ponytail-review: trim any duplication introduced across editor vs camera

6. Update docs/API.md only if nothing changed (no backend changes expected)


Do not add new features. Report APK path and test checklist status.
```

---

## 6. Risk register

| Risk | Mitigation |
|------|------------|
| Camera regression after preview extract | Prompt 2 requires identical camera behavior; retest capture in Prompt 8 |
| Router splash hang | Never `ref.watch(authProvider)` in routerProvider |
| Batch OOM on 4GB RAM phone | Sequential processing; dispose each image; cap 20 |
| ML server overload in batch | Default on-device only for batch |
| JPG from transparent PNG halos | White flatten in export_utils before encodeJpg |
| Gallery picker on Android 13+ | READ_MEDIA_IMAGES already in manifest |
| PLAN violation | Prompt 0 must land before Prompt 1 |

---

## 7. Optional later (not in this plan)

- Product/object segmentation (needs new model — PLAN2)
- Server-side batch API
- Share sheet export
- Undo brush / manual mask edit

---

## 8. Quick reference — which prompt when

| You want | Run prompt |
|----------|------------|
| Legal approval in PLAN | **0** |
| Crop + export helpers | **1** |
| Shared preview + provider | **2** |
| Gallery pick one photo | **3** |
| PNG/JPG/WebP choice | **4** |
| Trim empty edges | **5** |
| One-tap white JPG | **6** |
| Multi-photo queue | **7** |
| APK on phone + QA | **8** |

**After each prompt:** build APK (§4.2–4.3) and smoke-test camera + the feature you just added.
