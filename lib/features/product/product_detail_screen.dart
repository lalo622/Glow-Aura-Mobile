import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:glow_aura/core/theme/app_theme.dart';
import 'models/product_model.dart';
import 'product_viewmodel.dart';
import 'package:glow_aura/shared/widgets/product_image.dart';


class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref
        .read(productViewModelProvider.notifier)
        .loadProductDetail(widget.productId));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : state.errorMessage != null
                ? _ErrorView(
                    message: state.errorMessage!,
                    onRetry: () => ref
                        .read(productViewModelProvider.notifier)
                        .loadProductDetail(widget.productId),
                  )
                : state.selectedProduct == null
                    ? const _ErrorView(message: 'Không tìm thấy sản phẩm.')
                    : _buildContent(state.selectedProduct!),
      ),
    );
  }

  Widget _buildContent(ProductModel product) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAppBar(context),
                _buildImage(product),
                Padding(
                  padding: const EdgeInsets.all(AppColors.s16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTags(product),
                      const SizedBox(height: AppColors.s8),
                      Text(product.brand.toUpperCase(),
                          style: AppTextStyles.label()),
                      const SizedBox(height: 4),
                      Text(product.name, style: AppTextStyles.heading()),
                      const SizedBox(height: AppColors.s12),
                      _buildPriceRow(product),
                      const SizedBox(height: AppColors.s8),
                      _buildStockRow(product),
                      const SizedBox(height: AppColors.s24),
                      if (product.description != null &&
                          product.description!.isNotEmpty) ...[
                        Text('Mô tả sản phẩm',
                            style: AppTextStyles.title()),
                        const SizedBox(height: AppColors.s8),
                        Text(product.description!,
                            style: AppTextStyles.body().copyWith(height: 1.6)),
                        const SizedBox(height: AppColors.s24),
                      ],
                      if (product.ingredients != null &&
                          product.ingredients!.isNotEmpty) ...[
                        _buildInfoCard(
                          icon: Icons.science_outlined,
                          title: 'Thành phần',
                          content: product.ingredients!,
                        ),
                        const SizedBox(height: AppColors.s12),
                      ],
                      if (product.usageInstructions != null &&
                          product.usageInstructions!.isNotEmpty) ...[
                        _buildInfoCard(
                          icon: Icons.info_outline,
                          title: 'Hướng dẫn sử dụng',
                          content: product.usageInstructions!,
                        ),
                        const SizedBox(height: AppColors.s12),
                      ],
                      if (product.isExpiringSoon &&
                          product.daysUntilExpiry != null)
                        _buildExpiryWarning(product.daysUntilExpiry!),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        _buildBottomBar(product),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppColors.s16, vertical: AppColors.s12),
      child: Row(
        children: [
          _circleButton(
            icon: Icons.arrow_back,
            onTap: () =>
                context.canPop() ? context.pop() : context.go('/products'),
          ),
          const Spacer(),
          _circleButton(icon: Icons.favorite_border, onTap: () {}),
          const SizedBox(width: AppColors.s8),
          _circleButton(
            icon: Icons.shopping_bag_outlined,
            onTap: () => context.go('/cart'),
          ),
        ],
      ),
    );
  }

  Widget _circleButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, size: 18, color: AppColors.textPrimary),
      ),
    );
  }

  Widget _buildImage(ProductModel product) {
    return AspectRatio(
      aspectRatio: 1,
      child: ProductImageWidget(
        imageUrl: product.imageUrl,
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }

  Widget _buildTags(ProductModel product) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        if (product.isFlashSale)
          _tag('Flash Sale', Colors.orange, Icons.flash_on),
        if (product.hasDiscount)
          _tag('-${product.discountPercent}%', AppColors.error, null),
        if (product.skinType != null && product.skinType!.isNotEmpty)
          _tag(product.skinType!, AppColors.primary, null),
      ],
    );
  }

  Widget _tag(String text, Color color, IconData? icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(text, style: AppTextStyles.caption(color: color)),
        ],
      ),
    );
  }

  Widget _buildPriceRow(ProductModel product) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(_formatPrice(product.displayPrice),
            style: AppTextStyles.display(color: AppColors.primary)),
        if (product.hasDiscount) ...[
          const SizedBox(width: AppColors.s8),
          Text(_formatPrice(product.price),
              style: AppTextStyles.body().copyWith(
                  decoration: TextDecoration.lineThrough,
                  color: AppColors.textTertiary)),
        ],
      ],
    );
  }

  Widget _buildStockRow(ProductModel product) {
    final inStock = product.stockQuantity > 0;
    return Row(
      children: [
        Icon(
          inStock ? Icons.check_circle_outline : Icons.cancel_outlined,
          size: 16,
          color: inStock ? AppColors.success : AppColors.error,
        ),
        const SizedBox(width: 6),
        Text(
          inStock ? 'Còn ${product.stockQuantity} sản phẩm' : 'Hết hàng',
          style: AppTextStyles.caption(
              color: inStock ? AppColors.success : AppColors.error),
        ),
        if (product.volume != null && product.volume!.isNotEmpty) ...[
          const SizedBox(width: AppColors.s12),
          Text('· ${product.volume}', style: AppTextStyles.caption()),
        ],
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppColors.s16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(title, style: AppTextStyles.title()),
            ],
          ),
          const SizedBox(height: AppColors.s8),
          Text(content, style: AppTextStyles.body().copyWith(height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildExpiryWarning(int daysLeft) {
    return Container(
      padding: const EdgeInsets.all(AppColors.s12),
      decoration: BoxDecoration(
        color: AppColors.accentTint,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEDD9B0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.access_time, size: 18, color: AppColors.accentGold),
          const SizedBox(width: AppColors.s8),
          Expanded(
            child: Text(
              'Sản phẩm sắp hết hạn — còn $daysLeft ngày',
              style: AppTextStyles.caption(color: AppColors.accentGold)
                  .copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(ProductModel product) {
    final inStock = product.stockQuantity > 0;
    return Container(
      padding: EdgeInsets.fromLTRB(AppColors.s16, AppColors.s12,
          AppColors.s16, AppColors.s16 + MediaQuery.of(context).padding.bottom),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          _buildQtyControl(product),
          const SizedBox(width: AppColors.s12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: inStock ? () => _addToCart(product) : null,
              icon: const Icon(Icons.shopping_bag_outlined, size: 18),
              label: const Text('Thêm vào giỏ'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQtyControl(ProductModel product) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primarySubtle,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryTint),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _quantity > 1
                ? () => setState(() => _quantity--)
                : null,
            icon: const Icon(Icons.remove, size: 16),
          ),
          Text('$_quantity', style: AppTextStyles.title()),
          IconButton(
            onPressed: _quantity < product.stockQuantity
                ? () => setState(() => _quantity++)
                : null,
            icon: const Icon(Icons.add, size: 16),
          ),
        ],
      ),
    );
  }

  void _addToCart(ProductModel product) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã thêm $_quantity "${product.name}" vào giỏ hàng',
            style: AppTextStyles.body(color: Colors.white)),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(AppColors.s16),
      ),
    );
  }

  String _formatPrice(double price) {
    final formatted = price.toInt().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
    return '$formatted₫';
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  const _ErrorView({required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppColors.s24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 56, color: AppColors.error),
            const SizedBox(height: AppColors.s16),
            Text(message,
                textAlign: TextAlign.center,
                style: AppTextStyles.body(color: AppColors.textSecondary)),
            if (onRetry != null) ...[
              const SizedBox(height: AppColors.s16),
              ElevatedButton(onPressed: onRetry, child: const Text('Thử lại')),
            ],
          ],
        ),
      ),
    );
  }
}