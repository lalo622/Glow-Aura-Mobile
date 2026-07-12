import 'package:flutter/material.dart';
import 'package:glow_aura/core/theme/app_theme.dart';

class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(text, style: AppTextStyles.label()),
    );
  }
}

class MenuItemData {
  final IconData icon;
  final Color iconBg, iconColor;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;
  final Widget? trailing;

  const MenuItemData({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.onTap,
    this.subtitle,
    this.trailing,
  });
}

class ProfileMenuCard extends StatelessWidget {
  final List<MenuItemData> items;
  const ProfileMenuCard({super.key, required this.items});

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
                const Divider(height: 1, color: AppColors.border, indent: 56),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _MenuItemTile extends StatelessWidget {
  final MenuItemData item;
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