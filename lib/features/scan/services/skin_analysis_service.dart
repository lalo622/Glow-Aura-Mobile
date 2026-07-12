import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/app_exception.dart';
import '../../../core/network/safe_call.dart';
import '../../../core/network/token_storage.dart';
import '../data/models/skin_analysis_history.dart';
import '../data/models/skin_analysis_result.dart';

class SkinAnalysisService {
  final Dio _dio;

  SkinAnalysisService(this._dio);

  /// Upload ảnh để phân tích da.
  ///
  /// [onProgress] callback (0.0 → 1.0) — đây là % UPLOAD (gửi bytes lên),
  /// không phải % xử lý AI ở server.
  Future<SafeResult<SkinAnalysisResult>> analyzeImage(
    String imagePath, {
    void Function(double progress)? onProgress,
    CancelToken? cancelToken,
  }) =>
      safeCall(() async {
        final fileName = imagePath.split('/').last;

        final formData = FormData.fromMap({
          'image': await MultipartFile.fromFile(imagePath, filename: fileName),
        });

        final response = await _dio.post(
          ApiEndpoints.skinAnalysisAnalyze,
          data: formData,
          cancelToken: cancelToken,
          options: Options(
            headers: {'Content-Type': 'multipart/form-data'},
            sendTimeout: const Duration(seconds: 60),
            receiveTimeout: const Duration(seconds: 60),
          ),
          onSendProgress: (sent, total) {
            if (total <= 0) return;
            onProgress?.call(sent / total);
          },
        );

        final data = response.data;
        if (data is! Map<String, dynamic>) {
          throw const AppException(
            type: AppErrorType.unknown,
            message: 'Phản hồi từ server không đúng định dạng.',
          );
        }

        return SkinAnalysisResult.fromJson(data);
      });

  /// Lấy lịch sử các lần phân tích da của người dùng đang đăng nhập.
  Future<SafeResult<SkinAnalysisHistoryResponse>> getHistory({int? limit}) =>
      safeCall(() async {
        final userId = await _getCurrentUserId();
        if (userId == null) {
          throw const AppException(
            type: AppErrorType.unauthorized,
            message: 'Không xác định được người dùng. Vui lòng đăng nhập lại.',
            statusCode: 401,
          );
        }

        final response = await _dio.get(
          ApiEndpoints.skinAnalysisHistory,
          queryParameters: {
            'userId': userId,
            if (limit != null) 'limit': limit,
          },
        );

        final data = response.data;
        if (data is! Map<String, dynamic>) {
          throw const AppException(
            type: AppErrorType.unknown,
            message: 'Phản hồi từ server không đúng định dạng.',
          );
        }

        return SkinAnalysisHistoryResponse.fromJson(data);
      });

  /// Đọc userId từ claim "nameidentifier" trong JWT access token hiện tại.
  Future<String?> _getCurrentUserId() async {
    final token = await TokenStorage.getAccessToken();
    if (token == null) return null;
    try {
      final decoded = JwtDecoder.decode(token);
      return decoded[
          'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier']
          as String?;
    } catch (_) {
      return null;
    }
  }
}

final skinAnalysisServiceProvider = Provider<SkinAnalysisService>((ref) {
  return SkinAnalysisService(ApiClient.instance.dio);
});