# MACKHAN — STEPS (agent handoff + PowerShell runbook)

## Can I put the full app on the phone again?

**YES.** Product is Flutter Android in `D:\MACKHAN\mobile`. Goal = backend + ML + `flutter run` on phone `RRCW900YP4V`.

**Hard requirements before Phase I succeeds:**
1. Phone USB plugged → `adb devices` shows `RRCW900YP4V    device`
2. PC + phone same Wi‑Fi; `mobile\assets\.env` uses PC IPv4 (last known `192.168.100.118`)
3. **C: FreeGB ≥ 4** (A1→A3→**A8**→A10 if not)
4. **Free RAM ≥ 2000 MB** (Phase C). This PC is ~4 GB total — **close Chrome/Edge and prefer build outside Cursor** or Flutter OOMs
5. Backend `:3000` up; ML `:8000` up only if testing HQ capture (live cutout = on-device ML Kit, no ML server)

---

## NEW CHAT — what you type

Paste this in a **new Cursor chat**:

```
Read D:\MACKHAN\STEPS.MD fully (especially AGENT PROTOCOL + SESSION MEMORY).
Do the full phone run: Phase A (if C:<4GB) → B if DNS broken → C → D → E → F → G → H → I.
Run the commands yourself. Do not only paste instructions.
Keep phone on USB. Stop if personal-data risk. Report after each phase.
```

That is enough — this file is the session memory for the next agent.

---

## AGENT PROTOCOL (mandatory for every new chat)

When user says **read STEPS.MD / do it / full flutter / app on phone**:

1. Read this whole file + `docs/PLAN.md` boundary + `.cursor/skills/ponytail/SKILL.md`
2. Run phases **in order**. Prefer **executing** PowerShell via Shell tool over telling user to copy-paste
3. **Never** delete Documents/Desktop/Pictures/Videos/Music/`D:\MACKHAN`/browser passwords
4. Skip A2 Recycle Bin unless user asks
5. If C: FreeGB ≥ 4 → skip heavy A3–A9; still run A1
6. If DNS already resolves `dl.google.com` → skip B2 Admin set (still flushdns if builds fail with No such host)
7. Phase C: kill chrome/msedge/java/dart leftovers; warn if FreeMB &lt; 2000 — Flutter build will OOM inside Cursor
8. Phase G/H: start servers in background if not healthy; check `/api/health` and `/health`
9. Phase I: set all `D:\mackhan-cache` env vars + `GRADLE_USER_HOME` + `flutter run -d RRCW900YP4V`
10. On failure: fix root cause from **KNOWN FAILURES** below, retry once, then report exact error
11. Update **SESSION MEMORY** date/status at top of this file when a phase succeeds or state changes
12. Update `docs/LOG.md` after meaningful progress

**Do not** invent new product features. Stay inside PLAN §0–§13.

---

## SESSION MEMORY (update this after each run)

| Field | Value (2026-07-27 night — full phone run) |
|-------|----------------------------|
| **Goal** | Full app on phone via `flutter run` |
| **Phone ADB id** | `RRCW900YP4V` — **device** (USB OK this session) |
| **PC IPv4 (last)** | `192.168.100.118` — matches `mobile\assets\.env` |
| **Flutter** | `D:\flutter` |
| **Android SDK** | `D:\Android\Sdk` |
| **Caches** | `D:\mackhan-cache\` ready (tmp, pub-cache, gradle, npm, pip, manual) |
| **C: free** | **4.79 GB** — Phase A skipped heavy clean (already ≥4) |
| **D: free** | ~**26 GB** |
| **RAM** | **~4 GB total / FreeMB ~500 with Cursor** → Phase I **blocked**; close Cursor, run I in external PowerShell |
| **Backend** | **Healthy** `http://localhost:3000/api/health` → `status:ok` |
| **ML** | **Down** — venv bare; TF wheel curl in progress → `D:\mackhan-cache\manual\tensorflow-2.21.0-cp311-cp311-win_amd64.whl` (~30 KB/s); then `pip install` + model + uvicorn |
| **JWT** | backend ↔ ml-service **MATCH** (len 64) |
| **DNS** | Wi-Fi already `8.8.8.8`/`8.8.4.4`; `dl.google.com` resolves |
| **Gradle on C leftover** | `C:\Users\AP\.gradle` may still have ~0.5 GB locked; live home is `D:\mackhan-cache\gradle` |
| **Android fixes already in repo** | Manifest `tools:replace` for storage; `gradle.properties` low heap + `maven.repo.local` on D; arm64 `abiFilters`; lifecycle force in `android/build.gradle.kts` |
| **Prior fail modes** | C: full; DNS (router-only); Gradle SSL/host; OOM; bad `local-m2.gradle` init (deleted); lifecycle missing (forced); **pip TF hang** (use curl to D:\mackhan-cache\manual) |

### Known failures → fix

| Symptom | Fix |
|---------|-----|
| C: &lt; 1–2 GB / weird shell fails | Phase A especially **A8** (delete C `.gradle` caches) |
| `No such host` / SSL to Google Maven | Phase B DNS 8.8.8.8 + flushdns |
| `OutOfMemory` / Dart or Kotlin killed | Phase C — FreeMB ≥ 2000, close Cursor, rebuild in external PowerShell |
| `unauthorized` adb | Unlock phone → Allow USB debugging → Phase E |
| Backend 401 / ML JWT | Phase F — JWT_SECRET must match backend + ml-service `.env` |
| HQ capture fails, live preview OK | Start Phase H (ML); live cutout does not need ML |
| App can’t reach API | Same Wi‑Fi + update `mobile\assets\.env` to current PC IPv4 |

### Transcript / prior chat
Long prior agent thread: Cursor agent transcript `5327814e-849f-4819-b6ee-29e5a0ef0e0b` (C: cleanup, STEPS rewrite, Flutter build attempts). Prefer **this file** over re-reading the whole transcript.

---

## Two ways to run

**A) Agent runs it (preferred):** new chat + the paste block above.  
**B) You run PowerShell yourself:** close Cursor for Phase I, copy one phase block at a time.

Phone USB in. PC + phone same Wi‑Fi.  
**Phase A order that frees space:** A1 → A3 → **A8** → A9 → A10 (A4–A6 often free 0 MB).

---

# SAFETY — what these commands never touch

**Never deleted by this runbook:**
- Documents, Desktop, Pictures, Videos, Music  
- Your project `D:\MACKHAN`  
- Browser bookmarks / passwords (we only *close* Chrome, we don’t wipe profile)  
- Installed programs (except their temp/cache)  
- Photos, WhatsApp data, personal folders you created  

| Step | Deletes personal data? | Notes |
|------|------------------------|--------|
| A1, A7, A10, B1, B3, B4, C1, C4 | **No** — read only | Safe |
| A3 Temp wipe | **No** | User + Windows Temp (locked files skip) |
| A4 Update cache | **No** | Often already **0 MB** — “did nothing” is normal |
| A5 Thumbnails | **No** | Explorer thumbnail cache only |
| A6 npm/pip | **No** | Package caches only (often already empty) |
| A8 Leftover `.gradle` on C: | **No** | Safe if `D:\mackhan-cache\gradle` exists (Phase D) |
| A9 Browser/editor cache | **No** | Cache folders only — not bookmarks/passwords |
| A2 Recycle Bin | **Caution** | Only what is *already in* Recycle Bin |
| A11 Disk Cleanup | **You choose** | Temp / Update / Thumbnails — **not** Downloads |
| C2/C3 Stop processes | **No** | Closes apps; does not delete files |
| D–K build/run | **No** | Create folders / run servers / flutter |

**Skip A2** if you might still restore something from Recycle Bin.  
**In A11**, never tick “Downloads” or anything that looks like personal files.

### Why clean “doesn’t work”
If FreeGB barely moves, the step is usually **already empty** (Update Download, Recycle Bin, Win Temp, npm/pip).  
On this PC the real C: hog was leftover **`C:\Users\AP\.gradle`** (~3+ GB) while builds use **`D:\mackhan-cache\gradle`**. That is **A8** — do not skip A8 when C: is full.

---

# PHASE A — Free space on C: (REQUIRED)

## A1 — See how full C: and D: are (SAFE — read only)
```powershell
Get-PSDrive C,D | Format-Table Name,@{N='FreeGB';E={[math]::Round($_.Free/1GB,2)}},@{N='UsedGB';E={[math]::Round($_.Used/1GB,2)}}
```
Goal: **C: FreeGB ≥ 5** (4+ is workable; 10 is better).

## A2 — Empty Recycle Bin (OPTIONAL — skip if unsure)
Only removes items **already in Recycle Bin** (not your Documents/Photos).  
If you emptied something important into the bin and might restore it → **SKIP A2**.  
If you see “path not found” → Bin is already empty — ignore and continue.
```powershell
Clear-RecycleBin -Force -ErrorAction SilentlyContinue
Write-Host "Recycle Bin cleared (or already empty)"
```

## A3 — Wipe unlockable TEMP (SAFE for personal data)
Deletes whatever is **not locked** under user Temp + `C:\Windows\Temp`.  
Does **not** touch Documents, Desktop, Pictures, Downloads, or `D:\MACKHAN`.  
Locked files (Cursor/Chrome open) are skipped — close those apps first for a bigger free.
```powershell
$before = (Get-PSDrive C).Free
$n = 0
Get-ChildItem $env:TEMP -Force -ErrorAction SilentlyContinue | ForEach-Object {
  try { Remove-Item $_.FullName -Recurse -Force -ErrorAction Stop; $n++ } catch {}
}
Get-ChildItem "$env:LOCALAPPDATA\Temp" -Force -ErrorAction SilentlyContinue | ForEach-Object {
  try { Remove-Item $_.FullName -Recurse -Force -ErrorAction Stop; $n++ } catch {}
}
Get-ChildItem "C:\Windows\Temp" -Force -ErrorAction SilentlyContinue | ForEach-Object {
  try { Remove-Item $_.FullName -Recurse -Force -ErrorAction Stop; $n++ } catch {}
}
$after = (Get-PSDrive C).Free
Write-Host ("Temp: removed $n items, freed ~{0:N0} MB" -f (($after-$before)/1MB))
```

## A4 — Clear Windows Update download cache (SAFE)
Often **already 0 MB** — that is fine, continue to A8.  
Needs Admin sometimes; without Admin, locked files are skipped.
```powershell
$before = (Get-PSDrive C).Free
Stop-Service wuauserv -Force -ErrorAction SilentlyContinue
Remove-Item "C:\Windows\SoftwareDistribution\Download\*" -Recurse -Force -ErrorAction SilentlyContinue
Start-Service wuauserv -ErrorAction SilentlyContinue
$after = (Get-PSDrive C).Free
Write-Host ("Update cache freed ~{0:N0} MB (0 is OK if already empty)" -f (($after-$before)/1MB))
```

## A5 — Clear Explorer thumbnail cache (SAFE, optional)
```powershell
Remove-Item "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\thumbcache_*.db" -Force -ErrorAction SilentlyContinue
Write-Host "Thumbnail cache cleared"
```

## A6 — Clear npm / pip download caches (SAFE)
Often already empty if caches live on D:. Warnings like “No matching packages” = nothing to clear.
```powershell
npm cache clean --force 2>$null
pip cache purge 2>$null
Write-Host "npm/pip cache cleaned (0 files = already empty)"
```

## A7 — See the real C: space hogs (SAFE — read only)
```powershell
@(
  "$env:USERPROFILE\.gradle",
  "$env:LOCALAPPDATA\Temp",
  "$env:LOCALAPPDATA\Pub\Cache",
  "$env:LOCALAPPDATA\Android",
  "$env:LOCALAPPDATA\Google",
  "$env:LOCALAPPDATA\Microsoft",
  "$env:USERPROFILE\Downloads",
  "C:\Windows\SoftwareDistribution\Download"
) | ForEach-Object {
  if (Test-Path $_) {
    $s = (Get-ChildItem $_ -Recurse -File -Force -ErrorAction SilentlyContinue |
      Measure-Object -Property Length -Sum).Sum
    [PSCustomObject]@{ GB = [math]::Round(($s/1GB),2); Path = $_ }
  }
} | Sort-Object GB -Descending | Format-Table -AutoSize
```
If `Downloads` is huge: **move** big installers/zips to `D:\` — do not delete photos/docs unless sure.

## A8 — Delete leftover Gradle on C: (SAFE if D: cache exists) — DO THIS WHEN C: IS FULL
Builds must use `GRADLE_USER_HOME=D:\mackhan-cache\gradle` (Phase D + I).  
Old cache often still sits on **`C:\Users\AP\.gradle`** and can be **3+ GB**. That is why A3–A6 looked broken.
```powershell
# Run Phase D once first if D:\mackhan-cache\gradle is missing
New-Item -ItemType Directory -Force -Path D:\mackhan-cache\gradle | Out-Null
$before = (Get-PSDrive C).Free
$gradleC = "$env:USERPROFILE\.gradle"
if (Test-Path $gradleC) {
  foreach ($t in @("caches","daemon","native","wrapper\dists")) {
    $p = Join-Path $gradleC $t
    if (Test-Path $p) {
      Write-Host "Removing $p ..."
      Remove-Item $p -Recurse -Force -ErrorAction SilentlyContinue
    }
  }
}
$after = (Get-PSDrive C).Free
Write-Host ("Gradle-on-C freed ~{0:N0} MB  C free now {1:N2} GB" -f (($after-$before)/1MB), ($after/1GB))
```
If a long-path error appears, ignore leftovers (~0.5 GB) and continue — you usually already freed enough.

## A9 — Browser + Cursor/VS Code caches only (SAFE — optional)
Closes nothing. Does **not** delete bookmarks, passwords, or project files.  
Bigger free if Chrome/Edge/Cursor are closed first (Phase C).
```powershell
$before = (Get-PSDrive C).Free
foreach ($p in @(
  "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache",
  "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Code Cache",
  "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\GPUCache",
  "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache",
  "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Code Cache",
  "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\GPUCache",
  "$env:APPDATA\Cursor\Cache",
  "$env:APPDATA\Cursor\CachedData",
  "$env:APPDATA\Cursor\Code Cache",
  "$env:APPDATA\Cursor\GPUCache"
)) {
  if (Test-Path $p) {
    Get-ChildItem $p -Force -ErrorAction SilentlyContinue | ForEach-Object {
      try { Remove-Item $_.FullName -Recurse -Force -ErrorAction Stop } catch {}
    }
  }
}
$after = (Get-PSDrive C).Free
Write-Host ("Browser/editor cache freed ~{0:N0} MB" -f (($after-$before)/1MB))
```

## A10 — Check C: again (SAFE — read only)
```powershell
Get-PSDrive C,D | Format-Table Name,@{N='FreeGB';E={[math]::Round($_.Free/1GB,2)}}
```
If still &lt; 4 GB: re-run **A8**, then **A3** with browsers/Cursor closed, then **move** big Downloads to `D:\`.

## A11 — Disk Cleanup GUI (YOU choose boxes — be careful)
```powershell
cleanmgr /d C
```
**Safe to tick:** Temporary files, Recycle Bin, Thumbnails, Delivery Optimization, Windows Update cleanup.  
**Do NOT tick:** Downloads, or anything that lists your personal folders.

---

# PHASE B — Fix DNS (REQUIRED, once)

## B1 — See current DNS
```powershell
Get-DnsClientServerAddress -AddressFamily IPv4 |
  Where-Object { $_.InterfaceAlias -match 'Wi-Fi|Ethernet|WiFi' } |
  Format-Table InterfaceAlias,ServerAddresses
```

## B2 — Set Google DNS on Wi-Fi (needs Admin PowerShell)
Right‑click Start → **Windows PowerShell (Admin)** → run:
```powershell
Set-DnsClientServerAddress -InterfaceAlias "Wi-Fi" -ServerAddresses "8.8.8.8","8.8.4.4"
Get-DnsClientServerAddress -InterfaceAlias "Wi-Fi" -AddressFamily IPv4
```
If alias is different (e.g. `WiFi`), use that name from B1.

## B3 — Flush DNS
```powershell
ipconfig /flushdns
```

## B4 — Test Google hosts resolve
```powershell
Resolve-DnsName dl.google.com -Server 8.8.8.8 | Select-Object -First 3
Resolve-DnsName storage.googleapis.com -Server 8.8.8.8 | Select-Object -First 3
[System.Net.Dns]::GetHostAddresses("dl.google.com") | Select-Object -First 2
```
All three should show IPs, not errors.

---

# PHASE C — Free RAM (REQUIRED before Flutter build)

## C1 — See free RAM
```powershell
$os = Get-CimInstance Win32_OperatingSystem
"TotalMB=$([math]::Round($os.TotalVisibleMemorySize/1KB)) FreeMB=$([math]::Round($os.FreePhysicalMemory/1KB))"
```
Goal before Flutter: **FreeMB ≥ 2000**.

## C2 — Close Chrome / Edge (frees a lot)
```powershell
Stop-Process -Name chrome,msedge,msedgewebview2 -Force -ErrorAction SilentlyContinue
Write-Host "Browsers closed"
```

## C3 — Stop leftover Java / Dart / Gradle from failed builds
```powershell
Stop-Process -Name java,dart,dartvm,gradle -Force -ErrorAction SilentlyContinue
Write-Host "Build leftovers stopped"
```

## C4 — See what still uses RAM
```powershell
Get-Process | Sort-Object WorkingSet64 -Descending |
  Select-Object -First 12 Name,@{N='MB';E={[math]::Round($_.WorkingSet64/1MB)}} |
  Format-Table -AutoSize
$os = Get-CimInstance Win32_OperatingSystem
"FreeMB=$([math]::Round($os.FreePhysicalMemory/1KB))"
```

## C5 — If FreeMB still &lt; 2000
Close more apps in Task Manager (Ctrl+Shift+Esc): Discord, Teams, Spotify, extra Explorer windows.  
**For Phase I, strongest option:** close **Cursor** and run Phase I in a normal PowerShell window (this PC only has ~4 GB RAM — Cursor + Flutter often OOMs). Re-check:
```powershell
$os = Get-CimInstance Win32_OperatingSystem
"FreeMB=$([math]::Round($os.FreePhysicalMemory/1KB))"
```
If agent is running inside Cursor and FreeMB &lt; 1500: stop, tell user to close Cursor and run Phase I paste from this file, or close Chrome and retry once.

---

# PHASE D — One-time folders on D: (run once)

```powershell
New-Item -ItemType Directory -Force -Path `
  D:\mackhan-cache\tmp,
  D:\mackhan-cache\pub-cache,
  D:\mackhan-cache\gradle,
  D:\mackhan-cache\npm,
  D:\mackhan-cache\pip | Out-Null
Write-Host "D:\mackhan-cache ready"
```

---

# PHASE E — Phone must show as device

```powershell
$env:Path = [Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [Environment]::GetEnvironmentVariable("Path","User")
if (Test-Path "D:\Android\Sdk") { $env:ANDROID_HOME = "D:\Android\Sdk" } else { $env:ANDROID_HOME = "$env:LOCALAPPDATA\Android\Sdk" }
adb kill-server
adb start-server
adb devices
```
Must show: `RRCW900YP4V    device`  
If `unauthorized` → unlock phone → Allow USB debugging → run `adb devices` again.

---

# PHASE F — Env check (quick)

```powershell
Select-String -Path D:\MACKHAN\backend\.env,D:\MACKHAN\ml-service\.env -Pattern '^JWT_SECRET='
Get-Content D:\MACKHAN\mobile\assets\.env
ipconfig | Select-String "IPv4"
```
JWT lines must match.  
Phone URLs must use your PC IPv4 (example `192.168.100.118`). If IP changed, edit `D:\MACKHAN\mobile\assets\.env` then continue.

---

# PHASE G — Terminal 1: Backend (leave this window OPEN)

Open a **new** PowerShell window for backend:
```powershell
$env:TEMP = "D:\mackhan-cache\tmp"; $env:TMP = "D:\mackhan-cache\tmp"
$env:npm_config_cache = "D:\mackhan-cache\npm"
cd D:\MACKHAN\backend
npm run dev
```
Wait until you see server listening on 3000. Test in another window:
```powershell
Invoke-WebRequest http://localhost:3000/api/health -UseBasicParsing
```
Expect JSON with `"status":"ok"`.

---

# PHASE H — Terminal 2: ML service (leave OPEN)

New PowerShell window:
```powershell
$env:TEMP = "D:\mackhan-cache\tmp"; $env:TMP = "D:\mackhan-cache\tmp"
$env:PIP_CACHE_DIR = "D:\mackhan-cache\pip"
cd D:\MACKHAN\ml-service
.\.venv\Scripts\Activate.ps1
```
If Activate blocked:
```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
.\.venv\Scripts\Activate.ps1
```

Install + model + start (first time slow):
```powershell
python -m pip install -r requirements.txt
python scripts/download_model.py
python -m uvicorn main:app --reload --host 0.0.0.0 --port 8000
```
Test:
```powershell
Invoke-WebRequest http://localhost:8000/health -UseBasicParsing
```

---

# PHASE I — Terminal 3: Flutter → phone (THE BUILD)

New PowerShell window. **Confirm RAM first:**
```powershell
$os = Get-CimInstance Win32_OperatingSystem
"FreeMB=$([math]::Round($os.FreePhysicalMemory/1KB))"
```
If FreeMB &lt; 2000 → go back to Phase C.

Then set env + run (first build 10–30+ minutes):
```powershell
$env:Path = [Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [Environment]::GetEnvironmentVariable("Path","User")
if (Test-Path "D:\Android\Sdk") { $env:ANDROID_HOME = "D:\Android\Sdk" } else { $env:ANDROID_HOME = "$env:LOCALAPPDATA\Android\Sdk" }
$env:TEMP = "D:\mackhan-cache\tmp"
$env:TMP = "D:\mackhan-cache\tmp"
$env:TMPDIR = "D:\mackhan-cache\tmp"
$env:PUB_CACHE = "D:\mackhan-cache\pub-cache"
$env:GRADLE_USER_HOME = "D:\mackhan-cache\gradle"
cd D:\MACKHAN\mobile
adb devices
flutter pub get
flutter run -d RRCW900YP4V
```

Success signs:
- `Flutter run key commands` / app opens on phone  
- Hot reload: press `r` in that window after code changes  

If **Out of Memory** → close more apps, FreeMB ≥ 2000, run Phase I again.  
If **No such host** → re-do Phase B.  
If **unauthorized** → re-do Phase E.

---

# PHASE J — After app is installed: prove ALL features

Keep G + H + I windows running.

| Feature | What you do on phone | Needs |
|---------|----------------------|--------|
| App opens | Launch MACKHAN | Phase I |
| Register / login | Create account / sign in | Backend (G) + Firebase |
| Profile | Open profile, save | Backend (G) |
| **Real-time BG removal** | Open camera — live cutout | On-device ML Kit only |
| **HQ capture** | Capture / HQ button | ML (H) + JWT + same Wi‑Fi |
| Gallery / save | Save image | Phone permission Allow |

Same Wi‑Fi. If IP changed → update `mobile\assets\.env` → hot restart (`R`) or `flutter run` again.

---

# PHASE K — Daily work (after first success)

1. Plug phone → Phase E (`adb devices`)  
2. Start backend (G)  
3. Start ML (H) if testing HQ  
4. `flutter run` **or** if already running: `r` / `R`  
5. You do **not** redo Phase A/B every day unless C: full or DNS broke again  
6. You do **not** re-download Gradle every day if `D:\mackhan-cache` exists  

---

# Optional — manual downloads (only if DNS still broken)

Save files to `D:\mackhan-cache\manual\` then open Cursor later and ask agent to place them.

1. Gradle: https://services.gradle.org/distributions/gradle-9.1.0-all.zip  
2. Flutter arm64 engine jar (this SDK hash):  
   https://storage.googleapis.com/download.flutter.io/io/flutter/arm64_v8a_debug/1.0.0-0cd610717bde95fd88343c64f81c11ba4e5c0010/arm64_v8a_debug-1.0.0-0cd610717bde95fd88343c64f81c11ba4e5c0010.jar  

Prefer fixing DNS (Phase B) over manual downloads.

---

# Cheat sheet — order

```
A  free C:  A1 → A3 → A8 (Gradle on C) → A9 → A10  (≥4–5 GB free)
   (A4/A5/A6 often free 0 MB — that is OK; A2 optional; A11 optional GUI)
B  DNS 8.8.8.8 + flushdns
C  free RAM (≥2000 MB), Cursor CLOSED
D  create D:\mackhan-cache
E  adb devices = device
F  env / IP check
G  backend (window stays open)
H  ML (window stays open)
I  flutter run (window stays open)  — GRADLE_USER_HOME on D:
J  test all features on phone
K  daily: G+H+I or hot reload
```

**Last verified (2026-07-27 night):** C: 4.79 GB. Phone `RRCW900YP4V device`. Backend up. ML TF curl in progress (~30 KB/s). FreeMB ~500 with Cursor → **close Cursor for Phase I**.

---

# When done / new chat

**Start full phone run again:** open **new chat**, paste the block under **NEW CHAT — what you type** (top of this file).

After app installs: tell agent **“App is on phone”** or paste Phase I error.  
Then: ML polish, SMTP if needed, feature QA (Phase J).
