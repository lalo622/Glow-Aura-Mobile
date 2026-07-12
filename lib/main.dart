import 'package:flutter/material.dart';
import 'package:flutter/services.dart';               
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glow_aura/core/theme/app_theme.dart';
import 'package:glow_aura/core/theme/theme_provider.dart';
import 'package:glow_aura/core/router/app_router.dart';

void main() async {                                     
  WidgetsFlutterBinding.ensureInitialized();             
  await SystemChrome.setPreferredOrientations([          
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const ProviderScope(child: GlowAuraApp()));
}

class GlowAuraApp extends ConsumerWidget {
  const GlowAuraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);
    return MaterialApp.router(
      title: 'Glow Aura',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      routerConfig: AppRouter.router,
    );
  }
}