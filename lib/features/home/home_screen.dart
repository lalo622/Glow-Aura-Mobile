import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:glow_aura/core/theme/app_theme.dart';
import 'package:glow_aura/shared/widgets/main_scaffold.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:glow_aura/features/auth/auth_viewmodel.dart';
import 'package:glow_aura/features/product/models/product_model.dart';
import 'package:glow_aura/features/product/product_viewmodel.dart';
import 'dart:async';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        ref.read(productViewModelProvider.notifier).init());
  }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productViewModelProvider);

    return MainScaffold(
      currentIndex: 0,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TopBar(),
              _HeroBanner(),
              _ScanCtaCard(),
              _CategoriesSection(),

              // ── Best sellers (6 sản phẩm đầu) ────────────────────────
              _ProductSection(
                title: 'Sản phẩm nổi bật',
                subtitle: 'Được yêu thích nhất',
                tag: 'HOT',
                tagColor: AppColors.error,
                products: productState.products.take(6).toList(),
                isLoading: productState.isLoading,
              ),

              _HealthScoreCard(),
              _RecentAnalysesSection(),

              // ── New arrivals (6 sản phẩm tiếp theo) ──────────────────
              _ProductSection(
                title: 'Sản phẩm mới',
                subtitle: 'Bộ sưu tập mới nhất',
                tag: 'MỚI',
                tagColor: AppColors.success,
                products: productState.products.skip(6).take(6).toList(),
                isLoading: productState.isLoading,
              ),

              _SaleBanner(),
              _TipCard(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Shared: Product image (hỗ trợ base64 + network + placeholder) ─────────────
class ProductImageWidget extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const ProductImageWidget({
    super.key,
    this.imageUrl,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _placeholder();
    }

    // Base64 image
    if (imageUrl!.startsWith('data:image')) {
      try {
        final base64Str = imageUrl!.split(',').last;
        final Uint8List bytes = base64Decode(base64Str);
        return ClipRRect(
          borderRadius: borderRadius ?? BorderRadius.zero,
          child: Image.memory(
            bytes,
            width: width,
            height: height,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _placeholder(),
          ),
        );
      } catch (_) {
        return _placeholder();
      }
    }

    // Network image
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: Image.network(
        imageUrl!,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.primarySubtle,
        borderRadius: borderRadius,
      ),
      child: Center(
        child: Icon(Icons.inventory_2_outlined,
            size: (height ?? 120) * 0.4,
            color: AppColors.primaryTint),
      ),
    );
  }
}

// ── Top bar ───────────────────────────────────────────────────────────────────
class _TopBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authViewModelProvider).user;
    final firstName = user?.fullName.split(' ').last ?? '---';
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppColors.s16, vertical: AppColors.s12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
                color: AppColors.primaryTint, shape: BoxShape.circle),
            child: const Icon(Icons.person_outline,
                color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: AppColors.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Xin chào, $firstName ',
                    style: AppTextStyles.title()),
                Text('Hôm nay làn da của bạn thế nào?',
                    style: AppTextStyles.caption()),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search, color: AppColors.textSecondary),
          ),
          Stack(
            children: [
              IconButton(
                onPressed: () => context.go('/cart'),
                icon: const Icon(Icons.shopping_bag_outlined,
                    color: AppColors.textSecondary),
              ),
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child:
                        Text('2', style: AppTextStyles.label(color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Hero banner ───────────────────────────────────────────────────────────────
class _HeroBanner extends StatefulWidget {
  @override
  State<_HeroBanner> createState() => _HeroBannerState();
}

class _HeroBannerState extends State<_HeroBanner> {
  final _pageController = PageController();
  int _current = 0;
  Timer? _timer;

  final _banners = const [
    _BannerData(
      imagePath: 'assets/images/home_hero_1.jpg',
      title: 'Tỏa sáng rạng ngời\ncùng Glow Aura',
      subtitle: 'Khám phá bộ sưu tập dưỡng da cao cấp',
      buttonLabel: 'MUA SẮM NGAY',
      gradient: LinearGradient(
        colors: [Color(0xFF6B1E3E), Color(0xFFC0356B)],
      ),
    ),
    _BannerData(
      imagePath: 'assets/images/home_hero_2.jpg',
      title: 'Đang Sale Sốc\nĐến 50%',
      subtitle: 'Ưu đãi có hạn — Mua ngay hôm nay',
      buttonLabel: 'XEM ƯU ĐÃI',
      gradient: LinearGradient(
        colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
      ),
    ),
    _BannerData(
      imagePath: 'assets/images/home_hero_3.jpg',
      title: 'Bộ sưu tập\nMùa Thu 2024',
      subtitle: 'Sản phẩm dưỡng da thiên nhiên mới nhất',
      buttonLabel: 'KHÁM PHÁ NGAY',
      gradient: LinearGradient(
        colors: [Color(0xFF4A148C), Color(0xFF880E4F)],
      ),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      final next = (_current + 1) % _banners.length;
      _pageController.animateToPage(next,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _current = i),
            itemCount: _banners.length,
            itemBuilder: (_, i) => _BannerItem(data: _banners[i]),
          ),
        ),
        const SizedBox(height: AppColors.s8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _banners.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: i == _current ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: i == _current
                    ? AppColors.primary
                    : AppColors.primaryTint,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BannerItem extends StatelessWidget {
  final _BannerData data;
  const _BannerItem({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppColors.s16),
      decoration:
          BoxDecoration(borderRadius: BorderRadius.circular(20)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              data.imagePath,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Container(decoration: BoxDecoration(gradient: data.gradient)),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.55),
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
                  Text(
                    data.title,
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: AppColors.s8),
                  Text(data.subtitle,
                      style: AppTextStyles.caption(color: Colors.white70)),
                  const SizedBox(height: AppColors.s12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppColors.s12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(data.buttonLabel,
                        style: AppTextStyles.label(color: AppColors.primary)),
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

// ── Scan CTA card ─────────────────────────────────────────────────────────────
class _ScanCtaCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppColors.s16),
      padding: const EdgeInsets.all(AppColors.s16),
      decoration: BoxDecoration(
        color: AppColors.primarySubtle,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryTint),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
                color: AppColors.primary, shape: BoxShape.circle),
            child: const Icon(Icons.document_scanner_outlined,
                color: Colors.white, size: 24),
          ),
          const SizedBox(width: AppColors.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Phân tích da miễn phí',
                    style: AppTextStyles.title()),
                Text('Nhận gợi ý sản phẩm phù hợp với làn da bạn',
                    style: AppTextStyles.caption()),
              ],
            ),
          ),
          const SizedBox(width: AppColors.s8),
          GestureDetector(
            onTap: () => context.go('/scan-guide'),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppColors.s12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child:
                  Text('Quét ngay', style: AppTextStyles.label(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Categories ────────────────────────────────────────────────────────────────
class _CategoriesSection extends StatelessWidget {
  static const _categories = [
    _CategoryData(icon: Icons.face_outlined, label: 'Dưỡng da'),
    _CategoryData(icon: Icons.brush_outlined, label: 'Trang điểm'),
    _CategoryData(icon: Icons.remove_red_eye_outlined, label: 'Mắt'),
    _CategoryData(icon: Icons.local_offer_outlined, label: 'Sale'),
    _CategoryData(icon: Icons.new_releases_outlined, label: 'Mới'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppColors.s16),
          child: Text('Danh mục', style: AppTextStyles.heading()),
        ),
        const SizedBox(height: AppColors.s12),
        SizedBox(
          height: 88,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding:
                const EdgeInsets.symmetric(horizontal: AppColors.s16),
            itemCount: _categories.length,
            separatorBuilder: (_, __) =>
                const SizedBox(width: AppColors.s12),
            itemBuilder: (_, i) => _CategoryItem(data: _categories[i]),
          ),
        ),
        const SizedBox(height: AppColors.s24),
      ],
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final _CategoryData data;
  const _CategoryItem({required this.data});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/products'),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primarySubtle,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryTint),
            ),
            child: Icon(data.icon, color: AppColors.primary, size: 26),
          ),
          const SizedBox(height: AppColors.s4),
          Text(data.label, style: AppTextStyles.caption()),
        ],
      ),
    );
  }
}

// ── Product section (dùng ProductModel thật từ BE) ────────────────────────────
class _ProductSection extends StatelessWidget {
  final String title, subtitle, tag;
  final Color tagColor;
  final List<ProductModel> products;
  final bool isLoading;

  const _ProductSection({
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.tagColor,
    required this.products,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppColors.s16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(title, style: AppTextStyles.heading()),
                        const SizedBox(width: AppColors.s8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: tagColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(tag,
                              style: AppTextStyles.label(color: Colors.white)),
                        ),
                      ],
                    ),
                    Text(subtitle, style: AppTextStyles.caption()),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => context.go('/products'),
                style: TextButton.styleFrom(
                    padding: EdgeInsets.zero, minimumSize: Size.zero),
                child: Text('Xem tất cả',
                    style: AppTextStyles.body(color: AppColors.primary)),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppColors.s12),
        SizedBox(
          height: 220,
          child: isLoading
              ? _buildSkeletonList()
              : products.isEmpty
                  ? const Center(child: Text('Không có sản phẩm'))
                  : ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppColors.s16),
                      itemCount: products.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(width: AppColors.s12),
                      itemBuilder: (_, i) =>
                          _HomeProductCard(product: products[i]),
                    ),
        ),
        const SizedBox(height: AppColors.s24),
      ],
    );
  }

  Widget _buildSkeletonList() {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding:
          const EdgeInsets.symmetric(horizontal: AppColors.s16),
      itemCount: 3,
      separatorBuilder: (_, __) =>
          const SizedBox(width: AppColors.s12),
      itemBuilder: (_, __) => _HomeSkeletonCard(),
    );
  }
}

// ── Home product card (horizontal list, 150×220) ──────────────────────────────
class _HomeProductCard extends StatelessWidget {
  final ProductModel product;
  const _HomeProductCard({required this.product});

  String _formatPrice(double price) {
    final thousands = (price / 1000).toStringAsFixed(0);
    final formatted = thousands.replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
    return '$formatted.000đ';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/product-detail/${product.id}'),
      child: Container(
        width: 150,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image ─────────────────────────────────────────────────
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: ProductImageWidget(
                    imageUrl: product.imageUrl,
                    width: 150,
                    height: 120,
                  ),
                ),
                // Wishlist
                Positioned(
                  top: AppColors.s8,
                  right: AppColors.s8,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                        color: AppColors.surface, shape: BoxShape.circle),
                    child: const Icon(Icons.favorite_border,
                        size: 14, color: AppColors.primary),
                  ),
                ),
                // Sale badge
                if (product.hasDiscount)
                  Positioned(
                    top: AppColors.s8,
                    left: AppColors.s8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text('-${product.discountPercent}%',
                          style:
                              AppTextStyles.label(color: Colors.white)),
                    ),
                  ),
                // Flash Sale badge
                if (product.isFlashSale)
                  Positioned(
                    bottom: AppColors.s4,
                    left: AppColors.s8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.flash_on,
                              size: 10, color: Colors.white),
                          Text('Flash',
                              style:
                                  AppTextStyles.label(color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            // ── Info ──────────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppColors.s8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.brand, style: AppTextStyles.label()),
                    const SizedBox(height: 2),
                    Text(product.name,
                        style: AppTextStyles.body(
                            color: AppColors.textPrimary),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const Spacer(),
                    Text(
                      _formatPrice(product.displayPrice),
                      style: AppTextStyles.body(color: AppColors.primary)
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                    if (product.hasDiscount)
                      Text(
                        _formatPrice(product.price),
                        style: AppTextStyles.caption().copyWith(
                            decoration: TextDecoration.lineThrough),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Skeleton card ──────────────────────────────────────────────────────────────
class _HomeSkeletonCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            height: 120,
            decoration: const BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppColors.s8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 10, width: 60, color: AppColors.border),
                const SizedBox(height: 6),
                Container(
                    height: 12,
                    width: double.infinity,
                    color: AppColors.border),
                const SizedBox(height: 4),
                Container(height: 12, width: 80, color: AppColors.border),
                const SizedBox(height: 8),
                Container(height: 14, width: 70, color: AppColors.border),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Health score card ─────────────────────────────────────────────────────────
class _HealthScoreCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppColors.s16),
      child: Container(
        padding: const EdgeInsets.all(AppColors.s16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 72,
              height: 72,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const SizedBox(
                    width: 72,
                    height: 72,
                    child: CircularProgressIndicator(
                      value: 0.85,
                      strokeWidth: 6,
                      backgroundColor: AppColors.primaryTint,
                      valueColor:  AlwaysStoppedAnimation<Color>(
                          AppColors.primary),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('85',
                          style: GoogleFonts.manrope(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary)),
                      Text('/100', style: AppTextStyles.label()),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppColors.s16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CHỈ SỐ SỨC KHỎE DA',
                      style: AppTextStyles.label()),
                  const SizedBox(height: AppColors.s4),
                  Row(children: [
                    const Icon(Icons.trending_up,
                        size: 14, color: AppColors.success),
                    const SizedBox(width: 4),
                    Text('+5% so với tuần trước',
                        style: AppTextStyles.caption(
                            color: AppColors.success)),
                  ]),
                  const SizedBox(height: AppColors.s8),
                  GestureDetector(
                    onTap: () => context.go('/scan-result'),
                    child: Text('Xem chi tiết →',
                        style:
                            AppTextStyles.body(color: AppColors.primary)),
                  ),
                ],
              ),
            ),
            const Icon(Icons.favorite_border,
                color: AppColors.primary, size: 22),
          ],
        ),
      ),
    );
  }
}

// ── Recent analyses ───────────────────────────────────────────────────────────
class _RecentAnalysesSection extends StatelessWidget {
  static const _items = [
    _AnalysisData(
      iconBg: Color(0xFFE8F0FB),
      iconColor: Color(0xFF3B7DD8),
      icon: Icons.water_drop_outlined,
      title: 'Độ ẩm & Dầu',
      time: 'Hôm nay, 08:30 AM',
      status: 'Tốt',
      statusColor: AppColors.success,
      statusIcon: Icons.check_circle_outline,
    ),
    _AnalysisData(
      iconBg: Color(0xFFFFF3E8),
      iconColor: Color(0xFFD4821C),
      icon: Icons.blur_on,
      title: 'Lỗ chân lông',
      time: 'Hôm qua, 09:15 PM',
      status: 'Cần chú ý',
      statusColor: AppColors.warning,
      statusIcon: Icons.warning_amber_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppColors.s16, AppColors.s24, AppColors.s16, AppColors.s8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Phân tích gần đây', style: AppTextStyles.heading()),
              TextButton(
                onPressed: () => context.go('/history'),
                style: TextButton.styleFrom(
                    padding: EdgeInsets.zero, minimumSize: Size.zero),
                child: Text('Xem tất cả',
                    style: AppTextStyles.body(color: AppColors.primary)),
              ),
            ],
          ),
          const SizedBox(height: AppColors.s12),
          ..._items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: AppColors.s8),
                child: _AnalysisCard(data: item),
              )),
        ],
      ),
    );
  }
}

class _AnalysisCard extends StatelessWidget {
  final _AnalysisData data;
  const _AnalysisCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppColors.s12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
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
                Text(data.title, style: AppTextStyles.title()),
                const SizedBox(height: AppColors.s4),
                Text(data.time, style: AppTextStyles.caption()),
              ],
            ),
          ),
          Row(children: [
            Icon(data.statusIcon, color: data.statusColor, size: 14),
            const SizedBox(width: 4),
            Text(data.status,
                style: AppTextStyles.caption(color: data.statusColor)),
          ]),
        ],
      ),
    );
  }
}

// ── Sale banner ───────────────────────────────────────────────────────────────
class _SaleBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/products'),
      child: Container(
        margin: const EdgeInsets.all(AppColors.s16),
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFF6B1E3E), Color(0xFFC0356B)],
          ),
        ),
        child: Row(
          children: [
            const SizedBox(width: AppColors.s24),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ĐANG SALE SỐC',
                      style: AppTextStyles.label(color: Colors.white70)),
                  const SizedBox(height: AppColors.s4),
                  Text('Giảm đến 50%\ncho sản phẩm chọn lọc',
                      style: GoogleFonts.manrope(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.3,
                      )),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('50%',
                    style: GoogleFonts.manrope(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    )),
                Text('OFF',
                    style: AppTextStyles.label(color: Colors.white70)),
              ],
            ),
            const SizedBox(width: AppColors.s24),
          ],
        ),
      ),
    );
  }
}

// ── Tip card ──────────────────────────────────────────────────────────────────
class _TipCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppColors.s16),
      padding: const EdgeInsets.all(AppColors.s16),
      decoration: BoxDecoration(
        color: AppColors.accentTint,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDD9B0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
                color: AppColors.accentGold, shape: BoxShape.circle),
            child: const Icon(Icons.lightbulb_outline,
                color: Colors.white, size: 18),
          ),
          const SizedBox(width: AppColors.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mẹo nhỏ cho bạn',
                    style: AppTextStyles.title(color: AppColors.accentGold)),
                const SizedBox(height: AppColors.s4),
                Text(
                  'Đừng quên thoa kem chống nắng ngay cả khi trời nhiều mây để bảo vệ làn da nhé!',
                  style:
                      AppTextStyles.body(color: const Color(0xFF7A5A1A)),
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
class _BannerData {
  final String title, subtitle, buttonLabel, imagePath;
  final LinearGradient gradient;
  const _BannerData({
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.imagePath,
    required this.gradient,
  });
}

class _CategoryData {
  final IconData icon;
  final String label;
  const _CategoryData({required this.icon, required this.label});
}

class _AnalysisData {
  final Color iconBg, iconColor, statusColor;
  final IconData icon, statusIcon;
  final String title, time, status;
  const _AnalysisData({
    required this.iconBg,
    required this.iconColor,
    required this.icon,
    required this.title,
    required this.time,
    required this.status,
    required this.statusColor,
    required this.statusIcon,
  });
}