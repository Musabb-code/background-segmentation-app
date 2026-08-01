import 'user.dart';

class AuthResponse {
  const AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    this.user,
  });

  final String accessToken;
  final String refreshToken;
  final User? user;

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
        accessToken: json['accessToken'] as String,
        refreshToken: json['refreshToken'] as String,
        user: json['user'] is Map<String, dynamic>
            ? User.fromJson(json['user'] as Map<String, dynamic>)
            : null,
      );
}
