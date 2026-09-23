import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'features/auth/presentation/forgot_password_screen.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/register_screen.dart';
import 'features/auth/presentation/reset_password_screen.dart';
import 'features/auth/presentation/splash_screen.dart';
import 'features/auth/presentation/verify_email_screen.dart';
import 'features/camera/presentation/camera_screen.dart';
import 'features/editor/presentation/editor_screen.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/profile/presentation/profile_screen.dart';
import 'features/settings/presentation/settings_screen.dart';
import 'providers/auth_provider.dart';
     
final _rootKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  // ponytail: never `watch` auth here — rebuilding the provider builds a new
  // GoRouter that resets to initialLocation '/', discarding navigation.
  // `refreshListenable` re-runs `redirect` on auth changes instead.
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/',
    refreshListenable: _AuthListenable(ref),
    redirect: (context, state) {
      final auth = ref.read(authProvider);
      if (!auth.bootstrapped && state.matchedLocation != '/') {
        return '/';
      }
      final loggingIn = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/verify-email' ||
          state.matchedLocation == '/forgot-password' ||
          state.matchedLocation == '/reset-password' ||
          state.matchedLocation == '/';

      if (!auth.bootstrapped) return null;

      if (!auth.isAuthenticated && !loggingIn) return '/login';
      // Authoritative: once authenticated, leave splash/auth screens for /home
      // rather than relying on SplashScreen winning a navigation race.
      if (auth.isAuthenticated &&
          (state.matchedLocation == '/' ||
              state.matchedLocation == '/login' ||
              state.matchedLocation == '/register')) {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(
        path: '/verify-email',
        builder: (_, state) => VerifyEmailScreen(
          email: state.uri.queryParameters['email'],
        ),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (_, __) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (_, state) => ResetPasswordScreen(
          email: state.uri.queryParameters['email'],
        ),
      ),
      GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
      GoRoute(path: '/camera', builder: (_, __) => const CameraScreen()),
      GoRoute(
        path: '/editor',
        builder: (_, state) => EditorScreen(
          preset: state.uri.queryParameters['preset'],
          batch: state.uri.queryParameters['batch'] == '1',
        ),
      ),
      GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
      GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
    ],
  );
});

/// Bridges Riverpod auth changes into go_router refresh.
class _AuthListenable extends ChangeNotifier {
  _AuthListenable(this._ref) {
    _ref.listen(authProvider, (_, __) => notifyListeners());
  }

  final Ref _ref;
}
