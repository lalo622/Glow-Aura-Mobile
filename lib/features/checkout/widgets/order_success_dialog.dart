import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class OrderSuccessDialog extends StatelessWidget {
  final String? orderNumber;

  const OrderSuccessDialog({super.key, this.orderNumber});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppColors.surface,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(color: Color(0xFFE8F8EE), shape: BoxShape.circle),
            child: const Icon(Icons.check_circle_outline_rounded, color: AppColors.success, size: 40),
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
                ..pop()
                ..pop();
            },
            child: const Text('Về trang chủ'),
          ),
        ],
      ),
    );
  }
}