import 'package:get/get.dart';

import '../../../../constants/endpoints.dart';
import '../../../../enum/http_method.dart';
import '../../../../models/treino.dart';
import '../../../abstracts/http_manager_interface.dart';
import '../abstracts/treinos_repository_interface.dart';

/// Repository de Meus Treinos sobre a API (`/treinos`).
class TreinosRepository implements TreinosRepositoryInterface {
  final HttpManagerInterface _http = Get.find();

  @override
  Future<List<Treino>> listar() async {
    final dynamic corpo = await _http.restRequest(
      path: Endpoints.treinos,
      method: HttpMethod.get,
    );
    return (corpo as List<dynamic>)
        .map((dynamic e) => Treino.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Treino> duplicar(String id) async {
    final dynamic corpo = await _http.restRequest(
      path: Endpoints.duplicarTreino(id),
      method: HttpMethod.post,
    );
    return Treino.fromJson(corpo as Map<String, dynamic>);
  }

  @override
  Future<void> excluir(String id) async {
    await _http.restRequest(
      path: Endpoints.treino(id),
      method: HttpMethod.delete,
    );
  }

  @override
  Future<Treino?> obterTreinoDoDia() async {
    final dynamic corpo = await _http.restRequest(
      path: Endpoints.treinoDoDia,
      method: HttpMethod.get,
      query: <String, dynamic>{'diaSemana': DateTime.now().weekday},
    );
    if (corpo == null) {
      return null;
    }
    return Treino.fromJson(corpo as Map<String, dynamic>);
  }
}
