class ApiConstants {
  ApiConstants._();

  static const accessTokenKey = 'access_token';
  static const refreshTokenKey = 'refresh_token';

  static const login = '/api/auth/login';
  static const register = '/api/auth/register';
  static const verify = '/api/auth/verify';
  static const forgotPassword = '/api/auth/forgot-password';
  static const resetPassword = '/api/auth/reset-password';
  static const refresh = '/api/auth/refresh';
  static const logout = '/api/auth/logout';
  static const me = '/api/users/me';
  static const mePassword = '/api/users/me/password';
  static const segment = '/inference/segment';
}
