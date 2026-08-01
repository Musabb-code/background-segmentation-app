import 'package:shared_preferences/shared_preferences.dart';

enum CameraResolution { p480, p720, p1080 }

enum ProcessingQuality { standard, high }

class SettingsService {
  SettingsService(this._prefs);

  final SharedPreferences _prefs;

  static const _darkKey = 'dark_mode';
  static const _resKey = 'camera_resolution';
  static const _qualityKey = 'processing_quality';
  static const _bgModeKey = 'background_mode';
  static const privacyPolicyUrl = 'https://example.com/privacy';

  Future<void> setDark(bool value) => _prefs.setBool(_darkKey, value);

  String? get backgroundModeRaw => _prefs.getString(_bgModeKey);

  Future<void> setBackgroundModeRaw(String value) =>
      _prefs.setString(_bgModeKey, value);

  CameraResolution get cameraResolution {
    final v = _prefs.getString(_resKey);
    return switch (v) {
      '480p' => CameraResolution.p480,
      '1080p' => CameraResolution.p1080,
      _ => CameraResolution.p720,
    };
  }

  Future<void> setCameraResolution(CameraResolution r) {
    final s = switch (r) {
      CameraResolution.p480 => '480p',
      CameraResolution.p720 => '720p',
      CameraResolution.p1080 => '1080p',
    };
    return _prefs.setString(_resKey, s);
  }

  /// High = skip-frame off (process every frame); Standard = may skip.
  ProcessingQuality get processingQuality {
    final v = _prefs.getString(_qualityKey);
    return v == 'high' ? ProcessingQuality.high : ProcessingQuality.standard;
  }

  Future<void> setProcessingQuality(ProcessingQuality q) =>
      _prefs.setString(_qualityKey, q == ProcessingQuality.high ? 'high' : 'standard');
}
