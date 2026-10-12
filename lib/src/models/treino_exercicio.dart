import '../core/utils/json_utils.dart';
import 'exercicio.dart';

/// Exercicio configurado dentro de um treino (series, reps, carga, descanso).
class TreinoExercicio {
  const TreinoExercicio({
    required this.id,
    required this.exercicio,
    required this.ordem,
    this.series = 4,
    this.repeticoes = 12,
    this.cargaInicial = 0,
    this.descansoSeg = 90,
    this.observacao = '',
  });

  factory TreinoExercicio.fromJson(Map<String, dynamic> json) {
    return TreinoExercicio(
      id: JsonUtils.idParaTexto(json['id']),
      exercicio:
          Exercicio.fromJson(json['exercicio'] as Map<String, dynamic>),
      ordem: JsonUtils.inteiro(json['ordem']),
      series: JsonUtils.inteiro(json['series'], padrao: 4),
      repeticoes: JsonUtils.inteiro(json['repeticoes'], padrao: 12),
      cargaInicial: JsonUtils.decimal(json['cargaInicial']),
      descansoSeg: JsonUtils.inteiro(json['descansoSeg'], padrao: 60),
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

  /// Ex.: "4 séries • 12 reps • 90 s" — o que se configura no treino. A carga
  /// nao entra: ela se define na execucao.
  String get resumo =>
      '$series ${series == 1 ? 'série' : 'séries'} • $repeticoes reps • '
      '$descansoSeg s';

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
}
