import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../components/cards/app_card.dart';
import '../../../../components/chips/app_chip.dart';
import '../../../../components/common/gap.dart';
import '../../../../components/empty_states/empty_state.dart';
import '../../../../components/modals/app_modal_sheet.dart';
import '../../../../components/navbars/app_bottom_nav.dart';
import '../../../../components/navbars/app_navbar.dart';
import '../../../../components/scaffolds/app_scaffold.dart';
import '../../../../core/abstracts/format_service_interface.dart';
import '../../../../core/theme/tokens/color_tokens.dart';
import '../../../../core/theme/tokens/spacing_tokens.dart';
import '../../../../core/theme/tokens/typography_tokens.dart';
import '../../../../enum/app_tab.dart';
import '../../../../enum/periodo_estatistica.dart';
import '../../../../models/sessao.dart';
import '../abstracts/historico_controller_interface.dart';
import 'widgets/sessao_detalhe_sheet.dart';
import 'widgets/sessao_tile.dart';

const double _limiteScrollPx = 200;

/// Tela de historico (tela 16) — sessoes paginadas com scroll infinito e
/// resumo agrupado por exercicio.
class HistoricoView extends StatefulWidget {
  const HistoricoView({super.key});

  @override
  State<HistoricoView> createState() => _HistoricoViewState();
}

class _HistoricoViewState extends State<HistoricoView> {
  final HistoricoControllerInterface _controller = Get.find();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }
    final double faltante = _scrollController.position.maxScrollExtent -
        _scrollController.position.pixels;
    if (faltante <= _limiteScrollPx) {
      _controller.carregarMais();
    }
  }

  void _abrirDetalhe(Sessao sessao) {
    showAppModalSheet<void>(
      title: sessao.treinoNome,
      child: SessaoDetalheSheet(sessao: sessao),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      navbar: const AppNavbar(title: 'Histórico'),
      bottomNav: const AppBottomNav(current: AppTab.treinos),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Gap(SpacingTokens.md),
          Obx(
            () => AppChipBar(
              labels: HistoricoFiltro.values
                  .map((HistoricoFiltro f) => f.label)
                  .toList(),
              selectedIndex:
                  HistoricoFiltro.values.indexOf(_controller.filtro.value),
              onSelected: (int i) =>
                  _controller.trocarFiltro(HistoricoFiltro.values[i]),
            ),
          ),
          const Gap(SpacingTokens.md),
          Expanded(
            child: Obx(() {
              if (_controller.carregando.value) {
                return const Center(
                  child: CircularProgressIndicator(color: ColorTokens.accent),
                );
              }
              if (_controller.filtro.value == HistoricoFiltro.exercicios) {
                return _buildResumoExercicios();
              }
              return _buildSessoes();
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSessoes() {
    return Obx(() {
      final List<Sessao> sessoes = _controller.sessoes;
      if (sessoes.isEmpty) {
        return const EmptyState(
          icon: Icons.history_rounded,
          title: 'Nenhuma sessão ainda',
          message: 'Seus treinos concluídos vão aparecer aqui.',
        );
      }
      final bool mostrarLoadingFinal = _controller.temMais.value;
      return ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.only(bottom: SpacingTokens.lg),
        itemCount: sessoes.length + (mostrarLoadingFinal ? 1 : 0),
        separatorBuilder: (BuildContext context, int index) =>
            const Gap(SpacingTokens.sm),
        itemBuilder: (BuildContext context, int index) {
          if (index >= sessoes.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: SpacingTokens.md),
              child: Center(
                child: CircularProgressIndicator(color: ColorTokens.accent),
              ),
            );
          }
          final Sessao sessao = sessoes[index];
          return SessaoTile(
            sessao: sessao,
            onTap: () => _abrirDetalhe(sessao),
          );
        },
      );
    });
  }

  Widget _buildResumoExercicios() {
    return Obx(() {
      final List<ResumoExercicio> resumo = _controller.resumoExercicios;
      if (resumo.isEmpty) {
        return const EmptyState(
          icon: Icons.fitness_center_rounded,
          title: 'Nenhum exercício registrado',
          message: 'Execute um treino para ver o resumo por exercício.',
        );
      }
      return ListView.separated(
        padding: const EdgeInsets.only(bottom: SpacingTokens.lg),
        itemCount: resumo.length,
        separatorBuilder: (BuildContext context, int index) =>
            const Gap(SpacingTokens.sm),
        itemBuilder: (BuildContext context, int index) {
          return _ResumoExercicioTile(resumo: resumo[index]);
        },
      );
    });
  }
}

class _ResumoExercicioTile extends StatelessWidget {
  const _ResumoExercicioTile({required this.resumo});

  final ResumoExercicio resumo;

  @override
  Widget build(BuildContext context) {
    final FormatServiceInterface format = Get.find();
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(resumo.nome, style: TypographyTokens.bodyStrong),
          const Gap(SpacingTokens.xs),
          Text(
            '${resumo.execucoes} execuções · melhor carga '
            '${format.cargaKg(resumo.melhorCarga)}',
            style: TypographyTokens.bodyMuted,
          ),
        ],
      ),
    );
  }
}
