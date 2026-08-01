import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:mackhan/core/services/ml_on_device_service.dart';

void main() {
  test('composite keeps high-confidence pixels opaque', () {
    final frame = img.Image(width: 2, height: 1);
    frame.setPixelRgba(0, 0, 10, 20, 30, 255);
    frame.setPixelRgba(1, 0, 40, 50, 60, 255);
    final mask = MaskFrame(
      width: 2,
      height: 1,
      confidences: Float32List.fromList([0.9, 0.1]),
    );
    final out = MlOnDeviceService().composite(frame, mask);
    expect(out.getPixel(0, 0).r, 10);
    expect(out.getPixel(0, 0).a, 255);
    expect(out.getPixel(1, 0).a, 0); // transparent bg default
  });
}
