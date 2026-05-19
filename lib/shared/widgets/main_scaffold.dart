import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:glow_aura/core/theme/app_theme.dart';

class MainScaffold extends StatelessWidget {
  final Widget body;
  final int currentIndex;

  const MainScaffold({
    super.key,
    required this.body,
    required this.currentIndex,
  });

  void _onNavTap(BuildContext context, int index) {
    switch (index) {
      case 0: context.go('/home'); break;
      case 1: context.go('/history'); break;
      case 2: context.go('/advice'); break;
      case 3: context.go('/profile'); break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: body,
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/scan-guide'),
        backgroundColor: AppColors.primary,
        shape: const CircleBorder(),
        child: const Icon(Icons.camera_alt, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: AppColors.surface,
        elevation: 8,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home,
                  label: 'TRANG CHỦ', index: 0, currentIndex: currentIndex,
                  onTap: (i) => _onNavTap(context, i)),
              _NavItem(icon: Icons.bar_chart_outlined, activeIcon: Icons.bar_chart,
                  label: 'PHÂN TÍCH', index: 1, currentIndex: currentIndex,
                  onTap: (i) => _onNavTap(context, i)),

              const SizedBox(width: 48), 

              _NavItem(icon: Icons.storefront_outlined, activeIcon: Icons.storefront,
                  label: 'SẢN PHẨM', index: 2, currentIndex: currentIndex,
                  onTap: (i) => _onNavTap(context, i)),
              _NavItem(icon: Icons.person_outline, activeIcon: Icons.person,
                  label: 'HỒ SƠ', index: 3, currentIndex: currentIndex,
                  onTap: (i) => _onNavTap(context, i)),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon, activeIcon;
  final String label;
  final int index, currentIndex;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.icon, required this.activeIcon, required this.label,
    required this.index, required this.currentIndex, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = index == currentIndex;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? AppColors.primary : AppColors.textTertiary,
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(label,
                style: AppTextStyles.label(
                    color: isActive ? AppColors.primary : AppColors.textTertiary)),
          ],
        ),
      ),
    );
  }
}