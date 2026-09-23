import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:mackhan/core/utils/export_utils.dart';

void main() {
  img.Image sampleRgba() {
    final image = img.Image(width: 4, height: 4, numChannels: 4);
    image.setPixelRgba(0, 0, 10, 20, 30, 255);
    image.setPixelRgba(1, 0, 10, 20, 30, 128);
    return image;
  }

  test('encodeExport PNG returns non-empty bytes', () {
    final bytes = encodeExport(sampleRgba(), ExportFormat.png);
    expect(bytes, isNotEmpty);
    expect(img.decodeImage(bytes), isNotNull);
  });

  test('jpgWhite flattens transparent pixels to white', () {
    final image = img.Image(width: 2, height: 1, numChannels: 4);
    image.setPixelRgba(0, 0, 0, 0, 0, 0);
    image.setPixelRgba(1, 0, 255, 0, 0, 255);
    final bytes = encodeExport(image, ExportFormat.jpgWhite);
    final decoded = img.decodeImage(bytes)!;
    expect(decoded.getPixel(0, 0).r, 255);
    expect(decoded.getPixel(1, 0).r, greaterThan(240));
  });

  test('encodeExport JPG white has no transparent pixels', () {
    final bytes = encodeExport(sampleRgba(), ExportFormat.jpgWhite);
    expect(bytes, isNotEmpty);
    final decoded = img.decodeImage(bytes)!;
    expect(decoded.numChannels, 3);
    for (var y = 0; y < decoded.height; y++) {
      for (var x = 0; x < decoded.width; x++) {
        expect(decoded.getPixel(x, y).a, 255);
      }
    }
  });

  test('fileExtension matches format', () {
    expect(fileExtension(ExportFormat.png), 'png');
    expect(fileExtension(ExportFormat.jpgWhite), 'jpg');
    expect(fileExtension(ExportFormat.webp), 'webp');
  });
}
