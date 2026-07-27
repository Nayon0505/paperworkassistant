import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';

abstract final class AppTheme {
  static final light = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.canvas,
    colorScheme: const ColorScheme.light(
      primary: AppColors.navy900,
      onPrimary: AppColors.white,
      secondary: AppColors.green600,
      onSecondary: AppColors.white,
      surface: AppColors.white,
      onSurface: AppColors.ink,
      outline: AppColors.border,
      error: Color(0xFFB3261E),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 58,
        height: 1.06,
        fontWeight: FontWeight.w800,
        letterSpacing: -2.2,
        color: AppColors.navy950,
      ),
      displaySmall: TextStyle(
        fontSize: 38,
        height: 1.12,
        fontWeight: FontWeight.w800,
        letterSpacing: -1,
        color: AppColors.navy950,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        height: 1.2,
        fontWeight: FontWeight.w700,
        color: AppColors.navy950,
      ),
      headlineSmall: TextStyle(
        fontSize: 22,
        height: 1.25,
        fontWeight: FontWeight.w700,
        color: AppColors.navy950,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        height: 1.3,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      ),
      bodyLarge: TextStyle(fontSize: 17, height: 1.55, color: AppColors.muted),
      bodyMedium: TextStyle(fontSize: 15, height: 1.5, color: AppColors.muted),
      labelLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: 18,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: 18,
        ),
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
        ),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: AppColors.white,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 1),
    navigationBarTheme: NavigationBarThemeData(
      height: 76,
      backgroundColor: AppColors.white,
      indicatorColor: AppColors.green100,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        return TextStyle(
          fontSize: 11,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w700
              : FontWeight.w500,
          color: AppColors.navy900,
        );
      }),
    ),
    navigationRailTheme: const NavigationRailThemeData(
      backgroundColor: AppColors.white,
      indicatorColor: AppColors.green100,
      selectedIconTheme: IconThemeData(color: AppColors.green700),
      unselectedIconTheme: IconThemeData(color: AppColors.muted),
      selectedLabelTextStyle: TextStyle(
        color: AppColors.navy900,
        fontWeight: FontWeight.w700,
      ),
      unselectedLabelTextStyle: TextStyle(color: AppColors.muted),
    ),
  );
}
