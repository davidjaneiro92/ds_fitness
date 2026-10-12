import 'package:flutter/material.dart';

import 'color_tokens.dart';

/// Tokens tipograficos do DS Fitness.
///
/// Papeis (planejamento §1): display 42–48/800 · titulo de tela 20/700 ·
/// titulo de card 16/700 · corpo 14 (400/600) · label 11–12/600.
abstract class TypographyTokens {
  static const TextStyle display = TextStyle(
    fontSize: 44,
    fontWeight: FontWeight.w800,
    color: ColorTokens.textPrimary,
    height: 1.1,
    letterSpacing: -1,
  );

  static const TextStyle displaySm = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: ColorTokens.textPrimary,
    height: 1.1,
    letterSpacing: -0.5,
  );

  static const TextStyle screenTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: ColorTokens.textPrimary,
  );

  /// Titulo grande das telas do fluxo, logo abaixo da seta de voltar.
  static const TextStyle pageTitle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: ColorTokens.textPrimary,
    height: 1.15,
  );

  /// Rotulo de campo de formulario, acima do campo.
  static const TextStyle fieldLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: ColorTokens.textPrimary,
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: ColorTokens.textPrimary,
  );

  static const TextStyle bodyStrong = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: ColorTokens.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: ColorTokens.textPrimary,
  );

  static const TextStyle bodyMuted = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: ColorTokens.textSecondary,
  );

  static const TextStyle label = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: ColorTokens.textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: ColorTokens.textSecondary,
  );

  static const TextStyle button = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: ColorTokens.textOnAccent,
  );

  /// TextTheme do Material mapeado para os papeis acima.
  static const TextTheme textTheme = TextTheme(
    displayLarge: display,
    displayMedium: displaySm,
    headlineSmall: screenTitle,
    titleLarge: screenTitle,
    titleMedium: cardTitle,
    bodyLarge: bodyStrong,
    bodyMedium: body,
    bodySmall: bodyMuted,
    labelLarge: button,
    labelMedium: label,
    labelSmall: caption,
  );
}
