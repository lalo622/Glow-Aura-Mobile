import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:glow_aura/features/auth/login_screen.dart';
import 'package:glow_aura/features/auth/register_screen.dart';
import 'package:glow_aura/features/home/home_screen.dart';
import 'package:glow_aura/features/onboarding/onboarding_screen.dart';
import 'package:glow_aura/features/scan/scan_screen.dart';
import 'package:glow_aura/features/scan/scan_result_screen.dart';
import 'package:glow_aura/features/scan_guide/scan_guide_step1_screen.dart';
import 'package:glow_aura/features/scan_guide/scan_guide_step2_screen.dart';
import 'package:glow_aura/features/profile/profile_screen.dart';
import 'package:glow_aura/features/settings/settings_screen.dart';
import 'package:glow_aura/features/scan/scan_history_screen.dart';
import 'package:glow_aura/features/scan/scan_detail_screen.dart';
import 'package:glow_aura/features/onboarding/splash_screen.dart';
import 'package:glow_aura/features/profile/edit_profile_screen.dart';
import 'package:glow_aura/features/product/product_list_screen.dart';
import 'package:glow_aura/features/cart/cart_screen.dart';
import 'package:glow_aura/features/checkout/checkout_screen.dart';
import 'package:glow_aura/features/product/product_detail_screen.dart';
import 'package:glow_aura/features/scan/data/models/skin_analysis_result.dart';
import 'package:glow_aura/features/profile/change_password_screen.dart';
import 'package:glow_aura/features/profile/order_history_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(path: '/splash', builder: (c, s) => const SplashScreen()),
      GoRoute(path: '/onboarding',   builder: (c, s) => const OnboardingScreen()),
      GoRoute(path: '/login',        builder: (c, s) => const LoginScreen()),
      GoRoute(path: '/register',     builder: (c, s) => const RegisterScreen()),
      GoRoute(path: '/home',         builder: (c, s) => const HomeScreen()),
      GoRoute(path: '/scan',         builder: (c, s) => const ScanScreen()),
      GoRoute(
        path: '/scan-result',
        builder: (context, state) {
          final extra = state.extra;

          if (extra == null || extra is! Map<String, dynamic>) {
            return const Scaffold(
              body: Center(
                child: Text('Không có dữ liệu kết quả'),
              ),
            );
          }

          return ScanResultScreen(
            imagePath: extra['imagePath'] as String,
            scanId: extra['scanId'] as int,
          );
        },
      ),
      GoRoute(path: '/scan-guide',   builder: (c, s) => const ScanGuideStep1Screen()),
      GoRoute(path: '/scan-guide-2', builder: (c, s) => const ScanGuideStep2Screen()),
      GoRoute(path: '/profile', builder: (c, s) => const ProfileScreen()),
      GoRoute(path: '/settings', builder: (c, s) => const SettingsScreen()),
      GoRoute(path: '/history', builder: (c, s) => const HistoryScreen()),
      GoRoute(
        path: '/scan-detail',
        builder: (context, state) {
          final extra = state.extra;
          if (extra == null || extra is! Map<String, dynamic>) {
            return const Scaffold(
              body: Center(child: Text('Không có dữ liệu')),
            );
          }
          return ScanDetailScreen(
          imagePath: extra['imagePath'] as String,
          result: extra['result'] as SkinAnalysisResult,
        );
        },
      ),
      GoRoute(path: '/edit-profile', builder: (c, s) => const EditProfileScreen()),
      GoRoute(path: '/products', builder: (c, s) => const ProductListScreen()),
      GoRoute(
          path: '/product-detail/:id',
          builder: (context, state) => ProductDetailScreen(
            productId: state.pathParameters['id']!,
          ),
        ),
      GoRoute(path: '/cart', builder: (c, s) => const CartScreen()),
      GoRoute(path: '/checkout', builder: (c, s) => const CheckoutScreen()),
      GoRoute(path: '/change-password', builder: (c, s) => const ChangePasswordScreen()),
      GoRoute(path: '/order-history', builder: (c, s) => const OrderHistoryScreen()),
    ],
  );
}