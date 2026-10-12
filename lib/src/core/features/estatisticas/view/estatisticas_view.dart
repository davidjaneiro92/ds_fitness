import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../components/cards/app_card.dart';
import '../../../../components/cards/stat_box.dart';
import '../../../../components/charts/app_line_chart.dart';
import '../../../../components/common/gap.dart';
import '../../../../components/common/page_header.dart';
import '../../../../components/common/section_header.dart';
import '../../../../components/empty_states/empty_state.dart';
import '../../../../components/inputs/app_dropdown_field.dart';
import '../../../../components/navbars/app_bottom_nav.dart';
import '../../../../components/navbars/app_navbar.dart';
import '../../../../components/scaffolds/app_scaffold.dart';
import '../../../../core/abstracts/format_service_interface.dart';
import '../../../../core/theme/tokens/color_tokens.dart';
import '../../../../core/theme/tokens/spacing_tokens.dart';
import '../../../../core/theme/tokens/typography_tokens.dart';
import '../../../../enum/app_tab.dart';
import '../../../../enum/pages_routes.dart';
import '../../../../enum/periodo_estatistica.dart';
import '../abstracts/estatisticas_controller_interface.dart';

const double _gridSpacing = SpacingTokens.sm + SpacingTokens.xs;
const double _dropdownWidth = 180;
const double _distribuicaoLabelWidth = 90;
const double _distribuicaoPercentWidth = 40;

/// Tela de estatisticas (tela 17) — agregacoes por periodo, grafico de
/// evolucao de volume e distribuicao por grupo muscular.
class EstatisticasView extends StatelessWidget {
  const EstatisticasView({super.key});

  @override
  Widget build(BuildContext context) {
    final EstatisticasControllerInterface controller = Get.find();
    final FormatServiceInterface format = Get.find();

    return AppScaffold(
      bottomNav: const AppBottomNav(current: AppTab.evolucao),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Gap(SpacingTokens.lg),
          PageHeader(
            title: 'Evolução',
            subtitle: 'Seus treinos e sua carga ao longo do tempo.',
            trailing: NavbarAction(
              icon: Icons.history_rounded,
              onTap: () => Get.toNamed<void>(PagesRoutes.historico.path),
            ),
          ),
          Expanded(child: _Resumo(controller: controller, format: format)),
        ],
      ),
    );
  }
}

/// O corpo da tela: periodo, numeros, grafico e distribuicao por grupo.
class _Resumo extends StatelessWidget {
  const _Resumo({required this.controller, required this.format});

  final EstatisticasControllerInterface controller;
  final FormatServiceInterface format;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.carregando.value) {
        return const Center(
          child: CircularProgressIndicator(color: ColorTokens.accent),
        );
      }

      final bool semDados = controller.totalTreinos.value == 0;

      return SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: SpacingTokens.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Gap(SpacingTokens.md),
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: _dropdownWidth,
                child: AppDropdownField<PeriodoEstatistica>(
                  label: '',
                  value: controller.periodo.value,
                  items: PeriodoEstatistica.values,
                  itemLabel: (PeriodoEstatistica p) => p.label,
                  onChanged: (PeriodoEstatistica? p) {
                    if (p != null) {
                      controller.trocarPeriodo(p);
                    }
                  },
                ),
              ),
            ),
            const Gap(SpacingTokens.lg),
            if (semDados)
              const EmptyState(
                icon: Icons.bar_chart_rounded,
                title: 'Sem dados no período',
                message: 'Escolha outro período ou conclua um treino.',
              )
            else ...<Widget>[
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.5,
                mainAxisSpacing: _gridSpacing,
                crossAxisSpacing: _gridSpacing,
                children: <Widget>[
                  StatBox(
                    value: format.numero(controller.totalTreinos.value),
                    label: 'Treinos',
                  ),
                  StatBox(
                    value: format.duracao(controller.tempoTotalSeg.value),
                    label: 'Tempo total',
                  ),
                  StatBox(
                    value: format.volume(controller.volumeTotal.value),
                    label: 'Volume total',
                  ),
                  StatBox(
                    value: format.numero(controller.calorias.value),
                    label: 'Calorias',
                  ),
                ],
              ),
              const Gap(SpacingTokens.lg),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Evolução de volume (kg)',
                      style: TypographyTokens.cardTitle,
                    ),
                    const Gap(SpacingTokens.md),
                    AppLineChart(
                      points: controller.pontosVolume,
                      height: 180,
                      formatarValor: (double v) => format.numero(v),
                    ),
                  ],
                ),
              ),
              const Gap(SpacingTokens.lg),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Distribuição por grupo muscular',
                      style: TypographyTokens.cardTitle,
                    ),
                    const Gap(SpacingTokens.md),
                    for (final DistribuicaoGrupo grupo
                        in controller.distribuicao)
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: SpacingTokens.sm + 4,
                        ),
                        child: Row(
                          children: <Widget>[
                            SizedBox(
                              width: _distribuicaoLabelWidth,
                              child: Text(
                                grupo.nome,
                                style: TypographyTokens.body,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Expanded(
                              child: AppProgressBar(
                                value: grupo.percentual,
                              ),
                            ),
                            const Gap.horizontal(SpacingTokens.sm),
                            SizedBox(
                              width: _distribuicaoPercentWidth,
                              child: Text(
                                '${(grupo.percentual * 100).round()}%',
                                textAlign: TextAlign.right,
                                style: TypographyTokens.bodyMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    });
  }
}
