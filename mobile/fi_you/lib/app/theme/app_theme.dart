import 'package:flutter/material.dart';

class FiYouColors {
  static const canvas = Color(0xFF020714);
  static const night = Color(0xFF070B18);
  static const panel = Color(0xFF0E1426);
  static const panelDeep = Color(0xFF090E1C);
  static const ink = Color(0xFFFFFFFF);
  static const text = Color(0xFFAAB2C8);
  static const muted = Color(0xFF737C95);
  static const line = Color(0x1AFFFFFF);
  static const violet = Color(0xFF8B5CF6);
  static const violetSoft = Color(0xFFBCA7FF);
  static const purple = Color(0xFFA855F7);
  static const blue = Color(0xFF7EA6FF);
  static const cyan = Color(0xFF63F2D1);
  static const gold = Color(0xFFF8C66C);
  static const danger = Color(0xFFFF7C8A);
}

class AppTheme {
  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    final textTheme = base.textTheme.apply(
      bodyColor: FiYouColors.ink,
      displayColor: FiYouColors.ink,
      fontFamily: 'Roboto',
    );

    return base.copyWith(
      scaffoldBackgroundColor: FiYouColors.canvas,
      colorScheme: const ColorScheme.dark(
        primary: FiYouColors.violet,
        secondary: FiYouColors.cyan,
        tertiary: FiYouColors.gold,
        surface: FiYouColors.panel,
        error: FiYouColors.danger,
      ),
      textTheme: textTheme.copyWith(
        displaySmall: textTheme.displaySmall?.copyWith(
          fontWeight: FontWeight.w900,
          letterSpacing: 0,
          height: 1.05,
        ),
        headlineMedium: textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w900,
          letterSpacing: 0,
          height: 1.12,
        ),
        headlineSmall: textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w900,
          letterSpacing: 0,
          height: 1.16,
        ),
        titleLarge: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
          height: 1.24,
        ),
        titleMedium: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
          height: 1.28,
        ),
        bodyLarge: textTheme.bodyLarge?.copyWith(
          color: FiYouColors.text,
          height: 1.52,
          letterSpacing: 0,
        ),
        bodyMedium: textTheme.bodyMedium?.copyWith(
          color: FiYouColors.text,
          height: 1.48,
          letterSpacing: 0,
        ),
        bodySmall: textTheme.bodySmall?.copyWith(
          color: FiYouColors.muted,
          height: 1.45,
          letterSpacing: 0,
        ),
        labelLarge: textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.065),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: FiYouColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: FiYouColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: FiYouColors.violetSoft),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: FiYouColors.danger),
        ),
        labelStyle: const TextStyle(color: FiYouColors.text),
        hintStyle: const TextStyle(color: FiYouColors.muted),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: FiYouColors.violetSoft,
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: FiYouColors.ink,
          backgroundColor: Colors.white.withValues(alpha: 0.07),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: FiYouColors.panel,
        contentTextStyle: const TextStyle(color: FiYouColors.ink),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: FiYouColors.panel,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
