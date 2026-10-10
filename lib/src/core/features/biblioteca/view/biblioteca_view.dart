import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../components/cards/exercise_card.dart';
import '../../../../components/chips/app_chip.dart';
import '../../../../components/common/gap.dart';
import '../../../../components/empty_states/empty_state.dart';
import '../../../../components/inputs/app_search_field.dart';
import '../../../../components/navbars/app_bottom_nav.dart';
import '../../../../components/navbars/app_navbar.dart';
import '../../../../components/scaffolds/app_scaffold.dart';
import '../../../../enum/app_tab.dart';
import '../../../../enum/grupo_muscular.dart';
import '../../../../enum/periodo_estatistica.dart';
import '../../../../models/exercicio.dart';
import '../../../theme/tokens/color_tokens.dart';
import '../../../theme/tokens/spacing_tokens.dart';
import '../abstracts/biblioteca_controller_interface.dart';

/// Tela 18 — Biblioteca de Exercicios.
class BibliotecaView extends GetView<BibliotecaControllerInterface> {
  const BibliotecaView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      navbar: AppNavbar(
        title: 'Exercícios',
        showBack: false,
        action: NavbarAction(
          icon: Icons.add_rounded,
          onTap: () => controller.novoExercicio(),
          color: ColorTokens.accent,
        ),
      ),
      bottomNav: const AppBottomNav(current: AppTab.exercicios),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AppSearchField(onChanged: controller.buscar),
          const Gap(SpacingTokens.md),
          Obx(
            () => AppChipBar(
              labels: BibliotecaFiltro.values
                  .map((BibliotecaFiltro f) => f.label)
                  .toList(),
              selectedIndex:
                  BibliotecaFiltro.values.indexOf(controller.filtro.value),
              onSelected: (int index) => controller
                  .selecionarFiltro(BibliotecaFiltro.values[index]),
            ),
          ),
          const Gap(SpacingTokens.md),
          SizedBox(
            height: SpacingTokens.buttonHeightSm,
            child: Obx(() {
              // O Rx precisa ser lido no corpo do Obx: dentro do itemBuilder
              // ele seria avaliado fora do escopo reativo.
              final GrupoMuscular? grupoSelecionado =
                  controller.grupoFiltro.value;
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: GrupoMuscular.grid.length,
                separatorBuilder: (BuildContext context, int index) =>
                    const Gap.horizontal(SpacingTokens.sm),
                itemBuilder: (BuildContext context, int index) {
                  final GrupoMuscular grupo = GrupoMuscular.grid[index];
                  final bool selecionado = grupo == GrupoMuscular.todos
                      ? grupoSelecionado == null
                      : grupoSelecionado == grupo;
                  return AppChip(
                    label: grupo.label,
                    selected: selecionado,
                    dense: true,
                    onTap: () => controller.selecionarGrupo(
                      grupo == GrupoMuscular.todos ? null : grupo,
                    ),
                  );
                },
              );
            }),
          ),
          const Gap(SpacingTokens.md),
          Expanded(
            child: Obx(() {
              if (controller.carregando.value) {
                return const Center(
                  child: CircularProgressIndicator(color: ColorTokens.accent),
                );
              }
              final List<Exercicio> lista = controller.filtrados;
              if (lista.isEmpty) {
                return _EmptyBiblioteca(filtro: controller.filtro.value);
              }
              return ListView.separated(
                itemCount: lista.length,
                separatorBuilder: (BuildContext context, int index) =>
                    const Gap(SpacingTokens.sm),
                itemBuilder: (BuildContext context, int index) {
                  final Exercicio exercicio = lista[index];
                  return ExerciseCard(
                    exercicio: exercicio,
                    subtitle: exercicio.gruposLabel,
                    onTap: () => controller.abrirDetalhe(exercicio),
                    trailing: IconButton(
                      onPressed: () =>
                          controller.alternarFavorito(exercicio.id),
                      icon: Icon(
                        exercicio.favorito
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: exercicio.favorito
                            ? ColorTokens.warning
                            : ColorTokens.textSecondary,
                      ),
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

/// Estado vazio contextual para cada filtro da biblioteca.
class _EmptyBiblioteca extends StatelessWidget {
  const _EmptyBiblioteca({required this.filtro});

  final BibliotecaFiltro filtro;

  @override
  Widget build(BuildContext context) {
    final String titulo;
    final String mensagem;
    switch (filtro) {
      case BibliotecaFiltro.favoritos:
        titulo = 'Nenhum favorito ainda';
        mensagem = 'Toque na estrela de um exercício para adicioná-lo aqui.';
      case BibliotecaFiltro.recentes:
        titulo = 'Nenhum exercício recente';
        mensagem = 'Os exercícios que você abrir vão aparecer aqui.';
      case BibliotecaFiltro.todos:
        titulo = 'Nenhum exercício encontrado';
        mensagem = 'Tente ajustar a busca ou o filtro selecionado.';
    }
    return EmptyState(
      icon: Icons.fitness_center_rounded,
      title: titulo,
      message: mensagem,
    );
  }
}
