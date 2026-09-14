import 'package:flutter/material.dart';
import 'package:glow_aura/core/theme/app_theme.dart';
import 'package:glow_aura/features/scan/data/models/skin_analysis_history.dart';
import 'history_format_utils.dart';
import 'history_scan_card.dart';
import 'history_stat_card.dart';
import 'score_trend_chart.dart';
import 'history_scan_detail_sheet.dart';

class HistoryAllTab extends StatefulWidget {
  final List<SkinAnalysisHistoryItem> items;
  final Map<String, int> deltaMap;
  final Future<void> Function() onRefresh;
  final bool hasMore;
  final bool isLoadingMore;
  final VoidCallback onLoadMore;

  const HistoryAllTab({
    super.key,
    required this.items,
    required this.deltaMap,
    required this.onRefresh,
    this.hasMore = false,
    this.isLoadingMore = false,
    required this.onLoadMore,
  });

  @override
  State<HistoryAllTab> createState() => _HistoryAllTabState();
}

class _HistoryAllTabState extends State<HistoryAllTab> {
  final _scrollController = ScrollController();

  static const _loadMoreTriggerOffset = 300.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!widget.hasMore || widget.isLoadingMore) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - _loadMoreTriggerOffset) {
      widget.onLoadMore();
    }
  }

  Map<String, List<SkinAnalysisHistoryItem>> _groupByDate() {
    final map = <String, List<SkinAnalysisHistoryItem>>{};
    for (final item in widget.items) {
      final key = isToday(item.capturedAt)
          ? 'HÔM NAY'
          : 'THÁNG ${item.capturedAt.month}, ${item.capturedAt.year}';
      map.putIfAbsent(key, () => []).add(item);
    }
    return map;
  }
    void _showDetail(
    BuildContext context,
    SkinAnalysisHistoryItem item,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => HistoryScanDetailSheet(item: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.items;

    if (items.isEmpty) {
      return RefreshIndicator(
        onRefresh: widget.onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 120),
            Center(
              child: Text(
                'Chưa có lịch sử quét da nào',
                style: TextStyle(color: Colors.white60),
              ),
            ),
          ],
        ),
      );
    }

    final groups = _groupByDate();
    final avgScore =
        (items.map((e) => e.overallScore).reduce((a, b) => a + b) /
                items.length)
            .round();
    final lastScan = items.first.capturedAt;
    final lastScanLabel = isToday(lastScan)
        ? 'Hôm nay'
        : '${lastScan.day}/${lastScan.month}/${lastScan.year}';

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppColors.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppColors.s16),
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
                      delta: widget.deltaMap[item.sessionId] ?? 0,
                        onTap: () => _showDetail(context, item),
                    ),
                  )),
              const SizedBox(height: AppColors.s16),
            ],

            // ── [MỚI] Loading indicator cuối list khi đang tải thêm trang ──
            if (widget.isLoadingMore)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppColors.s16),
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}