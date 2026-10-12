import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../components/buttons/app_button.dart';
import '../../../../components/cards/app_card.dart';
import '../../../../components/common/gap.dart';
import '../../../../components/common/page_header.dart';
import '../../../../components/empty_states/empty_state.dart';
import '../../../../components/inputs/stepper_field.dart';
import '../../../../components/media/exercise_illustration.dart';
import '../../../../components/navbars/app_navbar.dart';
import '../../../../components/scaffolds/app_scaffold.dart';
import '../../../../core/theme/tokens/color_tokens.dart';
import '../../../../core/theme/tokens/spacing_tokens.dart';
import '../../../../core/theme/tokens/typography_tokens.dart';
import '../../../../enum/pages_routes.dart';
import '../../../../models/exercicio.dart';
import '../abstracts/treino_form_controller_interface.dart';

/// Passo 4 do fluxo — *Configurar exercício* (`/exercicios/configurar`): o
/// exercicio escolhido, com o GIF do movimento, e os tres campos do treino:
/// series, repeticoes e descanso. A carga nao se define aqui, e sim na
/// execucao.
///
/// Serve tambem para editar um exercicio que ja esta no treino (aberto pelo
/// menu da tela de revisao).
class ExercicioConfigurarView extends StatefulWidget {
  const ExercicioConfigurarView({super.key});

  @override
  State<ExercicioConfigurarView> createState() =>
      _ExercicioConfigurarViewState();
}

class _ExercicioConfigurarViewState extends State<ExercicioConfigurarView> {
  static const int _maximoDeSeries = 20;
  static const int _maximoDeRepeticoes = 100;
  static const int _minimoDeDescansoSeg = 15;
  static const int _maximoDeDescansoSeg = 600;
  static const int _passoDoDescansoSeg = 15;

  // Guardado ao criar a tela: ver `TreinoFormControllerInterface`.
  final TreinoFormControllerInterface _controller = Get.find();

  /// Volta a tela de revisao.
  ///
  /// Num treino que ja existe, a revisao e a base do fluxo — a lista de treinos
  /// espera por ela e so recarrega quando ela sai da pilha —, entao ela fica onde
  /// esta e so se volta a ela. Num treino novo ela e recriada: desempilha o que
  /// estiver acima do formulario e abre a revisao no lugar.
  void _confirmar() {
    _controller.confirmarConfiguracao();
    if (_controller.existente) {
      Get.until(
        (Route<dynamic> rota) =>
            rota.settings.name == PagesRoutes.treinoRevisar.path,
      );
      return;
    }
    Get.offNamedUntil<void>(
      PagesRoutes.treinoRevisar.path,
      (Route<dynamic> rota) =>
          rota.settings.name == PagesRoutes.treinoNovo.path ||
          rota.settings.name == PagesRoutes.treinos.path,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final Exercicio? exercicio = _controller.exercicioEscolhido.value;
      if (exercicio == null) {
        return AppScaffold(
          navbar: const AppNavbar(),
          body: EmptyState(
            icon: Icons.search_off_rounded,
            title: 'Nenhum exercício selecionado',
            message: 'Volte e escolha o exercício que será configurado.',
            actionLabel: 'Voltar',
            onAction: () => Get.back<void>(),
          ),
        );
      }

      return AppScaffold(
        navbar: const AppNavbar(),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const PageHeader(title: 'Configurar exercício'),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(exercicio.nome, style: TypographyTokens.cardTitle),
                    const Gap(SpacingTokens.xxs),
                    Text(exercicio.gruposLabel, style: TypographyTokens.bodyMuted),
                    const Gap(SpacingTokens.md),
                    ExerciseIllustration(
                      imagem: exercicio.imagem,
                      grupo: exercicio.grupoPrimario,
                      height: 240,
                    ),
                  ],
                ),
              ),
              const Gap(SpacingTokens.md),
              AppCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: SpacingTokens.md,
                  vertical: SpacingTokens.sm,
                ),
                child: Column(
                  children: <Widget>[
                    _Linha(
                      child: StepperField(
                        icon: Icons.layers_outlined,
                        label: 'Séries',
                        value: _controller.series.value,
                        min: 1,
                        max: _maximoDeSeries,
                        onChanged: (num valor) =>
                            _controller.series.value = valor.toInt(),
                      ),
                    ),
                    const Divider(height: 1, color: ColorTokens.divider),
                    _Linha(
                      child: StepperField(
                        icon: Icons.repeat_rounded,
                        label: 'Repetições',
                        value: _controller.repeticoes.value,
                        min: 1,
                        max: _maximoDeRepeticoes,
                        onChanged: (num valor) =>
                            _controller.repeticoes.value = valor.toInt(),
                      ),
                    ),
                    const Divider(height: 1, color: ColorTokens.divider),
                    _Linha(
                      child: StepperField(
                        icon: Icons.timer_outlined,
                        label: 'Descanso',
                        value: _controller.descansoSeg.value,
                        min: _minimoDeDescansoSeg,
                        max: _maximoDeDescansoSeg,
                        step: _passoDoDescansoSeg,
                        suffix: 's',
                        onChanged: (num valor) =>
                            _controller.descansoSeg.value = valor.toInt(),
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(SpacingTokens.lg),
            ],
          ),
        ),
        footer: AppButton(
          label: _controller.editandoItem
              ? 'Salvar alterações'
              : 'Adicionar ao treino',
          onPressed: _confirmar,
        ),
      );
    });
  }
}

class _Linha extends StatelessWidget {
  const _Linha({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SpacingTokens.sm + 4),
      child: child,
    );
  }
}
