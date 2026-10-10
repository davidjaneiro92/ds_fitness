import '../core/utils/json_utils.dart';

/// Serie efetivamente executada dentro de uma sessao (planejamento §5).
class SerieExecutada {
  const SerieExecutada({
    required this.id,
    required this.exercicioId,
    required this.numeroSerie,
    required this.repeticoes,
    required this.carga,
    this.exercicioNome = '',
    this.concluida = false,
    this.dificuldade = 0,
    this.observacao = '',
  });

  factory SerieExecutada.fromJson(Map<String, dynamic> json) {
    return SerieExecutada(
      id: JsonUtils.idParaTexto(json['id']),
      exercicioId: JsonUtils.idParaTexto(json['exercicioId']),
      exercicioNome: json['exercicioNome'] as String? ?? '',
      numeroSerie: JsonUtils.inteiro(json['numeroSerie']),
      repeticoes: JsonUtils.inteiro(json['repeticoes']),
      carga: JsonUtils.decimal(json['carga']),
      concluida: json['concluida'] as bool? ?? false,
      dificuldade: JsonUtils.inteiro(json['dificuldade']),
      observacao: json['observacao'] as String? ?? '',
    );
  }

  final String id;
  final String exercicioId;

  /// Nome do exercicio na hora da execucao (o servidor guarda junto com a
  /// serie, para o historico nao mudar se o exercicio for renomeado).
  final String exercicioNome;
  final int numeroSerie;
  final int repeticoes;
  final double carga;
  final bool concluida;

  /// Rating de 1 a 5 estrelas (0 = nao avaliada).
  final int dificuldade;
  final String observacao;

  /// Volume da serie: carga x repeticoes.
  double get volume => carga * repeticoes;

  SerieExecutada copyWith({
    int? repeticoes,
    double? carga,
    bool? concluida,
    int? dificuldade,
    String? observacao,
  }) {
    return SerieExecutada(
      id: id,
      exercicioId: exercicioId,
      exercicioNome: exercicioNome,
      numeroSerie: numeroSerie,
      repeticoes: repeticoes ?? this.repeticoes,
      carga: carga ?? this.carga,
      concluida: concluida ?? this.concluida,
      dificuldade: dificuldade ?? this.dificuldade,
      observacao: observacao ?? this.observacao,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'exercicioId': exercicioId,
        'exercicioNome': exercicioNome,
        'numeroSerie': numeroSerie,
        'repeticoes': repeticoes,
        'carga': carga,
        'concluida': concluida,
        'dificuldade': dificuldade,
        'observacao': observacao,
      };
}
