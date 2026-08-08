/// Serie efetivamente executada dentro de uma sessao (planejamento §5).
class SerieExecutada {
  const SerieExecutada({
    required this.id,
    required this.exercicioId,
    required this.numeroSerie,
    required this.repeticoes,
    required this.carga,
    this.concluida = false,
    this.dificuldade = 0,
    this.observacao = '',
  });

  factory SerieExecutada.fromJson(Map<String, dynamic> json) {
    return SerieExecutada(
      id: json['id'] as String,
      exercicioId: json['exercicioId'] as String,
      numeroSerie: json['numeroSerie'] as int,
      repeticoes: json['repeticoes'] as int,
      carga: (json['carga'] as num).toDouble(),
      concluida: json['concluida'] as bool? ?? false,
      dificuldade: json['dificuldade'] as int? ?? 0,
      observacao: json['observacao'] as String? ?? '',
    );
  }

  final String id;
  final String exercicioId;
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
        'numeroSerie': numeroSerie,
        'repeticoes': repeticoes,
        'carga': carga,
        'concluida': concluida,
        'dificuldade': dificuldade,
        'observacao': observacao,
      };
}
