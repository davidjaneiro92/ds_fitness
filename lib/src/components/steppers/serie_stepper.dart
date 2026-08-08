import 'package:flutter/material.dart';

import '../../core/theme/tokens/color_tokens.dart';
import '../../core/theme/tokens/spacing_tokens.dart';
import '../../core/theme/tokens/typography_tokens.dart';

/// Linha de indicadores de serie da execucao do exercicio: concluida
/// (verde com check), atual (borda verde) ou futura (cinza).
class SerieStepper extends StatelessWidget {
  const SerieStepper({
    required this.total,
    required this.atual,
    required this.concluidas,
    super.key,
  });

  /// Total de series do exercicio.
  final int total;

  /// Serie atual (1-based).
  final int atual;

  /// Quantidade de series ja concluidas.
  final int concluidas;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: total,
        separatorBuilder: (BuildContext context, int index) =>
            const SizedBox(width: SpacingTokens.sm),
        itemBuilder: (BuildContext context, int index) {
          final int numero = index + 1;
          final bool concluida = numero <= concluidas;
          final bool ehAtual = !concluida && numero == atual;
          return _SeriePill(numero: numero, concluida: concluida, atual: ehAtual);
        },
      ),
    );
  }
}

class _SeriePill extends StatelessWidget {
  const _SeriePill({
    required this.numero,
    required this.concluida,
    required this.atual,
  });

  final int numero;
  final bool concluida;
  final bool atual;

  @override
  Widget build(BuildContext context) {
    if (concluida) {
      return Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: ColorTokens.accent,
          borderRadius: BorderRadius.circular(SpacingTokens.radiusXs),
        ),
        child: const Icon(
          Icons.check_rounded,
          size: 16,
          color: ColorTokens.textOnAccent,
        ),
      );
    }

    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: atual ? Colors.transparent : ColorTokens.bgSurfaceAlt,
        borderRadius: BorderRadius.circular(SpacingTokens.radiusXs),
        border: atual ? Border.all(color: ColorTokens.accent, width: 1.5) : null,
      ),
      child: Text(
        '$numero',
        style: TypographyTokens.bodyStrong.copyWith(
          color: atual ? ColorTokens.accent : ColorTokens.textSecondary,
        ),
      ),
    );
  }
}
