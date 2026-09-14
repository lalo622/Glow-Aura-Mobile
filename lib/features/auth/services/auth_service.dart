import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/safe_call.dart';
import '../../../../core/network/token_storage.dart';
import '../data/models/auth_models.dart';
import 'package:flutter/foundation.dart';
class AuthService {
  final Dio _dio = ApiClient.instance.dio;

  Future<SafeResult<AuthResponse>> register(RegisterRequest request) =>
      safeCall(() async {
        final response = await _dio.post(
          ApiEndpoints.register,
          data: request.toJson(),
        );
        final result = AuthResponse.fromJson(response.data);
        if (result.isSuccess && result.token != null) {
          await TokenStorage.saveTokens(
            accessToken: result.token!.accessToken,
            refreshToken: result.token!.refreshToken,
          );
        }
        return result;
      });

  Future<SafeResult<AuthResponse>> login(LoginRequest request) =>
      safeCall(() async {
        final response = await _dio.post(
          ApiEndpoints.login,
          data: request.toJson(),
        );
        final result = AuthResponse.fromJson(response.data);
        if (result.isSuccess && result.token != null) {
          await TokenStorage.saveTokens(
            accessToken: result.token!.accessToken,
            refreshToken: result.token!.refreshToken,
          );
        }
        return result;
      });

  Future<void> logout() async {
    try {
      await _dio.post(ApiEndpoints.logout);
    } catch (_) {
    } finally {
      await TokenStorage.clearTokens();
    }
  }

  Future<SafeResult<AuthResponse>> changePassword(ChangePasswordRequest request) =>
      safeCall(() async {
        final response = await _dio.post(
          ApiEndpoints.changePassword,
          data: request.toJson(),
        );
        return AuthResponse.fromJson(response.data);
      });

  Future<bool> isLoggedIn() async {
    final token = await TokenStorage.getAccessToken();
    return token != null;
  }
  Future<SafeResult<AuthResponse>> googleLogin(
    GoogleLoginRequest request) =>
  safeCall(() async {
    final response = await _dio.post(
      ApiEndpoints.googleLogin,
      data: request.toJson(),
    );
    final result = AuthResponse.fromJson(response.data);
    if (result.isSuccess && result.token != null) {
      await TokenStorage.saveTokens(
        accessToken: result.token!.accessToken,
        refreshToken: result.token!.refreshToken,
      );
    }

    return result;
  });
}