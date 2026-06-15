import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
// import '../cart/cart_screen.dart'; // CartItemModel


enum ShippingMethod { fast, standard }

enum PaymentMethod { cod, momo, zalopay, vnpay }

class _MockCartItem {
  final String name;
  final String brand;
  final String variant;
  final double price;
  final int quantity;
  final String emoji;

  const _MockCartItem({
    required this.name,
    required this.brand,
    required this.variant,
    required this.price,
    required this.quantity,
    required this.emoji,
  });
}

const _mockItems = [
  _MockCartItem(
    name: 'Kem chống nắng Anthelios SPF 50+',
    brand: 'La Roche-Posay',
    variant: 'Da nhạy cảm · 50ml',
    price: 385000,
    quantity: 2,
    emoji: '🧴',
  ),
  _MockCartItem(
    name: 'Serum AHA BHA PHA 30 Days Miracle',
    brand: 'Some By Mi',
    variant: 'Da dầu mụn · 50ml',
    price: 320000,
    quantity: 1,
    emoji: '✨',
  ),
  _MockCartItem(
    name: 'Sữa rửa mặt Hydrating Cleanser',
    brand: 'CeraVe',
    variant: 'Da khô · 236ml',
    price: 280000,
    quantity: 1,
    emoji: '💧',
  ),
];

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // Form controllers
  final _fullNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _couponCtrl = TextEditingController();

  // Form key
  final _formKey = GlobalKey<FormState>();

  // State
  ShippingMethod _shippingMethod = ShippingMethod.fast;
  PaymentMethod _paymentMethod = PaymentMethod.cod;
  bool _isSubmitting = false;
  double _discountAmount = 0;
  bool _couponApplied = false;

  final List<_MockCartItem> _items = _mockItems;

  @override
  void initState() {
    super.initState();
    // Điền sẵn thông tin từ user profile
    // _fullNameCtrl.text = user.fullName;
    // _phoneCtrl.text = user.phoneNumber;
    // _emailCtrl.text = user.email;
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    _couponCtrl.dispose();
    super.dispose();
  }

  // ── Tính toán ──
  double get _subtotal =>
      _items.fold(0, (sum, i) => sum + i.price * i.quantity);

  int get _totalQuantity => _items.fold(0, (sum, i) => sum + i.quantity);

  double get _shippingFee =>
      _shippingMethod == ShippingMethod.fast ? 35000 : 0;

  double get _total => _subtotal + _shippingFee - _discountAmount;

  // ── Coupon ──
  void _applyCoupon() {
    final code = _couponCtrl.text.trim().toUpperCase();
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

  // ── Place order ──
  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    HapticFeedback.mediumImpact();

    try {
      await Future.delayed(const Duration(seconds: 2)); 
      if (!mounted) return;
      _showOrderSuccess();
    } catch (e) {
      _showSnack('Đặt hàng thất bại: ${e.toString()}', isError: true);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showOrderSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: AppColors.surface,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72, height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F8EE),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_outline_rounded,
                  color: AppColors.success, size: 40),
            ),
            const SizedBox(height: AppColors.s16),
            Text('Đặt hàng thành công!', style: AppTextStyles.heading()),
            const SizedBox(height: AppColors.s8),
            Text(
              'Chúng tôi sẽ xử lý đơn hàng\nvà thông báo cho bạn sớm nhất.',
              style: AppTextStyles.body(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppColors.s24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Về trang chủ'),
            ),
          ],
        ),
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppColors.s16, vertical: AppColors.s12),
                children: [
                  _buildSection('1', 'Thông tin vận chuyển',
                      _buildShippingForm()),
                  const SizedBox(height: AppColors.s16),
                  _buildSection('2', 'Phương thức vận chuyển',
                      _buildShippingOptions()),
                  const SizedBox(height: AppColors.s16),
                  _buildSection('3', 'Phương thức thanh toán',
                      _buildPaymentOptions()),
                  const SizedBox(height: AppColors.s16),
                  _buildSection('4', 'Đơn hàng của bạn',
                      _buildOrderSummary()),
                  const SizedBox(height: AppColors.s16),
                ],
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        color: AppColors.textPrimary,
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Giỏ hàng',
              style: AppTextStyles.body(color: AppColors.textSecondary)),
          const Icon(Icons.chevron_right_rounded,
              size: 16, color: AppColors.textTertiary),
          Text('Thanh toán',
              style: AppTextStyles.body(color: AppColors.primary)
                  .copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ── Section wrapper ──
  Widget _buildSection(String number, String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 26, height: 26,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(number,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(width: AppColors.s8),
            Text(title, style: AppTextStyles.heading()),
          ],
        ),
        const SizedBox(height: AppColors.s12),
        child,
      ],
    );
  }

  // ── Section 1: Shipping Form ──
  Widget _buildShippingForm() {
    return Container(
      padding: const EdgeInsets.all(AppColors.s16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildFormField(
                  label: 'Họ và tên',
                  required: true,
                  controller: _fullNameCtrl,
                  hint: 'Nguyễn Văn A',
                  keyboardType: TextInputType.name,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Vui lòng nhập họ tên' : null,
                ),
              ),
              const SizedBox(width: AppColors.s8),
              Expanded(
                child: _buildFormField(
                  label: 'Số điện thoại',
                  required: true,
                  controller: _phoneCtrl,
                  hint: '0901 234 567',
                  keyboardType: TextInputType.phone,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Nhập số điện thoại';
                    if (v.length < 10) return 'Số không hợp lệ';
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppColors.s12),
          _buildFormField(
            label: 'Email (nhận hóa đơn)',
            controller: _emailCtrl,
            hint: 'example@gmail.com',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: AppColors.s12),
          _buildAddressPicker(),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    String? hint,
    bool required = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label.toUpperCase(),
            style: AppTextStyles.label(),
            children: required
                ? [
                    const TextSpan(
                      text: ' *',
                      style: TextStyle(color: AppColors.error),
                    )
                  ]
                : [],
          ),
        ),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: AppTextStyles.body(color: AppColors.textPrimary),
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }

  Widget _buildAddressPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: 'ĐỊA CHỈ GIAO HÀNG',
            style: AppTextStyles.label(),
            children: const [
              TextSpan(
                  text: ' *', style: TextStyle(color: AppColors.error)),
            ],
          ),
        ),
        const SizedBox(height: 5),
        // Nếu đã chọn địa chỉ, hiện text field; chưa chọn hiện nút bản đồ
        _addressCtrl.text.isEmpty
            ? GestureDetector(
                onTap: () {
                  // showModalBottomSheet(context: context, builder: (_) => AddressMapPicker(...));
                  setState(() {
                    _addressCtrl.text =
                        '123 Nguyễn Huệ, Quận 1, TP. Hồ Chí Minh'; // mock
                  });
                },
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primarySubtle,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppColors.primaryTint,
                        width: 1,
                        style: BorderStyle.solid),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.map_outlined,
                          color: AppColors.primary, size: 18),
                      const SizedBox(width: 8),
                      Text('Chọn địa chỉ trên bản đồ',
                          style: AppTextStyles.body(color: AppColors.primary)
                              .copyWith(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              )
            : Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _addressCtrl,
                      style: AppTextStyles.body(color: AppColors.textPrimary),
                      maxLines: 2,
                      validator: (v) => (v == null || v.length < 10)
                          ? 'Vui lòng chọn địa chỉ'
                          : null,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.location_on_outlined,
                            color: AppColors.primary, size: 18),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      setState(() => _addressCtrl.clear());
                    },
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppColors.border, width: 0.5),
                      ),
                      child: const Icon(Icons.edit_location_outlined,
                          size: 16, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
      ],
    );
  }

  // ── Section 2: Shipping Options ──
  Widget _buildShippingOptions() {
    return Column(
      children: [
        _shippingOption(
          method: ShippingMethod.fast,
          icon: Icons.electric_bolt_outlined,
          title: 'Giao hàng nhanh',
          subtitle: 'Dự kiến nhận hàng 2–3 ngày',
          priceLabel: '35.000₫',
          isFree: false,
        ),
        const SizedBox(height: AppColors.s8),
        _shippingOption(
          method: ShippingMethod.standard,
          icon: Icons.local_shipping_outlined,
          title: 'Giao hàng tiêu chuẩn',
          subtitle: 'Dự kiến nhận hàng 4–7 ngày',
          priceLabel: 'Miễn phí',
          isFree: true,
        ),
      ],
    );
  }

  Widget _shippingOption({
    required ShippingMethod method,
    required IconData icon,
    required String title,
    required String subtitle,
    required String priceLabel,
    required bool isFree,
  }) {
    final selected = _shippingMethod == method;
    return GestureDetector(
      onTap: () => setState(() => _shippingMethod = method),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
            horizontal: AppColors.s16, vertical: AppColors.s12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primarySubtle : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.5 : 0.5,
          ),
        ),
        child: Row(
          children: [
            // Radio dot
            Container(
              width: 18, height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: selected ? AppColors.primary : AppColors.border,
                    width: 2),
              ),
              child: selected
                  ? Center(
                      child: Container(
                        width: 8, height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primary, shape: BoxShape.circle),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: AppColors.s12),
            // Icon
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : AppColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon,
                  size: 18,
                  color: selected ? Colors.white : AppColors.textTertiary),
            ),
            const SizedBox(width: AppColors.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppTextStyles.title(
                          color: selected
                              ? AppColors.primary
                              : AppColors.textPrimary)),
                  Text(subtitle, style: AppTextStyles.caption()),
                ],
              ),
            ),
            Text(
              priceLabel,
              style: AppTextStyles.title(
                  color: isFree ? AppColors.success : AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }

  // ── Section 3: Payment Options ──
  Widget _buildPaymentOptions() {
    final methods = [
      (
        PaymentMethod.cod,
        Icons.payments_outlined,
        'Thanh toán khi nhận hàng (COD)',
        'Kiểm tra hàng trước khi thanh toán'
      ),
      (
        PaymentMethod.momo,
        Icons.account_balance_wallet_outlined,
        'Ví điện tử MoMo',
        'Thanh toán nhanh qua ứng dụng MoMo'
      ),
      (
        PaymentMethod.zalopay,
        Icons.smartphone_outlined,
        'Ví ZaloPay',
        'Thanh toán tiện lợi qua ứng dụng ZaloPay'
      ),
      (
        PaymentMethod.vnpay,
        Icons.qr_code_outlined,
        'Cổng thanh toán VNPay',
        'Quét mã QR qua ứng dụng ngân hàng'
      ),
    ];

    return Column(
      children: methods
          .map((m) => Padding(
                padding: const EdgeInsets.only(bottom: AppColors.s8),
                child: _paymentOption(m.$1, m.$2, m.$3, m.$4),
              ))
          .toList(),
    );
  }

  Widget _paymentOption(
      PaymentMethod method, IconData icon, String title, String subtitle) {
    final selected = _paymentMethod == method;
    return GestureDetector(
      onTap: () => setState(() => _paymentMethod = method),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
            horizontal: AppColors.s12, vertical: AppColors.s12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primarySubtle : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.5 : 0.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 18, height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: selected ? AppColors.primary : AppColors.border,
                    width: 2),
              ),
              child: selected
                  ? Center(
                      child: Container(
                        width: 8, height: 8,
                        decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: AppColors.s12),
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : AppColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon,
                  size: 18,
                  color: selected ? Colors.white : AppColors.textTertiary),
            ),
            const SizedBox(width: AppColors.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppTextStyles.title(
                          color: selected
                              ? AppColors.primary
                              : AppColors.textPrimary)),
                  Text(subtitle, style: AppTextStyles.caption()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Section 4: Order Summary ──
  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(AppColors.s16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        children: [
          // Danh sách sản phẩm
          ..._items.map(_buildOrderItem),
          const SizedBox(height: AppColors.s12),

          // Coupon
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _couponCtrl,
                  enabled: !_couponApplied,
                  style: AppTextStyles.body(color: AppColors.textPrimary),
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    hintText: 'Nhập mã giảm giá...',
                    suffixIcon: _couponApplied
                        ? const Icon(Icons.check_circle_outline,
                            color: AppColors.success, size: 18)
                        : null,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
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
                          _couponCtrl.clear();
                        }),
                        style: OutlinedButton.styleFrom(
                            minimumSize: const Size(72, 44)),
                        child: const Text('Hủy'),
                      )
                    : ElevatedButton(
                        onPressed: _applyCoupon,
                        style: ElevatedButton.styleFrom(
                            minimumSize: const Size(90, 44)),
                        child: const Text('ÁP DỤNG'),
                      ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppColors.s12),
            child: Divider(color: AppColors.border, thickness: 0.5, height: 0),
          ),

          // Summary rows
          _summaryRow('Tạm tính ($_totalQuantity sp)',
              _formatPrice(_subtotal)),
          _summaryRow(
            'Phí vận chuyển',
            _shippingFee == 0 ? 'Miễn phí' : _formatPrice(_shippingFee),
            valueColor: _shippingFee == 0 ? AppColors.success : null,
          ),
          if (_discountAmount > 0)
            _summaryRow('Giảm giá', '−${_formatPrice(_discountAmount)}',
                valueColor: AppColors.error),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppColors.s8),
            child: Divider(color: AppColors.border, thickness: 0.5, height: 0),
          ),
          Row(
            children: [
              Text('Tổng cộng', style: AppTextStyles.heading()),
              const Spacer(),
              Text(_formatPrice(_total),
                  style: AppTextStyles.display(color: AppColors.primary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(_MockCartItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppColors.s8),
      child: Row(
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: AppColors.primarySubtle,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
                child: Text(item.emoji,
                    style: const TextStyle(fontSize: 24))),
          ),
          const SizedBox(width: AppColors.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name,
                    style: AppTextStyles.title(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text('${item.brand} · SL: ${item.quantity} · ${item.variant}',
                    style: AppTextStyles.caption()),
              ],
            ),
          ),
          const SizedBox(width: AppColors.s8),
          Text(
            _formatPrice(item.price * item.quantity),
            style: AppTextStyles.title(color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: AppTextStyles.body()),
          const Spacer(),
          Text(value,
              style: AppTextStyles.body(
                      color: valueColor ?? AppColors.textPrimary)
                  .copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ── Bottom Bar ──
  Widget _buildBottomBar() {
    return Container(
      decoration:const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      padding: EdgeInsets.fromLTRB(
        AppColors.s16,
        AppColors.s12,
        AppColors.s16,
        AppColors.s16 + MediaQuery.of(context).padding.bottom,
      ),
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _placeOrder,
        child: _isSubmitting
            ? const SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Text('Hoàn tất đặt hàng'),
                   SizedBox(width: 8),
                   Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
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