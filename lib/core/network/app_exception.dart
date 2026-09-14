import 'package:dio/dio.dart';
import '../network/api_endpoints.dart'; 

enum AppErrorType {
  network,      // Mất mạng, timeout
  server,       // 5xx
  unauthorized, // 401
  notFound,     // 404
  badRequest,   // 400
  unknown,
}

class AppException implements Exception {
  final AppErrorType type;
  final String message;
  final int? statusCode;

  const AppException({
    required this.type,
    required this.message,
    this.statusCode,
  });

  factory AppException.fromDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return const AppException(
          type: AppErrorType.network,
          message: 'Kết nối quá chậm, vui lòng thử lại.',
        );
      case DioExceptionType.connectionError:
        return const AppException(
          type: AppErrorType.network,
          message: 'Không có kết nối mạng.',
        );
      case DioExceptionType.badResponse:
        return AppException._fromStatusCode(
          e.response?.statusCode,
          e.response?.data,
          isLoginRequest: e.requestOptions.path == ApiEndpoints.login,
        );
      default:
        return AppException(
          type: AppErrorType.unknown,
          message: e.message ?? 'Đã xảy ra lỗi không xác định.',
        );
    }
  }

  factory AppException._fromStatusCode(
    int? code,
    dynamic data, {
    bool isLoginRequest = false,
  }) {
    String? beMessage;
    if (data is Map<String, dynamic>) {
      beMessage = data['message'] as String?;
    }

    if (code == 401) {
      if (isLoginRequest) {
        return AppException(
          type: AppErrorType.unauthorized,
          message: beMessage ?? 'Email hoặc mật khẩu không chính xác.',
          statusCode: 401,
        );
      }
      return const AppException(
        type: AppErrorType.unauthorized,
        message: 'Phiên đăng nhập đã hết hạn.',
        statusCode: 401,
      );
    } else if (code == 404) {
      return AppException(
        type: AppErrorType.notFound,
        message: beMessage ?? 'Không tìm thấy dữ liệu.',
        statusCode: 404,
      );
    } else if (code == 400) {
      return AppException(
        type: AppErrorType.badRequest,
        message: beMessage ?? 'Yêu cầu không hợp lệ.',
        statusCode: 400,
      );
    } else if (code != null && code >= 500) {
      return AppException(
        type: AppErrorType.server,
        message: 'Máy chủ đang gặp sự cố, vui lòng thử lại sau.',
        statusCode: code,
      );
    } else {
      return AppException(
        type: AppErrorType.unknown,
        message: beMessage ?? 'Đã xảy ra lỗi ($code).',
        statusCode: code,
      );
    }
  }

  @override
  String toString() => message;
}