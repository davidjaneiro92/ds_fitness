import 'exercicio.dart';

/// Exercicio configurado dentro de um treino (series, reps, carga, descanso).
class TreinoExercicio {
  const TreinoExercicio({
    required this.id,
    required this.exercicio,
    required this.ordem,
    this.series = 4,
    this.repeticoes = 12,
    this.cargaInicial = 20,
    this.descansoSeg = 60,
    this.observacao = '',
  });

  factory TreinoExercicio.fromJson(Map<String, dynamic> json) {
    return TreinoExercicio(
      id: json['id'] as String,
      exercicio:
          Exercicio.fromJson(json['exercicio'] as Map<String, dynamic>),
      ordem: json['ordem'] as int,
      series: json['series'] as int? ?? 4,
      repeticoes: json['repeticoes'] as int? ?? 12,
      cargaInicial: (json['cargaInicial'] as num?)?.toDouble() ?? 0,
      descansoSeg: json['descansoSeg'] as int? ?? 60,
      observacao: json['observacao'] as String? ?? '',
    );
  }

  final String id;
  final Exercicio exercicio;
  final int ordem;
  final int series;
  final int repeticoes;
  final double cargaInicial;
  final int descansoSeg;
  final String observacao;

  String get exercicioId => exercicio.id;

  /// Ex.: "4x 12 reps · 30 kg".
  String get resumo =>
      '${series}x $repeticoes reps · ${_formatCarga(cargaInicial)} kg';

  /// Volume planejado: carga x reps x series.
  double get volumePlanejado => cargaInicial * repeticoes * series;

  TreinoExercicio copyWith({
    Exercicio? exercicio,
    int? ordem,
    int? series,
    int? repeticoes,
    double? cargaInicial,
    int? descansoSeg,
    String? observacao,
  }) {
    return TreinoExercicio(
      id: id,
      exercicio: exercicio ?? this.exercicio,
      ordem: ordem ?? this.ordem,
      series: series ?? this.series,
      repeticoes: repeticoes ?? this.repeticoes,
      cargaInicial: cargaInicial ?? this.cargaInicial,
      descansoSeg: descansoSeg ?? this.descansoSeg,
      observacao: observacao ?? this.observacao,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'exercicio': exercicio.toJson(),
        'ordem': ordem,
        'series': series,
        'repeticoes': repeticoes,
        'cargaInicial': cargaInicial,
        'descansoSeg': descansoSeg,
        'observacao': observacao,
      };

  static String _formatCarga(double valor) {
    return valor == valor.roundToDouble()
        ? valor.toStringAsFixed(0)
        : valor.toStringAsFixed(1).replaceAll('.', ',');
  }
}
