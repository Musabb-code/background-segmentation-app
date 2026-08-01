class User {
  const User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.isVerified,
    this.profileImageUrl,
  });

  final String id;
  final String fullName;
  final String email;
  final bool isVerified;
  final String? profileImageUrl;

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as String? ?? json['userId'] as String? ?? '',
        fullName: json['fullName'] as String? ?? '',
        email: json['email'] as String? ?? '',
        isVerified: json['isVerified'] as bool? ?? false,
        profileImageUrl: json['profileImageUrl'] as String?,
      );
}
