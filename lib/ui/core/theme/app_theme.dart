import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract class AppTheme {
  static const fontFamily = 'Poppins';

  static ThemeData get dark {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: fontFamily,
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.primaryBright,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        surfaceContainerHighest: AppColors.surfaceHigh,
        onSurfaceVariant: AppColors.textSecondary,
        outline: AppColors.outline,
        error: AppColors.loss,
      ),
      textTheme: base.textTheme
          .copyWith(
            displaySmall: const TextStyle(fontSize: 34, fontWeight: FontWeight.w800, height: 1.1, letterSpacing: -0.5),
            headlineMedium: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.3),
            headlineSmall: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            titleLarge: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
            titleMedium: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            titleSmall: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            bodyLarge: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
            bodyMedium: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
            bodySmall: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            labelSmall: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2),
          )
          .apply(
            bodyColor: AppColors.textPrimary,
            displayColor: AppColors.textPrimary,
            fontFamily: fontFamily,
          ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.outline, thickness: 1, space: 1),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        hintStyle: const TextStyle(color: AppColors.textMuted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surfaceHigh,
        contentTextStyle: const TextStyle(fontFamily: fontFamily, color: AppColors.textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppColors.primary),
    );
  }
}
