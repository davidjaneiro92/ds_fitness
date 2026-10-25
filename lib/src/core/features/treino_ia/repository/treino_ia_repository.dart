import 'package:get/get.dart';

import '../../../../constants/endpoints.dart';
import '../../../../enum/http_method.dart';
import '../../../../models/treino.dart';
import '../../../abstracts/http_manager_interface.dart';
import '../abstracts/treino_ia_repository_interface.dart';

/// Client do contrato POST /calculo-treino/previa e /gerar.
class TreinoIaRepository implements TreinoIaRepositoryInterface {
  final HttpManagerInterface _http = Get.find();

  @override
  Future<List<Treino>> previa(Map<String, dynamic> preferencias) =>
      _calcular(Endpoints.calculoTreinoPrevia, preferencias);

  @override
  Future<List<Treino>> gerar(Map<String, dynamic> preferencias) =>
      _calcular(Endpoints.calculoTreinoGerar, preferencias);

  Future<List<Treino>> _calcular(
    String endpoint,
    Map<String, dynamic> preferencias,
  ) async {
    final dynamic resposta = await _http.restRequest(
      path: endpoint,
      method: HttpMethod.post,
      body: preferencias,
    );
    final Map<String, dynamic> plano = resposta as Map<String, dynamic>;
    final List<dynamic> treinos =
        plano['treinos'] as List<dynamic>? ?? <dynamic>[];
    return treinos
        .map(
            (dynamic treino) => Treino.fromJson(treino as Map<String, dynamic>))
        .toList();
  }
}
