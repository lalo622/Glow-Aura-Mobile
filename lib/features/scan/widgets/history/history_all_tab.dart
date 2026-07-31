import 'package:flutter/material.dart';
import 'package:glow_aura/core/theme/app_theme.dart';
import 'package:glow_aura/features/scan/data/models/skin_analysis_history.dart';
import 'history_format_utils.dart';
import 'history_scan_card.dart';
import 'history_stat_card.dart';
import 'score_trend_chart.dart';

class HistoryAllTab extends StatelessWidget {
  final List<SkinAnalysisHistoryItem> items;
  final Map<String, int> deltaMap;
  final Future<void> Function() onRefresh;

  const HistoryAllTab({
    super.key,
    required this.items,
    required this.deltaMap,
    required this.onRefresh,
  });

  Map<String, List<SkinAnalysisHistoryItem>> _groupByDate() {
    final map = <String, List<SkinAnalysisHistoryItem>>{};
    for (final item in items) {
      final key = isToday(item.capturedAt)
          ? 'HÔM NAY'
          : 'THÁNG ${item.capturedAt.month}, ${item.capturedAt.year}';
      map.putIfAbsent(key, () => []).add(item);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final groups = _groupByDate();
    final avgScore = items.isEmpty
        ? 0
        : (items.map((e) => e.overallScore).reduce((a, b) => a + b) /
                items.length)
            .round();
    final lastScan = items.first.capturedAt;
    final lastScanLabel = isToday(lastScan)
        ? 'Hôm nay'
        : '${lastScan.day}/${lastScan.month}/${lastScan.year}';

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppColors.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppColors.s16),

            // ── Stats summary ─────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: HistoryStatCard(
                    label: 'ĐIỂM TRUNG BÌNH',
                    value: '$avgScore',
                    trailing: const SizedBox.shrink(),
                  ),
                ),
                const SizedBox(width: AppColors.s12),
                Expanded(
                  child: HistoryStatCard(
                    label: 'LẦN QUÉT CUỐI',
                    value: lastScanLabel,
                    trailing: const Icon(Icons.check_circle,
                        size: 16, color: AppColors.success),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppColors.s24),

            // ── Chart xu hướng ─────────────────────────────────────────────
            ScoreTrendChart(items: items),
            const SizedBox(height: AppColors.s24),

            for (final entry in groups.entries) ...[
              HistoryGroupLabel(entry.key),
              const SizedBox(height: AppColors.s8),
              ...entry.value.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: AppColors.s8),
                    child: HistoryScanCard(
                      item: item,
                      delta: deltaMap[item.sessionId] ?? 0,
                    ),
                  )),
              const SizedBox(height: AppColors.s16),
            ],
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}