import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data/models/auth_models.dart';
import 'services/auth_service.dart';
import 'services/google_auth_helper.dart';

// ─── Entity ───────────────────────────────────────────────────────────────────
class UserEntity {
  final String id;
  final String fullName;
  final String email;
  final String role;
  final String vipLevel;
  final String? phoneNumber;

  const UserEntity({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.vipLevel,
    this.phoneNumber,
  });

  factory UserEntity.fromModel(UserModel model) => UserEntity(
    id: model.id,
    fullName: model.fullName,
    email: model.email,
    role: model.role,
    vipLevel: model.vipLevel,
    phoneNumber: model.phoneNumber,
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

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _authService.login(
      LoginRequest(email: email, password: password),
    );

    if (result.error != null) {
      state = state.copyWith(isLoading: false, errorMessage: result.error!.message);
      return false;
    }

    final data = result.data!;
    if (data.isSuccess && data.user != null) {
      state = state.copyWith(isLoading: false, user: UserEntity.fromModel(data.user!));
      return true;
    }

    state = state.copyWith(isLoading: false, errorMessage: data.message);
    return false;
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
    required String phoneNumber,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _authService.register(
      RegisterRequest(
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        fullName: fullName,
        phoneNumber: phoneNumber,
      ),
    );

    if (result.error != null) {
      state = state.copyWith(isLoading: false, errorMessage: result.error!.message);
      return false;
    }

    final data = result.data!;
    if (data.isSuccess && data.user != null) {
      state = state.copyWith(isLoading: false, user: UserEntity.fromModel(data.user!));
      return true;
    }

    state = state.copyWith(isLoading: false, errorMessage: data.message);
    return false;
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    await _authService.logout();
    state = const AuthState();
  }

Future<bool> loginWithGoogle() async {
  state = state.copyWith(isLoading: true, clearError: true);

  final idToken = await GoogleAuthHelper.signInAndGetIdToken();
  if (idToken == null) {
    state = state.copyWith(isLoading: false);
    return false;
  }

  final result = await _authService.googleLogin(GoogleLoginRequest(idToken: idToken));

  if (result.error != null) {
    state = state.copyWith(isLoading: false, errorMessage: result.error!.message);
    return false;
  }

  final data = result.data!;
  if (data.isSuccess && data.user != null) {
    state = state.copyWith(isLoading: false, user: UserEntity.fromModel(data.user!));
    return true;
  }

  state = state.copyWith(isLoading: false, errorMessage: data.message);
  return false;
}  Future<void> loginWithFacebook() async {}

  void clearError() => state = state.copyWith(clearError: true);

}

// ─── Provider ─────────────────────────────────────────────────────────────────
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authViewModelProvider =
    StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  return AuthViewModel(ref.watch(authServiceProvider));
});