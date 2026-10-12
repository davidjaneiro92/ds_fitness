import 'package:flutter/material.dart';

import '../../../../theme/tokens/color_tokens.dart';
import '../../../../theme/tokens/spacing_tokens.dart';
import '../../../../theme/tokens/typography_tokens.dart';

/// Marca DS Fitness desenhada em codigo (sem imagem/asset): "DS" em verde e
/// "Fitness" em branco, os dois em italico pesado. Com [mostrarLema], o lema
/// "DISCIPLINA HOJE. RESULTADOS SEMPRE." vem espacado logo abaixo.
class DsLogo extends StatelessWidget {
  const DsLogo({super.key, this.size = 56, this.mostrarLema = false});

  /// Tamanho da fonte da marca; o lema escala a partir dele.
  final double size;
  final bool mostrarLema;

  static const String lema = 'DISCIPLINA HOJE.\nRESULTADOS SEMPRE.';

  @override
  Widget build(BuildContext context) {
    final TextStyle base = TextStyle(
      fontSize: size,
      fontWeight: FontWeight.w900,
      fontStyle: FontStyle.italic,
      letterSpacing: -1.5,
      height: 1,
      color: ColorTokens.textPrimary,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text.rich(
          TextSpan(
            style: base,
            children: <InlineSpan>[
              TextSpan(
                text: 'DS ',
                style: base.copyWith(color: ColorTokens.accent),
              ),
              const TextSpan(text: 'Fitness'),
            ],
          ),
        ),
        if (mostrarLema) ...<Widget>[
          const SizedBox(height: SpacingTokens.sm + 4),
          Text(
            lema,
            textAlign: TextAlign.center,
            style: TypographyTokens.caption.copyWith(
              fontSize: (size * 0.2).clamp(10, 14).toDouble(),
              letterSpacing: 3,
              height: 1.5,
            ),
          ),
        ],
      ],
    );
  }
}
