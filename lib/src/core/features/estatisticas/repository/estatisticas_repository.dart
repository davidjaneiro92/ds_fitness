import 'package:get/get.dart';

import '../../../../components/charts/app_line_chart.dart';
import '../../../../constants/endpoints.dart';
import '../../../../enum/grupo_muscular.dart';
import '../../../../enum/http_method.dart';
import '../../../../enum/periodo_estatistica.dart';
import '../../../abstracts/http_manager_interface.dart';
import '../../../utils/json_utils.dart';
import '../abstracts/estatisticas_controller_interface.dart';
import '../abstracts/estatisticas_repository_interface.dart';

/// Repository de estatisticas sobre a API. As somas, o agrupamento por
/// semana e a distribuicao por grupo vem prontos do servidor; aqui so ficam
/// o rotulo das datas e o limite de pontos do grafico, que sao de tela.
class EstatisticasRepository implements EstatisticasRepositoryInterface {
  final HttpManagerInterface _http = Get.find();

  static const int _maxPontosGrafico = 8;

  @override
  Future<EstatisticasResumo> calcular(PeriodoEstatistica periodo) async {
    final dynamic corpo = await _http.restRequest(
      path: Endpoints.estatisticas,
      method: HttpMethod.get,
      query: <String, dynamic>{'periodo': periodo.name},
    );
    final Map<String, dynamic> resumo = corpo as Map<String, dynamic>;

    return EstatisticasResumo(
      totalTreinos: JsonUtils.inteiro(resumo['totalTreinos']),
      tempoTotalSeg: JsonUtils.inteiro(resumo['tempoTotalSeg']),
      volumeTotal: JsonUtils.decimal(resumo['volumeTotal']),
      calorias: JsonUtils.inteiro(resumo['calorias']),
      pontosVolume: _limitarPontos(_pontosDe(resumo['pontosVolume'])),
      distribuicao: _distribuicaoDe(resumo['distribuicao']),
    );
  }

  List<ChartPoint> _pontosDe(Object? bruto) {
    return (bruto as List<dynamic>? ?? <dynamic>[]).map((dynamic e) {
      final Map<String, dynamic> ponto = e as Map<String, dynamic>;
      final DateTime data =
          JsonUtils.dataHora(ponto['data']) ?? DateTime.now();
      return ChartPoint(
        label: _dataCurta(data),
        value: JsonUtils.decimal(ponto['valor']),
      );
    }).toList();
  }

  List<DistribuicaoGrupo> _distribuicaoDe(Object? bruto) {
    return (bruto as List<dynamic>? ?? <dynamic>[]).map((dynamic e) {
      final Map<String, dynamic> grupo = e as Map<String, dynamic>;
      return DistribuicaoGrupo(
        nome: GrupoMuscular.fromSlug(grupo['grupo'] as String?).label,
        percentual: JsonUtils.decimal(grupo['percentual']),
      );
    }).toList();
  }

  /// O grafico comporta poucos pontos: acima do limite, junta blocos
  /// consecutivos somando o volume.
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

  String _dataCurta(DateTime data) {
    final String dia = data.day.toString().padLeft(2, '0');
    final String mes = data.month.toString().padLeft(2, '0');
    return '$dia/$mes';
  }
}
