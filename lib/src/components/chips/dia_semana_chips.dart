import 'package:flutter/material.dart';

import '../../core/theme/tokens/color_tokens.dart';
import '../../core/theme/tokens/spacing_tokens.dart';
import '../../enum/dia_semana.dart';

/// Escolha do dia da semana: sete botoes em uma linha (Seg ... Dom), um
/// selecionado por vez. [selecionado] `null` deixa todos apagados — o treino
/// ainda nao tem dia.
class DiaSemanaChips extends StatelessWidget {
  const DiaSemanaChips({
    required this.selecionado,
    required this.onSelecionar,
    super.key,
  });

  final DiaSemana? selecionado;
  final void Function(DiaSemana dia) onSelecionar;

  static const double _espaco = 6;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        for (int i = 0; i < DiaSemana.values.length; i++) ...<Widget>[
          if (i > 0) const SizedBox(width: _espaco),
          Expanded(
            child: _DiaChip(
              dia: DiaSemana.values[i],
              selecionado: DiaSemana.values[i] == selecionado,
              onTap: () => onSelecionar(DiaSemana.values[i]),
            ),
          ),
        ],
      ],
    );
  }
}

class _DiaChip extends StatelessWidget {
  const _DiaChip({
    required this.dia,
    required this.selecionado,
    required this.onTap,
  });

  final DiaSemana dia;
  final bool selecionado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selecionado,
      label: dia.nome,
      // O leitor de tela le "Quarta", e nao tambem a abreviacao do botao.
      excludeSemantics: true,
      child: Material(
        color: selecionado ? ColorTokens.accent : ColorTokens.bgSurfaceAlt,
        borderRadius: BorderRadius.circular(SpacingTokens.radiusSm),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(SpacingTokens.radiusSm),
          child: SizedBox(
            height: SpacingTokens.buttonHeightSm,
            child: Center(
              child: FittedBox(
                child: Text(
                  dia.abreviacao,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: selecionado ? FontWeight.w800 : FontWeight.w600,
                    color: selecionado
                        ? ColorTokens.textOnAccent
                        : ColorTokens.textPrimary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
