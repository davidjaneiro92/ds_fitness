import 'package:flutter/material.dart';

import '../../core/theme/tokens/color_tokens.dart';
import '../../core/theme/tokens/spacing_tokens.dart';
import '../../core/theme/tokens/typography_tokens.dart';
import '../../models/exercicio.dart';
import '../media/exercise_illustration.dart';
import 'app_card.dart';

/// Linha da escolha de exercicio: miniatura, nome, grupos e uma marca de
/// selecao (so um exercicio por vez). Um exercicio que ja esta no treino fica
/// travado, com o aviso *No treino*: a API nao aceita o mesmo exercicio duas
/// vezes.
class ExercicioSelecaoTile extends StatelessWidget {
  const ExercicioSelecaoTile({
    required this.exercicio,
    required this.selecionado,
    required this.onTap,
    super.key,
    this.jaAdicionado = false,
  });

  final Exercicio exercicio;
  final bool selecionado;
  final bool jaAdicionado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selecionado,
      enabled: !jaAdicionado,
      child: Opacity(
        opacity: jaAdicionado ? 0.55 : 1,
        child: AppCard(
          onTap: jaAdicionado ? null : onTap,
          highlighted: selecionado,
          padding: const EdgeInsets.all(SpacingTokens.sm + 4),
          margin: const EdgeInsets.only(bottom: SpacingTokens.sm),
          child: Row(
            children: <Widget>[
              ExerciseIllustration(
                imagem: exercicio.imagem,
                grupo: exercicio.grupoPrimario,
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
                      exercicio.nome,
                      overflow: TextOverflow.ellipsis,
                      style: TypographyTokens.bodyStrong,
                    ),
                    const SizedBox(height: SpacingTokens.xxs),
                    Text(
                      exercicio.gruposLabel,
                      overflow: TextOverflow.ellipsis,
                      style: TypographyTokens.label,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: SpacingTokens.sm),
              if (jaAdicionado)
                const Text('No treino', style: TypographyTokens.caption)
              else
                _MarcaDeSelecao(selecionado: selecionado),
            ],
          ),
        ),
      ),
    );
  }
}

class _MarcaDeSelecao extends StatelessWidget {
  const _MarcaDeSelecao({required this.selecionado});

  final bool selecionado;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selecionado ? ColorTokens.accent : Colors.transparent,
        border: selecionado
            ? null
            : Border.all(color: ColorTokens.textDisabled, width: 2),
      ),
      child: selecionado
          ? const Icon(
              Icons.check_rounded,
              size: 16,
              color: ColorTokens.textOnAccent,
            )
          : null,
    );
  }
}
