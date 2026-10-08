# Pixel Lift — production APK (cloud backend, no cloud ML).
# Usage:
#   .\scripts\build-production-apk.ps1 -ApiUrl "https://pixel-lift-api.onrender.com"

param(
  [Parameter(Mandatory = $true)]
  [string]$ApiUrl
)

$ErrorActionPreference = "Stop"

$env:JAVA_HOME = (Get-ChildItem "C:\Program Files\Microsoft" -Directory -Filter "jdk-17*" -ErrorAction SilentlyContinue | Select-Object -First 1).FullName
$env:ANDROID_HOME = "D:\Android\Sdk"
$env:Path = "$env:JAVA_HOME\bin;D:\flutter\bin;D:\Android\Sdk\platform-tools;$env:Path"

$ApiUrl = $ApiUrl.TrimEnd("/")

Set-Location "$PSScriptRoot\..\mobile"
flutter pub get
flutter build apk --release --target-platform android-arm64 `
  --dart-define=API_BASE_URL=$ApiUrl `
  --dart-define=ML_CLOUD_ENABLED=false

Write-Host ""
Write-Host "APK: $PWD\build\app\outputs\flutter-apk\app-release.apk"
Write-Host "Install: adb install -r build\app\outputs\flutter-apk\app-release.apk"
