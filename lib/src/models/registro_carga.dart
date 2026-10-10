import '../core/utils/json_utils.dart';

/// Ponto de evolucao de carga de um exercicio ao longo do tempo.
///
/// Alimenta o modal "Evolução de Carga" (tela 22) e a aba Historico do
/// detalhe do exercicio (tela 19).
class RegistroCarga {
  const RegistroCarga({
    required this.exercicioId,
    required this.data,
    required this.carga,
    this.repeticoes = 12,
  });

  factory RegistroCarga.fromJson(Map<String, dynamic> json) {
    return RegistroCarga(
      exercicioId: JsonUtils.idParaTexto(json['exercicioId']),
      data: JsonUtils.dataHora(json['data']) ?? DateTime.now(),
      carga: JsonUtils.decimal(json['carga']),
      repeticoes: JsonUtils.inteiro(json['repeticoes'], padrao: 12),
    );
  }

  final String exercicioId;
  final DateTime data;
  final double carga;
  final int repeticoes;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'exercicioId': exercicioId,
        'data': data.toIso8601String(),
        'carga': carga,
        'repeticoes': repeticoes,
      };
}

/// Evolucao de carga de um exercicio: os registros em ordem cronologica e o
/// recorde pessoal (maior carga). Exercicio nunca treinado vem vazio.
class EvolucaoDeCarga {
  const EvolucaoDeCarga({
    this.registros = const <RegistroCarga>[],
    this.recorde,
  });

  factory EvolucaoDeCarga.fromJson(Map<String, dynamic> json) {
    final dynamic recorde = json['recorde'];
    return EvolucaoDeCarga(
      registros: (json['registros'] as List<dynamic>? ?? <dynamic>[])
          .map(
            (dynamic e) => RegistroCarga.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      recorde: recorde is Map<String, dynamic>
          ? RegistroCarga.fromJson(recorde)
          : null,
    );
  }

  final List<RegistroCarga> registros;
  final RegistroCarga? recorde;
}

/// Medida corporal registrada no perfil (tela 20).
class MedidaCorporal {
  const MedidaCorporal({
    required this.nome,
    required this.valor,
    required this.unidade,
    this.variacao = 0,
  });

  factory MedidaCorporal.fromJson(Map<String, dynamic> json) {
    return MedidaCorporal(
      nome: json['nome'] as String,
      valor: JsonUtils.decimal(json['valor']),
      unidade: json['unidade'] as String? ?? 'cm',
      variacao: JsonUtils.decimal(json['variacao']),
    );
  }

  final String nome;
  final double valor;
  final String unidade;

  /// Variacao em relacao a medida anterior (positivo = ganho).
  final double variacao;
}
