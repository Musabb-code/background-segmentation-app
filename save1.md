# MACKHAN Conversation Save — Flutter Android Build + Auth + Deploy

> Saved from Cursor chat session covering Windows reset → APK build → phone install → auth/backend → university demo hosting.
> Dates covered: ~2026-07-30 to 2026-08-01

---

## 1. User goal (original)

Full Flutter Android development environment audit + setup after a complete Windows PC reset. Goal:

- Inspect existing Flutter project first (do NOT install blindly)
- Build Android APK
- Install/test on physical Android phone (USB)
- Optimize for limited disk space
- Do not install Python/Git/Node/Android Studio/Emulator unless actually required

---

## 2. Project audit findings (before install)

### App identity
- Product: Flutter Android real-time background removal (`mobile/`)
- Package: `com.mackhan.mackhan`
- On-device ML: Google ML Kit Selfie Segmentation (live)
- HQ capture: optional Python FastAPI MODNet (`ml-service/`) — not needed for APK build
- Auth/profile: Express backend → Firebase Firestore (Admin SDK)

### Exact toolchain versions from project files
| Item | Value |
|------|-------|
| Flutter | ≥3.44.0 (last build: **3.44.8**) |
| Dart | ≥3.12.0 (bundled **3.12.2** with Flutter) — do NOT install Dart separately |
| AGP | **9.0.1** |
| Gradle | **9.1.0** (wrapper — do NOT install Gradle globally) |
| Kotlin | **2.3.20** |
| JDK | **17** |
| compileSdk / targetSdk | **36** (from Flutter defaults) |
| minSdk | **24** |
| ABI | **arm64-v8a only** |
| NDK / CMake | NOT required (`tflite_flutter` commented out) |
| Android Studio | NOT required (CLI sufficient) |
| Python / Git / Node | NOT required for APK build |

### Machine surprise after Windows reset
PATH/env vars were wiped and JDK was gone, BUT these still existed on D: drive:
- `D:\flutter` (3.44.8) ~3 GB
- `D:\Android\Sdk` (API 34/35/36, platform-tools, cmdline-tools, NDK 28.2) ~3 GB
- `D:\mackhan-cache` (gradle + pub + local-m2) ~4.5 GB

So: mostly restore PATH + install JDK 17 — not a full reinstall.

### Minimal install checklist (what was actually needed)
```
[ ] Install JDK 17
[ ] Set JAVA_HOME
[ ] Add to PATH: D:\flutter\bin
[ ] Add to PATH: D:\Android\Sdk\platform-tools
[ ] Add to PATH: D:\Android\Sdk\cmdline-tools\latest\bin
[ ] Set ANDROID_HOME = D:\Android\Sdk
[ ] flutter config --android-sdk D:\Android\Sdk
[ ] flutter doctor -v
[ ] USB debugging → adb devices
[ ] cd D:\MACKHAN\mobile → flutter pub get → flutter run
```

Do NOT install: Python, Git, Node, Android Studio, Emulator, global Gradle, separate Dart, CMake (for APK only).

---

## 3. Environment setup — what user ran / what worked

### JDK install
```powershell
winget install Microsoft.OpenJDK.17
```
- Accepted msstore terms with `Y`
- First shell didn't see `java` → reopen PowerShell
- Verified: `openjdk version "17.0.20"`

### PATH / env restore
```powershell
$jdk = (Get-ChildItem "C:\Program Files\Microsoft" -Directory -Filter "jdk-17*" | Select-Object -First 1).FullName
[Environment]::SetEnvironmentVariable("JAVA_HOME", $jdk, "User")
[Environment]::SetEnvironmentVariable("ANDROID_HOME", "D:\Android\Sdk", "User")

$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
foreach ($p in @(
  "$jdk\bin",
  "D:\flutter\bin",
  "D:\Android\Sdk\platform-tools",
  "D:\Android\Sdk\cmdline-tools\latest\bin"
)) {
  if ($userPath -notlike "*$p*") { $userPath += ";$p" }
}
[Environment]::SetEnvironmentVariable("Path", $userPath, "User")
```

### Verification results
- `flutter --version` → Flutter 3.44.8 / Dart 3.12.2 ✅
- `java -version` → OpenJDK 17.0.20 ✅
- `adb version` → 1.0.41 ✅
- `flutter doctor -v` → Flutter + Android toolchain OK
  - Ignore: Visual Studio warning (Windows desktop only)
  - Ignore: Network/GitHub handshake warning
  - Ignore: Android Studio missing
- Phone: `SM A346E` · `RRCW900YP4V` · android-arm64 · Android 16 (API 36) ✅
- `adb devices` → `RRCW900YP4V device` ✅

### Mistake that caused "No pubspec.yaml"
User ran `flutter run` / `flutter pub get` **before** `cd D:\MACKHAN\mobile`.
Correct order (one by one):
```powershell
cd D:\MACKHAN\mobile
flutter pub get
flutter run -d RRCW900YP4V
```

---

## 4. First build — downloads / resume / time

### What was downloading during first `assembleDebug`
AndroidX, ML Kit, CameraX, and other Maven artifacts — **cannot practically download manually**.

### Disk impact
First build ~1.5–3 GB total (Gradle ~670 MB + deps + build files).

### Resume if power/internet drops
Yes. Gradle keeps finished downloads. Rerun:
```powershell
cd D:\MACKHAN\mobile
flutter run -d RRCW900YP4V
```
Only missing/incomplete files re-download.

### Time estimate discussed
First build often 15–40+ minutes (user's first run failed after ~1h 10m due to compile error, not network hang). Later builds much faster.

---

## 5. Build errors — root causes and fixes

### Error A — integration_test / FragmentActivity
```
:integration_test:compileDebugJavaWithJavac
cannot access FragmentActivity
```
**Cause:** AGP 9 no longer puts common AndroidX on plugin compile classpath.
**Fix:** In `mobile/android/build.gradle.kts`, existing workaround already had core + lifecycle; added fragment:
```kotlin
dependencies.add("implementation", "androidx.fragment:fragment:1.7.1")
```

### Error B — Java heap space (JetifyTransform)
```
Failed to transform arm64_v8a_debug-...jar
Java heap space
```
**Cause:** `gradle.properties` had `-Xmx768m` (too low); also competing Gradle processes.
**Fix:** Raised heap:
```
org.gradle.jvmargs=-Xmx1536m -XX:MaxMetaspaceSize=512m -XX:+UseSerialGC
```
Stopped stale duplicate Gradle/Java processes.

### Error C — corrupt unused ABI JARs
```
Jetifier failed ... armeabi_v7a_debug / x86_64_debug
Unexpected end of ZLIB input stream
```
**Cause:** Incomplete/corrupt cached JARs for ABIs this phone does not need.
**arm64 JAR was valid.**
**Fix:** Build only phone ABI:
```powershell
flutter build apk --debug --target-platform android-arm64
```

### Successful APK
```
√ Built build\app\outputs\flutter-apk\app-debug.apk
```
Path: `D:\MACKHAN\mobile\build\app\outputs\flutter-apk\app-debug.apk`

Install:
```powershell
adb install -r D:\MACKHAN\mobile\build\app\outputs\flutter-apk\app-debug.apk
```
Or live run:
```powershell
cd D:\MACKHAN\mobile
flutter run -d RRCW900YP4V --target-platform android-arm64
```

---

## 6. App crash on open — ReLinker fix

### Symptom
App opens then immediately closes.

### Crash log (adb)
```
NoClassDefFoundError: Failed resolution of: Lcom/getkeepsafe/relinker/ReLinker$Logger;
ClassNotFoundException: com.getkeepsafe.relinker.ReLinker$Logger
```
Happened during Flutter engine init (`FlutterLoader` / `FlutterJNI`).

### Cause
Incomplete local Maven metadata omitted Flutter's ReLinker runtime dependency from the APK.

### Fix
In `mobile/android/app/build.gradle.kts`:
```kotlin
implementation("com.getkeepsafe.relinker:relinker:1.4.5")
```

### Verified
Rebuilt → reinstalled → cold launch → process stayed alive → `MainActivity` resumed.
Screenshot showed working **Sign in** screen (Email / Password / Login / Register).

---

## 7. Register / login / backend attempt

### Why backend is needed
Router guards `/camera` behind auth. Unauthenticated users stay on login.
`bootstrap()` calls `/api/auth/refresh`; if server unreachable, tokens are cleared and user is sent to login.

### Architecture reminder
```
Phone app → Wi-Fi → Laptop Express backend → Internet → Firebase Firestore
```
Phone does **NOT** talk to Firebase directly.
Firestore rules are deny-all for clients (Admin SDK only).

### What was done
1. Installed Node.js LTS via winget (`v24.18.0`)
2. Started backend: `node server.js` → listening on port 3000
3. PC Wi-Fi IP: `192.168.100.118` (matches `mobile/assets/.env`)
4. Registered via API: `tester@mackhan.com` / `Test@12345`
5. Dev OTP printed in backend log: `559034`

### Verify failed
Firestore error:
```
FAILED_PRECONDITION: The query requires an index
```
Collection: `verificationCodes` (email + type + createdAt)

Index is defined in repo (`firebase/firestore.indexes.json`) but was **never deployed** to Firebase project `pixel-lift-423b5`.

Create-index link (from backend error):
https://console.firebase.google.com/v1/r/project/pixel-lift-423b5/firestore/indexes?create_composite=Clpwcm9qZWN0cy9waXhlbC1saWZ0LTQyM2I1L2RhdGFiYXNlcy8oZGVmYXVsdCkvY29sbGVjdGlvbkdyb3Vwcy92ZXJpZmljYXRpb25Db2Rlcy9pbmRleGVzL18QARoJCgVlbWFpbBABGggKBHR5cGUQARoNCgljcmVhdGVkQXQQAhoMCghfX25hbWVfXxAC

Until that index is Enabled, verify + login cannot complete.

### Backend later aborted
Local `node server.js` process was aborted — must restart for laptop-based login again.

---

## 8. User idea: local-only registration (university project)

### User proposal
Store register/login locally on phone so demo doesn't need laptop/server — because this is a university project, not App Store production.

### Assistant recommendation
**Do not build local password registration.**
Reasons:
- Unsafe (passwords on device)
- Conflicts with PLAN.md (custom Express JWT + bcrypt + Firebase Admin)
- Backend already almost works (only missing Firestore index)

Safer offline demo option (would need PLAN.md update first):
- "Continue as Demo" button — skip fake local passwords, unlock camera for ML Kit demo

---

## 9. What is required when testing the app

| Need | For what |
|------|----------|
| USB cable | Only to **install** APK (or hot-reload with `flutter run`). Not needed every open after install. |
| Laptop + backend running | **Yes** for login/register/session refresh (current design) |
| Same Wi-Fi (phone + PC) | **Yes** when backend is on laptop (`API_BASE_URL=http://192.168.100.118:3000`) |
| Firebase | Used **via backend**, not direct from phone |
| Python ML service | Optional — only HQ capture upload, not live ML Kit preview |
| Live background removal | Runs on phone (ML Kit) after you pass login |

Important: if PC IP changes, update `mobile/assets/.env` and rebuild APK.

---

## 10. University demo — remove laptop dependency

### Can we remove the middleman?
Technically only by rewriting auth to Firebase Auth + client SDK + new security rules.
PLAN lists "Firebase Auth migration" as **Post-MVP**.
Current Firestore deny-all + Admin key must never ship in the APK.

### Recommended path
**Keep middleman, deploy it online** (already in `docs/DEPLOYMENT.md`).

Then:
```
Phone (any Wi-Fi / mobile data)
  → https://your-backend.onrender.com
  → Firebase
```

No laptop at the demo. USB only if reinstalling APK.
Live BG removal still on-device.

### Exact deploy link (recommended free host)
- Sign up / dashboard: https://render.com
- New Web Service: https://dashboard.render.com/web/new

Suggested Render settings:

| Field | Value |
|-------|-------|
| Root Directory | `backend` |
| Build Command | `npm ci --omit=dev` |
| Start Command | `node server.js` |
| Instance | Free |

Add env vars from `backend/.env` (JWT, Firebase credentials, SMTP, `NODE_ENV=production`).

Free-tier note: sleeps after ~15 min idle; wake takes 30–60s. Before presentation, hit `/api/health` once.

After deploy:
1. Create Firestore index
2. Set app `API_BASE_URL` to public HTTPS URL
3. Rebuild APK once

Optional always-on / more free requests: Google Cloud Run — https://cloud.google.com/run

---

## 11. Files changed during this session

| File | Change |
|------|--------|
| `mobile/android/build.gradle.kts` | Added `androidx.fragment:fragment:1.7.1` for AGP 9 plugin classpath |
| `mobile/android/gradle.properties` | Heap `768m → 1536m`, metaspace `512m` |
| `mobile/android/app/build.gradle.kts` | Added `com.getkeepsafe.relinker:relinker:1.4.5` |
| `docs/LOG.md` | Steps 30–32 + Current Status updates |

---

## 12. Short status as of end of conversation

### APK build — SOLVED
Previous problems (PATH/JDK, FragmentActivity, heap space, corrupt ABI JARs, ReLinker crash) are fixed.
Easy rebuild command:
```powershell
cd D:\MACKHAN\mobile
flutter build apk --debug --target-platform android-arm64
```
APK: `mobile\build\app\outputs\flutter-apk\app-debug.apk`

### App open — SOLVED
Installed and verified running on phone `RRCW900YP4V` (Sign in screen works).

### Login / camera demo — BLOCKED
Needs:
1. Firestore composite index created/enabled
2. Backend running (local `node server.js` **or** deployed online)
3. Then register/verify/login → camera → ML Kit background removal

### Best next step for university presentation
Deploy backend to Render + create Firestore index + rebuild APK with public API URL.

---

## 13. Useful commands cheat sheet

```powershell
# Tool versions
java -version
flutter --version
adb version
flutter doctor -v

# Phone
adb devices
flutter devices

# Build / install
cd D:\MACKHAN\mobile
flutter pub get
flutter build apk --debug --target-platform android-arm64
adb install -r build\app\outputs\flutter-apk\app-debug.apk
flutter run -d RRCW900YP4V --target-platform android-arm64

# Local backend
cd D:\MACKHAN\backend
node server.js
# Health: http://192.168.100.118:3000/api/health
```

### Test account created (not fully verified yet)
- Email: `tester@mackhan.com`
- Password: `Test@12345`
- OTP seen once: `559034` (expired / needs fresh OTP after index is created)

---

*End of saved conversation.*
