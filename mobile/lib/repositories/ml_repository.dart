import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../core/constants/api_constants.dart';
import '../core/services/api_client.dart';
import '../models/api_error.dart';

/// HQ capture → ml-service PNG (PLAN §8.6).
class MlRepository {
  MlRepository(this._api);

  final ApiClient _api;

  Future<Uint8List> segmentImage(File file) async {
    try {
      final form = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: 'capture.jpg',
        ),
        'quality': 'high',
      });
      final res = await _api.mlDio().post(
            ApiConstants.segment,
            data: form,
            options: Options(
              responseType: ResponseType.bytes,
              receiveTimeout: const Duration(seconds: 30),
              sendTimeout: const Duration(seconds: 30),
            ),
          );
      final data = res.data;
      if (data is Uint8List) return data;
      if (data is List<int>) return Uint8List.fromList(data);
      throw ApiError(message: 'Unexpected ML response');
    } on DioException catch (e) {
      throw ApiError(
        message: e.message ?? 'Segmentation failed',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
