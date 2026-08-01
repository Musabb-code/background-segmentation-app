import 'package:camera/camera.dart';

/// Thin CameraController lifecycle helper.
class CameraService {
  CameraController? controller;
  List<CameraDescription> _cameras = [];
  int _lensIndex = 0;

  Future<void> init({ResolutionPreset preset = ResolutionPreset.high}) async {
    _cameras = await availableCameras();
    if (_cameras.isEmpty) {
      throw CameraException('NoCamera', 'No cameras available');
    }
    _lensIndex = _cameras.indexWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
    );
    if (_lensIndex < 0) _lensIndex = 0;
    await _open(preset);
  }

  Future<void> _open(ResolutionPreset preset) async {
    final desc = _cameras[_lensIndex];
    await controller?.dispose();
    controller = CameraController(
      desc,
      preset,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.nv21,
    );
    await controller!.initialize();
  }

  Future<void> switchCamera(ResolutionPreset preset) async {
    if (_cameras.length < 2) return;
    _lensIndex = (_lensIndex + 1) % _cameras.length;
    if (controller?.value.isStreamingImages ?? false) {
      await controller?.stopImageStream();
    }
    await _open(preset);
  }

  Future<XFile?> takePicture() async {
    final c = controller;
    if (c == null || !c.value.isInitialized) return null;
    if (c.value.isTakingPicture) return null;
    return c.takePicture();
  }

  Future<void> dispose() async {
    final c = controller;
    controller = null;
    if (c != null) {
      if (c.value.isStreamingImages) {
        await c.stopImageStream();
      }
      await c.dispose();
    }
  }
}
