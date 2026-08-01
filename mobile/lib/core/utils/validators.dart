class Validators {
  Validators._();

  static final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final _passwordStrong = RegExp(r'^(?=.*[A-Z])(?=.*\d).{8,}$');

  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    if (!_email.hasMatch(v.trim())) return 'Enter a valid email';
    return null;
  }

  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    return null;
  }

  static String? passwordStrong(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (!_passwordStrong.hasMatch(v)) {
      return 'Min 8 chars, 1 uppercase, 1 number';
    }
    return null;
  }

  static String? fullName(String? v) {
    if (v == null || v.trim().length < 2) return 'Name must be at least 2 characters';
    return null;
  }

  static String? confirmPassword(String? v, String password) {
    if (v != password) return 'Passwords do not match';
    return null;
  }
}
