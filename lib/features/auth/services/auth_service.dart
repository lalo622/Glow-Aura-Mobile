import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/token_storage.dart';
import '../models/auth_models.dart';

class AuthService {
  final Dio _dio = ApiClient.instance.dio;

  // ─── Register ─────────────────────────────────────────────────
  Future<AuthResponse> register(RegisterRequest request) async {
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
  }

  // ─── Login ────────────────────────────────────────────────────
  Future<AuthResponse> login(LoginRequest request) async {
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
  }

  // ─── Logout ───────────────────────────────────────────────────
  Future<void> logout() async {
    try {
      await _dio.post(ApiEndpoints.logout);
    } catch (_) {
      // Dù BE lỗi vẫn xóa token local
    } finally {
      await TokenStorage.clearTokens();
    }
  }

  // ─── Change Password ──────────────────────────────────────────
  Future<AuthResponse> changePassword(ChangePasswordRequest request) async {
    final response = await _dio.post(
      ApiEndpoints.changePassword,
      data: request.toJson(),
    );
    return AuthResponse.fromJson(response.data);
  }

  // ─── Check login state ────────────────────────────────────────
  Future<bool> isLoggedIn() async {
    final token = await TokenStorage.getAccessToken();
    return token != null;
  }
}