# YOUR steps — deploy Pixel Lift (after AI prep is done)

> AI has added: `render.yaml`, `backend/.env.render.example`, `scripts/build-production-apk.ps1`, production backend fixes, `ML_CLOUD_ENABLED=false` for APK builds.  
> **You** do the steps below **in order**. Reply in chat after each phase if something fails.

---

## Step 1 — GitHub

1. Open your GitHub repo for `D:\MACKHAN`.
2. Confirm **no** `backend/.env` or `serviceAccountKey.json` is tracked.
3. **Push** latest code (includes new deploy files).

---

## Step 2 — Render account

1. Go to [render.com](https://render.com) → sign up (free).
2. **New → Blueprint** (or **Web Service** if Blueprint asks for repo).
3. Connect the **same GitHub repo**.
4. Render should detect **`render.yaml`** at repo root → service **`pixel-lift-api`**, root **`backend`**.

---

## Step 3 — Production secrets (Render → Environment)

Open **`backend/.env.render.example`** on your PC. For **each** key, paste the **real** value in Render.

| Must set | Where you get it |
|----------|------------------|
| `CLIENT_URL` | After first deploy: `https://<your-service>.onrender.com` (no `/api`) |
| `JWT_SECRET` | Run twice: `node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"` |
| `JWT_REFRESH_SECRET` | Second output from above |
| `FIREBASE_PROJECT_ID` | Firebase → Project settings |
| `FIREBASE_CLIENT_EMAIL` | Service account JSON |
| `FIREBASE_PRIVATE_KEY` | Service account JSON (`private_key` field; keep `\n`) |
| `FIREBASE_STORAGE_BUCKET` | e.g. `pixel-lift-423b5.appspot.com` |

**Optional but recommended for new signups:**

| `SMTP_USER` | Your Gmail |
| `SMTP_PASS` | Gmail [App Password](https://myaccount.google.com/apppasswords) |
| `EMAIL_FROM` | `Pixel Lift <your@gmail.com>` |

If SMTP is empty: new users’ OTP appears only in **Render → Logs** (search `[dev OTP]`).

Click **Save** → **Manual Deploy** if needed.

---

## Step 4 — Check backend is live

In PowerShell:

```powershell
Invoke-RestMethod -Uri "https://YOUR-SERVICE.onrender.com/api/health"
```

Want: `status : ok`  
**First hit after idle:** may take up to ~60 seconds (free tier wake-up).

Tell AI your exact URL: `My API URL is https://....`

---

## Step 5 — Build production APK (you or AI on your PC)

Replace URL with yours:

```powershell
cd D:\MACKHAN
.\scripts\build-production-apk.ps1 -ApiUrl "https://YOUR-SERVICE.onrender.com"
```

APK path:

`D:\MACKHAN\mobile\build\app\outputs\flutter-apk\app-release.apk`

---

## Step 6 — Install on phone

1. Copy APK to phone (USB, Drive, etc.).
2. Install → allow unknown apps if asked.
3. **No** `adb reverse` needed.
4. Use **Wi‑Fi or mobile data**.

Login (existing Firebase users):

| Email | Password |
|-------|----------|
| `pixel.lift.demo@gmail.com` | `Lift@12345` |
| `pixellift.user@gmail.com` | `Pixel@2026` |

---

## Step 7 — Demo checklist (viva)

- [ ] Login without USB
- [ ] **Start Lift** (live camera)
- [ ] **Capture** → should be **Quick (on device)** quickly (no 30s wait)
- [ ] **Edit from Gallery**
- [ ] Logout → login again

---

## If something breaks

| Issue | What to do |
|-------|------------|
| Health never returns | Render logs → env validation / Firebase key |
| Login timeout 60s | Wait once (cold start) or redeploy |
| Too many requests | Wait 15 min or redeploy backend |
| Register no email | Add SMTP or read OTP in Render logs |

Full reference: [DEPLOY_ACTION_PLAN.md](DEPLOY_ACTION_PLAN.md)
