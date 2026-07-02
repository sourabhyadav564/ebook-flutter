import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    final base = ThemeData.dark();
    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surfaceDark,
        error: AppColors.error,
        onPrimary: Colors.black,
        onSurface: AppColors.textPrimary,
      ),
      scaffoldBackgroundColor: AppColors.bgDark,
      cardTheme: base.cardTheme.copyWith(
        color: AppColors.cardDark,
        elevation: 4.0,
        margin: EdgeInsets.zero,
      ),
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: AppColors.textPrimary,
        elevation: 0.0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20.0,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
      floatingActionButtonTheme: base.floatingActionButtonTheme.copyWith(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.black,
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: AppColors.cardDark,
        selectedColor: AppColors.primary.withOpacity(0.25),
        labelStyle: const TextStyle(color: AppColors.textPrimary),
        side: const BorderSide(color: AppColors.secondary),
      ),
      inputDecorationTheme: base.inputDecorationTheme.copyWith(
        filled: true,
        fillColor: AppColors.cardDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: AppColors.secondary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: AppColors.secondary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: AppColors.primary, width: 2.0),
        ),
        hintStyle: const TextStyle(color: AppColors.textSecondary),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15.0),
        ),
      ),
      textTheme: base.textTheme.copyWith(
        displayLarge: (base.textTheme.displayLarge ?? const TextStyle()).copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w800,
        ),
        headlineMedium: (base.textTheme.headlineMedium ?? const TextStyle()).copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: (base.textTheme.titleLarge ?? const TextStyle()).copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: (base.textTheme.titleMedium ?? const TextStyle()).copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: (base.textTheme.bodyLarge ?? const TextStyle()).copyWith(
          color: AppColors.textPrimary,
        ),
        bodyMedium: (base.textTheme.bodyMedium ?? const TextStyle()).copyWith(
          color: AppColors.textSecondary,
        ),
        labelLarge: (base.textTheme.labelLarge ?? const TextStyle()).copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static ThemeData get light => dark; // Use dark as the primary theme
}
