import 'dart:typed_data';

import 'package:image/image.dart' as img;

import 'export_utils.dart';

/// Inclusive pixel bounds of non-transparent content.
typedef AlphaBounds = ({int left, int top, int right, int bottom});

/// Scan [rgba] for pixels with alpha > [alphaThreshold].
AlphaBounds? alphaBounds(
  img.Image rgba, {
  int alphaThreshold = 10,
}) {
  if (rgba.width == 0 || rgba.height == 0) return null;

  var left = rgba.width;
  var top = rgba.height;
  var right = -1;
  var bottom = -1;

  for (var y = 0; y < rgba.height; y++) {
    for (var x = 0; x < rgba.width; x++) {
      if (rgba.getPixel(x, y).a > alphaThreshold) {
        if (x < left) left = x;
        if (x > right) right = x;
        if (y < top) top = y;
        if (y > bottom) bottom = y;
      }
    }
  }

  if (right < 0) return null;
  return (left: left, top: top, right: right, bottom: bottom);
}

/// Crop to content bounds + [padding], clamped to image edges.
img.Image cropToAlphaBounds(
  img.Image rgba, {
  int alphaThreshold = 10,
  int padding = 8,
}) {
  final b = alphaBounds(rgba, alphaThreshold: alphaThreshold);
  if (b == null) return rgba;

  final x = (b.left - padding).clamp(0, rgba.width - 1);
  final y = (b.top - padding).clamp(0, rgba.height - 1);
  final x2 = (b.right + padding).clamp(0, rgba.width - 1);
  final y2 = (b.bottom + padding).clamp(0, rgba.height - 1);
  final w = x2 - x + 1;
  final h = y2 - y + 1;

  return img.copyCrop(rgba, x: x, y: y, width: w, height: h);
}

/// Decode PNG → crop subject bounds → re-encode (PLAN §8.4.11 Feature 3).
Uint8List autoCropPngBytes(Uint8List png) {
  final decoded = img.decodeImage(png);
  if (decoded == null) return png;
  final cropped = cropToAlphaBounds(ensureRgba(decoded));
  return Uint8List.fromList(img.encodePng(cropped));
}
