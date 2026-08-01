import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/services/settings_service.dart';

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final dark = prefs.getBool('dark_mode');
    if (dark == null) return;
    state = dark ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> setDark(bool dark) async {
    state = dark ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await SettingsService(prefs).setDark(dark);
  }
}

class AppSettingsState {
  const AppSettingsState({
    this.resolution = CameraResolution.p720,
    this.quality = ProcessingQuality.standard,
  });

  final CameraResolution resolution;
  final ProcessingQuality quality;

  AppSettingsState copyWith({
    CameraResolution? resolution,
    ProcessingQuality? quality,
  }) =>
      AppSettingsState(
        resolution: resolution ?? this.resolution,
        quality: quality ?? this.quality,
      );
}

class AppSettingsNotifier extends StateNotifier<AppSettingsState> {
  AppSettingsNotifier() : super(const AppSettingsState()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final svc = SettingsService(prefs);
    state = AppSettingsState(
      resolution: svc.cameraResolution,
      quality: svc.processingQuality,
    );
  }

  Future<void> setResolution(CameraResolution r) async {
    state = state.copyWith(resolution: r);
    final prefs = await SharedPreferences.getInstance();
    await SettingsService(prefs).setCameraResolution(r);
  }

  Future<void> setQuality(ProcessingQuality q) async {
    state = state.copyWith(quality: q);
    final prefs = await SharedPreferences.getInstance();
    await SettingsService(prefs).setProcessingQuality(q);
  }
}

final appSettingsProvider =
    StateNotifierProvider<AppSettingsNotifier, AppSettingsState>(
  (ref) => AppSettingsNotifier(),
);
