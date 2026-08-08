import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../components/buttons/app_button.dart';
import '../../../../components/cards/stat_box.dart';
import '../../../../components/chips/app_chip.dart';
import '../../../../components/common/gap.dart';
import '../../../../components/empty_states/empty_state.dart';
import '../../../../components/feedback/app_snackbar.dart';
import '../../../../components/feedback/confetti_burst.dart';
import '../../../../components/scaffolds/app_scaffold.dart';
import '../../../../core/abstracts/format_service_interface.dart';
import '../../../../core/theme/tokens/color_tokens.dart';
import '../../../../core/theme/tokens/spacing_tokens.dart';
import '../../../../core/theme/tokens/typography_tokens.dart';
import '../../../../enum/pages_routes.dart';
import '../../../../models/sessao.dart';
import '../../../../routes/route_args.dart';

/// Tela 21 — resumo do treino concluido (rota `/execucao/concluido`).
///
/// Nao depende de [ExecucaoControllerInterface]: le a [Sessao] direto de
/// `Get.arguments`, pois o controller da execucao pode ja ter sido
/// descartado quando esta rota e alcancada via `Get.offNamed`.
class TreinoConcluidoView extends StatelessWidget {
  const TreinoConcluidoView({super.key});

  @override
  Widget build(BuildContext context) {
    final dynamic args = Get.arguments;
    if (args is! ExecucaoConcluidoArgs) {
      return AppScaffold(
        body: Center(
          child: EmptyState(
            icon: Icons.emoji_events_rounded,
            title: 'Nenhum treino concluído',
            message: 'Volte para a home e inicie um treino.',
            actionLabel: 'Voltar para home',
            onAction: () => Get.offAllNamed<void>(PagesRoutes.home.path),
          ),
        ),
      );
    }

    final Sessao sessao = args.sessao;
    final FormatServiceInterface format = Get.find();

    return AppScaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Gap(SpacingTokens.lg),
            SizedBox(
              height: 140,
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  const ConfettiBurst(size: 260),
                  Container(
                    height: 96,
                    width: 96,
                    decoration: const BoxDecoration(
                      color: ColorTokens.accentSoft,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.emoji_events_rounded,
                      color: ColorTokens.accent,
                      size: 56,
                    ),
                  ),
                ],
              ),
            ),
            const Gap(SpacingTokens.md),
            Text(
              'Treino Concluído!',
              style: TypographyTokens.displaySm.copyWith(fontSize: 24),
            ),
            const Gap(SpacingTokens.xs),
            const Text('Parabéns, você mandou bem!', style: TypographyTokens.bodyMuted),
            const Gap(SpacingTokens.xl),
            Row(
              children: <Widget>[
                Expanded(
                  child: StatBox(
                    value: format.cronometro(sessao.duracaoSeg),
                    label: 'Tempo total',
                  ),
                ),
                const Gap.horizontal(SpacingTokens.sm),
                Expanded(
                  child: StatBox(
                    value: '${sessao.totalExercicios}',
                    label: 'Exercícios',
                  ),
                ),
              ],
            ),
            const Gap(SpacingTokens.sm),
            Row(
              children: <Widget>[
                Expanded(
                  child: StatBox(
                    value: '${sessao.totalSeries}',
                    label: 'Séries',
                  ),
                ),
                const Gap.horizontal(SpacingTokens.sm),
                Expanded(
                  child: StatBox(
                    value: format.volume(sessao.volumeTotal),
                    label: 'Volume total',
                  ),
                ),
              ],
            ),
            const Gap(SpacingTokens.sm),
            StatBox(value: '${sessao.calorias} kcal', label: 'Calorias'),
            if (sessao.recordes.isNotEmpty) ...<Widget>[
              const Gap(SpacingTokens.lg),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Recordes pessoais', style: TypographyTokens.cardTitle),
              ),
              const Gap(SpacingTokens.sm),
              Wrap(
                spacing: SpacingTokens.sm,
                runSpacing: SpacingTokens.sm,
                children: sessao.recordes
                    .map(
                      (String nome) => AppChip(
                        label: nome,
                        icon: Icons.local_fire_department_rounded,
                        color: ColorTokens.accent,
                      ),
                    )
                    .toList(),
              ),
            ],
            const Gap(SpacingTokens.xl),
            AppButton(
              label: 'Compartilhar',
              variant: AppButtonVariant.outline,
              onPressed: () => AppSnackbar.info('Compartilhamento em breve'),
            ),
            const Gap(SpacingTokens.sm),
            AppButton(
              label: 'Voltar para home',
              onPressed: () => Get.offAllNamed<void>(PagesRoutes.home.path),
            ),
            const Gap(SpacingTokens.lg),
          ],
        ),
      ),
    );
  }
}
