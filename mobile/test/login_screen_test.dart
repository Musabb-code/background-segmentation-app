import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mackhan/features/auth/presentation/login_screen.dart';

void main() {
  Widget wrap(Widget child) => ProviderScope(
        child: MaterialApp(home: child),
      );

  testWidgets('shows validation errors when Login tapped empty', (tester) async {
    await tester.pumpWidget(wrap(const LoginScreen()));

    await tester.tap(find.widgetWithText(FilledButton, 'Login'));
    await tester.pump();

    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
  });

  testWidgets('rejects invalid email', (tester) async {
    await tester.pumpWidget(wrap(const LoginScreen()));

    await tester.enterText(find.byType(TextFormField).at(0), 'not-an-email');
    await tester.enterText(find.byType(TextFormField).at(1), 'secret');
    await tester.tap(find.widgetWithText(FilledButton, 'Login'));
    await tester.pump();

    expect(find.text('Enter a valid email'), findsOneWidget);
  });

  testWidgets('Login button enabled when idle', (tester) async {
    await tester.pumpWidget(wrap(const LoginScreen()));

    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Login'),
    );
    expect(button.onPressed, isNotNull);
  });
}
