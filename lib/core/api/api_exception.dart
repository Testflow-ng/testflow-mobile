import 'package:dio/dio.dart';

class ApiException implements Exception {
  final int status;
  final String code;
  final String message;

  const ApiException({
    required this.status,
    required this.code,
    required this.message,
  });

  factory ApiException.fromDio(DioException error) {
    final response = error.response;
    final data = response?.data;
    String? code;
    String? message;

    if (data is Map<String, dynamic>) {
      final err = data['error'];
      if (err is Map<String, dynamic>) {
        code = err['code'] as String?;
        message = err['message'] as String?;
      }
      message ??= data['message'] as String?;
    }

    return ApiException(
      status: response?.statusCode ?? 0,
      code: code ?? 'NETWORK_ERROR',
      message: message ??
          (response == null
              ? 'Could not reach the server. It may be waking up, wait a few seconds and try again.'
              : 'Something went wrong. Please try again.'),
    );
  }

  bool get isUnauthenticated => status == 401;
  bool get isNetwork => status == 0;

  @override
  String toString() => message;
}
