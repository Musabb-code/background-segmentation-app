import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/services/settings_service.dart';
import '../core/utils/export_utils.dart';

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
    this.exportFormat = ExportFormat.png,
    this.autoCrop = true,
  });

  final CameraResolution resolution;
  final ProcessingQuality quality;
  final ExportFormat exportFormat;
  final bool autoCrop;

  AppSettingsState copyWith({
    CameraResolution? resolution,
    ProcessingQuality? quality,
    ExportFormat? exportFormat,
    bool? autoCrop,
  }) =>
      AppSettingsState(
        resolution: resolution ?? this.resolution,
        quality: quality ?? this.quality,
        exportFormat: exportFormat ?? this.exportFormat,
        autoCrop: autoCrop ?? this.autoCrop,
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
      exportFormat: svc.exportFormat,
      autoCrop: svc.autoCrop,
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

  Future<void> setExportFormat(ExportFormat format) async {
    state = state.copyWith(exportFormat: format);
    final prefs = await SharedPreferences.getInstance();
    await SettingsService(prefs).setExportFormat(format);
  }

  Future<void> setAutoCrop(bool value) async {
    state = state.copyWith(autoCrop: value);
    final prefs = await SharedPreferences.getInstance();
    await SettingsService(prefs).setAutoCrop(value);
  }
}

final appSettingsProvider =
    StateNotifierProvider<AppSettingsNotifier, AppSettingsState>(
  (ref) => AppSettingsNotifier(),
);
