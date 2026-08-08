import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/tokens/color_tokens.dart';
import '../../core/theme/tokens/typography_tokens.dart';

/// Um ponto do [AppLineChart]: um rotulo de eixo X e um valor numerico.
class ChartPoint {
  const ChartPoint({required this.label, required this.value});

  final String label;
  final double value;
}

/// Grafico de linha desenhado com [CustomPainter]: linha verde suavizada,
/// area em gradiente, pontos marcados e rotulos de valor e de eixo X.
class AppLineChart extends StatelessWidget {
  const AppLineChart({
    required this.points,
    super.key,
    this.height = 160,
    this.mostrarRotulos = true,
    this.formatarValor,
  });

  final List<ChartPoint> points;
  final double height;
  final bool mostrarRotulos;
  final String Function(double)? formatarValor;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(
          child: Text('Sem dados', style: TypographyTokens.bodyMuted),
        ),
      );
    }

    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _AppLineChartPainter(
          points: points,
          mostrarRotulos: mostrarRotulos,
          formatarValor: formatarValor ?? (double v) => v.toStringAsFixed(0),
        ),
      ),
    );
  }
}

class _AppLineChartPainter extends CustomPainter {
  _AppLineChartPainter({
    required this.points,
    required this.mostrarRotulos,
    required this.formatarValor,
  });

  final List<ChartPoint> points;
  final bool mostrarRotulos;
  final String Function(double) formatarValor;

  static const double _reservedBottom = 20;

  @override
  void paint(Canvas canvas, Size size) {
    final double reservedTop = mostrarRotulos ? 22 : 4;
    final double plotTop = reservedTop;
    final double plotBottom = size.height - _reservedBottom;
    final double plotHeight = math.max(plotBottom - plotTop, 1);

    final double minV = points.map((ChartPoint p) => p.value).reduce(math.min);
    final double maxV = points.map((ChartPoint p) => p.value).reduce(math.max);
    final bool valoresIguais = maxV == minV;
    final double range = valoresIguais ? 1 : (maxV - minV);

    final double xStep = points.length > 1 ? size.width / (points.length - 1) : 0;

    final List<Offset> offsets = <Offset>[
      for (int i = 0; i < points.length; i++)
        Offset(
          points.length > 1 ? i * xStep : size.width / 2,
          valoresIguais
              ? plotTop + plotHeight / 2
              : plotBottom - ((points[i].value - minV) / range) * plotHeight,
        ),
    ];

    _desenharGrade(canvas, size, plotTop, plotBottom);

    if (offsets.length > 1) {
      final Path linha = _construirLinhaSuavizada(offsets);
      _desenharArea(canvas, size, linha, offsets, plotBottom);

      final Paint linhaPaint = Paint()
        ..color = ColorTokens.accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(linha, linhaPaint);
    }

    final Paint pontoPaint = Paint()..color = ColorTokens.accent;
    final Paint mioloPaint = Paint()..color = ColorTokens.bgPrimary;
    for (final Offset offset in offsets) {
      canvas.drawCircle(offset, 4, pontoPaint);
      canvas.drawCircle(offset, 2, mioloPaint);
    }

    if (mostrarRotulos) {
      for (int i = 0; i < offsets.length; i++) {
        _desenharTexto(
          canvas,
          formatarValor(points[i].value),
          offsets[i].translate(0, -18),
          TypographyTokens.caption.copyWith(color: ColorTokens.textPrimary),
          larguraCanvas: size.width,
        );
      }
    }

    _desenharRotulosEixoX(canvas, size, offsets);
  }

  void _desenharGrade(Canvas canvas, Size size, double plotTop, double plotBottom) {
    final Paint gradePaint = Paint()
      ..color = ColorTokens.divider
      ..strokeWidth = 1;
    final List<double> fracoes = <double>[0, 0.5, 1];
    for (final double fracao in fracoes) {
      final double y = plotTop + (plotBottom - plotTop) * fracao;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gradePaint);
    }
  }

  Path _construirLinhaSuavizada(List<Offset> offsets) {
    final Path caminho = Path()..moveTo(offsets.first.dx, offsets.first.dy);
    if (offsets.length == 2) {
      caminho.lineTo(offsets[1].dx, offsets[1].dy);
      return caminho;
    }
    for (int i = 0; i < offsets.length - 1; i++) {
      final Offset atual = offsets[i];
      final Offset proximo = offsets[i + 1];
      final Offset meio = Offset(
        (atual.dx + proximo.dx) / 2,
        (atual.dy + proximo.dy) / 2,
      );
      if (i == 0) {
        caminho.lineTo(meio.dx, meio.dy);
      } else {
        caminho.quadraticBezierTo(atual.dx, atual.dy, meio.dx, meio.dy);
      }
    }
    caminho.quadraticBezierTo(
      offsets[offsets.length - 2].dx,
      offsets[offsets.length - 2].dy,
      offsets.last.dx,
      offsets.last.dy,
    );
    return caminho;
  }

  void _desenharArea(
    Canvas canvas,
    Size size,
    Path linha,
    List<Offset> offsets,
    double plotBottom,
  ) {
    final Path area = Path.from(linha)
      ..lineTo(offsets.last.dx, plotBottom)
      ..lineTo(offsets.first.dx, plotBottom)
      ..close();

    final Paint areaPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          ColorTokens.accent.withOpacity(0.28),
          ColorTokens.accent.withOpacity(0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(area, areaPaint);
  }

  void _desenharRotulosEixoX(Canvas canvas, Size size, List<Offset> offsets) {
    final List<int> indices = points.length <= 6
        ? List<int>.generate(points.length, (int i) => i)
        : List<int>.generate(6, (int i) => (i * (points.length - 1) / 5).round());

    for (final int indice in indices) {
      _desenharTexto(
        canvas,
        points[indice].label,
        Offset(offsets[indice].dx, size.height - _reservedBottom + 4),
        TypographyTokens.caption,
        larguraCanvas: size.width,
      );
    }
  }

  void _desenharTexto(
    Canvas canvas,
    String texto,
    Offset posicao,
    TextStyle estilo, {
    required double larguraCanvas,
    bool centralizarHorizontal = true,
  }) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: texto, style: estilo),
      textDirection: TextDirection.ltr,
    )..layout();
    final double dx =
        centralizarHorizontal ? posicao.dx - textPainter.width / 2 : posicao.dx;
    // Mantem o rotulo dentro da area do grafico: nas pontas ele seria
    // cortado pela borda do card.
    final double limite = math.max(larguraCanvas - textPainter.width, 0);
    final double dxLimitado = dx.clamp(0.0, limite);
    textPainter.paint(canvas, Offset(dxLimitado, posicao.dy));
  }

  @override
  bool shouldRepaint(covariant _AppLineChartPainter oldDelegate) {
    if (oldDelegate.mostrarRotulos != mostrarRotulos) {
      return true;
    }
    if (oldDelegate.points.length != points.length) {
      return true;
    }
    for (int i = 0; i < points.length; i++) {
      if (oldDelegate.points[i].value != points[i].value ||
          oldDelegate.points[i].label != points[i].label) {
        return true;
      }
    }
    return false;
  }
}
