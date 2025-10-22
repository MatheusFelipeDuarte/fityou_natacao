import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Define a tipografia base do app com foco em legibilidade em celular e tablet.
class AppTypography {
  AppTypography._();

  static TextTheme textTheme = const TextTheme(
    displayLarge: TextStyle(fontSize: 48, fontWeight: FontWeight.w700, height: 1.2, color: AppColors.lightTextPrimary),
    displayMedium: TextStyle(fontSize: 40, fontWeight: FontWeight.w700, height: 1.2, color: AppColors.lightTextPrimary),
    displaySmall: TextStyle(fontSize: 34, fontWeight: FontWeight.w700, height: 1.2, color: AppColors.lightTextPrimary),

    headlineLarge: TextStyle(fontSize: 30, fontWeight: FontWeight.w700, height: 1.25, color: AppColors.lightTextPrimary),
    headlineMedium: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, height: 1.25, color: AppColors.lightTextPrimary),
    headlineSmall: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, height: 1.25, color: AppColors.lightTextPrimary),

    titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, height: 1.3, color: AppColors.lightTextPrimary),
    titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, height: 1.3, color: AppColors.lightTextPrimary),
    titleSmall: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.3, color: AppColors.lightTextPrimary),

    bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 1.5, color: AppColors.lightTextSecondary),
    bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, height: 1.5, color: AppColors.lightTextSecondary),
    bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, height: 1.4, color: AppColors.lightTextSecondary),

    labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.lightTextPrimary),
    labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.lightTextPrimary),
    labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.lightTextPrimary),
  );
}
