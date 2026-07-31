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

  // Tháng đang được chọn để xem (dùng chung cho tab Tuần & Tháng)
  DateTime _selectedMonth =
      DateTime(DateTime.now().year, DateTime.now().month);
  // Tuần đang chọn (index trong tháng đã chọn), reset khi đổi tháng
  int _selectedWeekIndex = 0;

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

  void _changeMonth(int delta) {
    setState(() {
      _selectedMonth =
          DateTime(_selectedMonth.year, _selectedMonth.month + delta);
      _selectedWeekIndex = 0;
    });
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
                error: (err, _) => HistoryErrorState(
                  error: err,
                  onRetry: () => ref.invalidate(skinAnalysisHistoryProvider),
                ),
                data: (response) {
                  final items = [...response.items]
                    ..sort((a, b) => b.capturedAt.compareTo(a.capturedAt));

                  if (items.isEmpty) {
                    return HistoryEmptyState(
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

                  final monthlyItems = items
                      .where((i) =>
                          i.capturedAt.year == _selectedMonth.year &&
                          i.capturedAt.month == _selectedMonth.month)
                      .toList();

                  final weeksInSelectedMonth = _weeksInMonth(_selectedMonth);
                  final safeWeekIndex = _selectedWeekIndex.clamp(
                      0, weeksInSelectedMonth.length - 1);
                  final selectedWeekRange =
                      weeksInSelectedMonth[safeWeekIndex];
                  final weeklyItems = items
                      .where((i) =>
                          !i.capturedAt.isBefore(selectedWeekRange.start) &&
                          !i.capturedAt.isAfter(selectedWeekRange.end))
                      .toList();

                  Future<void> onRefresh() =>
                      ref.refresh(skinAnalysisHistoryProvider.future);

                  return TabBarView(
                    controller: _tabController,
                    children: [
                      // ── Tab Tất cả ─────────────────────────────────────
                      HistoryAllTab(
                        items: items,
                        deltaMap: deltaMap,
                        onRefresh: onRefresh,
                      ),

                      // ── Tab Hàng tuần ──────────────────────────────────
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(AppColors.s16),
                            child: Column(
                              children: [
                                _MonthPicker(
                                  month: _selectedMonth,
                                  onChange: _changeMonth,
                                ),
                                const SizedBox(height: AppColors.s12),
                                _WeekChips(
                                  weeks: weeksInSelectedMonth,
                                  selectedIndex: safeWeekIndex,
                                  onSelect: (i) =>
                                      setState(() => _selectedWeekIndex = i),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: weeklyItems.isEmpty
                                ? HistoryEmptyState(
                                    message: 'Không có dữ liệu quét tuần này',
                                    onRefresh: onRefresh)
                                : HistoryAllTab(
                                    items: weeklyItems,
                                    deltaMap: deltaMap,
                                    onRefresh: onRefresh),
                          ),
                        ],
                      ),

                      // ── Tab Hàng tháng ─────────────────────────────────
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(AppColors.s16),
                            child: _MonthPicker(
                              month: _selectedMonth,
                              onChange: _changeMonth,
                            ),
                          ),
                          Expanded(
                            child: monthlyItems.isEmpty
                                ? HistoryEmptyState(
                                    message: 'Không có dữ liệu quét tháng này',
                                    onRefresh: onRefresh)
                                : HistoryAllTab(
                                    items: monthlyItems,
                                    deltaMap: deltaMap,
                                    onRefresh: onRefresh),
                          ),
                        ],
                      ),
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