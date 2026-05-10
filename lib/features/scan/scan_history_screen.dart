import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:glow_aura/core/theme/app_theme.dart';
import 'package:glow_aura/shared/widgets/main_scaffold.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
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

  static const _todayItems = [
    _ScanItem(
      icon: Icons.wb_sunny_outlined,
      iconBg: Color(0xFFFFF8E1),
      iconColor: Color(0xFFD4A24C),
      title: 'Buổi sáng',
      subtitle: '10:24 AM • Da khô',
      score: 92,
      delta: '+3',
      deltaPositive: true,
    ),
  ];

  static const _oct2023Items = [
    _ScanItem(
      icon: Icons.face_retouching_natural,
      iconBg: Color(0xFFF7D0E0),
      iconColor: Color(0xFFC0356B),
      title: 'Sau khi skincare',
      subtitle: '25 Tháng 10 • 09:15 PM',
      score: 88,
      delta: '+8',
      deltaPositive: true,
    ),
    _ScanItem(
      icon: Icons.access_alarm_outlined,
      iconBg: Color(0xFFE8F0FB),
      iconColor: Color(0xFF3B7DD8),
      title: 'Quét định kỳ',
      subtitle: '20 Tháng 10 • 08:00 AM',
      score: 84,
      delta: '+1',
      deltaPositive: true,
    ),
    _ScanItem(
      icon: Icons.spa_outlined,
      iconBg: Color(0xFFE8F5E9),
      iconColor: Color(0xFF388E3C),
      title: 'Sau liệu trình spa',
      subtitle: '15 Tháng 10 • 05:30 PM',
      score: 95,
      delta: '+10',
      deltaPositive: true,
    ),
    _ScanItem(
      icon: Icons.nightlight_outlined,
      iconBg: Color(0xFFEDE7F6),
      iconColor: Color(0xFF6A1B9A),
      title: 'Buổi tối muộn',
      subtitle: '10 Tháng 10 • 11:45 PM',
      score: 78,
      delta: '-5',
      deltaPositive: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
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
              child: TabBarView(
                controller: _tabController,
                children: [
                  _AllTab(
                    todayItems: _todayItems,
                    oct2023Items: _oct2023Items,
                  ),
                  _EmptyTab(message: 'Chưa có dữ liệu hàng tuần'),
                  _EmptyTab(message: 'Chưa có dữ liệu hàng tháng'),
                ],
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
  final List<_ScanItem> todayItems;
  final List<_ScanItem> oct2023Items;

  const _AllTab({required this.todayItems, required this.oct2023Items});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
                  value: '85',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.trending_up,
                          size: 12, color: AppColors.success),
                      const SizedBox(width: 2),
                      Text('~5%',
                          style: AppTextStyles.caption(
                              color: AppColors.success)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppColors.s12),
              Expanded(
                child: _StatCard(
                  label: 'LẦN QUÉT CUỐI',
                  value: 'Hôm nay',
                  trailing: const Icon(Icons.check_circle,
                      size: 16, color: AppColors.success),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppColors.s24),

          // ── Today ─────────────────────────────────────────────────────
          _GroupLabel('HÔM NAY'),
          const SizedBox(height: AppColors.s8),
          ...todayItems.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: AppColors.s8),
                child: _ScanCard(item: item),
              )),
          const SizedBox(height: AppColors.s16),

          // ── October 2023 ──────────────────────────────────────────────
          _GroupLabel('THÁNG 10, 2023'),
          const SizedBox(height: AppColors.s8),
          ...oct2023Items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: AppColors.s8),
                child: _ScanCard(item: item),
              )),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

// ── Empty tab ─────────────────────────────────────────────────────────────────
class _EmptyTab extends StatelessWidget {
  final String message;
  const _EmptyTab({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
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

// ── Scan card ─────────────────────────────────────────────────────────────────
class _ScanCard extends StatelessWidget {
  final _ScanItem item;
  const _ScanCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppColors.s12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: item.iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(item.icon, color: item.iconColor, size: 22),
          ),
          const SizedBox(width: AppColors.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: AppTextStyles.title()),
                const SizedBox(height: AppColors.s4),
                Text(item.subtitle, style: AppTextStyles.caption()),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${item.score}',
                  style: AppTextStyles.heading(
                      color: AppColors.textPrimary)),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    item.deltaPositive
                        ? Icons.arrow_upward
                        : Icons.arrow_downward,
                    size: 10,
                    color: item.deltaPositive
                        ? AppColors.success
                        : AppColors.error,
                  ),
                  Text(item.delta.replaceAll('+', '').replaceAll('-', ''),
                      style: AppTextStyles.caption(
                          color: item.deltaPositive
                              ? AppColors.success
                              : AppColors.error)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Data model ────────────────────────────────────────────────────────────────
class _ScanItem {
  final IconData icon;
  final Color iconBg, iconColor;
  final String title, subtitle, delta;
  final int score;
  final bool deltaPositive;

  const _ScanItem({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.score,
    required this.delta,
    required this.deltaPositive,
  });
}