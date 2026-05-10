import 'package:flutter/material.dart';
import 'package:glow_aura/core/theme/app_theme.dart';

// ── Primary Button ────────────────────────────────────────────────────────────
class GlowButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const GlowButton({
    super.key, required this.label,
    this.onPressed, this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(width: 22, height: 22,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5))
            : Text(label),
      ),
    );
  }
}

// ── Social Auth Button ────────────────────────────────────────────────────────
class SocialAuthButton extends StatelessWidget {
  final String label;
  final String logoText;
  final Color logoColor;
  final VoidCallback? onPressed;

  const SocialAuthButton({
    super.key, required this.label,
    required this.logoText, required this.logoColor, this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: OutlinedButton(
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(logoText,
                style: AppTextStyles.title(color: logoColor)),
            const SizedBox(width: AppColors.s8),
            Text(label, style: AppTextStyles.body(color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}

// ── Divider with text ─────────────────────────────────────────────────────────
class DividerWithText extends StatelessWidget {
  final String text;
  const DividerWithText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppColors.s12),
          child: Text(text, style: AppTextStyles.caption()),
        ),
        const Expanded(child: Divider(color: AppColors.border)),
      ],
    );
  }
}

// ── Password Field ────────────────────────────────────────────────────────────
class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final String? Function(String?)? validator;

  const PasswordField({
    super.key, required this.controller,
    this.hintText = 'Nhập mật khẩu', this.validator,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscure,
      validator: widget.validator,
      decoration: InputDecoration(
        hintText: widget.hintText,
        suffixIcon: GestureDetector(
          onTap: () => setState(() => _obscure = !_obscure),
          child: Icon(
            _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: AppColors.textTertiary, size: 20,
          ),
        ),
      ),
    );
  }
}

// ── Step Indicator ────────────────────────────────────────────────────────────
class StepIndicator extends StatelessWidget {
  final int step, total;
  final String label;

  const StepIndicator({
    super.key,
    required this.step,
    required this.total,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyles.body(color: AppColors.textSecondary)),
            Text('$step/$total',
                style: AppTextStyles.label(color: AppColors.primary)),
          ],
        ),
        const SizedBox(height: AppColors.s8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: step / total,
            minHeight: 4,
            backgroundColor: AppColors.primaryTint,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ],
    );
  }
}

// ── Bottom CTA ────────────────────────────────────────────────────────────────
class BottomCta extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool showArrow;
  final String? footnote;

  const BottomCta({
    super.key,
    required this.label,
    required this.onPressed,
    this.showArrow = false,
    this.footnote,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
          AppColors.s16, AppColors.s12, AppColors.s16, AppColors.s24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity, height: 52,
            child: ElevatedButton(
              onPressed: onPressed,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(label),
                  if (showArrow) ...[
                    const SizedBox(width: AppColors.s8),
                    const Icon(Icons.arrow_forward,
                        size: 18, color: Colors.white),
                  ],
                ],
              ),
            ),
          ),
          if (footnote != null) ...[
            const SizedBox(height: AppColors.s12),
            Text(footnote!,
                style: AppTextStyles.caption(),
                textAlign: TextAlign.center),
          ],
        ],
      ),
    );
  }
}