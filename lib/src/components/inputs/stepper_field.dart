import 'package:flutter/material.dart';

import '../../core/theme/tokens/color_tokens.dart';
import '../../core/theme/tokens/spacing_tokens.dart';
import '../../core/theme/tokens/typography_tokens.dart';

/// Linha label + controle `[-] valor [+]`, usada para series, repeticoes,
/// carga e descanso. Com [icon], o rotulo vem precedido do icone e em destaque
/// (como na tela de configurar exercicio).
class StepperField extends StatelessWidget {
  const StepperField({
    required this.label,
    required this.value,
    required this.onChanged,
    super.key,
    this.step = 1,
    this.min = 0,
    this.max = 999,
    this.suffix,
    this.dense = false,
    this.icon,
  });

  final String label;
  final num value;
  final void Function(num) onChanged;
  final num step;
  final num min;
  final num max;
  final String? suffix;
  final bool dense;
  final IconData? icon;

  String get _valorFormatado {
    final bool isInteiro = value == value.roundToDouble();
    if (isInteiro) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(1).replaceAll('.', ',');
  }

  void _decrementar() {
    final num proximo = value - step;
    onChanged(proximo < min ? min : proximo);
  }

  void _incrementar() {
    final num proximo = value + step;
    onChanged(proximo > max ? max : proximo);
  }

  @override
  Widget build(BuildContext context) {
    final double botao = dense ? 28 : 32;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        if (icon != null) ...<Widget>[
          Icon(icon, size: 20, color: ColorTokens.textSecondary),
          const SizedBox(width: SpacingTokens.sm + 4),
        ],
        Expanded(
          child: Text(
            label,
            style: icon == null ? TypographyTokens.label : TypographyTokens.body,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _StepperButton(
              icon: Icons.remove_rounded,
              size: botao,
              enabled: value > min,
              onTap: _decrementar,
            ),
            SizedBox(
              width: 56,
              child: Text(
                suffix == null ? _valorFormatado : '$_valorFormatado $suffix',
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TypographyTokens.bodyStrong,
              ),
            ),
            _StepperButton(
              icon: Icons.add_rounded,
              size: botao,
              enabled: value < max,
              onTap: _incrementar,
            ),
          ],
        ),
      ],
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    required this.size,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final double size;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ColorTokens.bgSurfaceAlt,
      borderRadius: BorderRadius.circular(SpacingTokens.radiusXs),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(SpacingTokens.radiusXs),
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(
            icon,
            size: 16,
            color: enabled ? ColorTokens.textPrimary : ColorTokens.textDisabled,
          ),
        ),
      ),
    );
  }
}
