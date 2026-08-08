import 'package:flutter/material.dart';

import '../../../../../components/cards/app_card.dart';
import '../../../../../core/theme/tokens/color_tokens.dart';
import '../../../../../core/theme/tokens/spacing_tokens.dart';
import '../../../../../core/theme/tokens/typography_tokens.dart';
import '../../../../../models/treino_exercicio.dart';

/// Linha de exercicio dentro do formulario de treino: indice, nome, resumo
/// e botao de remover. Quando [arrastavel] e `true`, exibe uma alca de
/// arraste para uso dentro de um `ReorderableListView`.
class ExercicioOrdenavelTile extends StatelessWidget {
  const ExercicioOrdenavelTile({
    required this.item,
    required this.indice,
    super.key,
    this.onTap,
    this.onRemover,
    this.arrastavel = false,
  });

  final TreinoExercicio item;
  final int indice;
  final VoidCallback? onTap;
  final VoidCallback? onRemover;
  final bool arrastavel;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(SpacingTokens.sm + 4),
      child: Row(
        children: <Widget>[
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: ColorTokens.bgSurfaceAlt,
              shape: BoxShape.circle,
            ),
            child: Text('${indice + 1}', style: TypographyTokens.label),
          ),
          const SizedBox(width: SpacingTokens.sm + 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  item.exercicio.nome,
                  overflow: TextOverflow.ellipsis,
                  style: TypographyTokens.bodyStrong,
                ),
                const SizedBox(height: SpacingTokens.xxs),
                Text(
                  item.resumo,
                  overflow: TextOverflow.ellipsis,
                  style: TypographyTokens.label,
                ),
              ],
            ),
          ),
          if (onRemover != null)
            IconButton(
              onPressed: onRemover,
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: ColorTokens.danger,
              ),
            ),
          if (arrastavel)
            ReorderableDragStartListener(
              index: indice,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: SpacingTokens.xs),
                child: Icon(
                  Icons.drag_indicator_rounded,
                  color: ColorTokens.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
