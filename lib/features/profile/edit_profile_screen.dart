import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:glow_aura/core/theme/app_theme.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController(text: 'Gia Tiến');
  final _emailCtrl = TextEditingController(
      text: 'tkonn552@gmail.com');
  final _ageCtrl = TextEditingController(text: '24');
  String _selectedSkinType = 'Da hỗn hợp';
  bool _isSaving = false;

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
    _emailCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Cập nhật thành công!',
            style: AppTextStyles.body(color: Colors.white)),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
      ),
    );
    context.go('/profile');
  }

  @override
  Widget build(BuildContext context) {
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
      body: SafeArea(
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

                      // ── Avatar ──────────────────────────────────────────
                      Center(
                        child: Stack(
                          children: [
                            Container(
                              width: 96, height: 96,
                              decoration: BoxDecoration(
                                color: AppColors.primaryTint,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: AppColors.primary,
                                    width: 2),
                              ),
                              child: const Icon(Icons.person,
                                  size: 52, color: AppColors.primary),
                            ),
                            Positioned(
                              bottom: 0, right: 0,
                              child: GestureDetector(
                                onTap: () {},
                                child: Container(
                                  width: 32, height: 32,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                      Icons.camera_alt_outlined,
                                      color: Colors.white, size: 16),
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

                      // ── Thông tin cơ bản ────────────────────────────────
                      _SectionLabel('THÔNG TIN CƠ BẢN'),
                      const SizedBox(height: AppColors.s12),

                      _FieldLabel('Họ và tên'),
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

                      _FieldLabel('Email'),
                      const SizedBox(height: AppColors.s8),
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Vui lòng nhập email'
                            : null,
                        decoration: const InputDecoration(
                          hintText: 'Nhập email',
                          prefixIcon: Icon(Icons.mail_outline,
                              color: AppColors.textTertiary, size: 20),
                        ),
                      ),
                      const SizedBox(height: AppColors.s16),

                      _FieldLabel('Tuổi'),
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

                      // ── Thông tin da ────────────────────────────────────
                      _SectionLabel('THÔNG TIN DA'),
                      const SizedBox(height: AppColors.s12),

                      _FieldLabel('Loại da'),
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
                            onChanged: (v) {
                              if (v != null) {
                                setState(
                                    () => _selectedSkinType = v);
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: AppColors.s24),

                      // ── Skin concerns ───────────────────────────────────
                      _SectionLabel('VẤN ĐỀ DA QUAN TÂM'),
                      const SizedBox(height: AppColors.s12),
                      _SkinConcernChips(),
                      const SizedBox(height: AppColors.s32),
                    ],
                  ),
                ),
              ),

              // ── Save button ───────────────────────────────────────────
              Container(
                padding: const EdgeInsets.fromLTRB(
                    AppColors.s16, AppColors.s12,
                    AppColors.s16, AppColors.s24),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border:
                      Border(top: BorderSide(color: AppColors.border)),
                ),
                child: SizedBox(
                  width: double.infinity, height: 52,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    child: _isSaving
                        ? const SizedBox(
                            width: 22, height: 22,
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
          onTap: () => setState(
              () => _concerns[entry.key] = !entry.value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(
                horizontal: AppColors.s12, vertical: AppColors.s8),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.primaryTint
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected
                    ? AppColors.primary
                    : AppColors.border,
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

// ── Helper widgets ────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: AppTextStyles.label(color: AppColors.primary));
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: AppTextStyles.body(color: AppColors.textSecondary)
            .copyWith(fontWeight: FontWeight.w600));
  }
}