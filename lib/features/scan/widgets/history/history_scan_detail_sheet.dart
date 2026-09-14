import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:glow_aura/core/theme/app_theme.dart';
import 'package:glow_aura/features/scan/data/models/skin_analysis_history.dart';

class HistoryScanDetailSheet extends StatelessWidget {
  final SkinAnalysisHistoryItem item;

  const HistoryScanDetailSheet({
    super.key,
    required this.item,
  });

  Color _severityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'mild':
        return const Color(0xFF4CAF50);
      case 'moderate':
        return const Color(0xFFFF9800);
      case 'severe':
        return const Color(0xFFF44336);
      default:
        return AppColors.primary;
    }
  }

  String _severityLabel(String severity) {
    switch (severity.toLowerCase()) {
      case 'mild':
        return 'Nhẹ';
      case 'moderate':
        return 'Trung bình';
      case 'severe':
        return 'Nặng';
      default:
        return severity.isEmpty ? 'Không xác định' : severity;
    }
  }

  String _skinTypeLabel(String skinType) {
    switch (skinType.toLowerCase()) {
      case 'oily':
        return 'Da dầu';
      case 'dry':
        return 'Da khô';
      case 'combination':
        return 'Da hỗn hợp';
      case 'normal':
        return 'Da thường';
      case 'sensitive':
        return 'Da nhạy cảm';
      default:
        return skinType.isEmpty ? 'Không xác định' : skinType;
    }
  }

  @override
  Widget build(BuildContext context) {
    final severityColor = _severityColor(item.severity);

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(22),
            ),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Nội dung
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(
                    AppColors.s16,
                    AppColors.s8,
                    AppColors.s16,
                    32,
                  ),
                  children: [
                    // ── Header ──────────────────────────────────────
                    Text(
                      'Chi tiết lần quét',
                      style: AppTextStyles.heading(),
                    ),

                    const SizedBox(height: 6),

                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 15,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 7),
                        Text(
                          DateFormat('dd/MM/yyyy • HH:mm')
                              .format(item.capturedAt.toLocal()),
                          style: AppTextStyles.caption(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppColors.s16),

                    // ── Metrics ─────────────────────────────────────
                    Row(
                      children: [
                        _MetricCard(
                          label: 'Glow Score',
                          value: '${item.overallScore}',
                          icon: Icons.auto_awesome,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: AppColors.s8),
                        _MetricCard(
                          label: 'Số mụn',
                          value: '${item.acneCount}',
                          icon: Icons.bubble_chart_outlined,
                          color: severityColor,
                        ),
                        const SizedBox(width: AppColors.s8),
                        _MetricCard(
                          label: 'Mức độ',
                          value: _severityLabel(item.severity),
                          icon: Icons.warning_amber_rounded,
                          color: severityColor,
                        ),
                      ],
                    ),

                    const SizedBox(height: AppColors.s16),

                    // ── Loại da ─────────────────────────────────────
                    _InfoCard(
                      title: 'Loại da',
                      icon: Icons.face_retouching_natural,
                      child: Text(
                        _skinTypeLabel(item.detectedSkinType),
                        style: AppTextStyles.body().copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    // ── Lời khuyên ──────────────────────────────────
                    if (item.adviceText.trim().isNotEmpty) ...[
                      const SizedBox(height: AppColors.s16),
                      _InfoCard(
                        title: 'Lời khuyên',
                        icon: Icons.lightbulb_outline_rounded,
                        child: Text(
                          item.adviceText,
                          style: AppTextStyles.body().copyWith(
                            height: 1.6,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: AppColors.s16),

                    // ── Session ─────────────────────────────────────
                    Text(
                      'Mã phiên: ${item.sessionId}',
                      style: AppTextStyles.caption(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Metric Card
// ─────────────────────────────────────────────────────────────────────────────

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        constraints: const BoxConstraints(
          minHeight: 92,
        ),
        padding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 6,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: color,
            ),
            const SizedBox(height: 6),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppTextStyles.title(color: color),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppTextStyles.label(),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Info Card
// ─────────────────────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _InfoCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 7),
              Text(
                title,
                style: AppTextStyles.heading(),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}