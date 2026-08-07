import 'package:flutter/material.dart';

/// Food Rescue color system based on UI Guidelines v1.0
/// Material 3 token mapping included
class AppColors {
  AppColors._();

  // Primary — Fresh Green
  static const Color primary = Color(0xFF2E7D32);
  static const Color onPrimary = Colors.white;
  static const Color primaryContainer = Color(0xFFE8F5E9);
  static const Color onPrimaryContainer = Color(0xFF1B5E20);
  static const Color primaryPressed = Color(0xFF1B5E20);

  // Secondary — Harvest Amber
  static const Color secondary = Color(0xFFF9A825);
  static const Color onSecondary = Color(0xFF212121);
  static const Color secondaryContainer = Color(0xFFFFF8E1);
  static const Color onSecondaryContainer = Color(0xFF5D4037);

  // Tertiary — Earth Brown
  static const Color tertiary = Color(0xFF8D6E63);
  static const Color onTertiary = Colors.white;
  static const Color tertiaryContainer = Color(0xFFEFEBE9);
  static const Color onTertiaryContainer = Color(0xFF5D4037);

  // Error
  static const Color error = Color(0xFFB3261E);
  static const Color onError = Colors.white;
  static const Color errorContainer = Color(0xFFF9DEDC);
  static const Color onErrorContainer = Color(0xFF601410);

  // Neutral
  static const Color surface = Color(0xFFFEF7FF);
  static const Color onSurface = Color(0xFF212121);
  static const Color onSurfaceVariant = Color(0xFF424242);
  static const Color surfaceVariant = Color(0xFFE8F5E9);
  static const Color outline = Color(0xFF9E9E9E);
  static const Color outlineVariant = Color(0xFFC8E6C9);

  // Semantic
  static const Color success = Color(0xFF43A047);
  static const Color info = Color(0xFF0288D1);
  static const Color infoLight = Color(0xFFE1F5FE);

  // Dark mode
  static const Color darkSurface = Color(0xFF141218);
  static const Color darkOnSurface = Color(0xFFE6E1E5);
  static const Color darkSurfaceVariant = Color(0xFF49454F);
  static const Color darkPrimary = Color(0xFF4CAF50);
  static const Color darkSecondary = Color(0xFFFFCA28);

  // Material 3 ColorScheme
  static ColorScheme get lightColorScheme => const ColorScheme(
        brightness: Brightness.light,
        primary: primary,
        onPrimary: onPrimary,
        primaryContainer: primaryContainer,
        onPrimaryContainer: onPrimaryContainer,
        secondary: secondary,
        onSecondary: onSecondary,
        secondaryContainer: secondaryContainer,
        onSecondaryContainer: onSecondaryContainer,
        tertiary: tertiary,
        onTertiary: onTertiary,
        tertiaryContainer: tertiaryContainer,
        onTertiaryContainer: onTertiaryContainer,
        error: error,
        onError: onError,
        errorContainer: errorContainer,
        onErrorContainer: onErrorContainer,
        surface: surface,
        onSurface: onSurface,
        surfaceContainerHighest: surfaceVariant,
        onSurfaceVariant: onSurfaceVariant,
        outline: outline,
        outlineVariant: outlineVariant,
        inverseSurface: onSurface,
        inversePrimary: darkPrimary,
        shadow: Colors.black,
      );

  static ColorScheme get darkColorScheme => const ColorScheme(
        brightness: Brightness.dark,
        primary: darkPrimary,
        onPrimary: Color(0xFF003300),
        primaryContainer: Color(0xFF1B5E20),
        onPrimaryContainer: primaryContainer,
        secondary: darkSecondary,
        onSecondary: onSecondary,
        secondaryContainer: Color(0xFF5D4037),
        onSecondaryContainer: secondaryContainer,
        tertiary: Color(0xFFBCAAA4),
        onTertiary: Color(0xFF3E2723),
        tertiaryContainer: Color(0xFF5D4037),
        onTertiaryContainer: tertiaryContainer,
        error: Color(0xFFF2B8B5),
        onError: Color(0xFF601410),
        errorContainer: Color(0xFF8C1D18),
        onErrorContainer: errorContainer,
        surface: darkSurface,
        onSurface: darkOnSurface,
        surfaceContainerHighest: darkSurfaceVariant,
        onSurfaceVariant: Color(0xFFCAC4D0),
        outline: Color(0xFF938F99),
        outlineVariant: darkSurfaceVariant,
        inverseSurface: darkOnSurface,
        inversePrimary: primary,
        shadow: Colors.black,
      );
}