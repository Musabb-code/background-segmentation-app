# Pixel Lift — APK Build, Install & Login Runbook

> **Rule:** Use **only** the ways below that already succeeded on this project.  
> Do **not** invent other build flags, Wi‑Fi IPs, or `flutter run --target-platform` — those failed or hung before.

**Proven successful path (do this):**

1. Set env (§1)  
2. Phone USB + `adb devices` → `device` (§2)  
3. `cd D:\MACKHAN\mobile` then  
   `flutter build apk --debug --target-platform android-arm64` (§3)  
4. `adb install -r build\app\outputs\flutter-apk\app-debug.apk` (§4)  
5. Backend `node server.js` + `adb reverse tcp:3000 tcp:3000` (§5)  
6. Login `pixel.lift.demo@gmail.com` / `Lift@12345` on phone  

**Product:** Flutter Android (`mobile/`) — package `com.mackhan.mackhan`  
**App name:** Pixel Lift  
**Build type that worked:** debug APK, **arm64 only**

Broader first-time machine setup: [INSTALLATION.md](INSTALLATION.md).

---

## A. Do it yourself — click by click (no AI needed)

Follow **A1 → A6** in order. Use **Windows PowerShell** (search “PowerShell” in Start menu → Open).

### A1. Prepare the phone (one time per phone)

1. Unlock the phone.  
2. Open **Settings**.  
3. Tap **About phone** (sometimes under **My device** / **System**).  
4. Find **Build number** (or **Version** → **Build number**).  
5. Tap **Build number** **7 times** until it says you are a developer.  
6. Go **Back** to Settings.  
7. Open **Developer options** (often under **System** / **Additional settings**).  
8. Turn **ON**:
   - **USB debugging**
   - (Optional) **Install via USB** / **USB debugging (Security settings)** if you see it  
9. Plug the phone into the PC with a **data USB cable** (not charge-only).  
10. On the phone popup **Allow USB debugging?** → tap **Allow** (check “Always allow” if you want).  
11. If it says **Unauthorized** later, unplug/replug and tap **Allow** again.

### A2. Open PowerShell and set tools (every time)

1. Press **Windows key**, type `PowerShell`, press **Enter**.  
2. Copy **all** of this, paste into PowerShell, press **Enter**:

```powershell
$env:JAVA_HOME = (Get-ChildItem "C:\Program Files\Microsoft" -Directory -Filter "jdk-17*" | Select-Object -First 1).FullName
$env:ANDROID_HOME = "D:\Android\Sdk"
$env:Path = "$env:JAVA_HOME\bin;D:\flutter\bin;D:\Android\Sdk\platform-tools;D:\Android\Sdk\cmdline-tools\latest\bin;$env:Path"
$env:GIT_CONFIG_COUNT = "1"
$env:GIT_CONFIG_KEY_0 = "safe.directory"
$env:GIT_CONFIG_VALUE_0 = "*"
```

3. Check tools work (paste one line at a time, Enter each):

```powershell
java -version
flutter --version
adb version
adb devices
```

4. In `adb devices` you must see your phone ending with **`device`**.  
   - If **`unauthorized`** → look at phone screen → tap **Allow**.  
   - If empty → check cable, USB mode (File transfer / MTP), USB debugging on.

### A3. Build the latest APK (when you changed code, or want a fresh build)

1. In the **same** PowerShell window, paste:

```powershell
cd D:\MACKHAN\mobile
flutter build apk --debug --target-platform android-arm64
```

2. Wait until you see:

```text
√ Built build\app\outputs\flutter-apk\app-debug.apk
```

3. If it fails with **Java heap space**, paste this then rebuild §A3 again:

```powershell
Get-Process java -ErrorAction SilentlyContinue | ForEach-Object { Stop-Process -Id $_.Id -Force }
```

(Heap is already set to 1536m in the project — killing old Java is what usually fixes it.)

### A4. Install that APK on the connected phone

1. Phone still plugged in, USB debugging allowed.  
2. Paste:

```powershell
cd D:\MACKHAN\mobile
adb install -r "build\app\outputs\flutter-apk\app-debug.apk"
```

3. Wait for **`Success`**.  
4. Open the app:

```powershell
adb shell am start -n com.mackhan.mackhan/.MainActivity
```

Or on the phone: find app **Pixel Lift** → tap it.

**Two phones connected?** First run `adb devices`, copy the serial, then:

```powershell
adb -s PASTE_SERIAL_HERE install -r "build\app\outputs\flutter-apk\app-debug.apk"
adb -s PASTE_SERIAL_HERE shell am start -n com.mackhan.mackhan/.MainActivity
```

### A5. Make login work (USB tunnel + backend) — every plug-in

Login needs the PC backend. Do this **every time you plug the cable**:

1. **Start backend** — open a **second** PowerShell window, paste §A2 env lines (or at least Node on PATH), then:

```powershell
cd D:\MACKHAN\backend
node server.js
```

2. Leave that window **open**. (Seeing activity / no crash = good. A 404 on `/` in a browser is OK.)

3. Back in the **first** PowerShell (with adb), paste:

```powershell
adb reverse tcp:3000 tcp:3000
adb reverse tcp:8000 tcp:8000
adb reverse --list
```

You should see lines with `tcp:3000` and `tcp:8000`.

4. On the phone, in Pixel Lift **Sign in**:

| Field | Type this |
|-------|-----------|
| Email | `pixel.lift.demo@gmail.com` |
| Password | `Lift@12345` |

5. Tap **Login**.  
6. On Home, tap **Open Pixel Lift** → **Start Lift** → **Modes**.

**Important:** If you **unplug** USB, login/API stop until you plug in again and repeat **A5 steps 3–4** (and start backend if it was closed).

### A6. Fast “install again” (APK already built)

If you did **not** change code and only need to put the same latest APK back on the phone:

1. Plug phone → tap **Allow** if asked.  
2. PowerShell → paste §A2 env block.  
3. Paste:

```powershell
adb devices
cd D:\MACKHAN\mobile
adb install -r "build\app\outputs\flutter-apk\app-debug.apk"
adb reverse tcp:3000 tcp:3000
adb reverse tcp:8000 tcp:8000
adb shell am start -n com.mackhan.mackhan/.MainActivity
```

4. Start backend (§A5) if you need login.  
5. Log in if asked.

---

## What already worked vs what to avoid

| Do (succeeded) | Don’t (failed / not needed) |
|----------------|-----------------------------|
| `flutter build apk --debug --target-platform android-arm64` | Full multi-ABI debug (corrupt/jetify OOM on this PC) |
| Gradle heap **1536m** + kill leftover `java` before rebuild | Leaving old Gradle Java running (heap space) |
| `adb install -r` over USB | Relying on Wi‑Fi `192.168.x.x` without firewall (phone often can’t reach PC) |
| `adb reverse` + app URL `http://127.0.0.1:3000` | Expecting login after unplug without re-running reverse |
| `cd D:\MACKHAN\mobile` before flutter | Running flutter from `D:\MACKHAN` (no pubspec) |
| `flutter build` for APK | `flutter run --target-platform` (invalid flag) |

---

## 0. Paths on this machine (adjust if yours differ)

| Tool | Path |
|------|------|
| Flutter | `D:\flutter\bin` |
| Android SDK | `D:\Android\Sdk` |
| `adb` | `D:\Android\Sdk\platform-tools` |
| JDK 17 | `C:\Program Files\Microsoft\jdk-17*` (OpenJDK 17) |
| Project | `D:\MACKHAN` |
| App folder | `D:\MACKHAN\mobile` |
| APK output | `D:\MACKHAN\mobile\build\app\outputs\flutter-apk\app-debug.apk` |
| Gradle / Maven cache | `D:\mackhan-cache` (see `mobile/android/gradle.properties`) |

---

## 1. Open PowerShell and set environment (every new window)

Run this **first** in every new PowerShell session:

```powershell
$env:JAVA_HOME = (Get-ChildItem "C:\Program Files\Microsoft" -Directory -Filter "jdk-17*" | Select-Object -First 1).FullName
$env:ANDROID_HOME = "D:\Android\Sdk"
$env:Path = "$env:JAVA_HOME\bin;D:\flutter\bin;D:\Android\Sdk\platform-tools;D:\Android\Sdk\cmdline-tools\latest\bin;$env:Path"

# Optional: avoids Flutter "dubious ownership" errors on D:\flutter after Windows reset
$env:GIT_CONFIG_COUNT = "1"
$env:GIT_CONFIG_KEY_0 = "safe.directory"
$env:GIT_CONFIG_VALUE_0 = "*"

java -version
flutter --version
adb version
```

If `java` / `flutter` / `adb` are “not recognized,” PATH is wrong — fix paths above, then **close and reopen** PowerShell.

---

## 2. Connect the phone (USB)

### On the phone

1. Enable **Developer options** (tap Build number 7 times in About phone).  
2. Enable **USB debugging**.  
3. Plug USB into the PC.  
4. Accept **Allow USB debugging** when the phone asks.

### On the PC

```powershell
adb devices
```

You want a line like:

```text
XXXXXXXX    device
```

| Status | Meaning | Fix |
|--------|---------|-----|
| `device` | OK | Continue |
| `unauthorized` | Phone didn’t allow PC | Unlock phone → Allow USB debugging |
| empty list | No connection | New cable / different USB port / re-enable debugging |

**New phone example (Vivo V2352):** serial `10FEBS02QE000A2` — use `-s SERIAL` if more than one device is connected.

```powershell
adb devices -l
adb shell getprop ro.product.cpu.abi
# Expect: arm64-v8a  → use android-arm64 build below
```

---

## 3. Build the latest debug APK (known-good way)

```powershell
cd D:\MACKHAN\mobile

# Optional: free RAM if a previous build hung
# Get-Process java -ErrorAction SilentlyContinue | ForEach-Object { Stop-Process -Id $_.Id -Force }

flutter build apk --debug --target-platform android-arm64
```

**Success looks like:**

```text
√ Built build\app\outputs\flutter-apk\app-debug.apk
```

**Why these flags?**

| Flag | Why |
|------|-----|
| `--debug` | Faster; fine for testing |
| `--target-platform android-arm64` | Matches real phones; avoids bad/corrupt 32-bit & x86 engine JARs on this PC |

**Do not use** `--target-platform` with `flutter run` (that flag is for `flutter build` only).

### If build fails with `Java heap space`

In `mobile/android/gradle.properties` heap should be at least:

```properties
org.gradle.jvmargs=-Xmx1536m -XX:MaxMetaspaceSize=512m -XX:+UseSerialGC
```

Then stop leftover Java and rebuild:

```powershell
Get-Process java -ErrorAction SilentlyContinue | ForEach-Object { Stop-Process -Id $_.Id -Force }
cd D:\MACKHAN\mobile
flutter build apk --debug --target-platform android-arm64
```

---

## 4. Install APK on the phone

### One phone connected

```powershell
cd D:\MACKHAN\mobile
adb install -r "build\app\outputs\flutter-apk\app-debug.apk"
```

`-r` = replace / upgrade if already installed.

### Specific phone (when several are listed)

```powershell
adb devices
adb -s YOUR_SERIAL install -r "build\app\outputs\flutter-apk\app-debug.apk"
```

Example:

```powershell
adb -s 10FEBS02QE000A2 install -r "build\app\outputs\flutter-apk\app-debug.apk"
```

### Open the app

```powershell
adb shell am start -n com.mackhan.mackhan/.MainActivity
```

Or tap **Pixel Lift** on the phone.

### Uninstall old app first (optional clean install)

```powershell
adb uninstall com.mackhan.mackhan
adb install "build\app\outputs\flutter-apk\app-debug.apk"
```

(Samsung sometimes returns `DELETE_FAILED_INTERNAL_ERROR`; `adb install -r` still usually updates the app.)

---

## 5. Login — USB tunnel (required while backend runs on the PC)

The app’s `mobile/assets/.env` (baked into the APK) currently uses:

```text
API_BASE_URL=http://127.0.0.1:3000
ML_SERVICE_URL=http://127.0.0.1:8000
```

`127.0.0.1` on the phone means **the phone itself**, unless you tunnel USB with `adb reverse`. So:

### Every time you plug the phone in

```powershell
adb reverse tcp:3000 tcp:3000
adb reverse tcp:8000 tcp:8000
adb reverse --list
```

Specific device:

```powershell
adb -s YOUR_SERIAL reverse tcp:3000 tcp:3000
adb -s YOUR_SERIAL reverse tcp:8000 tcp:8000
```

**If you unplug USB, reverse tunnels die** → login / API fail until you plug in and run `adb reverse` again.

### Start the backend (PC)

```powershell
cd D:\MACKHAN\backend
# Need Node on PATH; serviceAccountKey.json + .env already set for this project
node server.js
```

Leave that window open. Quick check:

```powershell
# 404 on / is OK — server is up; there is no route for /
Invoke-WebRequest -Uri "http://127.0.0.1:3000/" -UseBasicParsing
```

### Demo account (already created & verified)

| Field | Value |
|-------|--------|
| Email | `pixel.lift.demo@gmail.com` |
| Password | `Lift@12345` |

Older test account (if still valid):

| Field | Value |
|-------|--------|
| Email | `tester@mackhan.com` |
| Password | `Test@12345` |

### Login on the phone

1. Keep USB plugged.  
2. `adb reverse` as above.  
3. Backend running.  
4. Open Pixel Lift → Sign in → enter email/password → **Login**.  
5. Home → **Open Pixel Lift** → **Start Lift** → **Modes**.

### After you are logged in

- **Live background removal** works **without USB** (on-device ML Kit).  
- Unplug is OK for camera testing.  
- Plug USB + `adb reverse` again if you need login, refresh session, or HQ Capture to the PC ML service.

---

## 6. One-shot script (new phone + latest APK)

Copy all of this after section 1 env setup:

```powershell
cd D:\MACKHAN\mobile

# Build
flutter build apk --debug --target-platform android-arm64

# Pick device (if only one phone, adb without -s is fine)
adb devices
$serial = (adb devices | Select-String "`tdevice" | ForEach-Object { ($_ -split "\s+")[0] } | Select-Object -First 1)
Write-Output "Using device: $serial"

# Install + tunnel + open
adb -s $serial install -r "build\app\outputs\flutter-apk\app-debug.apk"
adb -s $serial reverse tcp:3000 tcp:3000
adb -s $serial reverse tcp:8000 tcp:8000
adb -s $serial shell am start -n com.mackhan.mackhan/.MainActivity
```

Then log in with `pixel.lift.demo@gmail.com` / `Lift@12345`.

---

## 7. Copy APK without `adb` (optional — not our main success path)

We always used **`adb install -r`** (§4). Manual copy only if you must:

1. Build as in §3.  
2. Copy:

```text
D:\MACKHAN\mobile\build\app\outputs\flutter-apk\app-debug.apk
```

3. On phone: open file → Install.  
4. Login still needs the **successful** way: USB + `adb reverse` + local backend (§5), or a hosted API later.

---

## 8. Create a new account via API (optional)

Backend must be running. PowerShell:

```powershell
$body = @{
  fullName = "Your Name"
  email    = "you@example.com"
  password = "YourPass@123"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://127.0.0.1:3000/api/auth/register" `
  -Method Post -ContentType "application/json" -Body $body
```

OTP is logged in the backend console as `[dev OTP] ...` when SMTP is not configured. Then:

```powershell
$verify = @{ email = "you@example.com"; code = "123456" } | ConvertTo-Json
Invoke-RestMethod -Uri "http://127.0.0.1:3000/api/auth/verify" `
  -Method Post -ContentType "application/json" -Body $verify
```

Use the same email/password in the app.

---

## 9. Useful adb helpers

```powershell
# Screenshot to PC
adb shell screencap -p /sdcard/s.png
adb pull /sdcard/s.png .
adb shell rm /sdcard/s.png

# Clear app data (forces logout / fresh Sign in)
adb shell pm clear com.mackhan.mackhan

# Force-stop
adb shell am force-stop com.mackhan.mackhan

# Live logs (Flutter)
adb logcat | Select-String "flutter"
```

---

## 10. Troubleshooting

| Problem | Likely cause | Fix |
|---------|--------------|-----|
| Login fails after unplug | `adb reverse` gone | Plug USB → `adb reverse tcp:3000 tcp:3000` |
| Splash hangs forever | Old bug / no API | Use latest APK; ensure backend + reverse; clear app data if needed |
| `Java heap space` | Gradle OOM | Raise heap in `gradle.properties`; kill `java` processes; rebuild |
| `No pubspec.yaml` | Wrong folder | `cd D:\MACKHAN\mobile` first |
| App closes on open | Missing ReLinker (old) | Current `app/build.gradle.kts` has ReLinker — rebuild latest |
| Build wants wrong ABI | Emulator/x86 cache | Always `--target-platform android-arm64` for phones |
| `flutter` engine version error | Dubious ownership on `D:\flutter` | Set `GIT_CONFIG_*` as in §1 |
| Two phones, wrong target | Default adb device | Use `adb -s SERIAL ...` |

---

## 11. Checklist (print / keep)

- [ ] §1 env vars set in this PowerShell  
- [ ] `adb devices` → `device`  
- [ ] Backend: `node server.js` in `backend/`  
- [ ] `flutter build apk --debug --target-platform android-arm64`  
- [ ] `adb install -r ...\app-debug.apk`  
- [ ] `adb reverse tcp:3000 tcp:3000`  
- [ ] Login with demo account  
- [ ] Open Pixel Lift → Start Lift  

---

## 12. Related docs

| Doc | Use when |
|-----|----------|
| [INSTALLATION.md](INSTALLATION.md) | First-time machine setup (JDK, SDK, Flutter) |
| [API.md](API.md) | Auth / profile / ML endpoints |
| [DEPLOYMENT.md](DEPLOYMENT.md) | Host backend online (no USB login) |
| [PIXEL_LIFT_PLAN.md](PIXEL_LIFT_PLAN.md) | Product polish / modes / accuracy roadmap |

---

*Last verified: same commands that succeeded — Windows, arm64 phone, USB `adb install -r`, `adb reverse`, local Express `:3000`, demo account login.*
