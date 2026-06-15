import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';

class CartItemModel {
  final String id;
  final String brand;
  final String name;
  final String variant;
  final double salePrice;
  final double? originalPrice;
  final String imageEmoji; 
  int quantity;

  CartItemModel({
    required this.id,
    required this.brand,
    required this.name,
    required this.variant,
    required this.salePrice,
    this.originalPrice,
    required this.imageEmoji,
    this.quantity = 1,
  });
}

final List<CartItemModel> _mockCartItems = [
  CartItemModel(
    id: '1',
    brand: 'La Roche-Posay',
    name: 'Kem chống nắng Anthelios SPF 50+',
    variant: 'Da nhạy cảm · 50ml',
    salePrice: 385000,
    originalPrice: 450000,
    imageEmoji: '🧴',
    quantity: 2,
  ),
  CartItemModel(
    id: '2',
    brand: 'Some By Mi',
    name: 'Serum AHA BHA PHA 30 Days Miracle',
    variant: 'Da dầu mụn · 50ml',
    salePrice: 320000,
    originalPrice: 380000,
    imageEmoji: '✨',
    quantity: 1,
  ),
  CartItemModel(
    id: '3',
    brand: 'CeraVe',
    name: 'Sữa rửa mặt Hydrating Cleanser',
    variant: 'Da khô · 236ml',
    salePrice: 280000,
    imageEmoji: '💧',
    quantity: 1,
  ),
];

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final List<CartItemModel> _items = List.from(_mockCartItems);
  final TextEditingController _couponController = TextEditingController();
  double _discountAmount = 0;
  bool _couponApplied = false;
  static const double _shippingThreshold = 500000;

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  // ── Tính toán ──
  int get _totalQuantity => _items.fold(0, (sum, i) => sum + i.quantity);

  double get _subtotal =>
      _items.fold(0, (sum, i) => sum + i.salePrice * i.quantity);

  bool get _isFreeShipping => _subtotal >= _shippingThreshold;

  double get _shippingFee => _isFreeShipping ? 0 : 30000;

  double get _total => _subtotal + _shippingFee - _discountAmount;

  // ── Actions ──
  void _increment(CartItemModel item) {
    setState(() => item.quantity++);
  }

  void _decrement(CartItemModel item) {
    if (item.quantity > 1) {
      setState(() => item.quantity--);
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
              width: 40, height: 4,
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                    ),
                    onPressed: () {
                      setState(() => _items.removeWhere((e) => e.id == item.id));
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

  void _applyCoupon() {
    final code = _couponController.text.trim().toUpperCase();
    // gọi API kiểm tra coupon
    if (code == 'GLOWAURA10') {
      setState(() {
        _discountAmount = _subtotal * 0.1;
        _couponApplied = true;
      });
      _showSnack('Áp dụng mã thành công! Giảm 10%', isError: false);
    } else if (code.isNotEmpty) {
      _showSnack('Mã giảm giá không hợp lệ hoặc đã hết hạn', isError: true);
    }
  }

  void _showSnack(String msg, {required bool isError}) {
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
    //  Navigator.push đến CheckoutScreen
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: _items.isEmpty ? _buildEmptyCart() : _buildCartBody(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        color: AppColors.textPrimary,
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        children: [
          Text('Giỏ hàng', style: AppTextStyles.title()),
          if (_items.isNotEmpty)
            Text(
              '$_totalQuantity sản phẩm',
              style: AppTextStyles.caption(),
            ),
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
              width: 96, height: 96,
              decoration: const BoxDecoration(
                color: AppColors.primarySubtle,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.shopping_bag_outlined,
                  size: 44, color: AppColors.primary),
            ),
            const SizedBox(height: AppColors.s24),
            Text('Giỏ hàng đang trống',
                style: AppTextStyles.heading()),
            const SizedBox(height: AppColors.s8),
            Text(
              'Hãy thêm sản phẩm yêu thích\nvào giỏ hàng của bạn nhé!',
              style: AppTextStyles.body(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppColors.s32),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tiếp tục mua sắm'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Giỏ có sản phẩm ──
  Widget _buildCartBody() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppColors.s16,
              vertical: AppColors.s12,
            ),
            children: [
              _buildSectionLabel('Sản phẩm'),
              const SizedBox(height: AppColors.s8),
              ..._items.map(_buildCartItem),
              const SizedBox(height: AppColors.s16),
              _buildCouponSection(),
              const SizedBox(height: AppColors.s12),
              _buildOrderSummary(),
              const SizedBox(height: AppColors.s12),
              _buildTrustBadges(),
              const SizedBox(height: AppColors.s16),
            ],
          ),
        ),
        _buildBottomBar(),
      ],
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: AppTextStyles.label(),
    );
  }

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
            // Ảnh sản phẩm
            _buildProductImage(item),
            const SizedBox(width: AppColors.s12),
            // Info
            Expanded(child: _buildItemInfo(item)),
            // Nút xóa
            _buildDeleteButton(item),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(CartItemModel item) {
    return Container(
      width: 76, height: 76,
      decoration: BoxDecoration(
        color: AppColors.primarySubtle,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(item.imageEmoji, style: const TextStyle(fontSize: 32)),
      ),
    );
  }

  Widget _buildItemInfo(CartItemModel item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(item.brand.toUpperCase(), style: AppTextStyles.label()),
        const SizedBox(height: 2),
        Text(item.name,
            style: AppTextStyles.title(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis),
        const SizedBox(height: 4),
        // Variant chip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.primarySubtle,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.primaryTint, width: 0.5),
          ),
          child: Text(item.variant,
              style: AppTextStyles.caption(color: AppColors.primary)),
        ),
        const SizedBox(height: 8),
        // Giá + số lượng
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
          _formatPrice(item.salePrice),
          style: AppTextStyles.title(color: AppColors.primary)
              .copyWith(fontWeight: FontWeight.w700),
        ),
        if (item.originalPrice != null) ...[
          const SizedBox(width: 4),
          Text(
            _formatPrice(item.originalPrice!),
            style: AppTextStyles.caption().copyWith(
              decoration: TextDecoration.lineThrough,
            ),
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
          _qtyButton(Icons.add, () => _increment(item)),
        ],
      ),
    );
  }

  Widget _qtyButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28, height: 28,
        alignment: Alignment.center,
        child: Icon(icon, size: 16, color: AppColors.primary),
      ),
    );
  }

  Widget _buildDeleteButton(CartItemModel item) {
    return GestureDetector(
      onTap: () => _confirmRemove(item),
      child: Container(
        width: 28, height: 28,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: const Icon(Icons.delete_outline_rounded,
            size: 15, color: AppColors.textTertiary),
      ),
    );
  }

  // ── Coupon ──
  Widget _buildCouponSection() {
    return Container(
      padding: const EdgeInsets.all(AppColors.s16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_offer_outlined,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text('MÃ GIẢM GIÁ', style: AppTextStyles.label()),
            ],
          ),
          const SizedBox(height: AppColors.s8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _couponController,
                  enabled: !_couponApplied,
                  style: AppTextStyles.body(color: AppColors.textPrimary),
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    hintText: 'Nhập mã của bạn',
                    suffixIcon: _couponApplied
                        ? const Icon(Icons.check_circle_outline,
                            color: AppColors.success, size: 18)
                        : null,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: AppColors.s8),
              SizedBox(
                height: 44,
                child: _couponApplied
                    ? OutlinedButton(
                        onPressed: () => setState(() {
                          _couponApplied = false;
                          _discountAmount = 0;
                          _couponController.clear();
                        }),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(80, 44),
                        ),
                        child: const Text('Hủy'),
                      )
                    : ElevatedButton(
                        onPressed: _applyCoupon,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(80, 44),
                        ),
                        child: const Text('Áp dụng'),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Order Summary ──
  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(AppColors.s16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tóm tắt đơn hàng', style: AppTextStyles.heading()),
          const SizedBox(height: AppColors.s12),
          _summaryRow(
              'Tạm tính ($_totalQuantity sp)', _formatPrice(_subtotal)),
          _summaryRow(
            'Phí vận chuyển',
            _isFreeShipping ? 'Miễn phí' : _formatPrice(_shippingFee),
            valueColor: _isFreeShipping ? AppColors.success : null,
          ),
          if (_discountAmount > 0)
            _summaryRow(
              'Giảm giá',
              '−${_formatPrice(_discountAmount)}',
              valueColor: AppColors.error,
            ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppColors.s12),
            child: Divider(color: AppColors.border, thickness: 0.5, height: 0),
          ),
          Row(
            children: [
              Text('Tổng cộng', style: AppTextStyles.heading()),
              const Spacer(),
              Text(
                _formatPrice(_total),
                style: AppTextStyles.display(color: AppColors.primary),
              ),
            ],
          ),
          if (!_isFreeShipping) ...[
            const SizedBox(height: AppColors.s8),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.accentTint,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.local_shipping_outlined,
                      size: 14, color: AppColors.accentGold),
                  const SizedBox(width: 6),
                  Text(
                    'Thêm ${_formatPrice(_shippingThreshold - _subtotal)} để được miễn phí ship!',
                    style: AppTextStyles.caption(color: AppColors.accentGold)
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Text(label, style: AppTextStyles.body()),
          const Spacer(),
          Text(
            value,
            style: AppTextStyles.body(
              color: valueColor ?? AppColors.textPrimary,
            ).copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // ── Trust Badges ──
  Widget _buildTrustBadges() {
    return Row(
      children: [
        _trustBadge(Icons.shield_outlined, 'Thanh toán\nbảo mật'),
        const SizedBox(width: AppColors.s8),
        _trustBadge(Icons.local_shipping_outlined, 'Giao hàng\n2–3 ngày'),
        const SizedBox(width: AppColors.s8),
        _trustBadge(Icons.refresh_outlined, 'Đổi trả\n30 ngày'),
      ],
    );
  }

  Widget _trustBadge(IconData icon, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 8, vertical: AppColors.s8),
        decoration: BoxDecoration(
          color: AppColors.primarySubtle,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.caption(color: AppColors.primaryDark)
                    .copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Bottom Bar ──
  Widget _buildBottomBar() {
    return Container(
      decoration:const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 0.5),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        AppColors.s16,
        AppColors.s12,
        AppColors.s16,
        AppColors.s16 + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton.icon(
            onPressed: _items.isEmpty ? null : _goToCheckout,
            icon: const Icon(Icons.lock_outline_rounded, size: 18),
            label: const Text('Tiến hành thanh toán'),
          ),
          const SizedBox(height: AppColors.s8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: ['MOMO', 'VNPAY', 'COD', 'VISA']
                .map((m) => _paymentChip(m))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _paymentChip(String label) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Text(
        label,
        style: AppTextStyles.label().copyWith(letterSpacing: 0.3),
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