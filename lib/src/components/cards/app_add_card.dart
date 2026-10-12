import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/theme/tokens/color_tokens.dart';
import '../../core/theme/tokens/spacing_tokens.dart';
import '../../core/theme/tokens/typography_tokens.dart';

/// Cartao de borda tracejada verde com um `+`: o convite para acrescentar mais
/// um item a uma lista (ex.: *Adicionar exercício*).
class AppAddCard extends StatelessWidget {
  const AppAddCard({
    required this.label,
    required this.onTap,
    super.key,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: CustomPaint(
        painter: const _BordaTracejada(
          cor: ColorTokens.accent,
          raio: SpacingTokens.radiusCard,
        ),
        child: Material(
          color: ColorTokens.accentSoft,
          borderRadius: BorderRadius.circular(SpacingTokens.radiusCard),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(SpacingTokens.radiusCard),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: SpacingTokens.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: ColorTokens.accent, width: 1.6),
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      size: 18,
                      color: ColorTokens.accent,
                    ),
                  ),
                  const SizedBox(width: SpacingTokens.sm + 4),
                  Text(
                    label,
                    style: TypographyTokens.bodyStrong.copyWith(
                      color: ColorTokens.accent,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BordaTracejada extends CustomPainter {
  const _BordaTracejada({required this.cor, required this.raio});

  final Color cor;
  final double raio;

  static const double _traco = 7;
  static const double _vao = 5;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint pincel = Paint()
      ..color = cor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final Path contorno = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(raio)),
      );
    for (final ui.PathMetric trecho in contorno.computeMetrics()) {
      double inicio = 0;
      while (inicio < trecho.length) {
        final double fim = math.min(inicio + _traco, trecho.length);
        canvas.drawPath(trecho.extractPath(inicio, fim), pincel);
        inicio += _traco + _vao;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BordaTracejada antigo) =>
      antigo.cor != cor || antigo.raio != raio;
}
