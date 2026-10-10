/// Conversoes entre o JSON da API e os modelos do app.
///
/// O backend usa ids numericos e instantes em UTC (com `Z`); os modelos
/// guardam ids como `String` e datas no fuso do aparelho. Centralizar aqui
/// evita um `as int` ou `DateTime.parse` espalhado por cada `fromJson`.
abstract class JsonUtils {
  /// Id do servidor (numero) ou id local (texto) como `String`.
  static String idParaTexto(Object? valor) => valor?.toString() ?? '';

  /// Id numerico do servidor, ou `null` para id local (ainda nao salvo).
  static int? idDoServidor(String id) => int.tryParse(id);

  static int inteiro(Object? valor, {int padrao = 0}) {
    if (valor is num) {
      return valor.toInt();
    }
    if (valor is String) {
      return int.tryParse(valor) ?? padrao;
    }
    return padrao;
  }

  static double decimal(Object? valor, {double padrao = 0}) {
    if (valor is num) {
      return valor.toDouble();
    }
    if (valor is String) {
      return double.tryParse(valor) ?? padrao;
    }
    return padrao;
  }

  /// Instante enviado pela API (ISO 8601, UTC) no fuso do aparelho.
  static DateTime? dataHora(Object? valor) {
    if (valor is! String || valor.isEmpty) {
      return null;
    }
    return DateTime.tryParse(valor)?.toLocal();
  }

  /// Data sem hora (`aaaa-mm-dd`). Fica em meia-noite local, para o fuso nao
  /// mudar o dia.
  static DateTime? data(Object? valor) {
    if (valor is! String || valor.isEmpty) {
      return null;
    }
    return DateTime.tryParse(valor);
  }

  /// `aaaa-mm-dd`, o formato que a API espera para datas sem hora.
  static String dataParaApi(DateTime data) {
    final String mes = data.month.toString().padLeft(2, '0');
    final String dia = data.day.toString().padLeft(2, '0');
    return '${data.year}-$mes-$dia';
  }

  /// Instante em UTC com `Z`, o formato que a API espera.
  static String instanteParaApi(DateTime instante) =>
      instante.toUtc().toIso8601String();
}
