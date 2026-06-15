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
  final _ageCtrl = TextEditingController();
  String? _selectedSkinType;
  bool _initialized = false;

  final _skinTypes = [
    'Da thường',
    'Da khô',
    'Da dầu',
    'Da hỗn hợp',
    'Da nhạy cảm',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  void _initFromProfile(UserProfileModel profile) {
    if (_initialized) return;
    _initialized = true;
    _nameCtrl.text = profile.fullName;
    _ageCtrl.text = profile.age?.toString() ?? '';
    _selectedSkinType = _skinTypes.contains(profile.skinType)
        ? profile.skinType
        : null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final ok = await ref.read(profileViewModelProvider.notifier).updateProfile(
          UpdateProfileRequest(
            fullName: _nameCtrl.text.trim(),
            age: int.tryParse(_ageCtrl.text.trim()),
            skinType: _selectedSkinType,
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

                            const _FieldLabel('Tuổi'),
                            const SizedBox(height: AppColors.s8),
                            TextFormField(
                              controller: _ageCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                hintText: 'Nhập tuổi',
                                prefixIcon: Icon(Icons.cake_outlined,
                                    color: AppColors.textTertiary, size: 20),
                              ),
                            ),
                            const SizedBox(height: AppColors.s24),

                            // ── Thông tin da ─────────────────────────────
                            const _SectionLabel('THÔNG TIN DA'),
                            const SizedBox(height: AppColors.s12),

                            const _FieldLabel('Loại da'),
                            const SizedBox(height: AppColors.s8),
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedSkinType,
                                  hint: Text('Chọn loại da',
                                      style: AppTextStyles.body(
                                          color: AppColors.textTertiary)),
                                  isExpanded: true,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: AppColors.s16),
                                  borderRadius: BorderRadius.circular(12),
                                  items: _skinTypes
                                      .map((type) => DropdownMenuItem(
                                            value: type,
                                            child: Text(type,
                                                style: AppTextStyles.body(
                                                    color:
                                                        AppColors.textPrimary)),
                                          ))
                                      .toList(),
                                  onChanged: (v) =>
                                      setState(() => _selectedSkinType = v),
                                ),
                              ),
                            ),
                            const SizedBox(height: AppColors.s24),

                            // ── Skin concerns ─────────────────────────────
                            const _SectionLabel('VẤN ĐỀ DA QUAN TÂM'),
                            const SizedBox(height: AppColors.s12),
                            _SkinConcernChips(),
                            const SizedBox(height: AppColors.s32),
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

// ── Skin concern chips ────────────────────────────────────────────────────────
class _SkinConcernChips extends StatefulWidget {
  @override
  State<_SkinConcernChips> createState() => _SkinConcernChipsState();
}

class _SkinConcernChipsState extends State<_SkinConcernChips> {
  final _concerns = {
    'Mụn': false,
    'Lỗ chân lông': false,
    'Thâm mụn': true,
    'Nếp nhăn': false,
    'Da dầu': true,
    'Nhạy cảm': false,
    'Tàn nhang': false,
    'Thâm quầng': false,
  };

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppColors.s8,
      runSpacing: AppColors.s8,
      children: _concerns.entries.map((entry) {
        final selected = entry.value;
        return GestureDetector(
          onTap: () =>
              setState(() => _concerns[entry.key] = !entry.value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(
                horizontal: AppColors.s12, vertical: AppColors.s8),
            decoration: BoxDecoration(
              color:
                  selected ? AppColors.primaryTint : AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color:
                    selected ? AppColors.primary : AppColors.border,
              ),
            ),
            child: Text(
              entry.key,
              style: AppTextStyles.body(
                color: selected
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ).copyWith(
                fontWeight: selected
                    ? FontWeight.w600
                    : FontWeight.w400,
              ),
            ),
          ),
        );
      }).toList(),
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
        style: AppTextStyles.body(color: AppColors.textSecondary)
            .copyWith(fontWeight: FontWeight.w600),
      );
}