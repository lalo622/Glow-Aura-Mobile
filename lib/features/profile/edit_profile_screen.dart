import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:glow_aura/core/theme/app_theme.dart';
import 'package:glow_aura/features/profile/models/user_profile_model.dart';
import 'package:glow_aura/features/profile/profile_viewmodel.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _initialized = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _initFromProfile(UserProfileModel profile) {
  if (_initialized) return;
  _initialized = true;
  _nameCtrl.text = profile.fullName;
  _phoneCtrl.text = profile.phoneNumber ?? '';
}

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

      final ok = await ref.read(profileViewModelProvider.notifier).updateProfile(
        UpdateProfileRequest(
          fullName: _nameCtrl.text.trim(),
          phoneNumber: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
        ),
      );

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cập nhật thành công!',
              style: AppTextStyles.body(color: Colors.white)),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      context.go('/profile');
    } else {
      final error = ref.read(profileViewModelProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Cập nhật thất bại',
              style: AppTextStyles.body(color: Colors.white)),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileViewModelProvider);

    // Điền form khi profile load xong
    if (profileState.profile != null) {
      _initFromProfile(profileState.profile!);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/profile'),
        ),
        title: Text('Chỉnh sửa hồ sơ', style: AppTextStyles.title()),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: profileState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(AppColors.s16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: AppColors.s16),

                            // ── Avatar ───────────────────────────────────
                            Center(
                              child: Stack(
                                children: [
                                  Container(
                                    width: 96,
                                    height: 96,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryTint,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: AppColors.primary, width: 2),
                                    ),
                                    child: const Icon(Icons.person,
                                        size: 52, color: AppColors.primary),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: () {},
                                      child: Container(
                                        width: 32,
                                        height: 32,
                                        decoration: const BoxDecoration(
                                          color: AppColors.primary,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                            Icons.camera_alt_outlined,
                                            color: Colors.white,
                                            size: 16),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppColors.s8),
                            Center(
                              child: TextButton(
                                onPressed: () {},
                                child: Text('Thay đổi ảnh đại diện',
                                    style: AppTextStyles.body(
                                        color: AppColors.primary)),
                              ),
                            ),
                            const SizedBox(height: AppColors.s24),

                            // ── Thông tin cơ bản ─────────────────────────
                            const _SectionLabel('THÔNG TIN CƠ BẢN'),
                            const SizedBox(height: AppColors.s12),

                            const _FieldLabel('Họ và tên'),
                            const SizedBox(height: AppColors.s8),
                            TextFormField(
                              controller: _nameCtrl,
                              validator: (v) => (v == null || v.isEmpty)
                                  ? 'Vui lòng nhập họ tên'
                                  : null,
                              decoration: const InputDecoration(
                                hintText: 'Nhập họ và tên',
                                prefixIcon: Icon(Icons.person_outline,
                                    color: AppColors.textTertiary, size: 20),
                              ),
                            ),
                            const SizedBox(height: AppColors.s16),

                            // Email 
                            const _FieldLabel('Email'),
                            const SizedBox(height: AppColors.s8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppColors.s16,
                                  vertical: AppColors.s12),
                              decoration: BoxDecoration(
                                color: AppColors.primarySubtle,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.mail_outline,
                                      color: AppColors.textTertiary, size: 20),
                                  const SizedBox(width: AppColors.s12),
                                  Text(
                                    profileState.profile?.email ?? '---',
                                    style: AppTextStyles.body(
                                        color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppColors.s16),

                            const _FieldLabel('Số điện thoại'),
                            const SizedBox(height: AppColors.s8),
                            TextFormField(
                              controller: _phoneCtrl,
                              keyboardType: TextInputType.phone,
                              validator: (v) {
                                if (v == null || v.isEmpty) return null; // optional
                                final ok = RegExp(r'^0\d{9}$').hasMatch(v.trim());
                                return ok ? null : 'Số điện thoại không hợp lệ';
                              },
                              decoration: const InputDecoration(
                                hintText: 'Nhập số điện thoại',
                                prefixIcon: Icon(Icons.phone_outlined,
                                    color: AppColors.textTertiary, size: 20),
                              ),
                            ),
                            const SizedBox(height: AppColors.s24),
                          ],
                        ),
                      ),
                    ),

                    // ── Save button ───────────────────────────────────────
                    Container(
                      padding: const EdgeInsets.fromLTRB(AppColors.s16,
                          AppColors.s12, AppColors.s16, AppColors.s24),
                      decoration: const BoxDecoration(
                        color: AppColors.surface,
                        border:
                            Border(top: BorderSide(color: AppColors.border)),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: profileState.isSaving ? null : _save,
                          child: profileState.isSaving
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2.5),
                                )
                              : const Text('Lưu thay đổi'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}


class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) =>
      Text(text, style: AppTextStyles.label(color: AppColors.primary));
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(
        text,
        style: AppTextStyles.body(color: const Color.fromARGB(255, 117, 56, 56))
            .copyWith(fontWeight: FontWeight.w600),
      );
}