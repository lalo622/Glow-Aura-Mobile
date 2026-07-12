import 'package:flutter/material.dart';
import 'package:glow_aura/core/theme/app_theme.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const CategoryChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final disableAnim = MediaQuery.of(context).disableAnimations;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: disableAnim
            ? Duration.zero
            : const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: AppColors.s16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primarySubtle : AppColors.surface,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.2 : 1,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.body(
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
          ).copyWith(fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400),
        ),
      ),
    );
  }
}