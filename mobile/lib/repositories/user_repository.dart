import 'dart:io';

import 'package:dio/dio.dart';

import '../core/constants/api_constants.dart';
import '../core/services/api_client.dart';
import '../core/services/secure_storage_service.dart';
import '../models/api_error.dart';
import '../models/user.dart';

class UserRepository {
  UserRepository(this._api, this._storage);

  final ApiClient _api;
  final SecureStorageService _storage;

  Future<User> getMe() async {
    try {
      final res = await _api.dio.get(ApiConstants.me);
      return User.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _map(e, 'Failed to load profile');
    }
  }

  Future<User> updateFullName(String fullName) async {
    try {
      final res = await _api.dio.put(
        ApiConstants.me,
        data: FormData.fromMap({'fullName': fullName.trim()}),
      );
      return User.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _map(e, 'Failed to update name');
    }
  }

  Future<User> uploadProfileImage(File file) async {
    try {
      final form = FormData.fromMap({
        'profileImage': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split(Platform.pathSeparator).last,
        ),
      });
      final res = await _api.dio.put(ApiConstants.me, data: form);
      return User.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _map(e, 'Failed to upload photo');
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final refresh = await _storage.readRefreshToken();
      await _api.dio.put(
        ApiConstants.mePassword,
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
          if (refresh != null) 'refreshToken': refresh,
        },
      );
    } on DioException catch (e) {
      throw _map(e, 'Failed to change password');
    }
  }

  ApiError _map(DioException e, String fallback) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      return ApiError.fromJson(data, statusCode: e.response?.statusCode);
    }
    return ApiError(
      message: e.message ?? fallback,
      statusCode: e.response?.statusCode,
    );
  }
}
