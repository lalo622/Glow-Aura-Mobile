import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserEntity {
  final String id;
  final String fullName;
  final String email;
  const UserEntity({required this.id, required this.fullName, required this.email});
}

class AuthState {
  final bool isLoading;
  final UserEntity? user;
  final String? errorMessage;

  const AuthState({this.isLoading = false, this.user, this.errorMessage});

  AuthState copyWith({bool? isLoading, UserEntity? user, String? errorMessage}) =>
      AuthState(
        isLoading: isLoading ?? this.isLoading,
        user: user ?? this.user,
        errorMessage: errorMessage,
      );
}

class AuthViewModel extends StateNotifier<AuthState> {
  AuthViewModel() : super(const AuthState());

  static const _mockUser = UserEntity(
    id: 'mock_001',
    fullName: 'Gia Tien',
    email: 'tkonn552@gmail.com',
  );

  Future<bool> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (email.isEmpty || password.length < 6) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Email hoặc mật khẩu không hợp lệ',
      );
      return false;
    }
    state = state.copyWith(isLoading: false, user: _mockUser);
    return true;
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    await Future.delayed(const Duration(milliseconds: 1500));
    state = state.copyWith(
      isLoading: false,
      user: UserEntity(
        id: 'u_${DateTime.now().millisecondsSinceEpoch}',
        fullName: fullName,
        email: email,
      ),
    );
    return true;
  }

  Future<void> loginWithGoogle() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 800));
    state = state.copyWith(isLoading: false);
  }

  Future<void> loginWithFacebook() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 800));
    state = state.copyWith(isLoading: false);
  }

  void clearError() => state = state.copyWith(errorMessage: null);
}

final authViewModelProvider =
    StateNotifierProvider<AuthViewModel, AuthState>((ref) => AuthViewModel());