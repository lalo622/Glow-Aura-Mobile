import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:glow_aura/core/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

import 'data/scan_database.dart';

class ScanResultScreen extends StatefulWidget {
  final String imagePath;
  final int    scanId;

  const ScanResultScreen({
    super.key,
    required this.imagePath,
    required this.scanId,
  });

  @override
  State<ScanResultScreen> createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends State<ScanResultScreen> {
  ScanRecord? _scanRecord;
  final bool _isLoadingResult = false;

  // ── Hardcode data — TODO: replace bằng _scanRecord.metricsJson  ──
  static const _metrics = [
    _MetricData(
      icon:          Icons.light_mode_outlined,
      iconBg:        Color(0xFFFFF8E1),
      iconColor:     Color(0xFFD4A24C),
      label:         'Độ sáng',
      value:         82,
      delta:         '+5%',
      deltaPositive: true,
    ),
    _MetricData(
      icon:          Icons.blur_linear_outlined,
      iconBg:        Color(0xFFE8F5E9),
      iconColor:     Color(0xFF388E3C),
      label:         'Độ đều màu',
      value:         78,
      delta:         '-2%',
      deltaPositive: false,
    ),
    _MetricData(
      icon:          Icons.grain_outlined,
      iconBg:        Color(0xFFE8EAF6),
      iconColor:     Color(0xFF3949AB),
      label:         'Độ mịn',
      value:         90,
      delta:         '+1%',
      deltaPositive: true,
    ),
  ];

  int    get _glowScore  => _scanRecord?.glowScore  ?? 85;
  String get _adviceText => _scanRecord?.adviceText ??
      'Làn da của bạn đang có độ sáng khá tốt. Tuy nhiên, sự chênh lệch nhẹ '
      'về độ đều màu cho thấy bạn nên bổ sung các sản phẩm có chứa Vitamin C '
      'và Niacinamide để duy trì độ rạng rỡ tối ưu.';

  @override
  void initState() {
    super.initState();
    // TODO: khi BE connect xong, gọi _loadResultFromDb() để lấy kết quả 
    // _loadResultFromDb();
  }

  // Future<void> _loadResultFromDb() async {
  //   setState(() => _isLoadingResult = true);
  //   final db     = ScanDatabase();
  //   final record = await db.getScanById(widget.scanId);
  //   if (mounted) setState(() {
  //     _scanRecord       = record;
  //     _isLoadingResult  = false;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
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
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppColors.s16),
                child: Column(
                  children: [
                    const SizedBox(height: AppColors.s24),

                    // ── Ảnh chụp thật ────────────────────────────────────
                    _CapturedImageCard(imagePath: widget.imagePath),
                    const SizedBox(height: AppColors.s24),

                    // ── Score ring ────────────────────────────────────────
                    _isLoadingResult
                        ? const _ScoreRingSkeleton()
                        : _ScoreRing(score: _glowScore),
                    const SizedBox(height: AppColors.s12),
                    Text(
                      'Chỉ số Glow Aura của bạn đang ở mức rất tốt',
                      style: AppTextStyles.body(color: AppColors.primary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppColors.s32),

                    // ── Detailed metrics ──────────────────────────────────
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Phân tích chi tiết',
                          style: AppTextStyles.heading()),
                    ),
                    const SizedBox(height: AppColors.s12),
                    ..._metrics.map((m) => Padding(
                          padding:
                              const EdgeInsets.only(bottom: AppColors.s12),
                          child: _MetricCard(data: m),
                        )),
                    const SizedBox(height: AppColors.s8),

                    // ── Expert advice ─────────────────────────────────────
                    _ExpertAdviceCard(adviceText: _adviceText),
                    const SizedBox(height: AppColors.s24),

                    // ── Sync status chip (debug helper) ───────────────────
                    // Hiện trạng sync với BE — bỏ đi khi release
                    _SyncStatusChip(scanId: widget.scanId),
                    const SizedBox(height: AppColors.s8),
                  ],
                ),
              ),
            ),

            // ── CTA ───────────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(
                  AppColors.s16, AppColors.s12,
                  AppColors.s16, AppColors.s24),
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
                    'scanId': widget.scanId,
                  }),
                  child: const Text('Kết quả chi tiết'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CapturedImageCard extends StatelessWidget {
  final String imagePath;
  const _CapturedImageCard({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          Image.file(
            File(imagePath),
            width:     double.infinity,
            height:    220,
            fit:       BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width:  double.infinity,
              height: 220,
              color:  AppColors.surface,
              child:  const Icon(Icons.broken_image_outlined,
                  size: 48, color: AppColors.textSecondary),
            ),
          ),
          // Label góc trên trái
          Positioned(
            top: 12, left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color:        Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, color: Colors.greenAccent, size: 14),
                  SizedBox(width: 4),
                  Text('Đã lưu vào thư viện',
                      style: TextStyle(color: Colors.white, fontSize: 11)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SyncStatusChip extends StatelessWidget {
  final int scanId;
  const _SyncStatusChip({required this.scanId});

  @override
  Widget build(BuildContext context) {
    // TODO: khi connect BE FutureBuilder lấy status thật từ Drift
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color:        Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border:       Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_outlined,
              size: 14, color: Colors.orange),
          const SizedBox(width: 6),
          Text('Scan #$scanId · Hachimichi',
              style: const TextStyle(
                  color: Colors.orange, fontSize: 11)),
        ],
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
              value:           score / 100,
              strokeWidth:     10,
              backgroundColor: AppColors.primaryTint,
              valueColor:      const AlwaysStoppedAnimation<Color>(
                  AppColors.primary),
              strokeCap: StrokeCap.round,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$score',
                  style: GoogleFonts.manrope(
                      fontSize:   48,
                      fontWeight: FontWeight.w700,
                      color:      AppColors.primary)),
              Text('EXCELLENT',
                  style: AppTextStyles.label(color: AppColors.primary)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScoreRingSkeleton extends StatelessWidget {
  const _ScoreRingSkeleton();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 160, height: 160,
      child: Center(
        child: CircularProgressIndicator(color: AppColors.primary),
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
        color:        AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border:       Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width:  44, height: 44,
            decoration: BoxDecoration(
                color:        data.iconBg,
                borderRadius: BorderRadius.circular(10)),
            child: Icon(data.icon, color: data.iconColor, size: 22),
          ),
          const SizedBox(width: AppColors.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.label,
                    style: AppTextStyles.body(
                        color: AppColors.textSecondary)),
                Text('${data.value}%',
                    style: AppTextStyles.heading()),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppColors.s8, vertical: 4),
            decoration: BoxDecoration(
              color: data.deltaPositive
                  ? AppColors.success.withValues(alpha: 0.1)
                  : AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  data.deltaPositive
                      ? Icons.trending_up
                      : Icons.trending_down,
                  size:  12,
                  color: data.deltaPositive
                      ? AppColors.success
                      : AppColors.error,
                ),
                const SizedBox(width: 2),
                Text(data.delta,
                    style: AppTextStyles.caption(
                        color: data.deltaPositive
                            ? AppColors.success
                            : AppColors.error)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpertAdviceCard extends StatelessWidget {
  final String adviceText;
  const _ExpertAdviceCard({required this.adviceText});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppColors.s16),
      decoration: BoxDecoration(
        color:        AppColors.accentTint,
        borderRadius: BorderRadius.circular(16),
        border:       Border.all(color: const Color(0xFFEDD9B0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44, height: 44,
            decoration: const BoxDecoration(
                color: AppColors.accentGold, shape: BoxShape.circle),
            child: const Icon(Icons.person_outline,
                color: Colors.white, size: 24),
          ),
          const SizedBox(width: AppColors.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Lời khuyên chuyên gia',
                    style:
                        AppTextStyles.title(color: AppColors.accentGold)),
                Text('AI GLOW AURA',
                    style:
                        AppTextStyles.label(color: AppColors.accentGold)),
                const SizedBox(height: AppColors.s8),
                Text(adviceText, style: AppTextStyles.body()),
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
  final Color    iconBg, iconColor;
  final String   label, delta;
  final int      value;
  final bool     deltaPositive;

  const _MetricData({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.delta,
    required this.deltaPositive,
  });
}