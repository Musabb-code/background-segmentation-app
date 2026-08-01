# Agent tooling (not product code)

Everything in this folder is for **Cursor / AI agents** — skills repos, workflow docs, Ponytail.

| Path | Role |
|------|------|
| `AGENTS.md` | Short agent rules |
| `CLOUDE.md` | Skills hub index |
| `cloude/CLAUDE.md` | Full workflow |
| `ponytail/` | Repo 1 — YAGNI / minimum code |
| `skills/` | Repo 2 — Anthropic skills |
| `flutter-skills/` | Repo 3 — Flutter skills |
| `dart-skills/` | Repo 4 — Dart skills |

**Product app** is one level up: `../mobile/`, `../backend/`, `../ml-service/`, `../firebase/`, `../docs/`.

**Active Cursor skills** stay at `../.cursor/skills/` (IDE path). Source copies of skill repos live here; when a task says “read SKILL.md”, prefer `.cursor/skills/{name}/SKILL.md` if present, else the matching path under this folder.
