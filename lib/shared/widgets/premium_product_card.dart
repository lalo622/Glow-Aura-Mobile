import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:glow_aura/core/theme/app_theme.dart';
import 'package:glow_aura/features/product/data/models/product_model.dart';
import 'package:glow_aura/shared/widgets/product_image.dart';

enum ProductCardMode { horizontal, grid }

/// Image-dominant product card — "beauty store cao cấp" style.
/// Image fills the entire card; brand/name/price sit on a soft scrim at
/// the bottom edge so the photo stays the hero, not a white card frame.
class PremiumProductCard extends StatefulWidget {
  final ProductModel product;
  final ProductCardMode mode;

  const PremiumProductCard({
    super.key,
    required this.product,
    this.mode = ProductCardMode.grid,
  });

  @override
  State<PremiumProductCard> createState() => _PremiumProductCardState();
}

class _PremiumProductCardState extends State<PremiumProductCard> {
  bool _pressed = false;
  bool _wishlisted = false;

  String _formatPrice(double price) {
    final thousands = (price / 1000).toStringAsFixed(0);
    final formatted = thousands.replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
    return '$formatted.000đ';
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final isHorizontal = widget.mode == ProductCardMode.horizontal;
    const cardHeight = 240.0;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () => context.go('/product-detail/${product.id}'),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: Container(
          width: isHorizontal ? 168 : null,
          height: cardHeight,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ProductImageWidget(
                imageUrl: product.imageUrl,
                width: double.infinity,
                height: double.infinity,
              ),

              // Bottom scrim so text is legible over any product photo.
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 110,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.62),
                      ],
                    ),
                  ),
                ),
              ),

              if (product.hasDiscount)
                Positioned(
                  top: AppColors.s12,
                  left: AppColors.s12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text('-${product.discountPercent}%',
                        style: AppTextStyles.label(color: AppColors.error)),
                  ),
                ),

              // Wishlist — scale-pop animation on tap.
              Positioned(
                top: AppColors.s12,
                right: AppColors.s12,
                child: GestureDetector(
                  onTap: () => setState(() => _wishlisted = !_wishlisted),
                  child: Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.25),
                      shape: BoxShape.circle,
                    ),
                    child: AnimatedScale(
                      scale: _wishlisted ? 1.15 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      child: Icon(
                        _wishlisted ? Icons.favorite : Icons.favorite_border,
                        size: 16,
                        color: _wishlisted ? AppColors.primary : Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              // Text block, pinned to bottom of card.
              Positioned(
                left: AppColors.s12,
                right: AppColors.s12,
                bottom: AppColors.s12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      product.brand.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.label(color: Colors.white70)
                          .copyWith(letterSpacing: 0.6),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.title(color: Colors.white),
                    ),
                    const SizedBox(height: AppColors.s4),
                    Row(
                      children: [
                        Text(
                          _formatPrice(product.displayPrice),
                          style: AppTextStyles.title(color: Colors.white)
                              .copyWith(fontWeight: FontWeight.w700),
                        ),
                        if (product.hasDiscount) ...[
                          const SizedBox(width: AppColors.s8),
                          Text(
                            _formatPrice(product.price),
                            style: AppTextStyles.caption(color: Colors.white60)
                                .copyWith(
                                    decoration: TextDecoration.lineThrough),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}