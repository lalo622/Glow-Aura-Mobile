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
import 'package:glow_aura/features/advice/advice_screen.dart';
import 'package:glow_aura/features/onboarding/splash_screen.dart';
import 'package:glow_aura/features/profile/edit_profile_screen.dart';
import 'package:glow_aura/features/product/product_list_screen.dart';
import 'package:glow_aura/features/cart/cart_screen.dart';
import 'package:glow_aura/features/checkout/checkout_screen.dart';


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
      GoRoute(path: '/scan-result',  builder: (c, s) => const ScanResultScreen()),
      GoRoute(path: '/scan-guide',   builder: (c, s) => const ScanGuideStep1Screen()),
      GoRoute(path: '/scan-guide-2', builder: (c, s) => const ScanGuideStep2Screen()),
      GoRoute(path: '/profile', builder: (c, s) => const ProfileScreen()),
      GoRoute(path: '/settings', builder: (c, s) => const SettingsScreen()),
      GoRoute(path: '/history', builder: (c, s) => const HistoryScreen()),
      GoRoute(path: '/scan-detail',  builder: (c, s) => const ScanDetailScreen()),
      GoRoute(path: '/advice',       builder: (c, s) => const AdviceScreen()),
      GoRoute(path: '/edit-profile', builder: (c, s) => const EditProfileScreen()),
      GoRoute(path: '/products', builder: (c, s) => const ProductListScreen()),
      GoRoute(path: '/cart', builder: (c, s) => const CartScreen()),
      GoRoute(path: '/checkout', builder: (c, s) => const CheckoutScreen()),
    ],
  );
}