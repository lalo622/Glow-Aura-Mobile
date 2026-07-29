import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../cart/data/models/cart_item_model.dart';
import '../checkout_viewmodel.dart';

class OrderSummarySection extends StatelessWidget {
  final List<CartItemModel> items;
  final CheckoutState checkoutState;
  final ShippingMethod shippingMethod;
  final TextEditingController couponCtrl;
  final bool couponApplied;
  final VoidCallback onApplyCoupon;
  final VoidCallback onRemoveCoupon;

  const OrderSummarySection({
    super.key,
    required this.items,
    required this.checkoutState,
    required this.shippingMethod,
    required this.couponCtrl,
    required this.couponApplied,
    required this.onApplyCoupon,
    required this.onRemoveCoupon,
  });

  String _formatPrice(double price) {
    final formatted = price.toInt().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
    return '$formatted₫';
  }

  @override
  Widget build(BuildContext context) {
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
          ...items.map(_orderItem),
          const SizedBox(height: AppColors.s12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: couponCtrl,
                  enabled: !couponApplied,
                  style: AppTextStyles.body(color: AppColors.textPrimary),
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    hintText: 'Nhập mã giảm giá...',
                    suffixIcon: couponApplied
                        ? const Icon(Icons.check_circle_outline, color: AppColors.success, size: 18)
                        : null,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: AppColors.s8),
              SizedBox(
                height: 44,
                child: couponApplied
                    ? OutlinedButton(
                        onPressed: onRemoveCoupon,
                        style: OutlinedButton.styleFrom(minimumSize: const Size(72, 44)),
                        child: const Text('Hủy'),
                      )
                    : ElevatedButton(
                        onPressed: checkoutState.isLoadingPreview ? null : onApplyCoupon,
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
          if (checkoutState.isLoadingPreview && preview == null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppColors.s16),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else ...[
            _summaryRow(
              'Tạm tính (${items.fold<int>(0, (s, i) => s + i.quantity)} sp)',
              _formatPrice(preview?.subTotal ?? items.fold<double>(0, (s, i) => s + i.lineTotal)),
            ),
            _summaryRow(
              'Phí vận chuyển',
              (preview?.shippingFee ?? 0) == 0 ? 'Miễn phí' : _formatPrice(preview!.shippingFee),
              valueColor: (preview?.shippingFee ?? 0) == 0 ? AppColors.success : null,
            ),
            if ((preview?.totalDiscount ?? 0) > 0)
              _summaryRow('Giảm giá', '−${_formatPrice(preview!.totalDiscount)}', valueColor: AppColors.error),
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
                  _formatPrice(preview?.totalAmount ?? items.fold<double>(0, (s, i) => s + i.lineTotal)),
                  style: AppTextStyles.display(color: AppColors.primary),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _orderItem(CartItemModel item) {
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
            child: item.imageUrl == null ? const Icon(Icons.spa_outlined, color: AppColors.primary, size: 22) : null,
          ),
          const SizedBox(width: AppColors.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: AppTextStyles.title(), maxLines: 2, overflow: TextOverflow.ellipsis),
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
}