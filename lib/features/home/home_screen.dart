import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:glow_aura/core/theme/app_theme.dart';
import 'package:glow_aura/shared/widgets/main_scaffold.dart';
import 'package:glow_aura/shared/widgets/category_chip.dart';
import 'package:glow_aura/shared/widgets/section_header.dart';
import 'package:glow_aura/shared/widgets/insight_card.dart';
import 'package:glow_aura/shared/widgets/premium_product_card.dart';
import 'package:glow_aura/features/auth/auth_viewmodel.dart';
import 'package:glow_aura/features/home/widgets/home_hero.dart';
import 'package:glow_aura/features/product/data/models/product_model.dart';
import 'package:glow_aura/features/product/product_viewmodel.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(productViewModelProvider.notifier).init());
  }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productViewModelProvider);
    final user = ref.watch(authViewModelProvider).user;
    final firstName = user?.fullName.split(' ').last ?? '';

    return MainScaffold(
      currentIndex: 0,
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HomeHero(firstName: firstName, score: 85, scoreDelta: 5),
            const SizedBox(height: 70),

            const _EntranceFade(
              delayMs: 0,
              child:  Padding(
                padding: EdgeInsets.symmetric(horizontal: AppColors.s16),
                child: _CategoriesRow(),
              ),
            ),
            const SizedBox(height: AppColors.s32),

            _EntranceFade(
              delayMs: 60,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppColors.s16),
                child: SectionHeader(
                  title: 'Gợi ý cho bạn',
                  subtitle: 'Dựa trên phân tích da gần nhất',
                  actionLabel: 'Xem tất cả',
                  onActionTap: () => context.go('/products'),
                ),
              ),
            ),
            const SizedBox(height: AppColors.s16),
            _EntranceFade(
              delayMs: 100,
              child: _ProductRow(
                products: productState.products.take(6).toList(),
                isLoading: productState.isLoading,
              ),
            ),
            const SizedBox(height: AppColors.s32),

            const _EntranceFade(
              delayMs: 140,
              child:  Padding(
                padding: EdgeInsets.symmetric(horizontal: AppColors.s16),
                child: SectionHeader(title: 'Phân tích gần đây'),
              ),
            ),
            const SizedBox(height: AppColors.s16),
            const _EntranceFade(delayMs: 180, child:  _InsightRow()),
            const SizedBox(height: AppColors.s32),

            const _EntranceFade(delayMs: 220, child:  _EditorialPromo()),
            const SizedBox(height: AppColors.s32),

            _EntranceFade(
              delayMs: 260,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppColors.s16),
                child: SectionHeader(
                  title: 'Mới ra mắt',
                  actionLabel: 'Xem tất cả',
                  onActionTap: () => context.go('/products'),
                ),
              ),
            ),
            const SizedBox(height: AppColors.s16),
            _EntranceFade(
              delayMs: 300,
              child: _ProductRow(
                products: productState.products.skip(6).take(6).toList(),
                isLoading: productState.isLoading,
              ),
            ),

            const SizedBox(height: 110),
          ],
        ),
      ),
    );
  }
}

class _EntranceFade extends StatefulWidget {
  final Widget child;
  final int delayMs;
  const _EntranceFade({required this.child, this.delayMs = 0});

  @override
  State<_EntranceFade> createState() => _EntranceFadeState();
}

class _EntranceFadeState extends State<_EntranceFade>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) return widget.child;
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

// ── Categories ────────────────────────────────────────────────────────────
class _CategoriesRow extends StatelessWidget {
  const _CategoriesRow();
  static const _categories = ['Dưỡng da', 'Trang điểm', 'Mắt', 'Sale', 'Mới'];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppColors.s8),
        itemBuilder: (_, i) => CategoryChip(
          label: _categories[i],
          onTap: () => context.go('/products'),
        ),
      ),
    );
  }
}

// ── Product row ───────────────────────────────────────────────────────────
class _ProductRow extends StatelessWidget {
  final List<ProductModel> products;
  final bool isLoading;
  const _ProductRow({required this.products, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      child: isLoading
          ? ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppColors.s16),
              itemCount: 3,
              separatorBuilder: (_, __) => const SizedBox(width: AppColors.s12),
              itemBuilder: (_, __) => const _ProductSkeleton(),
            )
          : products.isEmpty
              ? Center(
                  child: Text('Chưa có sản phẩm',
                      style: AppTextStyles.caption()))
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppColors.s16),
                  itemCount: products.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: AppColors.s12),
                  itemBuilder: (_, i) => PremiumProductCard(
                    product: products[i],
                    mode: ProductCardMode.horizontal,
                  ),
                ),
    );
  }
}

class _ProductSkeleton extends StatelessWidget {
  const _ProductSkeleton();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 168,
      height: 240,
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}

// ── Insight row ───────────────────────────────────────────────────────────
class _InsightRow extends StatelessWidget {
  const _InsightRow();

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        icon: Icons.water_drop_outlined,
        title: 'Độ ẩm & Dầu',
        time: 'Hôm nay, 08:30',
        status: 'Tốt',
        color: AppColors.success,
      ),
      (
        icon: Icons.blur_on,
        title: 'Lỗ chân lông',
        time: 'Hôm qua, 21:15',
        status: 'Cần chú ý',
        color: AppColors.warning,
      ),
      (
        icon: Icons.wb_sunny_outlined,
        title: 'Bảo vệ da',
        time: '2 ngày trước',
        status: 'Tốt',
        color: AppColors.success,
      ),
    ];

    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppColors.s16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppColors.s12),
        itemBuilder: (_, i) {
          final it = items[i];
          return InsightCard(
            icon: it.icon,
            title: it.title,
            time: it.time,
            status: it.status,
            statusColor: it.color,
          );
        },
      ),
    );
  }
}

// ── Editorial promo — landing-page style block instead of a flat banner ──
class _EditorialPromo extends StatelessWidget {
  const _EditorialPromo();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/products'),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppColors.s16),
        height: 180,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(24)),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/home_promo.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF3A0E22), Color(0xFF6B1E3E)],
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.black.withValues(alpha: 0.55),
                    Colors.black.withValues(alpha: 0.1),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppColors.s24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Bộ sưu tập\nMùa Thu',
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        height: 1.15,
                        color: Colors.white,
                      )),
                  const SizedBox(height: AppColors.s8),
                  Text('Giảm đến 30% — sản phẩm chọn lọc',
                      style: AppTextStyles.body(color: Colors.white70)),
                  const SizedBox(height: AppColors.s16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppColors.s16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('Khám phá ngay',
                        style: AppTextStyles.body(color: AppColors.primary)
                            .copyWith(fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}