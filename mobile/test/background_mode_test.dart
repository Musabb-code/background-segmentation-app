import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mackhan/features/camera/models/background_mode.dart';

void main() {
  test('BackgroundMode round-trips storage keys', () {
    expect(BackgroundMode.fromStorage(null).kind, BgKind.transparent);
    expect(
      BackgroundMode.fromStorage(BackgroundMode.transparent.storageKey).kind,
      BgKind.transparent,
    );
    final solid = BackgroundMode.solid(const Color(0xFF0EA5E9));
    final again = BackgroundMode.fromStorage(solid.storageKey);
    expect(again.kind, BgKind.solid);
    expect(again.color, solid.color);
    final asset = BackgroundMode.asset(BackgroundMode.builtInAssets.first);
    expect(BackgroundMode.fromStorage(asset.storageKey).assetPath, asset.assetPath);
  });
}
