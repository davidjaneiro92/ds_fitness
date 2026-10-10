import 'package:get/get.dart';

import '../../../../constants/endpoints.dart';
import '../../../../enum/http_method.dart';
import '../../../../models/registro_carga.dart';
import '../../../../models/usuario.dart';
import '../../../abstracts/http_manager_interface.dart';
import '../abstracts/perfil_repository_interface.dart';

/// Repository do Perfil sobre a API (tela 20).
class PerfilRepository implements PerfilRepositoryInterface {
  final HttpManagerInterface _http = Get.find();

  @override
  Future<Usuario> obterUsuario() async {
    final dynamic corpo = await _http.restRequest(
      path: Endpoints.perfil,
      method: HttpMethod.get,
    );
    return Usuario.fromJson(corpo as Map<String, dynamic>);
  }

  @override
  Future<List<MedidaCorporal>> obterMedidas() async {
    final dynamic corpo = await _http.restRequest(
      path: Endpoints.medidas,
      method: HttpMethod.get,
    );
    return (corpo as List<dynamic>)
        .map(
          (dynamic e) => MedidaCorporal.fromJson(e as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  Future<Usuario> salvarUsuario(Usuario usuario) async {
    final Map<String, dynamic> corpo = usuario.toJson()..remove('id');
    final dynamic resposta = await _http.restRequest(
      path: Endpoints.perfil,
      method: HttpMethod.put,
      body: corpo,
    );
    return Usuario.fromJson(resposta as Map<String, dynamic>);
  }
}
