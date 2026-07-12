import 'package:flutter/material.dart';
import 'package:glow_aura/core/theme/app_theme.dart';

class ProfileStatsRow extends StatelessWidget {
  final String skinType;
  final String age;
  const ProfileStatsRow({super.key, required this.skinType, required this.age});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          vertical: AppColors.s12, horizontal: AppColors.s8),
      decoration: BoxDecoration(
        color: AppColors.primarySubtle,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryTint),
      ),
      child: Row(
        children: [
          _StatItem(label: 'LOẠI DA', value: skinType),
          _StatDivider(),
          _StatItem(label: 'ĐỘ TUỔI', value: age),
          _StatDivider(),
          const _StatItem(label: 'ĐIỂM GLOW', value: '---'),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label, value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: AppTextStyles.label()),
          const SizedBox(height: AppColors.s4),
          Text(value,
              style: AppTextStyles.title(color: AppColors.primary),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 32, color: AppColors.primaryTint);
  }
}