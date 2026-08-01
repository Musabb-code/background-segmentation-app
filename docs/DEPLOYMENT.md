# MACKHAN — Deployment

Ship the Android app and the HTTP services it calls. Local setup: [INSTALLATION.md](INSTALLATION.md). APIs: [API.md](API.md).

| Component | Platform | Summary |
|-----------|----------|---------|
| Backend | Render / Railway / AWS EC2 | Env vars, `node server.js`, health `/api/health` |
| ML Service | Railway / EC2 + Docker | Build image, mount `models/`, GPU optional |
| Firebase | Google Cloud | Prod Firestore + Storage; service account on server |
| Android APK | Local / CI | `flutter build apk --release`, signing keystore |

---

## Backend (Render / Railway / EC2)

1. Set production env from `backend/.env.example`: `NODE_ENV=production`, strong `JWT_SECRET` / `JWT_REFRESH_SECRET`, Firebase credentials (file or env vars), SMTP_*, `CLIENT_URL`, `ML_SERVICE_URL` (public ML URL).
2. Deploy Node 20: `npm ci --omit=dev` then `npm start` (`node server.js`). Port: `PORT` (default 3000).
3. Health check: `GET /api/health`.
4. Terminate TLS at the platform or reverse proxy (HTTPS required in production).

**EC2 sketch:** install Node 20, clone repo, copy env + service account, `npm ci --omit=dev`, run under systemd/pm2 listening on `PORT`.

---

## ML service (Railway / EC2 + Docker)

Image: [`ml-service/Dockerfile`](../ml-service/Dockerfile) (Python 3.11, uvicorn `:8000`).

```bash
cd ml-service
docker build -t mackhan-ml .
docker run -d --env-file .env -p 8000:8000 -v /path/to/models:/app/models mackhan-ml
```

- Mount real MODNet SavedModel at `/app/models/modnet` (same layout as local `models/modnet/`).
- Set `JWT_SECRET` to match backend.
- Health: `GET /health`.
- GPU optional: use a CUDA base image / host NVIDIA runtime when CPU latency is too high; default image is CPU.

Railway: connect the `ml-service/` directory, set env vars, attach a volume for weights if the platform supports it.

---

## Firebase (Google Cloud)

1. Use a dedicated production Firebase project (not the dev project).
2. Deploy [`firebase/firestore.rules`](../firebase/firestore.rules), [`firebase/storage.rules`](../firebase/storage.rules), and indexes from [`firebase/firestore.indexes.json`](../firebase/firestore.indexes.json).
3. Put the production service account on the backend host only (`serviceAccountKey.json` or env vars). Never ship it in the APK.
4. Confirm Storage bucket name matches `FIREBASE_STORAGE_BUCKET`.

---

## Android APK (release)

1. Create an upload keystore (once):

```bash
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

2. Configure signing in `android/key.properties` (gitignored) per [Flutter signing docs](https://docs.flutter.dev/deployment/android).
3. Point the app at production APIs:

```bash
cd mobile
flutter build apk --release \
  --dart-define=API_BASE_URL=https://api.yourdomain.com \
  --dart-define=ML_SERVICE_URL=https://ml.yourdomain.com
```

Output: `build/app/outputs/flutter-apk/app-release.apk`.

CI: same command on a Linux/macOS runner with Flutter + Android SDK; store keystore + passwords in CI secrets.

---

## Post-deploy checks

- [ ] `GET https://…/api/health` and `GET https://…/health` succeed
- [ ] Register / verify / login against production backend
- [ ] Profile image upload reaches Firebase Storage
- [ ] Release APK HQ capture reaches ML with a valid JWT
