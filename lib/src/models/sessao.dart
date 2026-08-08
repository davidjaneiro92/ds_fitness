import 'serie_executada.dart';

/// Sessao de treino concluida — base do historico e das estatisticas.
class Sessao {
  const Sessao({
    required this.id,
    required this.treinoId,
    required this.treinoNome,
    required this.iniciadoEm,
    this.finalizadoEm,
    this.duracaoSeg = 0,
    this.tempoDescansoSeg = 0,
    this.volumeTotal = 0,
    this.calorias = 0,
    this.series = const <SerieExecutada>[],
    this.recordes = const <String>[],
  });

  factory Sessao.fromJson(Map<String, dynamic> json) {
    return Sessao(
      id: json['id'] as String,
      treinoId: json['treinoId'] as String,
      treinoNome: json['treinoNome'] as String,
      iniciadoEm: DateTime.parse(json['iniciadoEm'] as String),
      finalizadoEm: DateTime.tryParse(json['finalizadoEm'] as String? ?? ''),
      duracaoSeg: json['duracaoSeg'] as int? ?? 0,
      tempoDescansoSeg: json['tempoDescansoSeg'] as int? ?? 0,
      volumeTotal: (json['volumeTotal'] as num?)?.toDouble() ?? 0,
      calorias: json['calorias'] as int? ?? 0,
      series: (json['series'] as List<dynamic>? ?? <dynamic>[])
          .map((dynamic e) =>
              SerieExecutada.fromJson(e as Map<String, dynamic>))
          .toList(),
      recordes: (json['recordes'] as List<dynamic>? ?? <dynamic>[])
          .map((dynamic e) => e as String)
          .toList(),
    );
  }

  final String id;
  final String treinoId;
  final String treinoNome;
  final DateTime iniciadoEm;
  final DateTime? finalizadoEm;
  final int duracaoSeg;
  final int tempoDescansoSeg;
  final double volumeTotal;
  final int calorias;
  final List<SerieExecutada> series;

  /// Nomes de exercicios em que um recorde pessoal foi batido nessa sessao.
  final List<String> recordes;

  int get totalSeries => series.length;

  int get totalExercicios =>
      series.map((SerieExecutada s) => s.exercicioId).toSet().length;

  Sessao copyWith({
    DateTime? finalizadoEm,
    int? duracaoSeg,
    int? tempoDescansoSeg,
    double? volumeTotal,
    int? calorias,
    List<SerieExecutada>? series,
    List<String>? recordes,
  }) {
    return Sessao(
      id: id,
      treinoId: treinoId,
      treinoNome: treinoNome,
      iniciadoEm: iniciadoEm,
      finalizadoEm: finalizadoEm ?? this.finalizadoEm,
      duracaoSeg: duracaoSeg ?? this.duracaoSeg,
      tempoDescansoSeg: tempoDescansoSeg ?? this.tempoDescansoSeg,
      volumeTotal: volumeTotal ?? this.volumeTotal,
      calorias: calorias ?? this.calorias,
      series: series ?? this.series,
      recordes: recordes ?? this.recordes,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'treinoId': treinoId,
        'treinoNome': treinoNome,
        'iniciadoEm': iniciadoEm.toIso8601String(),
        'finalizadoEm': finalizadoEm?.toIso8601String(),
        'duracaoSeg': duracaoSeg,
        'tempoDescansoSeg': tempoDescansoSeg,
        'volumeTotal': volumeTotal,
        'calorias': calorias,
        'series': series.map((SerieExecutada s) => s.toJson()).toList(),
        'recordes': recordes,
      };
}
