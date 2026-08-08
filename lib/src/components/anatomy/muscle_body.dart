import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/theme/tokens/color_tokens.dart';
import '../../enum/grupo_muscular.dart';

/// Silhueta de um corpo humano visto de frente, com os grupos musculares em
/// [destaque] pintados em [ColorTokens.muscle].
///
/// Desenhada inteiramente com [CustomPainter] (sem imagem/asset). O corpo e
/// desenhado num viewport logico de 100x160 e escalado para [size].
class MuscleBody extends StatelessWidget {
  const MuscleBody({
    required this.destaque,
    super.key,
    this.size = 56,
  });

  final Set<GrupoMuscular> destaque;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 1.6,
      child: CustomPaint(
        painter: _MuscleBodyPainter(destaque: destaque),
      ),
    );
  }
}

class _MuscleBodyPainter extends CustomPainter {
  _MuscleBodyPainter({required this.destaque}) : _regioes = _MuscleRegions.build();

  final Set<GrupoMuscular> destaque;
  final _MuscleRegions _regioes;

  static const double _viewportWidth = 100;
  static const double _viewportHeight = 160;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / _viewportWidth, size.height / _viewportHeight);

    final Paint base = Paint()..color = ColorTokens.bodyBase;
    for (final Path caminho in _regioes.all) {
      canvas.drawPath(caminho, base);
    }

    if (destaque.contains(GrupoMuscular.cardio)) {
      final Paint cardio = Paint()..color = ColorTokens.accent.withOpacity(0.35);
      for (final Path caminho in _regioes.all) {
        canvas.drawPath(caminho, cardio);
      }
    }

    if (destaque.contains(GrupoMuscular.costas)) {
      final Paint costas = Paint()..color = ColorTokens.muscle.withOpacity(0.55);
      canvas.drawPath(_regioes.torso, costas);
    }

    final Paint musculo = Paint()..color = ColorTokens.muscle;
    for (final GrupoMuscular grupo in destaque) {
      final List<Path>? caminhos = _regioes.byGrupo[grupo];
      if (caminhos == null) {
        continue;
      }
      for (final Path caminho in caminhos) {
        canvas.drawPath(caminho, musculo);
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _MuscleBodyPainter oldDelegate) {
    return !setEquals(oldDelegate.destaque, destaque);
  }
}

/// Conjunto de [Path]s pre-calculados que compoem a silhueta do corpo,
/// organizados por [GrupoMuscular] para permitir destaque seletivo.
class _MuscleRegions {
  _MuscleRegions._({
    required this.all,
    required this.torso,
    required this.byGrupo,
  });

  factory _MuscleRegions.build() {
    final Path cabeca = Path()..addOval(const Rect.fromLTWH(40, 5, 20, 20));
    final Path pescoco = Path()..addRect(const Rect.fromLTWH(44, 23, 12, 7));

    final Path torso = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(28, 28, 44, 64),
          const Radius.circular(10),
        ),
      );

    final Path peito = Path.combine(
      PathOperation.intersect,
      torso,
      Path()..addRect(const Rect.fromLTWH(28, 28, 44, 26)),
    );
    final Path abdomen = Path.combine(
      PathOperation.intersect,
      torso,
      Path()..addRect(const Rect.fromLTWH(28, 54, 44, 38)),
    );

    final Path deltoideEsq = Path()..addOval(const Rect.fromLTWH(9, 26, 20, 20));
    final Path deltoideDir = Path()..addOval(const Rect.fromLTWH(71, 26, 20, 20));

    final Path bicepsEsq = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(19, 40, 11, 28),
          const Radius.circular(5),
        ),
      );
    final Path tricepsEsq = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(9, 40, 11, 28),
          const Radius.circular(5),
        ),
      );
    final Path bicepsDir = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(70, 40, 11, 28),
          const Radius.circular(5),
        ),
      );
    final Path tricepsDir = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(80, 40, 11, 28),
          const Radius.circular(5),
        ),
      );

    final Path antebracoEsq = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(11, 67, 18, 25),
          const Radius.circular(6),
        ),
      );
    final Path antebracoDir = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(71, 67, 18, 25),
          const Radius.circular(6),
        ),
      );

    final Path maoEsq = Path()..addOval(const Rect.fromLTWH(14, 90, 12, 12));
    final Path maoDir = Path()..addOval(const Rect.fromLTWH(74, 90, 12, 12));

    final Path gluteos = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(28, 89, 44, 16),
          const Radius.circular(9),
        ),
      );

    final Path pernaEsq = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(29, 101, 20, 36),
          const Radius.circular(9),
        ),
      );
    final Path pernaDir = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(51, 101, 20, 36),
          const Radius.circular(9),
        ),
      );

    final Path panturrilhaEsq = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(31, 133, 16, 25),
          const Radius.circular(7),
        ),
      );
    final Path panturrilhaDir = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(53, 133, 16, 25),
          const Radius.circular(7),
        ),
      );

    final Path peEsq = Path()..addOval(const Rect.fromLTWH(30, 155, 16, 8));
    final Path peDir = Path()..addOval(const Rect.fromLTWH(54, 155, 16, 8));

    final List<Path> bracos = <Path>[
      deltoideEsq,
      deltoideDir,
      bicepsEsq,
      tricepsEsq,
      bicepsDir,
      tricepsDir,
      antebracoEsq,
      antebracoDir,
      maoEsq,
      maoDir,
    ];

    final List<Path> pernasCompletas = <Path>[
      gluteos,
      pernaEsq,
      pernaDir,
      panturrilhaEsq,
      panturrilhaDir,
      peEsq,
      peDir,
    ];

    return _MuscleRegions._(
      all: <Path>[
        cabeca,
        pescoco,
        torso,
        ...bracos,
        ...pernasCompletas,
      ],
      torso: torso,
      byGrupo: <GrupoMuscular, List<Path>>{
        GrupoMuscular.peito: <Path>[peito],
        GrupoMuscular.abdomen: <Path>[abdomen],
        GrupoMuscular.ombro: <Path>[deltoideEsq, deltoideDir],
        GrupoMuscular.biceps: <Path>[bicepsEsq, bicepsDir],
        GrupoMuscular.triceps: <Path>[tricepsEsq, tricepsDir],
        GrupoMuscular.antebraco: <Path>[antebracoEsq, antebracoDir],
        GrupoMuscular.pernas: <Path>[pernaEsq, pernaDir],
        GrupoMuscular.gluteos: <Path>[gluteos],
        GrupoMuscular.panturrilha: <Path>[panturrilhaEsq, panturrilhaDir],
      },
    );
  }

  final List<Path> all;
  final Path torso;
  final Map<GrupoMuscular, List<Path>> byGrupo;
}
