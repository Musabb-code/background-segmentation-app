import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:google_mlkit_selfie_segmentation/google_mlkit_selfie_segmentation.dart';
import 'package:image/image.dart' as img;

class MaskFrame {
  const MaskFrame({
    required this.width,
    required this.height,
    required this.confidences,
  });

  final int width;
  final int height;
  final Float32List confidences;
}

/// On-device selfie segmentation — ML Kit primary; soft prior if unavailable.
/// ponytail: tflite_flutter stays in pubspec (PLAN §8.5); wire Interpreter when
/// assets/models/selfie_segmentation.tflite ships.
class MlOnDeviceService {
  SelfieSegmenter? _segmenter;
  bool _mlKitFailed = false;

  Future<void> init() async {
    try {
      _segmenter = SelfieSegmenter(
        mode: SegmenterMode.stream,
        enableRawSizeMask: true,
      );
    } on MissingPluginException {
      _mlKitFailed = true;
    } catch (_) {
      _mlKitFailed = true;
    }
  }

  Future<MaskFrame?> segment(InputImage image) async {
    if (_mlKitFailed || _segmenter == null) return null;
    try {
      final mask = await _segmenter!.processImage(image);
      if (mask == null) return null;
      return MaskFrame(
        width: mask.width,
        height: mask.height,
        confidences: Float32List.fromList(mask.confidences),
      );
    } on MissingPluginException {
      _mlKitFailed = true;
    } catch (_) {
      // fall through
    }
    return null;
  }

  /// Full-res still → PNG with alpha (PLAN §8.6 on-device fallback).
  Future<Uint8List> segmentStillToPng(File file) async {
    final bytes = await file.readAsBytes();
    final frame = img.decodeImage(bytes);
    if (frame == null) {
      throw StateError('Could not decode capture');
    }

    MaskFrame? mask;
    try {
      mask = await segment(InputImage.fromFilePath(file.path));
    } catch (_) {
      // fall through to prior
    }

    mask ??= MaskFrame(
      width: 256,
      height: 256,
      confidences: _ellipticalPrior(),
    );

    return Uint8List.fromList(img.encodePng(composite(frame, mask)));
  }

  /// Soft elliptical prior until TFLite asset ships (PLAN §8.5).
  Float32List _ellipticalPrior() {
    const size = 256;
    final prior = Float32List(size * size);
    final cx = size / 2.0, cy = size / 2.0;
    for (var y = 0; y < size; y++) {
      for (var x = 0; x < size; x++) {
        final dx = (x - cx) / (size * 0.35);
        final dy = (y - cy) / (size * 0.45);
        prior[y * size + x] = (1.0 - (dx * dx + dy * dy)).clamp(0.0, 1.0);
      }
    }
    return prior;
  }

  img.Image composite(img.Image frame, MaskFrame mask) {
    final out =
        img.Image(width: frame.width, height: frame.height, numChannels: 4);
    for (var y = 0; y < frame.height; y++) {
      final my =
          (y * mask.height / frame.height).floor().clamp(0, mask.height - 1);
      for (var x = 0; x < frame.width; x++) {
        final mx =
            (x * mask.width / frame.width).floor().clamp(0, mask.width - 1);
        final conf = mask.confidences[my * mask.width + mx];
        final p = frame.getPixel(x, y);
        // Soft edge: feather around 0.45 threshold for cleaner hair/body.
        const lo = 0.33;
        const hi = 0.57;
        final a = conf <= lo
            ? 0
            : conf >= hi
                ? 255
                : (((conf - lo) / (hi - lo)) * 255).round();
        out.setPixelRgba(x, y, p.r.toInt(), p.g.toInt(), p.b.toInt(), a);
      }
    }
    return out;
  }

  Future<void> dispose() async {
    await _segmenter?.close();
    _segmenter = null;
  }
}
