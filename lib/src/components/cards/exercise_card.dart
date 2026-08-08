import 'package:flutter/material.dart';

import '../../core/theme/tokens/spacing_tokens.dart';
import '../../core/theme/tokens/typography_tokens.dart';
import '../../models/exercicio.dart';
import '../media/exercise_illustration.dart';
import 'app_card.dart';

/// Linha de exercicio: thumb + nome + subtitulo, usada em listas de
/// biblioteca, favoritos e montagem de treino.
class ExerciseCard extends StatelessWidget {
  const ExerciseCard({
    required this.exercicio,
    super.key,
    this.onTap,
    this.trailing,
    this.subtitle,
    this.showThumb = true,
  });

  final Exercicio exercicio;
  final VoidCallback? onTap;
  final Widget? trailing;
  final String? subtitle;
  final bool showThumb;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(SpacingTokens.sm + 4),
      margin: const EdgeInsets.only(bottom: SpacingTokens.sm),
      child: Row(
        children: <Widget>[
          if (showThumb) ...<Widget>[
            ExerciseIllustration(
              nome: exercicio.nome,
              grupo: exercicio.grupoPrimario,
              compact: true,
            ),
            const SizedBox(width: SpacingTokens.sm + 4),
          ],
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
                  subtitle ?? exercicio.gruposLabel,
                  overflow: TextOverflow.ellipsis,
                  style: TypographyTokens.label,
                ),
              ],
            ),
          ),
          if (trailing != null) ...<Widget>[
            const SizedBox(width: SpacingTokens.sm),
            trailing!,
          ],
        ],
      ),
    );
  }
}
