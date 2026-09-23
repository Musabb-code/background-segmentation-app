import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:mackhan/core/services/ml_on_device_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('segmentStillToPng encodes RGBA PNG', () async {
    final frame = img.Image(width: 32, height: 32);
    for (var y = 0; y < 32; y++) {
      for (var x = 0; x < 32; x++) {
        frame.setPixelRgba(x, y, 200, 100, 50, 255);
      }
    }
    final dir = Directory.systemTemp.createTempSync('mackhan_hq_');
    final file = File('${dir.path}/cap.jpg')
      ..writeAsBytesSync(img.encodeJpg(frame));
    addTearDown(() => dir.deleteSync(recursive: true));

    final svc = MlOnDeviceService();
    await svc.init();
    final png = await svc.segmentStillToPng(file);
    // dispose needs platform channel — not available in unit test host

    final decoded = img.decodePng(png);
    expect(decoded, isNotNull);
    expect(decoded!.numChannels, greaterThanOrEqualTo(3));
  });
}
