import 'package:flutter/material.dart';
import 'package:glow_aura/core/theme/app_theme.dart';

class ProfileAvatarSection extends StatelessWidget {
  final String fullName;
  final String email;
  final bool isVip;

  const ProfileAvatarSection({
    super.key,
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
              child:
                  const Icon(Icons.person, size: 50, color: AppColors.primary),
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
        Text(email, style: AppTextStyles.body(color: AppColors.textSecondary)),
      ],
    );
  }
}