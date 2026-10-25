import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../components/buttons/app_button.dart';
import '../../../../components/cards/app_card.dart';
import '../../../../components/common/gap.dart';
import '../../../../components/empty_states/empty_state.dart';
import '../../../../components/inputs/app_search_field.dart';
import '../../../../components/media/asset_first_frame.dart';
import '../../../../components/navbars/app_navbar.dart';
import '../../../../components/scaffolds/app_scaffold.dart';
import '../../../../constants/app_assets.dart';
import '../../../../core/theme/tokens/color_tokens.dart';
import '../../../../core/theme/tokens/spacing_tokens.dart';
import '../../../../core/theme/tokens/typography_tokens.dart';
import '../../../../models/exercicio.dart';
import '../../../../routes/route_args.dart';
import '../abstracts/treino_ia_controller_interface.dart';

/// Busca um único exercício do catálogo para acrescentar à sessão escolhida.
class TreinoIaSelecionarExercicioView extends StatefulWidget {
  const TreinoIaSelecionarExercicioView({super.key});

  @override
  State<TreinoIaSelecionarExercicioView> createState() =>
      _TreinoIaSelecionarExercicioViewState();
}

class _TreinoIaSelecionarExercicioViewState
    extends State<TreinoIaSelecionarExercicioView> {
  final TreinoIaControllerInterface _controller = Get.find();
  late final int _indiceTreino;
  Exercicio? _selecionado;
  String _busca = '';

  @override
  void initState() {
    super.initState();
    _indiceTreino =
        (Get.arguments as TreinoIaAdicionarExercicioArgs).indiceTreino;
    unawaited(_controller.carregarCatalogo());
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      navbar: const AppNavbar(title: 'Adicionar exercício'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.only(
              top: SpacingTokens.sm,
              bottom: SpacingTokens.md,
            ),
            child: Text(
              'Pesquise e selecione um exercício para este treino.',
              style: TypographyTokens.bodyMuted,
            ),
          ),
          AppSearchField(onChanged: (String valor) {
            setState(() => _busca = valor);
          }),
          const Gap(SpacingTokens.md),
          Expanded(
            child: Obx(() {
              if (_controller.carregandoCatalogo.value) {
                return const Center(
                  child: CircularProgressIndicator(color: ColorTokens.accent),
                );
              }
              final List<Exercicio> exercicios =
                  _controller.exerciciosParaTreino(_indiceTreino, _busca);
              if (exercicios.isEmpty) {
                return const EmptyState(
                  icon: Icons.search_off_rounded,
                  title: 'Nenhum exercício encontrado',
                  message:
                      'Tente outra busca ou revise os grupos deste treino.',
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.only(bottom: SpacingTokens.md),
                itemCount: exercicios.length,
                separatorBuilder: (BuildContext context, int index) =>
                    const SizedBox(height: SpacingTokens.sm),
                itemBuilder: (BuildContext context, int index) {
                  final Exercicio exercicio = exercicios[index];
                  final bool selecionado = _selecionado?.id == exercicio.id;
                  return AppCard(
                    onTap: () => setState(() => _selecionado = exercicio),
                    highlighted: selecionado,
                    background: selecionado ? const Color(0xFF15231A) : null,
                    padding: const EdgeInsets.all(SpacingTokens.sm),
                    child: Row(
                      children: <Widget>[
                        _Miniatura(exercicio: exercicio),
                        const SizedBox(width: SpacingTokens.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                exercicio.nome,
                                style: TypographyTokens.cardTitle,
                              ),
                              const SizedBox(height: SpacingTokens.xxs),
                              Text(
                                exercicio.gruposLabel,
                                style: TypographyTokens.bodyMuted,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (exercicio.equipamento.isNotEmpty) ...<Widget>[
                                const SizedBox(height: SpacingTokens.xxs),
                                Text(
                                  exercicio.equipamento,
                                  style: TypographyTokens.caption,
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: SpacingTokens.sm),
                        Icon(
                          selecionado
                              ? Icons.check_circle_rounded
                              : Icons.add_circle_outline_rounded,
                          color: selecionado
                              ? ColorTokens.accent
                              : ColorTokens.textSecondary,
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
      footer: AppButton(
        label: 'Adicionar exercício',
        icon: Icons.add_rounded,
        onPressed: _selecionado == null
            ? null
            : () => Get.back<Exercicio>(result: _selecionado),
      ),
    );
  }
}

class _Miniatura extends StatelessWidget {
  const _Miniatura({required this.exercicio});

  final Exercicio exercicio;

  @override
  Widget build(BuildContext context) {
    final String asset = exercicio.imagem.isEmpty
        ? ''
        : AppAssets.miniaturaDoExercicio(exercicio.imagem);
    return ClipRRect(
      borderRadius: BorderRadius.circular(SpacingTokens.radiusXs),
      child: SizedBox(
        width: 60,
        height: 60,
        child: asset.isEmpty
            ? const _ExerciseFallback()
            : AssetFirstFrame(
                asset: asset,
                largura: 128,
                fallback: const _ExerciseFallback(),
              ),
      ),
    );
  }
}

class _ExerciseFallback extends StatelessWidget {
  const _ExerciseFallback();

  @override
  Widget build(BuildContext context) => const ColoredBox(
        color: ColorTokens.bgSurfaceAlt,
        child: Icon(Icons.fitness_center_rounded, color: ColorTokens.accent),
      );
}
