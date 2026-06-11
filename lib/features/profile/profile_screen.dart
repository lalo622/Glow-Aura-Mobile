import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:glow_aura/core/theme/app_theme.dart';
import 'package:glow_aura/features/auth/auth_viewmodel.dart';
import 'package:glow_aura/features/profile/profile_viewmodel.dart';
import 'package:glow_aura/shared/widgets/main_scaffold.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _reminderEnabled = true;

  @override
  void initState() {
    super.initState();
    // Load profile từ BE khi vào màn hình
    Future.microtask(() =>
        ref.read(profileViewModelProvider.notifier).loadProfile());
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileViewModelProvider);
    final authState = ref.watch(authViewModelProvider);

    // Ưu tiên dùng data từ profileViewModel (đầy đủ hơn),
    // fallback về authViewModel nếu chưa load xong
    final fullName = profileState.profile?.fullName ??
        authState.user?.fullName ?? '---';
    final email = profileState.profile?.email ??
        authState.user?.email ?? '---';
    final vipLevel = profileState.profile?.vipLevel ??
        authState.user?.vipLevel ?? 'None';
    final skinType = profileState.profile?.skinType ?? '---';
    final age = profileState.profile?.age?.toString() ?? '---';
    final isVip = vipLevel != 'None';

    return MainScaffold(
      currentIndex: 3,
      body: SafeArea(
        child: Column(
          children: [
            // ── App bar ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppColors.s16, vertical: AppColors.s12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.go('/home'),
                    icon: const Icon(Icons.arrow_back,
                        color: AppColors.textPrimary),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: AppColors.s12),
                  Expanded(
                    child: Text('Hồ sơ người dùng',
                        style: AppTextStyles.title(),
                        textAlign: TextAlign.center),
                  ),
                  IconButton(
                    onPressed: () => context.go('/settings'),
                    icon: const Icon(Icons.settings_outlined,
                        color: AppColors.textSecondary),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            Container(height: 1, color: AppColors.border),

            Expanded(
              child: profileState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppColors.s16),
                      child: Column(
                        children: [
                          const SizedBox(height: AppColors.s24),

                          // ── Avatar + info ─────────────────────────────
                          _AvatarSection(
                            fullName: fullName,
                            email: email,
                            isVip: isVip,
                          ),
                          const SizedBox(height: AppColors.s16),

                          // ── Stats row ──────────────────────────────────
                          _StatsRow(
                            skinType: skinType,
                            age: age,
                          ),
                          const SizedBox(height: AppColors.s24),

                          // ── Section: Thông tin cá nhân ─────────────────
                          _SectionLabel('THÔNG TIN CÁ NHÂN'),
                          const SizedBox(height: AppColors.s8),
                          _MenuCard(items: [
                            _MenuItem(
                              icon: Icons.person_outline,
                              iconBg: AppColors.primaryTint,
                              iconColor: AppColors.primary,
                              label: 'Chỉnh sửa hồ sơ',
                              onTap: () => context.go('/edit-profile'),
                            ),
                            _MenuItem(
                              icon: Icons.monitor_heart_outlined,
                              iconBg: AppColors.primaryTint,
                              iconColor: AppColors.primary,
                              label: 'Chỉ số sức khỏe da',
                              onTap: () {},
                            ),
                          ]),
                          const SizedBox(height: AppColors.s24),

                          // ── Section: Chu trình chăm sóc da ────────────
                          _SectionLabel('CHU TRÌNH CHĂM SÓC DA'),
                          const SizedBox(height: AppColors.s8),
                          _MenuCard(items: [
                            _MenuItem(
                              icon: Icons.calendar_today_outlined,
                              iconBg: AppColors.primaryTint,
                              iconColor: AppColors.primary,
                              label: 'Cài đặt chu trình',
                              subtitle: 'Sáng & Tối hàng ngày',
                              onTap: () {},
                            ),
                            _MenuItem(
                              icon: Icons.inventory_2_outlined,
                              iconBg: AppColors.primaryTint,
                              iconColor: AppColors.primary,
                              label: 'Tủ đồ mỹ phẩm của tôi',
                              onTap: () {},
                            ),
                            _MenuItem(
                              icon: Icons.notifications_outlined,
                              iconBg: AppColors.primaryTint,
                              iconColor: AppColors.primary,
                              label: 'Lời nhắc chăm sóc',
                              onTap: () {},
                              trailing: Switch(
                                value: _reminderEnabled,
                                onChanged: (v) =>
                                    setState(() => _reminderEnabled = v),
                                activeThumbColor: AppColors.primary,
                              ),
                            ),
                          ]),
                          const SizedBox(height: AppColors.s24),

                          // ── Section: Premium & Hỗ trợ ─────────────────
                          _SectionLabel('PREMIUM & HỖ TRỢ'),
                          const SizedBox(height: AppColors.s8),
                          _MenuCard(items: [
                            _MenuItem(
                              icon: Icons.workspace_premium_outlined,
                              iconBg: const Color(0xFFFBF1DE),
                              iconColor: AppColors.accentGold,
                              label: 'Gói hội viên Premium',
                              onTap: () {},
                              trailing: isVip
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: AppColors.s8,
                                          vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius:
                                            BorderRadius.circular(20),
                                      ),
                                      child: Text('ĐANG KÍCH HOẠT',
                                          style: AppTextStyles.label(
                                              color: Colors.white)),
                                    )
                                  : null,
                            ),
                            _MenuItem(
                              icon: Icons.help_outline,
                              iconBg: AppColors.primaryTint,
                              iconColor: AppColors.primary,
                              label: 'Trung tâm trợ giúp',
                              onTap: () {},
                            ),
                          ]),
                          const SizedBox(height: AppColors.s24),

                          // ── Logout button ──────────────────────────────
                          GestureDetector(
                            onTap: () => _showLogoutDialog(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: AppColors.s16),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.logout,
                                      color: AppColors.error, size: 20),
                                  const SizedBox(width: AppColors.s8),
                                  Text('Đăng xuất',
                                      style: AppTextStyles.title(
                                          color: AppColors.error)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: Text('Đăng xuất', style: AppTextStyles.heading()),
        content: Text(
          'Bạn có chắc chắn muốn đăng xuất không?',
          style: AppTextStyles.body(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Huỷ',
                style: AppTextStyles.body(
                    color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              // Gọi logout thật — xóa token + revoke BE
              await ref
                  .read(authViewModelProvider.notifier)
                  .logout();
              if (context.mounted) context.go('/login');
            },
            child: Text('Đăng xuất',
                style: AppTextStyles.body(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

// ── Avatar section ────────────────────────────────────────────────────────────
class _AvatarSection extends StatelessWidget {
  final String fullName;
  final String email;
  final bool isVip;

  const _AvatarSection({
    required this.fullName,
    required this.email,
    required this.isVip,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryTint,
                border: Border.all(color: AppColors.primary, width: 2),
              ),
              child: const Icon(Icons.person,
                  size: 50, color: AppColors.primary),
            ),
            if (isVip)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppColors.s8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('PREMIUM',
                        style: AppTextStyles.label(color: Colors.white)),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppColors.s12),
        Text(fullName, style: AppTextStyles.heading()),
        const SizedBox(height: AppColors.s4),
        Text(email,
            style: AppTextStyles.body(color: AppColors.textSecondary)),
      ],
    );
  }
}

// ── Stats row ─────────────────────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  final String skinType;
  final String age;

  const _StatsRow({required this.skinType, required this.age});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          vertical: AppColors.s12, horizontal: AppColors.s8),
      decoration: BoxDecoration(
        color: AppColors.primarySubtle,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryTint),
      ),
      child: Row(
        children: [
          _StatItem(label: 'LOẠI DA', value: skinType),
          _Divider(),
          _StatItem(label: 'ĐỘ TUỔI', value: age),
          _Divider(),
          const _StatItem(label: 'ĐIỂM GLOW', value: '---'),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label, value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: AppTextStyles.label()),
          const SizedBox(height: AppColors.s4),
          Text(value,
              style: AppTextStyles.title(color: AppColors.primary),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 32, color: AppColors.primaryTint);
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(text, style: AppTextStyles.label()),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final List<_MenuItem> items;
  const _MenuCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          return Column(
            children: [
              _MenuItemTile(item: item),
              if (i < items.length - 1)
                const Divider(
                    height: 1, color: AppColors.border, indent: 56),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _MenuItemTile extends StatelessWidget {
  final _MenuItem item;
  const _MenuItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.trailing is Switch ? null : item.onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppColors.s16, vertical: AppColors.s12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: item.iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(item.icon, color: item.iconColor, size: 18),
            ),
            const SizedBox(width: AppColors.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.label, style: AppTextStyles.title()),
                  if (item.subtitle != null)
                    Text(item.subtitle!, style: AppTextStyles.caption()),
                ],
              ),
            ),
            item.trailing ??
                const Icon(Icons.chevron_right,
                    color: AppColors.textTertiary, size: 20),
          ],
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final Color iconBg, iconColor;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;
  final Widget? trailing;

  const _MenuItem({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.onTap,
    this.subtitle,
    this.trailing,
  });
}