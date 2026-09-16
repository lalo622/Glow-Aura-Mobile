import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:glow_aura/core/theme/app_theme.dart';
import 'package:glow_aura/features/auth/auth_viewmodel.dart';
import 'package:glow_aura/shared/widgets/shared_widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:glow_aura/features/scan/providers/skin_history_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void dispose() { _emailCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref.read(authViewModelProvider.notifier)
        .login(email: _emailCtrl.text.trim(), password: _passCtrl.text);
    if (ok && mounted) {
      ref.invalidate(historyPagingProvider);
      context.go('/home');
    }
  }
  Future<void> _onLoginWithGoogle() async {
  final ok = await ref.read(authViewModelProvider.notifier).loginWithGoogle();
  if (ok && mounted) {
    ref.invalidate(historyPagingProvider);
    context.go('/home');
  }
}

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                Text('Glow Aura', style: GoogleFonts.cormorantGaramond(
                  fontSize: 18, fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary, letterSpacing: 2)),
                const SizedBox(height: 12),
                Text('Chào mừng bạn', style: Theme.of(context).textTheme.displayMedium, textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text('Đăng nhập để khám phá vẻ đẹp rạng rỡ',
                  style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
                const SizedBox(height: 40),

                if (state.errorMessage != null) ...[
                  _ErrorBanner(state.errorMessage!),
                  const SizedBox(height: 16),
                ],

                const _Label('Email'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => (v == null || v.isEmpty) ? 'Vui lòng nhập email' : null,
                  decoration: const InputDecoration(hintText: 'Nhập email của bạn'),
                ),
                const SizedBox(height: 16),

                const _Label('Mật khẩu'),
                const SizedBox(height: 6),
                PasswordField(
                  controller: _passCtrl,
                  validator: (v) => (v == null || v.length < 6) ? 'Tối thiểu 6 ký tự' : null,
                ),
                const SizedBox(height: 8),

                GlowButton(label: 'Đăng nhập', isLoading: state.isLoading, onPressed: _onLogin),
                const SizedBox(height: 24),

                const DividerWithText(text: 'Hoặc đăng nhập với'),
                const SizedBox(height: 16),

                Row(children: [
                  Expanded(child: SocialAuthButton(label: 'Google', logoText: 'G',
                    logoColor: const Color(0xFFEA4335),
                    onPressed: _onLoginWithGoogle,
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: SocialAuthButton(label: 'Facebook', logoText: 'f',
                    logoColor: const Color(0xFF1877F2),
                    onPressed: () => ref.read(authViewModelProvider.notifier).loginWithFacebook())),
                ]),
                const SizedBox(height: 28),

                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('Bạn chưa có tài khoản? ', style: GoogleFonts.dmSans(
                    fontSize: 14, color: AppColors.textSecondary)),
                  GestureDetector(
                    onTap: () => context.go('/register'),
                    child: Text('Đăng ký ngay', style: GoogleFonts.dmSans(
                      fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary)),
                  ),
                ]),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: Text(text, style: GoogleFonts.dmSans(
      fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
  );
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner(this.message);
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: AppColors.error.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
    ),
    child: Text(message, style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.error)),
  );
}