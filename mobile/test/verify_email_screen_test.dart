import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mackhan/core/constants/app_constants.dart';
import 'package:mackhan/features/auth/presentation/verify_email_screen.dart';

void main() {
  Widget wrap(Widget child) => ProviderScope(
        child: MaterialApp(home: child),
      );

  testWidgets('OTP field and expiry label render', (tester) async {
    await tester.pumpWidget(
      wrap(const VerifyEmailScreen(email: 'a@b.com')),
    );

    expect(find.textContaining('Code sent to a@b.com'), findsOneWidget);
    expect(find.textContaining('Code expires in'), findsOneWidget);
    expect(find.byType(TextFormField), findsOneWidget);
    expect(find.text('Resend OTP'), findsOneWidget);
  });

  testWidgets('rejects short OTP on Verify', (tester) async {
    await tester.pumpWidget(
      wrap(const VerifyEmailScreen(email: 'a@b.com')),
    );

    await tester.enterText(find.byType(TextFormField), '12');
    await tester.tap(find.widgetWithText(FilledButton, 'Verify'));
    await tester.pump();

    expect(find.text('Enter the 6-digit code'), findsOneWidget);
  });

  testWidgets('Resend starts cooldown', (tester) async {
    await tester.pumpWidget(
      wrap(const VerifyEmailScreen(email: 'a@b.com')),
    );

    await tester.tap(find.text('Resend OTP'));
    await tester.pump();

    expect(
      find.text('Resend OTP (${AppConstants.otpResendCooldownSec}s)'),
      findsOneWidget,
    );
    expect(
      find.textContaining('Use the 6-digit code from your registration email'),
      findsOneWidget,
    );

    final resend = tester.widget<TextButton>(
      find.widgetWithText(
        TextButton,
        'Resend OTP (${AppConstants.otpResendCooldownSec}s)',
      ),
    );
    expect(resend.onPressed, isNull);
  });
}
