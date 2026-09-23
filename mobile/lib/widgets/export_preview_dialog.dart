import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gal/gal.dart';
import 'package:image/image.dart' as img;

import '../core/utils/export_utils.dart';
import '../providers/theme_provider.dart';
import 'error_snackbar.dart';

/// Full-screen preview after HQ capture or gallery segment (PLAN §8.4.11).
class ExportPreviewDialog extends ConsumerStatefulWidget {
  const ExportPreviewDialog({
    super.key,
    required this.imageBytes,
    this.initialFormat,
    this.lockFormat = false,
    this.saveNamePrefix = 'pixel_lift',
    this.presetLabel,
  });

  final Uint8List imageBytes;
  final ExportFormat? initialFormat;
  final bool lockFormat;
  final String saveNamePrefix;
  final String? presetLabel;

  @override
  ConsumerState<ExportPreviewDialog> createState() =>
      _ExportPreviewDialogState();
}

class _ExportPreviewDialogState extends ConsumerState<ExportPreviewDialog> {
  ExportFormat? _format;

  ExportFormat get _selected =>
      _format ??
      widget.initialFormat ??
      ref.read(appSettingsProvider).exportFormat;

  Future<void> _save() async {
    try {
      final decoded = img.decodeImage(widget.imageBytes);
      if (decoded == null) {
        if (mounted) showErrorSnackbar(context, 'Could not decode image');
        return;
      }
      final rgba = ensureRgba(decoded);

      Uint8List out;
      try {
        out = encodeExport(rgba, _selected);
      } catch (e) {
        if (mounted) {
          showErrorSnackbar(context, 'Export failed: $e');
        }
        return;
      }

      final ok = await Gal.requestAccess();
      if (!ok) {
        if (mounted) {
          showErrorSnackbar(context, 'Gallery permission denied');
        }
        return;
      }
      final ext = fileExtension(_selected);
      await Gal.putImageBytes(
        out,
        name:
            '${widget.saveNamePrefix}_${DateTime.now().millisecondsSinceEpoch}.$ext',
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Saved as ${ext.toUpperCase()}')),
        );
      }
    } catch (e) {
      if (mounted) showErrorSnackbar(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      backgroundColor: Colors.black,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: _save,
                    child: const Text('Save'),
                  ),
                ],
              ),
            ),
            if (widget.presetLabel != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  widget.presetLabel!,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ),
            if (!widget.lockFormat) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SegmentedButton<ExportFormat>(
                  segments: ExportFormat.values
                      .map(
                        (f) => ButtonSegment(
                          value: f,
                          label: Text(
                            switch (f) {
                              ExportFormat.png => 'PNG',
                              ExportFormat.jpgWhite => 'JPG',
                              ExportFormat.webp => 'WebP',
                            },
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      )
                      .toList(),
                  selected: {_selected},
                  onSelectionChanged: (s) => setState(() => _format = s.first),
                ),
              ),
              const SizedBox(height: 4),
            ],
            Text(
              _selected == ExportFormat.jpgWhite
                  ? 'JPG saves on white background'
                  : 'Checkerboard = transparent areas',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            Expanded(
              child: InteractiveViewer(
                child: Center(
                  child: Image.memory(widget.imageBytes, fit: BoxFit.contain),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
