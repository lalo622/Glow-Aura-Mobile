import 'package:flutter/material.dart';
import 'package:glow_aura/core/theme/app_theme.dart';

class GlowButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;

  const GlowButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
  });

  @override
  State<GlowButton> createState() => _GlowButtonState();
}

class _GlowButtonState extends State<GlowButton> {
  bool _pressed = false;

  bool get _enabled =>
      !widget.isDisabled && !widget.isLoading && widget.onPressed != null;

  void _setPressed(bool v) {
    if (!_enabled) return;
    setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final disableAnim = MediaQuery.of(context).disableAnimations;

    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: _enabled ? widget.onPressed : null,
      child: AnimatedScale(
        scale: disableAnim ? 1.0 : (_pressed ? 0.96 : 1.0),
        duration: Duration(milliseconds: _pressed ? 100 : 150),
        curve: Curves.easeOut,
        child: AnimatedOpacity(
          opacity: disableAnim
              ? 1.0
              : (_enabled ? (_pressed ? 0.88 : 1.0) : 0.5),
          duration: Duration(milliseconds: _pressed ? 100 : 150),
          curve: Curves.easeOut,
          child: Container(
            width: double.infinity,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(30),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: widget.isLoading
                  ? const SizedBox(
                      key: ValueKey('loading'),
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Text(
                      widget.label,
                      key: const ValueKey('label'),
                      style: AppTextStyles.title(color: Colors.white),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}