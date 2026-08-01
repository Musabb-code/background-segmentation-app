import 'package:flutter/material.dart';

/// Live preview background behind the subject (PLAN §8.4.7 / §8.4.10).
enum BgKind { transparent, blur, solid, asset, gallery }

class BackgroundMode {
  const BackgroundMode._({
    required this.kind,
    this.color,
    this.assetPath,
    this.galleryPath,
  });

  final BgKind kind;
  final Color? color;
  final String? assetPath;
  final String? galleryPath;

  static const transparent = BackgroundMode._(kind: BgKind.transparent);

  static const blur = BackgroundMode._(kind: BgKind.blur);

  static BackgroundMode solid(Color color) =>
      BackgroundMode._(kind: BgKind.solid, color: color);

  static BackgroundMode asset(String path) =>
      BackgroundMode._(kind: BgKind.asset, assetPath: path);

  static BackgroundMode gallery(String path) =>
      BackgroundMode._(kind: BgKind.gallery, galleryPath: path);

  static const palette = <Color>[
    Color(0xFFFFFFFF),
    Color(0xFF000000),
    Color(0xFF0EA5E9),
    Color(0xFFFB923C),
    Color(0xFF22C55E),
    Color(0xFF6366F1),
  ];

  static const builtInAssets = <String>[
    'assets/backgrounds/sky.png',
    'assets/backgrounds/orange.png',
    'assets/backgrounds/studio.png',
    'assets/backgrounds/navy.png',
    'assets/backgrounds/white.png',
    'assets/backgrounds/black.png',
  ];

  String get storageKey {
    switch (kind) {
      case BgKind.transparent:
        return 'transparent';
      case BgKind.blur:
        return 'blur';
      case BgKind.solid:
        return 'solid:${color!.toARGB32()}';
      case BgKind.asset:
        return 'asset:$assetPath';
      case BgKind.gallery:
        return 'gallery:$galleryPath';
    }
  }

  static BackgroundMode fromStorage(String? raw) {
    if (raw == null || raw == 'transparent') return transparent;
    if (raw == 'blur') return blur;
    if (raw.startsWith('solid:')) {
      final v = int.tryParse(raw.substring(6));
      if (v != null) return solid(Color(v));
    }
    if (raw.startsWith('asset:')) {
      final p = raw.substring(6);
      if (builtInAssets.contains(p)) return asset(p);
    }
    if (raw.startsWith('gallery:')) {
      final p = raw.substring(8);
      if (p.isNotEmpty) return gallery(p);
    }
    return transparent;
  }
}
