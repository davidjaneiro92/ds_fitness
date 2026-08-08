import 'package:flutter/material.dart';

import '../../core/theme/tokens/color_tokens.dart';
import '../../core/theme/tokens/spacing_tokens.dart';
import '../../core/theme/tokens/typography_tokens.dart';

/// Cabecalho de secao: titulo a esquerda e acao opcional a direita.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.title,
    super.key,
    this.actionLabel,
    this.onAction,
    this.trailing,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: SpacingTokens.sm + 4),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(title, style: TypographyTokens.cardTitle),
          ),
          if (trailing != null)
            trailing!
          else if (actionLabel != null)
            GestureDetector(
              onTap: onAction,
              child: Row(
                children: <Widget>[
                  Text(
                    actionLabel!,
                    style: TypographyTokens.label.copyWith(
                      color: ColorTokens.accent,
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: ColorTokens.accent,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Barra de progresso fina com trilho escuro e preenchimento verde.
class AppProgressBar extends StatelessWidget {
  const AppProgressBar({
    required this.value,
    super.key,
    this.height = 8,
    this.color,
  });

  /// Progresso de 0.0 a 1.0.
  final double value;
  final double height;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
      child: LinearProgressIndicator(
        value: value.clamp(0.0, 1.0),
        minHeight: height,
        backgroundColor: ColorTokens.bgSurfaceAlt,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? ColorTokens.accent,
        ),
      ),
    );
  }
}
