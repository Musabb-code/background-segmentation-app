# MACKHAN — Agent Instructions

> **Product:** Flutter **Android mobile app** (`mobile/`) — real-time background removal  
> **Supporting services:** `backend/` (Express API for the app) · `ml-service/` (HQ ML) · Firebase (data)  
> **Tasks:** [docs/TASKS.md](../docs/TASKS.md)  
> **ONLY blueprint:** [docs/PLAN.md](../docs/PLAN.md) — **never go outside §0–§13**  
> **Memory:** [docs/LOG.md](../docs/LOG.md)  
> **Full workflow:** [cloude/CLAUDE.md](cloude/CLAUDE.md)  
> **Home:** this folder = all agent/skills tooling (`agent/`)

---

## What we are building

**MACKHAN is a Flutter Android app.** Users install the APK and use the camera with live background removal.

The monorepo also contains **servers the app talks to over HTTP** — not separate products:

| Folder | Why it exists |
|--------|----------------|
| `mobile/` | **The app** — screens, camera, on-device ML Kit, calls backend API |
| `backend/server.js` | **REST API** for login, register, profile — mobile app is the client |
| `ml-service/` | **ML API** for high-quality capture uploads from the app |
| `firebase/` | Firestore + Storage — accessed by backend Admin SDK, not by the app directly |

Do **not** build a web frontend, admin dashboard, or iOS app. Do **not** skip `backend/` — the Android app needs it for auth and profiles per PLAN.md §6–§8.

---

## Mandatory — 4 repos + PLAN.md boundary

**Do not build outside `docs/PLAN.md`.** Read SKILL.md from each applicable repo before coding.

| Repo | When |
|------|------|
| 1 Ponytail | **Every task — mandatory, never skip** |
| 2 Anthropic | Per TASKS.md table |
| 3 Flutter | Tasks 12–17 |
| 4 Dart | Tasks 12–17 |

1. **Read `docs/PLAN.md`** — find section + todo; **refuse anything outside §0–§13**
2. **Read `docs/TASKS.md`** — pick the next unchecked task
3. **Read `docs/LOG.md`** — check history and current next step
4. **Read Ponytail `SKILL.md`** — `.cursor/skills/ponytail/SKILL.md` (Repo 1, always)
5. **Read Anthropic / Flutter / Dart `SKILL.md`** — per TASKS.md (Repos 2–4)
6. **Write code** — exactly what PLAN.md specifies
7. **Apply Ponytail YAGNI** — can this diff be shorter? (mandatory before done)
8. **Update `docs/LOG.md`** + check off `docs/TASKS.md`

PLAN.md = what to build (mandatory boundary). LOG.md = memory. **Ponytail = mandatory on every task.** Other repos = per TASKS.md.

This project uses [Ponytail](https://github.com/DietrichGebert/ponytail) (`agent/ponytail/` + `.cursor/rules/ponytail.mdc`). Before writing code, climb the YAGNI ladder:

1. Does this need to exist? → skip if no
2. Already in this codebase? → reuse
3. Stdlib covers it? → use stdlib
4. Native platform feature? → use it
5. Installed dependency? → use it
6. One line? → one line
7. Only then: minimum code that works

**Never cut:** validation at trust boundaries, error handling, security (JWT, bcrypt, Firestore rules), accessibility, anything explicitly requested in PLAN.md.

**Always cut:** unrequested abstractions, new dependencies, boilerplate, speculative flexibility.

After every change, ask: *can this diff be shorter?* Use `/ponytail-review` skill to audit over-engineering.

---

## Project context

| Layer | Stack | Path | Notes |
|-------|-------|------|-------|
| **Mobile (primary)** | Flutter, Riverpod, ML Kit, TFLite | `mobile/` | Android app — main deliverable |
| Backend API | Node.js, Express, Firebase Admin, JWT | `backend/` | Serves the mobile app via REST |
| ML API | Python, FastAPI, MODNet | `ml-service/` | HQ capture from mobile uploads |
| Infra | Firebase Firestore + Storage, Docker Compose | `firebase/`, root | Backend-only data access |

**Before scaffolding:** read [docs/PLAN.md](../docs/PLAN.md) for file structure, API contracts, and security checklist.

---

## Skills to use

| When | Skill | Location |
|------|-------|----------|
| Any coding task | ponytail | `.cursor/skills/ponytail/` |
| Review diff for bloat | ponytail-review | `.cursor/skills/ponytail-review/` |
| Audit whole repo | ponytail-audit | `.cursor/skills/ponytail-audit/` |
| Flutter UI design | frontend-design | `skills/skills/frontend-design/` (under `agent/`) |
| Write docs | doc-coauthoring | `skills/skills/doc-coauthoring/` |
| API/integration tests | webapp-testing | `skills/skills/webapp-testing/` |

Full skill index: [CLOUDE.md](CLOUDE.md) · [cloude/CLAUDE.md](cloude/CLAUDE.md)

---

## MACKHAN-specific rules

1. **Minimal scope** — one PLAN.md todo at a time; smallest diff that satisfies the spec.
2. **Reuse patterns** — same repository/middleware/error format across backend routes.
3. **Security first** — bcrypt cost 12, JWT secrets in env, Firestore deny-all client rules, ML service validates JWT.
4. **Log steps** — append completed work to [docs/LOG.md](../docs/LOG.md).
5. **No over-build** — e.g. use ML Kit native segmentation before custom TFLite pipeline; use Express built-ins before new middleware libraries.
