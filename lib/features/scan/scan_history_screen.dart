import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:glow_aura/core/theme/app_theme.dart';
import 'package:glow_aura/shared/widgets/main_scaffold.dart';
import 'package:glow_aura/features/scan/data/models/skin_analysis_history.dart';
import 'package:glow_aura/features/scan/providers/skin_history_provider.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(skinAnalysisHistoryProvider);

    return MainScaffold(
      currentIndex: 1,
      body: SafeArea(
        child: Column(
          children: [
            // ── App bar ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppColors.s16, vertical: AppColors.s12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.go('/home'),
                    icon: const Icon(Icons.arrow_back,
                        color: AppColors.textPrimary),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: AppColors.s12),
                  Expanded(
                    child: Text('Lịch sử quét',
                        style: AppTextStyles.title(),
                        textAlign: TextAlign.center),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.calendar_month_outlined,
                        color: AppColors.textSecondary),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            Container(height: 1, color: AppColors.border),

            // ── Tab bar ───────────────────────────────────────────────────
            TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textTertiary,
              labelStyle: AppTextStyles.body(color: AppColors.primary)
                  .copyWith(fontWeight: FontWeight.w600),
              unselectedLabelStyle: AppTextStyles.body(),
              indicatorColor: AppColors.primary,
              indicatorWeight: 2,
              tabs: const [
                Tab(text: 'Tất cả'),
                Tab(text: 'Hàng tuần'),
                Tab(text: 'Hàng tháng'),
              ],
            ),

            // ── Tab content ───────────────────────────────────────────────
            Expanded(
              child: historyAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (err, _) => _ErrorState(
                  message: 'Không thể tải lịch sử quét',
                  onRetry: () => ref.invalidate(skinAnalysisHistoryProvider),
                ),
                data: (response) {
                  final items = [...response.items]
                    ..sort((a, b) => b.capturedAt.compareTo(a.capturedAt));

                  if (items.isEmpty) {
                    return _EmptyTab(
                      message: 'Chưa có dữ liệu quét nào',
                      onRefresh: () =>
                          ref.refresh(skinAnalysisHistoryProvider.future),
                    );
                  }

                  // Delta = chênh lệch điểm so với lần quét liền trước
                  final deltaMap = <String, int>{};
                  for (var i = 0; i < items.length; i++) {
                    final delta = (i + 1 < items.length)
                        ? items[i].overallScore - items[i + 1].overallScore
                        : 0;
                    deltaMap[items[i].sessionId] = delta;
                  }

                  final now = DateTime.now();
                  final weekAgo = now.subtract(const Duration(days: 7));
                  final weeklyItems = items
                      .where((i) => i.capturedAt.isAfter(weekAgo))
                      .toList();
                  final monthlyItems = items
                      .where((i) =>
                          i.capturedAt.year == now.year &&
                          i.capturedAt.month == now.month)
                      .toList();

                  Future<void> onRefresh() =>
                      ref.refresh(skinAnalysisHistoryProvider.future);

                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _AllTab(
                        items: items,
                        deltaMap: deltaMap,
                        onRefresh: onRefresh,
                      ),
                      weeklyItems.isEmpty
                          ? _EmptyTab(
                              message: 'Chưa có dữ liệu hàng tuần',
                              onRefresh: onRefresh)
                          : _AllTab(
                              items: weeklyItems,
                              deltaMap: deltaMap,
                              onRefresh: onRefresh),
                      monthlyItems.isEmpty
                          ? _EmptyTab(
                              message: 'Chưa có dữ liệu hàng tháng',
                              onRefresh: onRefresh)
                          : _AllTab(
                              items: monthlyItems,
                              deltaMap: deltaMap,
                              onRefresh: onRefresh),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── All tab ───────────────────────────────────────────────────────────────────
class _AllTab extends StatelessWidget {
  final List<SkinAnalysisHistoryItem> items;
  final Map<String, int> deltaMap;
  final Future<void> Function() onRefresh;

  const _AllTab({
    required this.items,
    required this.deltaMap,
    required this.onRefresh,
  });

  Map<String, List<SkinAnalysisHistoryItem>> _groupByDate() {
    final map = <String, List<SkinAnalysisHistoryItem>>{};
    for (final item in items) {
      final key = _isToday(item.capturedAt)
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
    final lastScanLabel = _isToday(lastScan)
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
                  child: _StatCard(
                    label: 'ĐIỂM TRUNG BÌNH',
                    value: '$avgScore',
                    trailing: const SizedBox.shrink(),
                  ),
                ),
                const SizedBox(width: AppColors.s12),
                Expanded(
                  child: _StatCard(
                    label: 'LẦN QUÉT CUỐI',
                    value: lastScanLabel,
                    trailing: const Icon(Icons.check_circle,
                        size: 16, color: AppColors.success),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppColors.s24),

            for (final entry in groups.entries) ...[
              _GroupLabel(entry.key),
              const SizedBox(height: AppColors.s8),
              ...entry.value.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: AppColors.s8),
                    child: _ScanCard(
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

bool _isToday(DateTime d) {
  final now = DateTime.now();
  return d.year == now.year && d.month == now.month && d.day == now.day;
}

String _formatTime(DateTime d) {
  final hour = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final period = d.hour >= 12 ? 'PM' : 'AM';
  final minute = d.minute.toString().padLeft(2, '0');
  return '$hour:$minute $period';
}

String _severityLabel(String severity) {
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

Color _severityColor(String severity) {
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

// ── Empty tab ─────────────────────────────────────────────────────────────────
class _EmptyTab extends StatelessWidget {
  final String message;
  final Future<void> Function()? onRefresh;
  const _EmptyTab({required this.message, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final content = Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.history, size: 48, color: AppColors.primaryTint),
          const SizedBox(height: AppColors.s12),
          Text(message,
              style: AppTextStyles.body(color: AppColors.textTertiary)),
        ],
      ),
    );

    if (onRefresh == null) return content;

    return RefreshIndicator(
      onRefresh: onRefresh!,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: content,
          ),
        ],
      ),
    );
  }
}

// ── Error state ───────────────────────────────────────────────────────────────
class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: AppColors.s12),
          Text(message,
              style: AppTextStyles.body(color: AppColors.textTertiary)),
          const SizedBox(height: AppColors.s12),
          TextButton(
            onPressed: onRetry,
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }
}

// ── Stat card ─────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label, value;
  final Widget trailing;

  const _StatCard({
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

// ── Group label ───────────────────────────────────────────────────────────────
class _GroupLabel extends StatelessWidget {
  final String text;
  const _GroupLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: AppTextStyles.label(color: AppColors.textSecondary));
  }
}

// ── Scan card (with larger image preview) ──────────────────────────────────────
class _ScanCard extends StatelessWidget {
  final SkinAnalysisHistoryItem item;
  final int delta;

  const _ScanCard({required this.item, required this.delta});

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
          // ── Ảnh preview lớn ─────────────────────────────────────────
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
                              color: AppColors.primaryTint.withValues(alpha:0.15),
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
                        color: _severityColor(item.severity),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _severityLabel(item.severity),
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
                  '${_formatTime(item.capturedAt)} • ${item.acneCount} nốt mụn',
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
                              .withValues(alpha:0.1),
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
      color: AppColors.primaryTint.withValues(alpha:0.15),
      child: const Center(
        child: Icon(Icons.face_retouching_natural,
            size: 32, color: AppColors.primary),
      ),
    );
  }
}