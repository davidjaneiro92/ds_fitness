import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/abstracts/format_service_interface.dart';
import '../../core/theme/tokens/color_tokens.dart';
import '../../core/theme/tokens/spacing_tokens.dart';
import '../../core/theme/tokens/typography_tokens.dart';
import '../../models/registro_carga.dart';
import '../buttons/app_button.dart';
import '../charts/app_line_chart.dart';
import 'app_modal_sheet.dart';

/// Abre o modal "Evolução de carga" (tela 22): grafico de linha com o
/// historico de cargas do exercicio e o recorde pessoal no rodape.
Future<void> showEvolucaoCargaModal({
  required String exercicioNome,
  required List<RegistroCarga> registros,
}) {
  return showAppModalSheet<void>(
    title: 'Evolução de carga',
    child: _EvolucaoCargaContent(
      exercicioNome: exercicioNome,
      registros: registros,
    ),
  );
}

class _EvolucaoCargaContent extends StatelessWidget {
  const _EvolucaoCargaContent({
    required this.exercicioNome,
    required this.registros,
  });

  final String exercicioNome;
  final List<RegistroCarga> registros;

  @override
  Widget build(BuildContext context) {
    final FormatServiceInterface format = Get.find();
    final List<RegistroCarga> ordenados = List<RegistroCarga>.of(registros)
      ..sort((RegistroCarga a, RegistroCarga b) => a.data.compareTo(b.data));

    RegistroCarga? melhor;
    for (final RegistroCarga registro in ordenados) {
      if (melhor == null || registro.carga > melhor.carga) {
        melhor = registro;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(exercicioNome, style: TypographyTokens.cardTitle),
        const SizedBox(height: SpacingTokens.md),
        if (ordenados.isEmpty)
          const SizedBox(
            height: 160,
            child: Center(
              child: Text(
                'Sem registros de carga ainda.',
                style: TypographyTokens.bodyMuted,
              ),
            ),
          )
        else
          AppLineChart(
            points: <ChartPoint>[
              for (final RegistroCarga registro in ordenados)
                ChartPoint(
                  label: format.dataCurta(registro.data),
                  value: registro.carga,
                ),
            ],
            formatarValor: format.cargaKg,
          ),
        if (melhor != null) ...<Widget>[
          const SizedBox(height: SpacingTokens.md),
          RichText(
            text: TextSpan(
              style: TypographyTokens.bodyMuted,
              children: <InlineSpan>[
                const TextSpan(text: 'Melhor carga '),
                TextSpan(
                  text: format.cargaKg(melhor.carga),
                  style: TypographyTokens.bodyStrong.copyWith(color: ColorTokens.accent),
                ),
                TextSpan(text: ' — ${format.data(melhor.data)}'),
              ],
            ),
          ),
        ],
        const SizedBox(height: SpacingTokens.lg),
        AppButton(
          label: 'Fechar',
          variant: AppButtonVariant.outline,
          onPressed: () => Get.back<void>(),
        ),
      ],
    );
  }
}
