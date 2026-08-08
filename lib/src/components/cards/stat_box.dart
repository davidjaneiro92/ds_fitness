import 'package:flutter/material.dart';

import '../../core/theme/tokens/color_tokens.dart';
import '../../core/theme/tokens/spacing_tokens.dart';
import '../../core/theme/tokens/typography_tokens.dart';

/// Caixa de metrica: valor grande + label pequeno.
///
/// Usada nos resumos (estatisticas, treino concluido, historico).
class StatBox extends StatelessWidget {
  const StatBox({
    required this.value,
    required this.label,
    super.key,
    this.valueColor,
    this.icon,
    this.compact = false,
    this.background,
  });

  final String value;
  final String label;
  final Color? valueColor;
  final IconData? icon;
  final bool compact;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SpacingTokens.md,
        vertical: compact ? SpacingTokens.sm + 2 : SpacingTokens.md,
      ),
      decoration: BoxDecoration(
        color: background ?? ColorTokens.bgSurface,
        borderRadius: BorderRadius.circular(SpacingTokens.radiusCard),
        border: Border.all(color: ColorTokens.divider),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: 18, color: ColorTokens.accent),
            const SizedBox(height: SpacingTokens.xs),
          ],
          FittedBox(
            child: Text(
              value,
              style: TypographyTokens.displaySm.copyWith(
                fontSize: compact ? 20 : 26,
                color: valueColor ?? ColorTokens.accent,
              ),
            ),
          ),
          const SizedBox(height: SpacingTokens.xs),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TypographyTokens.caption,
          ),
        ],
      ),
    );
  }
}
