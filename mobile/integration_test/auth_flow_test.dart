import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mackhan/core/constants/app_constants.dart';
import 'package:mackhan/core/services/secure_storage_service.dart';
import 'package:mackhan/features/auth/presentation/login_screen.dart';
import 'package:mackhan/features/auth/presentation/splash_screen.dart';
import 'package:mackhan/features/home/presentation/home_screen.dart';
import 'package:mackhan/models/auth_response.dart';
import 'package:mackhan/models/user.dart';
import 'package:mackhan/providers/auth_provider.dart';
import 'package:mackhan/repositories/auth_repository.dart';
import 'package:mackhan/repositories/user_repository.dart';
import 'package:mocktail/mocktail.dart';

class _MockStorage extends Mock implements SecureStorageService {}

class _MockAuthRepo extends Mock implements AuthRepository {}

class _MockUserRepo extends Mock implements UserRepository {}

/// PLAN §8.8 — splash → login → home (mocked API).
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late _MockStorage storage;
  late _MockAuthRepo authRepo;
  late _MockUserRepo userRepo;

  const user = User(
    id: 'u1',
    fullName: 'Test User',
    email: 'test@example.com',
    isVerified: true,
  );

  setUp(() {
    storage = _MockStorage();
    authRepo = _MockAuthRepo();
    userRepo = _MockUserRepo();

    when(() => storage.readRefreshToken()).thenAnswer((_) async => null);
    when(
      () => authRepo.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer(
      (_) async => const AuthResponse(
        accessToken: 'a',
        refreshToken: 'r',
        user: user,
      ),
    );
    when(() => userRepo.getMe()).thenAnswer((_) async => user);
  });

  testWidgets('splash → login → home', (tester) async {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
        GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
        GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          secureStorageProvider.overrideWithValue(storage),
          authRepositoryProvider.overrideWithValue(authRepo),
          userRepositoryProvider.overrideWithValue(userRepo),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    expect(find.text(AppConstants.appName), findsOneWidget);

    await tester.pump(
      const Duration(milliseconds: AppConstants.splashMaxMs + 100),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sign in'), findsOneWidget);

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'test@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'Password1');
    await tester.tap(find.widgetWithText(FilledButton, 'Login'));
    await tester.pumpAndSettle();

    verify(
      () => authRepo.login(email: 'test@example.com', password: 'Password1'),
    ).called(1);

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Test User'), findsOneWidget);
  });
}
