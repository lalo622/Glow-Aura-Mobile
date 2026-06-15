import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:glow_aura/core/theme/app_theme.dart';
import 'package:glow_aura/shared/widgets/shared_widgets.dart';

class ScanGuideStep1Screen extends StatelessWidget {
  const ScanGuideStep1Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        title: Text('Hướng dẫn chuẩn bị', style: AppTextStyles.title()),
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
                    const StepIndicator(step: 1, total: 4, label: 'Bước 1: Chuẩn bị'),
                    const SizedBox(height: AppColors.s24),
                    Text('Căn chỉnh khuôn mặt', style: AppTextStyles.display()),
                    const SizedBox(height: AppColors.s8),
                    Text(
                      'Để có kết quả phân tích Glow Aura chính xác nhất, hãy đảm bảo khuôn mặt bạn nằm trọn trong khung hình.',
                      style: AppTextStyles.body(),
                    ),
                    const SizedBox(height: AppColors.s24),
                    _FaceFramePreview(),
                    const SizedBox(height: AppColors.s24),
                    const _InstructionItem(
                      number: '1',
                      text: 'Giữ điện thoại ngang tầm mắt, cách mặt khoảng 30–40cm.',
                    ),
                    const SizedBox(height: AppColors.s12),
                    const _InstructionItem(
                      number: '2',
                      text: 'Giữ biểu cảm tự nhiên, không đeo kính hoặc phụ kiện che mặt.',
                    ),
                  ],
                ),
              ),
            ),
            BottomCta(
              label: 'Tiếp theo',
              showArrow: true,
              onPressed: () => context.go('/scan-guide-2'),
              footnote: 'Glow Aura sử dụng AI để phân tích sắc diện của bạn',
            ),
          ],
        ),
      ),
    );
  }
}

// ── Face frame preview ────────────────────────────────────────────────────────
class _FaceFramePreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 360,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 142, 142, 143),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ── Ảnh người dùng ─────────────────────────────────────────
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/images/scan_1.png',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // ── Oval guide ──────────────────────────────────────────────
          Container(
            width: 160,
            height: 210,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(80),
              border: Border.all(
                color: AppColors.primary,
                width: 2,
              ),
            ),
          ),

          // ── Scan label ──────────────────────────────────────────────
          Positioned(
            top: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('KHUNG QUÉT',
                  style: AppTextStyles.label(color: Colors.white)),
            ),
          ),

          // ── Tip bar ─────────────────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppColors.s16, vertical: AppColors.s12),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.93),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.wb_sunny_outlined,
                      color: AppColors.accentGold, size: 16),
                  const SizedBox(width: AppColors.s8),
                  Expanded(
                    child: Text(
                      'Mẹo: Chọn nơi có ánh sáng tự nhiên, tránh ngược sáng.',
                      style: AppTextStyles.caption(
                          color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Instruction item ──────────────────────────────────────────────────────────
class _InstructionItem extends StatelessWidget {
  final String number;
  final String text;
  const _InstructionItem({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28, height: 28,
          decoration: const BoxDecoration(
              color: AppColors.primary, shape: BoxShape.circle),
          child: Center(
            child: Text(number,
                style: AppTextStyles.body(color: Colors.white)
                    .copyWith(fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(width: AppColors.s12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(text, style: AppTextStyles.body()),
          ),
        ),
      ],
    );
  }
}