import 'package:dio/dio.dart';

import '../core/constants/api_constants.dart';
import '../core/services/api_client.dart';
import '../core/services/secure_storage_service.dart';
import '../models/api_error.dart';
import '../models/auth_response.dart';

class AuthRepository {
  AuthRepository(this._api, this._storage);

  final ApiClient _api;
  final SecureStorageService _storage;

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _api.dio.post(
        ApiConstants.login,
        data: {'email': email.trim(), 'password': password},
      );
      final auth = AuthResponse.fromJson(res.data as Map<String, dynamic>);
      await _storage.saveTokens(
        access: auth.accessToken,
        refresh: auth.refreshToken,
      );
      return auth;
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  Future<String> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final res = await _api.dio.post(
        ApiConstants.register,
        data: {
          'fullName': fullName.trim(),
          'email': email.trim(),
          'password': password,
        },
      );
      final data = res.data as Map<String, dynamic>;
      return data['email'] as String? ?? email.trim();
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  Future<void> verifyEmail({required String email, required String code}) async {
    try {
      await _api.dio.post(
        ApiConstants.verify,
        data: {'email': email.trim(), 'code': code.trim()},
      );
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  Future<void> forgotPassword({required String email}) async {
    try {
      await _api.dio.post(
        ApiConstants.forgotPassword,
        data: {'email': email.trim()},
      );
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    try {
      await _api.dio.post(
        ApiConstants.resetPassword,
        data: {
          'email': email.trim(),
          'code': code.trim(),
          'newPassword': newPassword,
        },
      );
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  Future<AuthResponse> refresh() async {
    final refresh = await _storage.readRefreshToken();
    if (refresh == null) throw ApiError(message: 'No refresh token');
    try {
      final res = await _api.dio.post(
        ApiConstants.refresh,
        data: {'refreshToken': refresh},
      );
      final auth = AuthResponse.fromJson(res.data as Map<String, dynamic>);
      await _storage.saveTokens(
        access: auth.accessToken,
        refresh: auth.refreshToken,
      );
      return auth;
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  Future<void> logout() async {
    final refresh = await _storage.readRefreshToken();
    try {
      if (refresh != null) {
        await _api.dio
            .post(ApiConstants.logout, data: {'refreshToken': refresh});
      }
    } catch (_) {}
    await _storage.clearTokens();
  }

  ApiError _map(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      return ApiError.fromJson(data, statusCode: e.response?.statusCode);
    }
    return ApiError(
      message: e.message ?? 'Network error',
      statusCode: e.response?.statusCode,
    );
  }
}
