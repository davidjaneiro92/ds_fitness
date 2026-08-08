import 'package:get/get.dart';

import '../../../../components/charts/app_line_chart.dart';
import '../../../../enum/periodo_estatistica.dart';

/// Percentual de series treinadas em um grupo muscular no periodo
/// selecionado (tela 17 — Estatisticas).
class DistribuicaoGrupo {
  const DistribuicaoGrupo({required this.nome, required this.percentual});

  final String nome;

  /// Percentual de 0.0 a 1.0.
  final double percentual;
}

/// Contrato do controller da tela de estatisticas (tela 17).
abstract class EstatisticasControllerInterface {
  Rx<PeriodoEstatistica> get periodo;

  RxBool get carregando;

  RxInt get totalTreinos;

  RxInt get tempoTotalSeg;

  RxDouble get volumeTotal;

  RxInt get calorias;

  RxList<ChartPoint> get pontosVolume;

  RxList<DistribuicaoGrupo> get distribuicao;

  Future<void> carregar();

  void trocarPeriodo(PeriodoEstatistica periodo);
}
