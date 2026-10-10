import 'package:get/get.dart';

import '../../../../constants/endpoints.dart';
import '../../../../enum/http_method.dart';
import '../../../../enum/periodo_estatistica.dart';
import '../../../../models/treino.dart';
import '../../../../models/usuario.dart';
import '../../../abstracts/http_manager_interface.dart';
import '../../../utils/json_utils.dart';
import '../abstracts/home_repository_interface.dart';

/// Repository da Home sobre a API: treino do dia, progresso da semana e perfil.
class HomeRepository implements HomeRepositoryInterface {
  final HttpManagerInterface _http = Get.find();

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

  @override
  Future<int> obterTreinosNaSemana() async {
    final dynamic corpo = await _http.restRequest(
      path: Endpoints.estatisticas,
      method: HttpMethod.get,
      query: <String, dynamic>{'periodo': PeriodoEstatistica.semana.name},
    );
    return JsonUtils.inteiro((corpo as Map<String, dynamic>)['totalTreinos']);
  }

  @override
  Future<Usuario> obterUsuario() async {
    final dynamic corpo = await _http.restRequest(
      path: Endpoints.perfil,
      method: HttpMethod.get,
    );
    return Usuario.fromJson(corpo as Map<String, dynamic>);
  }
}
