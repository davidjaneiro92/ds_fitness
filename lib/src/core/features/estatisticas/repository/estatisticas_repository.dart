import 'package:get/get.dart';

import '../../../../components/charts/app_line_chart.dart';
import '../../../../core/abstracts/mock_database_interface.dart';
import '../../../../enum/grupo_muscular.dart';
import '../../../../enum/periodo_estatistica.dart';
import '../../../../models/exercicio.dart';
import '../../../../models/serie_executada.dart';
import '../../../../models/sessao.dart';
import '../abstracts/estatisticas_controller_interface.dart';
import '../abstracts/estatisticas_repository_interface.dart';

/// Repository de estatisticas — fala apenas com `MockDatabaseInterface`.
class EstatisticasRepository implements EstatisticasRepositoryInterface {
  final MockDatabaseInterface _db = Get.find();

  static const int _maxPontosGrafico = 8;
  static const int _maxGruposDistribuicao = 5;

  @override
  Future<EstatisticasResumo> calcular(PeriodoEstatistica periodo) async {
    await Future<void>.delayed(const Duration(milliseconds: 220));

    final DateTime limite =
        DateTime.now().subtract(Duration(days: periodo.dias));
    final List<Sessao> sessoes = _db.sessoes
        .where((Sessao s) => s.iniciadoEm.isAfter(limite))
        .toList()
      ..sort((Sessao a, Sessao b) => a.iniciadoEm.compareTo(b.iniciadoEm));

    final int tempoTotalSeg =
        sessoes.fold(0, (int acc, Sessao s) => acc + s.duracaoSeg);
    final double volumeTotal =
        sessoes.fold(0.0, (double acc, Sessao s) => acc + s.volumeTotal);
    final int calorias =
        sessoes.fold(0, (int acc, Sessao s) => acc + s.calorias);

    return EstatisticasResumo(
      totalTreinos: sessoes.length,
      tempoTotalSeg: tempoTotalSeg,
      volumeTotal: volumeTotal,
      calorias: calorias,
      pontosVolume: _pontosVolume(sessoes, periodo),
      distribuicao: _distribuicao(sessoes),
    );
  }

  List<ChartPoint> _pontosVolume(
    List<Sessao> sessoes,
    PeriodoEstatistica periodo,
  ) {
    if (sessoes.isEmpty) {
      return <ChartPoint>[];
    }

    final bool agruparPorSemana = periodo == PeriodoEstatistica.trimestre ||
        periodo == PeriodoEstatistica.ano ||
        periodo == PeriodoEstatistica.tudo;

    List<ChartPoint> pontos;
    if (agruparPorSemana) {
      final DateTime referencia = sessoes.first.iniciadoEm;
      final Map<int, double> volumePorSemana = <int, double>{};
      final Map<int, DateTime> dataPorSemana = <int, DateTime>{};
      for (final Sessao sessao in sessoes) {
        final int semana =
            sessao.iniciadoEm.difference(referencia).inDays ~/ 7;
        volumePorSemana[semana] =
            (volumePorSemana[semana] ?? 0) + sessao.volumeTotal;
        dataPorSemana[semana] = sessao.iniciadoEm;
      }
      final List<int> semanas = volumePorSemana.keys.toList()..sort();
      pontos = semanas
          .map(
            (int semana) => ChartPoint(
              label: _dataCurta(dataPorSemana[semana]!),
              value: volumePorSemana[semana]!,
            ),
          )
          .toList();
    } else {
      pontos = sessoes
          .map(
            (Sessao s) => ChartPoint(
              label: _dataCurta(s.iniciadoEm),
              value: s.volumeTotal,
            ),
          )
          .toList();
    }

    return _limitarPontos(pontos);
  }

  List<ChartPoint> _limitarPontos(List<ChartPoint> pontos) {
    if (pontos.length <= _maxPontosGrafico) {
      return pontos;
    }
    final int tamanhoBloco = (pontos.length / _maxPontosGrafico).ceil();
    final List<ChartPoint> resultado = <ChartPoint>[];
    for (int i = 0; i < pontos.length; i += tamanhoBloco) {
      final int fim = (i + tamanhoBloco).clamp(0, pontos.length);
      final List<ChartPoint> bloco = pontos.sublist(i, fim);
      final double soma =
          bloco.fold(0.0, (double acc, ChartPoint p) => acc + p.value);
      resultado.add(ChartPoint(label: bloco.last.label, value: soma));
    }
    return resultado;
  }

  List<DistribuicaoGrupo> _distribuicao(List<Sessao> sessoes) {
    final Map<GrupoMuscular, int> contagem = <GrupoMuscular, int>{};
    int totalSeries = 0;
    for (final Sessao sessao in sessoes) {
      for (final SerieExecutada serie in sessao.series) {
        final Exercicio? exercicio = _db.exercicioPorId(serie.exercicioId);
        if (exercicio == null) {
          continue;
        }
        contagem[exercicio.grupoPrimario] =
            (contagem[exercicio.grupoPrimario] ?? 0) + 1;
        totalSeries++;
      }
    }
    if (totalSeries == 0) {
      return <DistribuicaoGrupo>[];
    }
    final List<MapEntry<GrupoMuscular, int>> ordenado = contagem.entries
        .toList()
      ..sort(
        (MapEntry<GrupoMuscular, int> a, MapEntry<GrupoMuscular, int> b) =>
            b.value.compareTo(a.value),
      );
    return ordenado
        .take(_maxGruposDistribuicao)
        .map(
          (MapEntry<GrupoMuscular, int> e) => DistribuicaoGrupo(
            nome: e.key.label,
            percentual: e.value / totalSeries,
          ),
        )
        .toList();
  }

  String _dataCurta(DateTime data) {
    final String dia = data.day.toString().padLeft(2, '0');
    final String mes = data.month.toString().padLeft(2, '0');
    return '$dia/$mes';
  }
}
