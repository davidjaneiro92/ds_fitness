import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../components/buttons/app_button.dart';
import '../../../../../components/common/gap.dart';
import '../../../../../components/feedback/app_confirm_dialog.dart';
import '../../../../../components/navbars/app_navbar.dart';
import '../../../../../components/scaffolds/app_scaffold.dart';
import '../../../../../components/timers/circular_timer.dart';
import '../../../../../core/theme/tokens/spacing_tokens.dart';
import '../../../../../core/theme/tokens/typography_tokens.dart';
import '../../abstracts/execucao_controller_interface.dart';

/// Tela 12 — descanso entre series: anel regressivo, ajustes de ±15s,
/// pausar/retomar e pular. Nunca aparece apos a ultima serie de um
/// exercicio — a maquina de estados (no controller) garante isso.
class DescansoView extends StatelessWidget {
  const DescansoView({super.key});

  Future<void> _confirmarAbandono(ExecucaoControllerInterface controller) async {
    final bool confirmar = await showAppConfirmDialog(
      title: 'Abandonar o treino?',
      message: 'Seu progresso desta sessão será perdido.',
      confirmLabel: 'Abandonar',
      danger: true,
    );
    if (confirmar) {
      await controller.abandonar();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ExecucaoControllerInterface controller = Get.find();

    return Obx(() {
      final int totalSeries = controller.totalSeries;
      final int proximaSerie = controller.serieAtual.value + 1;
      final String? legenda = controller.segundosDescanso.value == 0
          ? 'Hora da próxima série!'
          : (controller.descansoPausado.value ? 'Pausado' : null);

      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, Object? result) {
          if (didPop) {
            return;
          }
          unawaited(_confirmarAbandono(controller));
        },
        child: AppScaffold(
          navbar: AppNavbar(
            title: 'Descanso',
            onBack: () => unawaited(_confirmarAbandono(controller)),
          ),
          body: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Gap(SpacingTokens.xl),
                CircularTimer(
                  totalSeg: controller.descansoTotal.value,
                  restanteSeg: controller.segundosDescanso.value,
                  size: 240,
                  legenda: legenda,
                ),
                const Gap(SpacingTokens.lg),
                Text(
                  'Série ${controller.serieAtual.value} de $totalSeries concluída!',
                  style: TypographyTokens.bodyStrong,
                ),
                const Gap(SpacingTokens.xs),
                Text(
                  'Próxima série: $proximaSerie de $totalSeries',
                  style: TypographyTokens.bodyMuted,
                ),
                const Gap(SpacingTokens.xl),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: AppButton(
                        label: '−15s',
                        variant: AppButtonVariant.surface,
                        size: AppButtonSize.small,
                        onPressed: () => controller.ajustarDescanso(-15),
                      ),
                    ),
                    const Gap.horizontal(SpacingTokens.sm),
                    Expanded(
                      child: AppButton(
                        label: controller.descansoPausado.value ? 'Retomar' : 'Pausar',
                        variant: AppButtonVariant.surface,
                        size: AppButtonSize.small,
                        onPressed: controller.alternarPausaDescanso,
                      ),
                    ),
                    const Gap.horizontal(SpacingTokens.sm),
                    Expanded(
                      child: AppButton(
                        label: '+15s',
                        variant: AppButtonVariant.surface,
                        size: AppButtonSize.small,
                        onPressed: () => controller.ajustarDescanso(15),
                      ),
                    ),
                  ],
                ),
                const Gap(SpacingTokens.md),
                AppButton(
                  label: 'Pular descanso',
                  variant: AppButtonVariant.outline,
                  onPressed: controller.pularDescanso,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
