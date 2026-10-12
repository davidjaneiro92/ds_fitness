import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../components/buttons/app_button.dart';
import '../../../../components/cards/exercicio_selecao_tile.dart';
import '../../../../components/common/gap.dart';
import '../../../../components/common/page_header.dart';
import '../../../../components/empty_states/empty_state.dart';
import '../../../../components/inputs/app_search_field.dart';
import '../../../../components/navbars/app_navbar.dart';
import '../../../../components/scaffolds/app_scaffold.dart';
import '../../../../core/theme/tokens/spacing_tokens.dart';
import '../../../../enum/pages_routes.dart';
import '../../../../models/exercicio.dart';
import '../abstracts/exercicios_controller_interface.dart';
import '../abstracts/treino_form_controller_interface.dart';

/// Passo 3 do fluxo — *Selecionar exercício* (`/exercicios`): os exercicios dos
/// grupos escolhidos, com busca, e um deles marcado. *Configurar exercício* leva
/// a tela de series, repeticoes e descanso.
class ExerciciosView extends GetView<ExerciciosControllerInterface> {
  const ExerciciosView({super.key});

  @override
  Widget build(BuildContext context) {
    final TreinoFormControllerInterface treinoForm = Get.find();

    return AppScaffold(
      navbar: const AppNavbar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const PageHeader(title: 'Selecionar exercício'),
          AppSearchField(onChanged: controller.buscar),
          const Gap(SpacingTokens.md),
          Expanded(
            child: Obx(() {
              if (controller.carregando.value) {
                return const Center(child: CircularProgressIndicator());
              }
              final List<Exercicio> lista = controller.filtrados;
              if (lista.isEmpty) {
                return const EmptyState(
                  icon: Icons.search_off_rounded,
                  title: 'Nenhum exercício encontrado',
                  message: 'Tente pesquisar por outro nome ou escolha outros grupos.',
                );
              }
              final Set<String> adicionados = controller.adicionadosIds;
              final String? escolhido = treinoForm.exercicioEscolhido.value?.id;
              return ListView.builder(
                itemCount: lista.length,
                itemBuilder: (BuildContext context, int index) {
                  final Exercicio exercicio = lista[index];
                  return ExercicioSelecaoTile(
                    exercicio: exercicio,
                    selecionado: exercicio.id == escolhido,
                    jaAdicionado: adicionados.contains(exercicio.id),
                    onTap: () => treinoForm.escolherExercicio(exercicio),
                  );
                },
              );
            }),
          ),
        ],
      ),
      footer: Obx(
        () => AppButton(
          label: 'Configurar exercício',
          onPressed: treinoForm.exercicioEscolhido.value == null
              ? null
              : () => Get.toNamed<void>(PagesRoutes.exercicioConfigurar.path),
        ),
      ),
    );
  }
}
