import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../components/anatomy/muscle_chip.dart';
import '../../../../../components/buttons/app_button.dart';
import '../../../../../components/cards/stat_box.dart';
import '../../../../../components/chips/app_chip.dart';
import '../../../../../components/common/gap.dart';
import '../../../../../components/feedback/app_confirm_dialog.dart';
import '../../../../../components/feedback/app_snackbar.dart';
import '../../../../../components/media/exercise_illustration.dart';
import '../../../../../components/modals/alterar_carga_modal.dart';
import '../../../../../components/modals/evolucao_carga_modal.dart';
import '../../../../../components/modals/observacoes_modal.dart';
import '../../../../../components/navbars/app_navbar.dart';
import '../../../../../components/scaffolds/app_scaffold.dart';
import '../../../../../components/steppers/serie_stepper.dart';
import '../../../../../core/abstracts/format_service_interface.dart';
import '../../../../../core/theme/tokens/color_tokens.dart';
import '../../../../../core/theme/tokens/spacing_tokens.dart';
import '../../../../../core/theme/tokens/typography_tokens.dart';
import '../../../../../models/exercicio.dart';
import '../../../../../models/registro_carga.dart';
import '../../../../../models/treino.dart';
import '../../../../../models/treino_exercicio.dart';
import '../../abstracts/execucao_controller_interface.dart';

/// Menu da execucao (planejamento telas 22 e 24): observacoes da serie e
/// evolucao de carga do exercicio atual.
class _MenuExecucao extends StatelessWidget {
  const _MenuExecucao({required this.controller});

  final ExecucaoControllerInterface controller;

  Future<void> _abrirObservacoes() async {
    final ObservacaoResultado? resultado = await showObservacoesModal();
    if (resultado == null) {
      return;
    }
    controller.registrarObservacao(
      texto: resultado.texto,
      dificuldade: resultado.dificuldade,
    );
    AppSnackbar.success('Observação registrada');
  }

  Future<void> _abrirEvolucao() async {
    final TreinoExercicio? atual = controller.exercicioAtual;
    if (atual == null) {
      return;
    }
    final List<RegistroCarga> registros =
        await controller.registrosDoExercicioAtual();
    await showEvolucaoCargaModal(
      exercicioNome: atual.exercicio.nome,
      registros: registros,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      icon: const Icon(Icons.more_vert_rounded, color: ColorTokens.textPrimary),
      color: ColorTokens.bgSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusButton),
        side: const BorderSide(color: ColorTokens.divider),
      ),
      onSelected: (int opcao) {
        if (opcao == 0) {
          unawaited(_abrirObservacoes());
        } else {
          unawaited(_abrirEvolucao());
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
        const PopupMenuItem<int>(
          value: 0,
          child: _ItemMenu(
            icon: Icons.edit_note_rounded,
            label: 'Observações',
          ),
        ),
        const PopupMenuItem<int>(
          value: 1,
          child: _ItemMenu(
            icon: Icons.show_chart_rounded,
            label: 'Evolução de carga',
          ),
        ),
      ],
    );
  }
}

class _ItemMenu extends StatelessWidget {
  const _ItemMenu({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(icon, size: 18, color: ColorTokens.textSecondary),
        const Gap.horizontal(SpacingTokens.sm),
        Text(label, style: TypographyTokens.bodyStrong),
      ],
    );
  }
}

/// Botao quadrado de navegacao entre exercicios (anterior / proximo).
///
/// Usa icone em vez de texto para caber junto do botao "Realizado" mesmo em
/// telas de 360px.
class _NavegacaoExercicioButton extends StatelessWidget {
  const _NavegacaoExercicioButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool habilitado = onTap != null;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: ColorTokens.bgSurfaceAlt,
        borderRadius: BorderRadius.circular(SpacingTokens.radiusButton),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(SpacingTokens.radiusButton),
          child: SizedBox(
            height: SpacingTokens.buttonHeight,
            width: SpacingTokens.buttonHeight,
            child: Icon(
              icon,
              size: 24,
              color: habilitado
                  ? ColorTokens.textPrimary
                  : ColorTokens.textDisabled,
            ),
          ),
        ),
      ),
    );
  }
}

/// Tela 11/13/15 — exercicio em execucao: métricas, ilustracao, navegacao
/// entre exercicios e acao "Realizado" que dispara [ExecucaoControllerInterface.concluirSerie].
class ExercicioStepView extends StatelessWidget {
  const ExercicioStepView({super.key});

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
    final FormatServiceInterface format = Get.find();

    return Obx(() {
      final TreinoExercicio? treinoExercicio = controller.exercicioAtual;
      if (treinoExercicio == null) {
        return const AppScaffold(
          body: Center(
            child: CircularProgressIndicator(color: ColorTokens.accent),
          ),
        );
      }

      final Exercicio exercicio = treinoExercicio.exercicio;
      final Treino? t = controller.treino.value;
      final bool primeiroExercicio = controller.indiceExercicio.value == 0;
      final bool ultimoExercicio =
          t == null || controller.indiceExercicio.value >= t.exercicios.length - 1;

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
            title: exercicio.nome,
            onBack: () => unawaited(_confirmarAbandono(controller)),
            action: _MenuExecucao(controller: controller),
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    AppChip(
                      label: 'Série: ${controller.serieAtual.value} de ${controller.totalSeries}',
                      dense: true,
                    ),
                    const Gap.horizontal(SpacingTokens.sm),
                    AppChip(
                      label: 'Descanso: ${treinoExercicio.descansoSeg}s',
                      dense: true,
                    ),
                    const Spacer(),
                    // Cronometro geral do treino (regra transversal do
                    // planejamento §7): visivel durante toda a execucao.
                    AppChip(
                      label: format.cronometro(controller.segundosTreino.value),
                      icon: Icons.access_time_rounded,
                      dense: true,
                    ),
                  ],
                ),
                const Gap(SpacingTokens.md),
                SerieStepper(
                  total: controller.totalSeries,
                  atual: controller.serieAtual.value,
                  concluidas: controller.serieAtual.value - 1,
                ),
                const Gap(SpacingTokens.lg),
                ExerciseIllustration(
                  nome: exercicio.nome,
                  grupo: exercicio.grupoPrimario,
                  height: 200,
                  gifUrl: exercicio.gifUrl,
                ),
                const Gap(SpacingTokens.md),
                MuscleChipsRow(grupos: exercicio.todosGrupos),
                const Gap(SpacingTokens.lg),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: StatBox(
                        value: '${treinoExercicio.repeticoes}',
                        label: 'Repetições',
                        compact: true,
                      ),
                    ),
                    const Gap.horizontal(SpacingTokens.sm),
                    Expanded(
                      child: StatBox(
                        value: format.cargaKg(controller.cargaAtual),
                        label: 'Carga',
                        compact: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          footer: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: <Widget>[
                  _NavegacaoExercicioButton(
                    icon: Icons.chevron_left_rounded,
                    tooltip: 'Exercício anterior',
                    onTap: primeiroExercicio ? null : controller.anterior,
                  ),
                  const Gap.horizontal(SpacingTokens.sm),
                  Expanded(
                    child: AppButton(
                      label: 'Realizado',
                      icon: Icons.check_rounded,
                      onPressed: () => unawaited(controller.concluirSerie()),
                    ),
                  ),
                  const Gap.horizontal(SpacingTokens.sm),
                  _NavegacaoExercicioButton(
                    icon: Icons.chevron_right_rounded,
                    tooltip: 'Próximo exercício',
                    onTap: ultimoExercicio ? null : controller.proximo,
                  ),
                ],
              ),
              const Gap(SpacingTokens.sm),
              AppButton(
                label: 'Alterar carga',
                variant: AppButtonVariant.ghost,
                size: AppButtonSize.small,
                icon: Icons.tune_rounded,
                onPressed: () async {
                  final double? novaCarga = await showAlterarCargaModal(
                    cargaAtual: controller.cargaAtual,
                    sugestao: controller.cargaAtual + 2.5,
                  );
                  if (novaCarga != null) {
                    await controller.alterarCarga(novaCarga);
                  }
                },
              ),
            ],
          ),
        ),
      );
    });
  }
}
