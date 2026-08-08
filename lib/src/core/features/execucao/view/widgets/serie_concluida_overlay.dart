import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../components/buttons/app_button.dart';
import '../../../../../components/common/gap.dart';
import '../../../../../components/feedback/confetti_burst.dart';
import '../../../../../core/theme/tokens/color_tokens.dart';
import '../../../../../core/theme/tokens/spacing_tokens.dart';
import '../../../../../core/theme/tokens/typography_tokens.dart';
import '../../../../../models/treino.dart';
import '../../abstracts/execucao_controller_interface.dart';

/// Tela 14 — celebracao ao concluir a ultima serie de um exercicio.
/// Auto-dismiss em 3s (timer no controller) ou tap no botao.
class SerieConcluidaOverlay extends StatelessWidget {
  const SerieConcluidaOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final ExecucaoControllerInterface controller = Get.find();

    return Obx(() {
      final int totalSeries = controller.totalSeries;
      final Treino? t = controller.treino.value;
      final bool ultimoExercicio =
          t == null || controller.indiceExercicio.value >= t.exercicios.length - 1;

      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, Object? result) {
          if (didPop) {
            return;
          }
          controller.avancarAposSerieConcluida();
        },
        // Material (e nao ColoredBox): sem um ancestral Material os `Text`
        // ficam com a decoracao amarela de debug do framework.
        child: Material(
          color: ColorTokens.bgPrimary,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.screenPadding),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SizedBox(
                      height: 320,
                      width: 320,
                      child: Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          const ConfettiBurst(size: 320),
                          Container(
                            height: 120,
                            width: 120,
                            decoration: const BoxDecoration(
                              color: ColorTokens.accent,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              color: ColorTokens.textOnAccent,
                              size: 64,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Gap(SpacingTokens.lg),
                    Text(
                      'Série ${controller.serieAtual.value} de $totalSeries',
                      style: TypographyTokens.bodyMuted,
                    ),
                    const Gap(SpacingTokens.xs),
                    Text(
                      'Concluída!',
                      style: TypographyTokens.displaySm.copyWith(fontSize: 28),
                    ),
                    const Gap(SpacingTokens.sm),
                    const Text('Excelente! 💪', style: TypographyTokens.bodyMuted),
                    const Gap(SpacingTokens.xl),
                    AppButton(
                      label: ultimoExercicio ? 'Finalizar treino' : 'Próximo exercício',
                      onPressed: controller.avancarAposSerieConcluida,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
