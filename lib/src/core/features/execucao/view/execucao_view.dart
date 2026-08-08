import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../components/scaffolds/app_scaffold.dart';
import '../../../../core/theme/tokens/color_tokens.dart';
import '../../../../enum/execucao_state.dart';
import '../abstracts/execucao_controller_interface.dart';
import 'widgets/descanso_view.dart';
import 'widgets/exercicio_step_view.dart';
import 'widgets/serie_concluida_overlay.dart';

/// Host da execucao de treino (rota `/execucao`): alterna entre os
/// widgets de cada [ExecucaoState] com uma transicao suave.
class ExecucaoView extends GetView<ExecucaoControllerInterface> {
  const ExecucaoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final Widget child = controller.exercicioAtual == null
          ? const _EstadoCarregando()
          : switch (controller.estado.value) {
              ExecucaoState.carregando => const _EstadoCarregando(),
              ExecucaoState.exercicio => const ExercicioStepView(),
              ExecucaoState.descanso => const DescansoView(),
              ExecucaoState.serieConcluida => const SerieConcluidaOverlay(),
              ExecucaoState.concluido => const _EstadoCarregando(),
            };

      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: KeyedSubtree(
          key: ValueKey<ExecucaoState>(controller.estado.value),
          child: child,
        ),
      );
    });
  }
}

class _EstadoCarregando extends StatelessWidget {
  const _EstadoCarregando();

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      body: Center(
        child: CircularProgressIndicator(color: ColorTokens.accent),
      ),
    );
  }
}
