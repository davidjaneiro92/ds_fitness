import 'package:flutter/material.dart';

import '../../core/theme/tokens/color_tokens.dart';
import '../../core/theme/tokens/spacing_tokens.dart';
import '../../core/theme/tokens/typography_tokens.dart';
import '../../models/treino_exercicio.dart';
import '../media/exercise_illustration.dart';
import 'app_card.dart';

enum _AcaoDoItem { editar, remover }

/// Linha de um exercicio ja configurado no treino (tela de revisao): miniatura,
/// nome, "4 séries • 12 reps • 90 s" e o menu de tres pontos com editar e
/// remover.
class ExercicioResumoTile extends StatelessWidget {
  const ExercicioResumoTile({
    required this.item,
    required this.onEditar,
    required this.onRemover,
    super.key,
  });

  final TreinoExercicio item;
  final VoidCallback onEditar;
  final VoidCallback onRemover;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onEditar,
      padding: const EdgeInsets.all(SpacingTokens.sm + 4),
      child: Row(
        children: <Widget>[
          ExerciseIllustration(
            imagem: item.exercicio.imagem,
            grupo: item.exercicio.grupoPrimario,
            compact: true,
            tamanho: 56,
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
          PopupMenuButton<_AcaoDoItem>(
            tooltip: 'Opções do exercício',
            icon: const Icon(
              Icons.more_vert_rounded,
              color: ColorTokens.textSecondary,
            ),
            color: ColorTokens.bgSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(SpacingTokens.radiusButton),
              side: const BorderSide(color: ColorTokens.divider),
            ),
            onSelected: (_AcaoDoItem acao) {
              switch (acao) {
                case _AcaoDoItem.editar:
                  onEditar();
                case _AcaoDoItem.remover:
                  onRemover();
              }
            },
            itemBuilder: (BuildContext context) =>
                <PopupMenuEntry<_AcaoDoItem>>[
              const PopupMenuItem<_AcaoDoItem>(
                value: _AcaoDoItem.editar,
                child: Text('Editar', style: TypographyTokens.bodyStrong),
              ),
              PopupMenuItem<_AcaoDoItem>(
                value: _AcaoDoItem.remover,
                child: Text(
                  'Remover',
                  style: TypographyTokens.bodyStrong.copyWith(
                    color: ColorTokens.danger,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
