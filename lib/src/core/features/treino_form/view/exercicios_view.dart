import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../components/cards/exercise_card.dart';
import '../../../../components/common/gap.dart';
import '../../../../components/empty_states/empty_state.dart';
import '../../../../components/inputs/app_search_field.dart';
import '../../../../components/modals/app_modal_sheet.dart';
import '../../../../components/navbars/app_navbar.dart';
import '../../../../components/scaffolds/app_scaffold.dart';
import '../../../../core/theme/tokens/color_tokens.dart';
import '../../../../core/theme/tokens/spacing_tokens.dart';
import '../../../../models/exercicio.dart';
import '../../../../models/treino_exercicio.dart';
import '../abstracts/exercicios_controller_interface.dart';
import '../abstracts/treino_form_controller_interface.dart';
import 'widgets/add_exercicio_sheet.dart';

/// Tela 8 — lista de exercicios de um grupo muscular (`/exercicios`).
class ExerciciosView extends GetView<ExerciciosControllerInterface> {
  const ExerciciosView({super.key});

  Future<void> _abrirSheet(Exercicio exercicio) async {
    final TreinoFormControllerInterface treinoForm = Get.find();
    TreinoExercicio? existente;
    for (final TreinoExercicio item in treinoForm.exercicios) {
      if (item.exercicioId == exercicio.id) {
        existente = item;
        break;
      }
    }
    await showAppModalSheet<void>(
      title: exercicio.nome,
      child: AddExercicioSheet(exercicio: exercicio, existente: existente),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      navbar: AppNavbar(title: controller.grupo.label),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AppSearchField(onChanged: controller.buscar),
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
                return const EmptyState(
                  icon: Icons.search_off_rounded,
                  title: 'Nenhum exercício encontrado',
                  message: 'Tente pesquisar por outro nome.',
                );
              }
              final Set<String> adicionados = controller.adicionadosIds;
              return ListView.builder(
                itemCount: lista.length,
                itemBuilder: (BuildContext context, int index) {
                  final Exercicio exercicio = lista[index];
                  final bool jaAdicionado = adicionados.contains(exercicio.id);
                  return ExerciseCard(
                    exercicio: exercicio,
                    onTap: () => _abrirSheet(exercicio),
                    trailing: _BotaoAdicionar(
                      adicionado: jaAdicionado,
                      onTap: () => _abrirSheet(exercicio),
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

/// Botao circular do trailing do [ExerciseCard]: `+` quando ainda nao
/// adicionado ao treino, `check` (verde sobre `accentSoft`) quando ja esta.
class _BotaoAdicionar extends StatelessWidget {
  const _BotaoAdicionar({required this.adicionado, required this.onTap});

  final bool adicionado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: adicionado ? ColorTokens.accentSoft : ColorTokens.accent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          adicionado ? Icons.check_rounded : Icons.add_rounded,
          size: 18,
          color: adicionado ? ColorTokens.accent : ColorTokens.textOnAccent,
        ),
      ),
    );
  }
}
