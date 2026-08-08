import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../components/cards/app_card.dart';
import '../../../../../components/common/gap.dart';
import '../../../../../core/abstracts/format_service_interface.dart';
import '../../../../../core/theme/tokens/color_tokens.dart';
import '../../../../../core/theme/tokens/spacing_tokens.dart';
import '../../../../../core/theme/tokens/typography_tokens.dart';
import '../../../../../models/sessao.dart';

/// Item de lista de uma sessao concluida (tela 16 — Historico).
class SessaoTile extends StatelessWidget {
  const SessaoTile({required this.sessao, super.key, this.onTap});

  final Sessao sessao;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final FormatServiceInterface format = Get.find();

    return AppCard(
      onTap: onTap,
      child: Row(
        children: <Widget>[
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: ColorTokens.accentSoft,
              borderRadius: BorderRadius.circular(SpacingTokens.radiusSm),
            ),
            child: const Icon(
              Icons.fitness_center_rounded,
              color: ColorTokens.accent,
            ),
          ),
          const Gap.horizontal(SpacingTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  sessao.treinoNome,
                  style: TypographyTokens.bodyStrong,
                  overflow: TextOverflow.ellipsis,
                ),
                const Gap(SpacingTokens.xs),
                Text(
                  '${format.dataRelativa(sessao.iniciadoEm)} · '
                  '${format.duracao(sessao.duracaoSeg)} · '
                  '${sessao.calorias} kcal',
                  style: TypographyTokens.bodyMuted,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: ColorTokens.textSecondary,
          ),
        ],
      ),
    );
  }
}
