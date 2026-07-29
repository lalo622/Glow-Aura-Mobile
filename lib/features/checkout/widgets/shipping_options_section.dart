import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../checkout_viewmodel.dart';

class ShippingOptionsSection extends StatelessWidget {
  final ShippingMethod selected;
  final ValueChanged<ShippingMethod> onChanged;

  const ShippingOptionsSection({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _option(
          method: ShippingMethod.fast,
          icon: Icons.electric_bolt_outlined,
          title: 'Giao hàng nhanh',
          subtitle: 'Dự kiến nhận hàng 2–3 ngày',
        ),
        const SizedBox(height: AppColors.s8),
        _option(
          method: ShippingMethod.standard,
          icon: Icons.local_shipping_outlined,
          title: 'Giao hàng tiêu chuẩn',
          subtitle: 'Dự kiến nhận hàng 4–7 ngày',
        ),
        // Phí ship bên BE hiện chưa phân biệt đúng theo phương thức (bug đã báo BE)
        // — cảnh báo tạm để không hiển thị nhầm số cho user, xoá dòng này khi BE fix xong.
        if (selected == ShippingMethod.fast)
          Padding(
            padding: const EdgeInsets.only(top: AppColors.s8),
            child: Text(
              '* Phí ship giao nhanh đang được cập nhật lại cho chính xác',
              style: AppTextStyles.caption(color: AppColors.warning),
            ),
          ),
      ],
    );
  }

  Widget _option({
    required ShippingMethod method,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final isSelected = selected == method;
    return GestureDetector(
      onTap: () {
        if (isSelected) return;
        onChanged(method);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: AppColors.s16, vertical: AppColors.s12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primarySubtle : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 0.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? AppColors.primary : AppColors.border, width: 2),
              ),
              child: isSelected
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
                color: isSelected ? AppColors.primary : AppColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: isSelected ? Colors.white : AppColors.textTertiary),
            ),
            const SizedBox(width: AppColors.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppTextStyles.title(color: isSelected ? AppColors.primary : AppColors.textPrimary)),
                  Text(subtitle, style: AppTextStyles.caption()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}