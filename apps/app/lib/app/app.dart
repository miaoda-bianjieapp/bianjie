import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import '../core/theme/app_theme_provider.dart';
import 'router.dart';

class BianjieAiApp extends ConsumerWidget {
  const BianjieAiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visualTheme = ref.watch(appVisualThemeProvider);

    return MaterialApp.router(
      title: '边界 AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.forVisualTheme(visualTheme),
      themeAnimationDuration: const Duration(milliseconds: 220),
      themeAnimationCurve: Curves.easeOutCubic,
      routerConfig: appRouter,
    );
  }
}
