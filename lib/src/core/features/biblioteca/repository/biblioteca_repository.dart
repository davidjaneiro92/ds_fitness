import 'package:get/get.dart';

import '../../../../constants/endpoints.dart';
import '../../../../enum/http_method.dart';
import '../../../../models/exercicio.dart';
import '../../../abstracts/http_manager_interface.dart';
import '../abstracts/biblioteca_repository_interface.dart';

/// Repository da Biblioteca de Exercicios sobre a API (`/cadastro/exercicios`).
class BibliotecaRepository implements BibliotecaRepositoryInterface {
  final HttpManagerInterface _http = Get.find();

  @override
  Future<List<Exercicio>> listarExercicios() => _listar(null);

  @override
  Future<List<Exercicio>> listarFavoritos() => _listar('favoritos');

  @override
  Future<List<Exercicio>> listarRecentes() => _listar('recentes');

  @override
  Future<Exercicio> alternarFavorito(String id) async {
    final dynamic corpo = await _http.restRequest(
      path: Endpoints.favoritoDoExercicio(id),
      method: HttpMethod.post,
    );
    return Exercicio.fromJson(corpo as Map<String, dynamic>);
  }

  Future<List<Exercicio>> _listar(String? filtro) async {
    final dynamic corpo = await _http.restRequest(
      path: Endpoints.exercicios,
      method: HttpMethod.get,
      query: filtro == null ? null : <String, dynamic>{'filtro': filtro},
    );
    return (corpo as List<dynamic>)
        .map((dynamic e) => Exercicio.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
