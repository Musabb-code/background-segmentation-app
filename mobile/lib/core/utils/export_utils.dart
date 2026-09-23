import 'dart:typed_data';

import 'package:image/image.dart' as img;

enum ExportFormat { png, jpgWhite, webp }

ExportFormat exportFormatFromStorage(String? raw) => switch (raw) {
      'jpgWhite' => ExportFormat.jpgWhite,
      'webp' => ExportFormat.webp,
      _ => ExportFormat.png,
    };

String exportFormatLabel(ExportFormat format) => switch (format) {
      ExportFormat.png => 'PNG (transparent)',
      ExportFormat.jpgWhite => 'JPG (white bg)',
      ExportFormat.webp => 'WebP',
    };

String fileExtension(ExportFormat format) => switch (format) {
      ExportFormat.png => 'png',
      ExportFormat.jpgWhite => 'jpg',
      ExportFormat.webp => 'webp',
    };

/// Ensure 4 channels for export pipeline.
img.Image ensureRgba(img.Image src) {
  if (src.numChannels == 4) return src;
  final out = img.Image(width: src.width, height: src.height, numChannels: 4);
  for (var y = 0; y < src.height; y++) {
    for (var x = 0; x < src.width; x++) {
      final p = src.getPixel(x, y);
      out.setPixelRgba(x, y, p.r.toInt(), p.g.toInt(), p.b.toInt(), 255);
    }
  }
  return out;
}

/// Encode [rgba] for gallery save (PLAN §8.4.11).
Uint8List encodeExport(img.Image rgba, ExportFormat format) {
  return switch (format) {
    ExportFormat.png => Uint8List.fromList(img.encodePng(rgba)),
    ExportFormat.jpgWhite =>
      Uint8List.fromList(img.encodeJpg(_flattenWhite(rgba), quality: 92)),
    ExportFormat.webp => Uint8List.fromList(img.encodeWebP(rgba)),
  };
}

/// Alpha-composite [rgba] onto white → RGB (no alpha channel).
img.Image _flattenWhite(img.Image rgba) {
  final out = img.Image(width: rgba.width, height: rgba.height, numChannels: 3);
  for (var y = 0; y < rgba.height; y++) {
    for (var x = 0; x < rgba.width; x++) {
      final p = rgba.getPixel(x, y);
      final a = p.a / 255.0;
      final inv = 1.0 - a;
      out.setPixelRgba(
        x,
        y,
        (p.r * a + 255 * inv).round(),
        (p.g * a + 255 * inv).round(),
        (p.b * a + 255 * inv).round(),
        255,
      );
    }
  }
  return out;
}
