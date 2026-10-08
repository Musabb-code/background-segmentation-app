# Pixel Lift — Full deploy plan (no cloud HQ / no ML service)

> **Goal:** App works on **any phone** with **Wi‑Fi or mobile data** — **login, profile, live camera, gallery, batch** — **without your PC** and **without hosting MODNet**.  
> **Skipped by choice:** Cloud **ML service** (HQ “Studio quality” capture). **Capture / gallery still work** via **Quick (on device)** fallback.  
> **Cost target:** **$0–$7/month** (Firebase free + Render/Railway free or cheap backend). **No VPS required.**

**Roles:** **YOU** = accounts, secrets, clicks in dashboards, install APK on phones. **AI (Cursor)** = repo files, build commands, env templates, small code fixes if something blocks deploy.

**Your checklist (after AI prep):** [YOU_DEPLOY_STEPS.md](YOU_DEPLOY_STEPS.md)

### AI prep completed (in repo)

| Item | Path |
|------|------|
| Render blueprint | `render.yaml` |
| Railway config | `backend/railway.toml`, `backend/Procfile` |
| Render env template | `backend/.env.render.example` |
| Trust proxy (production) | `backend/server.js` |
| Node 20 engines | `backend/package.json` |
| Skip cloud ML in APK | `deploy_config.dart` + `ML_CLOUD_ENABLED=false` in build script |
| Production APK script | `scripts/build-production-apk.ps1` |

---

## 0. What gets deployed (picture)

```text
[Android phone]  ──HTTPS──►  [Backend on Render/Railway]  ──►  [Firebase Firestore + Storage]
     │                              │
     │ ML Kit / on-device           │ (no ML server in this plan)
     ▼                              │
 Live + Gallery + Capture           OTP email (SMTP)
         "Quick" only
```

| Feature | Works after deploy? |
|---------|---------------------|
| Register / login / profile | Yes (needs backend + Firebase + SMTP for new signups) |
| Live background removal | Yes (on phone, no server) |
| Gallery / batch / product white JPG | Yes (on-device segmentation) |
| Capture button | Yes → always **Quick (on device)** (no Studio/cloud) |
| USB + `adb reverse` | **Not needed** for login |

---

## 1. Decisions (YOU — 10 minutes)

| # | Decision | Recommendation |
|---|----------|----------------|
| 1 | Hosting for backend | **Render** (free tier OK for demo; sleeps when idle) or **Railway** |
| 2 | Firebase | **Keep current project** (`pixel-lift-423b5` style) unless you want prod isolation |
| 3 | Custom domain | **Skip** — use `https://your-app.onrender.com` |
| 4 | Play Store | **Skip for viva** — share **release APK** file |
| 5 | ML service | **Do not deploy** (this plan) |

Tell AI: **“Deploy backend on Render”** (or Railway) + **“no ML”**.

---

## 2. Prerequisites checklist

### YOU already need (no purchase for basic deploy)

- [ ] GitHub repo with this project (public or private)
- [ ] Firebase project + `backend/serviceAccountKey.json` (or env vars) — **already in your setup**
- [ ] Node 20 + Flutter on PC **only to build the APK** (not to run servers 24/7)
- [ ] **Render.com** or **Railway.app** account (free signup)

### YOU may need (production signup flow)

- [ ] **SMTP** for OTP emails (e.g. Gmail **App Password**) — **required** if examiners **register new emails** on the deployed app. Existing accounts from §1 in [CONNECTING_PROCESS.md](CONNECTING_PROCESS.md) still work without new OTP.

### NOT needed in this plan

- [ ] Paid VPS  
- [ ] Cloud ML / MODNet hosting  
- [ ] Domain purchase  
- [ ] Google Play $25 (unless publishing to Play)

---

## 3. Phase A — Firebase (YOU)

| Step | Action | Why |
|------|--------|-----|
| A1 | [Firebase Console](https://console.firebase.google.com) → your project | Backend stores users here |
| A2 | Firestore + Storage **enabled** | Auth data + profile images |
| A3 | Deploy rules: upload `firebase/firestore.rules`, `storage.rules`, indexes from repo | Security |
| A4 | Service account key: **Project settings → Service accounts → Generate key** | Backend on Render needs this |
| A5 | Save JSON **only** on PC; **never** commit to GitHub | Security |

**AI:** Can paste env-var format from JSON into Render dashboard template (you paste values).

---

## 4. Phase B — Secrets for production (YOU)

Generate **new** secrets for cloud (do not reuse dev JWT on a public URL):

```powershell
# Run on your PC once — copy output into Render env vars
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

| Env var | YOU provide |
|---------|-------------|
| `JWT_SECRET` | First random string (≥32 chars) |
| `JWT_REFRESH_SECRET` | Second random string |
| `FIREBASE_*` or `GOOGLE_APPLICATION_CREDENTIALS` | From service account |
| `SMTP_USER` / `SMTP_PASS` | Gmail app password (if new registrations) |
| `EMAIL_FROM` | e.g. `Pixel Lift <your@gmail.com>` |
| `CLIENT_URL` | `https://YOUR-SERVICE.onrender.com` (exact backend URL) |
| `NODE_ENV` | `production` |
| `PORT` | `3000` (Render often sets `PORT` automatically — use their value if injected) |

**AI:** Update `backend/.env.example` comments for Render if anything is unclear (optional).

---

## 5. Phase C — Push code to GitHub (YOU)

| Step | Action |
|------|--------|
| C1 | Ensure repo on GitHub has `backend/`, `firebase/`, `mobile/` |
| C2 | Confirm **`.gitignore`** excludes `backend/.env`, `serviceAccountKey.json`, `.cursor/` |
| C3 | Push latest `main` (or deploy branch) |

**AI:** Can run `git status`, help commit **only if you ask** — never commit secrets.

---

## 6. Phase D — Deploy backend on Render (YOU clicks + AI template)

### YOU in Render dashboard

| Step | Setting |
|------|---------|
| D1 | **New → Web Service** → Connect GitHub repo |
| D2 | **Root directory:** `backend` |
| D3 | **Runtime:** Node |
| D4 | **Build command:** `npm install` (or `npm ci`) |
| D5 | **Start command:** `npm start` |
| D6 | **Health check path:** `/api/health` |
| D7 | Paste all env vars from §4 |
| D8 | For Firebase: either paste `FIREBASE_PROJECT_ID`, `FIREBASE_CLIENT_EMAIL`, `FIREBASE_PRIVATE_KEY` (escape `\n` in key), `FIREBASE_STORAGE_BUCKET` **or** use Render secret file — **AI can add `render.yaml` if you want one-click** |
| D9 | Deploy → wait until **Live** |
| D10 | Copy public URL: `https://xxxx.onrender.com` |

### Verify (YOU or AI)

```powershell
Invoke-RestMethod -Uri "https://xxxx.onrender.com/api/health"
```

Want: `status : ok`

**First request after idle (free tier):** may take **30–60 s** — normal on Render free.

### Railway (alternative YOU)

Same idea: service root `backend`, start `npm start`, env vars §4, health `/api/health`.

**AI can add:** `backend/render.yaml` or `railway.toml` + `Procfile` if missing — **~0% app logic change**.

---

## 7. Phase E — Mobile app points to cloud (AI + YOU build)

### What changes in the app

| Item | Change |
|------|--------|
| `API_BASE_URL` | `https://xxxx.onrender.com` (your Render URL) |
| `ML_SERVICE_URL` | **Not used for success path** if you skip HQ cloud — set to same URL or dummy; Capture will fail ML quickly and use **on-device** |

**No feature code removal required** for “skip HQ cloud” — fallback already exists.

### AI actions

- [ ] Set `mobile/assets/.env.example` prod note (optional)
- [ ] Confirm `AndroidManifest` allows **HTTPS** (default OK; `usesCleartextTraffic` can stay for debug)
- [ ] Give exact **release** build command with your Render URL

### YOU actions — build release APK

```powershell
# Env block from CONNECTING_PROCESS.md §8.1 first
cd D:\MACKHAN\mobile
flutter pub get

flutter build apk --release --target-platform android-arm64 `
  --dart-define=API_BASE_URL=https://xxxx.onrender.com `
  --dart-define=ML_SERVICE_URL=https://xxxx.onrender.com
```

Output: `mobile\build\app\outputs\flutter-apk\app-release.apk`

**Optional (Play Store later):** create keystore + `key.properties` — see [DEPLOYMENT.md](DEPLOYMENT.md). For viva, **unsigned/release APK** sideload is enough if signing is configured; debug APK also works but points wrong URL unless rebuilt.

### Install on any phone (YOU)

- Share `app-release.apk` (Drive/USB) → install → allow “unknown sources”
- **No USB reverse** needed
- Phone needs **internet** (Wi‑Fi or 4G)

---

## 8. Phase F — Production test script (YOU)

Use accounts from [CONNECTING_PROCESS.md](CONNECTING_PROCESS.md) §1 if they exist in **same Firebase** project.

| # | Test | Pass |
|---|------|------|
| F1 | Open app → login | Reaches Home |
| F2 | Logout → login again | OK |
| F3 | **Start Lift** | Live cutout works |
| F4 | **Capture** | Snackbar **Quick (on device)** — expected without ML |
| F5 | **Edit from Gallery** | Works |
| F6 | **Batch edit** (2–3 photos) | Saves |
| F7 | Profile photo upload | URL in Firebase Storage |
| F8 | **New register** (optional) | Email OTP received (needs SMTP §4) |

**AI:** If a step fails, read error + fix CORS/env/JWT — typical fixes below.

---

## 9. Troubleshooting (avoid hurdles)

| Problem | Cause | Fix |
|---------|--------|-----|
| Login timeout 30–60s first time | Render free **sleep** | Wait once; or upgrade plan; tell examiner “cold start” |
| Too many requests | Rate limit | Wait 15 min or redeploy backend |
| 401 on login | Wrong JWT secrets between deploys | Set stable `JWT_SECRET` on Render |
| Register works but no OTP | No SMTP | Add Gmail app password env vars |
| Capture shows Quick only | **Expected** in this plan | Say: “Studio needs ML server; we use on-device Quick” |
| SSL / certificate error | Wrong `API_BASE_URL` | Must be `https://` Render URL, no trailing slash issues |
| Firebase permission denied | Wrong service account / bucket | Fix `FIREBASE_*` env |

---

## 10. Work split — YOU vs AI (summary)

### YOU (human) — must do

1. Create **Render/Railway** account and connect **GitHub**
2. **Firebase** console: rules, service account, bucket name
3. Generate **JWT secrets**; paste **all env vars** in dashboard
4. Configure **SMTP** (if new user registration in demo)
5. Click **Deploy**; copy **HTTPS backend URL**
6. Send AI the URL: “build APK with this URL”
7. **Build/install APK** on demo phones (or ask AI to run build on your PC)
8. Run **§8 test checklist** on real phone on **mobile data** (proves no USB)

### AI (Cursor) — can do when you ask

1. Add **`render.yaml`** / **`Procfile`** under `backend/` if helpful
2. Verify **`.gitignore`**, no secrets in repo
3. Run **`flutter build apk --release`** with your `--dart-define` URLs
4. Fix **backend CORS** / `CLIENT_URL` if needed (usually env only)
5. Document your final URL in **CONNECTING_PROCESS.md** or this file
6. **Will not** create Render account or paste your Firebase key (YOU only)

---

## 11. Timeline (realistic)

| Day | YOU | AI |
|-----|-----|-----|
| 1 | Render account + env vars + deploy backend | `render.yaml`, verify health |
| 1 | Share backend URL | Release build command + build APK |
| 2 | Install APK on 1–2 phones | Fix deploy errors if tests fail |
| 2 | Full §8 checklist on mobile data | Update docs with final URL |

---

## 12. What we explicitly do NOT deploy

- [ ] `ml-service/` on Render/Railway/VPS  
- [ ] MODNet / TensorFlow cloud  
- [ ] HQ “Studio quality (cloud)” — **product choice**, not a bug  

Live + gallery quality = **ML Kit + on-device** — fine for viva and real use without paid ML hosting.

---

## 13. After deploy — tell examiner (one sentence)

> “Auth and profiles run on a cloud Node API with Firebase; real-time and gallery background removal run on the device; high-quality server-side matting was scoped out of cloud deploy to avoid costly GPU/RAM hosting—we use on-device processing for captures instead.”

---

*Created: 2026-10-08 — companion to [DEPLOYMENT.md](DEPLOYMENT.md) (ML sections optional).*
