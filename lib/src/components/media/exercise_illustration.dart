import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/theme/tokens/color_tokens.dart';
import '../../core/theme/tokens/spacing_tokens.dart';
import '../../enum/grupo_muscular.dart';

/// Ilustracao do exercicio: o GIF do movimento (tela cheia) ou a miniatura
/// (modo [compact], das listas), quando o exercicio tem imagem.
///
/// Sem imagem — exercicio criado pelo usuario —, enquanto ela carrega ou se o
/// download falhar, mostra o placeholder: gradiente + padrao geometrico sutil
/// + icone Material coerente com o grupo muscular.
class ExerciseIllustration extends StatelessWidget {
  const ExerciseIllustration({
    required this.nome,
    required this.grupo,
    super.key,
    this.height = 180,
    this.compact = false,
    this.gifUrl = '',
    this.miniaturaUrl = '',
  });

  final String nome;
  final GrupoMuscular grupo;
  final double height;
  final bool compact;

  /// GIF do movimento, usado fora do modo [compact].
  final String gifUrl;

  /// Versao pequena do GIF, usada no modo [compact].
  final String miniaturaUrl;

  static const Map<GrupoMuscular, IconData> _icones = <GrupoMuscular, IconData>{
    GrupoMuscular.peito: Icons.sports_gymnastics_rounded,
    GrupoMuscular.costas: Icons.rowing_rounded,
    GrupoMuscular.ombro: Icons.sports_martial_arts_rounded,
    GrupoMuscular.biceps: Icons.fitness_center_rounded,
    GrupoMuscular.triceps: Icons.fitness_center_rounded,
    GrupoMuscular.pernas: Icons.airline_seat_legroom_extra_rounded,
    GrupoMuscular.abdomen: Icons.sports_martial_arts_rounded,
    GrupoMuscular.gluteos: Icons.airline_seat_legroom_extra_rounded,
    GrupoMuscular.panturrilha: Icons.airline_seat_legroom_extra_rounded,
    GrupoMuscular.cardio: Icons.directions_run_rounded,
    GrupoMuscular.antebraco: Icons.sports_mma_rounded,
    GrupoMuscular.todos: Icons.fitness_center_rounded,
  };

  IconData get _icone => _icones[grupo] ?? Icons.fitness_center_rounded;

  @override
  Widget build(BuildContext context) {
    final Widget placeholder = compact ? _placeholderCompacto() : _placeholder();
    final String url = compact ? miniaturaUrl : gifUrl;
    if (url.isEmpty) {
      return placeholder;
    }

    // Os GIFs tem fundo branco: ficam num cartao branco arredondado, e nao
    // soltos sobre o tema escuro.
    final double raio =
        compact ? SpacingTokens.radiusButton : SpacingTokens.radiusCard;
    return Container(
      width: compact ? 48 : double.infinity,
      height: compact ? 48 : height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(raio),
      ),
      child: CachedNetworkImage(
        imageUrl: url,
        fit: compact ? BoxFit.cover : BoxFit.contain,
        fadeInDuration: const Duration(milliseconds: 200),
        placeholder: (BuildContext context, String _) => placeholder,
        errorWidget: (BuildContext context, String _, Object __) => placeholder,
      ),
    );
  }

  Widget _placeholderCompacto() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: ColorTokens.surfaceGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(SpacingTokens.radiusButton),
      ),
      child: Icon(_icone, size: 24, color: ColorTokens.accent),
    );
  }

  Widget _placeholder() {
    return Container(
      height: height,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: ColorTokens.surfaceGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(SpacingTokens.radiusCard),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned.fill(
            child: CustomPaint(painter: _PadraoPainter()),
          ),
          Icon(_icone, size: 64, color: ColorTokens.accent),
        ],
      ),
    );
  }
}

/// Circulos concentricos sutis desenhados como pano de fundo da ilustracao.
class _PadraoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = ColorTokens.accent.withOpacity(0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    final Offset centro = Offset(size.width * 0.78, size.height * 0.28);
    for (int i = 1; i <= 4; i++) {
      canvas.drawCircle(centro, i * 28.0, paint);
    }

    final Paint linha = Paint()
      ..color = ColorTokens.accent.withOpacity(0.06)
      ..strokeWidth = 1.2;

    for (int i = 0; i < 5; i++) {
      final double y = size.height * (0.15 + i * 0.2);
      canvas.drawLine(
        Offset(-20, y),
        Offset(size.width * 0.4, y - size.height * 0.18),
        linha,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
