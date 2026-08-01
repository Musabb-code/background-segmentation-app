# Pixel Lift (background-segmentation-app)

**Repo:** https://github.com/Musabb-code/background-segmentation-app  

**Primary product:** Flutter Android app in `mobile/` — live camera background removal (Pixel Lift), auth, profile.

Supporting HTTP APIs (called by the app; not websites):

| Path | Role |
|------|------|
| `mobile/` | **Android app** — Riverpod, ML Kit, Dio |
| `backend/` | Express REST — auth, users, JWT |
| `ml-service/` | FastAPI MODNet — HQ capture |
| `firebase/` | Firestore + Storage rules (Admin SDK only) |

**Stack:** Flutter Android · Express · FastAPI · Firebase · Riverpod · JWT

## Quick start

Full steps: [docs/INSTALLATION.md](docs/INSTALLATION.md). Deploy: [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md).

```powershell
# Env
copy backend\.env.example backend\.env
copy ml-service\.env.example ml-service\.env
copy mobile\assets\.env.example mobile\assets\.env

# Backend (Node 20+)
cd backend; npm install; npm run dev

# ML (Python 3.11)
cd ml-service
python -m venv .venv; .\.venv\Scripts\Activate.ps1
python -m pip install -r requirements.txt
python scripts/download_model.py
python -m uvicorn main:app --reload --host 0.0.0.0 --port 8000

# App
cd mobile
flutter create . --platforms=android
flutter pub get
flutter run
```

Optional ML container: `docker compose up --build` (see `docker-compose.yml`).

## Docs

| Doc | Contents |
|-----|----------|
| [docs/PLAN.md](docs/PLAN.md) | Blueprint (§0–§13 only) |
| [docs/PIXEL_LIFT_PLAN.md](docs/PIXEL_LIFT_PLAN.md) | Branding / modes / accuracy plan |
| [docs/API.md](docs/API.md) | Backend + ML endpoints |
| [docs/INSTALLATION.md](docs/INSTALLATION.md) | Local setup |
| [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md) | Production |
| [docs/TASKS.md](docs/TASKS.md) | Build checklist |
| [docs/LOG.md](docs/LOG.md) | Dev history |
| [agent/](agent/) | AI agent / skills tooling (not app code) |

## Security (PLAN §10)

Verified in code: bcrypt cost 12, JWT secrets ≥32 chars (env), refresh tokens SHA-256 hashed, Firestore deny-all client rules, profile upload MIME+5MB, Helmet, CORS to `CLIENT_URL`, auth rate limits, OTP 10min + delete-on-use, generic forgot-password, ML JWT on inference, `serviceAccountKey.json` gitignored, Flutter tokens in `flutter_secure_storage`. Production HTTPS: terminate TLS at the host (see DEPLOYMENT).

## Tests

```powershell
cd backend; npm test
cd ml-service; pytest          # needs Python 3.11 + tensorflow
cd mobile; flutter test
```
