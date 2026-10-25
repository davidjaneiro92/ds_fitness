import 'package:get/get.dart';

import '../../../../constants/endpoints.dart';
import '../../../../enum/http_method.dart';
import '../../../../models/plano_ia.dart';
import '../../../abstracts/http_manager_interface.dart';
import '../abstracts/treino_ia_repository_interface.dart';

/// Client do contrato POST /calculo-treino/previa e /gerar.
class TreinoIaRepository implements TreinoIaRepositoryInterface {
  final HttpManagerInterface _http = Get.find();

  @override
  Future<PlanoIa> previa(Map<String, dynamic> preferencias) =>
      _calcular(Endpoints.calculoTreinoPrevia, preferencias);

  @override
  Future<PlanoIa> gerar(Map<String, dynamic> preferencias) =>
      _calcular(Endpoints.calculoTreinoGerar, preferencias);

  Future<PlanoIa> _calcular(
    String endpoint,
    Map<String, dynamic> preferencias,
  ) async {
    final dynamic resposta = await _http.restRequest(
      path: endpoint,
      method: HttpMethod.post,
      body: preferencias,
    );
    return PlanoIa.fromJson(resposta as Map<String, dynamic>);
  }
}
