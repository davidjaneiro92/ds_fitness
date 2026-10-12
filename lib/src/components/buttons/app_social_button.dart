import 'package:flutter/material.dart';

import '../../core/theme/tokens/color_tokens.dart';
import '../../core/theme/tokens/spacing_tokens.dart';

/// Botao quadrado de entrar por uma conta externa (Google, Apple, Facebook):
/// so o icone da marca, sobre a superficie escura. [semanticsLabel] diz ao
/// leitor de tela qual e o botao.
class AppSocialButton extends StatelessWidget {
  const AppSocialButton({
    required this.icon,
    required this.semanticsLabel,
    required this.onTap,
    super.key,
    this.iconColor = ColorTokens.textPrimary,
  });

  final IconData icon;
  final String semanticsLabel;
  final VoidCallback onTap;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticsLabel,
      child: Material(
        color: ColorTokens.bgSurface,
        borderRadius: BorderRadius.circular(SpacingTokens.radiusButton),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(SpacingTokens.radiusButton),
          child: Container(
            width: 64,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(SpacingTokens.radiusButton),
              border: Border.all(color: ColorTokens.divider),
            ),
            child: Icon(icon, size: 28, color: iconColor),
          ),
        ),
      ),
    );
  }
}
