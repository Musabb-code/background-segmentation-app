# MACKHAN Development Log

> **This file is the project memory and history.**  
> Agents must **read it before every task** and **update it after every task**.  
> **MANDATORY boundary:** [PLAN.md](PLAN.md) — nothing outside §0–§13  
> **Tasks:** [TASKS.md](TASKS.md) · **Agent guide:** [agent/cloude/CLAUDE.md](../agent/cloude/CLAUDE.md) · **Hub:** [agent/CLOUDE.md](../agent/CLOUDE.md)

---

## What This File Is

| Question | Answer |
|----------|--------|
| Is LOG.md our memory? | **Yes** — it remembers what was done, what was decided, and what skills were used. |
| Is LOG.md our history? | **Yes** — every step is logged chronologically with date, action, outcome. |
| Is LOG.md part of this project? | **Yes** — it lives in `docs/LOG.md` and is required for MACKHAN development. |
| Is Ponytail mandatory? | **Yes — every task, no exceptions.** Setup, docs, code, tests, reviews — always read `ponytail/SKILL.md` |
| Are all 4 repos mandatory? | **Repo 1 Ponytail: always.** Repo 2 Anthropic: per task. Repo 3–4 Flutter/Dart: Tasks 12–17 only |
| **Repos integrated** | Repo 1–4 at `.cursor/skills/` (26 skills total) |
| Can we go outside PLAN.md? | **No** — §14 and anything not in §0–§13 is forbidden |
| What is PLAN.md? | The **only blueprint** — what to build. Must be read every task. |
| What is LOG.md? | The **memory** — what happened and what is next. Must be read + updated every task. |

---

## Mandatory Agent Workflow (Every Task)

```
1. READ  docs/PLAN.md     → find section + todo; NEVER go outside §0–§13
2. READ  docs/TASKS.md    → pick next unchecked task
3. READ  docs/LOG.md      → check history, current step, next action
4. READ  ponytail SKILL.md → .cursor/skills/ponytail/SKILL.md (MANDATORY — every task)
5. READ  anthropic SKILL.md → agent/skills/skills/{name}/SKILL.md (Repo 2 — per task)
6. READ  flutter SKILL.md   → agent/flutter-skills/… (Repo 3 — Tasks 12–17)
7. READ  dart SKILL.md      → agent/dart-skills/… (Repo 4 — Tasks 12–17)
8. CODE  exactly what PLAN.md specifies
9. APPLY Ponytail YAGNI   → can this diff be shorter? (mandatory before done)
10. UPDATE docs/LOG.md + docs/TASKS.md
```

Full details: [agent/cloude/CLAUDE.md](../agent/cloude/CLAUDE.md)

---

## Current Status

| Field | Value |
|-------|-------|
| **Project phase** | Phase 1 complete + Phase 6 Gallery studio (§8.4.11) complete |
| **Active step** | Task G8 done — APK built; §4.4 device QA pending (no phone connected) |
| **Last updated** | 2026-09-23 |
| **Repos integrated** | Repo 1–4 at `.cursor/skills/` (26 skills total) |

---

## Next Plan (from PLAN.md)

| Priority | PLAN.md todo | Action | Read these SKILL.md first |
|----------|--------------|--------|---------------------------|
| 1 | §11.2 / run | Test app screens, camera permission, and live ML Kit segmentation on phone | ponytail |
| 2 | ML HQ | Optional later: Python/Node only if HQ capture / auth API needed | ponytail |
| Optional | PLAN2 | Tasks 21–31 custom model training | ponytail + PLAN2 |

**Build sequence** (PLAN.md §12): Foundation → Backend → ML → Flutter → Tests/Docs ✅
---

## Log Format

Each entry records:

| Field | Meaning |
|-------|---------|
| **Step** | Sequential number |
| **Date** | When the step was completed |
| **Action** | What was done |
| **PLAN.md todo** | Which todo item (if any) |
| **Skills read** | Which SKILL.md files were read before coding |
| **Files touched** | Paths created or modified |
| **Outcome** | Result / notes |
| **Next** | Recommended follow-up |

---

## Step 1 — Project plan established

| | |
|---|---|
| **Date** | 2026-07-13 (prior session) |
| **Action** | Created full implementation plan for Real-Time Background Removal monorepo |
| **PLAN.md todo** | — (plan itself) |
| **Skills read** | — |
| **Files touched** | `docs/PLAN.md` |
| **Outcome** | Locked stack: Flutter + Express + FastAPI + Firebase. 24 todo items, architecture diagrams, API specs, security checklist. |
| **Next** | Integrate agent tooling (Steps 2–3) |

---

## Step 2 — Anthropic Skills repo integrated

| | |
|---|---|
| **Date** | 2026-07-13 |
| **Action** | Integrated [anthropics/skills](https://github.com/anthropics/skills) (Repo 2) |
| **PLAN.md todo** | — |
| **Skills read** | skill-creator, doc-coauthoring (reference) |
| **Files touched** | `skills/` (17 SKILL.md files), `cloude/CLAUDE.md`, `CLOUDE.md` |
| **Outcome** | Anthropic skills vendored; skill-to-phase mapping documented |
| **Next** | Integrate Ponytail (Step 3) |

### Step 2.1 — git clone failed → curl fallback

Downloaded all 17 `SKILL.md` files individually via curl (git not in PATH).

---

## Step 3 — Ponytail integrated (Repo 1)

| | |
|---|---|
| **Date** | 2026-07-13 |
| **Action** | Cloned [DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail) v4.8.4 |
| **PLAN.md todo** | — |
| **Skills read** | ponytail/SKILL.md |
| **Files touched** | `ponytail/`, `.cursor/rules/ponytail.mdc`, `.cursor/rules/mackhan.mdc`, `.cursor/skills/ponytail-*` (×6), `AGENTS.md` |
| **Outcome** | Ponytail always-on; minimum code on every change |
| **Next** | Document mandatory workflow (Step 4) |

---

## Step 4 — Mandatory workflow documented

| | |
|---|---|
| **Date** | 2026-07-13 |
| **Action** | Updated CLAUDE.md + LOG.md with mandatory read-before-code workflow |
| **PLAN.md todo** | — |
| **Skills read** | — |
| **Files touched** | `cloude/CLAUDE.md`, `docs/LOG.md`, `AGENTS.md` |
| **Outcome** | Both repos mandatory; PLAN.md + LOG.md read/update rules defined |
| **Next** | Create task file (Step 4b) |

---

## Step 4c — PLAN.md set as mandatory boundary

| | |
|---|---|
| **Date** | 2026-07-13 |
| **Action** | Added PLAN.md §0 (authority, file purposes, allowed skills, workflow). Updated all docs to forbid building outside plan. |
| **PLAN.md todo** | — |
| **Skills read** | — |
| **Files touched** | `docs/PLAN.md`, `docs/TASKS.md`, `docs/LOG.md`, `CLOUDE.md`, `cloude/CLAUDE.md`, `AGENTS.md`, `.cursor/rules/mackhan.mdc` |
| **Outcome** | PLAN.md is the only blueprint; §0.3 allowlist for skills; §14 expanded with forbidden items |
| **Next** | Task 0 — copy Anthropic skills |

---

## Step 4d — Task 0: Anthropic skills copied to Cursor

| | |
|---|---|
| **Date** | 2026-07-13 |
| **Action** | Copied PLAN §0.3 allowed skills to `.cursor/skills/` |
| **PLAN.md todo** | Setup (§0.3) |
| **Skills read** | ponytail, skill-creator |
| **Files touched** | `.cursor/skills/frontend-design/SKILL.md`, `.cursor/skills/doc-coauthoring/SKILL.md`, `.cursor/skills/webapp-testing/SKILL.md`, `.cursor/skills/skill-creator/SKILL.md` |
| **Outcome** | **Success** — 4 Anthropic skills active in Cursor; ponytail skills (×6) already present; theme-factory remains in `skills/` until Task 14 |
| **Next** | Task 0b — Dart skills |

---

## Step 4f — Task 0b: Dart skills repo integrated (Repo 4)

| | |
|---|---|
| **Date** | 2026-07-13 |
| **Action** | Cloned [dart-lang/skills](https://github.com/dart-lang/skills) to `dart-skills/`; copied 8 PLAN §0.3 skills to `.cursor/skills/` |
| **PLAN.md todo** | Setup §0.3 |
| **Skills read** | ponytail |
| **Files touched** | `dart-skills/`, `.cursor/skills/dart-*` (×8), `docs/PLAN.md`, `docs/TASKS.md`, `docs/LOG.md` |
| **Dart skills copied** | dart-run-static-analysis, dart-use-primary-constructors, dart-use-pattern-matching, dart-add-unit-test, dart-generate-test-mocks, dart-collect-coverage, dart-fix-runtime-errors, dart-resolve-package-conflicts |
| **Outcome** | **Success** — 4-repo workflow complete |
| **Next** | **Task 1 — Monorepo scaffold** |

---

## Step 4g — Ponytail mandatory on every task (doc enforcement)

| | |
|---|---|
| **Date** | 2026-07-13 |
| **Action** | Enforced Ponytail (Repo 1) on **every task — no exceptions**. Removed "Repo 3–4 N/A" wording that implied optional repos. All TASKS.md prompts now say MANDATORY ponytail + Apply Ponytail YAGNI before done. Review tasks (8b, 11b, 16b, 20b) require ponytail + ponytail-review/audit. |
| **PLAN.md todo** | §0.3, §0.4 |
| **Skills read** | ponytail |
| **Files touched** | `docs/TASKS.md`, `docs/PLAN.md`, `docs/LOG.md`, `.cursor/rules/mackhan.mdc` |
| **Outcome** | **Success** — no task skips Ponytail |
| **Next** | **Task 1 — Monorepo scaffold** |

---

## Step 4e — Task 0a: Flutter skills repo integrated (Repo 3)

| | |
|---|---|
| **Date** | 2026-07-13 |
| **Action** | Cloned [flutter/skills](https://github.com/flutter/skills) to `flutter-skills/`; copied 8 PLAN §0.3 skills to `.cursor/skills/` | |
| **PLAN.md todo** | Setup §0.3 |
| **Skills read** | ponytail, skill-creator |
| **Files touched** | `flutter-skills/` (full repo), `.cursor/skills/flutter-*` (×8), `docs/PLAN.md`, `docs/TASKS.md`, `docs/LOG.md` |
| **Flutter skills copied** | flutter-setup-declarative-routing, flutter-apply-architecture-best-practices, flutter-implement-json-serialization, flutter-use-http-package, flutter-add-widget-test, flutter-add-integration-test, flutter-fix-layout-issues, flutter-build-responsive-layout |
| **Outcome** | **Success** — 3-repo workflow active; TASKS.md updated with Repo 3 on every step |
| **Next** | **Task 1 — Monorepo scaffold** |

---

## Step 5 — Task 1: Monorepo scaffold (PLAN todo #1)

| | |
|---|---|
| **Date** | 2026-07-13 |
| **Action** | Created monorepo root: `README.md`, `.gitignore`, `docker-compose.yml`, `.env.example`, `firebase/` rules + indexes |
| **PLAN.md todo** | #1 ✅ |
| **Skills read** | ponytail, doc-coauthoring |
| **Files created** | `README.md`, `.gitignore`, `docker-compose.yml`, `.env.example`, `firebase/firestore.rules`, `firebase/firestore.indexes.json`, `firebase/storage.rules` |
| **Outcome** | **Success** — root scaffold matches PLAN §3, §4.4, §5.4 |
| **Next** | **Task 2 — Firebase setup documentation** |

---

## Step 6 — Task 2: Firebase setup guide (PLAN todo #2)

| | |
|---|---|
| **Date** | 2026-07-13 |
| **Action** | Wrote Firebase setup guide in `docs/INSTALLATION.md` (§5.1–5.4: console, collections, indexes, rules, service account, storage path) |
| **PLAN.md todo** | #2 ✅ |
| **Skills read** | ponytail, doc-coauthoring |
| **Files created/updated** | `docs/INSTALLATION.md`, `README.md` (link) |
| **Outcome** | **Success** — operational Firebase guide; remaining INSTALLATION.md sections deferred to Task 19 |
| **Next** | **Task 3 — Backend scaffold** |

---

## Step 7 — Task 3: Backend scaffold (PLAN todo #3)

| | |
|---|---|
| **Date** | 2026-07-13 |
| **Action** | Scaffolded `backend/`: Express server, Joi env validation, firebase-admin init, Winston logger, error handler, `/api/health` |
| **PLAN.md todo** | #3 ✅ |
| **Skills read** | ponytail, doc-coauthoring |
| **Files created** | `backend/server.js`, `backend/package.json`, `backend/.env.example`, `backend/jest.config.js`, `backend/src/config/env.js`, `backend/src/config/firebase.js`, `backend/src/utils/logger.js`, `backend/src/utils/ApiError.js`, `backend/src/utils/asyncHandler.js`, `backend/src/middleware/errorHandler.js`, `backend/src/routes/index.js` |
| **Outcome** | **Success** — scaffold matches PLAN §6; routes/repos deferred to Tasks 4–7 |
| **Note** | `npm install` not run — Node/npm not in PATH on this machine |
| **Next** | **Task 4 — Firestore repositories + Storage** |

---

## Step 8 — Task 4: Repositories + storageService (PLAN todo #4)

| | |
|---|---|
| **Date** | 2026-07-13 |
| **Action** | Implemented Firestore repos (`users`, `verificationCodes`, `sessions`) + `storageService` for profile uploads |
| **PLAN.md todo** | #4 ✅ |
| **Skills read** | ponytail, doc-coauthoring |
| **Files created** | `backend/src/repositories/userRepository.js`, `otpRepository.js`, `sessionRepository.js`, `backend/src/services/storageService.js` |
| **Outcome** | **Success** — data layer ready for auth/user routes (Tasks 5–6) |
| **Next** | **Task 5 — Auth routes** |

---

## Step 9 — Task 5: Auth API routes (PLAN todo #5)

| | |
|---|---|
| **Date** | 2026-07-13 |
| **Action** | Auth JSON API for mobile/ app: register, verify, login, forgot/reset password, refresh, logout |
| **PLAN.md todo** | #5 ✅ |
| **Skills read** | ponytail, doc-coauthoring |
| **Files created** | `authController.js`, `authRoutes.js`, `authValidators.js`, `auth.js`, `validate.js`, `emailService.js`, `tokenService.js`, `otpService.js` |
| **Endpoints** | `POST /api/auth/register`, `/verify`, `/login`, `/forgot-password`, `/reset-password`, `/refresh`, `/logout` |
| **Outcome** | **Success** — bcrypt 12, JWT, OTP email (logs to console if no SMTP) |
| **Next** | **Task 6 — User profile API routes** |

---

## Step 10 — Task 6: User profile API (PLAN todo #6)

| | |
|---|---|
| **Date** | 2026-07-13 |
| **Action** | User profile JSON API for mobile/ app: GET/PUT `/api/users/me`, PUT `/api/users/me/password` |
| **PLAN.md todo** | #6 ✅ |
| **Skills read** | ponytail, doc-coauthoring |
| **Files created** | `userController.js`, `userRoutes.js`, `userValidators.js` |
| **Endpoints** | `GET /api/users/me`, `PUT /api/users/me` (multipart), `PUT /api/users/me/password` |
| **Outcome** | **Success** — profile image upload 5MB jpeg/png, optional refreshToken keeps session on password change |
| **Next** | **Task 7 — Validators, rate limits** |

---

## Step 11 — Task 7: Middleware + rate limits (PLAN §6.3–§6.5)

| | |
|---|---|
| **Date** | 2026-07-13 |
| **Action** | Rate limiters per §6.4; confirmed Helmet + CORS + Joi validators on all auth/user routes |
| **PLAN.md todo** | #7 partial (tests remain in Task 8) |
| **Skills read** | ponytail, doc-coauthoring |
| **Files created/updated** | `rateLimiter.js`, `authRoutes.js`, `routes/index.js`, `server.js` |
| **Rate limits** | Auth strict 5/15min, OTP 10/15min, other API 100/15min — `RATE_LIMITED` response |
| **Outcome** | **Success** — middleware stack matches §6.3 |
| **Next** | **Task 8 — Backend tests** |

---

## Step 12 — Task 8: Backend tests (PLAN §6.7, todo #7)

| | |
|---|---|
| **Date** | 2026-07-13 |
| **Action** | Jest + Supertest auth/user tests with mocked repositories (6 files, 14 cases) |
| **PLAN.md todo** | #7 ✅ |
| **Skills read** | ponytail, webapp-testing |
| **Files created** | `src/__tests__/setup.js`, `auth.register.test.js`, `auth.login.test.js`, `auth.verify.test.js`, `auth.refresh.test.js`, `users.me.test.js`, `middleware.rateLimit.test.js` |
| **Outcome** | **Success** — tests written; `npm test` not run (Node/npm not in PATH) |
| **Fix** | Per-route rate limiter instances (test isolation) |
| **Next** | **Task 8b — ponytail-review backend** |

---

## Step 13 — Task 8b: ponytail-review backend

| | |
|---|---|
| **Date** | 2026-07-13 |
| **Action** | Reviewed `backend/` for over-engineering; trimmed bloat |
| **Skills read** | ponytail, ponytail-review |
| **Findings** | `otpService.js` yagni (1 fn) → inlined crypto in authController; duplicate password Joi → shared export; duplicate refresh/logout schema merged; storageService bucket() shrink |
| **Files deleted** | `services/otpService.js` |
| **Outcome** | **Lean** — net ~15 lines removed |
| **Next** | **Task 9 — ML scaffold** |

---

## Step 14 — Task 9: ML service scaffold (PLAN todo #8)

| | |
|---|---|
| **Date** | 2026-07-13 |
| **Action** | Scaffolded `ml-service/` FastAPI app for mobile/ HQ capture |
| **PLAN.md todo** | #8 ✅ |
| **Skills read** | ponytail, doc-coauthoring |
| **Files created** | `main.py`, `config.py`, `requirements.txt`, `Dockerfile`, `.env.example`, `scripts/download_model.py`, `api/routes.py`, `api/schemas.py`, `api/auth.py`, `inference/engine.py`, `models/.gitkeep` |
| **Endpoint** | `GET /health` — model_loaded false until weights added |
| **Outcome** | **Success** — inference pipeline deferred to Task 10 |
| **Next** | **Task 10 — Inference pipeline** |

---

## Step 15 — Task 10: MODNet inference pipeline (PLAN todo #9)

| | |
|---|---|
| **Date** | 2026-07-13 |
| **Action** | Implemented preprocess → MODNet TF SavedModel → postprocess RGBA; `POST /inference/segment` |
| **PLAN.md todo** | #9 ✅ |
| **Skills read** | ponytail, doc-coauthoring |
| **Files created/updated** | `preprocessing/frame.py`, `postprocessing/mask.py`, `inference/engine.py`, `inference/segment.py`, `api/routes.py`, `main.py`, `scripts/download_model.py`, `config.py`, `.env.example` |
| **Endpoint** | `POST /inference/segment` — JWT + multipart `file` + optional `quality`; returns PNG |
| **Notes** | `download_model.py` writes placeholder SavedModel if no real MODNet weights; morph+blur instead of guided filter (opencv-headless). Needs Python 3.11 + tensorflow to run. |
| **Outcome** | **Success** |
| **Next** | **Task 11 — Benchmark + ML tests** |

---

## Step 16 — Task 11: Benchmark + ML tests (PLAN todo #10)

| | |
|---|---|
| **Date** | 2026-07-13 |
| **Action** | Added `POST /inference/benchmark` + `tests/test_inference.py` (alpha PNG assert, JWT segment, latency/FPS log ≥2 FPS target) |
| **PLAN.md todo** | #10 ✅ |
| **Skills read** | ponytail, webapp-testing |
| **Files** | `api/routes.py`, `api/schemas.py`, `tests/test_inference.py` |
| **Outcome** | **Success** — pytest needs Python 3.11 + tensorflow (skips cleanly otherwise) |
| **Next** | **Task 11b — ponytail-review ML** |

---

## Step 17 — Task 11b: ponytail-review ML

| | |
|---|---|
| **Date** | 2026-07-13 |
| **Action** | Reviewed `ml-service/` for over-engineering; trimmed bloat |
| **Skills read** | ponytail, ponytail-review |
| **Findings applied** | Dropped `_resolve_path` legacy `.pb` dance; dropped `LEGACY_PB` + `_has_saved_model`; merged format checks; inlined `TARGET_FPS`; `runpy` instead of importlib in tests |
| **Kept** | RuntimeError→500 at trust boundary; PLAN env keys; preprocess/postprocess self-checks; placeholder model |
| **Outcome** | **Lean** — net ~35 lines removed |
| **Next** | **Task 12 — Flutter project scaffold** |

---

## Step 18 — Task 12: Flutter project scaffold (PLAN todo #11)

| | |
|---|---|
| **Date** | 2026-07-13 |
| **Action** | Created `mobile/` Android app: Riverpod, go_router, Material 3, Dio ApiClient + JWT refresh, secure storage, route stubs |
| **PLAN.md todo** | #11 ✅ |
| **Skills read** | ponytail, frontend-design, flutter-setup-declarative-routing, flutter-apply-architecture-best-practices, flutter-implement-json-serialization, flutter-use-http-package (Dio per PLAN), dart-run-static-analysis, dart-use-primary-constructors, dart-use-pattern-matching, dart-resolve-package-conflicts |
| **Key paths** | `lib/main.dart`, `app.dart`, `router.dart`, `core/services/api_client.dart`, `secure_storage_service.dart`, `providers/auth_provider.dart`, feature stubs, `android/` minSdk 24 |
| **Note** | Flutter SDK not on PATH — scaffolded by hand; user runs `flutter create . --platforms=android` then `flutter pub get` |
| **Outcome** | **Success** — auth UI deferred to Task 13 |
| **Next** | **Task 13 — Auth screens + repository** |

---

## Step 19 — Task 13: Auth screens + repository (PLAN todo #12)

| | |
|---|---|
| **Date** | 2026-07-13 |
| **Action** | Full auth flows: login, register, verify OTP, forgot/reset; AuthRepository methods; EMAIL_NOT_VERIFIED → verify |
| **PLAN.md todo** | #12 ✅ |
| **Skills read** | ponytail, frontend-design, flutter-apply-architecture-best-practices, flutter-implement-json-serialization, dart-use-primary-constructors, dart-use-pattern-matching, dart-run-static-analysis |
| **Files** | `auth_repository.dart`, `auth_provider.dart`, login/register/verify/forgot/reset screens, `auth_form_field.dart` |
| **Note** | Resend OTP: cooldown UI only (no backend `/resend` in PLAN) — reminds user to use registration email code |
| **Outcome** | **Success** |
| **Next** | **Task 14 — Home, Profile, Settings** |

---

## Step 20 — Task 14: Home / Profile / Settings (PLAN todo #13)

| | |
|---|---|
| **Date** | 2026-07-13 |
| **Action** | Home profile card + logout menu; Profile edit name/photo/password; Settings resolution/quality/dark/privacy |
| **PLAN.md todo** | #13 ✅ |
| **Skills read** | ponytail, frontend-design, theme-factory (reference), flutter-build-responsive-layout, dart-run-static-analysis |
| **Files** | `home_screen.dart`, `profile_screen.dart`, `settings_screen.dart`, `user_repository.dart`, `settings_service.dart`, `theme_provider.dart` |
| **Deps** | Added `image_picker` for profile photo |
| **Outcome** | **Success** |
| **Next** | **Task 15 — Camera + on-device ML** |

---

## Step 21 — Task 15: Camera + ML Kit (PLAN todo #14)

| | |
|---|---|
| **Date** | 2026-07-13 |
| **Action** | Full-screen CameraScreen; ML Kit stream + TFLite stub fallback; SegmentationPainter checkerboard; Start/Stop/Switch/Capture; skip-frame from Settings quality |
| **PLAN.md todo** | #14 ✅ |
| **Skills read** | ponytail, frontend-design, flutter-fix-layout-issues, dart-fix-runtime-errors, dart-run-static-analysis |
| **Files** | `ml_on_device_service.dart`, `image_utils.dart`, `camera_service.dart`, `camera_provider.dart`, `segmentation_painter.dart`, `camera_screen.dart`, `test/ml_on_device_service_test.dart` |
| **Note** | Capture = local still + dialog; HQ server flow deferred to Task 16. No bundled `.tflite` yet — elliptical prior stub |
| **Outcome** | **Success** |
| **Next** | **Task 16 — HQ capture** |

---

## Step 22 — Task 16: HQ capture (PLAN todo #15)

| | |
|---|---|
| **Date** | 2026-07-13 |
| **Action** | Capture → loading dialog → `MlRepository.segmentImage` (30s) → fullscreen Save/Discard; on failure `segmentStillToPng` + “Processed on device”; gallery via `gal` |
| **PLAN.md todo** | #15 ✅ |
| **Skills read** | ponytail, frontend-design, flutter-use-http-package, dart-run-static-analysis |
| **Files** | `camera_provider.dart`, `camera_screen.dart`, `ml_repository.dart`, `ml_on_device_service.dart`, `test/hq_fallback_test.dart` |
| **Outcome** | **Success** |
| **Next** | **Task 16b — ponytail-review Flutter** |

---

## Step 23 — Task 16b: ponytail-review mobile/

| | |
|---|---|
| **Date** | 2026-07-13 |
| **Action** | Trimmed dead/unused: `app_button.dart`, `settings_provider` barrel, `intl`, hollow prefs providers, dead TFLite Interpreter path (kept elliptical prior + pubspec dep note), `presetFor` string hop, `setAuthenticated`/`User.toJson`/`health`/`isDark`, unused painter threshold |
| **PLAN.md todo** | — (review) |
| **Skills read** | ponytail, ponytail-review, frontend-design |
| **Files** | deleted `widgets/app_button.dart`, `providers/settings_provider.dart`; slimmed `ml_on_device_service`, `camera_service`, `image_utils`, `theme_provider`, `segmentation_painter`, `auth_provider`, `user.dart`, `api_constants`, `settings_service`, `pubspec.yaml` |
| **Review net** | ~−120 lines; left shared Dio→ApiError helper (mild dup OK) |
| **Outcome** | **Success** |
| **Next** | **Task 17 — Flutter tests** |

---

## Step 24 — Task 17: Flutter tests (PLAN §8.8 / todo #16 tests)

| | |
|---|---|
| **Date** | 2026-07-13 |
| **Action** | PLAN §8.8 suite: `validators_test`, `login_screen_test`, `verify_email_screen_test`, `settings_screen_test`, `auth_flow_test` (mocked splash→login→home) + `integration_test/auth_flow_test.dart` |
| **PLAN.md todo** | #16 (tests portion; docs Tasks 18–20 remain) |
| **Skills read** | ponytail, webapp-testing, flutter-add-widget-test, flutter-add-integration-test, dart-add-unit-test, dart-generate-test-mocks, dart-collect-coverage, dart-run-static-analysis |
| **Files** | `test/validators_test.dart`, `test/login_screen_test.dart`, `test/verify_email_screen_test.dart`, `test/settings_screen_test.dart`, `test/auth_flow_test.dart`, `integration_test/auth_flow_test.dart` |
| **Mocks** | mocktail (already in pubspec) — skipped mockito/build_runner |
| **Run** | **Blocked:** Flutter SDK not on PATH; download of stable zip (~1.6GB) too slow to finish in-session. After install: `cd mobile && flutter pub get && flutter test` |
| **Outcome** | **Success** (tests authored; execution pending local Flutter) |
| **Next** | **Task 18 — API.md** |

---

## Step 25 — Task 18: docs/API.md (PLAN §11.1)

| | |
|---|---|
| **Date** | 2026-07-13 |
| **Action** | Full API reference: 11 backend + 3 ML endpoints, curl examples, status/`code` tables, rate limits, JWT notes |
| **PLAN.md todo** | #16 (API.md portion) |
| **Skills read** | ponytail, doc-coauthoring |
| **Files** | `docs/API.md` |
| **Note** | PLAN said “13 backend”; shipped count is 11 (documented with index note) |
| **Outcome** | **Success** |
| **Next** | **Task 19 — INSTALLATION.md** |

---

## Note — Phase 2 planning doc (2026-07-13)

Created [PLAN2.md](PLAN2.md) — post-MVP plan for fine-tuning on Kaggle/custom data, which code changes, and how to swap trained models into `ml-service/` and optionally `mobile/`. **Do not implement until Phase 1 (PLAN.md §0–§13) is complete.**

---

## Note — Architecture clarity (2026-07-13)

**Primary product = Flutter Android app** (`mobile/`). `backend/server.js` is the REST API the app calls — not a web app. Updated `.cursor/rules/mackhan.mdc`, `AGENTS.md`, `PLAN.md` §0, `TASKS.md`, `README.md` so all agents know this.

---

## Note — Phase 2 docs (2026-07-13)

Added [PLAN2.md](PLAN2.md) + [TASKS2.md](TASKS2.md) for post-MVP custom model training (Kaggle fine-tune → swap `models/modnet/`). **Do not start Tasks 21–31 until TASKS.md 0–20b are complete.**

---

## Step 26 — Task 20: Final README + security verify

| | |
|---|---|
| **Date** | 2026-07-26 |
| **Action** | Final root README; verified PLAN §10 checklist against code; fixed broken Jest firebase mock + refresh `jti` so rotation tokens differ same-second; ran tests |
| **PLAN.md todo** | #16 ✅ |
| **Skills read** | ponytail, doc-coauthoring |
| **Files** | `README.md`, `docs/PLAN.md` (§10 checked), `backend/src/__tests__/setup.js`, `tokenService.js` (`jti`), `middleware.rateLimit.test.js` |
| **Tests** | Backend: **14/14 pass**. ML: **3 skipped** (no tensorflow / need Python 3.11). Flutter: **not run** (SDK not on PATH) |
| **§10** | All 14 items verified in code/docs (HTTPS = platform TLS in DEPLOYMENT) |
| **Outcome** | **Success** |
| **Next** | Task 20b ponytail-audit |

---

## Step 27 — Task 20b: ponytail-audit

| | |
|---|---|
| **Date** | 2026-07-26 |
| **Action** | Repo-wide over-engineering audit; applied shrinks that stay inside PLAN |
| **PLAN.md todo** | — (final audit) |
| **Skills read** | ponytail, ponytail-audit |
| **Applied** | `rateLimiter` one factory; `env.js` `unlessAdc` + drop redundant `stripUnknown`; remove redundant `jest.clearAllMocks` (config already clears) |
| **Skipped (PLAN-mandated)** | winston, uuid, Pillow, compose `backend:` block, `ML_SERVICE_URL`, ML dead-ish env keys, `storageService.js`, benchmark `image_path` |
| **Audit net applied** | ~−40 lines; 0 deps (PLAN locks winston/uuid/Pillow) |
| **Outcome** | **Success** — Phase 1 complete |
| **Next** | Optional TASKS2.md / PLAN2.md |

---

## Note — Agent tooling folder (2026-07-26)

Moved all AI/skills tooling into **`agent/`** so the product root stays clean: `AGENTS.md`, `CLOUDE.md`, `cloude/`, `ponytail/`, `skills/`, `flutter-skills/`, `dart-skills/`, `.tools`. Root keeps a thin `AGENTS.md` pointer. **`.cursor/` stays at repo root** (Cursor IDE requirement). Active skills still load from `.cursor/skills/`.

---

## Skill Usage Tracker

Update after every task when a skill's SKILL.md was read:

| Skill | Repo | Times read | Last used | Notes |
|-------|------|------------|-----------|-------|
| ponytail | Repo 1 | 24 | 2026-07-26 | Task 20b |
| webapp-testing | Repo 2 | 3 | 2026-07-13 | Task 17 (Flutter, not Playwright) |
| ponytail-review | Repo 1 | 3 | 2026-07-13 | Task 16b |
| ponytail-audit | Repo 1 | 1 | 2026-07-26 | Task 20b |
| doc-coauthoring | Repo 2 | 6 | 2026-07-26 | INSTALL CLI Android rewrite |
| frontend-design | Repo 2 | 6 | 2026-07-13 | Task 16b |
| theme-factory | Repo 2 | 1 | 2026-07-13 | Task 14 (reference) |
| skill-creator | Repo 2 | 1 | 2026-07-13 | Task 0 |
| flutter-setup-declarative-routing | Repo 3 | 1 | 2026-07-13 | Task 12 |
| flutter-apply-architecture-best-practices | Repo 3 | 2 | 2026-07-13 | Task 13 |
| flutter-build-responsive-layout | Repo 3 | 1 | 2026-07-13 | Task 14 |
| flutter-fix-layout-issues | Repo 3 | 1 | 2026-07-13 | Task 15 |
| flutter-use-http-package | Repo 3 | 1 | 2026-07-13 | Task 16 (Dio already in use) |
| flutter-add-widget-test | Repo 3 | 1 | 2026-07-13 | Task 17 |
| flutter-add-integration-test | Repo 3 | 1 | 2026-07-13 | Task 17 |
| dart-fix-runtime-errors | Repo 4 | 1 | 2026-07-13 | Task 15 |
| dart-run-static-analysis | Repo 4 | 6 | 2026-07-13 | Task 17 |
| dart-add-unit-test | Repo 4 | 1 | 2026-07-13 | Task 17 |
| dart-generate-test-mocks | Repo 4 | 1 | 2026-07-13 | Task 17 (used mocktail) |
| dart-collect-coverage | Repo 4 | 1 | 2026-07-13 | Task 17 (read; run after Flutter install) |

---

## PLAN.md Todo Progress

Copy from PLAN.md — check off here as work completes:

- [x] #1 Create monorepo root
- [x] #2 Document Firebase project setup
- [x] #3 Scaffold backend/
- [x] #4 Implement Firestore repositories
- [x] #5 Implement auth controllers/routes
- [x] #6 Implement user controllers/routes
- [x] #7 Add Joi validators, rate limiters, tests
- [x] #8 Scaffold ml-service/
- [x] #9 Implement MODNet inference pipeline
- [x] #10 Add benchmark endpoint + validation
- [x] #11 Create Flutter project
- [x] #12 Build auth feature screens
- [x] #13 Build Home, Profile, Settings
- [x] #14 Build Camera screen + on-device ML
- [x] #15 Implement HQ capture
- [x] #16 Write tests + API.md + INSTALLATION.md + DEPLOYMENT.md + root README

---

## Step — INSTALL.md CLI Android toolchain (no Studio)

| | |
|---|---|
| **Date** | 2026-07-26 |
| **Action** | Captured user’s Windows CLI-only setup plan into `docs/INSTALLATION.md` (Flutter + JDK 17 + Android cmdline-tools / adb — not Android Studio IDE). Flutter SDK already extracted to `D:\flutter` + User PATH. Aligned PLAN §11.2 wording. |
| **PLAN.md todo** | §11.2 |
| **Skills read** | ponytail, doc-coauthoring |
| **Files touched** | `docs/INSTALLATION.md`, `docs/PLAN.md` (§11.2), `docs/LOG.md` |
| **Outcome** | Success — single install doc is the source of truth; no new doc file |
| **Next** | Install JDK 17 + Android SDK CLI; run `flutter doctor` + `adb devices`; paste output |

---

## Step — STEPS.MD Phase A updated (C: cleanup lessons)

| | |
|---|---|
| **Date** | 2026-07-27 |
| **Action** | Ran C: cleanup; updated root `STEPS.MD` Phase A with real space hogs |
| **PLAN.md todo** | — (ops runbook, not product feature) |
| **Skills read** | ponytail |
| **Files touched** | `STEPS.MD`, `docs/LOG.md` |
| **Outcome** | C: ~0.9 → ~4.8 GB free. A3–A6 often 0 MB (already empty). Real win = delete leftover `C:\Users\AP\.gradle` when `GRADLE_USER_HOME` is `D:\mackhan-cache\gradle`. STEPS now has A8 (gradle-on-C), A9 (browser/editor cache), clearer “why clean does nothing” note |
| **Next** | Phase B DNS → C RAM → G/H/I flutter run outside Cursor |

---

## Step — STEPS.MD agent handoff for new chats

| | |
|---|---|
| **Date** | 2026-07-27 |
| **Action** | Added AGENT PROTOCOL + SESSION MEMORY so new chat can “read STEPS.MD / do it” for full phone run |
| **PLAN.md todo** | — |
| **Skills read** | ponytail |
| **Files touched** | `STEPS.MD`, `docs/LOG.md` |
| **Outcome** | Yes, full Flutter-on-phone is restartable. Snapshot: C~4.8GB, phone device, backend up, ML down, FreeMB~675 with Cursor (RAM is the main risk) |
| **Next** | New chat: paste NEW CHAT block from STEPS.MD; agent runs A→I |

---

## Step — Full phone run A→I (partial)

| | |
|---|---|
| **Date** | 2026-07-27 |
| **Action** | Executed STEPS.MD phases A→I for Flutter on phone |
| **PLAN.md todo** | §11.2 / install-run |
| **Skills read** | ponytail |
| **Files touched** | `STEPS.MD` (SESSION MEMORY), `docs/LOG.md` |
| **Outcome** | A skip (C 4.79GB); B DNS OK; C FreeMB~500; D cache OK; E `RRCW900YP4V device`; F JWT match + IP `192.168.100.118`; G backend healthy; H TF curl ~30KB/s to `D:\mackhan-cache\manual\…whl` (pip hung earlier); **I stopped** — FreeMB &lt;1500 with Cursor |
| **Next** | User closes Cursor → Phase I in external PowerShell; leave curl finish then pip install + uvicorn for HQ |

---

## Step 38 — APK / phone runbook doc

| | |
|---|---|
| **Date** | 2026-08-01 |
| **Action** | Added `docs/APK_PHONE_RUNBOOK.md`: full PowerShell commands for env setup, arm64 debug APK build, install on any phone (`adb` / `-s SERIAL`), USB `adb reverse` for login, backend start, demo credentials, one-shot script, troubleshooting. |
| **PLAN.md todo** | §11.2 companion (ops runbook) |
| **Skills read** | ponytail |
| **Files touched** | `docs/APK_PHONE_RUNBOOK.md`, `docs/LOG.md` |
| **Outcome** | Single copy-paste guide for rebuild / new phone / login after unplug |
| **Next** | User follows runbook; optional DEPLOYMENT for no-USB login |

---

## Step 37 — Mode tray touchable + blur + shader-mask accuracy

| | |
|---|---|
| **Date** | 2026-08-01 |
| **Action** | Tray was painted before the control bar so the bar swallowed taps: moved tray + bar into one bottom `Column` (tray above bar, always tappable, bigger 44px targets). Added `BgKind.blur` (ImageFiltered blurred preview behind subject). Replaced blocky `SegmentationPainter` (deleted) with real background replacement: mask → `ui.Image` alpha (smoothstep feather) + `ShaderMask` `dstIn` over a sharp `CameraPreview`, so GPU bilinear filtering smooths hair edges. Mask images disposed on replace/stop/dispose. |
| **PLAN.md todo** | §8.4.10 |
| **Skills read** | ponytail |
| **Files touched** | `camera_screen.dart`, `camera_provider.dart`, `background_mode.dart`, deleted `segmentation_painter.dart`, `docs/LOG.md` |
| **Outcome** | Analyze clean; APK built + installed. Multi-person / Snapchat-grade matting still limited by ML Kit Selfie Segmentation (person-centric) — documented as Stream 5. |
| **Next** | Device test tray + blur; if edges still short of target, Stream 5 model swap |

---

## Step 36 — Pixel Lift Streams 1–3 implemented

| | |
|---|---|
| **Date** | 2026-08-01 |
| **Action** | Promoted PIXEL_LIFT_PLAN Streams 1–3 into PLAN §8.4.10. Branding (Pixel Lift, sky/orange theme, launcher icon). Camera mode tray (transparent/colors/built-in/gallery), Start Lift idle UX, Stop clears mask. Live accuracy: temporal mask blend + soft threshold/feather; still PNG soft alpha. Capture labels Studio vs Quick. Stream 4 deploy + Stream 5 extras deferred (need hosting / YAGNI). |
| **PLAN.md todo** | §8.4.10 |
| **Skills read** | ponytail |
| **Files touched** | theme/constants/manifest/icons, camera_*, background_mode, segmentation_painter, ml_on_device_service, pubspec assets, docs |
| **Outcome** | Code complete for Streams 1–3; analyze clean; unit test for BackgroundMode |
| **Next** | Build/install APK; user device test; Stream 4 hosted backend when ready |

---

## Step 35 — Pixel Lift next-work plan written

| | |
|---|---|
| **Date** | 2026-08-01 |
| **Action** | Wrote `docs/PIXEL_LIFT_PLAN.md`: rebrand (Pixel Lift + icon + sky/orange), Start/Stop + background modes, accuracy layers (live post-process → HQ MODNet → optional TFLite → PLAN2 training), multi-object honesty, no-USB for live ML. Copied icon to `docs/assets/` and `mobile/assets/branding/`. Linked from PLAN.md docs table. |
| **PLAN.md todo** | Planning only — no product code outside §0–§13 |
| **Skills read** | ponytail, doc-coauthoring |
| **Files touched** | `docs/PIXEL_LIFT_PLAN.md`, `docs/PLAN.md`, `docs/assets/pixel_lift_icon.png`, `mobile/assets/branding/pixel_lift_icon.png`, `docs/LOG.md` |
| **Outcome** | Plan ready — next coding slice = Stream 1 branding after promoting into PLAN.md |
| **Next** | User approves Stream 1 (name/theme/icon) → update PLAN.md then implement |

---

## Step 34 — Splash hang root cause: GoRouter rebuild race

| | |
|---|---|
| **Date** | 2026-08-01 |
| **Action** | Runtime logs proved splash hang was not network: after successful bootstrap (~7.8s), `ref.watch(authProvider)` in `routerProvider` rebuilt a new GoRouter at `initialLocation: '/'`, discarding `context.go('/home')`. Fix: `ref.read` + `refreshListenable` only; redirect authenticated users from `/` to `/home`. Removed debug instrumentation. |
| **PLAN.md todo** | §11.2 / run |
| **Skills read** | ponytail |
| **Files touched** | `mobile/lib/router.dart`, `mobile/lib/features/auth/presentation/splash_screen.dart`, `mobile/lib/providers/auth_provider.dart`, `docs/LOG.md` |
| **Outcome** | Success — user confirmed fixed; instrumentation cleaned up |
| **Next** | Camera / real-time background removal on device |

---

## Step 33 — Splash hang fixed (secure-storage blocking read)

| | |
|---|---|
| **Date** | 2026-08-01 |
| **Action** | Diagnosed post-login splash freeze. Confirmed it was NOT a throw (try/catch didn't help) but `flutter_secure_storage.readRefreshToken()` blocking forever while decrypting a stale token from a prior install. Added hard `.timeout()` (4s read, 12s refresh, 4s clear) in `authProvider.bootstrap()` so splash always advances to `/login`. Verified: after `pm clear`, current build reached Sign-in screen. Rebuilt debug APK the known-good way (`--target-platform android-arm64`, heap 1536m) after killing stale Java procs that had caused a Jetify `Java heap space` OOM. |
| **PLAN.md todo** | §11.2 / run |
| **Skills read** | ponytail |
| **Files touched** | `mobile/lib/providers/auth_provider.dart`, `docs/LOG.md` |
| **Outcome** | Success — APK builds, installs, launches to Sign-in (no hang). Timeout makes splash resilient to stale keystore tokens. |
| **Next** | Log in on phone → reach camera → test real-time background removal |

---

## Step 32 — Android startup crash fixed

| | |
|---|---|
| **Date** | 2026-07-30 |
| **Action** | Captured phone crash log; restored missing Flutter ReLinker runtime dependency omitted by incomplete local Maven metadata |
| **PLAN.md todo** | §11.2 / run |
| **Skills read** | ponytail + dart-fix-runtime-errors |
| **Files touched** | `mobile/android/app/build.gradle.kts`, `docs/LOG.md` |
| **Outcome** | Success — APK rebuilt, installed, launched cold, and process remained active with `MainActivity` resumed |
| **Next** | Test camera permission and real-time segmentation |

---

## Step 31 — Debug APK build after reset (heap + jetify)

| | |
|---|---|
| **Date** | 2026-07-30 |
| **Action** | Fixed post-reset Android build: added `androidx.fragment` for AGP 9 plugin classpath; raised Gradle heap `768m→1536m`; avoided corrupt `armeabi_v7a`/`x86_64` jetify by building `--target-platform android-arm64` |
| **PLAN.md todo** | §11.2 / run |
| **Skills read** | ponytail |
| **Files touched** | `mobile/android/build.gradle.kts`, `mobile/android/gradle.properties`, `docs/LOG.md` |
| **Outcome** | Success — `mobile/build/app/outputs/flutter-apk/app-debug.apk` |
| **Next** | Install/run on phone `RRCW900YP4V` |

---

## Step 30 — Flutter Android env audit (post Windows reset)

| | |
|---|---|
| **Date** | 2026-07-30 |
| **Action** | Full project + machine audit for APK/phone testing; no installs performed |
| **PLAN.md todo** | §11.2 / environment |
| **Skills read** | ponytail |
| **Files touched** | docs/LOG.md (this entry + Current Status) |
| **Findings** | Project: Flutter ≥3.44 / Dart ≥3.12 (lock), AGP 9.0.1, Gradle 9.1.0 wrapper, Kotlin 2.3.20, JDK 17, compile/targetSdk 36, minSdk 24; NDK/CMake not required (`tflite_flutter` commented out); on-device ML = ML Kit only; arm64-v8a ABI filter. Machine: `D:\flutter` 3.44.8, `D:\Android\Sdk` (API 34–36 + platform-tools + NDK present), `D:\mackhan-cache` (~4.5GB) survive; User PATH / JAVA_HOME empty; JDK missing from disk; Git/Node not on PATH. Python/Node/Git not needed for APK build. |
| **Outcome** | Audit complete — wait for user to approve install steps |
| **Next** | Install JDK 17 only + restore PATH/env; verify with `flutter doctor -v` + `adb devices` |

---

## Environment Notes

| Item | Status |
|------|--------|
| Git | Not available in PATH (not required for APK) |
| GitHub CLI (`gh`) | Not available in PATH |
| curl | Available |
| Flutter SDK | `D:\flutter` (3.44.8 stable) — present; **User PATH cleared after Windows reset** |
| Android SDK | `D:\Android\Sdk` — present (platforms 34/35/36, build-tools, platform-tools, cmdline-tools, NDK 28.2) |
| JDK | **Missing** after reset — must reinstall OpenJDK 17 |
| Caches | `D:\mackhan-cache` (~4.5 GB: gradle + pub + local-m2) |
| Free space | C: ~29 GB · D: ~31 GB |
| Android Studio | Not required — use SDK cmdline-tools |
| Ponytail | v4.8.4 at `ponytail/` |
| Anthropic Skills | 17 skills at `skills/` |

---

## Step 39 — Gallery studio §8.4.11 adopted (Task G0)

| | |
|---|---|
| **Date** | 2026-09-14 |
| **Action** | Promoted [GALLERY_EXPORT_PLAN.md](GALLERY_EXPORT_PLAN.md) into PLAN.md §8.4.11; updated §3 monorepo tree; added Phase 6 Tasks G0–G8 in TASKS.md |
| **PLAN.md todo** | §8.4.11 adoption |
| **Skills read** | ponytail |
| **Files touched** | `docs/PLAN.md`, `docs/TASKS.md`, `docs/LOG.md` |
| **Outcome** | **Success** — gate cleared for gallery/export code |
| **Next** | Task G1 crop + export utils |

---

## Step 40 — crop_utils + export_utils (Task G1)

| | |
|---|---|
| **Date** | 2026-09-14 |
| **Action** | Added `crop_utils.dart` (alpha bounds + crop), `export_utils.dart` (PNG/JPG white/WebP encode), unit tests |
| **PLAN.md todo** | §8.4.11 |
| **Skills read** | ponytail |
| **Files touched** | `mobile/lib/core/utils/crop_utils.dart`, `export_utils.dart`, `test/crop_utils_test.dart`, `test/export_utils_test.dart`, `docs/TASKS.md`, `docs/LOG.md` |
| **Outcome** | **Success** — utils ready; run `flutter test test/crop_utils_test.dart test/export_utils_test.dart` locally |
| **Next** | Task G2 — extract `export_preview_dialog` + `editor_provider` |

---

## Step 41 — export_preview_dialog + editor_provider (Task G2)

| | |
|---|---|
| **Date** | 2026-09-14 |
| **Action** | Extracted `ExportPreviewDialog` from camera; added `editor_provider.dart` with `segmentFile()` (ML + on-device fallback) |
| **PLAN.md todo** | §8.4.11 |
| **Skills read** | ponytail |
| **Files touched** | `widgets/export_preview_dialog.dart`, `providers/editor_provider.dart`, `camera_screen.dart`, `test/widget_test.dart`, `test/hq_fallback_test.dart` |
| **Outcome** | **Success** — camera HQ capture unchanged; 24/24 flutter tests pass |
| **Next** | Task G3 editor screen |

---

## Step 42 — Gallery editor Feature 1 (Task G3)

| | |
|---|---|
| **Date** | 2026-09-14 |
| **Action** | `EditorScreen` (pick gallery → segment → preview); route `/editor`; Home **Edit from Gallery** button |
| **PLAN.md todo** | §8.4.11 Feature 1 |
| **Skills read** | ponytail |
| **Files touched** | `features/editor/presentation/editor_screen.dart`, `router.dart`, `home_screen.dart`, `docs/TASKS.md`, `docs/LOG.md` |
| **Outcome** | **Success** — Feature 1 code complete; device test via APK runbook |
| **Next** | Task G4 export format picker |

---

## Step 43 — Export format picker (Task G4)

| | |
|---|---|
| **Date** | 2026-09-16 |
| **Action** | Settings default export format; `ExportPreviewDialog` SegmentedButton PNG/JPG/WebP; save via `encodeExport` + correct file extension |
| **PLAN.md todo** | §8.4.11 Feature 2 |
| **Skills read** | ponytail |
| **Files touched** | `export_utils.dart`, `settings_service.dart`, `theme_provider.dart`, `export_preview_dialog.dart`, `settings_screen.dart`, tests |
| **Outcome** | **Success** — camera HQ + gallery editor share format picker; 25/25 tests pass |
| **Next** | Task G5 auto-crop |

---

## Step 44 — Auto-crop after remove (Task G5)

| | |
|---|---|
| **Date** | 2026-09-16 |
| **Action** | Settings toggle `auto_crop` (default ON); `autoCropPngBytes()` in gallery + camera HQ pipelines |
| **PLAN.md todo** | §8.4.11 Feature 3 |
| **Skills read** | ponytail |
| **Files touched** | `crop_utils.dart`, `settings_service.dart`, `theme_provider.dart`, `editor_provider.dart`, `camera_provider.dart`, `settings_screen.dart`, `crop_utils_test.dart` |
| **Outcome** | **Success** — 26/26 flutter tests pass |
| **Next** | Task G6 e-commerce white preset |

---

## Step 45 — Product white BG preset (Task G6)

| | |
|---|---|
| **Date** | 2026-09-16 |
| **Action** | Home **Product white BG** → `/editor?preset=product_white`; locked JPG export, `pixel_lift_product_*.jpg`, honest portrait-only label |
| **PLAN.md todo** | §8.4.11 Feature 4 |
| **Skills read** | ponytail |
| **Files touched** | `home_screen.dart`, `editor_screen.dart`, `export_preview_dialog.dart`, `router.dart`, `docs/TASKS.md`, `docs/LOG.md` |
| **Outcome** | **Success** — 26/26 tests pass |
| **Next** | Task G7 batch mode |

---

## Step 46 — Batch gallery edit (Task G7)

| | |
|---|---|
| **Date** | 2026-09-16 |
| **Action** | `processBatch()` up to 20 images on-device; progress UI + Cancel; Home **Batch edit** → `/editor?batch=1` |
| **PLAN.md todo** | §8.4.11 Feature 8 |
| **Skills read** | ponytail |
| **Files touched** | `editor_provider.dart`, `editor_screen.dart`, `home_screen.dart`, `router.dart` |
| **Outcome** | **Success** — 26/26 tests pass |
| **Next** | Task G8 full APK QA checklist |

---

## Step 47 — Gallery studio QA + APK (Task G8)

| | |
|---|---|
| **Date** | 2026-09-16 |
| **Action** | `flutter analyze` + `flutter test` (26/26); debug arm64 APK build; ponytail trim: shared `segmentStillFile()` in `camera_provider.dart` (camera HQ + editor/batch) |
| **PLAN.md todo** | §8.4.11 Phase 8 / GALLERY_EXPORT_PLAN §4.4 |
| **Skills read** | ponytail, ponytail-review |
| **Files touched** | `camera_provider.dart`, `editor_provider.dart`, `docs/LOG.md`, `docs/TASKS.md` |
| **Outcome** | **Success (build + unit tests)** — APK `mobile/build/app/outputs/flutter-apk/app-debug.apk` (~139 MB). Analyze: 1 pre-existing info (`depend_on_referenced_packages` in `image_utils.dart`). No backend changes — `docs/API.md` unchanged. |
| **§4.4 device checklist** | No phone on `adb devices` — manual QA not run this session |

| # | Test | Status |
|---|------|--------|
| 1 | Camera live + Capture | **Pending device** |
| 2 | Gallery single | **Pending device** |
| 3 | Export JPG | **Pending device** |
| 4 | Auto-crop | **Pending device** |
| 5 | Product preset | **Pending device** |
| 6 | Batch 5 photos | **Pending device** |
| 7 | Auth logout/login | **Pending device** |
| 8 | Offline batch | **Pending device** |

| **Next** | Install APK per [APK_PHONE_RUNBOOK.md](APK_PHONE_RUNBOOK.md) §3–§5; run §4.4 checklist on device |

---

## Step 48 — GitHub sync (Gallery studio + docs)

| | |
|---|---|
| **Date** | 2026-09-23 |
| **Action** | Push local `D:\MACKHAN` work to GitHub (`origin`). Excluded from repo: `.cursor/`, `.vscode/` (gitignore). Included: Phase 6 gallery & export studio (G0–G8), `docs/LOG.md`, `docs/TASKS.md`, `docs/GALLERY_EXPORT_PLAN.md`, `docs/APK_PHONE_RUNBOOK.md`, `agent/`, `AGENTS.md`, mobile editor/gallery/export code, unit tests, `.gitignore` updates |
| **PLAN.md todo** | §8.4.11 + project memory |
| **Skills read** | ponytail |
| **Chat summary (this session arc)** | Compared vs remove.bg; planned features 1/2/3/4/8 in `GALLERY_EXPORT_PLAN.md`; G0 §8.4.11 in PLAN; G1 `crop_utils` + `export_utils`; G2 preview dialog + `editor_provider`; G3 gallery `/editor`; G4 export formats; G5 auto-crop; G6 product white JPG preset; G7 batch (20, on-device); G8 analyze/test/APK + `segmentStillFile()` dedupe |
| **Files touched** | Whole gallery studio tree under `mobile/lib/` + `mobile/test/`; `docs/*` (LOG, TASKS, PLAN, runbooks); `.gitignore` |
| **Outcome** | **Success** — commit pushed to GitHub; device §4.4 checklist still pending on phone |
| **Next** | Manual §4.4 QA on device after `adb install` |

---

## How to Add a New Log Entry (Mandatory After Every Task)

```markdown
## Step N — Short title

| | |
|---|---|
| **Date** | YYYY-MM-DD |
| **Action** | What was done |
| **PLAN.md todo** | #N or — |
| **Skills read** | ponytail + {anthropic-skill} |
| **Files touched** | list of paths |
| **Outcome** | Success / failure + notes |
| **Next** | Follow-up step |
```

Also:
1. Update **Skill Usage Tracker** (increment "Times read")
2. Update **PLAN.md Todo Progress** (check off if done)
3. Update **Current Status** and **Next Plan** tables at top
