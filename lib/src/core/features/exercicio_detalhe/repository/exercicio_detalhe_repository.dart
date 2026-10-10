import 'package:get/get.dart';

import '../../../../constants/endpoints.dart';
import '../../../../enum/http_method.dart';
import '../../../../models/exercicio.dart';
import '../../../../models/registro_carga.dart';
import '../../../abstracts/http_manager_interface.dart';
import '../../../exceptions/api_exception.dart';
import '../abstracts/exercicio_detalhe_repository_interface.dart';

/// Repository do Detalhe do Exercicio sobre a API (`/cadastro/exercicios` e
/// `/execucao/cargas`).
class ExercicioDetalheRepository implements ExercicioDetalheRepositoryInterface {
  final HttpManagerInterface _http = Get.find();

  @override
  Future<Exercicio?> buscarExercicio(String id) async {
    try {
      final dynamic corpo = await _http.restRequest(
        path: Endpoints.exercicio(id),
        method: HttpMethod.get,
      );
      return Exercicio.fromJson(corpo as Map<String, dynamic>);
    } on ApiException catch (erro) {
      if (erro.ehNaoEncontrado) {
        return null;
      }
      rethrow;
    }
  }

  @override
  Future<EvolucaoDeCarga> evolucaoDeCarga(String exercicioId) async {
    final dynamic corpo = await _http.restRequest(
      path: Endpoints.evolucaoDeCarga(exercicioId),
      method: HttpMethod.get,
    );
    return EvolucaoDeCarga.fromJson(corpo as Map<String, dynamic>);
  }

  @override
  Future<Exercicio> alternarFavorito(String id) async {
    final dynamic corpo = await _http.restRequest(
      path: Endpoints.favoritoDoExercicio(id),
      method: HttpMethod.post,
    );
    return Exercicio.fromJson(corpo as Map<String, dynamic>);
  }

  @override
  Future<void> registrarAcesso(String id) async {
    await _http.restRequest(
      path: Endpoints.acessoAoExercicio(id),
      method: HttpMethod.post,
    );
  }
}
