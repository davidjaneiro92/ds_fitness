import 'package:flutter/material.dart';

import '../../constants/app_assets.dart';
import '../../core/theme/tokens/color_tokens.dart';
import '../../enum/grupo_muscular.dart';

/// Imagem do grupo muscular (corpo com o musculo pintado de verde), usada como
/// icone.
///
/// Com [destacado] `false` a imagem fica em tons de cinza — o estado de um
/// grupo ainda nao escolhido. As imagens sao grandes (mais de 1000 px); a
/// decodificacao usa so o tamanho necessario na tela.
class GrupoMuscularImagem extends StatelessWidget {
  const GrupoMuscularImagem({
    required this.grupo,
    super.key,
    this.tamanho = 56,
    this.destacado = true,
  });

  final GrupoMuscular grupo;

  /// Lado do quadrado em que a imagem cabe (a imagem mantem a proporcao).
  final double tamanho;
  final bool destacado;

  static const ColorFilter _tonsDeCinza = ColorFilter.matrix(<double>[
    0.2126, 0.7152, 0.0722, 0, 0, //
    0.2126, 0.7152, 0.0722, 0, 0, //
    0.2126, 0.7152, 0.0722, 0, 0, //
    0, 0, 0, 1, 0, //
  ]);

  @override
  Widget build(BuildContext context) {
    final Widget icone = Icon(
      Icons.fitness_center_rounded,
      size: tamanho * 0.5,
      color: ColorTokens.accent,
    );
    // "Todos" e um atalho da biblioteca, nao um grupo: nao tem imagem.
    if (grupo == GrupoMuscular.todos) {
      return SizedBox(width: tamanho, height: tamanho, child: icone);
    }

    final Widget imagem = Image.asset(
      AppAssets.musculo(grupo),
      width: tamanho,
      height: tamanho,
      fit: BoxFit.contain,
      cacheWidth: (tamanho * 3).round(),
      filterQuality: FilterQuality.medium,
      errorBuilder: (BuildContext context, Object erro, StackTrace? pilha) =>
          SizedBox(width: tamanho, height: tamanho, child: icone),
    );
    if (destacado) {
      return imagem;
    }
    return ColorFiltered(colorFilter: _tonsDeCinza, child: imagem);
  }
}
