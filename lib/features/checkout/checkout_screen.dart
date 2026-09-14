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
import 'widgets/shipping_form_section.dart';
import 'widgets/payment_options_section.dart';
import 'widgets/order_summary_section.dart';
import 'widgets/order_success_dialog.dart';
import 'widgets/address_picker_sheet.dart';

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

  PaymentMethod _paymentMethod = PaymentMethod.cod;
  bool _couponApplied = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authViewModelProvider).user;
    if (user != null) {
      _fullNameCtrl.text = user.fullName;
      _emailCtrl.text = user.email;
      _phoneCtrl.text = user.phoneNumber ?? '';
    }
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
          couponCode: _couponApplied ? _couponCtrl.text.trim() : null,
        );
  }

  Future<void> _applyCoupon() async {
    final code = _couponCtrl.text.trim();
    if (code.isEmpty) return;

    await ref.read(checkoutViewModelProvider.notifier).refreshPreview(
          items: _buildItemRequests(ref.read(cartViewModelProvider).items),
          couponCode: code,
        );

    final state = ref.read(checkoutViewModelProvider);
    if (state.preview?.isValid == true) {
      setState(() => _couponApplied = true);
      _showSnack('Áp dụng mã thành công!', isError: false);
    } else {
      setState(() => _couponApplied = false);
      _showSnack(
        state.preview?.errorMessage ?? state.errorMessage ?? 'Mã giảm giá không hợp lệ',
        isError: true,
      );
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
    if (!_formKey.currentState!.validate()) {
      _showSnack('Vui lòng điền đầy đủ thông tin bắt buộc (*)', isError: true);
      return;
    }
    if (_addressCtrl.text.trim().isEmpty) {
      _showSnack('Vui lòng chọn địa chỉ giao hàng', isError: true);
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

    // COD: đơn được xác nhận ngay, an toàn để báo thành công.
    if (_paymentMethod == PaymentMethod.cod) {
      _showOrderSuccessDialog();
      return;
    }

    // PayOS: đơn mới chỉ "khởi tạo", chưa được thanh toán.
    final paymentUrl = orderResult?.paymentUrl;
    if (paymentUrl == null || paymentUrl.isEmpty) {
      _showSnack('Không lấy được link thanh toán, vui lòng thử lại', isError: true);
      return;
    }

    final orderId = orderResult?.orderId;
    if (orderId == null) {
      _showSnack(
        'Thiếu mã đơn để xác nhận thanh toán. Vui lòng liên hệ hỗ trợ.',
        isError: true,
      );
      return;
    }

    final result = await Navigator.of(context).push<PayOSResult>(
      MaterialPageRoute(
        builder: (_) => PayOSWebViewScreen(checkoutUrl: paymentUrl, orderId: orderId),
      ),
    );

    if (!mounted) return;

    if (result != PayOSResult.success) {
      _showSnack('Bạn đã huỷ thanh toán, đơn hàng chưa được xử lý', isError: true);
      return;
    }

    await ref.read(cartViewModelProvider.notifier).clearCart();
    _showOrderSuccessDialog();
  }

  void _showOrderSuccessDialog() {
    final orderNumber = ref.read(checkoutViewModelProvider).orderResult?.orderNumber;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => OrderSuccessDialog(orderNumber: orderNumber),
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
                        _buildSection(
                          '1',
                          'Thông tin vận chuyển',
                          ShippingFormSection(
                            fullNameCtrl: _fullNameCtrl,
                            phoneCtrl: _phoneCtrl,
                            emailCtrl: _emailCtrl,
                            addressCtrl: _addressCtrl,
                            onPickAddress: () async {
                                final result = await showAddressPickerSheet(context);
                                if (result != null) {
                                  setState(() => _addressCtrl.text = result.formatted);
                                }
                              },
                            onClearAddress: () => setState(() => _addressCtrl.clear()),
                          ),
                        ),
                        const SizedBox(height: AppColors.s16),
                        _buildSection(
                          '2',
                          'Phương thức thanh toán',
                          PaymentOptionsSection(
                            selected: _paymentMethod,
                            onChanged: (method) => setState(() => _paymentMethod = method),
                            onDisabledTap: (title) =>
                                _showSnack('$title đang được phát triển', isError: false),
                          ),
                        ),
                        const SizedBox(height: AppColors.s16),
                        _buildSection(
                          '3',
                          'Đơn hàng của bạn',
                          OrderSummarySection(
                            items: cartState.items,
                            checkoutState: checkoutState,
                            couponCtrl: _couponCtrl,
                            couponApplied: _couponApplied,
                            onApplyCoupon: _applyCoupon,
                            onRemoveCoupon: _removeCoupon,
                          ),
                        ),
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
          Text(
            'Thanh toán',
            style: AppTextStyles.body(color: AppColors.primary).copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

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
                child: Text(
                  number,
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                ),
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
}