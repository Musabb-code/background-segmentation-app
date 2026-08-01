class ApiError implements Exception {
  ApiError({
    required this.message,
    this.code,
    this.statusCode,
  });

  final String message;
  final String? code;
  final int? statusCode;

  factory ApiError.fromJson(Map<String, dynamic> json, {int? statusCode}) {
    final errors = json['errors'];
    String message = json['message'] as String? ?? 'Request failed';
    if (errors is List && errors.isNotEmpty) {
      final first = errors.first;
      if (first is Map && first['message'] != null) {
        message = first['message'].toString();
      }
    }
    return ApiError(
      message: message,
      code: json['code'] as String?,
      statusCode: statusCode,
    );
  }

  @override
  String toString() => message;
}
