import 'dart:io';



import 'package:flutter/foundation.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gal/gal.dart';

import 'package:image/image.dart' as img;

import 'package:image_picker/image_picker.dart';



import '../core/utils/export_utils.dart';

import 'camera_provider.dart';



/// Result of gallery / editor segmentation (same ML path as §8.6 HQ capture).

class SegmentResult {

  const SegmentResult({required this.bytes, required this.onDevice});



  final Uint8List bytes;

  final bool onDevice;

}



class BatchProgress {

  const BatchProgress({

    required this.index,

    required this.total,

    this.fileName,

  });



  final int index;

  final int total;

  final String? fileName;

}



class BatchResult {

  const BatchResult({required this.saved, required this.cancelled});



  final int saved;

  final bool cancelled;

}



class EditorState {

  const EditorState({

    this.processing = false,

    this.error,

    this.batchProgress,

  });



  final bool processing;

  final String? error;

  final BatchProgress? batchProgress;



  EditorState copyWith({

    bool? processing,

    String? error,

    BatchProgress? batchProgress,

    bool clearError = false,

    bool clearBatchProgress = false,

  }) =>

      EditorState(

        processing: processing ?? this.processing,

        error: clearError ? null : (error ?? this.error),

        batchProgress:

            clearBatchProgress ? null : (batchProgress ?? this.batchProgress),

      );

}



final editorProvider =

    StateNotifierProvider.autoDispose<EditorNotifier, EditorState>((ref) {

  return EditorNotifier(ref);

});



class EditorNotifier extends StateNotifier<EditorState> {

  EditorNotifier(this._ref) : super(const EditorState());



  final Ref _ref;

  bool _cancelBatch = false;



  static const batchMax = 20;



  void cancelBatch() => _cancelBatch = true;



  Future<SegmentResult> _segmentBytes(

    File file, {

    required bool onDeviceOnly,

  }) async {

    final seg = await segmentStillFile(

      _ref,

      file,

      onDeviceOnly: onDeviceOnly,

    );

    return SegmentResult(bytes: seg.png, onDevice: seg.onDevice);

  }



  /// Studio ML server first, on-device fallback (mirrors [CameraNotifier.captureHq]).

  Future<SegmentResult> segmentFile(File file) async {

    state = state.copyWith(processing: true, clearError: true);

    try {

      return await _segmentBytes(file, onDeviceOnly: false);

    } catch (e) {

      state = state.copyWith(error: e.toString());

      rethrow;

    } finally {

      state = state.copyWith(processing: false);

    }

  }



  /// Sequential gallery batch (PLAN §8.4.11 Feature 8). Default on-device only.

  Future<BatchResult> processBatch(

    List<XFile> files, {

    ExportFormat format = ExportFormat.png,

    bool onDeviceOnly = true,

  }) async {

    _cancelBatch = false;

    final list = files.take(batchMax).toList();

    var saved = 0;



    state = state.copyWith(processing: true, clearError: true);

    try {

      if (!await Gal.requestAccess()) {

        throw StateError('Gallery permission denied');

      }



      for (var i = 0; i < list.length; i++) {

        if (_cancelBatch) break;



        final x = list[i];

        state = state.copyWith(

          batchProgress: BatchProgress(

            index: i + 1,

            total: list.length,

            fileName: x.name,

          ),

        );



        try {

          final seg = await _segmentBytes(File(x.path), onDeviceOnly: onDeviceOnly);

          final decoded = img.decodeImage(seg.bytes);

          if (decoded == null) continue;



          final out = encodeExport(ensureRgba(decoded), format);

          final ext = fileExtension(format);

          await Gal.putImageBytes(

            out,

            name: 'pixel_lift_batch_${DateTime.now().millisecondsSinceEpoch}_$i.$ext',

          );

          saved++;

        } catch (e) {

          debugPrint('Batch skip ${x.name}: $e');

        }

      }



      return BatchResult(saved: saved, cancelled: _cancelBatch);

    } catch (e) {

      state = state.copyWith(error: e.toString());

      rethrow;

    } finally {

      state = state.copyWith(processing: false, clearBatchProgress: true);

    }

  }

}


