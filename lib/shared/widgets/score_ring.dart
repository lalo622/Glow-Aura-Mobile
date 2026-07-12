import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:glow_aura/core/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

/// Premium circular score ring with a gradient sweep and animated fill.
/// Used as the hero element on Home (floating score card) and Profile.
class ScoreRing extends StatefulWidget {
  final int score; // 0-100
  final double size;
  final String label;

  const ScoreRing({
    super.key,
    required this.score,
    this.size = 88,
    this.label = '/100',
  });

  @override
  State<ScoreRing> createState() => _ScoreRingState();
}

class _ScoreRingState extends State<ScoreRing> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final animatedValue =
            Curves.easeOutCubic.transform(_controller.value) * widget.score;
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _RingPainter(value: animatedValue / 100),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    animatedValue.round().toString(),
                    style: GoogleFonts.manrope(
                      fontSize: widget.size * 0.28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 1.0,
                    ),
                  ),
                  Text(widget.label,
                      style: AppTextStyles.caption(color: AppColors.textTertiary)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  final double value; // 0..1
  _RingPainter({required this.value});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 6;
    const strokeWidth = 7.0;

    final bgPaint = Paint()
      ..color = AppColors.primaryTint
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    const gradient = SweepGradient(
      startAngle: -math.pi / 2,
      endAngle: -math.pi / 2 + 2 * math.pi,
      colors:  [AppColors.accentGold, AppColors.primary],
      stops:  [0.0, 1.0],
    );

    final fgPaint = Paint()
      ..shader = gradient.createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweep = 2 * math.pi * value;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweep,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.value != value;
}