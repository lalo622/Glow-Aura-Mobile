import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/auth_models.dart';
import 'services/auth_service.dart';

// ─── Entity ───────────────────────────────────────────────────────────────────
class UserEntity {
  final String id;
  final String fullName;
  final String email;
  final String role;
  final String vipLevel;

  const UserEntity({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.vipLevel,
  });

  factory UserEntity.fromModel(UserModel model) => UserEntity(
        id: model.id,
        fullName: model.fullName,
        email: model.email,
        role: model.role,
        vipLevel: model.vipLevel,
      );
}

// ─── State ────────────────────────────────────────────────────────────────────
class AuthState {
  final bool isLoading;
  final UserEntity? user;
  final String? errorMessage;

  const AuthState({
    this.isLoading = false,
    this.user,
    this.errorMessage,
  });

  bool get isLoggedIn => user != null;

  AuthState copyWith({
    bool? isLoading,
    UserEntity? user,
    String? errorMessage,
    bool clearUser = false,
    bool clearError = false,
  }) =>
      AuthState(
        isLoading: isLoading ?? this.isLoading,
        user: clearUser ? null : user ?? this.user,
        errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      );
}

// ─── ViewModel ────────────────────────────────────────────────────────────────
class AuthViewModel extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthViewModel(this._authService) : super(const AuthState());

  // ─── Login ──────────────────────────────────────────────────
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final result = await _authService.login(
        LoginRequest(email: email, password: password),
      );

      if (result.isSuccess && result.user != null) {
        state = state.copyWith(
          isLoading: false,
          user: UserEntity.fromModel(result.user!),
        );
        return true;
      }

      state = state.copyWith(
        isLoading: false,
        errorMessage: result.message,
      );
      return false;
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _parseError(e),
      );
      return false;
    }
  }

  // ─── Register ───────────────────────────────────────────────
  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
    required String phoneNumber,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final result = await _authService.register(
        RegisterRequest(
          email: email,
          password: password,
          confirmPassword: confirmPassword,
          fullName: fullName,
          phoneNumber: phoneNumber,
        ),
      );

      if (result.isSuccess && result.user != null) {
        state = state.copyWith(
          isLoading: false,
          user: UserEntity.fromModel(result.user!),
        );
        return true;
      }

      state = state.copyWith(
        isLoading: false,
        errorMessage: result.message,
      );
      return false;
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _parseError(e),
      );
      return false;
    }
  }

  // ─── Logout ─────────────────────────────────────────────────
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    await _authService.logout();
    state = const AuthState(); 
  }
  Future<void> loginWithGoogle() async {
  }

  Future<void> loginWithFacebook() async {
  }

  // ─── Helpers ────────────────────────────────────────────────
  void clearError() => state = state.copyWith(clearError: true);

  String _parseError(DioException e) {
    final statusCode = e.response?.statusCode;
    final message = e.response?.data?['message'];

    if (message != null && message is String) return message;

    return switch (statusCode) {
      400 => 'Thông tin không hợp lệ',
      401 => 'Email hoặc mật khẩu không đúng',
      409 => 'Email đã được sử dụng',
      500 => 'Lỗi server, vui lòng thử lại',
      null => 'Không thể kết nối server',
      _ => 'Đã có lỗi xảy ra (code: $statusCode)',
    };
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authViewModelProvider =
    StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  return AuthViewModel(ref.watch(authServiceProvider));
});