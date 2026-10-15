import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../components/cards/app_card.dart';
import '../../../../components/common/page_header.dart';
import '../../../../components/empty_states/empty_state.dart';
import '../../../../components/media/exercise_illustration.dart';
import '../../../../components/navbars/app_navbar.dart';
import '../../../../components/scaffolds/app_scaffold.dart';
import '../../../../core/theme/tokens/color_tokens.dart';
import '../../../../core/theme/tokens/spacing_tokens.dart';
import '../../../../core/theme/tokens/typography_tokens.dart';
import '../../../../enum/pages_routes.dart';
import '../../../../models/treino.dart';
import '../../../../models/treino_exercicio.dart';
import '../../../../routes/route_args.dart';

/// Lista somente leitura de exercícios para escolher o ponto inicial do treino.
class TreinoExecucaoListaView extends StatelessWidget {
  const TreinoExecucaoListaView({super.key});

  @override
  Widget build(BuildContext context) {
    final dynamic routeArgs = Get.arguments;
    if (routeArgs is! TreinoExecucaoListaArgs) {
      return const AppScaffold(
        body: Center(child: Text('Não foi possível abrir este treino.')),
      );
    }
    final Treino treino = routeArgs.treino;

    return AppScaffold(
      navbar: AppNavbar(title: treino.titulo, subtitle: treino.gruposLabel),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: SpacingTokens.md),
          PageHeader(
            title: treino.exerciciosLabel,
            subtitle: 'Toque em um exercício para começar.',
          ),
          const SizedBox(height: SpacingTokens.sm),
          Expanded(
            child: treino.exercicios.isEmpty
                ? const EmptyState(
                    icon: Icons.fitness_center_rounded,
                    title: 'Treino sem exercícios',
                    message:
                        'Edite o treino e adicione os exercícios primeiro.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.only(bottom: SpacingTokens.md),
                    itemCount: treino.exercicios.length,
                    separatorBuilder: (BuildContext context, int index) =>
                        const SizedBox(height: SpacingTokens.sm),
                    itemBuilder: (BuildContext context, int index) {
                      final TreinoExercicio item = treino.exercicios[index];
                      return _ExercicioParaExecutarCard(
                        item: item,
                        ordem: index + 1,
                        onTap: () => Get.toNamed<void>(
                          PagesRoutes.execucao.path,
                          arguments: ExecucaoArgs(
                            treinoId: treino.id,
                            indiceExercicio: index,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ExercicioParaExecutarCard extends StatelessWidget {
  const _ExercicioParaExecutarCard({
    required this.item,
    required this.ordem,
    required this.onTap,
  });

  final TreinoExercicio item;
  final int ordem;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(SpacingTokens.sm + 4),
      child: Row(
        children: <Widget>[
          ExerciseIllustration(
            imagem: item.exercicio.imagem,
            grupo: item.exercicio.grupoPrimario,
            compact: true,
            tamanho: 64,
          ),
          const SizedBox(width: SpacingTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  item.exercicio.nome,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TypographyTokens.bodyStrong,
                ),
                const SizedBox(height: SpacingTokens.xxs),
                Text(item.exercicio.gruposLabel, style: TypographyTokens.label),
                const SizedBox(height: SpacingTokens.xs),
                Text(
                  '${item.series} séries • ${item.repeticoes} reps',
                  style: TypographyTokens.caption,
                ),
                const SizedBox(height: SpacingTokens.xxs),
                Text(
                  '${item.descansoSeg} s de descanso',
                  style: TypographyTokens.caption,
                ),
              ],
            ),
          ),
          const SizedBox(width: SpacingTokens.sm),
          Column(
            children: <Widget>[
              Text(
                ordem.toString().padLeft(2, '0'),
                style: TypographyTokens.label.copyWith(
                  color: ColorTokens.accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: SpacingTokens.xs),
              const Icon(
                Icons.chevron_right_rounded,
                color: ColorTokens.textSecondary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
