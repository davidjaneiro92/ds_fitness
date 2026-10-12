import 'package:flutter/material.dart';

import '../../core/theme/tokens/color_tokens.dart';
import '../../core/theme/tokens/spacing_tokens.dart';
import '../../core/theme/tokens/typography_tokens.dart';
import '../../models/treino.dart';
import '../chips/app_chip.dart';
import 'app_card.dart';

/// Card de treino: icone, nome, grupos, resumo de exercicios e o dia da
/// semana (quando o treino tem um).
class TreinoCard extends StatelessWidget {
  const TreinoCard({
    required this.treino,
    super.key,
    this.onTap,
    this.onLongPress,
    this.destaque = false,
    this.trailing,
  });

  final Treino treino;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool destaque;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      onLongPress: onLongPress,
      highlighted: destaque,
      margin: const EdgeInsets.only(bottom: SpacingTokens.sm),
      child: Row(
        children: <Widget>[
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: ColorTokens.accentSoft,
              borderRadius: BorderRadius.circular(SpacingTokens.radiusButton),
            ),
            child: const Icon(
              Icons.fitness_center_rounded,
              size: 22,
              color: ColorTokens.accent,
            ),
          ),
          const SizedBox(width: SpacingTokens.sm + 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  treino.nome,
                  overflow: TextOverflow.ellipsis,
                  style: TypographyTokens.cardTitle,
                ),
                const SizedBox(height: SpacingTokens.xxs),
                Text(
                  treino.gruposLabel,
                  overflow: TextOverflow.ellipsis,
                  style: TypographyTokens.label,
                ),
                const SizedBox(height: SpacingTokens.xxs),
                Text(
                  treino.exerciciosLabel,
                  overflow: TextOverflow.ellipsis,
                  style: TypographyTokens.caption,
                ),
              ],
            ),
          ),
          const SizedBox(width: SpacingTokens.sm),
          if (treino.dia != null) ...<Widget>[
            AppChip(label: treino.dia!.abreviacao, dense: true),
            const SizedBox(width: SpacingTokens.xs),
          ],
          trailing ??
              const Icon(
                Icons.chevron_right_rounded,
                color: ColorTokens.textSecondary,
              ),
        ],
      ),
    );
  }
}
