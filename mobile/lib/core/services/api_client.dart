import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../constants/api_constants.dart';
import 'secure_storage_service.dart';

typedef OnAuthLost = void Function();

/// Dio client for backend/ (+ optional ML base). PLAN §8.7 interceptors.
class ApiClient {
  ApiClient({
    required SecureStorageService storage,
    OnAuthLost? onAuthLost,
    String? baseUrl,
  })  : _storage = storage,
        _onAuthLost = onAuthLost {
    final url = baseUrl ??
        const String.fromEnvironment(
          'API_BASE_URL',
          defaultValue: '',
        );
    final resolved = url.isNotEmpty
        ? url
        : (dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:3000');

    dio = Dio(
      BaseOptions(
        baseUrl: resolved,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.readAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (err, handler) async {
          if (err.response?.statusCode != 401 ||
              err.requestOptions.extra['retried'] == true) {
            return handler.next(err);
          }
          final refreshed = await _tryRefresh();
          if (!refreshed) {
            await _storage.clearTokens();
            _onAuthLost?.call();
            return handler.next(err);
          }
          final req = err.requestOptions;
          req.extra['retried'] = true;
          final token = await _storage.readAccessToken();
          if (token != null) {
            req.headers['Authorization'] = 'Bearer $token';
          }
          try {
            final response = await dio.fetch(req);
            return handler.resolve(response);
          } on DioException catch (e) {
            return handler.next(e);
          }
        },
      ),
    );
  }

  late final Dio dio;
  final SecureStorageService _storage;
  final OnAuthLost? _onAuthLost;
  bool _refreshing = false;

  Future<bool> _tryRefresh() async {
    if (_refreshing) return false;
    _refreshing = true;
    try {
      final refresh = await _storage.readRefreshToken();
      if (refresh == null || refresh.isEmpty) return false;
      final res = await dio.post(
        ApiConstants.refresh,
        data: {'refreshToken': refresh},
        options: Options(extra: {'retried': true}),
      );
      final data = res.data as Map<String, dynamic>;
      final access = data['accessToken'] as String?;
      final newRefresh = data['refreshToken'] as String? ?? refresh;
      if (access == null) return false;
      await _storage.saveTokens(access: access, refresh: newRefresh);
      return true;
    } catch (_) {
      return false;
    } finally {
      _refreshing = false;
    }
  }

  /// Separate Dio for ml-service (same JWT).
  Dio mlDio() {
    final url = dotenv.env['ML_SERVICE_URL'] ?? 'http://10.0.2.2:8000';
    final client = Dio(
      BaseOptions(
        baseUrl: url,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
    client.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.readAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
    return client;
  }
}
