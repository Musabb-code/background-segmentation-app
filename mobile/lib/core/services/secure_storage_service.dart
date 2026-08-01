import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/api_constants.dart';

class SecureStorageService {
  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  Future<void> saveTokens({required String access, required String refresh}) async {
    await _storage.write(key: ApiConstants.accessTokenKey, value: access);
    await _storage.write(key: ApiConstants.refreshTokenKey, value: refresh);
  }

  Future<String?> readAccessToken() =>
      _storage.read(key: ApiConstants.accessTokenKey);

  Future<String?> readRefreshToken() =>
      _storage.read(key: ApiConstants.refreshTokenKey);

  Future<void> clearTokens() async {
    await _storage.delete(key: ApiConstants.accessTokenKey);
    await _storage.delete(key: ApiConstants.refreshTokenKey);
  }
}
