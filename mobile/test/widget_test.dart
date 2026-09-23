import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:mackhan/widgets/export_preview_dialog.dart';

void main() {
  testWidgets('ExportPreviewDialog shows Save and Close', (tester) async {
    final bytes = Uint8List.fromList(
      img.encodePng(img.Image(width: 2, height: 2, numChannels: 4)),
    );
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: ExportPreviewDialog(imageBytes: bytes),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Save'), findsOneWidget);
    expect(find.text('Close'), findsOneWidget);
  });
}
