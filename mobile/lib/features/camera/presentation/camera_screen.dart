import 'dart:io';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/theme/app_theme.dart';
import '../../../providers/camera_provider.dart';
import '../../../widgets/error_snackbar.dart';
import '../../../widgets/export_preview_dialog.dart';
import '../models/background_mode.dart';

class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen> {
  ui.Image? _bgImage;
  String? _bgImageKey;
  bool _trayOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cameraProvider.notifier).init();
    });
  }

  @override
  void dispose() {
    _bgImage?.dispose();
    super.dispose();
  }

  Future<void> _ensureBgImage(BackgroundMode mode) async {
    final key = mode.storageKey;
    if (_bgImageKey == key) return;
    _bgImageKey = key;
    _bgImage?.dispose();
    _bgImage = null;

    if (mode.kind == BgKind.asset && mode.assetPath != null) {
      final data = await rootBundle.load(mode.assetPath!);
      _bgImage = await _decodeUiImage(data.buffer.asUint8List());
    } else if (mode.kind == BgKind.gallery && mode.galleryPath != null) {
      final bytes = await File(mode.galleryPath!).readAsBytes();
      _bgImage = await _decodeUiImage(bytes);
    }
    if (mounted) setState(() {});
  }

  Future<ui.Image> _decodeUiImage(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  Future<void> _onCapture() async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Expanded(child: Text('Processing…')),
          ],
        ),
      ),
    );

    try {
      final result = await ref.read(cameraProvider.notifier).captureHq();
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.onDevice ? 'Quick (on device)' : 'Studio quality (cloud)',
          ),
        ),
      );

      await showDialog<void>(
        context: context,
        builder: (ctx) => ExportPreviewDialog(imageBytes: result.png),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      showErrorSnackbar(context, e.toString());
    }
  }

  Future<void> _pickGalleryBg() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file == null) return;
    final mode = BackgroundMode.gallery(file.path);
    await ref.read(cameraProvider.notifier).setBackgroundMode(mode);
    await _ensureBgImage(mode);
  }

  @override
  Widget build(BuildContext context) {
    final cam = ref.watch(cameraProvider);
    final notifier = ref.read(cameraProvider.notifier);
    final controller = notifier.controller;

    ref.listen(cameraProvider, (prev, next) {
      if (prev?.backgroundMode.storageKey != next.backgroundMode.storageKey) {
        _ensureBgImage(next.backgroundMode);
      }
    });

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (cam.permissionDenied)
            const _PermissionDenied(onOpenSettings: openAppSettings)
          else if (cam.error != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  cam.error!,
                  style: const TextStyle(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else if (!cam.ready ||
              controller == null ||
              !controller.value.isInitialized)
            const Center(child: CircularProgressIndicator(color: Colors.white))
          else
            _Preview(
              controller: controller,
              maskImage: cam.processing ? cam.maskImage : null,
              mode: cam.backgroundMode,
              bgImage: _bgImage,
            ),

          // Top status row
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/home');
                      }
                    },
                  ),
                  const Spacer(),
                  if (!cam.processing)
                    const Text(
                      'Tap Start Lift',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    )
                  else
                    const Row(
                      children: [
                        _GreenDot(),
                        SizedBox(width: 6),
                        Text(
                          'Live',
                          style:
                              TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        SizedBox(width: 12),
                      ],
                    ),
                ],
              ),
            ),
          ),

          // Bottom: tray sits ABOVE the bar in one column, so taps reach it.
          if (cam.ready && !cam.permissionDenied)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_trayOpen)
                      _ModeTray(
                        mode: cam.backgroundMode,
                        onSelect: (m) async {
                          await notifier.setBackgroundMode(m);
                          await _ensureBgImage(m);
                        },
                        onGallery: _pickGalleryBg,
                      ),
                    Container(
                      color: Colors.black54,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _BarButton(
                            icon:
                                cam.processing ? Icons.stop : Icons.play_arrow,
                            label: cam.processing ? 'Stop' : 'Start Lift',
                            onPressed: cam.busyCapture
                                ? null
                                : () {
                                    if (cam.processing) {
                                      notifier.stopProcessing();
                                    } else {
                                      notifier.startProcessing();
                                      _ensureBgImage(cam.backgroundMode);
                                    }
                                  },
                          ),
                          _BarButton(
                            icon: Icons.layers,
                            label: 'Modes',
                            highlight: _trayOpen,
                            onPressed: () =>
                                setState(() => _trayOpen = !_trayOpen),
                          ),
                          _BarButton(
                            icon: Icons.cameraswitch,
                            label: 'Switch',
                            onPressed:
                                cam.busyCapture ? null : notifier.switchCamera,
                          ),
                          _BarButton(
                            icon: Icons.camera,
                            label: 'Capture',
                            onPressed: cam.busyCapture ? null : _onCapture,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Background chooser. Always tappable; selection applies immediately and
/// shows as soon as Start Lift is running.
class _ModeTray extends StatelessWidget {
  const _ModeTray({
    required this.mode,
    required this.onSelect,
    required this.onGallery,
  });

  final BackgroundMode mode;
  final ValueChanged<BackgroundMode> onSelect;
  final VoidCallback onGallery;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.88),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Background',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 52,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _Chip(
                    icon: Icons.grid_on,
                    label: 'Clear',
                    selected: mode.kind == BgKind.transparent,
                    onTap: () => onSelect(BackgroundMode.transparent),
                  ),
                  const SizedBox(width: 8),
                  _Chip(
                    icon: Icons.blur_on,
                    label: 'Blur',
                    selected: mode.kind == BgKind.blur,
                    onTap: () => onSelect(BackgroundMode.blur),
                  ),
                  const SizedBox(width: 8),
                  _Chip(
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    selected: mode.kind == BgKind.gallery,
                    onTap: onGallery,
                  ),
                  for (final c in BackgroundMode.palette) ...[
                    const SizedBox(width: 8),
                    _ColorDot(
                      color: c,
                      selected:
                          mode.kind == BgKind.solid && mode.color == c,
                      onTap: () => onSelect(BackgroundMode.solid(c)),
                    ),
                  ],
                  for (final p in BackgroundMode.builtInAssets) ...[
                    const SizedBox(width: 8),
                    _AssetThumb(
                      path: p,
                      selected:
                          mode.kind == BgKind.asset && mode.assetPath == p,
                      onTap: () => onSelect(BackgroundMode.asset(p)),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary : Colors.white12,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? AppTheme.accent : Colors.white54,
            width: selected ? 3 : 1,
          ),
        ),
      ),
    );
  }
}

class _AssetThumb extends StatelessWidget {
  const _AssetThumb({
    required this.path,
    required this.selected,
    required this.onTap,
  });

  final String path;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppTheme.accent : Colors.white54,
            width: selected ? 3 : 1,
          ),
          image: DecorationImage(image: AssetImage(path), fit: BoxFit.cover),
        ),
      ),
    );
  }
}

/// Background layer first, then the sharp subject masked on top.
/// GPU bilinear filtering of the mask = far smoother hair edges.
class _Preview extends StatelessWidget {
  const _Preview({
    required this.controller,
    required this.maskImage,
    required this.mode,
    required this.bgImage,
  });

  final CameraController controller;
  final ui.Image? maskImage;
  final BackgroundMode mode;
  final ui.Image? bgImage;

  Widget _background() {
    switch (mode.kind) {
      case BgKind.transparent:
        return const CustomPaint(painter: _CheckerPainter());
      case BgKind.blur:
        return ImageFiltered(
          imageFilter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: CameraPreview(controller),
        );
      case BgKind.solid:
        return ColoredBox(color: mode.color!);
      case BgKind.asset:
      case BgKind.gallery:
        final img = bgImage;
        if (img == null) return const ColoredBox(color: Colors.black);
        return RawImage(image: img, fit: BoxFit.cover);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final preview = controller.value.previewSize;
        if (preview == null) {
          return CameraPreview(controller);
        }
        final aspect = preview.height / preview.width;
        final mask = maskImage;

        return FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxWidth / aspect,
            child: mask == null
                ? CameraPreview(controller)
                : Stack(
                    fit: StackFit.expand,
                    children: [
                      _background(),
                      ShaderMask(
                        blendMode: BlendMode.dstIn,
                        shaderCallback: (rect) => ImageShader(
                          mask,
                          TileMode.clamp,
                          TileMode.clamp,
                          (Matrix4.identity()
                                ..scaleByDouble(
                                  rect.width / mask.width,
                                  rect.height / mask.height,
                                  1,
                                  1,
                                ))
                              .storage,
                          filterQuality: FilterQuality.high,
                        ),
                        child: CameraPreview(controller),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}

class _CheckerPainter extends CustomPainter {
  const _CheckerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const cell = 24.0;
    final light = Paint()..color = const Color(0xFFE8EDF2);
    final dark = Paint()..color = const Color(0xFFB9C3CE);
    canvas.drawRect(Offset.zero & size, light);
    for (var y = 0; y * cell < size.height; y++) {
      for (var x = 0; x * cell < size.width; x++) {
        if ((x + y).isEven) continue;
        canvas.drawRect(
          Rect.fromLTWH(x * cell, y * cell, cell, cell),
          dark,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CheckerPainter oldDelegate) => false;
}

class _GreenDot extends StatelessWidget {
  const _GreenDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: const BoxDecoration(
        color: Color(0xFF22C55E),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _BarButton extends StatelessWidget {
  const _BarButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.highlight = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final color = highlight ? AppTheme.primary : Colors.white;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onPressed,
          icon: Icon(icon, color: onPressed == null ? Colors.white38 : color,
              size: 28),
        ),
        Text(
          label,
          style: TextStyle(
            color: highlight ? AppTheme.primary : Colors.white70,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _PermissionDenied extends StatelessWidget {
  const _PermissionDenied({required this.onOpenSettings});

  final Future<bool> Function() onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.videocam_off, color: Colors.white54, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Camera permission is required for Pixel Lift.',
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: onOpenSettings,
              child: const Text('Open Settings'),
            ),
          ],
        ),
      ),
    );
  }
}
