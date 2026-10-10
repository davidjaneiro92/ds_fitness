import 'package:get/get.dart';

import '../../../../constants/endpoints.dart';
import '../../../../enum/http_method.dart';
import '../../../../models/sessao.dart';
import '../../../abstracts/http_manager_interface.dart';
import '../../../utils/json_utils.dart';
import '../abstracts/historico_controller_interface.dart';
import '../abstracts/historico_repository_interface.dart';

/// Repository de historico sobre a API (`/execucao/sessoes` e
/// `/execucao/exercicios/resumo`).
class HistoricoRepository implements HistoricoRepositoryInterface {
  final HttpManagerInterface _http = Get.find();

  @override
  Future<List<Sessao>> obterSessoes({
    required int pagina,
    required int porPagina,
  }) async {
    final dynamic corpo = await _http.restRequest(
      path: Endpoints.sessoes,
      method: HttpMethod.get,
      query: <String, dynamic>{'pagina': pagina, 'porPagina': porPagina},
    );
    final List<dynamic> dados =
        (corpo as Map<String, dynamic>)['data'] as List<dynamic>;
    return dados
        .map((dynamic e) => Sessao.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<ResumoExercicio>> obterResumoExercicios() async {
    final dynamic corpo = await _http.restRequest(
      path: Endpoints.resumoDeExercicios,
      method: HttpMethod.get,
    );
    return (corpo as List<dynamic>).map((dynamic e) {
      final Map<String, dynamic> item = e as Map<String, dynamic>;
      return ResumoExercicio(
        nome: item['nome'] as String,
        execucoes: JsonUtils.inteiro(item['execucoes']),
        melhorCarga: JsonUtils.decimal(item['melhorCarga']),
      );
    }).toList();
  }
}
