import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../components/buttons/app_button.dart';
import '../../../../components/cards/app_card.dart';
import '../../../../components/common/gap.dart';
import '../../../../components/media/asset_first_frame.dart';
import '../../../../components/navbars/app_navbar.dart';
import '../../../../components/scaffolds/app_scaffold.dart';
import '../../../../constants/app_assets.dart';
import '../../../../core/theme/tokens/color_tokens.dart';
import '../../../../core/theme/tokens/spacing_tokens.dart';
import '../../../../core/theme/tokens/typography_tokens.dart';
import '../../../../enum/pages_routes.dart';
import '../../../../models/exercicio.dart';
import '../../../../models/plano_ia.dart';
import '../../../../models/treino.dart';
import '../../../../models/treino_exercicio.dart';
import '../../../../routes/route_args.dart';
import '../abstracts/treino_ia_controller_interface.dart';
import 'widgets/treino_ia_widgets.dart';

/// Prévia revisável, com ações para remover ou acrescentar movimentos por dia.
class TreinoIaPreviaView extends GetView<TreinoIaControllerInterface> {
  const TreinoIaPreviaView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      navbar: const AppNavbar(title: 'Prévia do plano'),
      body: Obx(() {
        final List<Treino> treinos = controller.treinos.toList();
        if (treinos.isEmpty) {
          return const Center(
            child: Text('Não há exercícios para exibir.'),
          );
        }
        return ListView(
          padding: const EdgeInsets.only(top: SpacingTokens.sm),
          children: <Widget>[
            const TreinoIaStepTitle(
              etapa: 'Revise antes de salvar',
              titulo: 'Seu plano está pronto',
              descricao:
                  'Você pode remover exercícios ou incluir outros em cada treino.',
            ),
            if (controller.avaliacao.value
                case final AvaliacaoCorporal avaliacao)
              Padding(
                padding: const EdgeInsets.only(bottom: SpacingTokens.md),
                child: _AvaliacaoCard(avaliacao: avaliacao),
              ),
            ...treinos.asMap().entries.map(
                  (MapEntry<int, Treino> entrada) => Padding(
                    padding: const EdgeInsets.only(bottom: SpacingTokens.md),
                    child: _SessaoPreviewCard(
                      treino: entrada.value,
                      onAdicionar: () => _adicionar(entrada.key),
                      onRemover: (int indiceExercicio) => controller
                          .removerExercicio(entrada.key, indiceExercicio),
                    ),
                  ),
                ),
            const Gap(SpacingTokens.md),
          ],
        );
      }),
      footer: Obx(
        () => TreinoIaStepFooter(
          label: 'Salvar plano e começar',
          loading: controller.salvando.value,
          onPressed: controller.salvando.value
              ? null
              : () => unawaited(controller.salvarPlano()),
        ),
      ),
    );
  }

  Future<void> _adicionar(int indiceTreino) async {
    final Exercicio? selecionado = await Get.toNamed<Exercicio>(
      PagesRoutes.treinoIaAdicionarExercicio.path,
      arguments: TreinoIaAdicionarExercicioArgs(indiceTreino: indiceTreino),
    );
    if (selecionado != null) {
      controller.adicionarExercicio(indiceTreino, selecionado);
    }
  }
}

class _SessaoPreviewCard extends StatelessWidget {
  const _SessaoPreviewCard({
    required this.treino,
    required this.onAdicionar,
    required this.onRemover,
  });

  final Treino treino;
  final VoidCallback onAdicionar;
  final ValueChanged<int> onRemover;

  @override
  Widget build(BuildContext context) {
    final String dia = treino.dia?.nome ?? 'Dia sem definição';
    return AppCard(
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(treino.nome, style: TypographyTokens.cardTitle),
                    const SizedBox(height: SpacingTokens.xxs),
                    Text(
                      '$dia • ${treino.exercicios.length} '
                      '${treino.exercicios.length == 1 ? 'exercício' : 'exercícios'}',
                      style: TypographyTokens.bodyMuted,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.auto_awesome_rounded, color: ColorTokens.accent),
            ],
          ),
          const Gap(SpacingTokens.sm),
          if (treino.exercicios.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: SpacingTokens.sm),
              child: Text(
                'Adicione pelo menos um exercício para este treino.',
                style: TypographyTokens.bodyMuted,
              ),
            )
          else
            ...treino.exercicios.asMap().entries.map(
                  (MapEntry<int, TreinoExercicio> entrada) => Padding(
                    padding: const EdgeInsets.only(bottom: SpacingTokens.xs),
                    child: _ExercicioPreviewRow(
                      item: entrada.value,
                      onRemover: () => onRemover(entrada.key),
                    ),
                  ),
                ),
          const Gap(SpacingTokens.xs),
          AppButton(
            label: 'Adicionar exercício',
            icon: Icons.add_rounded,
            variant: AppButtonVariant.outline,
            size: AppButtonSize.small,
            onPressed: onAdicionar,
          ),
        ],
      ),
    );
  }
}

class _ExercicioPreviewRow extends StatelessWidget {
  const _ExercicioPreviewRow({required this.item, required this.onRemover});

  final TreinoExercicio item;
  final VoidCallback onRemover;

  @override
  Widget build(BuildContext context) {
    final String asset = item.exercicio.imagem.isEmpty
        ? ''
        : AppAssets.miniaturaDoExercicio(item.exercicio.imagem);
    return Container(
      padding: const EdgeInsets.all(SpacingTokens.xs),
      decoration: BoxDecoration(
        color: ColorTokens.bgSurfaceAlt,
        borderRadius: BorderRadius.circular(SpacingTokens.radiusButton),
      ),
      child: Row(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(SpacingTokens.radiusXs),
            child: SizedBox(
              width: 54,
              height: 54,
              child: asset.isEmpty
                  ? const _ExerciseFallback()
                  : AssetFirstFrame(
                      asset: asset,
                      largura: 128,
                      fallback: const _ExerciseFallback(),
                    ),
            ),
          ),
          const SizedBox(width: SpacingTokens.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  item.exercicio.nome,
                  style: TypographyTokens.cardTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: SpacingTokens.xxs),
                Text(
                  item.exercicio.grupoPrimario.label,
                  style: TypographyTokens.caption,
                ),
                const SizedBox(height: SpacingTokens.xxs),
                Text(
                  '${item.series} séries • ${item.repeticoes} reps • '
                  '${item.descansoSeg} s descanso',
                  style: TypographyTokens.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Remover exercício',
            onPressed: onRemover,
            icon: const Icon(Icons.remove_circle_outline_rounded),
            color: ColorTokens.textSecondary,
          ),
        ],
      ),
    );
  }
}

class _ExerciseFallback extends StatelessWidget {
  const _ExerciseFallback();

  @override
  Widget build(BuildContext context) => const ColoredBox(
        color: ColorTokens.bgSurface,
        child: Icon(Icons.fitness_center_rounded, color: ColorTokens.accent),
      );
}

/// Como o IMC do usuário mudou o plano, em linguagem simples.
class _AvaliacaoCard extends StatelessWidget {
  const _AvaliacaoCard({required this.avaliacao});

  final AvaliacaoCorporal avaliacao;

  @override
  Widget build(BuildContext context) {
    final double? imc = avaliacao.imc;
    return AppCard(
      background: ColorTokens.bgAccentSurface,
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(
                Icons.monitor_heart_outlined,
                color: ColorTokens.accent,
                size: 20,
              ),
              const SizedBox(width: SpacingTokens.sm),
              Expanded(
                child: Text(
                  imc == null
                      ? avaliacao.classificacao
                      : 'IMC ${imc.toStringAsFixed(1).replaceAll('.', ',')} · '
                          '${avaliacao.classificacao}',
                  style: TypographyTokens.cardTitle,
                ),
              ),
            ],
          ),
          for (final String ajuste in avaliacao.ajustes) ...<Widget>[
            const SizedBox(height: SpacingTokens.xs),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(
                    Icons.check_rounded,
                    color: ColorTokens.accent,
                    size: 16,
                  ),
                ),
                const SizedBox(width: SpacingTokens.xs),
                Expanded(
                  child: Text(ajuste, style: TypographyTokens.bodyMuted),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
