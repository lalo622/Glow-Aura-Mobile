import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:glow_aura/core/theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  final _pages = const [
    _OnboardingData(
      title: 'Chào mừng bạn đến\nvới Glow Aura',
      subtitle: '"Illuminate your beauty"',
      buttonLabel: 'Bắt đầu ngay',
      isFirst: true,
    ),
    _OnboardingData(
      title: 'Phân tích da thông minh với AI',
      subtitle:
          'Công nghệ AI tiên tiến giúp nhận diện các vấn đề về da như mụn, lỗ chân lông và nếp nhăn chỉ trong vài giây với độ chính xác cao.',
      buttonLabel: 'Tiếp tục',
      isFirst: false,
    ),
  ];

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (i) => setState(() => _currentPage = i),
        itemCount: _pages.length,
        itemBuilder: (_, i) => _OnboardingPage(
          data: _pages[i],
          currentPage: _currentPage,
          totalPages: _pages.length,
          onNext: _next,
          onSkip: () => context.go('/login'),
        ),
      ),
    );
  }
}

// ── Page ──────────────────────────────────────────────────────────────────────
class _OnboardingPage extends StatelessWidget {
  final _OnboardingData data;
  final int currentPage, totalPages;
  final VoidCallback onNext, onSkip;

  const _OnboardingPage({
    required this.data,
    required this.currentPage,
    required this.totalPages,
    required this.onNext,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Column(
        children: [
          // ── Top bar ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppColors.s16, vertical: AppColors.s12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Glow Aura', style: AppTextStyles.title(color: AppColors.primary)),
                TextButton(
                  onPressed: onSkip,
                  child: Text('Bỏ qua',
                      style: AppTextStyles.body(color: AppColors.textSecondary)),
                ),
              ],
            ),
          ),

          // ── Hero image ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppColors.s16),
            child: SizedBox(
              height: screenHeight * 0.38,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: data.isFirst ? const _GradientHero() : const _AiScanHero(),
              ),
            ),
          ),
          const SizedBox(height: AppColors.s24),

          // ── Content ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppColors.s24),
            child: Column(
              children: [
                Text(data.title,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.display()),
                const SizedBox(height: AppColors.s12),
                Text(data.subtitle,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body()),
                if (!data.isFirst) ...[
                  const SizedBox(height: AppColors.s16),
                  const _FeatureRow(),
                ],
              ],
            ),
          ),

          const Spacer(),

          // ── Dot indicators ────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              totalPages,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: i == currentPage ? 20 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: i == currentPage
                      ? AppColors.primary
                      : AppColors.primaryTint,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppColors.s16),

          // ── CTA Button ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppColors.s24),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: onNext,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(data.buttonLabel),
                    const SizedBox(width: AppColors.s8),
                    const Icon(Icons.arrow_forward,
                        size: 18, color: Colors.white),
                  ],
                ),
              ),
            ),
          ),

          if (data.isFirst) ...[
            const SizedBox(height: AppColors.s12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Bạn đã có tài khoản? ',
                    style: AppTextStyles.body()),
                GestureDetector(
                  onTap: () => context.go('/login'),
                  child: Text('Đăng nhập',
                      style: AppTextStyles.body(color: AppColors.primary)
                          .copyWith(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppColors.s32),
        ],
      ),
    );
  }
}

// ── Hero widgets ──────────────────────────────────────────────────────────────
class _GradientHero extends StatelessWidget {
  const _GradientHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF7D0E0),
            Color(0xFFC0356B),
            Color(0xFF9C2254),
            Color(0xFFF7D0E0),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _SheenPainter())),
          ...List.generate(8, (i) {
            final pos = [
              [0.15, 0.2], [0.8, 0.15], [0.25, 0.7], [0.75, 0.75],
              [0.5, 0.1],  [0.1, 0.5],  [0.9, 0.45], [0.6, 0.85],
            ];
            return Align(
              alignment: Alignment(pos[i][0] * 2 - 1, pos[i][1] * 2 - 1),
              child: Container(
                width: 4, height: 4,
                decoration: const BoxDecoration(
                    color: Colors.white54, shape: BoxShape.circle),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _SheenPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.15);
    final path = Path()
      ..moveTo(size.width * 0.3, 0)
      ..lineTo(size.width * 0.6, 0)
      ..lineTo(size.width * 0.3, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(_) => false;
}

class _AiScanHero extends StatelessWidget {
  const _AiScanHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF2E5C5A),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 160, height: 200,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(80),
            ),
          ),
          Container(width: 180, height: 220,
            decoration: BoxDecoration(shape: BoxShape.circle,
              border: Border.all(color: Colors.white30, width: 1.5))),
          Positioned(
            bottom: 40, left: 32, right: 32,
            child: Column(
              children: [
                Text('ĐANG PHÂN TÍCH',
                    style: AppTextStyles.label(color: Colors.white60)),
                const SizedBox(height: AppColors.s8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: const LinearProgressIndicator(
                    value: 0.67,
                    backgroundColor: Colors.white12,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text('67%',
                      style: AppTextStyles.caption(color: Colors.white70)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow();
  static const features = ['MỤN & SEO', 'LỖ CHÂN LÔNG', 'NẾP NHĂN'];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: features.map((f) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppColors.s8),
        child: Column(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: AppColors.primarySubtle,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryTint),
              ),
              child: const Center(
                child: Text('✦',
                    style: TextStyle(fontSize: 18, color: AppColors.primary)),
              ),
            ),
            const SizedBox(height: AppColors.s4),
            Text(f, style: AppTextStyles.label()),
          ],
        ),
      )).toList(),
    );
  }
}

// ── Data model ────────────────────────────────────────────────────────────────
class _OnboardingData {
  final String title, subtitle, buttonLabel;
  final bool isFirst;
  const _OnboardingData({
    required this.title, required this.subtitle,
    required this.buttonLabel, required this.isFirst,
  });
}