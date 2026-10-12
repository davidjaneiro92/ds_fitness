import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../components/buttons/app_button.dart';
import '../../../../components/cards/grupo_muscular_tile.dart';
import '../../../../components/common/page_header.dart';
import '../../../../components/navbars/app_navbar.dart';
import '../../../../components/scaffolds/app_scaffold.dart';
import '../../../../core/theme/tokens/spacing_tokens.dart';
import '../../../../enum/grupo_muscular.dart';
import '../../../../enum/pages_routes.dart';
import '../abstracts/treino_form_controller_interface.dart';

/// Passo 2 do fluxo — *Grupos musculares* (`/grupos`): a escolha de um ou mais
/// grupos para o treino. *Próximo* leva a lista de exercicios deles.
class GruposView extends StatefulWidget {
  const GruposView({super.key});

  @override
  State<GruposView> createState() => _GruposViewState();
}

class _GruposViewState extends State<GruposView> {
  // Guardado ao criar a tela: ver `TreinoFormControllerInterface`.
  final TreinoFormControllerInterface _controller = Get.find();

  void _proximo() {
    _controller.iniciarAdicao();
    Get.toNamed<void>(PagesRoutes.exercicios.path);
  }

  @override
  Widget build(BuildContext context) {
    final List<GrupoMuscular> grupos = GrupoMuscular.reais;

    return AppScaffold(
      navbar: const AppNavbar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const PageHeader(
            title: 'Grupos musculares',
            subtitle: 'Selecione um ou mais grupos para este treino.',
          ),
          Expanded(
            child: GridView.builder(
              // Folga para o visto que sai um pouco do canto do quadro.
              padding: const EdgeInsets.only(
                top: SpacingTokens.sm,
                right: SpacingTokens.xs,
                bottom: SpacingTokens.md,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: SpacingTokens.sm + 4,
                mainAxisSpacing: SpacingTokens.sm + 4,
                childAspectRatio: 0.82,
              ),
              itemCount: grupos.length,
              itemBuilder: (BuildContext context, int index) {
                final GrupoMuscular grupo = grupos[index];
                return Obx(
                  () => GrupoMuscularTile(
                    grupo: grupo,
                    selecionado: _controller.gruposSelecionados.contains(grupo),
                    onTap: () => _controller.alternarGrupo(grupo),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      footer: Obx(
        () => AppButton(
          label: 'Próximo',
          onPressed: _controller.gruposSelecionados.isEmpty ? null : _proximo,
        ),
      ),
    );
  }
}
