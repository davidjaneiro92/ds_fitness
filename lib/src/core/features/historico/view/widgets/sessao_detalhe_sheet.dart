import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../components/cards/stat_box.dart';
import '../../../../../components/common/gap.dart';
import '../../../../../core/abstracts/format_service_interface.dart';
import '../../../../../core/theme/tokens/color_tokens.dart';
import '../../../../../core/theme/tokens/spacing_tokens.dart';
import '../../../../../core/theme/tokens/typography_tokens.dart';
import '../../../../../models/serie_executada.dart';
import '../../../../../models/sessao.dart';
import '../../abstracts/historico_controller_interface.dart';

/// Conteudo do modal de detalhe de uma sessao (tela 16 — Historico):
/// resumo em `StatBox`s e series executadas agrupadas por exercicio.
class SessaoDetalheSheet extends StatelessWidget {
  const SessaoDetalheSheet({required this.sessao, super.key});

  final Sessao sessao;

  @override
  Widget build(BuildContext context) {
    final HistoricoControllerInterface controller = Get.find();
    final FormatServiceInterface format = Get.find();

    final Map<String, List<SerieExecutada>> porExercicio =
        <String, List<SerieExecutada>>{};
    for (final SerieExecutada serie in sessao.series) {
      porExercicio
          .putIfAbsent(serie.exercicioId, () => <SerieExecutada>[])
          .add(serie);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: StatBox(
                value: format.duracao(sessao.duracaoSeg),
                label: 'Duração',
              ),
            ),
            const Gap.horizontal(SpacingTokens.sm),
            Expanded(
              child: StatBox(
                value: format.volume(sessao.volumeTotal),
                label: 'Volume',
              ),
            ),
          ],
        ),
        const Gap(SpacingTokens.sm),
        Row(
          children: <Widget>[
            Expanded(
              child: StatBox(
                value: format.numero(sessao.calorias),
                label: 'Calorias',
              ),
            ),
            const Gap.horizontal(SpacingTokens.sm),
            Expanded(
              child: StatBox(
                value: format.numero(sessao.totalSeries),
                label: 'Séries',
              ),
            ),
          ],
        ),
        const Gap(SpacingTokens.lg),
        for (final MapEntry<String, List<SerieExecutada>> entry
            in porExercicio.entries) ...<Widget>[
          Text(
            controller.nomeExercicio(entry.key),
            style: TypographyTokens.bodyStrong,
          ),
          const Gap(SpacingTokens.sm),
          for (final SerieExecutada serie in entry.value)
            _SerieLinha(serie: serie, format: format),
          const Gap(SpacingTokens.md),
        ],
      ],
    );
  }
}

/// Linha de uma serie executada: check, "Série N · reps · carga",
/// dificuldade (estrelas) e observacao quando existirem.
class _SerieLinha extends StatelessWidget {
  const _SerieLinha({required this.serie, required this.format});

  final SerieExecutada serie;
  final FormatServiceInterface format;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SpacingTokens.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                serie.concluida
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                size: 16,
                color: serie.concluida
                    ? ColorTokens.accent
                    : ColorTokens.textDisabled,
              ),
              const Gap.horizontal(SpacingTokens.sm),
              Expanded(
                child: Text(
                  'Série ${serie.numeroSerie} · ${serie.repeticoes} reps · '
                  '${format.cargaKg(serie.carga)}',
                  style: TypographyTokens.body,
                ),
              ),
            ],
          ),
          if (serie.dificuldade > 0) ...<Widget>[
            const Gap(SpacingTokens.xs),
            Padding(
              padding: const EdgeInsets.only(left: SpacingTokens.lg),
              child: Row(
                children: List<Widget>.generate(5, (int i) {
                  return Icon(
                    Icons.star_rounded,
                    size: 14,
                    color: i < serie.dificuldade
                        ? ColorTokens.warning
                        : ColorTokens.divider,
                  );
                }),
              ),
            ),
          ],
          if (serie.observacao.isNotEmpty) ...<Widget>[
            const Gap(SpacingTokens.xs),
            Padding(
              padding: const EdgeInsets.only(left: SpacingTokens.lg),
              child: Text(
                serie.observacao,
                style: TypographyTokens.bodyMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
