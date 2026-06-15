  import 'package:flutter/material.dart';
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import 'package:go_router/go_router.dart';
  import 'package:glow_aura/core/theme/app_theme.dart';
  import 'package:glow_aura/features/auth/auth_viewmodel.dart';
  import 'package:glow_aura/shared/widgets/shared_widgets.dart';
  import 'package:google_fonts/google_fonts.dart';

  class RegisterScreen extends ConsumerStatefulWidget {
    const RegisterScreen({super.key});

    @override
    ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
  }

  class _RegisterScreenState extends ConsumerState<RegisterScreen> {
    final _formKey = GlobalKey<FormState>();
    final _nameCtrl = TextEditingController();
    final _emailCtrl = TextEditingController();
    final _passCtrl = TextEditingController();
    final _confirmCtrl = TextEditingController();
    bool _agreed = false;

    @override
    void dispose() {
      _nameCtrl.dispose(); _emailCtrl.dispose();
      _passCtrl.dispose(); _confirmCtrl.dispose();
      super.dispose();
    }

    Future<void> _onRegister() async {
      if (!_formKey.currentState!.validate()) return;
      if (!_agreed) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Vui lòng đồng ý với điều khoản sử dụng', style: GoogleFonts.dmSans()),
          backgroundColor: AppColors.primary,
        ));
        return;
      }
      final ok = await ref.read(authViewModelProvider.notifier).register(
        fullName: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
        confirmPassword: _confirmCtrl.text,
        phoneNumber: '',   
      );
      if (ok && mounted) context.go('/home');
    }

    @override
    Widget build(BuildContext context) {
      final state = ref.watch(authViewModelProvider);

      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  IconButton(
                    onPressed: () => context.go('/login'),
                    icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                    padding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 16),

                  // Spark logo placeholder
                  Container(
                    width: 52, height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.primarySubtle,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Center(child: Text('✦',
                      style: TextStyle(fontSize: 24, color: AppColors.primary))),
                  ),
                  const SizedBox(height: 16),

                  Text('Tham gia Glow Aura', style: Theme.of(context).textTheme.displayMedium),
                  const SizedBox(height: 8),
                  Text('Tạo tài khoản để bắt đầu hành trình làm đẹp của bạn.',
                    style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 28),

                  if (state.errorMessage != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(state.errorMessage!, style: GoogleFonts.dmSans(
                        fontSize: 13, color: AppColors.error)),
                    ),
                    const SizedBox(height: 16),
                  ],

                  const _FieldLabel('Họ và tên'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _nameCtrl,
                    validator: (v) => (v == null || v.isEmpty) ? 'Vui lòng nhập họ tên' : null,
                    decoration: const InputDecoration(
                      hintText: 'Nhập họ và tên của bạn',
                      prefixIcon: Icon(Icons.person_outline, color: AppColors.textTertiary, size: 20),
                    ),
                  ),
                  const SizedBox(height: 14),

                  const _FieldLabel('Email'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => (v == null || v.isEmpty) ? 'Vui lòng nhập email' : null,
                    decoration: const InputDecoration(
                      hintText: 'example@gmail.com',
                      prefixIcon: Icon(Icons.mail_outline, color: AppColors.textTertiary, size: 20),
                    ),
                  ),
                  const SizedBox(height: 14),

                  const _FieldLabel('Mật khẩu'),
                  const SizedBox(height: 6),
                  PasswordField(
                    controller: _passCtrl,
                    hintText: '• • • • • • • •',
                    validator: (v) => (v == null || v.length < 6) ? 'Tối thiểu 6 ký tự' : null,
                  ),
                  const SizedBox(height: 14),

                  const _FieldLabel('Xác nhận mật khẩu'),
                  const SizedBox(height: 6),
                  PasswordField(
                    controller: _confirmCtrl,
                    hintText: '• • • • • • • •',
                    validator: (v) => v != _passCtrl.text ? 'Mật khẩu không khớp' : null,
                  ),
                  const SizedBox(height: 18),

                  // Terms checkbox
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 22, height: 22,
                        child: Checkbox(
                          value: _agreed,
                          onChanged: (v) => setState(() => _agreed = v ?? false),
                          activeColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          side: const BorderSide(color: AppColors.border, width: 1.5),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textSecondary, height: 1.5),
                            children: [
                              const TextSpan(text: 'Tôi đồng ý với '),
                              TextSpan(text: 'Điều khoản & Điều kiện', style: GoogleFonts.dmSans(
                                fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600)),
                              const TextSpan(text: ' và '),
                              TextSpan(text: 'Chính sách Bảo mật', style: GoogleFonts.dmSans(
                                fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600)),
                              const TextSpan(text: ' của Glow Aura.'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  GlowButton(label: 'Đăng ký ngay', isLoading: state.isLoading, onPressed: _onRegister),
                  const SizedBox(height: 20),

                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Bạn đã có tài khoản? ', style: GoogleFonts.dmSans(
                          fontSize: 14, color: AppColors.textSecondary)),
                        GestureDetector(
                          onTap: () => context.go('/login'),
                          child: Text('Đăng nhập', style: GoogleFonts.dmSans(
                            fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  const DividerWithText(text: 'HOẶC ĐĂNG KÝ BẰNG'),
                  const SizedBox(height: 16),

                  Row(children: [
                    Expanded(child: SocialAuthButton(label: 'Google', logoText: 'G',
                      logoColor: const Color(0xFFEA4335), onPressed: () {})),
                    const SizedBox(width: 12),
                    Expanded(child: SocialAuthButton(label: 'Facebook', logoText: 'f',
                      logoColor: const Color(0xFF1877F2), onPressed: () {})),
                  ]),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }

  class _FieldLabel extends StatelessWidget {
    final String text;
    const _FieldLabel(this.text);
    @override
    Widget build(BuildContext context) => Text(text, style: GoogleFonts.dmSans(
      fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary));
  }