import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/tokens/color_tokens.dart';
import '../../core/theme/tokens/typography_tokens.dart';

/// Anel de progresso circular usado na tela de descanso: trilho cinza, arco
/// verde representando `restanteSeg/totalSeg` e o tempo em `mm:ss` no
/// centro. Anima suavemente entre valores com [TweenAnimationBuilder].
class CircularTimer extends StatelessWidget {
  const CircularTimer({
    required this.totalSeg,
    required this.restanteSeg,
    super.key,
    this.size = 220,
    this.legenda,
  });

  final int totalSeg;
  final int restanteSeg;
  final double size;
  final String? legenda;

  double get _progresso {
    if (totalSeg <= 0) {
      return 0;
    }
    return (restanteSeg / totalSeg).clamp(0.0, 1.0);
  }

  String get _tempoFormatado {
    final int segundos = restanteSeg < 0 ? 0 : restanteSeg;
    final int minutos = segundos ~/ 60;
    final int resto = segundos % 60;
    return '${minutos.toString().padLeft(2, '0')}:${resto.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: _progresso),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      builder: (BuildContext context, double valor, Widget? child) {
        return SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _CircularTimerPainter(progresso: valor),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(_tempoFormatado, style: TypographyTokens.display),
                  if (legenda != null) ...<Widget>[
                    const SizedBox(height: 4),
                    Text(legenda!, style: TypographyTokens.label),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CircularTimerPainter extends CustomPainter {
  _CircularTimerPainter({required this.progresso});

  final double progresso;

  static const double _espessura = 10;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset centro = size.center(Offset.zero);
    final double raio = (size.shortestSide - _espessura) / 2;

    final Paint trilhoPaint = Paint()
      ..color = ColorTokens.bgSurfaceAlt
      ..style = PaintingStyle.stroke
      ..strokeWidth = _espessura;
    canvas.drawCircle(centro, raio, trilhoPaint);

    final Paint progressoPaint = Paint()
      ..color = ColorTokens.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = _espessura
      ..strokeCap = StrokeCap.round;

    final double varredura = 2 * math.pi * progresso.clamp(0.0, 1.0);
    if (varredura > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: centro, radius: raio),
        -math.pi / 2,
        varredura,
        false,
        progressoPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CircularTimerPainter oldDelegate) {
    return oldDelegate.progresso != progresso;
  }
}
