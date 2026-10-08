# Pixel Lift — Connecting & install process (viva runbook)

> **Use this file alone** to install the app on any Android phone, start servers on your PC, log in, and run a full demo — **no AI assistant required**.  
> **App name:** Pixel Lift · **Package:** `com.mackhan.mackhan` · **Project folder:** `D:\MACKHAN`

Copy each PowerShell block **in order**. Run commands **one block at a time**. After changing PATH, **close and reopen PowerShell** if a command is “not recognized”.

More detail (first-time PC setup): [INSTALLATION.md](INSTALLATION.md) · APK troubleshooting: [APK_PHONE_RUNBOOK.md](APK_PHONE_RUNBOOK.md)

---

## 1. All login accounts (emails in one place)

These accounts live in **Firebase** (via the backend). Use any **verified** row below on the phone.

| # | Email | Password | Status | Notes |
|---|--------|----------|--------|--------|
| 1 | `pixel.lift.demo@gmail.com` | `Lift@12345` | Verified | **Main demo account** (runbook default) |
| 2 | `tester@mackhan.com` | `Test@12345` | Verified (if still in Firebase) | Older test account |
| 3 | `pixellift.user@gmail.com` | `Pixel@2026` | Verified | Extra account created during project testing |

**Rules**

- Password must be **≥8 characters**, **≥1 uppercase**, **≥1 number** (for new registrations).
- If login says **“Too many requests”**: you hit the server limit (**5 login tries per 15 minutes**). **Restart the backend** (see §6.4) or wait 15 minutes, then try again **once**.
- If login says **connection error**: backend is not running, USB is unplugged, or **`adb reverse`** was not run — not wrong email/password.

---

## 2. What runs where (why each piece exists)

| Piece | Port | Required for | Runs on |
|-------|------|----------------|---------|
| **Backend (Express)** | **3000** | Sign in, register, profile, JWT for ML | Your **PC** |
| **ML service (FastAPI)** | **8000** | **HQ Capture / Studio** quality (optional for live camera) | Your **PC** |
| **Pixel Lift app** | — | Camera, gallery, UI | **Phone** |
| **Firebase** | cloud | User database + profile images | Google Cloud (backend talks to it) |

**Live background removal (Start Lift)** uses **ML Kit on the phone** — **no PC** needed after install.

**Login and HQ capture** need the phone to reach your PC:

- App is built with `API_BASE_URL=http://127.0.0.1:3000` (see `mobile/assets/.env`).
- On the phone, `127.0.0.1` is the phone itself — so you **must** use USB **`adb reverse`** to tunnel phone → PC.

---

## 3. One-time machine setup (before viva day)

Do this once on the PC (full steps in [INSTALLATION.md](INSTALLATION.md)):

| Tool | Why |
|------|-----|
| **Flutter** (`D:\flutter\bin`) | Build the APK |
| **JDK 17** | Android/Gradle build |
| **Android SDK** (`D:\Android\Sdk`) + **platform-tools** (`adb`) | Install APK on phone |
| **Node.js 20** | Run backend |
| **Python 3.11** | Run ML service (optional for HQ demo) |
| **`backend\.env`** + **`backend\serviceAccountKey.json`** | Backend auth + Firebase (already in project if you cloned the repo) |

Check (optional):

```powershell
flutter --version
java -version
adb version
node --version
```

---

## 4. Every viva session — order of operations

Do these **every time** you plug in a phone for login or HQ demo:

| Step | Section | What |
|------|---------|------|
| 1 | §5 | Phone: USB debugging + `adb devices` → `device` |
| 2 | §6 | **Window 1:** Start **backend** (keep open) |
| 3 | §7 | **Window 2 (optional):** Start **ML service** for HQ Capture |
| 4 | §8 | **Window 2 or 3:** Env vars → build APK (if code changed) → **install** |
| 5 | §9 | **`adb reverse`** for ports 3000 and 8000 |
| 6 | §10 | Open app → **log in** |
| 7 | §11 | **Full demo** script for examiner |

---

## 5. Connect the phone (any Android, arm64)

### 5.1 On the phone (once per phone)

1. **Settings → About phone → Build number** → tap **7 times** (developer mode).
2. **Settings → Developer options → USB debugging** → **ON**.
3. Plug USB cable (data cable, not charge-only).
4. Tap **Allow USB debugging** on the phone.

### 5.2 On the PC — every plug-in

**Why:** Confirms the PC sees the phone before install/login.

```powershell
$env:ANDROID_HOME = "D:\Android\Sdk"
$env:Path = "D:\Android\Sdk\platform-tools;$env:Path"
adb devices
```

**Want:** a line ending with **`device`** (not `unauthorized` or empty).

**Two phones?** Note the serial (first column), then use `adb -s SERIAL ...` in §8–§9.

Example serial from this project: `10FEBS02QE000A2` (Vivo V2352).

---

## 6. Run the backend (login server)

### 6.1 Why this command

- Login hits **`http://127.0.0.1:3000/api/auth/login`** on the PC (via USB reverse).
- **`node server.js` must run inside `backend\`** — **not** `D:\MACKHAN` (that gives `Cannot find module 'D:\MACKHAN\server.js'`).

### 6.2 Start backend — Window 1 (leave open)

```powershell
cd D:\MACKHAN\backend
node server.js
```

**Success:** log line like `Server listening on port 3000`.

**Quick check** (new PowerShell window):

```powershell
Invoke-RestMethod -Uri "http://127.0.0.1:3000/api/health"
```

**Want:** `status : ok`

### 6.3 Stop backend

In Window 1: **Ctrl+C**

### 6.4 Fix “Too many requests, please try again later”

**Why:** Auth routes allow **5 login/register/forgot attempts per 15 minutes** per client IP.

**Fix for demo:** stop backend (**Ctrl+C**), start again (`node server.js`). Counter resets. Then log in **once** with a verified account from §1.

---

## 7. Run the ML service (optional — HQ / Studio capture)

**Skip this section** if you only demo **live camera (Start Lift)** and **gallery on-device** processing.

### 7.1 Why

**Capture / Studio** sends a photo to **`http://127.0.0.1:8000/inference/segment`** (needs **`adb reverse tcp:8000`** and same JWT secret as backend).

### 7.2 Start ML — Window 2 (leave open)

First time in a session (venv):

```powershell
cd D:\MACKHAN\ml-service
python -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install -r requirements.txt
python scripts/download_model.py
python -m uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

Next times (faster):

```powershell
cd D:\MACKHAN\ml-service
.\.venv\Scripts\Activate.ps1
python -m uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

**Check:**

```powershell
Invoke-RestMethod -Uri "http://127.0.0.1:8000/health"
```

**Want:** `status : healthy`, `model_loaded : true` (or true after placeholder download).

### 7.3 Stop ML

In ML window: **Ctrl+C**

---

## 8. Build and install the app on the phone

### 8.1 Set tools in this PowerShell window (every new window)

**Why:** Gradle, Flutter, and `adb` must be on PATH for build/install.

```powershell
$env:JAVA_HOME = (Get-ChildItem "C:\Program Files\Microsoft" -Directory -Filter "jdk-17*" | Select-Object -First 1).FullName
$env:ANDROID_HOME = "D:\Android\Sdk"
$env:Path = "$env:JAVA_HOME\bin;D:\flutter\bin;D:\Android\Sdk\platform-tools;D:\Android\Sdk\cmdline-tools\latest\bin;$env:Path"
$env:GIT_CONFIG_COUNT = "1"
$env:GIT_CONFIG_KEY_0 = "safe.directory"
$env:GIT_CONFIG_VALUE_0 = "*"
```

### 8.2 Build debug APK (when code changed or no APK yet)

**Why these flags:** This project’s phones are **arm64**; this avoids broken multi-ABI / Jetify OOM on this PC.

```powershell
cd D:\MACKHAN\mobile
flutter pub get
flutter build apk --debug --target-platform android-arm64
```

**Success:** `Built build\app\outputs\flutter-apk\app-debug.apk`

**If `Java heap space`:**

```powershell
Get-Process java -ErrorAction SilentlyContinue | ForEach-Object { Stop-Process -Id $_.Id -Force }
cd D:\MACKHAN\mobile
flutter build apk --debug --target-platform android-arm64
```

**Skip build** if APK already exists and you did not change code:

`D:\MACKHAN\mobile\build\app\outputs\flutter-apk\app-debug.apk`

### 8.3 Install on the connected phone

**Why `-r`:** Upgrades existing install without uninstall.

```powershell
cd D:\MACKHAN\mobile
adb install -r "build\app\outputs\flutter-apk\app-debug.apk"
```

**Want:** `Success`

**Specific phone:**

```powershell
adb -s 10FEBS02QE000A2 install -r "build\app\outputs\flutter-apk\app-debug.apk"
```

### 8.4 Open the app

```powershell
adb shell am start -n com.mackhan.mackhan/.MainActivity
```

Or tap **Pixel Lift** on the phone.

**Note:** Debug APK — **no release keystore / signing** needed for viva.

---

## 9. USB tunnel (connect phone app → PC servers)

**Run every time you plug USB** (tunnels die when you unplug).

**Why:** App uses `127.0.0.1:3000` and `:8000`; reverse maps phone localhost to PC.

```powershell
adb reverse tcp:3000 tcp:3000
adb reverse tcp:8000 tcp:8000
adb reverse --list
```

**Want:** lines with `tcp:3000` and `tcp:8000`.

With serial:

```powershell
adb -s 10FEBS02QE000A2 reverse tcp:3000 tcp:3000
adb -s 10FEBS02QE000A2 reverse tcp:8000 tcp:8000
```

**Before login:** §6 backend running + §9 reverse done + USB connected.

---

## 10. Log in on the phone

1. Open **Pixel Lift** → **Sign in**.
2. Enter one account from **§1** (recommended: `pixel.lift.demo@gmail.com` / `Lift@12345`).
3. Tap **Login** once; wait.
4. You should reach **Home**.

**After login:** you can **unplug USB** for **live camera** only. For **login again** or **HQ Capture to PC ML**, plug USB and repeat §9 + backend (and ML if needed).

---

## 11. Full demo script (viva — say + do)

| # | Show examiner | On phone |
|---|----------------|----------|
| 1 | Auth + profile | Home: name, email, verified badge |
| 2 | Live segmentation | **Open Pixel Lift** → **Start Lift** → subject on background; **Modes** (transparent / color / built-in / gallery) |
| 3 | Stop / idle | **Stop Lift** → raw camera again |
| 4 | HQ still (needs ML §7 + reverse :8000) | **Capture** → wait → preview → **Save** |
| 5 | Gallery studio | Home → **Edit from Gallery** → pick photo → preview → save (PNG/JPG/WebP) |
| 6 | E-commerce preset | Home → **Product white BG** → pick portrait → white JPG |
| 7 | Batch | Home → **Batch edit** → up to 20 photos → progress → saved to gallery |
| 8 | Settings | Resolution 480p/720p/1080p, quality, dark mode, auto-crop, export format |
| 9 | Logout | Menu → logout → sign in again (needs §6 + §9) |

---

## 12. Create a new account without the app (optional)

**Why:** Register + verify from PC; OTP prints in **backend Window 1** when SMTP is not configured.

Backend must be running (§6).

```powershell
$body = @{
  fullName = "Viva Student"
  email    = "you.viva@example.com"
  password = "VivaPass1"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://127.0.0.1:3000/api/auth/register" `
  -Method Post -ContentType "application/json" -Body $body
```

In backend console, find: `[dev OTP] you.viva@example.com (register): 123456`

```powershell
$verify = @{ email = "you.viva@example.com"; code = "123456" } | ConvertTo-Json
Invoke-RestMethod -Uri "http://127.0.0.1:3000/api/auth/verify" `
  -Method Post -ContentType "application/json" -Body $verify
```

Add the new email/password to your personal notes (and §1 table if you keep this file updated).

---

## 13. Troubleshooting (avoid errors in viva)

| Problem | Cause | Fix |
|---------|--------|-----|
| `Cannot find module D:\MACKHAN\server.js` | Wrong folder | `cd D:\MACKHAN\backend` then `node server.js` |
| Connection closed / connection errored | Backend off or no reverse | §6 + §9 |
| Too many requests | Rate limit (5 logins / 15 min) | Restart backend §6.4; wait; one login attempt |
| Login OK but Capture fails | ML off or no reverse :8000 | §7 + `adb reverse tcp:8000 tcp:8000` |
| `adb` empty / unauthorized | Cable / debugging | §5; Allow on phone |
| Build heap space | Old Java processes | Kill `java`, rebuild §8.2 |
| `No pubspec.yaml` | Wrong directory | `cd D:\MACKHAN\mobile` |

---

## 14. One-page checklist (print for viva)

- [ ] Phone: USB debugging, **`adb devices` → device**
- [ ] Window 1: `cd D:\MACKHAN\backend` → **`node server.js`**
- [ ] (Optional HQ) Window 2: ML **`uvicorn`** on **8000**
- [ ] **`adb reverse`** 3000 and 8000
- [ ] (If needed) **`flutter build apk --debug --target-platform android-arm64`**
- [ ] **`adb install -r`** app-debug.apk
- [ ] Login: **§1** account
- [ ] Demo: **§11**

---

## 15. Related docs

| File | When |
|------|------|
| [INSTALLATION.md](INSTALLATION.md) | First-time Flutter/JDK/SDK/Firebase |
| [APK_PHONE_RUNBOOK.md](APK_PHONE_RUNBOOK.md) | Extra adb tips, screenshots path |
| [API.md](API.md) | REST endpoints |
| [DEPLOYMENT.md](DEPLOYMENT.md) | Hosted backend (login without USB) |

*Last updated: 2026-10-08 — connecting, install, servers, accounts, and viva demo in one place.*
