import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../components/anatomy/grupo_muscular_imagem.dart';
import '../../../../components/anatomy/muscle_chip.dart';
import '../../../../components/buttons/app_button.dart';
import '../../../../components/charts/app_line_chart.dart';
import '../../../../components/chips/app_chip.dart';
import '../../../../components/common/gap.dart';
import '../../../../components/empty_states/empty_state.dart';
import '../../../../components/media/exercise_illustration.dart';
import '../../../../components/modals/evolucao_carga_modal.dart';
import '../../../../components/navbars/app_navbar.dart';
import '../../../../components/scaffolds/app_scaffold.dart';
import '../../../../enum/grupo_muscular.dart';
import '../../../../models/exercicio.dart';
import '../../../../models/registro_carga.dart';
import '../../../../routes/route_args.dart';
import '../../../abstracts/format_service_interface.dart';
import '../../../theme/tokens/color_tokens.dart';
import '../../../theme/tokens/spacing_tokens.dart';
import '../../../theme/tokens/typography_tokens.dart';
import '../abstracts/exercicio_detalhe_controller_interface.dart';

/// Tela 19 — Detalhe do Exercicio.
class ExercicioDetalheView
    extends GetView<ExercicioDetalheControllerInterface> {
  const ExercicioDetalheView({super.key});

  @override
  Widget build(BuildContext context) {
    final Object? args = Get.arguments;
    if (args is! ExercicioDetalheArgs) {
      return AppScaffold(
        navbar: AppNavbar(title: 'Exercício', onBack: () => Get.back<void>()),
        body: EmptyState(
          icon: Icons.search_off_rounded,
          title: 'Exercício não encontrado',
          message: 'Volte para a biblioteca e selecione um exercício.',
          actionLabel: 'Voltar',
          onAction: () => Get.back<void>(),
        ),
      );
    }

    return AppScaffold(
      navbar: _NavbarDoExercicio(controller: controller),
      body: DefaultTabController(
        length: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Obx(() => _Cabecalho(exercicio: controller.exercicio.value)),
            const Gap(SpacingTokens.md),
            const _TabBarEstilizada(),
            const Gap(SpacingTokens.sm),
            Expanded(
              child: TabBarView(
                children: <Widget>[
                  Obx(
                    () => _AbaExecucao(exercicio: controller.exercicio.value),
                  ),
                  Obx(
                    () => _AbaMusculos(exercicio: controller.exercicio.value),
                  ),
                  Obx(
                    () => _AbaHistorico(
                      nome: controller.exercicio.value.nome,
                      registros: controller.registros,
                      recorde: controller.recorde.value,
                      carregando: controller.carregando.value,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Navbar reativa: o titulo acompanha o nome do exercicio (que muda quando
/// ele e editado) e a edicao so aparece para exercicio do proprio usuario.
/// Fica fora do `Obx` da tela inteira para a aba escolhida nao ser perdida a
/// cada favorito.
class _NavbarDoExercicio extends StatelessWidget implements PreferredSizeWidget {
  const _NavbarDoExercicio({required this.controller});

  final ExercicioDetalheControllerInterface controller;

  @override
  Size get preferredSize => const Size.fromHeight(SpacingTokens.navBarHeight);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final Exercicio atual = controller.exercicio.value;
      return AppNavbar(
        title: atual.nome,
        action: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (atual.personalizado)
              NavbarAction(
                icon: Icons.edit_rounded,
                onTap: () => controller.editar(),
              ),
            NavbarAction(
              icon: atual.favorito
                  ? Icons.star_rounded
                  : Icons.star_outline_rounded,
              onTap: () => controller.alternarFavorito(),
              color: atual.favorito ? ColorTokens.warning : null,
            ),
          ],
        ),
      );
    });
  }
}

/// Cabecalho fixo: ilustracao, nome, equipamento e grupos musculares.
class _Cabecalho extends StatelessWidget {
  const _Cabecalho({required this.exercicio});

  final Exercicio exercicio;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        ExerciseIllustration(
          imagem: exercicio.imagem,
          grupo: exercicio.grupoPrimario,
          height: 220,
        ),
        const Gap(SpacingTokens.md),
        Text(exercicio.nome, style: TypographyTokens.screenTitle),
        if (exercicio.equipamento.isNotEmpty) ...<Widget>[
          const Gap(SpacingTokens.sm),
          AppChip(label: exercicio.equipamento, dense: true),
        ],
        const Gap(SpacingTokens.sm),
        MuscleChipsRow(grupos: exercicio.todosGrupos),
      ],
    );
  }
}

/// TabBar estilizada: indicador verde, sem divisor padrao.
class _TabBarEstilizada extends StatelessWidget {
  const _TabBarEstilizada();

  @override
  Widget build(BuildContext context) {
    return const TabBar(
      indicatorColor: ColorTokens.accent,
      indicatorSize: TabBarIndicatorSize.label,
      dividerColor: Colors.transparent,
      labelColor: ColorTokens.textPrimary,
      unselectedLabelColor: ColorTokens.textSecondary,
      labelStyle: TypographyTokens.bodyStrong,
      unselectedLabelStyle: TypographyTokens.body,
      tabs: <Widget>[
        Tab(text: 'Execução'),
        Tab(text: 'Músculos'),
        Tab(text: 'Histórico'),
      ],
    );
  }
}

/// Aba "Execução": passo a passo numerado a partir de [Exercicio.instrucoes].
class _AbaExecucao extends StatelessWidget {
  const _AbaExecucao({required this.exercicio});

  final Exercicio exercicio;

  @override
  Widget build(BuildContext context) {
    if (exercicio.instrucoes.isEmpty) {
      return const EmptyState(
        icon: Icons.list_alt_rounded,
        title: 'Sem instruções cadastradas',
        message: 'Este exercício ainda não tem passo a passo.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: SpacingTokens.lg),
      itemCount: exercicio.instrucoes.length,
      separatorBuilder: (BuildContext context, int index) =>
          const Gap(SpacingTokens.md),
      itemBuilder: (BuildContext context, int index) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: ColorTokens.accent,
                shape: BoxShape.circle,
              ),
              child: Text(
                '${index + 1}',
                style: TypographyTokens.bodyStrong
                    .copyWith(color: ColorTokens.textOnAccent),
              ),
            ),
            const Gap.horizontal(SpacingTokens.sm),
            Expanded(
              child: Text(
                exercicio.instrucoes[index],
                style: TypographyTokens.body,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Aba "Músculos": grupo primario, secundarios e a imagem do musculo.
class _AbaMusculos extends StatelessWidget {
  const _AbaMusculos({required this.exercicio});

  final Exercicio exercicio;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: SpacingTokens.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Text('Primário', style: TypographyTokens.label),
          const Gap(SpacingTokens.sm),
          AppChip(
            label: exercicio.grupoPrimario.label,
            color: ColorTokens.accent,
          ),
          if (exercicio.gruposSecundarios.isNotEmpty) ...<Widget>[
            const Gap(SpacingTokens.lg),
            const Text('Secundários', style: TypographyTokens.label),
            const Gap(SpacingTokens.sm),
            Wrap(
              spacing: SpacingTokens.sm,
              runSpacing: SpacingTokens.sm,
              children: exercicio.gruposSecundarios
                  .map((GrupoMuscular g) => AppChip(label: g.label))
                  .toList(),
            ),
          ],
          const Gap(SpacingTokens.lg),
          Center(
            child: GrupoMuscularImagem(
              grupo: exercicio.grupoPrimario,
              tamanho: 220,
            ),
          ),
        ],
      ),
    );
  }
}

/// Aba "Histórico": evolucao de carga do exercicio.
class _AbaHistorico extends StatelessWidget {
  const _AbaHistorico({
    required this.nome,
    required this.registros,
    required this.recorde,
    required this.carregando,
  });

  final String nome;
  final List<RegistroCarga> registros;
  final RegistroCarga? recorde;
  final bool carregando;

  @override
  Widget build(BuildContext context) {
    if (carregando) {
      return const Center(
        child: CircularProgressIndicator(color: ColorTokens.accent),
      );
    }
    if (registros.isEmpty) {
      return const EmptyState(
        icon: Icons.show_chart_rounded,
        title: 'Sem histórico ainda',
        message:
            'Registre uma carga neste exercício para ver a evolução aqui.',
      );
    }

    final FormatServiceInterface format = Get.find();
    final List<ChartPoint> pontos = registros
        .map(
          (RegistroCarga r) =>
              ChartPoint(label: format.dataCurta(r.data), value: r.carga),
        )
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: SpacingTokens.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AppLineChart(points: pontos, formatarValor: format.cargaKg),
          const Gap(SpacingTokens.sm),
          if (recorde != null)
            Text(
              'Melhor carga ${format.cargaKg(recorde!.carga)} — '
              '${format.data(recorde!.data)}',
              style: TypographyTokens.bodyMuted,
              textAlign: TextAlign.center,
            ),
          const Gap(SpacingTokens.lg),
          AppButton(
            label: 'Ver evolução completa',
            variant: AppButtonVariant.outline,
            onPressed: () => showEvolucaoCargaModal(
              exercicioNome: nome,
              registros: registros,
            ),
          ),
        ],
      ),
    );
  }
}
