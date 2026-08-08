import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/tokens/color_tokens.dart';
import '../../enum/grupo_muscular.dart';

/// Icone anatomico linear (stroke) para o grid de grupos musculares
/// (tela 7). Cada grupo tem um pictograma distinto, desenhado com
/// [CustomPainter] num viewport logico de 40x40.
class GrupoMuscularIcon extends StatelessWidget {
  const GrupoMuscularIcon({
    required this.grupo,
    super.key,
    this.size = 40,
    this.color,
  });

  final GrupoMuscular grupo;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GrupoMuscularIconPainter(
          grupo: grupo,
          cor: color ?? ColorTokens.accent,
        ),
      ),
    );
  }
}

class _GrupoMuscularIconPainter extends CustomPainter {
  _GrupoMuscularIconPainter({required this.grupo, required this.cor});

  final GrupoMuscular grupo;
  final Color cor;

  static const double _viewport = 40;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / _viewport, size.height / _viewport);

    final Paint traco = Paint()
      ..color = cor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    switch (grupo) {
      case GrupoMuscular.peito:
        _desenharPeito(canvas, traco);
      case GrupoMuscular.costas:
        _desenharCostas(canvas, traco);
      case GrupoMuscular.ombro:
        _desenharOmbro(canvas, traco);
      case GrupoMuscular.biceps:
        _desenharBiceps(canvas, traco);
      case GrupoMuscular.triceps:
        _desenharTriceps(canvas, traco);
      case GrupoMuscular.antebraco:
        _desenharAntebraco(canvas, traco);
      case GrupoMuscular.pernas:
        _desenharPernas(canvas, traco);
      case GrupoMuscular.abdomen:
        _desenharAbdomen(canvas, traco);
      case GrupoMuscular.gluteos:
        _desenharGluteos(canvas, traco);
      case GrupoMuscular.panturrilha:
        _desenharPanturrilha(canvas, traco);
      case GrupoMuscular.cardio:
        _desenharCardio(canvas, traco);
      case GrupoMuscular.todos:
        _desenharTodos(canvas, traco);
    }

    canvas.restore();
  }

  void _desenharPeito(Canvas canvas, Paint p) {
    final Path esquerdo = Path()
      ..moveTo(8, 14)
      ..quadraticBezierTo(14, 23, 19, 15);
    final Path direito = Path()
      ..moveTo(21, 15)
      ..quadraticBezierTo(26, 23, 32, 14);
    canvas.drawPath(esquerdo, p);
    canvas.drawPath(direito, p);
    canvas.drawLine(const Offset(20, 10), const Offset(20, 25), p);
  }

  void _desenharCostas(Canvas canvas, Paint p) {
    final Path contorno = Path()
      ..moveTo(9, 9)
      ..lineTo(31, 9)
      ..lineTo(24, 31)
      ..lineTo(16, 31)
      ..close();
    canvas.drawPath(contorno, p);
    canvas.drawLine(const Offset(20, 9), const Offset(20, 31), p);
  }

  void _desenharOmbro(Canvas canvas, Paint p) {
    final Rect arco = Rect.fromCircle(center: const Offset(20, 16), radius: 11);
    canvas.drawArc(arco, math.pi, math.pi, false, p);
    canvas.drawLine(const Offset(13, 16), const Offset(11, 31), p);
    canvas.drawLine(const Offset(27, 16), const Offset(29, 31), p);
  }

  void _desenharBiceps(Canvas canvas, Paint p) {
    final Path braco = Path()
      ..moveTo(10, 9)
      ..quadraticBezierTo(8, 22, 18, 24)
      ..quadraticBezierTo(27, 25, 25, 33);
    canvas.drawPath(braco, p);
    canvas.drawArc(
      const Rect.fromLTWH(9, 14, 15, 15),
      math.pi * 0.85,
      math.pi * 0.95,
      false,
      p,
    );
  }

  void _desenharTriceps(Canvas canvas, Paint p) {
    canvas.drawLine(const Offset(14, 8), const Offset(26, 32), p);
    final Path bump = Path()
      ..moveTo(17, 14)
      ..quadraticBezierTo(25, 17, 19, 22);
    canvas.drawPath(bump, p);
  }

  void _desenharAntebraco(Canvas canvas, Paint p) {
    canvas.drawLine(const Offset(13, 7), const Offset(24, 25), p);
    final Path punho = Path()
      ..addPolygon(
        const <Offset>[
          Offset(24, 21),
          Offset(31, 25),
          Offset(27, 33),
          Offset(20, 29),
        ],
        true,
      );
    canvas.drawPath(punho, p);
  }

  void _desenharPernas(Canvas canvas, Paint p) {
    canvas.drawLine(const Offset(15, 7), const Offset(14, 30), p);
    canvas.drawLine(const Offset(25, 7), const Offset(26, 30), p);
    canvas.drawLine(const Offset(14, 30), const Offset(9, 34), p);
    canvas.drawLine(const Offset(26, 30), const Offset(31, 34), p);
  }

  void _desenharAbdomen(Canvas canvas, Paint p) {
    const double esquerda = 12;
    const double topo = 8;
    const double largura = 16;
    const double altura = 24;
    final RRect grade = RRect.fromRectAndRadius(
      const Rect.fromLTWH(esquerda, topo, largura, altura),
      const Radius.circular(3),
    );
    canvas.drawRRect(grade, p);
    canvas.drawLine(
      const Offset(esquerda + largura / 2, topo),
      const Offset(esquerda + largura / 2, topo + altura),
      p,
    );
    canvas.drawLine(
      const Offset(esquerda, topo + altura / 3),
      const Offset(esquerda + largura, topo + altura / 3),
      p,
    );
    canvas.drawLine(
      const Offset(esquerda, topo + altura * 2 / 3),
      const Offset(esquerda + largura, topo + altura * 2 / 3),
      p,
    );
  }

  void _desenharGluteos(Canvas canvas, Paint p) {
    canvas.drawArc(const Rect.fromLTWH(8, 12, 14, 16), math.pi * 0.5, math.pi, false, p);
    canvas.drawArc(const Rect.fromLTWH(18, 12, 14, 16), math.pi * 1.5, math.pi, false, p);
    canvas.drawLine(const Offset(20, 12), const Offset(20, 26), p);
  }

  void _desenharPanturrilha(Canvas canvas, Paint p) {
    final Path perna = Path()
      ..moveTo(17, 6)
      ..lineTo(16, 18)
      ..quadraticBezierTo(25, 20, 20, 30)
      ..lineTo(18, 34);
    canvas.drawPath(perna, p);
  }

  void _desenharCardio(Canvas canvas, Paint p) {
    final Path coracao = Path()
      ..moveTo(20, 31)
      ..cubicTo(3, 19, 7, 5, 20, 14)
      ..cubicTo(33, 5, 37, 19, 20, 31)
      ..close();
    canvas.drawPath(coracao, p);
    final Path pulso = Path()
      ..moveTo(8, 18)
      ..lineTo(15, 18)
      ..lineTo(18, 12)
      ..lineTo(22, 22)
      ..lineTo(25, 18)
      ..lineTo(32, 18);
    canvas.drawPath(pulso, p);
  }

  void _desenharTodos(Canvas canvas, Paint p) {
    canvas.drawCircle(const Offset(20, 9), 4, p);
    canvas.drawLine(const Offset(20, 13), const Offset(20, 26), p);
    canvas.drawLine(const Offset(12, 18), const Offset(28, 18), p);
    canvas.drawLine(const Offset(20, 26), const Offset(12, 35), p);
    canvas.drawLine(const Offset(20, 26), const Offset(28, 35), p);
  }

  @override
  bool shouldRepaint(covariant _GrupoMuscularIconPainter oldDelegate) {
    return oldDelegate.grupo != grupo || oldDelegate.cor != cor;
  }
}
