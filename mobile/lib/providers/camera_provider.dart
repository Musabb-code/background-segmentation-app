import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/services/ml_on_device_service.dart';
import '../core/services/settings_service.dart';
import '../core/utils/image_utils.dart';
import '../features/camera/models/background_mode.dart';
import '../features/camera/services/camera_service.dart';
import 'auth_provider.dart';
import 'theme_provider.dart';

/// Result of PLAN §8.6 HQ capture.
class HqCaptureResult {
  const HqCaptureResult({required this.png, required this.onDevice});

  final Uint8List png;
  final bool onDevice;
}

class CameraState {
  const CameraState({
    this.ready = false,
    this.processing = false,
    this.permissionDenied = false,
    this.error,
    this.maskImage,
    this.busyCapture = false,
    this.backgroundMode = BackgroundMode.transparent,
  });

  final bool ready;
  final bool processing;
  final bool permissionDenied;
  final String? error;

  /// Foreground alpha mask (opaque where the person is), ready for ShaderMask.
  final ui.Image? maskImage;
  final bool busyCapture;
  final BackgroundMode backgroundMode;

  CameraState copyWith({
    bool? ready,
    bool? processing,
    bool? permissionDenied,
    String? error,
    ui.Image? maskImage,
    bool clearMask = false,
    bool clearError = false,
    bool? busyCapture,
    BackgroundMode? backgroundMode,
  }) =>
      CameraState(
        ready: ready ?? this.ready,
        processing: processing ?? this.processing,
        permissionDenied: permissionDenied ?? this.permissionDenied,
        error: clearError ? null : (error ?? this.error),
        maskImage: clearMask ? null : (maskImage ?? this.maskImage),
        busyCapture: busyCapture ?? this.busyCapture,
        backgroundMode: backgroundMode ?? this.backgroundMode,
      );
}

final mlOnDeviceProvider = Provider<MlOnDeviceService>((ref) {
  final svc = MlOnDeviceService();
  ref.onDispose(svc.dispose);
  return svc;
});

final cameraProvider =
    StateNotifierProvider.autoDispose<CameraNotifier, CameraState>((ref) {
  return CameraNotifier(ref);
});

class CameraNotifier extends StateNotifier<CameraState> {
  CameraNotifier(this._ref) : super(const CameraState());

  final Ref _ref;
  final CameraService _cam = CameraService();
  bool _segmentBusy = false;
  int _frameIndex = 0;
  bool _disposed = false;
  MaskFrame? _prevMask;

  CameraController? get controller => _cam.controller;

  ResolutionPreset get _preset {
    final r = _ref.read(appSettingsProvider).resolution;
    return switch (r) {
      CameraResolution.p480 => ResolutionPreset.medium,
      CameraResolution.p1080 => ResolutionPreset.veryHigh,
      CameraResolution.p720 => ResolutionPreset.high,
    };
  }

  Future<void> init() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      state = state.copyWith(permissionDenied: true);
      return;
    }
    try {
      await _ref.read(mlOnDeviceProvider).init();
      await _cam.init(preset: _preset);
      if (_disposed) return;
      final prefs = await SharedPreferences.getInstance();
      final bg = BackgroundMode.fromStorage(
        SettingsService(prefs).backgroundModeRaw,
      );
      state = state.copyWith(
        ready: true,
        clearError: true,
        backgroundMode: bg,
      );
    } catch (e) {
      if (!_disposed) {
        state = state.copyWith(error: e.toString(), ready: false);
      }
    }
  }

  Future<void> setBackgroundMode(BackgroundMode mode) async {
    state = state.copyWith(backgroundMode: mode);
    final prefs = await SharedPreferences.getInstance();
    await SettingsService(prefs).setBackgroundModeRaw(mode.storageKey);
  }

  Future<void> startProcessing() async {
    final c = _cam.controller;
    if (c == null || !c.value.isInitialized) return;
    if (c.value.isStreamingImages) return;
    _frameIndex = 0;
    _prevMask = null;
    state = state.copyWith(processing: true);
    await c.startImageStream(_onFrame);
  }

  Future<void> stopProcessing() async {
    final c = _cam.controller;
    if (c != null && c.value.isStreamingImages) {
      await c.stopImageStream();
    }
    _prevMask = null;
    state.maskImage?.dispose();
    if (!_disposed) {
      state = state.copyWith(processing: false, clearMask: true);
    }
  }

  Future<void> _onFrame(CameraImage image) async {
    if (_segmentBusy || !state.processing) return;
    final quality = _ref.read(appSettingsProvider).quality;
    _frameIndex++;
    // Standard = every 2nd frame; High = every frame (PLAN §8.5)
    if (quality == ProcessingQuality.standard && _frameIndex.isOdd) return;

    final c = _cam.controller;
    if (c == null) return;
    _segmentBusy = true;
    try {
      final input = ImageUtils.toInputImage(
        image: image,
        camera: c.description,
        orientation: c.value.deviceOrientation,
        sensorOrientation: c.description.sensorOrientation,
      );
      if (input == null) return;
      final mask = await _ref.read(mlOnDeviceProvider).segment(input);
      if (!_disposed && mask != null) {
        final image = await _maskToImage(_smoothMask(mask));
        if (_disposed || !state.processing) {
          image.dispose();
          return;
        }
        state.maskImage?.dispose();
        state = state.copyWith(maskImage: image);
      }
    } catch (e) {
      debugPrint('segment: $e');
    } finally {
      _segmentBusy = false;
    }
  }

  /// Confidence → premultiplied alpha image. Bilinear upscaling by the GPU
  /// gives smoother hair edges than per-pixel rectangles ever could.
  Future<ui.Image> _maskToImage(MaskFrame m) {
    const lo = 0.30;
    const hi = 0.62;
    final pixels = Uint8List(m.width * m.height * 4);
    for (var i = 0; i < m.confidences.length; i++) {
      final c = m.confidences[i];
      final t = c <= lo
          ? 0.0
          : c >= hi
              ? 1.0
              : (c - lo) / (hi - lo);
      // smoothstep keeps the soft band soft instead of a hard cut
      final a = (t * t * (3 - 2 * t) * 255).round();
      final o = i * 4;
      pixels[o] = a;
      pixels[o + 1] = a;
      pixels[o + 2] = a;
      pixels[o + 3] = a;
    }
    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      pixels,
      m.width,
      m.height,
      ui.PixelFormat.rgba8888,
      completer.complete,
    );
    return completer.future;
  }

  /// Temporal blend to reduce flicker (PIXEL_LIFT_PLAN Stream 3).
  MaskFrame _smoothMask(MaskFrame next) {
    final prev = _prevMask;
    if (prev == null ||
        prev.width != next.width ||
        prev.height != next.height) {
      _prevMask = next;
      return next;
    }
    final out = Float32List(next.confidences.length);
    for (var i = 0; i < out.length; i++) {
      out[i] = prev.confidences[i] * 0.35 + next.confidences[i] * 0.65;
    }
    final blended = MaskFrame(
      width: next.width,
      height: next.height,
      confidences: out,
    );
    _prevMask = blended;
    return blended;
  }

  Future<void> switchCamera() async {
    final wasProcessing = state.processing;
    if (wasProcessing) await stopProcessing();
    try {
      await _cam.switchCamera(_preset);
      if (!_disposed) {
        state = state.copyWith(ready: true, clearMask: true);
      }
      if (wasProcessing) await startProcessing();
    } catch (e) {
      if (!_disposed) state = state.copyWith(error: e.toString());
    }
  }

  /// PLAN §8.6: pause → JPEG → ML service (30s) → on-device fallback.
  Future<HqCaptureResult> captureHq() async {
    final wasProcessing = state.processing;
    state = state.copyWith(busyCapture: true);
    try {
      if (wasProcessing) await stopProcessing();
      final shot = await _cam.takePicture();
      if (shot == null) {
        throw StateError('Camera capture failed');
      }
      final file = File(shot.path);

      try {
        final png =
            await _ref.read(mlRepositoryProvider).segmentImage(file);
        return HqCaptureResult(png: png, onDevice: false);
      } catch (e) {
        debugPrint('HQ ML failed, on-device fallback: $e');
        final png =
            await _ref.read(mlOnDeviceProvider).segmentStillToPng(file);
        return HqCaptureResult(png: png, onDevice: true);
      }
    } finally {
      if (wasProcessing && !_disposed) {
        try {
          await startProcessing();
        } catch (_) {}
      }
      if (!_disposed) state = state.copyWith(busyCapture: false);
    }
  }

  @override
  void dispose() {
    _disposed = true;
    state.maskImage?.dispose();
    _cam.dispose();
    super.dispose();
  }
}
