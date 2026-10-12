import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/tokens/color_tokens.dart';
import '../../core/theme/tokens/spacing_tokens.dart';
import '../../core/theme/tokens/typography_tokens.dart';
import '../../enum/grupo_muscular.dart';
import '../anatomy/grupo_muscular_imagem.dart';

/// Quadro de um grupo muscular na escolha de grupos: a imagem do musculo e o
/// nome. Selecionado, ganha borda verde, a imagem em cores e um visto no canto.
class GrupoMuscularTile extends StatelessWidget {
  const GrupoMuscularTile({
    required this.grupo,
    required this.selecionado,
    required this.onTap,
    super.key,
  });

  final GrupoMuscular grupo;
  final bool selecionado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selecionado,
      label: grupo.label,
      excludeSemantics: true,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Positioned.fill(
            child: Material(
              color: ColorTokens.bgSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(SpacingTokens.radiusCard),
                side: BorderSide(
                  color: selecionado ? ColorTokens.accent : ColorTokens.divider,
                  width: selecionado ? 1.6 : 1,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    SpacingTokens.sm,
                    SpacingTokens.sm,
                    SpacingTokens.sm,
                    SpacingTokens.sm,
                  ),
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        child: LayoutBuilder(
                          builder: (BuildContext context, BoxConstraints box) {
                            return Center(
                              child: GrupoMuscularImagem(
                                grupo: grupo,
                                tamanho: math.min(box.maxWidth, box.maxHeight),
                                destacado: selecionado,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: SpacingTokens.xs),
                      Text(
                        grupo.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TypographyTokens.bodyStrong.copyWith(
                          fontSize: 13,
                          color: selecionado
                              ? ColorTokens.textPrimary
                              : ColorTokens.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (selecionado)
            Positioned(
              top: -6,
              right: -6,
              child: Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: ColorTokens.accent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 16,
                  color: ColorTokens.textOnAccent,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
