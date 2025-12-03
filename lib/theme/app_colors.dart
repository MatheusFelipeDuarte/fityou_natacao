import 'package:flutter/material.dart';

/// Centraliza as cores do app - Tema AquaNível (Azul/Ciano)
class AppColors {
  AppColors._();

  // Marca - Azul e Ciano
  static const Color primary = Color(0xFF01579B); // Azul Escuro (Light Mode Primary)
  static const Color primaryDark = Color(0xFF0a1929); // Azul Muito Escuro (Dark Mode Background)
  static const Color primaryLight = Color(0xFF4FC3F7); // Azul Claro (Dark Mode Accent)
  
  static const Color secondary = Color(0xFF26C6DA); // Ciano
  static const Color accent = Color(0xFFFFD54F); // Amarelo/Dourado

  static const Color black = Color(0xFF0a1929); // Usando o tom escuro do tema
  static const Color blackLight = Color(0xFF1a2332); 
  
  // Feedback
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFA726);
  static const Color error = Color(0xFFE53935);

  // Tema Claro
  static const Color lightBackgroundStart = Color(0xFFE1F5FE);
  static const Color lightBackgroundMiddle = Color(0xFFB3E5FC);
  static const Color lightBackgroundEnd = Color(0xFF81D4FA);
  
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF01579B);
  static const Color lightTextSecondary = Color(0xFF0277BD);
  static const Color lightDivider = Color(0xFFB3E5FC);

  // Tema Escuro
  static const Color darkBackgroundStart = Color(0xFF0a1929);
  static const Color darkBackgroundMiddle = Color(0xFF1a2332);
  static const Color darkBackgroundEnd = Color(0xFF0f1b2d);
  
  static const Color darkSurface = Color(0xFF1a2332); // Card bg
  static const Color darkSurfaceVariant = Color(0xFF263238);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB0BEC5);
  static const Color darkDivider = Color(0xFF4FC3F7); // Com opacidade no uso

  // Mapeamento para compatibilidade (Depreciado - Refatorar depois)
  static const Color primaryOrange = primary; 
  static const Color primaryOrangeDark = primaryDark;
  static const Color primaryOrangeLight = primaryLight;
  static const Color darkOrangeAccent = primaryLight; // No dark mode, o destaque é o azul claro
  static const Color darkOrangeHighlight = secondary;
  static const Color darkBackground = darkBackgroundStart; // Fallback para cor sólida
}
