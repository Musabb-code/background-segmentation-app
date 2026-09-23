import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/utils/export_utils.dart';
import '../../../providers/editor_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../widgets/error_snackbar.dart';
import '../../../widgets/export_preview_dialog.dart';

/// Gallery → segment → preview (PLAN §8.4.11).
class EditorScreen extends ConsumerStatefulWidget {
  const EditorScreen({super.key, this.preset, this.batch = false});

  /// `product_white` → JPG on white, portrait-only ML (no product detection).
  final String? preset;
  final bool batch;

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  bool get _productWhite => widget.preset == 'product_white';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.batch) {
        _runBatch();
      } else {
        _runSingle();
      }
    });
  }

  Future<void> _runSingle() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (!mounted) return;
    if (picked == null) {
      context.pop();
      return;
    }

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
      final result =
          await ref.read(editorProvider.notifier).segmentFile(File(picked.path));
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
        builder: (ctx) => ExportPreviewDialog(
          imageBytes: result.bytes,
          initialFormat: _productWhite ? ExportFormat.jpgWhite : null,
          lockFormat: _productWhite,
          saveNamePrefix:
              _productWhite ? 'pixel_lift_product' : 'pixel_lift',
          presetLabel: _productWhite
              ? 'White background · portrait cutout (not product detection)'
              : null,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      showErrorSnackbar(context, e.toString());
    } finally {
      if (mounted) context.pop();
    }
  }

  Future<void> _runBatch() async {
    final picked = await ImagePicker().pickMultiImage(
      limit: EditorNotifier.batchMax,
    );
    if (!mounted) return;
    if (picked.isEmpty) {
      context.pop();
      return;
    }

    final format = ref.read(appSettingsProvider).exportFormat;

    try {
      final result = await ref.read(editorProvider.notifier).processBatch(
            picked,
            format: format,
            onDeviceOnly: true,
          );
      if (!mounted) return;

      final msg = result.cancelled
          ? 'Stopped · saved ${result.saved} of ${picked.length}'
          : 'Saved ${result.saved} image${result.saved == 1 ? '' : 's'}';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      if (mounted) showErrorSnackbar(context, e.toString());
    } finally {
      if (mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final editor = ref.watch(editorProvider);
    final progress = editor.batchProgress;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.batch
              ? 'Batch edit'
              : _productWhite
                  ? 'White background JPG'
                  : 'Edit photo',
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.batch) ...[
                const Text(
                  'On-device only · up to ${EditorNotifier.batchMax} photos',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
              ],
              if (progress != null) ...[
                LinearProgressIndicator(
                  value: progress.index / progress.total,
                ),
                const SizedBox(height: 16),
                Text(
                  'Processing ${progress.index} of ${progress.total}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (progress.fileName != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    progress.fileName!,
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 24),
                TextButton(
                  onPressed: editor.processing
                      ? () => ref.read(editorProvider.notifier).cancelBatch()
                      : null,
                  child: const Text('Cancel'),
                ),
              ] else
                const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
