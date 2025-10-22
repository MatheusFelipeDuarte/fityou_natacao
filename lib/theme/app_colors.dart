import 'package:flutter/material.dart';

/// Centraliza as cores do app - Tema Laranja e Preto
class AppColors {
  AppColors._();

  // Marca - Laranja e Preto
  static const Color primaryOrange = Color(0xFFFF6B00); // Laranja vibrante
  static const Color primaryOrangeDark = Color(0xFFE65100); // Laranja escuro
  static const Color primaryOrangeLight = Color(0xFFFF9E40); // Laranja claro
  static const Color black = Color(0xFF1A1A1A); // Preto principal
  static const Color blackLight = Color(0xFF2D2D2D); // Preto claro
  static const Color blackDark = Color(0xFF000000); // Preto puro

  // Feedback
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFA726);
  static const Color error = Color(0xFFE53935);

  // Tema Claro
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF1A1A1A);
  static const Color lightTextSecondary = Color(0xFF666666);
  static const Color lightDivider = Color(0xFFE0E0E0);

  // Tema Escuro - Cinzas ainda mais claros
  static const Color darkBackground = Color(0xFF252525); // Cinza bem mais claro
  static const Color darkSurface = Color(0xFF353535); // Cinza médio mais claro para cards
  static const Color darkSurfaceVariant = Color(0xFF454545); // Ainda mais claro
  static const Color darkTextPrimary = Color(0xFFFFFFFF); // Branco puro
  static const Color darkTextSecondary = Color(0xFFD0D0D0); // Cinza muito claro
  static const Color darkDivider = Color(0xFF606060); // Divisor bem claro e visível

  // Laranja vibrante para modo escuro
  static const Color darkOrangeAccent = Color(0xFFFF7700); // Laranja mais vibrante
  static const Color darkOrangeHighlight = Color(0xFFFF9500); // Laranja brilhante
}
