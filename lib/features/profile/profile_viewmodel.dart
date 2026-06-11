import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/user_profile_model.dart';
import 'services/user_service.dart';

// ─── State ────────────────────────────────────────────────────────────────────
class ProfileState {
  final bool isLoading;
  final bool isSaving;
  final UserProfileModel? profile;
  final String? errorMessage;

  const ProfileState({
    this.isLoading = false,
    this.isSaving = false,
    this.profile,
    this.errorMessage,
  });

  ProfileState copyWith({
    bool? isLoading,
    bool? isSaving,
    UserProfileModel? profile,
    String? errorMessage,
    bool clearError = false,
  }) =>
      ProfileState(
        isLoading: isLoading ?? this.isLoading,
        isSaving: isSaving ?? this.isSaving,
        profile: profile ?? this.profile,
        errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      );
}

// ─── ViewModel ────────────────────────────────────────────────────────────────
class ProfileViewModel extends StateNotifier<ProfileState> {
  final UserService _userService;

  ProfileViewModel(this._userService) : super(const ProfileState());

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final profile = await _userService.getMyProfile();
      state = state.copyWith(isLoading: false, profile: profile);
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _parseError(e),
      );
    }
  }

  Future<bool> updateProfile(UpdateProfileRequest request) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final updated = await _userService.updateMyProfile(request);
      state = state.copyWith(isSaving: false, profile: updated);
      return true;
    } on DioException catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: _parseError(e),
      );
      return false;
    }
  }

  String _parseError(DioException e) {
    final message = e.response?.data?['message'];
    if (message != null && message is String) return message;
    return switch (e.response?.statusCode) {
      400 => 'Thông tin không hợp lệ',
      401 => 'Phiên đăng nhập hết hạn',
      500 => 'Lỗi server, vui lòng thử lại',
      null => 'Không thể kết nối server',
      _ => 'Đã có lỗi xảy ra',
    };
  }
}

// ─── Providers ────────────────────────────────────────────────────────────────
final userServiceProvider = Provider<UserService>((ref) => UserService());

final profileViewModelProvider =
    StateNotifierProvider<ProfileViewModel, ProfileState>((ref) {
  return ProfileViewModel(ref.watch(userServiceProvider));
});