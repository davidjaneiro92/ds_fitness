import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/tokens/color_tokens.dart';

/// Explosao de confete que roda uma unica vez ao ser montada, usada na
/// celebracao de serie/treino concluido (tela 14). Determinista: usa
/// `Random(7)` para que o resultado seja sempre o mesmo.
class ConfettiBurst extends StatefulWidget {
  const ConfettiBurst({super.key, this.size = 320});

  final double size;

  @override
  State<ConfettiBurst> createState() => _ConfettiBurstState();
}

class _ConfettiBurstState extends State<ConfettiBurst> with SingleTickerProviderStateMixin {
  static const List<Color> _cores = <Color>[
    ColorTokens.accent,
    Colors.white,
    ColorTokens.warning,
    ColorTokens.danger,
    ColorTokens.info,
  ];

  late final AnimationController _controller;
  late final List<_ConfettiParticula> _particulas;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    final math.Random aleatorio = math.Random(7);
    _particulas = List<_ConfettiParticula>.generate(40, (int index) {
      return _ConfettiParticula(
        corIndice: aleatorio.nextInt(_cores.length),
        angulo: -math.pi * 0.85 + aleatorio.nextDouble() * math.pi * 0.7,
        velocidade: 0.55 + aleatorio.nextDouble() * 0.85,
        deriva: (aleatorio.nextDouble() - 0.5) * 0.6,
        largura: 5 + aleatorio.nextDouble() * 4,
        altura: 8 + aleatorio.nextDouble() * 6,
        rotacaoInicial: aleatorio.nextDouble() * 2 * math.pi,
        velocidadeRotacao: (aleatorio.nextDouble() - 0.5) * 10,
      );
    });
    unawaited(_controller.forward());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget? child) {
          return CustomPaint(
            painter: _ConfettiPainter(
              progresso: _controller.value,
              particulas: _particulas,
              cores: _cores,
            ),
          );
        },
      ),
    );
  }
}

class _ConfettiParticula {
  const _ConfettiParticula({
    required this.corIndice,
    required this.angulo,
    required this.velocidade,
    required this.deriva,
    required this.largura,
    required this.altura,
    required this.rotacaoInicial,
    required this.velocidadeRotacao,
  });

  final int corIndice;
  final double angulo;
  final double velocidade;
  final double deriva;
  final double largura;
  final double altura;
  final double rotacaoInicial;
  final double velocidadeRotacao;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({
    required this.progresso,
    required this.particulas,
    required this.cores,
  });

  final double progresso;
  final List<_ConfettiParticula> particulas;
  final List<Color> cores;

  static const double _gravidade = 2.6;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipRect(Offset.zero & size);

    final Offset centro = Offset(size.width / 2, size.height * 0.15);
    final double escala = size.shortestSide / 2;

    for (final _ConfettiParticula particula in particulas) {
      final double t = progresso;
      final double x = math.cos(particula.angulo) * particula.velocidade * t * escala +
          particula.deriva * t * escala;
      final double y = math.sin(particula.angulo) * particula.velocidade * t * escala +
          0.5 * _gravidade * t * t * escala;

      final double opacidade = t < 0.7 ? 1.0 : (1 - (t - 0.7) / 0.3).clamp(0.0, 1.0);
      if (opacidade <= 0) {
        continue;
      }

      final Paint tinta = Paint()..color = cores[particula.corIndice].withOpacity(opacidade);
      final double rotacao = particula.rotacaoInicial + particula.velocidadeRotacao * t;

      canvas.save();
      canvas.translate(centro.dx + x, centro.dy + y);
      canvas.rotate(rotacao);
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: particula.largura,
          height: particula.altura,
        ),
        tinta,
      );
      canvas.restore();
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.progresso != progresso;
  }
}
