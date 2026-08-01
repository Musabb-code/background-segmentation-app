# Pixel Lift — Product Polish & Accuracy Plan

> **What this file is:** The next-work blueprint after MVP is running on a phone.  
> **Product name (new):** **Pixel Lift**  
> **Does not replace** [PLAN.md](PLAN.md). Agents building MVP still follow PLAN.md §0–§13 only.  
> **Before coding features listed here:** promote the chosen slice into PLAN.md (or explicitly adopt this doc) so it is not blocked by PLAN.md §14.  
> **Related:** [PLAN2.md](PLAN2.md) = custom model training later. This file = product polish, UX modes, branding, and accuracy upgrades that do **not** require training first.

**Icon source (canonical):** [assets/pixel_lift_icon.png](assets/pixel_lift_icon.png)  
**App asset copy:** `mobile/assets/branding/pixel_lift_icon.png`

---

## 0. One-page summary

| Question | Answer |
|----------|--------|
| Does live background removal need the laptop after install? | **No** — ML Kit runs on the phone. Laptop/USB is only for install + local backend during lab testing. |
| What is Pixel Lift? | Rebrand + polish of the current MACKHAN Android app: cleaner UX, stronger edges (hair/body), background modes, finished look. |
| App name | **Pixel Lift** (replace “Real-Time Background Removal” / MACKHAN display strings) |
| Color scheme | **Sky blue** primary (matches icon glow) + optional **light orange** accent |
| App icon | User-provided split before/after icon (landscape → transparent checkerboard + cyan scan) |
| Biggest accuracy truth | Live preview (ML Kit) will never match HQ stills (MODNet). Plan accuracy in **two layers**: live “good enough + sharper edges” and capture “hair-detail / studio quality”. |
| Multi-object truth | ML Kit Selfie Segmentation is **person-centric**. “Multiple things” is a later mode (people vs objects) — not a free upgrade of selfie masks. |

---

## 1. Goals (what “done” means for this plan)

### 1.1 User-facing goals

1. **Start clean** — Open camera → see normal live camera first (no processing). Tap **Start** → background removal begins. Tap **Stop** → back to normal camera; mask/compositing fully cleared (already partially true today).
2. **More accurate subject cutout** — Cleaner hair edges, fewer body halo artifacts, less flicker.
3. **Background studio modes** — After (or while) removing background, user can pick:
   - Fully transparent (true alpha / PNG)
   - Checkerboard preview (editor-style “see transparency”)
   - Solid colors (white, black, and a palette; user-custom color)
   - Built-in picture backgrounds
   - User-picked gallery picture as background
   - Optional fun overlays (emoji / stickers) — **separate from** the matte, not a fake “mask”
4. **Polish / finishing** — Consistent branding, icon, colors, typography, empty states, errors, naming everywhere.
5. **No laptop tether for the live feature** — Real-time remover stays on-device. Backend only for auth / HQ upload when online.

### 1.2 Non-goals (explicit YAGNI)

- Not rewriting the whole app architecture.
- Not building iOS (still PLAN.md §14).
- Not training a custom model in this plan (that is [PLAN2.md](PLAN2.md)).
- Not turning live preview into cinema-grade hair matting on every mid-range phone (physics + model limits).
- Not “detect every object in the room” in v1 of accuracy work — that needs a different model family.

---

## 2. Current state (honest baseline)

| Area | Today | Gap vs your wish |
|------|--------|------------------|
| Live remove | ML Kit Selfie Segmentation stream | Soft/noisy hair edges; person-focused only |
| Start / Stop | Exists on Camera screen | Needs clearer “idle camera → Start → Live → Stop clears” UX + mode tray |
| HQ capture | MODNet via `ml-service` (or on-device fallback) | Best path for hair detail **when server is reachable** |
| Background options | PLAN §8.4.7 mentions checkerboard / solid / blur(post-MVP) | Not fully productized as a polished mode tray |
| Branding | Name “Real-Time Background Removal”, teal theme | Rename Pixel Lift, sky-blue/orange, new icon |
| Laptop | USB only for adb install / local API tunnel | Not required for on-device live ML |

---

## 3. Branding — Pixel Lift

### 3.1 Name map

| Place | Change to |
|-------|-----------|
| Display name (splash, titles) | **Pixel Lift** |
| Android launcher label | Pixel Lift |
| `AppConstants.appName` | `Pixel Lift` |
| Package / applicationId | **Keep** `com.mackhan.mackhan` for now (renaming id = reinstall / Play conflicts). Optional later: `com.pixellift.app` |
| Folder / repo name `MACKHAN` | Keep (code history). Product brand ≠ folder name. |
| Save-to-gallery prefix | `pixel_lift_…` |

### 3.2 Icon

- Source file: `docs/assets/pixel_lift_icon.png` (and `mobile/assets/branding/pixel_lift_icon.png`).
- Generate Android mipmaps (`mdpi` … `xxxhdpi`) from this PNG; set as launcher icon.
- Adaptive icon: keep the rounded-square art; foreground = full icon, background = deep navy matching left sky.

### 3.3 Color scheme (decision locked in this plan)

**Primary direction: sky blue** (matches icon cyan glow). Light orange as **accent only** (CTAs / highlights), not a second competing primary.

| Token | Hex (starting point) | Use |
|-------|----------------------|-----|
| `primary` | `#0EA5E9` (sky) | Buttons, links, Live indicator |
| `primaryDark` | `#0284C7` | Pressed / dark surfaces |
| `accent` | `#FB923C` (light orange) | Secondary CTA, badges |
| `surfaceLight` | `#F0F9FF` | Light mode surfaces |
| `surfaceDark` | `#0B1220` | Dark mode surfaces |
| `success` | `#22C55E` | Live / verified |
| `danger` | `#EF4444` | Errors / stop |

Replace current teal seed (`#0D9488`) in `AppTheme` with this palette. Keep Material 3 `ColorScheme.fromSeed` or explicit scheme — prefer explicit tokens so the icon and UI match.

### 3.4 Branding tasks (checklist)

- [ ] Update `AppConstants.appName`
- [ ] Update Android `android:label` / launcher name
- [ ] Wire launcher icon from provided PNG
- [ ] Update splash title/icon treatment to Pixel Lift
- [ ] Update theme colors (sky + orange accent)
- [ ] Sweep hardcoded strings that still say “Real-Time Background Removal” / MACKHAN in UI
- [ ] Gallery save filename prefix

---

## 4. Camera UX — modes & Start / Stop

### 4.1 Intended flow (product)

```text
Open Camera
   │
   ▼
[IDLE] Normal camera preview only
   │  user taps Start
   ▼
[LIVE] Segmentation ON + chosen Background Mode applied
   │  user changes mode tray (color / picture / transparent / …)
   ▼
Still LIVE, background swaps without restarting camera
   │  user taps Stop
   ▼
[IDLE] Raw camera again; mask cleared; mode tray disabled or dimmed
```

Capture (HQ) can work from IDLE or LIVE; document preferred: **Capture prefers HQ server when online**, else on-device still.

### 4.2 Mode tray (UI)

Bottom or side sheet while LIVE (or always visible but only active when LIVE):

| Mode | What user sees | Export meaning |
|------|----------------|----------------|
| **Transparent** | Checkerboard under subject in preview | PNG with real alpha |
| **Solid color** | Flat fill (white default + palette + custom) | Subject on that color |
| **Built-in photo** | Pack of 6–12 scenic / studio / gradients | Subject composited on asset |
| **My photo** | Pick from gallery | Same |
| **Emoji / stickers** (phase later) | Stickers float behind or around subject | Overlay layer, not a matte |

**Stop behavior (required):**

- Stop ML loop
- Clear last mask
- Hide composited layers
- Keep last selected mode in memory (SharedPreferences) but do not apply until Start again

### 4.3 Controls bar (target)

| Control | Behavior |
|---------|----------|
| Start / Stop | Toggle processing (exists — clarify labels: “Start Lift” / “Stop”) |
| Switch camera | Unchanged |
| Capture | HQ still |
| Modes | Opens mode tray |
| (optional) Flash / resolution | Settings, not clutter on main bar |

---

## 5. Accuracy plan (do not skip the hard truths)

### 5.1 What “more accurate hair / body” actually means

| Layer | Where | What improves edges | Cost |
|-------|--------|---------------------|------|
| **A. Live post-process** | Phone | Threshold, feather, morphological clean, temporal smooth | Low — do first |
| **B. Live model upgrade** | Phone | Better TFLite / MediaPipe-class model if ML Kit ceiling hit | Medium |
| **C. HQ capture path** | `ml-service` MODNet | True hair / fine mattes on stills | Needs online ML service |
| **D. Custom training** | PLAN2 | Domain-specific people / scenes | Later — [PLAN2.md](PLAN2.md) |

**Recommendation order:** A → polish UX → C always available for “best shot” → B only if A is still not enough → D last.

### 5.2 Phase A — Live edge quality (no new model)

Work in `ml_on_device_service.dart` + `segmentation_painter.dart` + camera loop:

1. **Confidence threshold tuning** — separate soft hair band vs solid body.
2. **Feather / anti-alias** on mask edge (small Gaussian or distance falloff).
3. **Temporal smoothing** — blend mask N frames to kill flicker (keeps FPS).
4. **Morphology** — light open/close to remove speckles without eating hair.
5. **Resolution policy** — 720p default; “High quality” setting = less frame skip, slightly lower FPS.
6. **Front vs back** — different thresholds if needed (selfie bias).

**Success metric:** Subjectively cleaner hair line on 3 phones; FPS still ≥ 15 on mid-range; no permanent hang.

### 5.3 Phase C — HQ accuracy (best detail)

1. Ensure `ml-service` MODNet is reachable without USB (deploy online **or** same Wi‑Fi + firewall) — otherwise users only get weak on-device still fallback.
2. Capture UI: show “Studio quality (cloud)” vs “Quick (on device)” clearly.
3. Optional: after capture, allow background mode re-composite on the PNG (color / image) before save.

### 5.4 Phase B — Better live model (only if needed)

- Wire TFLite fallback already reserved in PLAN (`tflite_flutter` + `assets/models/…`).
- Evaluate selfie / portrait matting TFLite that improves hair vs ML Kit.
- Keep ML Kit as default if FPS wins; allow Settings toggle “Accuracy vs Speed”.

### 5.5 Multi-object / “focus many things”

| User meaning | Feasible approach | When |
|--------------|-------------------|------|
| Multiple **people** in frame | Person segmentation / multi-instance models | After Phase A |
| Arbitrary **objects** (desk, pet, product) | Different model (e.g. general segmentation) — **not** Selfie Segmentation | Separate milestone |
| “Focus” as UI (pick who stays) | Tap subject → keep one mask / discard others | After multi-person works |

**Plan stance:** v1 accuracy = **best person matte**. Multi-object is **v2 feature**, documented so we do not fake it with selfie ML.

---

## 6. Background & export details

### 6.1 Preview vs export

| Mode | Live preview | Saved file |
|------|--------------|------------|
| Transparent | Checkerboard | PNG RGBA, alpha 0 background |
| White / colors | Solid fill | PNG or JPEG on solid (JPEG if no alpha needed) |
| Picture | Image fill, cover/crop | Same composite baked in |
| Emoji layer | Drawn above/behind | Flattened into export |

### 6.2 Built-in background pack (v1 suggestion)

Ship ~8–12 compressed JPGs under `mobile/assets/backgrounds/`:

- Solid gradients (sky blue, orange wash, studio gray)
- Soft studio, office blur-like stills, nature (match icon mood)
- One pure white, one pure black as “presets” in color mode too

### 6.3 Performance rules

- Downscale background bitmaps to preview size; full-res only on Capture.
- Do not re-decode gallery image every frame — cache the chosen bg.
- When Stop: release mask buffers; keep bg cache.

---

## 7. Efficiency (FPS / battery)

Already partly in PLAN Settings (resolution, processing quality). This plan adds:

| Lever | Action |
|-------|--------|
| Idle camera | No ML work until Start |
| Frame skip | Adaptive: drop frames if segment time > budget |
| Isolate / compute | Keep heavy decode off UI isolate where already possible |
| Resolution | Default 720p; 480p option for weak devices |
| Stop | Explicitly cancel in-flight segment calls |

**Target:** Mid-range Android: ≥ 15–20 FPS in LIVE Standard; High mode may be 10–15 FPS with sharper edges.

---

## 8. Workstreams & build order

Do in this order (ponytail: polish brand early so demos look finished; accuracy next; fancy stickers last).

### Stream 0 — Gate (docs)

- [x] Decide: promote this file’s first milestone into PLAN.md §8 (or temporary “adopt PIXEL_LIFT_PLAN”)
- [x] Update LOG.md when stream starts
- [x] Keep PLAN2 for training-only work

### Stream 1 — Brand polish (Pixel Lift)

- [x] Name + theme + icon + splash
- [x] Sweep UI copy
- [x] Visual pass: login / home / camera bars match sky-blue + orange accent

### Stream 2 — Camera mode UX

- [x] Idle-first clarity (copy + Start CTA)
- [x] Stop clears mask (verify + harden)
- [x] Mode tray: transparent / colors / built-in / gallery
- [x] Persist last mode in SharedPreferences

### Stream 3 — Live accuracy (Phase A)

- [x] Edge feather + threshold + temporal smooth
- [x] Settings: Standard / High
- [ ] Device test notes in LOG.md

### Stream 4 — Online HQ path (so accuracy can be “real”)

- [ ] Deploy `ml-service` (and backend) where phone can reach without USB
- [ ] Point `API_BASE_URL` / `ML_SERVICE_URL` to hosted URLs
- [x] Capture UX labels Studio vs Quick

### Stream 5 — Optional upgrades

- [ ] TFLite accuracy mode (Phase B) — deferred (YAGNI until Stream 3 verified on device)
- [ ] Emoji / sticker layer — deferred
- [ ] Multi-person selection (v2) — deferred
- [ ] PLAN2 custom training if still not enough — deferred

---

## 9. File / module touch map (expected)

| Area | Likely files |
|------|----------------|
| Branding | `app_constants.dart`, `app_theme.dart`, `AndroidManifest.xml`, `mipmap/*`, splash |
| Modes | `camera_screen.dart`, `camera_provider.dart`, new `background_mode.dart` / small tray widget |
| Accuracy | `ml_on_device_service.dart`, `segmentation_painter.dart` |
| Assets | `assets/branding/`, `assets/backgrounds/` |
| Config | `assets/.env` (hosted URLs when leaving USB lab mode) |

Fewest new files: prefer one `BackgroundMode` enum + tray widget over a new architecture layer.

---

## 10. Acceptance criteria (demo checklist)

### Branding

- [ ] Launcher shows Pixel Lift + new icon
- [ ] Splash / Sign in / Home use sky-blue primary + orange accent consistently

### Camera

- [ ] Open → raw camera (not removing) until Start
- [ ] Start → subject lifted onto selected background
- [ ] Stop → raw camera; no leftover mask ghost
- [ ] Switch Transparent / White / Color / Built-in / Gallery without crash
- [ ] Capture saves sensible PNG (alpha when Transparent)

### Accuracy / efficiency

- [ ] Hair/body edges visibly cleaner than pre-Stream-3 baseline (side-by-side screenshot in LOG)
- [ ] LIVE Standard stays usable FPS on the test phone
- [ ] No USB required for live remove after install

### Honesty checks

- [ ] App never claims “object detection of everything” until Stream 5 multi-object ships
- [ ] HQ “studio” path only advertised when ML URL is reachable

---

## 11. Risks & decisions

| Risk | Mitigation |
|------|------------|
| User expects live = MODNet hair quality | UI: “Live” vs “Studio capture” labels |
| Hosted ML cost / cold start | Cache; show spinner; on-device fallback |
| Gallery bg memory | Decode once, downscale, dispose on mode change |
| Icon glow vs flat Material | Use sky primary; don’t paste neon everywhere in forms |
| Renaming applicationId | Defer; brand name is enough for uni demo |

**Open decision (you choose before Stream 1):**  
Accent orange **on** (recommended, matches “or light orange”) vs sky-only. Default in this plan: **sky primary + light orange accent**.

---

## 12. Suggested first implementation slice (next coding session)

Smallest high-value slice:

1. **Stream 1** — Pixel Lift name, theme, launcher icon  
2. **Stream 2** — Mode tray: Transparent + White + 4 colors + 4 built-in images  
3. **Stream 3** — Feather + temporal smooth on live mask  

Then deploy backend/ML online so Capture can show true accuracy without the laptop.

---

## 13. How agents must use this file

1. Read [PLAN.md](PLAN.md) — if a task is not in §0–§13 and not promoted from here, **stop**.  
2. Read this file for Pixel Lift polish / modes / accuracy sequencing.  
3. Read [PLAN2.md](PLAN2.md) only for training.  
4. Read Ponytail every task.  
5. Update [LOG.md](LOG.md) after each stream slice.  
6. Prefer deletion and reuse (`camera_provider` Start/Stop already exists) over new frameworks.

---

## 14. Traceability to your request

| You asked | Where in this plan |
|-----------|-------------------|
| More accurate hair / body | §5 Phase A/C/B |
| Multiple things / focus | §5.5 (v2 honesty) |
| Transparent / white / colors | §4.2, §6 |
| Picture backgrounds + built-in | §4.2, §6.2 |
| Normal camera first; Start/Stop clears | §4.1, §4.2 Stop behavior |
| Modes / emojis | §4.2 (emoji = later) |
| Polish / finishing | §3, Stream 1 |
| Rename Pixel Lift | §3.1 |
| Color sky blue / light orange | §3.3 |
| App icon image | §3.2 + `docs/assets/pixel_lift_icon.png` |
| No laptop for live remove | §0 + Stream 4 for auth/HQ only |

---

*End of Pixel Lift plan.*
