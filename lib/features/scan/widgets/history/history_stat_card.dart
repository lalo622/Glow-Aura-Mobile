import 'package:flutter/material.dart';
import 'package:glow_aura/core/theme/app_theme.dart';

class HistoryStatCard extends StatelessWidget {
  final String label;
  final String value;
  final Widget trailing;

  const HistoryStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppColors.s12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.label()),
          const SizedBox(height: AppColors.s4),
          Row(
            children: [
              Text(value,
                  style: AppTextStyles.display(color: AppColors.primary)),
              const SizedBox(width: AppColors.s8),
              trailing,
            ],
          ),
        ],
      ),
    );
  }
}