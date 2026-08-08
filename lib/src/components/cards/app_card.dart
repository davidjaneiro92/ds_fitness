import 'package:flutter/material.dart';

import '../../core/theme/tokens/color_tokens.dart';
import '../../core/theme/tokens/spacing_tokens.dart';

/// Superficie padrao de card: fundo `bgSurface`, raio 16, sem sombra.
///
/// A separacao visual vem do contraste de superficie, nunca de elevacao.
class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    super.key,
    this.onTap,
    this.onLongPress,
    this.padding = const EdgeInsets.all(SpacingTokens.md),
    this.margin,
    this.highlighted = false,
    this.background,
    this.borderColor,
    this.radius = SpacingTokens.radiusCard,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsets padding;
  final EdgeInsets? margin;

  /// Destaque com borda verde (ex.: treino do dia).
  final bool highlighted;
  final Color? background;
  final Color? borderColor;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final Color border = borderColor ??
        (highlighted ? ColorTokens.accent : ColorTokens.divider);

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: background ?? ColorTokens.bgSurface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: border,
          width: highlighted ? 1.4 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
