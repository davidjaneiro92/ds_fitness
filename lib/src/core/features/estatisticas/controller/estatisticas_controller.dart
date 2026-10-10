import 'package:get/get.dart';

import '../../../../components/charts/app_line_chart.dart';
import '../../../../components/feedback/app_snackbar.dart';
import '../../../../core/abstracts/log_service_interface.dart';
import '../../../../enum/periodo_estatistica.dart';
import '../../../utils/error_messages.dart';
import '../abstracts/estatisticas_controller_interface.dart';
import '../abstracts/estatisticas_repository_interface.dart';

/// Controller da tela de estatisticas (tela 17) — agregacoes reativas por
/// periodo.
class EstatisticasController extends GetxController
    implements EstatisticasControllerInterface {
  final EstatisticasRepositoryInterface _repository = Get.find();
  final LogServiceInterface _log = Get.find();

  @override
  final Rx<PeriodoEstatistica> periodo = PeriodoEstatistica.mes.obs;
  @override
  final RxBool carregando = true.obs;
  @override
  final RxInt totalTreinos = 0.obs;
  @override
  final RxInt tempoTotalSeg = 0.obs;
  @override
  final RxDouble volumeTotal = 0.0.obs;
  @override
  final RxInt calorias = 0.obs;
  @override
  final RxList<ChartPoint> pontosVolume = <ChartPoint>[].obs;
  @override
  final RxList<DistribuicaoGrupo> distribuicao = <DistribuicaoGrupo>[].obs;

  @override
  void onInit() {
    super.onInit();
    carregar();
  }

  @override
  Future<void> carregar() async {
    carregando.value = true;
    try {
      final EstatisticasResumo resumo =
          await _repository.calcular(periodo.value);
      totalTreinos.value = resumo.totalTreinos;
      tempoTotalSeg.value = resumo.tempoTotalSeg;
      volumeTotal.value = resumo.volumeTotal;
      calorias.value = resumo.calorias;
      pontosVolume.value = resumo.pontosVolume;
      distribuicao.value = resumo.distribuicao;
    } catch (e, s) {
      _log.error('Erro ao carregar estatisticas', error: e, stackTrace: s);
      AppSnackbar.erro(ErrorMessages.de(e));
    } finally {
      carregando.value = false;
    }
  }

  @override
  void trocarPeriodo(PeriodoEstatistica novo) {
    if (periodo.value == novo) {
      return;
    }
    periodo.value = novo;
    carregar();
  }
}
