import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/abstracts/format_service_interface.dart';
import '../../core/theme/tokens/color_tokens.dart';
import '../../core/theme/tokens/spacing_tokens.dart';
import '../../core/theme/tokens/typography_tokens.dart';
import '../buttons/app_button.dart';
import '../inputs/app_dropdown_field.dart';
import '../inputs/stepper_field.dart';
import 'app_modal_sheet.dart';

/// Abre o modal "Alterar Carga" (tela 23). Retorna a nova carga escolhida
/// ou `null` se o usuario fechar sem salvar.
Future<double?> showAlterarCargaModal({
  required double cargaAtual,
  double? sugestao,
}) {
  return showAppModalSheet<double>(
    title: 'Alterar Carga',
    child: _AlterarCargaContent(cargaAtual: cargaAtual, sugestao: sugestao),
  );
}

class _AlterarCargaContent extends StatefulWidget {
  const _AlterarCargaContent({required this.cargaAtual, this.sugestao});

  final double cargaAtual;
  final double? sugestao;

  @override
  State<_AlterarCargaContent> createState() => _AlterarCargaContentState();
}

class _AlterarCargaContentState extends State<_AlterarCargaContent> {
  static const List<double> _incrementos = <double>[0.5, 1, 2.5, 5];

  late double _novaCarga;
  late double _incremento;

  @override
  void initState() {
    super.initState();
    _novaCarga = widget.cargaAtual;
    _incremento = 2.5;
  }

  @override
  Widget build(BuildContext context) {
    final FormatServiceInterface format = Get.find();
    final double? diferenca = widget.sugestao == null ? null : widget.sugestao! - widget.cargaAtual;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const Text('Carga atual', style: TypographyTokens.label),
        const SizedBox(height: SpacingTokens.xs),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: <Widget>[
            Text(
              format.carga(widget.cargaAtual),
              style: TypographyTokens.display.copyWith(color: ColorTokens.accent),
            ),
            const SizedBox(width: SpacingTokens.xs),
            Text(
              'kg',
              style: TypographyTokens.bodyStrong.copyWith(color: ColorTokens.accent),
            ),
          ],
        ),
        const SizedBox(height: SpacingTokens.lg),
        StepperField(
          label: 'Nova carga (kg)',
          value: _novaCarga,
          step: _incremento,
          onChanged: (num valor) => setState(() => _novaCarga = valor.toDouble()),
        ),
        const SizedBox(height: SpacingTokens.md),
        AppDropdownField<double>(
          label: 'Incremento',
          value: _incremento,
          items: _incrementos,
          itemLabel: format.cargaKg,
          onChanged: (double? valor) {
            if (valor != null) {
              setState(() => _incremento = valor);
            }
          },
        ),
        if (widget.sugestao != null && diferenca != null) ...<Widget>[
          const SizedBox(height: SpacingTokens.md),
          Container(
            padding: const EdgeInsets.all(SpacingTokens.sm),
            decoration: BoxDecoration(
              color: ColorTokens.accentSoft,
              borderRadius: BorderRadius.circular(SpacingTokens.radiusSm),
            ),
            child: Text(
              'Sugestão: ${format.cargaKg(widget.sugestao!)} '
              '(${diferenca >= 0 ? '+' : ''}${format.cargaKg(diferenca)})',
              style: TypographyTokens.bodyMuted.copyWith(color: ColorTokens.accent),
            ),
          ),
        ],
        const SizedBox(height: SpacingTokens.lg),
        AppButton(
          label: 'Salvar',
          onPressed: () => Get.back<double>(result: _novaCarga),
        ),
      ],
    );
  }
}
