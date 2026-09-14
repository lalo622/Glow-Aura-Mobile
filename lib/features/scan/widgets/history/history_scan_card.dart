import 'package:flutter/material.dart';
import 'package:glow_aura/core/theme/app_theme.dart';
import 'package:glow_aura/features/scan/data/models/skin_analysis_history.dart';
import 'history_format_utils.dart';

class HistoryScanCard extends StatelessWidget {
  final SkinAnalysisHistoryItem item;
  final int delta;
  final VoidCallback? onTap;

  const HistoryScanCard({
    super.key,
    required this.item,
    required this.delta,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final deltaPositive = delta >= 0;
    final imageUrl = item.fullImageUrl;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(AppColors.s12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            // ── Ảnh preview ───────────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 64,
                height: 64,
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;

                          return _buildImagePlaceholder();
                        },
                        errorBuilder: (_, __, ___) {
                          return _buildImagePlaceholder();
                        },
                      )
                    : _buildImagePlaceholder(),
              ),
            ),

            const SizedBox(width: AppColors.s12),

            // ── Thông tin lần quét ────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.detectedSkinType.isNotEmpty
                        ? item.detectedSkinType
                        : 'Kết quả quét da',
                    style: AppTextStyles.title(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: AppColors.s4),

                  Text(
                    '${formatTime(item.capturedAt)} • ${item.acneCount} nốt mụn',
                    style: AppTextStyles.caption(),
                  ),

                  const SizedBox(height: AppColors.s8),

                  Row(
                    children: [
                      Text(
                        '${item.overallScore}',
                        style: AppTextStyles.heading(
                          color: AppColors.textPrimary,
                        ),
                      ),

                      const SizedBox(width: AppColors.s8),

                      if (delta != 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: (deltaPositive
                                    ? AppColors.success
                                    : AppColors.error)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                deltaPositive
                                    ? Icons.arrow_upward
                                    : Icons.arrow_downward,
                                size: 10,
                                color: deltaPositive
                                    ? AppColors.success
                                    : AppColors.error,
                              ),
                              Text(
                                '${delta.abs()}',
                                style: AppTextStyles.caption(
                                  color: deltaPositive
                                      ? AppColors.success
                                      : AppColors.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: AppColors.s8),

            // ── Mức độ + mũi tên ──────────────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: severityColor(item.severity),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    severityLabel(item.severity),
                    style: AppTextStyles.caption(
                      color: Colors.white,
                    ).copyWith(
                      fontSize: 10,
                      height: 1,
                    ),
                  ),
                ),

                const SizedBox(height: AppColors.s8),

                const Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: AppColors.textTertiary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: AppColors.primaryTint.withValues(alpha: 0.15),
      child: const Center(
        child: Icon(
          Icons.face_retouching_natural,
          size: 28,
          color: AppColors.primary,
        ),
      ),
    );
  }
}