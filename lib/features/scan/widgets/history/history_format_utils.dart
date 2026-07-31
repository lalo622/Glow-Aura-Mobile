import 'package:flutter/material.dart';
import 'package:glow_aura/core/theme/app_theme.dart';

bool isToday(DateTime d) {
  final now = DateTime.now();
  return d.year == now.year && d.month == now.month && d.day == now.day;
}

String formatTime(DateTime d) {
  final hour = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final period = d.hour >= 12 ? 'PM' : 'AM';
  final minute = d.minute.toString().padLeft(2, '0');
  return '$hour:$minute $period';
}

String severityLabel(String severity) {
  switch (severity.toLowerCase()) {
    case 'mild':
      return 'Nhẹ';
    case 'moderate':
      return 'Trung bình';
    case 'severe':
      return 'Nặng';
    case 'clear':
      return 'Sạch mụn';
    default:
      return severity;
  }
}

Color severityColor(String severity) {
  switch (severity.toLowerCase()) {
    case 'mild':
      return AppColors.success;
    case 'moderate':
      return const Color(0xFFD4A24C);
    case 'severe':
      return AppColors.error;
    case 'clear':
      return AppColors.primary;
    default:
      return AppColors.textTertiary;
  }
}

class HistoryGroupLabel extends StatelessWidget {
  final String text;
  const HistoryGroupLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: AppTextStyles.label(color: AppColors.textSecondary));
  }
}