import 'package:flutter/material.dart';
import 'package:glow_aura/core/theme/app_theme.dart';

/// A horizontally-scrollable insight card — replaces the flat
/// icon+title+time list row. Each card is its own "moment" with a tinted
/// background matched to its semantic status (success/warning/neutral).
class InsightCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String time;
  final String status;
  final Color statusColor;

  const InsightCard({
    super.key,
    required this.icon,
    required this.title,
    required this.time,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 168,
      padding: const EdgeInsets.all(AppColors.s16),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: statusColor.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: statusColor),
          ),
          const SizedBox(height: AppColors.s12),
          Text(title,
              style: AppTextStyles.title(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(time, style: AppTextStyles.caption()),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(status,
                style: AppTextStyles.caption(color: statusColor)
                    .copyWith(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}