import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:glow_aura/core/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/skin_analysis_viewmodel.dart';

class ScanResultScreen extends ConsumerStatefulWidget {
  final String imagePath;
  final int scanId;

  const ScanResultScreen({
    super.key,
    required this.imagePath,
    required this.scanId,
  });

  @override
  ConsumerState<ScanResultScreen> createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends ConsumerState<ScanResultScreen> {

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(skinAnalysisViewmodelProvider.notifier)
          .analyze(widget.imagePath);
    });
  }

  @override
  Widget build(BuildContext context) {
    final analysisState = ref.watch(skinAnalysisViewmodelProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text('Kết quả phân tích', style: AppTextStyles.title()),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: SafeArea(
        child: analysisState.when(
          idle: () => const SizedBox.shrink(),
          uploading: (progress) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 64,
                  height: 64,
                  child: CircularProgressIndicator(
                    value: progress > 0 ? progress : null,
                    strokeWidth: 5,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    backgroundColor: AppColors.primaryTint,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  progress < 1.0
                      ? 'Đang gửi ảnh lên hệ thống... ${(progress * 100).toStringAsFixed(0)}%'
                      : 'Hệ thống AI đang phân tích làn da...',
                  style: AppTextStyles.body(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),

          success: (result) {
            final dynamicMetrics = [
              _MetricData(
                icon: Icons.light_mode_outlined,
                iconBg: const Color(0xFFFFF8E1),
                iconColor: const Color(0xFFD4A24C),
                label: 'Tổng số nốt mụn',
                value: result.acneSummary.totalAcne,
                suffix: ' nốt',
                remark: 'Tình trạng: ${result.acneSummary.severity}',
                isAlert: result.acneSummary.totalAcne > 5,
              ),
              _MetricData(
                icon: Icons.blur_linear_outlined,
                iconBg: const Color(0xFFE8F5E9),
                iconColor: const Color(0xFF388E3C),
                label: 'Mụn đầu đen / đầu trắng',
                value: result.acneSummary.blackheads,
                suffix: ' / ${result.acneSummary.whiteheads}',
                remark: 'Mụn viêm/mủ: ${result.acneSummary.pimples}',
                isAlert: result.acneSummary.pimples > 2,
              ),
            ];

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppColors.s16),
                    child: Column(
                      children: [
                        const SizedBox(height: AppColors.s24),

                        _ScoreRing(score: result.overallScore),
                        const SizedBox(height: AppColors.s12),
                        Text(
                          result.overallScore >= 80
                              ? 'Chỉ số Glow Aura của bạn đang ở mức rất tốt'
                              : 'Làn da của bạn cần được chăm sóc kỹ hơn',
                          style: AppTextStyles.body(color: AppColors.primary),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppColors.s32),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Phân tích chi tiết', style: AppTextStyles.heading()),
                        ),
                        const SizedBox(height: AppColors.s12),

                        ...dynamicMetrics.map((m) => Padding(
                              padding: const EdgeInsets.only(bottom: AppColors.s12),
                              child: _MetricCard(data: m),
                            )),
                        const SizedBox(height: AppColors.s8),

                        _ExpertAdviceCard(
                          advice: result.advice,
                          disclaimer: result.disclaimer,
                        ),
                        const SizedBox(height: AppColors.s24),
                      ],
                    ),
                  ),
                ),

                Container(
                  padding: const EdgeInsets.fromLTRB(
                      AppColors.s16, AppColors.s12, AppColors.s16, AppColors.s24),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    border: Border(top: BorderSide(color: AppColors.border)),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => context.push('/scan-detail', extra: {
                          'imagePath': widget.imagePath,
                          'result': result,
                        }),
                      child: const Text('Kết quả chi tiết'),
                    ),
                  ),
                ),
              ],
            );
          },

          error: (message) => Center(
            child: Padding(
              padding: const EdgeInsets.all(AppColors.s24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: 160,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () => ref
                          .read(skinAnalysisViewmodelProvider.notifier)
                          .analyze(widget.imagePath),
                      child: const Text('Thử lại'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ScoreRing extends StatelessWidget {
  final int score;
  const _ScoreRing({required this.score});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160, height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 160, height: 160,
            child: CircularProgressIndicator(
              value: score / 100,
              strokeWidth: 10,
              backgroundColor: AppColors.primaryTint,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              strokeCap: StrokeCap.round,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$score',
                  style: GoogleFonts.manrope(
                      fontSize: 48,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary)),
              Text(score >= 80 ? 'EXCELLENT' : 'STABLE',
                  style: AppTextStyles.label(color: AppColors.primary)),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final _MetricData data;
  const _MetricCard({required this.data});

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
                Text(data.label,
                    style: AppTextStyles.body(color: AppColors.textSecondary)),
                Text('${data.value}${data.suffix}',
                    style: AppTextStyles.heading()),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppColors.s8, vertical: 4),
            decoration: BoxDecoration(
              color: data.isAlert
                  ? AppColors.error.withValues(alpha: 0.1)
                  : AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              data.remark,
              style: AppTextStyles.caption(
                color: data.isAlert ? AppColors.error : AppColors.success,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class _ExpertAdviceCard extends StatelessWidget {
  final String advice;
  final String disclaimer;
  const _ExpertAdviceCard({required this.advice, required this.disclaimer});

  @override
  Widget build(BuildContext context) {
    final hasAdvice = advice.trim().isNotEmpty;
    final text = hasAdvice
        ? advice
        : (disclaimer.isNotEmpty
            ? disclaimer
            : 'Hệ thống chưa thể đưa ra tư vấn cho lần phân tích này.');

    return Container(
      padding: const EdgeInsets.all(AppColors.s16),
      decoration: BoxDecoration(
        color: hasAdvice ? AppColors.accentTint : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasAdvice ? const Color(0xFFEDD9B0) : AppColors.border,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
                color: hasAdvice ? AppColors.accentGold : AppColors.textSecondary,
                shape: BoxShape.circle),
            child: Icon(
              hasAdvice ? Icons.person_outline : Icons.info_outline,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: AppColors.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasAdvice ? 'Lời khuyên chuyên gia' : 'Thông báo',
                  style: AppTextStyles.title(
                      color: hasAdvice ? AppColors.accentGold : AppColors.textSecondary),
                ),
                Text('AI GLOW AURA',
                    style: AppTextStyles.label(
                        color: hasAdvice ? AppColors.accentGold : AppColors.textSecondary)),
                const SizedBox(height: AppColors.s8),
                Text(text, style: AppTextStyles.body()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricData {
  final IconData icon;
  final Color iconBg, iconColor;
  final String label;
  final int value;
  final String suffix;
  final String remark;
  final bool isAlert;

  const _MetricData({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.suffix,
    required this.remark,
    required this.isAlert,
  });
}