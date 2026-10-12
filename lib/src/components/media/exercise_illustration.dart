import 'package:flutter/material.dart';

import '../../constants/app_assets.dart';
import '../../core/theme/tokens/color_tokens.dart';
import '../../core/theme/tokens/spacing_tokens.dart';
import '../../enum/grupo_muscular.dart';
import 'asset_first_frame.dart';

/// Ilustracao do exercicio: o GIF do movimento (telas cheias) ou a miniatura
/// parada (modo [compact], das listas), quando o exercicio tem imagem.
///
/// As imagens vem dos assets do app, pela chave [imagem] que a API informa
/// (`AppAssets`). Sem imagem — exercicio criado pelo usuario — ou se o arquivo
/// nao existir, mostra o placeholder: gradiente + padrao geometrico sutil +
/// icone Material coerente com o grupo muscular.
class ExerciseIllustration extends StatelessWidget {
  const ExerciseIllustration({
    required this.imagem,
    required this.grupo,
    super.key,
    this.height = 180,
    this.compact = false,
    this.tamanho = 48,
  });

  /// Chave da imagem (`Exercicio.imagem`); vazia = sem imagem.
  final String imagem;
  final GrupoMuscular grupo;

  /// Altura no modo cheio.
  final double height;
  final bool compact;

  /// Lado do quadrado no modo [compact].
  final double tamanho;

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
    if (imagem.isEmpty) {
      return placeholder;
    }

    // Os GIFs e as miniaturas tem fundo branco: ficam num cartao branco
    // arredondado, e nao soltos sobre o tema escuro.
    final double raio =
        compact ? SpacingTokens.radiusButton : SpacingTokens.radiusCard;
    return Container(
      width: compact ? tamanho : double.infinity,
      height: compact ? tamanho : height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(raio),
      ),
      child: compact
          ? AssetFirstFrame(
              asset: AppAssets.miniaturaDoExercicio(imagem),
              fallback: placeholder,
            )
          : Image.asset(
              AppAssets.gifDoExercicio(imagem),
              fit: BoxFit.contain,
              gaplessPlayback: true,
              errorBuilder:
                  (BuildContext context, Object erro, StackTrace? pilha) =>
                      placeholder,
            ),
    );
  }

  Widget _placeholderCompacto() {
    return Container(
      width: tamanho,
      height: tamanho,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: ColorTokens.surfaceGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(SpacingTokens.radiusButton),
      ),
      child: Icon(_icone, size: tamanho / 2, color: ColorTokens.accent),
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
