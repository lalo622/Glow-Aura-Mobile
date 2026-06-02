import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:glow_aura/core/theme/app_theme.dart';

class ScanDetailScreen extends StatelessWidget {
  final String imagePath;
  final int scanId;
  const ScanDetailScreen({
    super.key,
    required this.imagePath,
    required this.scanId,
  });
  
  static const _zones = [
    _ZoneData(
      number: '1',
      title: 'Vùng chữ T',
      subtitle: 'Mật độ mụn trung bình',
      value: 'Giảm 8%',
      positive: true,
    ),
    _ZoneData(
      number: '2',
      title: 'Vùng má',
      subtitle: 'Mật độ thấp',
      value: 'Giảm 22%',
      positive: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text('Chi tiết Mụn & Đốm', style: AppTextStyles.title()),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined,
                color: AppColors.textSecondary),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppColors.s16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppColors.s16),

              // ── Header card ───────────────────────────────────────────
              _HeaderCard(),
              const SizedBox(height: AppColors.s24),

              // ── Stats row ─────────────────────────────────────────────
              _StatsRow(),
              const SizedBox(height: AppColors.s24),

              // ── Face map — sẽ tích hợp ML Kit sau ────────────────────
              _FaceMapComingSoon(),
              const SizedBox(height: AppColors.s24),

              // ── Deep analysis ─────────────────────────────────────────
              Text('Phân tích chuyên sâu', style: AppTextStyles.heading()),
              const SizedBox(height: AppColors.s12),
              ..._zones.map((z) => Padding(
                    padding: const EdgeInsets.only(bottom: AppColors.s8),
                    child: _ZoneCard(data: z),
                  )),
              const SizedBox(height: AppColors.s16),

              // ── Expert tip ────────────────────────────────────────────
              _ExpertTipCard(),
              const SizedBox(height: AppColors.s32),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Header card ───────────────────────────────────────────────────────────────
class _HeaderCard extends StatelessWidget {
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
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              color: AppColors.primaryTint,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            child: const Icon(Icons.person,
                size: 36, color: AppColors.primary),
          ),
          const SizedBox(width: AppColors.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Phân tích Aura của bạn',
                    style: AppTextStyles.title()),
                const SizedBox(height: AppColors.s4),
                Row(
                  children: [
                    const Icon(Icons.refresh,
                        size: 12, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text('Cập nhật: Hôm nay, 10:45 AM',
                        style: AppTextStyles.caption(
                            color: AppColors.primary)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stats row ─────────────────────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.circle_outlined,
            iconColor: AppColors.error,
            label: 'MỤN',
            value: '12',
            delta: '↘ 15%',
            deltaPositive: true,
          ),
        ),
        const SizedBox(width: AppColors.s12),
        Expanded(
          child: _StatCard(
            icon: Icons.grain_outlined,
            iconColor: AppColors.accentGold,
            label: 'ĐỐM NÂU',
            value: '8',
            delta: '↘ 5%',
            deltaPositive: true,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label, value, delta;
  final bool deltaPositive;

  const _StatCard({
    required this.icon, required this.iconColor,
    required this.label, required this.value,
    required this.delta, required this.deltaPositive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppColors.s16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: AppColors.s4),
              Text(label, style: AppTextStyles.label()),
            ],
          ),
          const SizedBox(height: AppColors.s8),
          Text(value,
              style: AppTextStyles.display(
                  color: AppColors.textPrimary)),
          const SizedBox(height: AppColors.s4),
          Text(delta,
              style: AppTextStyles.caption(
                  color: deltaPositive
                      ? AppColors.success
                      : AppColors.error)),
        ],
      ),
    );
  }
}

// ── Face map — coming soon ────────────────────────────────────────────────────
class _FaceMapComingSoon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Bản đồ mật độ', style: AppTextStyles.heading()),
        const SizedBox(height: AppColors.s12),
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: AppColors.primaryTint, width: 1.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primaryTint,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.face_outlined,
                    color: AppColors.primary, size: 28),
              ),
              const SizedBox(height: AppColors.s12),
              Text('Bản đồ mặt AI',
                  style: AppTextStyles.title(
                      color: AppColors.primary)),
              const SizedBox(height: AppColors.s4),
              Text('Đang phát triển',
                  style: AppTextStyles.caption(),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Zone card ─────────────────────────────────────────────────────────────────
class _ZoneCard extends StatelessWidget {
  final _ZoneData data;
  const _ZoneCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppColors.s16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 28, height: 28,
            decoration: const BoxDecoration(
              color: AppColors.primaryTint,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(data.number,
                  style: AppTextStyles.body(color: AppColors.primary)
                      .copyWith(fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(width: AppColors.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.title, style: AppTextStyles.title()),
                const SizedBox(height: AppColors.s4),
                Text(data.subtitle, style: AppTextStyles.caption()),
              ],
            ),
          ),
          Text(data.value,
              style: AppTextStyles.body(
                      color: data.positive
                          ? AppColors.success
                          : AppColors.error)
                  .copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ── Expert tip ────────────────────────────────────────────────────────────────
class _ExpertTipCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppColors.s16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_outline,
              color: Colors.white70, size: 20),
          const SizedBox(width: AppColors.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('LỜI KHUYÊN CHUYÊN GIA',
                    style: AppTextStyles.label(color: Colors.white70)),
                const SizedBox(height: AppColors.s4),
                Text(
                  'Tiếp tục sử dụng sản phẩm chứa Niacinamide để giảm thiểu đốm nâu vùng trán.',
                  style: AppTextStyles.body(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Data models ───────────────────────────────────────────────────────────────
class _ZoneData {
  final String number, title, subtitle, value;
  final bool positive;

  const _ZoneData({
    required this.number, required this.title,
    required this.subtitle, required this.value,
    required this.positive,
  });
}