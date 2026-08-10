import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../checkout_viewmodel.dart';

class PaymentOptionsSection extends StatelessWidget {
  final PaymentMethod selected;
  final ValueChanged<PaymentMethod> onChanged;
  final void Function(String title) onDisabledTap;

  const PaymentOptionsSection({
    super.key,
    required this.selected,
    required this.onChanged,
    required this.onDisabledTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _option(
          method: PaymentMethod.cod,
          icon: Icons.payments_outlined,
          title: 'Thanh toán khi nhận hàng (COD)',
          subtitle: 'Kiểm tra hàng trước khi thanh toán',
          enabled: true,
        ),
        const SizedBox(height: AppColors.s8),
        _option(
          method: PaymentMethod.payOS,
          icon: Icons.qr_code_rounded,
          title: 'Thanh toán PayOS',
          subtitle: 'Quét mã QR / chuyển khoản ngân hàng',
          enabled: true,
        ),
      ],
    );
  }

  Widget _option({
    required PaymentMethod method,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool enabled,
  }) {
    final isSelected = selected == method;
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: GestureDetector(
        onTap: enabled ? () => onChanged(method) : () => onDisabledTap(title),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: AppColors.s12, vertical: AppColors.s12),
          decoration: BoxDecoration(
            color: isSelected && enabled ? AppColors.primarySubtle : AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected && enabled ? AppColors.primary : AppColors.border,
              width: isSelected && enabled ? 1.5 : 0.5,
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
                      color: isSelected && enabled ? AppColors.primary : AppColors.border, width: 2),
                ),
                child: isSelected && enabled
                    ? Center(
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: AppColors.s12),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isSelected && enabled ? AppColors.primary : AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: isSelected && enabled ? Colors.white : AppColors.textTertiary),
              ),
              const SizedBox(width: AppColors.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: AppTextStyles.title(
                            color: isSelected && enabled ? AppColors.primary : AppColors.textPrimary)),
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
}