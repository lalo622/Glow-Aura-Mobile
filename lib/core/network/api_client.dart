import 'package:dio/dio.dart';
import 'token_storage.dart';
 
class ApiClient {
  static const _baseUrl = 'https://glowauraapimongodb-production.up.railway.app/api';
 
  static final Dio _dio = Dio(BaseOptions(
    baseUrl:        _baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    headers: {'Content-Type': 'application/json'},
  ))
    ..interceptors.add(_AuthInterceptor())
    ..interceptors.add(LogInterceptor(
      requestBody:  true,
      responseBody: true,
      logPrint: (o) => print('[API] $o'),   
    ));
 
  static Dio get instance => _dio;
}
 

class _AuthInterceptor extends Interceptor {
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
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.next(err);
  }
}