import 'package:flutter_test/flutter_test.dart';
import 'package:mackhan/core/utils/validators.dart';

void main() {
  group('Validators.email', () {
    test('rejects empty/null', () {
      expect(Validators.email(null), 'Email is required');
      expect(Validators.email(''), 'Email is required');
      expect(Validators.email('   '), 'Email is required');
    });

    test('rejects invalid', () {
      expect(Validators.email('bad'), isNotNull);
      expect(Validators.email('a@b'), isNotNull);
      expect(Validators.email('@x.com'), isNotNull);
    });

    test('accepts valid', () {
      expect(Validators.email('a@b.com'), isNull);
      expect(Validators.email('  user@example.org  '), isNull);
    });
  });

  group('Validators.password', () {
    test('rejects empty', () {
      expect(Validators.password(null), 'Password is required');
      expect(Validators.password(''), 'Password is required');
    });

    test('accepts any non-empty (login)', () {
      expect(Validators.password('x'), isNull);
    });
  });

  group('Validators.passwordStrong', () {
    test('enforces rules', () {
      expect(Validators.passwordStrong('short'), isNotNull);
      expect(Validators.passwordStrong('nouppercase1'), isNotNull);
      expect(Validators.passwordStrong('NoNumber'), isNotNull);
      expect(Validators.passwordStrong('Password1'), isNull);
    });
  });

  test('confirmPassword', () {
    expect(Validators.confirmPassword('a', 'b'), 'Passwords do not match');
    expect(Validators.confirmPassword('a', 'a'), isNull);
  });
}
