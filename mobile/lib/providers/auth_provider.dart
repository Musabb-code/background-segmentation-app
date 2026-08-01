import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/services/api_client.dart';
import '../core/services/secure_storage_service.dart';
import '../models/user.dart';
import '../repositories/auth_repository.dart';
import '../repositories/ml_repository.dart';
import '../repositories/user_repository.dart';

final secureStorageProvider = Provider((ref) => SecureStorageService());

final apiClientProvider = Provider((ref) {
  final storage = ref.watch(secureStorageProvider);
  return ApiClient(
    storage: storage,
    onAuthLost: () {
      ref.read(authProvider.notifier).markLoggedOut();
    },
  );
});

final authRepositoryProvider = Provider(
  (ref) => AuthRepository(
    ref.watch(apiClientProvider),
    ref.watch(secureStorageProvider),
  ),
);

final userRepositoryProvider = Provider(
  (ref) => UserRepository(
    ref.watch(apiClientProvider),
    ref.watch(secureStorageProvider),
  ),
);

final mlRepositoryProvider = Provider(
  (ref) => MlRepository(ref.watch(apiClientProvider)),
);

class AuthState {
  const AuthState({
    this.isAuthenticated = false,
    this.user,
    this.bootstrapped = false,
  });

  final bool isAuthenticated;
  final User? user;
  final bool bootstrapped;

  AuthState copyWith({
    bool? isAuthenticated,
    User? user,
    bool? bootstrapped,
    bool clearUser = false,
  }) =>
      AuthState(
        isAuthenticated: isAuthenticated ?? this.isAuthenticated,
        user: clearUser ? null : (user ?? this.user),
        bootstrapped: bootstrapped ?? this.bootstrapped,
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._ref) : super(const AuthState());

  final Ref _ref;

  AuthRepository get _auth => _ref.read(authRepositoryProvider);

  void markLoggedOut() {
    state = state.copyWith(
      isAuthenticated: false,
      clearUser: true,
      bootstrapped: true,
    );
  }

  Future<void> bootstrap() async {
    final storage = _ref.read(secureStorageProvider);
    try {
      // ponytail: secure-storage reads can block forever on some Android
      // keystores — timeout so the splash always proceeds to /login.
      final refresh = await storage
          .readRefreshToken()
          .timeout(const Duration(seconds: 4));
      if (refresh == null || refresh.isEmpty) {
        state = state.copyWith(isAuthenticated: false, bootstrapped: true);
        return;
      }
      final auth =
          await _auth.refresh().timeout(const Duration(seconds: 12));
      state = state.copyWith(
        isAuthenticated: true,
        user: auth.user,
        bootstrapped: true,
      );
    } catch (_) {
      // Storage/refresh error or timeout → treat as logged out, never hang.
      try {
        await storage.clearTokens().timeout(const Duration(seconds: 4));
      } catch (_) {}
      state = state.copyWith(
        isAuthenticated: false,
        clearUser: true,
        bootstrapped: true,
      );
    }
  }

  Future<void> login({required String email, required String password}) async {
    final auth = await _auth.login(email: email, password: password);
    state = state.copyWith(
      isAuthenticated: true,
      user: auth.user,
      bootstrapped: true,
    );
  }

  Future<String> register({
    required String fullName,
    required String email,
    required String password,
  }) =>
      _auth.register(fullName: fullName, email: email, password: password);

  Future<void> verifyEmail({required String email, required String code}) =>
      _auth.verifyEmail(email: email, code: code);

  Future<void> forgotPassword({required String email}) =>
      _auth.forgotPassword(email: email);

  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) =>
      _auth.resetPassword(email: email, code: code, newPassword: newPassword);

  Future<void> logout() async {
    await _auth.logout();
    markLoggedOut();
  }

  Future<void> refreshProfile() async {
    final user = await _ref.read(userRepositoryProvider).getMe();
    state = state.copyWith(isAuthenticated: true, user: user, bootstrapped: true);
  }

  Future<void> applyUser(User user) async {
    state = state.copyWith(isAuthenticated: true, user: user, bootstrapped: true);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref),
);
