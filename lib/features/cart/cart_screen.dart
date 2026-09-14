import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import 'cart_viewmodel.dart';
import 'data/models/cart_item_model.dart';
import 'package:glow_aura/shared/widgets/product_image.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {


  // ── Actions ──
  void _increment(CartItemModel item) {
    ref.read(cartViewModelProvider.notifier).increment(item);
  }

  void _decrement(CartItemModel item) {
    if (item.quantity > 1) {
      ref.read(cartViewModelProvider.notifier).decrement(item);
    } else {
      _confirmRemove(item);
    }
  }

  void _confirmRemove(CartItemModel item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(AppColors.s24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppColors.s24),
            Text('Xóa sản phẩm?', style: AppTextStyles.heading()),
            const SizedBox(height: AppColors.s8),
            Text(
              'Bạn có chắc muốn xóa "${item.name}" khỏi giỏ hàng không?',
              style: AppTextStyles.body(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppColors.s24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Hủy'),
                  ),
                ),
                const SizedBox(width: AppColors.s12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                    onPressed: () {
                      ref.read(cartViewModelProvider.notifier).removeItem(item.productId);
                      Navigator.pop(context);
                    },
                    child: const Text('Xóa'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppColors.s16),
          ],
        ),
      ),
    );
  }

  void _showSnack(String msg, {required bool isError}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: AppTextStyles.body(color: Colors.white)),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(AppColors.s16),
      ),
    );
  }

  void _goToCheckout() {
    HapticFeedback.mediumImpact();
    context.push('/checkout');
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartViewModelProvider);

    ref.listen<CartState>(cartViewModelProvider, (previous, next) {
      if (next.errorMessage != null && next.errorMessage != previous?.errorMessage) {
        _showSnack(next.errorMessage!, isError: true);
        ref.read(cartViewModelProvider.notifier).clearError();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(cart),
      body: cart.isLoading && cart.items.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : cart.isEmpty
              ? _buildEmptyCart()
              : _buildCartBody(cart),
    );
  }

  AppBar _buildAppBar(CartState cart) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        color: AppColors.textPrimary,
        onPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/home');
          }
        },
      ),
      title: Column(
        children: [
          Text('Giỏ hàng', style: AppTextStyles.title()),
          if (cart.items.isNotEmpty)
            Text('${cart.totalQuantity} sản phẩm', style: AppTextStyles.caption()),
        ],
      ),
    );
  }

  // ── Giỏ trống ──
  Widget _buildEmptyCart() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppColors.s32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                color: AppColors.primarySubtle,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.shopping_bag_outlined, size: 44, color: AppColors.primary),
            ),
            const SizedBox(height: AppColors.s24),
            Text('Giỏ hàng đang trống', style: AppTextStyles.heading()),
            const SizedBox(height: AppColors.s8),
            Text(
              'Hãy thêm sản phẩm yêu thích\nvào giỏ hàng của bạn nhé!',
              style: AppTextStyles.body(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppColors.s32),
            ElevatedButton(
              onPressed: () => context.pop('/home'),
              child: const Text('Tiếp tục mua sắm'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Giỏ có sản phẩm ──
  Widget _buildCartBody(CartState cart) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: AppColors.s16, vertical: AppColors.s12),
            children: [
              _buildSectionLabel('Sản phẩm'),
              const SizedBox(height: AppColors.s8),
              ...cart.items.map(_buildCartItem),
              const SizedBox(height: AppColors.s16),
              const SizedBox(height: 24),
            ],
          ),
        ),
        _buildBottomBar(cart),
      ],
    );
  }

  Widget _buildSectionLabel(String text) => Text(text.toUpperCase(), style: AppTextStyles.label());

  // ── Cart Item Card ──
  Widget _buildCartItem(CartItemModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppColors.s8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppColors.s12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductImage(item),
            const SizedBox(width: AppColors.s12),
            Expanded(child: _buildItemInfo(item)),
            _buildDeleteButton(item),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(CartItemModel item) {
  return ProductImageWidget(
    imageUrl: item.imageUrl,
    width: 76,
    height: 76,
    borderRadius: BorderRadius.circular(12),
  );
}

  Widget _buildItemInfo(CartItemModel item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(item.brand.toUpperCase(), style: AppTextStyles.label()),
        const SizedBox(height: 2),
        Text(item.name, style: AppTextStyles.title(), maxLines: 2, overflow: TextOverflow.ellipsis),
        if (item.volume != null) ...[
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primarySubtle,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.primaryTint, width: 0.5),
            ),
            child: Text(item.volume!, style: AppTextStyles.caption(color: AppColors.primary)),
          ),
        ],
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildPriceGroup(item)),
            _buildQtyControl(item),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceGroup(CartItemModel item) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          _formatPrice(item.price),
          style: AppTextStyles.title(color: AppColors.primary).copyWith(fontWeight: FontWeight.w700),
        ),
        if (item.hasDiscount) ...[
          const SizedBox(width: 4),
          Text(
            _formatPrice(item.originalPrice!),
            style: AppTextStyles.caption().copyWith(decoration: TextDecoration.lineThrough),
          ),
        ],
      ],
    );
  }

  Widget _buildQtyControl(CartItemModel item) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primarySubtle,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryTint, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _qtyButton(Icons.remove, () => _decrement(item)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              '${item.quantity}',
              style: AppTextStyles.title().copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          _qtyButton(
            Icons.add,
            item.isMaxQuantity ? null : () => _increment(item),
            disabled: item.isMaxQuantity,
          ),
        ],
      ),
    );
  }

  Widget _qtyButton(IconData icon, VoidCallback? onTap, {bool disabled = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 16,
          color: disabled ? AppColors.textTertiary : AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildDeleteButton(CartItemModel item) {
    return GestureDetector(
      onTap: () => _confirmRemove(item),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: const Icon(Icons.delete_outline_rounded, size: 15, color: AppColors.textTertiary),
      ),
    );
  }
  // ── Order Summary ──
Widget _buildOrderSummary(CartState cart) {
  final subtotal = cart.items.fold<double>(
    0,
    (sum, item) => sum + (item.price * item.quantity),
  );

  final originalTotal = cart.items.fold<double>(
    0,
    (sum, item) =>
        sum + ((item.hasDiscount ? item.originalPrice! : item.price) * item.quantity),
  );

  final discount = originalTotal - subtotal;

  return Container(
    margin: const EdgeInsets.fromLTRB(AppColors.s16, 0, AppColors.s16, AppColors.s8),
    padding: const EdgeInsets.all(AppColors.s16),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.border, width: 0.5),
    ),
    child: Column(
      children: [
        _summaryRow('Tạm tính', _formatPrice(originalTotal)),
        if (discount > 0) ...[
          const SizedBox(height: 8),
          _summaryRow(
            'Giảm giá',
            '-${_formatPrice(discount)}',
            valueColor: AppColors.error,
          ),
        ],
        const SizedBox(height: 12),
        const Divider(height: 1, color: AppColors.border),
        const SizedBox(height: 12),
        _summaryRow(
          'Tổng cộng',
          _formatPrice(subtotal),
          isTotal: true,
        ),
      ],
    ),
  );
}

Widget _summaryRow(
  String label,
  String value, {
  bool isTotal = false,
  Color? valueColor,
}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: isTotal
            ? AppTextStyles.title()
            : AppTextStyles.body(color: AppColors.textSecondary),
      ),
      Text(
        value,
        style: isTotal
            ? AppTextStyles.title(color: AppColors.primary).copyWith(fontWeight: FontWeight.w700)
            : AppTextStyles.body(color: valueColor ?? AppColors.textPrimary),
      ),
    ],
  );
}
  // ── Bottom Bar ──
  Widget _buildBottomBar(CartState cart) {
  return Container(
    decoration: const BoxDecoration(
      color: AppColors.surface,
      border: Border(
        top: BorderSide(
          color: AppColors.border,
          width: .5,
        ),
      ),
    ),
    padding: EdgeInsets.fromLTRB(
      0,
      AppColors.s12,
      0,
      AppColors.s16 + MediaQuery.of(context).padding.bottom,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildOrderSummary(cart), 
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppColors.s16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: cart.isEmpty ? null : _goToCheckout,
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text("Tiến hành thanh toán"),
            ),
          ),
        ),
      ],
    ),
  );
}


  // ── Helper ──
  String _formatPrice(double price) {
    final formatted = price.toInt().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
    return '$formatted₫';
  }
}