import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:glow_aura/core/theme/app_theme.dart';
import 'package:glow_aura/shared/widgets/score_ring.dart';

/// Immersive hero block for Home.
///
/// Replaces the flat PageView banner. Structure:
///   - Full-bleed image (or gradient fallback) ~62% of hero height
///   - Editorial headline + greeting floating over the image
///   - A "floating" score card that overlaps the image/content boundary,
///     casting a soft shadow — gives layered depth (Apple Health feel)
///     instead of a flat banner.
class HomeHero extends StatelessWidget {
  final String firstName;
  final int score;
  final double scoreDelta;

  const HomeHero({
    super.key,
    required this.firstName,
    required this.score,
    required this.scoreDelta,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppColors.s8),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── Image block ───────────────────────────────────────────
          Container(
            height: 280,
            width: double.infinity,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/images/home_hero_face.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF2B0F1C), Color(0xFFC0356B)],
                      ),
                    ),
                  ),
                ),
                // Subtle top-to-bottom darken so status-bar text + headline
                // stay legible on any photo.
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.35),
                        Colors.black.withValues(alpha: 0.05),
                        Colors.black.withValues(alpha: 0.55),
                      ],
                      stops: const [0.0, 0.4, 1.0],
                    ),
                  ),
                ),
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        AppColors.s24, AppColors.s12, AppColors.s24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                firstName.isNotEmpty
                                    ? 'Xin chào, $firstName'
                                    : 'Xin chào',
                                style: AppTextStyles.body(color: Colors.white70),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              onPressed: () => context.go('/cart'),
                              icon: const Icon(Icons.shopping_bag_outlined,
                                  color: Colors.white, size: 22),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppColors.s8),
                        Text(
                          'Làn da của bạn,\nhôm nay thế nào?',
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 30,
                            fontWeight: FontWeight.w600,
                            height: 1.15,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Floating score card — overlaps hero bottom edge ───────
          Positioned(
            left: AppColors.s16,
            right: AppColors.s16,
            bottom: -54,
            child: _FloatingScoreCard(score: score, delta: scoreDelta),
          ),
        ],
      ),
    );
  }
}

class _FloatingScoreCard extends StatelessWidget {
  final int score;
  final double delta;
  const _FloatingScoreCard({required this.score, required this.delta});

  @override
  Widget build(BuildContext context) {
    final isUp = delta >= 0;
    return Container(
      padding: const EdgeInsets.all(AppColors.s16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          ScoreRing(score: score, size: 64),
          const SizedBox(width: AppColors.s16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Chỉ số sức khỏe da',
                    style: AppTextStyles.label(color: AppColors.textTertiary)),
                const SizedBox(height: AppColors.s4),
                Row(
                  children: [
                    Icon(
                      isUp ? Icons.trending_up : Icons.trending_down,
                      size: 14,
                      color: isUp ? AppColors.success : AppColors.error,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${isUp ? '+' : ''}${delta.toStringAsFixed(0)}% so với tuần trước',
                      style: AppTextStyles.caption(
                          color: isUp ? AppColors.success : AppColors.error),
                    ),
                  ],
                ),
                const SizedBox(height: AppColors.s8),
                GestureDetector(
                  onTap: () => context.go('/scan-result'),
                  child: Text('Xem chi tiết',
                      style: AppTextStyles.body(color: AppColors.primary)
                          .copyWith(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          // Scan FAB-style shortcut, secondary to the bottom-nav FAB but
          // gives immediate access from the hero.
          GestureDetector(
            onTap: () => context.go('/scan-guide'),
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.document_scanner_outlined,
                  color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}