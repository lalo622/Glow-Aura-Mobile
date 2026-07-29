import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../auth/auth_viewmodel.dart'; 
import '../cart/cart_viewmodel.dart'; 
import '../cart/data/models/cart_item_model.dart';
import 'checkout_viewmodel.dart';
import 'data/models/checkout_models.dart';
import 'payos_webview_screen.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _fullNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _couponCtrl = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  ShippingMethod _shippingMethod = ShippingMethod.fast;
  PaymentMethod _paymentMethod = PaymentMethod.cod;
  bool _couponApplied = false;

  @override
  void initState() {
    super.initState();
    // Điền sẵn thông tin từ user profile đang đăng nhập
    final user = ref.read(authViewModelProvider).user;
    if (user != null) {
      _fullNameCtrl.text = user.fullName;
      _emailCtrl.text = user.email;
    }

    // Gọi preview lần đầu sau khi build xong (cần context/ref sẵn sàng)
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshPreview());
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

  List<CheckoutItemRequest> _buildItemRequests(List<CartItemModel> items) {
    return items
        .map((i) => CheckoutItemRequest(productId: i.productId, quantity: i.quantity))
        .toList();
  }

  Future<void> _refreshPreview() async {
    final cartItems = ref.read(cartViewModelProvider).items;
    if (cartItems.isEmpty) return;
    await ref.read(checkoutViewModelProvider.notifier).refreshPreview(
          items: _buildItemRequests(cartItems),
          shippingMethod: _shippingMethod,
          couponCode: _couponApplied ? _couponCtrl.text.trim() : null,
        );
  }

  Future<void> _applyCoupon() async {
    final code = _couponCtrl.text.trim();
    if (code.isEmpty) return;

    await ref.read(checkoutViewModelProvider.notifier).refreshPreview(
          items: _buildItemRequests(ref.read(cartViewModelProvider).items),
          shippingMethod: _shippingMethod,
          couponCode: code,
        );

    final state = ref.read(checkoutViewModelProvider);
    if (state.preview?.isValid == true) {
      setState(() => _couponApplied = true);
      _showSnack('Áp dụng mã thành công!', isError: false);
    } else {
      setState(() => _couponApplied = false);
      _showSnack(state.preview?.errorMessage ?? state.errorMessage ?? 'Mã giảm giá không hợp lệ',
          isError: true);
    }
  }

  void _removeCoupon() {
    setState(() {
      _couponApplied = false;
      _couponCtrl.clear();
    });
    _refreshPreview();
  }

  Future<void> _placeOrder() async {
  if (!_formKey.currentState!.validate()) return;
  if (_addressCtrl.text.trim().isEmpty) {
    _showSnack('Vui lòng chọn địa chỉ giao hàng', isError: true);
    return;
  }
  // MoMo/VNPay đang lỗi bên BE, chỉ cho phép COD và PayOS
  if (_paymentMethod == PaymentMethod.momo) {
    _showSnack('MoMo hiện chưa được hỗ trợ, vui lòng chọn phương thức khác', isError: true);
    return;
  }

  final cartItems = ref.read(cartViewModelProvider).items;
  if (cartItems.isEmpty) {
    _showSnack('Giỏ hàng đang trống', isError: true);
    return;
  }

  HapticFeedback.mediumImpact();

  final success = await ref.read(checkoutViewModelProvider.notifier).placeOrder(
        fullName: _fullNameCtrl.text.trim(),
        phoneNumber: _phoneCtrl.text.trim(),
        email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
        shippingAddress: _addressCtrl.text.trim(),
        shippingMethod: _shippingMethod,
        paymentMethod: _paymentMethod,
        couponCode: _couponApplied ? _couponCtrl.text.trim() : null,
        items: _buildItemRequests(cartItems),
        returnUrl: kPayOSReturnUrl,
        cancelUrl: kPayOSCancelUrl,
      );

  if (!mounted) return;

  if (!success) {
    final err = ref.read(checkoutViewModelProvider).errorMessage;
    _showSnack(err ?? 'Đặt hàng thất bại, vui lòng thử lại', isError: true);
    return;
  }

  final orderResult = ref.read(checkoutViewModelProvider).orderResult;

  // COD → xong luôn, hiện dialog thành công như cũ
  if (_paymentMethod == PaymentMethod.cod) {
    _showOrderSuccess();
    return;
  }

  // PayOS → phải mở WebView để user thanh toán trước
  final paymentUrl = orderResult?.paymentUrl;
  if (paymentUrl == null || paymentUrl.isEmpty) {
    _showSnack('Không lấy được link thanh toán, vui lòng thử lại', isError: true);
    return;
  }

  final result = await Navigator.of(context).push<PayOSResult>(
    MaterialPageRoute(builder: (_) => PayOSWebViewScreen(checkoutUrl: paymentUrl)),
  );

  if (!mounted) return;

  if (result == PayOSResult.success) {
    // Confirm lại với BE trước khi báo thành công, vì webhook có thể trễ hơn WebView redirect
    final confirmed = await ref
        .read(checkoutViewModelProvider.notifier)
        .confirmOrderPaid(orderResult!.orderId!);

    if (confirmed) {
      _showOrderSuccess();
    } else {
      _showSnack(
        'Đã ghi nhận thanh toán, đơn hàng sẽ được cập nhật trong giây lát',
        isError: false,
      );
      // vẫn coi là thành công về mặt UX vì tiền đã trừ, webhook sẽ tự cập nhật sau
      _showOrderSuccess();
    }
  } else {
    _showSnack('Bạn đã huỷ thanh toán, đơn hàng chưa được xử lý', isError: true);
  }
}

  void _showOrderSuccess() {
    final orderNumber = ref.read(checkoutViewModelProvider).orderResult?.orderNumber;
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
              width: 72,
              height: 72,
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
            if (orderNumber != null) ...[
              Text('Mã đơn hàng: $orderNumber', style: AppTextStyles.body()),
              const SizedBox(height: AppColors.s8),
            ],
            Text(
              'Chúng tôi sẽ xử lý đơn hàng\nvà thông báo cho bạn sớm nhất.',
              style: AppTextStyles.body(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppColors.s24),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context)
                  ..pop() // đóng dialog
                  ..pop(); // rời khỏi CheckoutScreen
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
    final cartState = ref.watch(cartViewModelProvider);
    final checkoutState = ref.watch(checkoutViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: cartState.items.isEmpty
          ? _buildEmptyCart()
          : Form(
              key: _formKey,
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppColors.s16, vertical: AppColors.s12),
                      children: [
                        _buildSection('1', 'Thông tin vận chuyển', _buildShippingForm()),
                        const SizedBox(height: AppColors.s16),
                        _buildSection('2', 'Phương thức vận chuyển',
                            _buildShippingOptions(cartState.items)),
                        const SizedBox(height: AppColors.s16),
                        _buildSection('3', 'Phương thức thanh toán', _buildPaymentOptions()),
                        const SizedBox(height: AppColors.s16),
                        _buildSection('4', 'Đơn hàng của bạn',
                            _buildOrderSummary(cartState.items, checkoutState)),
                        const SizedBox(height: AppColors.s16),
                      ],
                    ),
                  ),
                  _buildBottomBar(checkoutState),
                ],
              ),
            ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.shopping_bag_outlined, size: 56, color: AppColors.textTertiary),
          const SizedBox(height: AppColors.s12),
          Text('Giỏ hàng của bạn đang trống', style: AppTextStyles.body()),
          const SizedBox(height: AppColors.s16),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Quay lại giỏ hàng'),
          ),
        ],
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
          Text('Giỏ hàng', style: AppTextStyles.body(color: AppColors.textSecondary)),
          const Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.textTertiary),
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
              width: 26,
              height: 26,
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              child: Center(
                child: Text(number,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
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
                ? [const TextSpan(text: ' *', style: TextStyle(color: AppColors.error))]
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
            children: const [TextSpan(text: ' *', style: TextStyle(color: AppColors.error))],
          ),
        ),
        const SizedBox(height: 5),
        _addressCtrl.text.isEmpty
            ? GestureDetector(
                onTap: () {
                  setState(() {
                    _addressCtrl.text = '123 Nguyễn Huệ, Quận 1, TP. Hồ Chí Minh';
                  });
                },
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primarySubtle,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppColors.primaryTint, width: 1, style: BorderStyle.solid),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.map_outlined, color: AppColors.primary, size: 18),
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
                      validator: (v) =>
                          (v == null || v.length < 10) ? 'Vui lòng chọn địa chỉ' : null,
                      decoration: const InputDecoration(
                        prefixIcon:
                            Icon(Icons.location_on_outlined, color: AppColors.primary, size: 18),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => setState(() => _addressCtrl.clear()),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border, width: 0.5),
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
  Widget _buildShippingOptions(List<CartItemModel> items) {
    return Column(
      children: [
        _shippingOption(
          method: ShippingMethod.fast,
          icon: Icons.electric_bolt_outlined,
          title: 'Giao hàng nhanh',
          subtitle: 'Dự kiến nhận hàng 2–3 ngày',
        ),
        const SizedBox(height: AppColors.s8),
        _shippingOption(
          method: ShippingMethod.standard,
          icon: Icons.local_shipping_outlined,
          title: 'Giao hàng tiêu chuẩn',
          subtitle: 'Dự kiến nhận hàng 4–7 ngày',
        ),
      ],
    );
  }

  Widget _shippingOption({
    required ShippingMethod method,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final selected = _shippingMethod == method;
    return GestureDetector(
      onTap: () {
        if (selected) return;
        setState(() => _shippingMethod = method);
        _refreshPreview();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding:
            const EdgeInsets.symmetric(horizontal: AppColors.s16, vertical: AppColors.s12),
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
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: selected ? AppColors.primary : AppColors.border, width: 2),
              ),
              child: selected
                  ? Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration:
                            const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: AppColors.s12),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : AppColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon,
                  size: 18, color: selected ? Colors.white : AppColors.textTertiary),
            ),
            const SizedBox(width: AppColors.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppTextStyles.title(
                          color: selected ? AppColors.primary : AppColors.textPrimary)),
                  Text(subtitle, style: AppTextStyles.caption()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Section 3: Payment Options (chỉ COD hoạt động, MoMo tạm khoá) ──
  Widget _buildPaymentOptions() {
  return Column(
    children: [
      _paymentOption(
        method: PaymentMethod.cod,
        icon: Icons.payments_outlined,
        title: 'Thanh toán khi nhận hàng (COD)',
        subtitle: 'Kiểm tra hàng trước khi thanh toán',
        enabled: true,
      ),
      const SizedBox(height: AppColors.s8),
      _paymentOption(
        method: PaymentMethod.payOS,
        icon: Icons.qr_code_rounded,
        title: 'Thanh toán PayOS',
        subtitle: 'Quét mã QR / chuyển khoản ngân hàng',
        enabled: true,
      ),
      const SizedBox(height: AppColors.s8),
      _paymentOption(
        method: PaymentMethod.momo,
        icon: Icons.account_balance_wallet_outlined,
        title: 'Ví điện tử MoMo',
        subtitle: 'Sắp ra mắt',
        enabled: false,
      ),
    ],
  );
}

  Widget _paymentOption({
    required PaymentMethod method,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool enabled,
  }) {
    final selected = _paymentMethod == method;
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: GestureDetector(
        onTap: enabled
            ? () => setState(() => _paymentMethod = method)
            : () => _showSnack('$title đang được phát triển', isError: false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding:
              const EdgeInsets.symmetric(horizontal: AppColors.s12, vertical: AppColors.s12),
          decoration: BoxDecoration(
            color: selected && enabled ? AppColors.primarySubtle : AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected && enabled ? AppColors.primary : AppColors.border,
              width: selected && enabled ? 1.5 : 0.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: selected && enabled ? AppColors.primary : AppColors.border,
                      width: 2),
                ),
                child: selected && enabled
                    ? Center(
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                              color: AppColors.primary, shape: BoxShape.circle),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: AppColors.s12),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: selected && enabled ? AppColors.primary : AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon,
                    size: 18,
                    color: selected && enabled ? Colors.white : AppColors.textTertiary),
              ),
              const SizedBox(width: AppColors.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: AppTextStyles.title(
                            color:
                                selected && enabled ? AppColors.primary : AppColors.textPrimary)),
                    Text(subtitle, style: AppTextStyles.caption()),
                  ],
                ),
              ),
              if (!enabled)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('Sắp ra mắt', style: AppTextStyles.caption()),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Section 4: Order Summary (dữ liệu thật từ Cart + preview API) ──
  Widget _buildOrderSummary(List<CartItemModel> items, CheckoutState checkoutState) {
    final preview = checkoutState.preview;

    return Container(
      padding: const EdgeInsets.all(AppColors.s16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        children: [
          ...items.map(_buildOrderItem),
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
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: AppColors.s8),
              SizedBox(
                height: 44,
                child: _couponApplied
                    ? OutlinedButton(
                        onPressed: _removeCoupon,
                        style: OutlinedButton.styleFrom(minimumSize: const Size(72, 44)),
                        child: const Text('Hủy'),
                      )
                    : ElevatedButton(
                        onPressed: checkoutState.isLoadingPreview ? null : _applyCoupon,
                        style: ElevatedButton.styleFrom(minimumSize: const Size(90, 44)),
                        child: const Text('ÁP DỤNG'),
                      ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppColors.s12),
            child: Divider(color: AppColors.border, thickness: 0.5, height: 0),
          ),

          // Summary rows — ưu tiên số liệu từ preview API, fallback cục bộ khi đang tải lần đầu
          if (checkoutState.isLoadingPreview && preview == null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppColors.s16),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else ...[
            _summaryRow(
              'Tạm tính (${items.fold<int>(0, (s, i) => s + i.quantity)} sp)',
              _formatPrice(preview?.subTotal ??
                  items.fold<double>(0, (s, i) => s + i.lineTotal)),
            ),
            _summaryRow(
              'Phí vận chuyển',
              (preview?.shippingFee ?? 0) == 0
                  ? 'Miễn phí'
                  : _formatPrice(preview!.shippingFee),
              valueColor: (preview?.shippingFee ?? 0) == 0 ? AppColors.success : null,
            ),
            if ((preview?.totalDiscount ?? 0) > 0)
              _summaryRow('Giảm giá', '−${_formatPrice(preview!.totalDiscount)}',
                  valueColor: AppColors.error),
            if (preview?.warnings.isNotEmpty == true)
              Padding(
                padding: const EdgeInsets.only(top: AppColors.s8),
                child: Text(
                  preview!.warnings.join('\n'),
                  style: AppTextStyles.caption(color: AppColors.error),
                ),
              ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppColors.s8),
              child: Divider(color: AppColors.border, thickness: 0.5, height: 0),
            ),
            Row(
              children: [
                Text('Tổng cộng', style: AppTextStyles.heading()),
                const Spacer(),
                Text(
                  _formatPrice(preview?.totalAmount ??
                      items.fold<double>(0, (s, i) => s + i.lineTotal)),
                  style: AppTextStyles.display(color: AppColors.primary),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderItem(CartItemModel item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppColors.s8),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primarySubtle,
              borderRadius: BorderRadius.circular(10),
              image: item.imageUrl != null
                  ? DecorationImage(image: NetworkImage(item.imageUrl!), fit: BoxFit.cover)
                  : null,
            ),
            child: item.imageUrl == null
                ? const Icon(Icons.spa_outlined, color: AppColors.primary, size: 22)
                : null,
          ),
          const SizedBox(width: AppColors.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name,
                    style: AppTextStyles.title(), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(
                  '${item.brand} · SL: ${item.quantity}${item.volume != null ? ' · ${item.volume}' : ''}',
                  style: AppTextStyles.caption(),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppColors.s8),
          Text(_formatPrice(item.lineTotal), style: AppTextStyles.title(color: AppColors.primary)),
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
              style: AppTextStyles.body(color: valueColor ?? AppColors.textPrimary)
                  .copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ── Bottom Bar ──
  Widget _buildBottomBar(CheckoutState checkoutState) {
    return Container(
      decoration: const BoxDecoration(
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
        onPressed: checkoutState.isSubmitting ? null : _placeOrder,
        child: checkoutState.isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
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