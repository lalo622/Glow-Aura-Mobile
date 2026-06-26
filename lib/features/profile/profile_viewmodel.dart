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

    final result = await _userService.getMyProfile();

    if (result.error != null) {
      state = state.copyWith(isLoading: false, errorMessage: result.error!.message);
      return;
    }

    state = state.copyWith(isLoading: false, profile: result.data);
  }

  Future<bool> updateProfile(UpdateProfileRequest request) async {
    state = state.copyWith(isSaving: true, clearError: true);

    final result = await _userService.updateMyProfile(request);

    if (result.error != null) {
      state = state.copyWith(isSaving: false, errorMessage: result.error!.message);
      return false;
    }

    state = state.copyWith(isSaving: false, profile: result.data);
    return true;

  }

  void clearError() => state = state.copyWith(clearError: true);
}

// ─── Providers ────────────────────────────────────────────────────────────────
final userServiceProvider = Provider<UserService>((ref) => UserService());

final profileViewModelProvider =
    StateNotifierProvider<ProfileViewModel, ProfileState>((ref) {
  return ProfileViewModel(ref.watch(userServiceProvider));
});