import '../enum/grupo_muscular.dart';

/// Caminhos das imagens que o app traz (pasta `assets/`).
///
/// A API so informa a *chave* da imagem de um exercicio (`Exercicio.imagem`, ex.:
/// `pectorals/barbell-bench-press`: pasta do grupo e nome do arquivo, sem
/// extensao); o app monta daqui o caminho do GIF e o da miniatura. Mudar de
/// pasta ou de formato e uma mudanca neste arquivo, sem tocar na API.
abstract class AppAssets {
  static const String _base = 'assets/img';

  /// GIF animado do movimento (telas de configuracao, execucao e detalhe).
  static String gifDoExercicio(String chave) => '$_base/gifs/$chave.gif';

  /// Miniatura do exercicio (listas). O arquivo e uma animacao curta de 128 px;
  /// as listas mostram so o primeiro quadro (`AssetFirstFrame`).
  static String miniaturaDoExercicio(String chave) =>
      '$_base/imagens_estaticas/$chave.thumb.webp';

  /// Imagem do grupo muscular, usada como icone. `todos` nao tem imagem.
  static String musculo(GrupoMuscular grupo) => '$_base/muscles/${grupo.slug}.png';
}
