import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../components/anatomy/grupo_muscular_imagem.dart';
import '../../../../components/cards/app_card.dart';
import '../../../../components/scaffolds/app_scaffold.dart';
import '../../../../core/theme/tokens/color_tokens.dart';
import '../../../../core/theme/tokens/spacing_tokens.dart';
import '../../../../core/theme/tokens/typography_tokens.dart';
import '../../../../enum/grupo_muscular.dart';
import '../abstracts/treino_ia_controller_interface.dart';
import 'widgets/treino_ia_widgets.dart';

/// Etapa 4/4: priorização visual dos grupos musculares.
class TreinoIaFocoView extends GetView<TreinoIaControllerInterface> {
  const TreinoIaFocoView({super.key});

  static const List<GrupoMuscular> _grupos = <GrupoMuscular>[
    GrupoMuscular.peito,
    GrupoMuscular.costas,
    GrupoMuscular.ombro,
    GrupoMuscular.biceps,
    GrupoMuscular.triceps,
    GrupoMuscular.antebraco,
    GrupoMuscular.pernas,
    GrupoMuscular.gluteos,
    GrupoMuscular.panturrilha,
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      navbar: PreferredSize(
        preferredSize: const Size.fromHeight(SpacingTokens.navBarHeight),
        child: Obx(() {
          final bool treinaEmCasa = controller.local.value == 'casa';
          return TreinoIaProgressHeader(
            etapaAtual: treinaEmCasa ? 5 : 4,
            totalEtapas: treinaEmCasa ? 5 : 4,
          );
        }),
      ),
      body: TreinoIaContentFrame(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const TreinoIaStepTitle(
              titulo: 'Quais grupos quer priorizar?',
              descricao: 'Escolha quantos quiser',
            ),
            Expanded(
              child: Obx(() {
                // A seleção precisa ser capturada no Obx antes do GridView
                // construir seus itens sob demanda.
                final Set<GrupoMuscular> selecionados = controller.foco.toSet();
                return CustomScrollView(
                  slivers: <Widget>[
                    SliverPadding(
                      padding: const EdgeInsets.only(bottom: SpacingTokens.sm),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                            final GrupoMuscular grupo = _grupos[index];
                            return _GrupoMuscularCard(
                              grupo: grupo,
                              selecionado: selecionados.contains(grupo),
                              onTap: () => controller.alternarFoco(grupo),
                            );
                          },
                          childCount: _grupos.length,
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: SpacingTokens.sm,
                          mainAxisSpacing: SpacingTokens.sm,
                          childAspectRatio: 0.84,
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding:
                            const EdgeInsets.only(bottom: SpacingTokens.md),
                        child: SizedBox(
                          height: 112,
                          child: _GrupoMuscularCard(
                            grupo: GrupoMuscular.abdomen,
                            selecionado:
                                selecionados.contains(GrupoMuscular.abdomen),
                            onTap: () =>
                                controller.alternarFoco(GrupoMuscular.abdomen),
                            largo: true,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
      footer: Obx(
        () => TreinoIaStepFooter(
          label: 'Ver prévia',
          loading: controller.carregandoPlano.value,
          onPressed: controller.carregandoPlano.value
              ? null
              : () => unawaited(controller.calcularPrevia()),
        ),
      ),
    );
  }
}

class _GrupoMuscularCard extends StatelessWidget {
  const _GrupoMuscularCard({
    required this.grupo,
    required this.selecionado,
    required this.onTap,
    this.largo = false,
  });

  final GrupoMuscular grupo;
  final bool selecionado;
  final VoidCallback onTap;
  final bool largo;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      highlighted: selecionado,
      background: selecionado ? ColorTokens.bgAccentSurface : null,
      padding: const EdgeInsets.all(SpacingTokens.xs),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          if (largo)
            Column(
              children: <Widget>[
                Expanded(
                  child: GrupoMuscularImagem(
                    grupo: grupo,
                    tamanho: 64,
                    destacado: selecionado,
                  ),
                ),
                Text(grupo.label, style: TypographyTokens.caption),
              ],
            )
          else
            Column(
              children: <Widget>[
                const SizedBox(height: SpacingTokens.xs),
                Expanded(
                  child: GrupoMuscularImagem(
                    grupo: grupo,
                    tamanho: 80,
                    destacado: selecionado,
                  ),
                ),
                Text(
                  grupo.label,
                  style: TypographyTokens.caption.copyWith(
                    color: ColorTokens.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          Align(
            alignment: Alignment.topRight,
            child: Icon(
              selecionado ? Icons.check_circle_rounded : Icons.circle_outlined,
              size: 18,
              color:
                  selecionado ? ColorTokens.accent : ColorTokens.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
