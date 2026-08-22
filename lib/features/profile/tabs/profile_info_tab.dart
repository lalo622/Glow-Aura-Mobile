import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:glow_aura/core/theme/app_theme.dart';
import 'package:glow_aura/features/profile/widgets/profile_menu_card.dart';

class ProfileInfoTab extends StatelessWidget {
  final bool isVip;
  final bool reminderEnabled;
  final ValueChanged<bool> onReminderChanged;
  final VoidCallback onLogout;

  const ProfileInfoTab({
    super.key,
    required this.isVip,
    required this.reminderEnabled,
    required this.onReminderChanged,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppColors.s16),
      child: Column(
        children: [
          const SizedBox(height: AppColors.s24),

          const SectionLabel('THÔNG TIN CÁ NHÂN'),
          const SizedBox(height: AppColors.s8),
          ProfileMenuCard(items: [
            MenuItemData(
              icon: Icons.person_outline,
              iconBg: AppColors.primaryTint,
              iconColor: AppColors.primary,
              label: 'Chỉnh sửa hồ sơ',
              onTap: () => context.go('/edit-profile'),
            ),
            MenuItemData(
              icon: Icons.lock_outline,
              iconBg: AppColors.primaryTint,
              iconColor: AppColors.primary,
              label: 'Đổi mật khẩu',
              onTap: () => context.go('/change-password'),
            ),
            MenuItemData(
              icon: Icons.receipt_long_outlined,
              iconBg: AppColors.primaryTint,
              iconColor: AppColors.primary,
              label: 'Lịch sử đơn hàng',
              onTap: () => context.go('/order-history'),
            ),
            MenuItemData(
              icon: Icons.monitor_heart_outlined,
              iconBg: AppColors.primaryTint,
              iconColor: AppColors.primary,
              label: 'Chỉ số sức khỏe da',
              onTap: () {},
            ),
          ]),
          const SizedBox(height: AppColors.s24),

          const SectionLabel('CHU TRÌNH CHĂM SÓC DA'),
          const SizedBox(height: AppColors.s8),
          ProfileMenuCard(items: [
            MenuItemData(
              icon: Icons.calendar_today_outlined,
              iconBg: AppColors.primaryTint,
              iconColor: AppColors.primary,
              label: 'Cài đặt chu trình',
              subtitle: 'Sáng & Tối hàng ngày',
              onTap: () {},
            ),
            MenuItemData(
              icon: Icons.inventory_2_outlined,
              iconBg: AppColors.primaryTint,
              iconColor: AppColors.primary,
              label: 'Tủ đồ mỹ phẩm của tôi',
              onTap: () {},
            ),
            MenuItemData(
              icon: Icons.notifications_outlined,
              iconBg: AppColors.primaryTint,
              iconColor: AppColors.primary,
              label: 'Lời nhắc chăm sóc',
              onTap: () {},
              trailing: Switch(
                value: reminderEnabled,
                onChanged: onReminderChanged,
                activeThumbColor: AppColors.primary,
              ),
            ),
          ]),
          const SizedBox(height: AppColors.s24),

          const SectionLabel('PREMIUM & HỖ TRỢ'),
          const SizedBox(height: AppColors.s8),
          ProfileMenuCard(items: [
            MenuItemData(
              icon: Icons.workspace_premium_outlined,
              iconBg: const Color(0xFFFBF1DE),
              iconColor: AppColors.accentGold,
              label: 'Gói hội viên Premium',
              onTap: () {},
              trailing: isVip
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppColors.s8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('ĐANG KÍCH HOẠT',
                          style: AppTextStyles.label(color: Colors.white)),
                    )
                  : null,
            ),
            MenuItemData(
              icon: Icons.help_outline,
              iconBg: AppColors.primaryTint,
              iconColor: AppColors.primary,
              label: 'Trung tâm trợ giúp',
              onTap: () {},
            ),
          ]),
          const SizedBox(height: AppColors.s24),

          GestureDetector(
            onTap: onLogout,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: AppColors.s16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.logout, color: AppColors.error, size: 20),
                  const SizedBox(width: AppColors.s8),
                  Text('Đăng xuất',
                      style: AppTextStyles.title(color: AppColors.error)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}