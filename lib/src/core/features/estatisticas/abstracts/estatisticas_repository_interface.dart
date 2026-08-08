import '../../../../components/charts/app_line_chart.dart';
import '../../../../enum/periodo_estatistica.dart';
import 'estatisticas_controller_interface.dart';

/// Agregacao de estatisticas de um periodo (tela 17).
class EstatisticasResumo {
  const EstatisticasResumo({
    required this.totalTreinos,
    required this.tempoTotalSeg,
    required this.volumeTotal,
    required this.calorias,
    required this.pontosVolume,
    required this.distribuicao,
  });

  final int totalTreinos;
  final int tempoTotalSeg;
  final double volumeTotal;
  final int calorias;
  final List<ChartPoint> pontosVolume;
  final List<DistribuicaoGrupo> distribuicao;
}

/// Contrato do repository de estatisticas — fala apenas com
/// `MockDatabaseInterface` (tela 17).
abstract class EstatisticasRepositoryInterface {
  Future<EstatisticasResumo> calcular(PeriodoEstatistica periodo);
}
