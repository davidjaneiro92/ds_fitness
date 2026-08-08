/// Contrato de formatacao pt-BR (numeros, cargas, datas e duracoes).
abstract class FormatServiceInterface {
  /// 30 -> "30" · 32.5 -> "32,5"
  String carga(double valor);

  /// 30 -> "30 kg" · 32.5 -> "32,5 kg"
  String cargaKg(double valor);

  /// 5240 -> "5.240"
  String numero(num valor);

  /// 5240 -> "5.240 kg" · 1200.5 -> "1.200,5 kg"
  String volume(double valor);

  /// 2905 -> "48:25" (mm:ss)
  String cronometro(int segundos);

  /// 37500 -> "10h 25m" · 2700 -> "45 min"
  String duracao(int segundos);

  /// 60 -> "60 segundos" · 90 -> "1 min 30s"
  String descanso(int segundos);

  /// DateTime -> "15/07/2026"
  String data(DateTime valor);

  /// DateTime -> "15/07"
  String dataCurta(DateTime valor);

  /// DateTime -> "Hoje", "Ontem" ou "15/07/2026"
  String dataRelativa(DateTime valor);
}
