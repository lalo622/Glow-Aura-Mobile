import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:glow_aura/core/theme/app_theme.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen>
    with SingleTickerProviderStateMixin {
  bool _isScanning = false;
  double _progress = 0.75;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05)
        .animate(CurvedAnimation(
            parent: _pulseController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primarySubtle,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => context.go('/home'),
        ),
        title: Text('Quét da mặt', style: AppTextStyles.title()),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline,
                color: AppColors.textSecondary),
            onPressed: () => context.go('/scan-guide'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Camera preview area ───────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppColors.s16),
                child: _CameraPreviewArea(pulseAnimation: _pulseAnimation),
              ),
            ),

            // ── Scan status ───────────────────────────────────────────────
            Container(
              margin: const EdgeInsets.symmetric(horizontal: AppColors.s16),
              padding: const EdgeInsets.all(AppColors.s16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Đang phân tích cấu trúc da',
                          style: AppTextStyles.body(
                              color: AppColors.textPrimary)
                              .copyWith(fontWeight: FontWeight.w500)),
                      Text('${(_progress * 100).toInt()}%',
                          style: AppTextStyles.body(color: AppColors.primary)
                              .copyWith(fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: AppColors.s8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _progress,
                      minHeight: 6,
                      backgroundColor: AppColors.primaryTint,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: AppColors.s8),
                  Text('GIỮ YÊN VỊ TRÍ TRONG VÀI GIÂY',
                      style: AppTextStyles.label(color: AppColors.primary)),
                ],
              ),
            ),
            const SizedBox(height: AppColors.s16),

            // ── Status indicators ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppColors.s16),
              child: Row(
                children: [
                  Expanded(
                    child: _StatusChip(
                      icon: Icons.wb_sunny_outlined,
                      label: 'Ánh sáng',
                      value: 'TỐI ƯU',
                      valueColor: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: AppColors.s12),
                  Expanded(
                    child: _StatusChip(
                      icon: Icons.face_outlined,
                      label: 'Vị trí',
                      value: 'CHÍNH XÁC',
                      valueColor: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppColors.s24),

            // ── Camera controls ───────────────────────────────────────────
            _CameraControls(
              onCapture: () => context.go('/scan-result'),
            ),
            const SizedBox(height: AppColors.s12),

            Text(
              'Căn chỉnh khuôn mặt vào giữa khung hình để có kết quả tốt nhất',
              style: AppTextStyles.caption(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppColors.s24),
          ],
        ),
      ),
    );
  }
}

// ── Camera preview ────────────────────────────────────────────────────────────
class _CameraPreviewArea extends StatelessWidget {
  final Animation<double> pulseAnimation;
  const _CameraPreviewArea({required this.pulseAnimation});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryTint.withOpacity(0.3),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Face oval guide — dashed border effect
          AnimatedBuilder(
            animation: pulseAnimation,
            builder: (_, __) => Transform.scale(
              scale: pulseAnimation.value,
              child: CustomPaint(
                size: const Size(220, 290),
                painter: _DashedOvalPainter(color: AppColors.primary),
              ),
            ),
          ),

          // Corner scan lines
          ..._buildScanCorners(),

          // Center face placeholder
          Container(
            width: 200, height: 260,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              color: AppColors.primary.withOpacity(0.04),
            ),
          ),
        ],
      ),
    );
  }

  static List<Widget> _buildScanCorners() {
    return [
      Positioned(top: 40, left: 60,
          child: _ScanCorner(top: true, left: true)),
      Positioned(top: 40, right: 60,
          child: _ScanCorner(top: true, left: false)),
      Positioned(bottom: 40, left: 60,
          child: _ScanCorner(top: false, left: true)),
      Positioned(bottom: 40, right: 60,
          child: _ScanCorner(top: false, left: false)),
    ];
  }
}

class _DashedOvalPainter extends CustomPainter {
  final Color color;
  const _DashedOvalPainter({required this.color});

  @override
void paint(Canvas canvas, Size size) {
  final paint = Paint()
    ..color = color
    ..strokeWidth = 2
    ..style = PaintingStyle.stroke;

  const dashWidth = 12.0;
  const dashSpace = 6.0;
  final path = Path()
    ..addOval(Rect.fromLTWH(0, 0, size.width, size.height));

  final pathMetrics = path.computeMetrics();
  for (final metric in pathMetrics) {
    double distance = 0;
    while (distance < metric.length) {
      final end = (distance + dashWidth).clamp(0.0, metric.length);
      canvas.drawPath(metric.extractPath(distance, end), paint);
      distance += dashWidth + dashSpace;
    }
  }
}

  @override
  bool shouldRepaint(_) => false;
}

class _ScanCorner extends StatelessWidget {
  final bool top, left;
  const _ScanCorner({required this.top, required this.left});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20, height: 20,
      child: CustomPaint(
        painter: _CornerPainter(
            color: AppColors.primary, top: top, left: left),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final Color color;
  final bool top, left;
  const _CornerPainter(
      {required this.color, required this.top, required this.left});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final x = left ? 0.0 : size.width;
    final y = top ? 0.0 : size.height;
    final dx = left ? size.width : -size.width;
    final dy = top ? size.height : -size.height;
    canvas.drawLine(Offset(x, y), Offset(x + dx, y), paint);
    canvas.drawLine(Offset(x, y), Offset(x, y + dy), paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Status chip ───────────────────────────────────────────────────────────────
class _StatusChip extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color valueColor;

  const _StatusChip({
    required this.icon, required this.label,
    required this.value, required this.valueColor,
  });

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
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: AppColors.s8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.caption()),
              Text(value,
                  style: AppTextStyles.label(color: valueColor)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Camera controls ───────────────────────────────────────────────────────────
class _CameraControls extends StatelessWidget {
  final VoidCallback onCapture;
  const _CameraControls({required this.onCapture});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Gallery button
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border),
          ),
          child: const Icon(Icons.photo_outlined,
              color: AppColors.textSecondary, size: 22),
        ),
        const SizedBox(width: AppColors.s32),

        // Capture button
        GestureDetector(
          onTap: onCapture,
          child: Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.4),
                  blurRadius: 16, spreadRadius: 4,
                ),
              ],
            ),
            child: const Icon(Icons.camera_alt,
                color: Colors.white, size: 32),
          ),
        ),
        const SizedBox(width: AppColors.s32),

        // Flip camera button
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border),
          ),
          child: const Icon(Icons.flip_camera_ios_outlined,
              color: AppColors.textSecondary, size: 22),
        ),
      ],
    );
  }
}