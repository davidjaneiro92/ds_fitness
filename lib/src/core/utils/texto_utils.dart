/// Apoio para comparar texto digitado pelo usuario.
abstract class TextoUtils {
  static const Map<String, String> _semAcento = <String, String>{
    'á': 'a', 'à': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a',
    'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
    'í': 'i', 'ì': 'i', 'î': 'i', 'ï': 'i',
    'ó': 'o', 'ò': 'o', 'ô': 'o', 'õ': 'o', 'ö': 'o',
    'ú': 'u', 'ù': 'u', 'û': 'u', 'ü': 'u',
    'ç': 'c',
  };

  /// Minusculo e sem acento, para a busca achar "Maquina" ao digitar "máquina".
  static String normalizar(String texto) {
    final StringBuffer saida = StringBuffer();
    for (final String letra in texto.toLowerCase().split('')) {
      saida.write(_semAcento[letra] ?? letra);
    }
    return saida.toString().trim();
  }

  /// `true` quando [texto] contem [busca], ignorando caixa e acentos. Busca
  /// vazia casa com tudo.
  static bool contem(String texto, String busca) {
    final String termo = normalizar(busca);
    return termo.isEmpty || normalizar(texto).contains(termo);
  }
}
