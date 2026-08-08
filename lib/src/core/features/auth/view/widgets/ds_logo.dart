import 'package:flutter/material.dart';

import '../../../../theme/tokens/color_tokens.dart';
import '../../../../theme/tokens/spacing_tokens.dart';
import '../../../../theme/tokens/typography_tokens.dart';

/// Marca DS Fitness desenhada em codigo (sem imagem/asset).
///
/// "DS" em verde sobre um bloco escuro e "FITNESS" em branco com
/// espacamento entre letras logo abaixo/ao lado — remete a uma marca de
/// academia.
class DsLogo extends StatelessWidget {
  const DsLogo({super.key, this.size = 96, this.horizontal = false});

  /// Lado do bloco "DS" — o restante da marca escala a partir dele.
  final double size;

  /// Quando `true`, dispõe o bloco "DS" e o rótulo "FITNESS" lado a lado.
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    final Widget bloco = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: ColorTokens.bgSurfaceAlt,
        borderRadius: BorderRadius.circular(
          size * SpacingTokens.radiusLg / 96,
        ),
        border: Border.all(color: ColorTokens.divider),
      ),
      child: Text(
        'DS',
        style: TypographyTokens.display.copyWith(
          fontSize: size * 0.5,
          color: ColorTokens.accent,
          letterSpacing: -2,
          height: 1,
        ),
      ),
    );

    final Widget rotulo = Text(
      'FITNESS',
      style: TypographyTokens.label.copyWith(
        color: ColorTokens.textPrimary,
        fontSize: size * 0.125,
        letterSpacing: 6,
        fontWeight: FontWeight.w700,
      ),
    );

    if (horizontal) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          bloco,
          const SizedBox(width: SpacingTokens.md),
          rotulo,
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        bloco,
        const SizedBox(height: SpacingTokens.sm),
        rotulo,
      ],
    );
  }
}
