import 'package:flutter/material.dart';

enum AppVisualTheme { signal, night }

class AppColors {
  const AppColors._();

  static const _signal = _AppPalette(
    primary: Color(0xFF1597A6),
    primaryDark: Color(0xFF0D6F7B),
    onPrimary: Color(0xFFFFFFFF),
    navigationActive: Color(0xFF242725),
    navigationIndicator: Color(0x00000000),
    surface: Color(0xFFFAFBFA),
    surfaceSoft: Color(0xFFF2F4F3),
    card: Color(0xFFFFFFFF),
    featuredSurface: Color(0xFF202725),
    chip: Color(0xFFF3F5F4),
    border: Color(0xFFE5E9E7),
    textPrimary: Color(0xFF282B29),
    textSecondary: Color(0xFF6F7471),
    textTertiary: Color(0xFF9BA09D),
  );

  static const _night = _AppPalette(
    primary: Color(0xFF54DFCF),
    primaryDark: Color(0xFF2BB6A8),
    onPrimary: Color(0xFF071714),
    navigationActive: Color(0xFF54DFCF),
    navigationIndicator: Color(0x2454DFCF),
    surface: Color(0xFF0D1110),
    surfaceSoft: Color(0xFF202826),
    card: Color(0xFF171D1B),
    featuredSurface: Color(0xFF202725),
    chip: Color(0xFF202826),
    border: Color(0xFF2B3532),
    textPrimary: Color(0xFFF1F0E8),
    textSecondary: Color(0xFFA4B0AB),
    textTertiary: Color(0xFF7F8B86),
  );

  static _AppPalette _active = _night;

  static void use(AppVisualTheme visualTheme) {
    _active = visualTheme == AppVisualTheme.signal ? _signal : _night;
  }

  static Color get primaryBlue => _active.primary;
  static Color get primaryBlueDark => _active.primaryDark;
  static Color get onPrimary => _active.onPrimary;
  static Color get navigationActive => _active.navigationActive;
  static Color get navigationIndicator => _active.navigationIndicator;
  static Color get surface => _active.surface;
  static Color get surfaceSoft => _active.surfaceSoft;
  static Color get card => _active.card;
  static Color get featuredSurface => _active.featuredSurface;
  static Color get chip => _active.chip;
  static Color get border => _active.border;
  static Color get textPrimary => _active.textPrimary;
  static Color get textSecondary => _active.textSecondary;
  static Color get textTertiary => _active.textTertiary;
  static const success = Color(0xFF4ED29A);
  static const warning = Color(0xFFFFBE65);
  static const danger = Color(0xFFFF6B78);
  static const accentBlue = Color(0xFF66A3FF);
  static const accentOrange = Color(0xFFFF8A65);
  static const accentCyan = Color(0xFF54DFCF);
  static const accentGreen = Color(0xFF5BDA91);
  static const accentPurple = Color(0xFFB496FF);
}

class _AppPalette {
  const _AppPalette({
    required this.primary,
    required this.primaryDark,
    required this.onPrimary,
    required this.navigationActive,
    required this.navigationIndicator,
    required this.surface,
    required this.surfaceSoft,
    required this.card,
    required this.featuredSurface,
    required this.chip,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
  });

  final Color primary;
  final Color primaryDark;
  final Color onPrimary;
  final Color navigationActive;
  final Color navigationIndicator;
  final Color surface;
  final Color surfaceSoft;
  final Color card;
  final Color featuredSurface;
  final Color chip;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
}
