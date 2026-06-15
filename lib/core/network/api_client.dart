import 'package:dio/dio.dart';
import 'api_endpoints.dart';
import '../../core/network/token_storage.dart';

class ApiClient {
  static ApiClient? _instance;
  late final Dio _dio;

  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    

    _dio.interceptors.add(_AuthInterceptor(_dio));
  }

  static ApiClient get instance => _instance ??= ApiClient._internal();

  Dio get dio => _dio;
}


class _AuthInterceptor extends Interceptor {
  final Dio _dio;
  bool _isRefreshing = false;

  _AuthInterceptor(this._dio);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await TokenStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final is401 = err.response?.statusCode == 401;
    final isNotRefreshEndpoint =
        !err.requestOptions.path.contains('refresh-token');

    if (is401 && isNotRefreshEndpoint && !_isRefreshing) {
      _isRefreshing = true;
      try {
        final newAccessToken = await _tryRefresh();
        if (newAccessToken != null) {
          err.requestOptions.headers['Authorization'] =
              'Bearer $newAccessToken';
          final response = await _dio.fetch(err.requestOptions);
          handler.resolve(response);
          return;
        }
      } catch (_) {
        await TokenStorage.clearTokens();
      } finally {
        _isRefreshing = false;
      }
    }

    handler.next(err);
  }

  Future<String?> _tryRefresh() async {
    final refreshToken = await TokenStorage.getRefreshToken();
    if (refreshToken == null) return null;

    final response = await _dio.post(
      ApiEndpoints.refreshToken,
      data: {'refreshToken': refreshToken},
    );

    if (response.statusCode == 200 && response.data['isSuccess'] == true) {
      final token = response.data['token'];
      await TokenStorage.saveTokens(
        accessToken: token['accessToken'] as String,
        refreshToken: token['refreshToken'] as String,
      );
      return token['accessToken'] as String;
    }

    return null;
  }
}