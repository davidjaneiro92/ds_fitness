import 'package:flutter/material.dart';

/// Tokens de cor do DS Fitness (tema dark com acento verde).
///
/// Nenhum widget deve declarar cor literal: sempre referenciar um token daqui.
abstract class ColorTokens {
  // Superficies
  static const Color bgPrimary = Color(0xFF0D0D0D);
  static const Color bgSurface = Color(0xFF1A1A1A);
  static const Color bgSurfaceAlt = Color(0xFF242424);

  // Acento
  static const Color accent = Color(0xFF4CE660);
  static const Color accentDark = Color(0xFF2FA843);
  static const Color accentSoft = Color(0x1A4CE660);

  // Texto
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9A9A9A);
  static const Color textOnAccent = Color(0xFF0D0D0D);
  static const Color textDisabled = Color(0xFF5C5C5C);

  // Semanticas
  static const Color danger = Color(0xFFE64C4C);
  static const Color warning = Color(0xFFE6B24C);
  static const Color info = Color(0xFF4C9AE6);
  static const Color muscle = Color(0xFFE64C4C);

  /// Cinza da silhueta anatomica — precisa contrastar com `bgSurface` e
  /// `bgSurfaceAlt`, por isso e mais claro que ambos.
  static const Color bodyBase = Color(0xFF3D3D3D);

  // Estrutura
  static const Color divider = Color(0xFF2E2E2E);
  static const Color overlay = Color(0xCC000000);
  static const Color scrim = Color(0x99000000);

  /// Gradiente usado em cards de destaque (treino do dia, splash).
  static const List<Color> accentGradient = <Color>[
    Color(0xFF4CE660),
    Color(0xFF2FA843),
  ];

  /// Gradiente sutil para superficies elevadas.
  static const List<Color> surfaceGradient = <Color>[
    Color(0xFF1F1F1F),
    Color(0xFF141414),
  ];
}
