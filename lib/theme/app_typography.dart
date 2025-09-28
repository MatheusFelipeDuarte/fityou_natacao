import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Define a tipografia base do app com foco em legibilidade em celular e tablet.
class AppTypography {
  AppTypography._();

  static TextTheme textTheme = const TextTheme(
    displayLarge: TextStyle(fontSize: 48, fontWeight: FontWeight.w700, height: 1.2, color: AppColors.textPrimary),
    displayMedium: TextStyle(fontSize: 40, fontWeight: FontWeight.w700, height: 1.2, color: AppColors.textPrimary),
    displaySmall: TextStyle(fontSize: 34, fontWeight: FontWeight.w700, height: 1.2, color: AppColors.textPrimary),

    headlineLarge: TextStyle(fontSize: 30, fontWeight: FontWeight.w700, height: 1.25, color: AppColors.textPrimary),
    headlineMedium: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, height: 1.25, color: AppColors.textPrimary),
    headlineSmall: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, height: 1.25, color: AppColors.textPrimary),

    titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, height: 1.3, color: AppColors.textPrimary),
    titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, height: 1.3, color: AppColors.textPrimary),
    titleSmall: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.3, color: AppColors.textPrimary),

    bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 1.5, color: AppColors.textSecondary),
    bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, height: 1.5, color: AppColors.textSecondary),
    bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, height: 1.4, color: AppColors.textSecondary),

    labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
    labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
    labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
  );
}
