import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../components/buttons/app_button.dart';
import '../../../../components/cards/app_card.dart';
import '../../../../components/empty_states/empty_state.dart';
import '../../../../components/navbars/app_navbar.dart';
import '../../../../components/scaffolds/app_scaffold.dart';
import '../../../../core/theme/tokens/color_tokens.dart';
import '../../../../core/theme/tokens/spacing_tokens.dart';
import '../../../../core/theme/tokens/typography_tokens.dart';
import '../../../../enum/pages_routes.dart';
import '../../../../models/treino.dart';
import '../../../../routes/route_args.dart';
import '../abstracts/treinos_controller_interface.dart';

/// Lista exclusiva para iniciar treinos. A edição continua em `/treinos`.
class TreinarView extends StatelessWidget {
  const TreinarView({super.key});

  @override
  Widget build(BuildContext context) {
    final TreinosControllerInterface controller = Get.find();

    return AppScaffold(
      navbar: const AppNavbar(title: 'Treinar'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.only(
              top: SpacingTokens.md,
              bottom: SpacingTokens.md,
            ),
            child: Text(
              'Escolha um treino para começar.',
              style: TypographyTokens.bodyMuted,
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.carregando.value) {
                return const Center(
                  child: CircularProgressIndicator(color: ColorTokens.accent),
                );
              }
              if (controller.treinos.isEmpty) {
                return EmptyState(
                  icon: Icons.fitness_center_rounded,
                  title: 'Você ainda não tem treinos',
                  message: 'Monte um treino antes de começar a treinar.',
                  actionLabel: 'Montar meu treino',
                  onAction: () =>
                      Get.toNamed<void>(PagesRoutes.treinoNovo.path),
                );
              }

              final String? treinoDoDiaId = controller.treinoDoDia.value?.id;
              return ListView.separated(
                padding: const EdgeInsets.only(bottom: SpacingTokens.md),
                itemCount: controller.treinos.length,
                separatorBuilder: (BuildContext context, int index) =>
                    const SizedBox(height: SpacingTokens.md),
                itemBuilder: (BuildContext context, int index) {
                  final Treino treino = controller.treinos[index];
                  return _TreinoParaIniciarCard(
                    treino: treino,
                    destaque: treino.id == treinoDoDiaId,
                    onStart: () => Get.toNamed<void>(
                      PagesRoutes.treinoExecucaoLista.path,
                      arguments: TreinoExecucaoListaArgs(treino: treino),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _TreinoParaIniciarCard extends StatelessWidget {
  const _TreinoParaIniciarCard({
    required this.treino,
    required this.onStart,
    this.destaque = false,
  });

  final Treino treino;
  final VoidCallback onStart;
  final bool destaque;

  int get _duracaoEstimadaSegundos => treino.exercicios.fold<int>(
        0,
        (int total, item) =>
            total +
            (item.series * item.repeticoes * 3) +
            ((item.series > 1 ? item.series - 1 : 0) * item.descansoSeg),
      );

  String get _duracaoEstimada {
    final int minutos = (_duracaoEstimadaSegundos / 60).ceil();
    return minutos == 1 ? 'Aprox. 1 min' : 'Aprox. $minutos min';
  }

  @override
  Widget build(BuildContext context) {
    final String dia = treino.dia?.nome ?? 'Dia não definido';

    return AppCard(
      highlighted: destaque,
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: ColorTokens.accentSoft,
                  borderRadius:
                      BorderRadius.circular(SpacingTokens.radiusButton),
                ),
                child: const Icon(
                  Icons.fitness_center_rounded,
                  color: ColorTokens.accent,
                ),
              ),
              const SizedBox(width: SpacingTokens.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(treino.nome, style: TypographyTokens.cardTitle),
                    const SizedBox(height: SpacingTokens.xxs),
                    Text(
                      '${treino.gruposLabel} • $dia',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TypographyTokens.label,
                    ),
                  ],
                ),
              ),
              if (destaque)
                const Icon(Icons.today_rounded, color: ColorTokens.accent),
            ],
          ),
          const SizedBox(height: SpacingTokens.md),
          Row(
            children: <Widget>[
              const Icon(
                Icons.format_list_numbered_rounded,
                size: 18,
                color: ColorTokens.textSecondary,
              ),
              const SizedBox(width: SpacingTokens.xs),
              Text(treino.exerciciosLabel, style: TypographyTokens.label),
              const SizedBox(width: SpacingTokens.md),
              const Icon(
                Icons.schedule_rounded,
                size: 18,
                color: ColorTokens.textSecondary,
              ),
              const SizedBox(width: SpacingTokens.xs),
              Text(_duracaoEstimada, style: TypographyTokens.label),
            ],
          ),
          const SizedBox(height: SpacingTokens.md),
          AppButton(
            label: 'Começar treino',
            icon: Icons.play_arrow_rounded,
            onPressed: onStart,
          ),
        ],
      ),
    );
  }
}
