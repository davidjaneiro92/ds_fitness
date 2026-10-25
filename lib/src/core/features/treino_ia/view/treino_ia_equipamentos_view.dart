import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../components/cards/app_card.dart';
import '../../../../components/scaffolds/app_scaffold.dart';
import '../../../../constants/app_assets.dart';
import '../../../../core/theme/tokens/color_tokens.dart';
import '../../../../core/theme/tokens/spacing_tokens.dart';
import '../../../../core/theme/tokens/typography_tokens.dart';
import '../../../../enum/pages_routes.dart';
import '../abstracts/treino_ia_controller_interface.dart';
import 'widgets/treino_ia_widgets.dart';

/// Etapa 2/4: grade ilustrada dos recursos disponíveis em casa.
class TreinoIaEquipamentosView extends GetView<TreinoIaControllerInterface> {
  const TreinoIaEquipamentosView({super.key});

  static const List<_EquipamentoVisual> _opcoes = <_EquipamentoVisual>[
    _EquipamentoVisual('Halteres', 'Halteres', AppAssets.iaHalteres),
    _EquipamentoVisual('Elástico', 'Elástico', AppAssets.iaElastico),
    _EquipamentoVisual('Banco', 'Banco', AppAssets.iaBanco),
    _EquipamentoVisual(
      'Peso do corpo',
      'Peso do corpo',
      AppAssets.iaPesoCorporal,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      navbar: const TreinoIaProgressHeader(etapaAtual: 2),
      body: TreinoIaContentFrame(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const TreinoIaStepTitle(
              titulo: 'O que você tem em casa?',
              descricao: 'Selecione todos os itens disponíveis',
            ),
            Expanded(
              child: Obx(() {
                // O itemBuilder do GridView é preguiçoso. A cópia lida aqui
                // mantém a seleção dentro do escopo reativo do Obx.
                final Set<String> selecionados =
                    controller.equipamentosSelecionados.toSet();
                return GridView.builder(
                  padding: const EdgeInsets.only(bottom: SpacingTokens.md),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: SpacingTokens.sm,
                    mainAxisSpacing: SpacingTokens.sm,
                    childAspectRatio: 0.92,
                  ),
                  itemCount: _opcoes.length,
                  itemBuilder: (BuildContext context, int index) {
                    final _EquipamentoVisual opcao = _opcoes[index];
                    final bool selecionado = selecionados.contains(opcao.valor);
                    return _EquipamentoCard(
                      equipamento: opcao,
                      selecionado: selecionado,
                      onTap: () => controller.alternarEquipamento(opcao.valor),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
      footer: TreinoIaStepFooter(
        label: 'Continuar',
        onPressed: () => Get.toNamed<void>(PagesRoutes.treinoIaLesoes.path),
      ),
    );
  }
}

class _EquipamentoVisual {
  const _EquipamentoVisual(this.nome, this.valor, this.asset);

  final String nome;
  final String valor;
  final String asset;
}

class _EquipamentoCard extends StatelessWidget {
  const _EquipamentoCard({
    required this.equipamento,
    required this.selecionado,
    required this.onTap,
  });

  final _EquipamentoVisual equipamento;
  final bool selecionado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      highlighted: selecionado,
      background: selecionado ? ColorTokens.bgAccentSurface : null,
      padding: const EdgeInsets.all(SpacingTokens.sm),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
              top: SpacingTokens.md,
              bottom: SpacingTokens.md,
            ),
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Image.asset(
                    equipamento.asset,
                    fit: BoxFit.contain,
                    cacheWidth: 420,
                    errorBuilder: (
                      BuildContext context,
                      Object erro,
                      StackTrace? stackTrace,
                    ) =>
                        const Icon(
                      Icons.fitness_center_rounded,
                      size: 52,
                      color: ColorTokens.accent,
                    ),
                  ),
                ),
                const SizedBox(height: SpacingTokens.xs),
                Text(
                  equipamento.nome,
                  style: TypographyTokens.bodyStrong,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Icon(
              selecionado ? Icons.check_circle_rounded : Icons.circle_outlined,
              size: 22,
              color:
                  selecionado ? ColorTokens.accent : ColorTokens.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
