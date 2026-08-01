# CLAUDE — Agent Guide for MACKHAN Development

> **Project:** Real-Time Background Removal (MACKHAN monorepo)  
> **ONLY blueprint:** [docs/PLAN.md](../docs/PLAN.md) — **never go outside §0–§13**  
> **Tasks:** [docs/TASKS.md](../docs/TASKS.md) · **Memory:** [docs/LOG.md](../docs/LOG.md)  
> **Repo 1 — Ponytail:** [ponytail/](../ponytail/) — minimum code on every change  
> **Repo 2 — Anthropic Skills:** [skills/](../skills/) — task-specific instructions  
> **Hub:** [CLOUDE.md](../CLOUDE.md)

---

## MANDATORY — Before You Write Any Code

**Four repos required for HOW we code. Ponytail (Repo 1) is mandatory on EVERY task. PLAN.md defines WHAT — never go outside it.**

```
┌─────────────────────────────────────────────────────────────┐
│  STEP 1 — READ PLAN.md (MANDATORY BOUNDARY)                 │
│  Open docs/PLAN.md §0 + matching section + todo.            │
│  If task is NOT in plan → STOP. Do not build.               │
│  §14 Post-MVP = forbidden until plan is updated.             │
└──────────────────────────┬──────────────────────────────────┘
                           ▼
┌─────────────────────────────────────────────────────────────┐
│  STEP 2 — READ LOG.md                                       │
│  Open docs/LOG.md. Check what is done, what is next,        │
│  last decisions, and skill usage history.                     │
└──────────────────────────┬──────────────────────────────────┘
                           ▼
┌─────────────────────────────────────────────────────────────┐
│  STEP 3 — READ PONYTAIL SKILL.md (Repo 1 — always)          │
│  Read: .cursor/skills/ponytail/SKILL.md                     │
│  Or:   ponytail/skills/ponytail/SKILL.md                    │
│  Rule: YAGNI ladder — minimum code, never cut security.     │
└──────────────────────────┬──────────────────────────────────┘
                           ▼
┌─────────────────────────────────────────────────────────────┐
│  STEP 4 — READ ANTHROPIC SKILL.md (Repo 2 — PLAN §0.3 only) │
│  Allowed: doc-coauthoring, frontend-design, theme-factory,  │
│           webapp-testing, skill-creator                      │
│  Read: skills/skills/{name}/SKILL.md — FULL file.           │
│  Forbidden: all other skills (see PLAN.md §0.3).            │
└──────────────────────────┬──────────────────────────────────┘
                           ▼
┌─────────────────────────────────────────────────────────────┐
│  STEP 5 — WRITE CODE (according to PLAN.md)                 │
│  Match PLAN.md file structure, APIs, and security checklist.│
│  Apply Ponytail YAGNI ladder. Follow Anthropic skill steps. │
└──────────────────────────┬──────────────────────────────────┘
                           ▼
┌─────────────────────────────────────────────────────────────┐
│  STEP 6 — UPDATE LOG.md (MANDATORY after every task)         │
│  Append new step entry. Update Skill Usage Tracker.         │
│  Mark PLAN.md todo done if completed. Set "Next" field.     │
└─────────────────────────────────────────────────────────────┘
```

### What each file is

| File | Role | Mandatory? |
|------|------|------------|
| `docs/PLAN.md` | **Blueprint** — what to build, how, where | **Yes — read every task** |
| `docs/LOG.md` | **Memory + history** — what is done, what is next, decisions | **Yes — read + update every task** |
| `agent/ponytail/` (Repo 1) | **How to write code** — minimum, lazy, safe | **Yes — every task, no exceptions** |
| `agent/skills/` (Repo 2) | **How to do specialized tasks** — UI, docs, tests | **Yes — when task matches a skill** |

**PLAN.md = what to build. LOG.md = project memory. Ponytail (Repo 1) = mandatory every task. Repos 2–4 = per TASKS.md.**

---

## Current Next Plan (from PLAN.md + LOG.md)

> Update this block in LOG.md when a step completes.

| # | Next action | PLAN.md todo | Skills to read first |
|---|-------------|--------------|----------------------|
| **1** | Create monorepo root: README, .gitignore, docker-compose.yml, docs/, root .env.example | Todo #1 | ponytail + doc-coauthoring |
| 2 | Document Firebase setup (Firestore, indexes, rules, Storage) | Todo #2 | ponytail + doc-coauthoring |
| 3 | Scaffold `backend/` Express server | Todo #3 | ponytail |
| 4 | Scaffold `ml-service/` FastAPI | Todo #8 | ponytail |
| 5 | Copy Anthropic skills to `.cursor/skills/` (frontend-design, doc-coauthoring, webapp-testing) | — | skill-creator |

**Active step:** #1 — Monorepo scaffold

---

## 0. Ponytail — Repo 1 (Always Required)

[Ponytail](https://github.com/DietrichGebert/ponytail) is **always active** in Cursor (`.cursor/rules/ponytail.mdc`). It chunks/minimizes code by running the YAGNI ladder before every write:

```
1. Need to exist?     → skip
2. Already in repo?   → reuse
3. Stdlib?            → use it
4. Native platform?   → use it
5. Installed dep?     → use it
6. One line?          → one line
7. Minimum that works → only then write
```

**Never skip:** JWT validation, bcrypt, Firestore security, error handling, accessibility, PLAN.md requirements.

| Ponytail skill | Path | Use when |
|----------------|------|----------|
| ponytail | `.cursor/skills/ponytail/` | Any coding task; say "be lazy" or "yagni" |
| ponytail-review | `.cursor/skills/ponytail-review/` | After a feature — trim the diff |
| ponytail-audit | `.cursor/skills/ponytail-audit/` | Before major refactor — find repo bloat |
| ponytail-debt | `.cursor/skills/ponytail-debt/` | Track deferred shortcuts |
| ponytail-help | `.cursor/skills/ponytail-help/` | Command reference |

Full ponytail source: `ponytail/` (v4.8.4)  
**Before coding:** always read `ponytail/skills/ponytail/SKILL.md` or `.cursor/skills/ponytail/SKILL.md`

---

## 1. Anthropic Skills — Repo 2 (Required When Task Matches)

MACKHAN is a Flutter Android + Node.js/Express + Python FastAPI + Firebase monorepo. The `skills/` folder is a vendored copy of [anthropics/skills](https://github.com/anthropics/skills).

**Before starting any specialized task, read the full `SKILL.md` in the matching skill folder.** Do not write code from memory — read the file first.

---

## 2. How to Activate a Skill in Cursor

| Method | When to use |
|--------|-------------|
| **Automatic** | Cursor loads skills whose `description` matches the task (project skills in `.cursor/skills/` or personal skills in `~/.cursor/skills/`) |
| **Explicit** | Say: *"Use the `{skill-name}` skill from `skills/skills/{skill-name}/`"* |
| **Copy to project** | Copy a skill folder to `.cursor/skills/{skill-name}/` for team-wide use |

Recommended project skills to copy first (highest value for MACKHAN):

```
skills/skills/frontend-design   → .cursor/skills/frontend-design
skills/skills/doc-coauthoring   → .cursor/skills/doc-coauthoring
skills/skills/webapp-testing    → .cursor/skills/webapp-testing
skills/skills/skill-creator     → .cursor/skills/skill-creator
skills/skills/mcp-builder       → .cursor/skills/mcp-builder
```

---

## 3. Allowed Skills Only (PLAN.md §0.3)

**Do not use any skill not in this table.** Full catalog in other files is reference only — PLAN.md is the allowlist.

| Skill | Path | Use in MACKHAN | PLAN section |
|-------|------|----------------|--------------|
| **ponytail** | `.cursor/skills/ponytail/` | Every coding task | All |
| **ponytail-review** | `.cursor/skills/ponytail-review/` | After each feature | — |
| **ponytail-audit** | `.cursor/skills/ponytail-audit/` | Final audit | — |
| **doc-coauthoring** | `agent/skills/skills/doc-coauthoring/` | README, API.md, INSTALLATION.md, DEPLOYMENT.md | §11 |
| **frontend-design** | `agent/skills/skills/frontend-design/` | Flutter UI screens | §8.4 |
| **theme-factory** | `agent/skills/skills/theme-factory/` | Material 3 light/dark theme | §8 theme |
| **webapp-testing** | `agent/skills/skills/webapp-testing/` | Jest, pytest, Flutter tests | §6.7, §7.7, §8.8 |
| **skill-creator** | `agent/skills/skills/skill-creator/` | Copy allowed skills to `.cursor/skills/` | §0.3 |

### Forbidden skills (outside plan)

claude-api, mcp-builder, pdf, docx, pptx, xlsx, canvas-design, algorithmic-art, brand-guidelines, internal-comms, slack-gif-creator, web-artifacts-builder — **do not use** unless PLAN.md §0.3 is updated.

---

## 4. Skill → Implementation Phase Matrix (PLAN §12)

Use this during each build phase from PLAN.md §12:

| Phase | Primary skills | Task examples |
|-------|----------------|---------------|
| **1 — Foundation** | doc-coauthoring | Monorepo README, `.gitignore`, docker-compose |
| **2 — Firebase docs** | doc-coauthoring | Firestore rules guide |
| **3 — Backend** | doc-coauthoring | Express scaffold, routes |
| **4 — ML service** | doc-coauthoring | FastAPI, inference pipeline |
| **5 — Flutter scaffold** | frontend-design, theme-factory | Router, theme, auth layouts |
| **6 — Auth screens** | frontend-design | Login, register, OTP flows |
| **7 — Home / Profile / Settings** | frontend-design | Profile UI, settings |
| **8 — Camera + on-device ML** | frontend-design | Camera UI, segmentation painter |
| **9 — HQ capture** | frontend-design | ML upload + fallback |
| **10 — Tests & docs** | webapp-testing, doc-coauthoring | Tests, API.md, INSTALLATION.md |

---

## 5. Agent Rules — All Mandatory

1. **PLAN.md is the boundary** — never build outside §0–§13; refuse §14 and unlisted features.
2. **Read PLAN.md** — every task. Find section + todo. Code must match exactly.
3. **Read LOG.md** — every task. Know history; never repeat completed work.
4. **Read Ponytail SKILL.md** — every coding task (Repo 1).
5. **Read Anthropic SKILL.md** — only PLAN §0.3 allowed skills (Repo 2).
6. **Update LOG.md** — after every task.
7. **Check TASKS.md** — mark complete.
8. **Ponytail-review** — after each feature.
9. **Minimal diffs** — match §3 file structure only.
10. **Security never cut** — JWT, bcrypt, Firestore rules per §10.

---

## 6. Creating MACKHAN-Specific Skills

Use `skills/skills/skill-creator/SKILL.md` and `skills/template/SKILL.md` as templates.

Suggested custom skills for `.cursor/skills/`:

| Skill name | Trigger | Purpose |
|------------|---------|---------|
| `mackhan-firebase-setup` | Firebase, Firestore, Storage rules | Console steps from PLAN §5 |
| `mackhan-express-auth` | JWT, bcrypt, OTP, Nodemailer | Auth route patterns from PLAN §6 |
| `mackhan-modnet-inference` | MODNet, segment, FastAPI ML | Inference pipeline from PLAN §7 |
| `mackhan-flutter-camera-ml` | ML Kit, TFLite, camera stream | On-device ML from PLAN §8.5 |
| `mackhan-api-docs` | API.md, curl examples | Endpoint documentation from PLAN §6.2 |

Spec reference: `skills/spec/agent-skills-spec.md`

---

## 7. Quick Reference — Skill Trigger Phrases

| Say this… | Skill activated |
|-----------|-----------------|
| "Be lazy" / "yagni" / "minimal solution" | ponytail |
| "Review for over-engineering" | ponytail-review |
| "Audit the repo for bloat" | ponytail-audit |
| "Design the login screen" | frontend-design |
| "Write API.md with curl examples" | doc-coauthoring |
| "Create a benchmark results spreadsheet" | xlsx |
| "Build an MCP server for Firebase" | mcp-builder |
| "Make a deployment runbook PDF" | pdf + doc-coauthoring |
| "Create a MACKHAN Cursor skill for auth" | skill-creator |
| "Test the backend with Playwright" | webapp-testing |
| "Define app light/dark theme colors" | theme-factory + frontend-design |

---

## 8. Related Files

| File | Purpose |
|------|---------|
| [docs/TASKS.md](../docs/TASKS.md) | Task file — copy prompts one by one |
| [AGENTS.md](../AGENTS.md) | Root agent instructions (Ponytail + MACKHAN) |
| [CLOUDE.md](../CLOUDE.md) | Project overview and skills index |
| [docs/PLAN.md](../docs/PLAN.md) | Full implementation specification |
| [docs/LOG.md](../docs/LOG.md) | Step-by-step development history |
| [ponytail/README.md](../ponytail/README.md) | Upstream Ponytail README |
| [skills/README.md](../skills/README.md) | Upstream Anthropic skills README |
| [skills/spec/agent-skills-spec.md](../skills/spec/agent-skills-spec.md) | Agent Skills standard |
