import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:glow_aura/core/theme/app_theme.dart';
import 'package:glow_aura/core/theme/theme_provider.dart';
import 'package:glow_aura/shared/widgets/main_scaffold.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider);

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
                    onPressed: () => context.go('/profile'),
                    icon: const Icon(Icons.arrow_back,
                        color: AppColors.textPrimary),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: AppColors.s12),
                  Expanded(
                    child: Text('Cài đặt', style: AppTextStyles.title()),
                  ),
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primaryTint,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person_outline,
                        color: AppColors.primary, size: 20),
                  ),
                ],
              ),
            ),
            Container(height: 1, color: AppColors.border),

            // ── Content ───────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppColors.s16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppColors.s8),

                    // ── Tài khoản & Bảo mật ───────────────────────────────
                    _SectionLabel('TÀI KHOẢN & BẢO MẬT'),
                    const SizedBox(height: AppColors.s8),
                    _MenuCard(
                      items: [
                        _MenuItem(
                          icon: Icons.notifications_outlined,
                          iconBg: const Color(0xFFE8F0FB),
                          iconColor: const Color(0xFF3B7DD8),
                          label: 'Thông báo',
                          subtitle: 'Quản lý các tin nhắn và cập nhật',
                          onTap: () {},
                        ),
                        _MenuItem(
                          icon: Icons.shield_outlined,
                          iconBg: const Color(0xFFE8F5E9),
                          iconColor: const Color(0xFF388E3C),
                          label: 'Bảo mật',
                          subtitle: 'Mật khẩu, Face ID & 2FA',
                          onTap: () {},
                        ),
                        _MenuItem(
                          icon: Icons.dark_mode_outlined,
                          iconBg: const Color(0xFFEDE7F6),
                          iconColor: const Color(0xFF6A1B9A),
                          label: 'Chế độ tối',
                          onTap: () {},
                          trailing: Switch(
                            value: isDark,
                            onChanged: (_) =>
                                ref.read(themeProvider.notifier).toggle(),
                            activeColor: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppColors.s24),

                    // ── Tuỳ chọn ─────────────────────────────────────────
                    _SectionLabel('TUỲ CHỌN'),
                    const SizedBox(height: AppColors.s8),
                    _MenuCard(
                      items: [
                        _MenuItem(
                          icon: Icons.language_outlined,
                          iconBg: const Color(0xFFFFF3E8),
                          iconColor: const Color(0xFFD4821C),
                          label: 'Ngôn ngữ',
                          onTap: () {},
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Tiếng Việt',
                                  style: AppTextStyles.body(
                                      color: AppColors.primary)),
                              const SizedBox(width: 4),
                              const Icon(Icons.chevron_right,
                                  color: AppColors.primary, size: 20),
                            ],
                          ),
                        ),
                        _MenuItem(
                          icon: Icons.help_outline,
                          iconBg: AppColors.primaryTint,
                          iconColor: AppColors.primary,
                          label: 'Hỗ trợ & Trợ giúp',
                          subtitle: 'Trung tâm trợ giúp, Liên hệ',
                          onTap: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: AppColors.s32),

                    // ── App info ──────────────────────────────────────────
                    _AppInfoCard(),
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
}

// ── App info card ─────────────────────────────────────────────────────────────
class _AppInfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            color: AppColors.primaryTint,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Center(
            child: Text('✦',
                style: TextStyle(fontSize: 36, color: AppColors.primary)),
          ),
        ),
        const SizedBox(height: AppColors.s12),
        Text('Glow Aura', style: AppTextStyles.heading()),
        const SizedBox(height: AppColors.s4),
        Text('PHIÊN BẢN 2.4.1',
            style: AppTextStyles.label(color: AppColors.textTertiary)),
        const SizedBox(height: AppColors.s16),
        Text(
          'Cảm ơn bạn đã sử dụng Glow Aura để chăm sóc vẻ đẹp tự nhiên của mình.',
          style: AppTextStyles.body(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: AppTextStyles.label(color: AppColors.primary));
  }
}

// ── Menu card ─────────────────────────────────────────────────────────────────
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
                    height: 1,
                    color: AppColors.border,
                    indent: 56),
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
              width: 36, height: 36,
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

// ── Data model ────────────────────────────────────────────────────────────────
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