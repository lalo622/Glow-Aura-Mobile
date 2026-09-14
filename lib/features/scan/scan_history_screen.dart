import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:glow_aura/core/theme/app_theme.dart';
import 'package:glow_aura/shared/widgets/main_scaffold.dart';
import 'package:glow_aura/features/scan/providers/skin_history_provider.dart';
import 'package:glow_aura/features/scan/widgets/history/history_all_tab.dart';
import 'package:glow_aura/features/scan/widgets/history/history_empty_state.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Tháng được chọn để xem
  DateTime _selectedMonth =
      DateTime(DateTime.now().year, DateTime.now().month);
  // Tuần được chọn để xem
  int _selectedWeekIndex = 0;
  int _loadGeneration = 0;
  bool _isLoadingRangeData = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
      WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!mounted) return;

    final state = ref.read(historyPagingProvider);

    if (!state.isLoading) {
      ref.read(historyPagingProvider.notifier).refresh();
    }

    _ensureMonthLoaded(_selectedMonth);
  });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loadGeneration++;
    super.dispose();
  }

  // ── Helpers ─────────────────────────────────────────────────────────────

  List<DateTimeRange> _weeksInMonth(DateTime month) {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final weeks = <DateTimeRange>[];
    for (int start = 1; start <= daysInMonth; start += 7) {
      final end = (start + 6) > daysInMonth ? daysInMonth : start + 6;
      weeks.add(DateTimeRange(
        start: DateTime(month.year, month.month, start),
        end: DateTime(month.year, month.month, end, 23, 59, 59),
      ));
    }
    return weeks;
  }

  DateTimeRange _monthRange(DateTime month) {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    return DateTimeRange(
      start: DateTime(month.year, month.month, 1),
      end: DateTime(month.year, month.month, daysInMonth, 23, 59, 59),
    );
  }

  void _changeMonth(int delta) {
    setState(() {
      _selectedMonth =
          DateTime(_selectedMonth.year, _selectedMonth.month + delta);
      _selectedWeekIndex = 0;
    });
    _ensureMonthLoaded(_selectedMonth);
  }

  Future<void> _ensureMonthLoaded(DateTime month) async {
    final myGeneration = ++_loadGeneration;
    final range = _monthRange(month);
    final notifier = ref.read(historyPagingProvider.notifier);

    if (mounted) setState(() => _isLoadingRangeData = true);

    try {
      while (mounted && myGeneration == _loadGeneration) {
        final state = ref.read(historyPagingProvider);

        if (state.isLoading || state.isLoadingMore) {
          await Future.delayed(const Duration(milliseconds: 100));
          continue;
        }

        if (state.items.isEmpty) {
          if (!state.hasMore) break; // thực sự không có dữ liệu nào cả
          await notifier.loadMore();
          continue;
        }

        final oldestLoaded = state.items
            .map((e) => e.capturedAt)
            .reduce((a, b) => a.isBefore(b) ? a : b);

        if (oldestLoaded.isBefore(range.start)) break; // đã phủ đủ tháng
        if (!state.hasMore) break; // hết trang, dữ liệu chỉ có bấy nhiêu

        await notifier.loadMore();
      }
    } finally {
      if (mounted && myGeneration == _loadGeneration) {
        setState(() => _isLoadingRangeData = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pagingState = ref.watch(historyPagingProvider);
    final notifier = ref.read(historyPagingProvider.notifier);
    ref.listen<HistoryPagingState>(historyPagingProvider, (previous, next) {
      if (next.error != null &&
          next.error != previous?.error &&
          next.items.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Không tải được thêm dữ liệu, thử lại sau.')),
        );
      }
    });

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
              child: _buildContent(pagingState, notifier),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
      HistoryPagingState pagingState, HistoryPagingNotifier notifier) {
    if (pagingState.items.isEmpty && pagingState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final error = pagingState.error;
    if (pagingState.items.isEmpty && error != null) {
      return HistoryErrorState(
        error: error,
        onRetry: notifier.refresh,
      );
    }

    if (pagingState.items.isEmpty) {
      return HistoryEmptyState(
        message: 'Chưa có dữ liệu quét nào',
        onRefresh: notifier.refresh,
      );
    }

    final items = [...pagingState.items]
      ..sort((a, b) => b.capturedAt.compareTo(a.capturedAt));

    // Delta = chênh lệch điểm so với lần quét liền trước.
    final deltaMap = <String, int>{};
    for (var i = 0; i < items.length; i++) {
      final delta = (i + 1 < items.length)
          ? items[i].overallScore - items[i + 1].overallScore
          : 0;
      deltaMap[items[i].sessionId] = delta;
    }

    final monthRange = _monthRange(_selectedMonth);
    final monthlyItems = items
        .where((i) =>
            !i.capturedAt.isBefore(monthRange.start) &&
            !i.capturedAt.isAfter(monthRange.end))
        .toList();

    final weeksInSelectedMonth = _weeksInMonth(_selectedMonth);
    final safeWeekIndex =
        _selectedWeekIndex.clamp(0, weeksInSelectedMonth.length - 1);
    final selectedWeekRange = weeksInSelectedMonth[safeWeekIndex];
    final weeklyItems = items
        .where((i) =>
            !i.capturedAt.isBefore(selectedWeekRange.start) &&
            !i.capturedAt.isAfter(selectedWeekRange.end))
        .toList();

    return TabBarView(
      controller: _tabController,
      children: [
        // ── Tab Tất cả — infinite scroll tự nhiên qua toàn bộ lịch sử ────
        HistoryAllTab(
          items: items,
          deltaMap: deltaMap,
          onRefresh: notifier.refresh,
          hasMore: pagingState.hasMore,
          isLoadingMore: pagingState.isLoadingMore,
          onLoadMore: () => notifier.loadMore(),
        ),

        // ── Tab Hàng tuần ─────────────────────────────────────────────
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppColors.s16),
              child: Column(
                children: [
                  _MonthPicker(month: _selectedMonth, onChange: _changeMonth),
                  const SizedBox(height: AppColors.s12),
                  _WeekChips(
                    weeks: weeksInSelectedMonth,
                    selectedIndex: safeWeekIndex,
                    onSelect: (i) => setState(() => _selectedWeekIndex = i),
                  ),
                ],
              ),
            ),
            if (_isLoadingRangeData)
              const Padding(
                padding: EdgeInsets.only(bottom: AppColors.s8),
                child: LinearProgressIndicator(
                  minHeight: 2,
                  color: AppColors.primary,
                ),
              ),
            Expanded(
              child: weeklyItems.isEmpty
                  ? (_isLoadingRangeData
                      ? const Center(child: CircularProgressIndicator())
                      : HistoryEmptyState(
                          message: 'Không có dữ liệu quét tuần này',
                          onRefresh: () => _ensureMonthLoaded(_selectedMonth)))
                  : HistoryAllTab(
                      items: weeklyItems,
                      deltaMap: deltaMap,
                      onRefresh: notifier.refresh,
                      hasMore: false,
                      isLoadingMore: _isLoadingRangeData,
                      onLoadMore: () {},
                    ),
            ),
          ],
        ),

        // ── Tab Hàng tháng ─────────────────────────────────────────────
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppColors.s16),
              child:
                  _MonthPicker(month: _selectedMonth, onChange: _changeMonth),
            ),
            if (_isLoadingRangeData)
              const Padding(
                padding: EdgeInsets.only(bottom: AppColors.s8),
                child: LinearProgressIndicator(
                  minHeight: 2,
                  color: AppColors.primary,
                ),
              ),
            Expanded(
              child: monthlyItems.isEmpty
                  ? (_isLoadingRangeData
                      ? const Center(child: CircularProgressIndicator())
                      : HistoryEmptyState(
                          message: 'Không có dữ liệu quét tháng này',
                          onRefresh: () => _ensureMonthLoaded(_selectedMonth)))
                  : HistoryAllTab(
                      items: monthlyItems,
                      deltaMap: deltaMap,
                      onRefresh: notifier.refresh,
                      hasMore: false,
                      isLoadingMore: _isLoadingRangeData,
                      onLoadMore: () {},
                    ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Month picker (prev/next) ─────────────────────────────────────────────
class _MonthPicker extends StatelessWidget {
  final DateTime month;
  final ValueChanged<int> onChange; // truyền -1 hoặc +1
  const _MonthPicker({required this.month, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppColors.s12, vertical: AppColors.s8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => onChange(-1),
            icon: const Icon(Icons.chevron_left, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          Text('Tháng ${month.month}, ${month.year}',
              style:
                  AppTextStyles.body().copyWith(fontWeight: FontWeight.w600)),
          IconButton(
            onPressed: () => onChange(1),
            icon: const Icon(Icons.chevron_right, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

// ── Week chips trong tháng đã chọn ───────────────────────────────────────
class _WeekChips extends StatelessWidget {
  final List<DateTimeRange> weeks;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  const _WeekChips({
    required this.weeks,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: weeks.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppColors.s8),
        itemBuilder: (_, i) {
          final selected = i == selectedIndex;
          return ChoiceChip(
            label: Text(
                'Tuần ${i + 1} (${weeks[i].start.day}-${weeks[i].end.day})'),
            selected: selected,
            onSelected: (_) => onSelect(i),
            selectedColor: AppColors.primary,
            labelStyle: AppTextStyles.caption(
                color: selected ? Colors.white : AppColors.textSecondary),
            backgroundColor: AppColors.surface,
            side: const BorderSide(color: AppColors.border),
          );
        },
      ),
    );
  }
}