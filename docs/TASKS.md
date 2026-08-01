# MACKHAN — Task File (One Step at a Time)

> **MANDATORY:** Every task must stay inside [PLAN.md](PLAN.md) §0–§13.  
> **Product:** Flutter **Android mobile app** in `mobile/` — this is what we ship.  
> **Supporting APIs:** `backend/` + `ml-service/` exist so the app can auth, save profiles, and HQ-capture — not websites.  
> **Four repos:** Repo 1 Ponytail (**mandatory every task — never skip**) · Repo 2 Anthropic · Repo 3 Flutter · Repo 4 Dart ([dart-lang/skills](https://github.com/dart-lang/skills) — Tasks 12–17)

---

## What we build (read first)

| Phase | Folder | Purpose |
|-------|--------|---------|
| **4 — Android app** | `mobile/` | **Primary product** — camera, ML Kit, UI, calls APIs below |
| 2 — Backend API | `backend/` | REST API for login, register, profile (app is the client) |
| 3 — ML API | `ml-service/` | HQ background removal when app uploads a capture |
| 1 — Foundation | root, `firebase/`, docs | Monorepo + Firebase config for backend |
| 0 — Setup | agent tooling | Skills repos — not product code |

**Build order:** Foundation (1–2) → Backend API (3–8) → ML API (9–11) → **Android app (12–16)** → Tests + docs (17–20).

**Do not build:** web frontend, admin dashboard, iOS app (Post-MVP §14).

---

## Rules for Every Task

1. **PLAN.md is the boundary** — only build what PLAN.md defines.
2. **Mobile app is the product** — `backend/` and `ml-service/` are APIs the Android app calls; never add a web UI.
3. **One task at a time** — finish, test, log, next.
4. **Ponytail (Repo 1) is mandatory on EVERY task — no exceptions.** Setup, docs, code, tests, and review tasks all require Ponytail. Never skip Repo 1.
5. **Other repos** — read SKILL.md from Repo 2–4 when the task table says so (in addition to Ponytail, never instead of it).
6. **Before marking done** — apply Ponytail YAGNI check: can this diff be shorter? Trim bloat. Use `ponytail-review` after feature phases (Tasks 8b, 11b, 16b) and `ponytail-audit` at end (Task 20b).
7. Update **`docs/LOG.md`** and check off **`docs/TASKS.md`** after every task.

### Four-repo read order

| Repo | Path | When |
|------|------|------|
| **1 Ponytail** | `.cursor/skills/ponytail/SKILL.md` (source: `agent/ponytail/`) | **Every task — mandatory, never skip** |
| **1 Ponytail review** | `.cursor/skills/ponytail-review/SKILL.md` | Tasks 8b, 11b, 16b (+ after any large diff) |
| **1 Ponytail audit** | `.cursor/skills/ponytail-audit/SKILL.md` | Task 20b (final) |
| **2 Anthropic** | `agent/skills/skills/{skill}/SKILL.md` | Per task table |
| **3 Flutter** | `agent/flutter-skills/skills/{skill}/SKILL.md` | Tasks 12–17 only |
| **4 Dart** | `agent/dart-skills/skills/{skill}/SKILL.md` | Tasks 12–17 only |

**Repos 3–4 are optional by task. Repo 1 Ponytail is never optional.**

### Prompt footer (every task)

```
Stay inside docs/PLAN.md only. Product = Flutter Android app (mobile/). Agent tooling lives in agent/. MANDATORY: read .cursor/skills/ponytail/SKILL.md (Repo 1 — every task). Also read docs/PLAN.md, docs/LOG.md, agent/skills/skills/{anthropic}/SKILL.md (Repo 2), agent/flutter-skills/skills/{flutter}/SKILL.md (Repo 3 — Tasks 12–17), agent/dart-skills/skills/{dart}/SKILL.md (Repo 4 — Tasks 12–17). Apply Ponytail YAGNI before done. Update docs/LOG.md. Mark complete in docs/TASKS.md.
```

---

## Phase 0 — Setup

- [x] **Task 0** — Copy Anthropic skills to Cursor

- [x] **Task 0a** — Clone Flutter skills repo + copy to Cursor

- [x] **Task 0b** — Clone Dart skills repo + copy to Cursor

**Prompt (done):**
```
Clone dart-lang/skills to dart-skills/. Copy PLAN §0.3 Dart skills to .cursor/skills/. Read .cursor/skills/ponytail/SKILL.md (Repo 1 — mandatory). Apply Ponytail YAGNI. Update docs/LOG.md and TASKS.md.
```

---

## Phase 1 — Foundation

- [x] **Task 1** — Monorepo root scaffold

**Prompt:**
```
Task 1: Create monorepo root per docs/PLAN.md §3 todo #1 — README.md, .gitignore, docker-compose.yml, .env.example, firebase/ rules stubs. MANDATORY: read .cursor/skills/ponytail/SKILL.md (Repo 1). Also read docs/PLAN.md, docs/LOG.md, skills/skills/doc-coauthoring/SKILL.md (Repo 2). Apply Ponytail YAGNI before done. Update docs/LOG.md. Mark Task 1 complete in docs/TASKS.md.
```

- [x] **Task 2** — Firebase setup documentation

**Prompt:**
```
Task 2: Write Firebase setup guide per docs/PLAN.md §5 todo #2. MANDATORY: read .cursor/skills/ponytail/SKILL.md (Repo 1). Also read docs/PLAN.md, docs/LOG.md, skills/skills/doc-coauthoring/SKILL.md (Repo 2). Apply Ponytail YAGNI before done. Update docs/LOG.md. Mark Task 2 complete in docs/TASKS.md.
```

---

## Phase 2 — Backend API (for Android app)

> REST API in `backend/` — consumed by `mobile/` via Dio. No web pages, no HTML.

- [x] **Task 3** — Backend scaffold

**Prompt:**
```
Task 3: Scaffold backend/ REST API (for mobile/ app) per docs/PLAN.md §6 todo #3. No web UI. MANDATORY: read .cursor/skills/ponytail/SKILL.md (Repo 1). Also read docs/PLAN.md, docs/LOG.md, skills/skills/doc-coauthoring/SKILL.md (Repo 2). Apply Ponytail YAGNI before done. Update docs/LOG.md. Mark Task 3 complete in docs/TASKS.md.
```

- [x] **Task 4** — Firestore repositories + Storage

**Prompt:**
```
Task 4: Implement repositories + storageService (data layer for mobile app auth/profile) per docs/PLAN.md §5.2 todo #4. MANDATORY: read .cursor/skills/ponytail/SKILL.md (Repo 1). Also read docs/PLAN.md, docs/LOG.md, skills/skills/doc-coauthoring/SKILL.md (Repo 2). Apply Ponytail YAGNI before done. Update docs/LOG.md. Mark Task 4 complete in docs/TASKS.md.
```

- [x] **Task 5** — Auth routes

**Prompt:**
```
Task 5: Auth API routes for mobile/ app per docs/PLAN.md §6.2 todo #5. JWT + bcrypt + OTP. JSON API only — no web UI. MANDATORY: read .cursor/skills/ponytail/SKILL.md (Repo 1). Also read docs/PLAN.md, docs/LOG.md, skills/skills/doc-coauthoring/SKILL.md (Repo 2). Apply Ponytail YAGNI before done. Update docs/LOG.md. Mark Task 5 complete in docs/TASKS.md.
```

- [x] **Task 6** — User routes

**Prompt:**
```
Task 6: User profile API routes for mobile/ app per docs/PLAN.md §6.2 todo #6. MANDATORY: read .cursor/skills/ponytail/SKILL.md (Repo 1). Also read docs/PLAN.md, docs/LOG.md, skills/skills/doc-coauthoring/SKILL.md (Repo 2). Apply Ponytail YAGNI before done. Update docs/LOG.md. Mark Task 6 complete in docs/TASKS.md.
```

- [x] **Task 7** — Validators, middleware, rate limits

**Prompt:**
```
Task 7: Joi, rateLimiter, Helmet, CORS per docs/PLAN.md §6.3–§6.5 todo #7. MANDATORY: read .cursor/skills/ponytail/SKILL.md (Repo 1). Also read docs/PLAN.md, docs/LOG.md, skills/skills/doc-coauthoring/SKILL.md (Repo 2). Apply Ponytail YAGNI before done. Update docs/LOG.md. Mark Task 7 complete in docs/TASKS.md.
```

- [x] **Task 8** — Backend tests

**Prompt:**
```
Task 8: Jest + Supertest auth tests per docs/PLAN.md §6.7 todo #7. MANDATORY: read .cursor/skills/ponytail/SKILL.md (Repo 1). Also read docs/PLAN.md, docs/LOG.md, skills/skills/webapp-testing/SKILL.md (Repo 2). Apply Ponytail YAGNI before done. Run tests. Update docs/LOG.md. Mark Task 8 complete in docs/TASKS.md.
```

- [x] **Task 8b** — ponytail-review backend

**Prompt:**
```
Review backend/ diff. MANDATORY: read .cursor/skills/ponytail/SKILL.md + .cursor/skills/ponytail-review/SKILL.md (Repo 1). Also read docs/PLAN.md, docs/LOG.md. Trim bloat from backend/. Update docs/LOG.md. Mark Task 8b complete in docs/TASKS.md.
```

---

## Phase 3 — ML API (for Android HQ capture)

> FastAPI in `ml-service/` — mobile/ uploads captures here for MODNet processing.

- [x] **Task 9** — ML scaffold

**Prompt:**
```
Task 9: Scaffold ml-service/ API (for mobile/ HQ capture) per docs/PLAN.md §7 todo #8. MANDATORY: read .cursor/skills/ponytail/SKILL.md (Repo 1). Also read docs/PLAN.md, docs/LOG.md, skills/skills/doc-coauthoring/SKILL.md (Repo 2). Apply Ponytail YAGNI before done. Update docs/LOG.md. Mark Task 9 complete in docs/TASKS.md.
```

- [x] **Task 10** — Inference pipeline

**Prompt:**
```
Task 10: MODNet pipeline per docs/PLAN.md §7.3–§7.6 todo #9. MANDATORY: read .cursor/skills/ponytail/SKILL.md (Repo 1). Also read docs/PLAN.md, docs/LOG.md, skills/skills/doc-coauthoring/SKILL.md (Repo 2). Apply Ponytail YAGNI before done. Update docs/LOG.md. Mark Task 10 complete in docs/TASKS.md.
```

- [x] **Task 11** — Benchmark + ML tests

**Prompt:**
```
Task 11: Benchmark + pytest per docs/PLAN.md §7.7 todo #10. MANDATORY: read .cursor/skills/ponytail/SKILL.md (Repo 1). Also read docs/PLAN.md, docs/LOG.md, skills/skills/webapp-testing/SKILL.md (Repo 2). Apply Ponytail YAGNI before done. Update docs/LOG.md. Mark Task 11 complete in docs/TASKS.md.
```

- [x] **Task 11b** — ponytail-review ML

**Prompt:**
```
Review ml-service/ diff. MANDATORY: read .cursor/skills/ponytail/SKILL.md + .cursor/skills/ponytail-review/SKILL.md (Repo 1). Also read docs/PLAN.md, docs/LOG.md. Trim bloat from ml-service/. Update docs/LOG.md. Mark Task 11b complete in docs/TASKS.md.
```

---

## Phase 4 — Android app (`mobile/`) — PRIMARY PRODUCT

> Flutter Android app users install. Repos 1 + 2 + 3 + 4 required.

- [x] **Task 12** — Flutter project scaffold

**Prompt:**
```
Task 12: Create mobile/ Android app per docs/PLAN.md §8 todo #11 — Riverpod, go_router, Material 3, api_client (Dio → backend/), secure_storage. MANDATORY: read .cursor/skills/ponytail/SKILL.md (Repo 1). Also read docs/PLAN.md, docs/LOG.md, skills/skills/frontend-design/SKILL.md (Repo 2), flutter-skills/skills/flutter-setup-declarative-routing/SKILL.md + flutter-apply-architecture-best-practices/SKILL.md + flutter-implement-json-serialization/SKILL.md + flutter-use-http-package/SKILL.md (Repo 3), dart-skills/skills/dart-run-static-analysis/SKILL.md + dart-use-primary-constructors/SKILL.md + dart-use-pattern-matching/SKILL.md + dart-resolve-package-conflicts/SKILL.md (Repo 4). Use Dio not http. Apply Ponytail YAGNI before done. Update docs/LOG.md. Mark Task 12 complete in docs/TASKS.md.
```

- [x] **Task 13** — Auth screens + repository

**Prompt:**
```
Task 13: Auth feature per docs/PLAN.md §8.4.1–§8.4.5 todo #12. MANDATORY: read .cursor/skills/ponytail/SKILL.md (Repo 1). Also read docs/PLAN.md, docs/LOG.md, skills/skills/frontend-design/SKILL.md (Repo 2), flutter-skills/skills/flutter-apply-architecture-best-practices/SKILL.md + flutter-implement-json-serialization/SKILL.md (Repo 3), dart-skills/skills/dart-use-primary-constructors/SKILL.md + dart-use-pattern-matching/SKILL.md + dart-run-static-analysis/SKILL.md (Repo 4). Apply Ponytail YAGNI before done. Update docs/LOG.md. Mark Task 13 complete in docs/TASKS.md.
```

- [x] **Task 14** — Home, Profile, Settings

**Prompt:**
```
Task 14: Home/Profile/Settings per docs/PLAN.md §8.4.6–§8.4.9 todo #13. MANDATORY: read .cursor/skills/ponytail/SKILL.md (Repo 1). Also read docs/PLAN.md, docs/LOG.md, skills/skills/frontend-design/SKILL.md + theme-factory/SKILL.md (Repo 2), flutter-skills/skills/flutter-build-responsive-layout/SKILL.md (Repo 3), dart-skills/skills/dart-run-static-analysis/SKILL.md (Repo 4). Apply Ponytail YAGNI before done. Update docs/LOG.md. Mark Task 14 complete in docs/TASKS.md.
```

- [x] **Task 15** — Camera + on-device ML

**Prompt:**
```
Task 15: Camera + ML Kit per docs/PLAN.md §8.4.7 + §8.5 todo #14. MANDATORY: read .cursor/skills/ponytail/SKILL.md (Repo 1). Also read docs/PLAN.md, docs/LOG.md, skills/skills/frontend-design/SKILL.md (Repo 2), flutter-skills/skills/flutter-fix-layout-issues/SKILL.md (Repo 3), dart-skills/skills/dart-fix-runtime-errors/SKILL.md + dart-run-static-analysis/SKILL.md (Repo 4). Apply Ponytail YAGNI before done. Update docs/LOG.md. Mark Task 15 complete in docs/TASKS.md.
```

- [x] **Task 16** — HQ capture

**Prompt:**
```
Task 16: HQ capture per docs/PLAN.md §8.6 todo #15. MANDATORY: read .cursor/skills/ponytail/SKILL.md (Repo 1). Also read docs/PLAN.md, docs/LOG.md, skills/skills/frontend-design/SKILL.md (Repo 2), flutter-skills/skills/flutter-use-http-package/SKILL.md (Repo 3), dart-skills/skills/dart-run-static-analysis/SKILL.md (Repo 4). Apply Ponytail YAGNI before done. Update docs/LOG.md. Mark Task 16 complete in docs/TASKS.md.
```

- [x] **Task 16b** — ponytail-review Flutter

**Prompt:**
```
Review mobile/ diff. MANDATORY: read .cursor/skills/ponytail/SKILL.md + .cursor/skills/ponytail-review/SKILL.md (Repo 1). Also read docs/PLAN.md, docs/LOG.md, skills/skills/frontend-design/SKILL.md (Repo 2). Trim bloat from mobile/. Update docs/LOG.md. Mark Task 16b complete in docs/TASKS.md.
```

---

## Phase 5 — Tests + Docs

- [x] **Task 17** — Flutter tests

**Prompt:**
```
Task 17: Flutter tests per docs/PLAN.md §8.8 todo #16. MANDATORY: read .cursor/skills/ponytail/SKILL.md (Repo 1). Also read docs/PLAN.md, docs/LOG.md, skills/skills/webapp-testing/SKILL.md (Repo 2), flutter-skills/skills/flutter-add-widget-test/SKILL.md + flutter-add-integration-test/SKILL.md (Repo 3), dart-skills/skills/dart-add-unit-test/SKILL.md + dart-generate-test-mocks/SKILL.md + dart-collect-coverage/SKILL.md + dart-run-static-analysis/SKILL.md (Repo 4). Run flutter test. Apply Ponytail YAGNI before done. Update docs/LOG.md. Mark Task 17 complete in docs/TASKS.md.
```

- [x] **Task 18** — API.md

**Prompt:**
```
Task 18: Write docs/API.md per docs/PLAN.md §11.1. MANDATORY: read .cursor/skills/ponytail/SKILL.md (Repo 1). Also read docs/PLAN.md, docs/LOG.md, skills/skills/doc-coauthoring/SKILL.md (Repo 2). Apply Ponytail YAGNI before done. Update docs/LOG.md. Mark Task 18 complete in docs/TASKS.md.
```

- [x] **Task 19** — INSTALLATION + c

**Prompt:**
```
Task 19: Write docs/INSTALLATION.md + DEPLOYMENT.md per docs/PLAN.md §11.2–§11.3. MANDATORY: read .cursor/skills/ponytail/SKILL.md (Repo 1). Also read docs/PLAN.md, docs/LOG.md, skills/skills/doc-coauthoring/SKILL.md (Repo 2). Apply Ponytail YAGNI before done. Update docs/LOG.md. Mark Task 19 complete in docs/TASKS.md.
```

- [x] **Task 20** — Final README + security verify

**Prompt:**
```
Task 20: Root README + verify docs/PLAN.md §10 security checklist. Run all tests. MANDATORY: read .cursor/skills/ponytail/SKILL.md (Repo 1). Also read docs/PLAN.md, docs/LOG.md, skills/skills/doc-coauthoring/SKILL.md (Repo 2). Apply Ponytail YAGNI before done. Update docs/LOG.md. Mark Task 20 complete in docs/TASKS.md.
```

- [x] **Task 20b** — ponytail-audit

**Prompt:**
```
Final repo audit. MANDATORY: read .cursor/skills/ponytail/SKILL.md + .cursor/skills/ponytail-audit/SKILL.md (Repo 1). Also read docs/PLAN.md, docs/LOG.md. Trim all over-engineering. Update docs/LOG.md. Mark Task 20b complete in docs/TASKS.md.
```

---

## Skill Reference — All 4 Repos (PLAN §0.3)

| Task | Repo 1 | Repo 2 | Repo 3 Flutter | Repo 4 Dart |
|------|--------|--------|----------------|-------------|
| 0–0b | ponytail | skill-creator | — | — |
| 1–7, 9–10, 18–20 | ponytail | doc-coauthoring | — | — |
| 8, 11 | ponytail | webapp-testing | — | — |
| 12 | ponytail | frontend-design | routing, architecture, json, http | static-analysis, constructors, patterns, pub conflicts |
| 13 | ponytail | frontend-design | architecture, json | constructors, patterns, static-analysis |
| 14 | ponytail | frontend-design, theme | responsive-layout | static-analysis |
| 15 | ponytail | frontend-design | fix-layout | fix-runtime-errors, static-analysis |
| 16 | ponytail | frontend-design | http-package | static-analysis |
| 17 | ponytail | webapp-testing | widget-test, integration-test | unit-test, mocks, coverage, static-analysis |
| 8b, 11b, 16b | ponytail + ponytail-review | — | — | — |
| 20b | ponytail + ponytail-audit | — | — | — |

---

## Progress

| Phase | Done | Delivers |
|-------|------|----------|
| 0 Setup | 3/3 | Agent skills |
| 1 Foundation | 2/2 | Monorepo + Firebase docs |
| 2 Backend API (for app) | 7/7 | REST API → mobile/ calls this |
| 3 ML API (for app) | 4/4 | HQ capture API → mobile/ calls this |
| 4 **Android app** | 6/6 | **Primary product** — `mobile/` |
| 5 Tests + Docs | 5/5 | Ship-ready |
| **Total** | **27/27** |

**Next:** Phase 1 complete. Optional: [TASKS2.md](TASKS2.md) — custom model training (Tasks 21–31).
