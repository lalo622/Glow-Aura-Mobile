import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class ShippingFormSection extends StatelessWidget {
  final TextEditingController fullNameCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController addressCtrl;
  final VoidCallback onPickAddress;
  final VoidCallback onClearAddress;

  const ShippingFormSection({
    super.key,
    required this.fullNameCtrl,
    required this.phoneCtrl,
    required this.emailCtrl,
    required this.addressCtrl,
    required this.onPickAddress,
    required this.onClearAddress,
  });

  @override
  Widget build(BuildContext context) {
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
                child: _field(
                  label: 'Họ và tên',
                  required: true,
                  controller: fullNameCtrl,
                  hint: 'Nguyễn Văn A',
                  keyboardType: TextInputType.name,
                  validator: (v) => (v == null || v.isEmpty) ? 'Vui lòng nhập họ tên' : null,
                ),
              ),
              const SizedBox(width: AppColors.s8),
              Expanded(
                child: _field(
                  label: 'Số điện thoại',
                  required: true,
                  controller: phoneCtrl,
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
          _field(
            label: 'Email (nhận hóa đơn)',
            controller: emailCtrl,
            hint: 'example@gmail.com',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: AppColors.s12),
          _addressPicker(),
        ],
      ),
    );
  }

  Widget _field({
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

  Widget _addressPicker() {
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
        addressCtrl.text.isEmpty
            ? GestureDetector(
                onTap: onPickAddress,
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primarySubtle,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.primaryTint, width: 1, style: BorderStyle.solid),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.map_outlined, color: AppColors.primary, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Chọn địa chỉ trên bản đồ',
                        style: AppTextStyles.body(color: AppColors.primary)
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              )
            : Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: addressCtrl,
                      style: AppTextStyles.body(color: AppColors.textPrimary),
                      maxLines: 2,
                      validator: (v) => (v == null || v.length < 10) ? 'Vui lòng chọn địa chỉ' : null,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.location_on_outlined, color: AppColors.primary, size: 18),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onClearAddress,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border, width: 0.5),
                      ),
                      child: const Icon(Icons.edit_location_outlined, size: 16, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
      ],
    );
  }
}