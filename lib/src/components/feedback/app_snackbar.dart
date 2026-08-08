import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/tokens/color_tokens.dart';
import '../../core/theme/tokens/spacing_tokens.dart';
import '../../core/theme/tokens/typography_tokens.dart';

/// Snackbars padronizados do app: sucesso, erro e informacao.
abstract class AppSnackbar {
  static void success(String mensagem) {
    _show(mensagem, icon: Icons.check_circle_rounded, color: ColorTokens.accent);
  }

  static void erro(String mensagem) {
    _show(mensagem, icon: Icons.error_rounded, color: ColorTokens.danger);
  }

  static void info(String mensagem) {
    _show(mensagem, icon: Icons.info_rounded, color: ColorTokens.info);
  }

  static void _show(
    String mensagem, {
    required IconData icon,
    required Color color,
  }) {
    Get.rawSnackbar(
      messageText: Text(
        mensagem,
        style: TypographyTokens.body.copyWith(color: ColorTokens.textPrimary),
      ),
      icon: Icon(icon, color: color),
      backgroundColor: ColorTokens.bgSurfaceAlt,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(SpacingTokens.md),
      borderRadius: SpacingTokens.radiusButton,
      duration: const Duration(milliseconds: 2500),
    );
  }
}
