import 'package:flutter/material.dart';

/// Centraliza as cores do app.
///
/// Observação: As cores abaixo são provisórias, baseadas em uma paleta
/// contemporânea que combina azul profundo com amarelo de destaque.
/// Ajustaremos para corresponder exatamente ao site após validação dos HEX.
class AppColors {
  AppColors._();

  // Marca (provisório)
  static const Color primary = Color(0xFF0B4D91); // azul profundo
  static const Color secondary = Color(0xFFF4B400); // amarelo destaque

  // Feedback
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFF57C00);
  static const Color error = Color(0xFFC62828);

  // Superfícies e fundos
  static const Color background = Color(0xFFF7F8FA);
  static const Color surface = Colors.white;

  // Texto
  static const Color textPrimary = Color(0xFF111827); // quase preto
  static const Color textSecondary = Color(0xFF4B5563); // cinza

  // Bordas/divisores
  static const Color divider = Color(0xFFE5E7EB);
}
