import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:mackhan/core/utils/crop_utils.dart';

void main() {
  test('alphaBounds finds opaque center region', () {
    final image = img.Image(width: 100, height: 100, numChannels: 4);
    for (var y = 40; y < 60; y++) {
      for (var x = 40; x < 60; x++) {
        image.setPixelRgba(x, y, 255, 0, 0, 255);
      }
    }
    final b = alphaBounds(image)!;
    expect(b.left, 40);
    expect(b.top, 40);
    expect(b.right, 59);
    expect(b.bottom, 59);
  });

  test('cropToAlphaBounds includes padding', () {
    final image = img.Image(width: 100, height: 100, numChannels: 4);
    for (var y = 40; y < 60; y++) {
      for (var x = 40; x < 60; x++) {
        image.setPixelRgba(x, y, 255, 0, 0, 255);
      }
    }
    final cropped = cropToAlphaBounds(image, padding: 8);
    expect(cropped.width, 36);
    expect(cropped.height, 36);
  });

  test('autoCropPngBytes shrinks PNG payload', () {
    final image = img.Image(width: 100, height: 100, numChannels: 4);
    for (var y = 40; y < 60; y++) {
      for (var x = 40; x < 60; x++) {
        image.setPixelRgba(x, y, 255, 0, 0, 255);
      }
    }
    final big = Uint8List.fromList(img.encodePng(image));
    final small = autoCropPngBytes(big);
    final decoded = img.decodePng(small)!;
    expect(decoded.width, 36);
    expect(decoded.height, 36);
  });
}
