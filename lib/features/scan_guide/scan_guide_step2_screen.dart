import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:glow_aura/core/theme/app_theme.dart';
import 'package:glow_aura/shared/widgets/shared_widgets.dart';


class ScanGuideStep2Screen extends StatelessWidget {
  const ScanGuideStep2Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/scan-guide'),
        ),
        title: Text('Glow Aura', style: AppTextStyles.title()),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline,
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
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppColors.s16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const StepIndicator(step: 2, total: 4, label: 'Bước 2: Ánh sáng'),
                    const SizedBox(height: AppColors.s24),
                    Text('Đảm bảo ánh sáng', style: AppTextStyles.display()),
                    const SizedBox(height: AppColors.s8),
                    Text(
                      'Để kết quả Glow Aura chính xác nhất, hãy chú ý đến môi trường xung quanh bạn.',
                      style: AppTextStyles.body(),
                    ),
                    const SizedBox(height: AppColors.s24),
                    _LightingExamples(),
                    const SizedBox(height: AppColors.s24),
                    Text('Mẹo nhỏ cho bạn', style: AppTextStyles.heading()),
                    const SizedBox(height: AppColors.s12),
                    const _TipCard(
                      icon: Icons.face_retouching_natural,
                      title: 'Làm sạch khuôn mặt',
                      desc: 'Giữ khuôn mặt tươi tắn và lau sạch ống kính camera.',
                    ),
                    const SizedBox(height: AppColors.s12),
                    const _TipCard(
                      icon: Icons.camera_outlined,
                      title: 'Giữ yên máy',
                      desc: 'Tránh rung lắc camera trong quá trình phân tích hào quang.',
                    ),
                  ],
                ),
              ),
            ),
            BottomCta(
              label: 'Bắt đầu quét',
              showArrow: true,
              onPressed: () => context.go('/scan'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Lighting examples ─────────────────────────────────────────────────────────
class _LightingExamples extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: _LightingCard(
            icon: Icons.wb_sunny_outlined,
            iconColor: AppColors.accentGold,
            bgColor:  Color(0xFFD8EAF5),
            label: 'Ánh sáng tự nhiên',
            sublabel: 'Tránh ngược sáng',
          ),
        ),
        SizedBox(width: AppColors.s8),
        Expanded(
          child: _LightingCard(
            icon: Icons.camera_front_outlined,
            iconColor: AppColors.primary,
            bgColor: AppColors.primaryTint,
            label: 'Vị trí camera',
            sublabel: 'Ngang tầm mắt',
          ),
        ),
      ],
    );
  }
}

class _LightingCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor, bgColor;
  final String label, sublabel;

  const _LightingCard({
    required this.icon, required this.iconColor,
    required this.bgColor, required this.label, required this.sublabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 110,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Center(
              child: Icon(icon, size: 40, color: iconColor),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppColors.s12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.title()),
                const SizedBox(height: AppColors.s4),
                Text(sublabel, style: AppTextStyles.caption()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tip card ──────────────────────────────────────────────────────────────────
class _TipCard extends StatelessWidget {
  final IconData icon;
  final String title, desc;
  const _TipCard({required this.icon, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppColors.s16),
      decoration: BoxDecoration(
        color: AppColors.primarySubtle,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryTint),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40, height: 40,
            decoration: const BoxDecoration(
              color: AppColors.primaryTint,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: AppColors.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.title()),
                const SizedBox(height: AppColors.s4),
                Text(desc, style: AppTextStyles.body()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}