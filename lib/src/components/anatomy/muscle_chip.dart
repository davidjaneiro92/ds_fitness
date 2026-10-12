import 'package:flutter/material.dart';

import '../../core/theme/tokens/color_tokens.dart';
import '../../core/theme/tokens/spacing_tokens.dart';
import '../../core/theme/tokens/typography_tokens.dart';
import '../../enum/grupo_muscular.dart';
import 'grupo_muscular_imagem.dart';

/// Imagem do grupo muscular com o nome embaixo, usada no detalhe e na
/// execucao do exercicio.
class MuscleChip extends StatelessWidget {
  const MuscleChip({
    required this.grupo,
    super.key,
    this.size = 56,
  });

  final GrupoMuscular grupo;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size + SpacingTokens.md,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(SpacingTokens.sm),
            decoration: BoxDecoration(
              color: ColorTokens.bgSurfaceAlt,
              borderRadius: BorderRadius.circular(SpacingTokens.radiusButton),
            ),
            child: GrupoMuscularImagem(grupo: grupo, tamanho: size),
          ),
          const SizedBox(height: SpacingTokens.xs),
          Text(
            grupo.label,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: TypographyTokens.caption,
          ),
        ],
      ),
    );
  }
}

/// Linha horizontal rolavel de [MuscleChip], espacamento 8 entre itens.
class MuscleChipsRow extends StatelessWidget {
  const MuscleChipsRow({
    required this.grupos,
    super.key,
    this.size = 56,
  });

  final List<GrupoMuscular> grupos;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size + SpacingTokens.xl + SpacingTokens.md,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: grupos.length,
        separatorBuilder: (BuildContext context, int index) =>
            const SizedBox(width: SpacingTokens.sm),
        itemBuilder: (BuildContext context, int index) {
          return MuscleChip(grupo: grupos[index], size: size);
        },
      ),
    );
  }
}
