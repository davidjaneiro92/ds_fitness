import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../components/anatomy/muscle_body.dart';
import '../../../../../components/buttons/app_button.dart';
import '../../../../../components/cards/app_card.dart';
import '../../../../../components/common/gap.dart';
import '../../../../../core/theme/tokens/color_tokens.dart';
import '../../../../../core/theme/tokens/spacing_tokens.dart';
import '../../../../../core/theme/tokens/typography_tokens.dart';
import '../../../../../enum/pages_routes.dart';
import '../../../../../models/treino.dart';
import '../../../../../routes/route_args.dart';

/// Card de destaque da Home com o treino sugerido para hoje.
///
/// Quando nao ha treino planejado, mostra um convite para criar um treino.
class TreinoDoDiaCard extends StatelessWidget {
  const TreinoDoDiaCard({
    required this.treino,
    required this.onIniciar,
    super.key,
  });

  final Treino? treino;
  final VoidCallback onIniciar;

  static const TextStyle _rotulo = TypographyTokens.caption;

  @override
  Widget build(BuildContext context) {
    final Treino? atual = treino;
    if (atual == null) {
      return AppCard(
        highlighted: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'TREINO DE HOJE',
              style: _rotulo.copyWith(letterSpacing: 1),
            ),
            const Gap(SpacingTokens.sm),
            const Text(
              'Nenhum treino planejado para hoje',
              style: TypographyTokens.cardTitle,
            ),
            const Gap(SpacingTokens.xs),
            const Text(
              'Crie um treino para comecar a acompanhar seu progresso.',
              style: TypographyTokens.bodyMuted,
            ),
            const Gap(SpacingTokens.md),
            AppButton(
              label: 'Criar treino',
              size: AppButtonSize.small,
              expanded: false,
              onPressed: () => Get.toNamed<void>(
                PagesRoutes.treinoNovo.path,
                arguments: const TreinoFormArgs(),
              ),
            ),
          ],
        ),
      );
    }

    return AppCard(
      highlighted: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'TREINO DE HOJE',
                  style: _rotulo.copyWith(letterSpacing: 1),
                ),
                const Gap(SpacingTokens.sm),
                Text(atual.nome, style: TypographyTokens.screenTitle),
                const Gap(SpacingTokens.xs),
                Row(
                  children: <Widget>[
                    Container(
                      height: 6,
                      width: 6,
                      decoration: const BoxDecoration(
                        color: ColorTokens.accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const Gap.horizontal(SpacingTokens.xs),
                    Flexible(
                      child: Text(
                        atual.exerciciosLabel,
                        style: TypographyTokens.bodyMuted,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const Gap(SpacingTokens.md),
                AppButton(
                  label: 'Iniciar treino',
                  size: AppButtonSize.small,
                  expanded: false,
                  onPressed: onIniciar,
                ),
              ],
            ),
          ),
          const Gap.horizontal(SpacingTokens.sm),
          MuscleBody(destaque: atual.grupos.toSet(), size: 72),
        ],
      ),
    );
  }
}
