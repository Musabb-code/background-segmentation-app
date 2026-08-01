# MACKHAN — Flutter Android app

Primary product: real-time background removal.

## Prerequisites

1. Install [Flutter SDK](https://docs.flutter.dev/get-started/install/windows) (stable).
2. Add `flutter\bin` to PATH; open a **new** terminal.
3. Android Studio + Android SDK (API 34), emulator or device.

## Run

```powershell
cd D:\MACKHAN\mobile
flutter create . --platforms=android
flutter pub get
flutter run
```

`flutter create .` fills missing platform files (icons, gradle wrapper) without overwriting `lib/`.

## Config

Edit `assets/.env`:

```env
API_BASE_URL=http://10.0.2.2:3000
ML_SERVICE_URL=http://10.0.2.2:8000
```

(`10.0.2.2` = host machine from Android emulator.)

## Task scope

- **Task 12 (done):** Riverpod, go_router, Material 3, Dio ApiClient, secure storage, route stubs
- **Task 13:** Auth screens
- **Task 14:** Home / Profile / Settings polish
- **Task 15:** Camera + ML Kit
- **Task 16:** HQ capture → ml-service
