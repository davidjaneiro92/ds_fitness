import 'package:get/get.dart';

import '../../../../constants/endpoints.dart';
import '../../../../enum/http_method.dart';
import '../../../../models/registro_carga.dart';
import '../../../../models/serie_executada.dart';
import '../../../../models/sessao.dart';
import '../../../../models/treino.dart';
import '../../../abstracts/http_manager_interface.dart';
import '../../../exceptions/api_exception.dart';
import '../../../utils/json_utils.dart';
import '../abstracts/execucao_repository_interface.dart';

/// Repository da execucao de treino sobre a API.
class ExecucaoRepository implements ExecucaoRepositoryInterface {
  final HttpManagerInterface _http = Get.find();

  @override
  Future<Treino?> obterTreino(String id) async {
    try {
      final dynamic corpo = await _http.restRequest(
        path: Endpoints.treino(id),
        method: HttpMethod.get,
      );
      return Treino.fromJson(corpo as Map<String, dynamic>);
    } on ApiException catch (erro) {
      if (erro.ehNaoEncontrado) {
        return null;
      }
      rethrow;
    }
  }

  @override
  Future<Sessao> finalizarSessao(Sessao sessao) async {
    final dynamic corpo = await _http.restRequest(
      path: Endpoints.sessoes,
      method: HttpMethod.post,
      body: _corpoDaSessao(sessao),
    );
    return Sessao.fromJson(corpo as Map<String, dynamic>);
  }

  @override
  Future<void> registrarCarga(RegistroCarga registro) async {
    await _http.restRequest(
      path: Endpoints.cargas,
      method: HttpMethod.post,
      body: <String, dynamic>{
        'exercicioId': JsonUtils.idDoServidor(registro.exercicioId),
        'carga': registro.carga,
        'repeticoes': registro.repeticoes,
      },
    );
  }

  @override
  Future<List<RegistroCarga>> registrosDeCarga(String exercicioId) async {
    final dynamic corpo = await _http.restRequest(
      path: Endpoints.evolucaoDeCarga(exercicioId),
      method: HttpMethod.get,
    );
    return EvolucaoDeCarga.fromJson(corpo as Map<String, dynamic>).registros;
  }

  Map<String, dynamic> _corpoDaSessao(Sessao sessao) {
    return <String, dynamic>{
      'treinoId': JsonUtils.idDoServidor(sessao.treinoId),
      'iniciadoEm': JsonUtils.instanteParaApi(sessao.iniciadoEm),
      'finalizadoEm': sessao.finalizadoEm == null
          ? null
          : JsonUtils.instanteParaApi(sessao.finalizadoEm!),
      'duracaoSeg': sessao.duracaoSeg,
      'tempoDescansoSeg': sessao.tempoDescansoSeg,
      'series': sessao.series.map(_corpoDaSerie).toList(),
    };
  }

  Map<String, dynamic> _corpoDaSerie(SerieExecutada serie) {
    return <String, dynamic>{
      'exercicioId': JsonUtils.idDoServidor(serie.exercicioId),
      'numeroSerie': serie.numeroSerie,
      'repeticoes': serie.repeticoes,
      'carga': serie.carga,
      'concluida': serie.concluida,
      'dificuldade': serie.dificuldade,
      'observacao': serie.observacao,
    };
  }
}
