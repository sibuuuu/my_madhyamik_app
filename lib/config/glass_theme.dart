// lib/config/glass_theme.dart
//
// Light theme design system for Madhyamik Shokha.
// Developer: Sibnath Bairagi

import 'package:flutter/material.dart';

class GlassTheme {
  GlassTheme._();

  // FONTS
  static const String fontPrimary = 'PlusJakartaSans';
  static const String fontBengali = 'HindSiliguri';
  static const List<String> fontFallback = [fontBengali];

  // BACKGROUND
  static const Color backgroundLight = Color(0xFFF2F2F7);
  static const Color backgroundDark = Color(0xFF121212);

  static const LinearGradient backgroundGradientLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFF8F8FA),
      Color(0xFFEDEDF2),
      Color(0xFFF5F5F7),
    ],
  );

  static const LinearGradient backgroundGradientDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF121212),
      Color(0xFF0E1013),
      Color(0xFF121212),
    ],
  );

  // GLASS SURFACES
  static const Color glassSurfaceLight = Color(0xE6FFFFFF);
  static const Color glassInputLight = Color(0xCCFFFFFF);
  static const Color glassSurfaceDark = Color(0x1AFFFFFF);
  static const Color glassInputDark = Color(0x0DFFFFFF);

  // BORDERS
  static const Color borderLight = Color(0x80FFFFFF);
  static const Color borderLightStrong = Color(0xB3FFFFFF);
  static const Color borderLightFaint = Color(0x33FFFFFF);
  static const Color borderDark = Color(0x33FFFFFF);

  // ACCENTS
  static const Color accentRed = Color(0xFFEF4444);
  static const Color accentRedDark = Color(0xFFDC2626);
  static const Color accentBlue = Color(0xFF3B82F6);
  static const Color accentBlueDark = Color(0xFF2563EB);
  static const Color accentGreen = Color(0xFF10B981);
  static const Color accentAmber = Color(0xFFF59E0B);
  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color accentGold = Color(0xFFE5B85C);
  static const Color accentSilver = Color(0xFF9CA3AF);
  static const Color accentBronze = Color(0xFFCD7F32);

  // TEXT COLORS — LIGHT
  static const Color textPrimaryLight = Color(0xFF1C1C1E);
  static const Color textSecondaryLight = Color(0xFF4A4A4F);
  static const Color textTertiaryLight = Color(0xFF7A7A80);
  static const Color textHintLight = Color(0xFF9A9AA0);
  static const Color textOnAccent = Color(0xFFFFFFFF);

  // TEXT COLORS — DARK
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB3B3B8);
  static const Color textTertiaryDark = Color(0xFF808085);
  static const Color textHintDark = Color(0xFF666670);

  // BLUR
  static const double blurSmall = 10.0;
  static const double blurMedium = 18.0;
  static const double blurLarge = 24.0;
  static const double blurXLarge = 30.0;

  // RADIUS
  static const double radiusSmall = 10.0;
  static const double radiusMedium = 14.0;
  static const double radiusLarge = 20.0;
  static const double radiusXLarge = 24.0;
  static const double radiusFull = 999.0;

  // SPACING
  static const double spaceXS = 4.0;
  static const double spaceS = 8.0;
  static const double spaceM = 16.0;
  static const double spaceL = 24.0;
  static const double spaceXL = 32.0;
  static const double spaceXXL = 48.0;

  // SHADOWS
  static List<BoxShadow> get softShadowLight => [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get mediumShadowLight => [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get strongShadowLight => [
        BoxShadow(
          color: Colors.black.withOpacity(0.10),
          blurRadius: 40,
          offset: const Offset(0, 16),
        ),
      ];

  static List<BoxShadow> get softShadowDark => [
        BoxShadow(
          color: Colors.black.withOpacity(0.25),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get mediumShadowDark => [
        BoxShadow(
          color: Colors.black.withOpacity(0.40),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get strongShadowDark => [
        BoxShadow(
          color: Colors.black.withOpacity(0.55),
          blurRadius: 40,
          offset: const Offset(0, 16),
        ),
      ];

  // GRADIENTS
  static const LinearGradient glassHighlight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x33FFFFFF), Color(0x00FFFFFF)],
  );

  static const LinearGradient buttonRedGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentRed, accentRedDark],
  );

  static const LinearGradient buttonBlueGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentBlue, accentBlueDark],
  );

  // DURATIONS
  static const Duration durationFast = Duration(milliseconds: 180);
  static const Duration durationNormal = Duration(milliseconds: 300);
  static const Duration durationSlow = Duration(milliseconds: 500);
  static const Duration durationPageTransition = Duration(milliseconds: 350);

  // HELPERS
  static LinearGradient backgroundGradient({required bool isDark}) =>
      isDark ? backgroundGradientDark : backgroundGradientLight;

  static Color glassSurface({required bool isDark}) =>
      isDark ? glassSurfaceDark : glassSurfaceLight;

  static Color glassInput({required bool isDark}) =>
      isDark ? glassInputDark : glassInputLight;

  static Color border({required bool isDark}) =>
      isDark ? borderDark : borderLight;

  static Color textPrimary({required bool isDark}) =>
      isDark ? textPrimaryDark : textPrimaryLight;

  static Color textSecondary({required bool isDark}) =>
      isDark ? textSecondaryDark : textSecondaryLight;

  static Color textTertiary({required bool isDark}) =>
      isDark ? textTertiaryDark : textTertiaryLight;

  static Color textHint({required bool isDark}) =>
      isDark ? textHintDark : textHintLight;

  static List<BoxShadow> cardShadow({required bool isDark}) =>
      isDark ? mediumShadowDark : mediumShadowLight;

  static List<BoxShadow> softShadow({required bool isDark}) =>
      isDark ? softShadowDark : softShadowLight;

  static List<BoxShadow> strongShadow({required bool isDark}) =>
      isDark ? strongShadowDark : strongShadowLight;

  static Color backgroundBase({required bool isDark}) =>
      isDark ? backgroundDark : backgroundLight;
}