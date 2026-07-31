import 'package:flutter/material.dart';
import 'package:glow_aura/core/theme/app_theme.dart';
import 'package:glow_aura/features/scan/data/models/skin_analysis_history.dart';
import 'history_format_utils.dart';

class HistoryScanCard extends StatelessWidget {
  final SkinAnalysisHistoryItem item;
  final int delta;

  const HistoryScanCard({super.key, required this.item, required this.delta});

  @override
  Widget build(BuildContext context) {
    final deltaPositive = delta >= 0;
    final hasImage = item.fullImageUrl.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(AppColors.s12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Ảnh preview ─────────────────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 88,
              height: 88,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  hasImage
                      ? Image.network(
                          item.fullImageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _fallbackImagePlaceholder(),
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return Container(
                              color:
                                  AppColors.primaryTint.withValues(alpha: 0.15),
                              child: const Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2),
                                ),
                              ),
                            );
                          },
                        )
                      : _fallbackImagePlaceholder(),
                  // Badge severity ở góc dưới
                  Positioned(
                    left: 6,
                    bottom: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: severityColor(item.severity),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        severityLabel(item.severity),
                        style: AppTextStyles.caption(color: Colors.white)
                            .copyWith(fontSize: 10, height: 1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppColors.s12),

          // ── Nội dung ─────────────────────────────────────────────────
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
                    Text('${item.overallScore}',
                        style: AppTextStyles.heading(
                            color: AppColors.textPrimary)),
                    const SizedBox(width: AppColors.s8),
                    if (delta != 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
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
                            Text('${delta.abs()}',
                                style: AppTextStyles.caption(
                                  color: deltaPositive
                                      ? AppColors.success
                                      : AppColors.error,
                                )),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallbackImagePlaceholder() {
    return Container(
      color: AppColors.primaryTint.withValues(alpha: 0.15),
      child: const Center(
        child: Icon(Icons.face_retouching_natural,
            size: 32, color: AppColors.primary),
      ),
    );
  }
}