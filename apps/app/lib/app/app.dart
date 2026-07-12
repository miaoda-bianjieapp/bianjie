import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import 'router.dart';

class BianjieAiApp extends StatelessWidget {
  const BianjieAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '边界 AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: appRouter,
    );
  }
}
