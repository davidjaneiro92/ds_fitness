import 'package:intl/intl.dart';

import '../abstracts/format_service_interface.dart';

/// Implementacao pt-BR de [FormatServiceInterface].
class FormatService implements FormatServiceInterface {
  FormatService()
      : _inteiro = NumberFormat.decimalPattern('pt_BR'),
        _decimal = NumberFormat('#,##0.#', 'pt_BR'),
        _data = DateFormat('dd/MM/yyyy'),
        _dataCurta = DateFormat('dd/MM');

  final NumberFormat _inteiro;
  final NumberFormat _decimal;
  final DateFormat _data;
  final DateFormat _dataCurta;

  @override
  String carga(double valor) => _decimal.format(valor);

  @override
  String cargaKg(double valor) => '${carga(valor)} kg';

  @override
  String numero(num valor) => _inteiro.format(valor);

  @override
  String volume(double valor) => '${_decimal.format(valor)} kg';

  @override
  String cronometro(int segundos) {
    final int total = segundos < 0 ? 0 : segundos;
    final String minutos = (total ~/ 60).toString().padLeft(2, '0');
    final String resto = (total % 60).toString().padLeft(2, '0');
    return '$minutos:$resto';
  }

  @override
  String duracao(int segundos) {
    final int total = segundos < 0 ? 0 : segundos;
    final int horas = total ~/ 3600;
    final int minutos = (total % 3600) ~/ 60;
    if (horas > 0) {
      return '${horas}h ${minutos}m';
    }
    return '$minutos min';
  }

  @override
  String descanso(int segundos) {
    if (segundos < 60) {
      return '$segundos segundos';
    }
    final int minutos = segundos ~/ 60;
    final int resto = segundos % 60;
    return resto == 0 ? '$minutos min' : '$minutos min ${resto}s';
  }

  @override
  String data(DateTime valor) => _data.format(valor);

  @override
  String dataCurta(DateTime valor) => _dataCurta.format(valor);

  @override
  String dataRelativa(DateTime valor) {
    final DateTime hoje = DateTime.now();
    final DateTime dia = DateTime(valor.year, valor.month, valor.day);
    final DateTime referencia = DateTime(hoje.year, hoje.month, hoje.day);
    final int diferenca = referencia.difference(dia).inDays;
    if (diferenca == 0) {
      return 'Hoje';
    }
    if (diferenca == 1) {
      return 'Ontem';
    }
    return data(valor);
  }
}
