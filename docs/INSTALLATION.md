# MACKHAN — Installation

Local setup for the Flutter **Android** app and the HTTP services it calls. API details: [API.md](API.md). Deploy: [DEPLOYMENT.md](DEPLOYMENT.md).

**Android toolchain = CLI only.** You do **not** need the Android Studio IDE — only Flutter + JDK 17 + Android SDK command-line tools (+ `adb`). Ignore `flutter doctor` warnings about “Android Studio not installed” if the Android toolchain / cmdline-tools are OK.

---

## What you install (no Android Studio UI)

| Need | Without Android Studio? |
|------|-------------------------|
| Edit UI in Studio | Not needed |
| Build & install APK | Flutter + Android SDK CLI + JDK 17 |
| See phone (`adb`) | platform-tools |

---

## 1. Prerequisites checklist

| Tool | Version | Used by |
|------|---------|---------|
| Flutter SDK (stable) | current stable | `mobile/` |
| JDK 17 | OpenJDK 17 | Android builds |
| Android SDK (cmdline-tools + platform-tools + API 34) | API 34+ | build / `adb` / device |
| Node.js | 20 LTS | `backend/` |
| Python | 3.11 | `ml-service/` |
| Firebase project | — | Firestore + Storage (backend Admin SDK) |

**Windows:** add tools to User PATH; **close and reopen** PowerShell after each PATH change. Prefer `python -m pip` over bare `pip`.

```powershell
flutter --version
java -version
adb version
node --version
python --version
```

Optional: `winget install Python.Python.3.11` · `winget install OpenJS.NodeJS.LTS`

---

## 2. JDK 17

```powershell
winget install Microsoft.OpenJDK.17
```

Close and reopen PowerShell. Confirm: `java -version` → 17.x.

---

## 3. Flutter SDK

1. Download Flutter SDK (Windows zip): https://docs.flutter.dev/get-started/install/windows/mobile  
2. Unzip so you have e.g. `D:\flutter\bin\flutter.bat` (any drive with space is fine; avoid spaces in the path).  
3. Add to User PATH: `D:\flutter\bin`  
4. Reopen PowerShell, then:

```powershell
flutter --version
```

**This machine:** SDK is at `D:\flutter` (zip was `D:\flutter_sdk.zip`). After extract, the zip can be deleted to free ~1.8 GB.

---

## 4. Android SDK (command-line only)

```powershell
winget install Google.PlatformTools
```

That gives `adb`. Flutter also needs the full SDK (platforms / build-tools). Without Studio:

```powershell
mkdir $env:LOCALAPPDATA\Android\Sdk -Force
winget search "Android SDK"
```

If winget has **cmdline-tools**, install that. Otherwise download **Command line tools only**: https://developer.android.com/studio#command-line-tools-only  

Unzip so you have:

```text
%LOCALAPPDATA%\Android\Sdk\cmdline-tools\latest\bin\sdkmanager.bat
```

Then:

```powershell
$env:ANDROID_HOME = "$env:LOCALAPPDATA\Android\Sdk"
[Environment]::SetEnvironmentVariable("ANDROID_HOME", $env:ANDROID_HOME, "User")
$env:Path += ";$env:ANDROID_HOME\cmdline-tools\latest\bin;$env:ANDROID_HOME\platform-tools"
# Persist platform-tools + cmdline-tools on User PATH (same two dirs) so new shells work.

sdkmanager "platform-tools" "platforms;android-36" "platforms;android-34" "build-tools;36.0.0" "build-tools;34.0.0"
sdkmanager --licenses
```

Accept licenses (`y`). (Flutter 3.44+ needs **API 36** + recent build-tools; API 34 is fine to keep too.) Point Flutter at the SDK:

```powershell
flutter config --android-sdk "$env:LOCALAPPDATA\Android\Sdk"
```

---

## 5. Check toolchain

```powershell
flutter doctor
adb version
```

`flutter doctor` may still warn about Android Studio — **ignore** if Android toolchain / cmdline-tools are OK.

### Phone USB

1. Phone: **Developer options → USB debugging ON**  
2. Plug USB → Allow this PC  
3. Check:

```powershell
adb devices
```

Must list your device (not `unauthorized` / empty).

---

## 6. Firebase project

The app never talks to Firebase directly. Only `backend/` uses the Admin SDK.

1. [Firebase Console](https://console.firebase.google.com) → **Add project**.
2. Enable **Firestore** (production mode) and **Storage** (default bucket).
3. **Project settings → Service accounts → Generate new private key** → save as `backend/serviceAccountKey.json` (gitignored).
4. Deploy rules from [`firebase/firestore.rules`](../firebase/firestore.rules) and [`firebase/storage.rules`](../firebase/storage.rules).
5. Create composite indexes from [`firebase/firestore.indexes.json`](../firebase/firestore.indexes.json).

**Collections** (created on first write): `users`, `verificationCodes`, `sessions` — schema in [PLAN.md §5.2](PLAN.md).

**Env (pick one):** `GOOGLE_APPLICATION_CREDENTIALS=./serviceAccountKey.json` **or** `FIREBASE_PROJECT_ID` + `FIREBASE_CLIENT_EMAIL` + `FIREBASE_PRIVATE_KEY` + `FIREBASE_STORAGE_BUCKET` in `backend/.env`.

---

## 7. Clone and env files

```powershell
cd D:\MACKHAN
copy backend\.env.example backend\.env
copy ml-service\.env.example ml-service\.env
copy mobile\assets\.env.example mobile\assets\.env
```

Fill secrets in `backend/.env` and `ml-service/.env`. **Same `JWT_SECRET`** on backend and ML (copy from `backend\.env` into `ml-service\.env`). Set SMTP_* for OTP email.

### Physical phone (same Wi‑Fi as PC)

Use the PC LAN IP — **not** `10.0.2.2` (that is emulator-only). Example already set on this machine:

```env
API_BASE_URL=http://192.168.100.118:3000
ML_SERVICE_URL=http://192.168.100.118:8000
```

Emulator only: `http://10.0.2.2:3000` / `:8000`.

---

## 8. Backend

```powershell
cd D:\MACKHAN\backend
npm install
npm run dev
```

Health: http://localhost:3000/api/health — Production-style: `npm start`.

---

## 9. ML service

```powershell
cd D:\MACKHAN\ml-service
python -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install -r requirements.txt
python scripts/download_model.py
python -m uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

If `Activate.ps1` is blocked: `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`

Health: http://localhost:8000/health

### MODNet weights

`scripts/download_model.py` writes a **placeholder** SavedModel under `models/modnet/` if none exists.

**Manual production weights:** place an official TensorFlow SavedModel from [MODNet](https://github.com/ZHKKKe/MODNet) at `ml-service/models/modnet/` (must include `saved_model.pb`). The script no-ops when that file is present.

---

## 10. Flutter app on phone

Start backend + ML first. Phone + PC on same Wi‑Fi; USB debugging on; `adb devices` shows the device.

```powershell
cd D:\MACKHAN\mobile
flutter create . --platforms=android
flutter pub get
flutter run
```

Release overrides: see [DEPLOYMENT.md](DEPLOYMENT.md) (`--dart-define=API_BASE_URL=…`).

---

## 11. Optional: Firebase Emulator Suite

No DB in Docker Compose — Firebase is cloud-hosted. Offline option:

1. Install [Firebase CLI](https://firebase.google.com/docs/cli) and Java.
2. `firebase init emulators` (Firestore + Storage), then `firebase emulators:start`.
3. Point backend at emulators:

```env
FIRESTORE_EMULATOR_HOST=127.0.0.1:8080
FIREBASE_STORAGE_EMULATOR_HOST=127.0.0.1:9199
```

Prefer cloud Firebase for full SMTP + Storage URL testing.

---

## Optional: Docker (ML)

```powershell
cd D:\MACKHAN\ml-service
docker build -t mackhan-ml .
docker run --env-file .env -p 8000:8000 -v "${PWD}/models:/app/models" mackhan-ml
```

Prefer `npm run dev` for backend (no `backend/Dockerfile` yet).

---

## Quick verify

- [ ] `flutter doctor` — Android toolchain OK (Studio warning OK to ignore)
- [ ] `adb devices` — phone listed
- [ ] `GET /api/health` → 200
- [ ] `GET /health` (ML) → healthy
- [ ] App register/login against backend
- [ ] Live camera (ML Kit) + HQ capture → ML

When `flutter doctor` and `adb devices` work, paste their output for the next exact run command.
