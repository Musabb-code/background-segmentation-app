
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';

/// Camera ↔ ML Kit helpers (Android-first).
class ImageUtils {
  ImageUtils._();

  /// Build InputImage for ML Kit from a camera stream frame.
  static InputImage? toInputImage({
    required CameraImage image,
    required CameraDescription camera,
    required DeviceOrientation orientation,
    required int sensorOrientation,
  }) {
    final rotation = _rotation(camera, orientation, sensorOrientation);
    final format = InputImageFormatValue.fromRawValue(image.format.raw);

    Uint8List bytes;
    InputImageFormat imageFormat;

    if (format == InputImageFormat.nv21 || image.planes.length == 1) {
      bytes = image.planes.first.bytes;
      imageFormat = InputImageFormat.nv21;
    } else {
      bytes = yuv420ToNv21(image);
      imageFormat = InputImageFormat.nv21;
    }

    final plane = image.planes.first;
    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: imageFormat,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  static InputImageRotation _rotation(
    CameraDescription camera,
    DeviceOrientation orientation,
    int sensorOrientation,
  ) {
    final orientations = {
      DeviceOrientation.portraitUp: 0,
      DeviceOrientation.landscapeLeft: 90,
      DeviceOrientation.portraitDown: 180,
      DeviceOrientation.landscapeRight: 270,
    };
    var rotationCompensation = orientations[orientation] ?? 0;
    if (camera.lensDirection == CameraLensDirection.front) {
      rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
    } else {
      rotationCompensation =
          (sensorOrientation - rotationCompensation + 360) % 360;
    }
    return InputImageRotationValue.fromRawValue(rotationCompensation) ??
        InputImageRotation.rotation0deg;
  }

  /// ponytail: compact NV21 pack for ML Kit when planes are split YUV420.
  static Uint8List yuv420ToNv21(CameraImage image) {
    final y = image.planes[0].bytes;
    final u = image.planes[1].bytes;
    final v = image.planes[2].bytes;
    final nv21 = Uint8List(y.length + u.length + v.length);
    nv21.setRange(0, y.length, y);
    var i = 0;
    final uv = y.length;
    final uvLen = u.length < v.length ? u.length : v.length;
    while (i < uvLen) {
      nv21[uv + i * 2] = v[i];
      nv21[uv + i * 2 + 1] = u[i];
      i++;
    }
    return nv21;
  }
}
