import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:glow_aura/core/theme/app_theme.dart';
import 'package:glow_aura/features/auth/auth_viewmodel.dart';
import 'package:glow_aura/features/profile/profile_viewmodel.dart';
import 'package:glow_aura/features/profile/tabs/profile_info_tab.dart';
import 'package:glow_aura/features/profile/tabs/scan_history_tab.dart';
import 'package:glow_aura/features/profile/widgets/profile_avatar_section.dart';
import 'package:glow_aura/features/profile/widgets/profile_stats_row.dart';
import 'package:glow_aura/shared/widgets/main_scaffold.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  bool _reminderEnabled = true;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(
        () => ref.read(profileViewModelProvider.notifier).loadProfile());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileViewModelProvider);
    final authState = ref.watch(authViewModelProvider);

    final fullName =
        profileState.profile?.fullName ?? authState.user?.fullName ?? '---';
    final email =
        profileState.profile?.email ?? authState.user?.email ?? '---';
    final vipLevel =
        profileState.profile?.vipLevel ?? authState.user?.vipLevel ?? 'None';
    final skinType = profileState.profile?.skinType ?? '---';
    final age = profileState.profile?.age?.toString() ?? '---';
    final isVip = vipLevel != 'None';

    return MainScaffold(
      currentIndex: 3,
      body: SafeArea(
        child: Column(
          children: [
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

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppColors.s16),
              child: Column(
                children: [
                  const SizedBox(height: AppColors.s24),
                  ProfileAvatarSection(
                      fullName: fullName, email: email, isVip: isVip),
                  const SizedBox(height: AppColors.s16),
                  ProfileStatsRow(skinType: skinType, age: age),
                  const SizedBox(height: AppColors.s8),
                ],
              ),
            ),

            TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              indicatorSize: TabBarIndicatorSize.tab,
              labelStyle: AppTextStyles.title(),
              tabs: const [
                Tab(text: 'Hồ sơ'),
                Tab(text: 'Lịch sử chụp'),
              ],
            ),
            Container(height: 1, color: AppColors.border),

            Expanded(
              child: profileState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        ProfileInfoTab(
                          isVip: isVip,
                          reminderEnabled: _reminderEnabled,
                          onReminderChanged: (v) =>
                              setState(() => _reminderEnabled = v),
                          onLogout: () => _showLogoutDialog(context),
                        ),
                        const ScanHistoryTab(),
                      ],
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Đăng xuất', style: AppTextStyles.heading()),
        content: Text(
          'Bạn có chắc chắn muốn đăng xuất không?',
          style: AppTextStyles.body(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Huỷ',
                style: AppTextStyles.body(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authViewModelProvider.notifier).logout();
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