import 'package:flutter/material.dart';
import 'package:glow_aura/core/theme/app_theme.dart';
import 'package:glow_aura/shared/widgets/main_scaffold.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      currentIndex: 0,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppColors.s16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppColors.s32),
              _TopBar(),
              const SizedBox(height: AppColors.s24),
              _Greeting(),
              const SizedBox(height: AppColors.s16),
              _ScanButton(),
              const SizedBox(height: AppColors.s24),
              _HealthScoreCard(),
              const SizedBox(height: AppColors.s24),
              _RecentAnalysesSection(),
              const SizedBox(height: AppColors.s16),
              _TipCard(),
              const SizedBox(height: 100), // padding cho FAB
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40, height: 40,
          decoration: const BoxDecoration(
              color: AppColors.primaryTint, shape: BoxShape.circle),
          child: const Icon(Icons.person_outline,
              color: AppColors.primary, size: 22),
        ),
        const SizedBox(width: AppColors.s12),
        Text('Glow Aura',
            style: AppTextStyles.title(color: AppColors.primary)),
        const Spacer(),
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: AppColors.surface, shape: BoxShape.circle,
            border: Border.all(color: AppColors.border),
          ),
          child: const Icon(Icons.notifications_none_outlined,
              color: AppColors.textSecondary, size: 20),
        ),
      ],
    );
  }
}

class _Greeting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Chào Tiến', style: AppTextStyles.display()),
        const SizedBox(height: AppColors.s4),
        Text('Hôm nay làn da của bạn thế nào?',
            style: AppTextStyles.body()),
      ],
    );
  }
}

class _ScanButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, height: 52,
      child: ElevatedButton.icon(
        onPressed: () => context.go('/scan-guide'),
        icon: const Icon(Icons.document_scanner_outlined,
            size: 20, color: Colors.white),
        label: const Text('Quét nhanh ngay'),
      ),
    );
  }
}

class _HealthScoreCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppColors.s16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 72, height: 72,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 72, height: 72,
                  child: CircularProgressIndicator(
                    value: 0.85,
                    strokeWidth: 6,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primary),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('85',
                        style: GoogleFonts.manrope(
                            fontSize: 22, fontWeight: FontWeight.w700,
                            color: AppColors.primary)),
                    Text('/100', style: AppTextStyles.label()),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppColors.s16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CHỈ SỐ SỨC KHỎE DA', style: AppTextStyles.label()),
                const SizedBox(height: AppColors.s4),
                Row(children: [
                  const Icon(Icons.trending_up,
                      size: 14, color: AppColors.success),
                  const SizedBox(width: 4),
                  Text('+5%',
                      style: AppTextStyles.caption(color: AppColors.success)),
                ]),
                const SizedBox(height: AppColors.s4),
                Text('So với tuần trước', style: AppTextStyles.caption()),
              ],
            ),
          ),
          const Icon(Icons.favorite_border,
              color: AppColors.primary, size: 22),
        ],
      ),
    );
  }
}

class _RecentAnalysesSection extends StatelessWidget {
  static const _items = [
    _AnalysisData(
      iconBg: Color(0xFFE8F0FB), iconColor: Color(0xFF3B7DD8),
      icon: Icons.water_drop_outlined,
      title: 'Độ ẩm & Dầu', time: 'Hôm nay, 08:30 AM',
      status: 'Tốt', statusColor: AppColors.success,
      statusIcon: Icons.check_circle_outline,
    ),
    _AnalysisData(
      iconBg: Color(0xFFFFF3E8), iconColor: Color(0xFFD4821C),
      icon: Icons.blur_on,
      title: 'Lỗ chân lông', time: 'Hôm qua, 09:15 PM',
      status: 'Cần chú ý', statusColor: AppColors.warning,
      statusIcon: Icons.warning_amber_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Phân tích gần đây', style: AppTextStyles.heading()),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                  padding: EdgeInsets.zero, minimumSize: Size.zero),
              child: Text('Xem tất cả',
                  style: AppTextStyles.body(color: AppColors.primary)),
            ),
          ],
        ),
        const SizedBox(height: AppColors.s12),
        ..._items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: AppColors.s12),
              child: _AnalysisCard(data: item),
            )),
      ],
    );
  }
}

class _AnalysisCard extends StatelessWidget {
  final _AnalysisData data;
  const _AnalysisCard({required this.data});

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
                color: data.iconBg,
                borderRadius: BorderRadius.circular(10)),
            child: Icon(data.icon, color: data.iconColor, size: 22),
          ),
          const SizedBox(width: AppColors.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.title, style: AppTextStyles.title()),
                const SizedBox(height: AppColors.s4),
                Text(data.time, style: AppTextStyles.caption()),
              ],
            ),
          ),
          Row(children: [
            Icon(data.statusIcon, color: data.statusColor, size: 14),
            const SizedBox(width: 4),
            Text(data.status,
                style: AppTextStyles.caption(color: data.statusColor)),
          ]),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppColors.s16),
      decoration: BoxDecoration(
        color: AppColors.accentTint,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDD9B0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36, height: 36,
            decoration: const BoxDecoration(
                color: AppColors.accentGold, shape: BoxShape.circle),
            child: const Icon(Icons.lightbulb_outline,
                color: Colors.white, size: 18),
          ),
          const SizedBox(width: AppColors.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mẹo nhỏ cho bạn',
                    style: AppTextStyles.title(color: AppColors.accentGold)),
                const SizedBox(height: AppColors.s4),
                Text(
                  'Đừng quên thoa kem chống nắng ngay cả khi trời nhiều mây để bảo vệ làn da nhé!',
                  style: AppTextStyles.body(color: const Color(0xFF7A5A1A)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalysisData {
  final Color iconBg, iconColor, statusColor;
  final IconData icon, statusIcon;
  final String title, time, status;
  const _AnalysisData({
    required this.iconBg, required this.iconColor, required this.icon,
    required this.title, required this.time, required this.status,
    required this.statusColor, required this.statusIcon,
  });
}