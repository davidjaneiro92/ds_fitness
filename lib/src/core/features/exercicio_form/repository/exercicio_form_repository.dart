import 'package:get/get.dart';

import '../../../../constants/endpoints.dart';
import '../../../../enum/grupo_muscular.dart';
import '../../../../enum/http_method.dart';
import '../../../../models/exercicio.dart';
import '../../../abstracts/http_manager_interface.dart';
import '../abstracts/exercicio_form_repository_interface.dart';

/// Repository do formulario de exercicio sobre a API.
class ExercicioFormRepository implements ExercicioFormRepositoryInterface {
  final HttpManagerInterface _http = Get.find();

  @override
  Future<Exercicio> criar(Exercicio exercicio) async {
    final dynamic corpo = await _http.restRequest(
      path: Endpoints.exercicios,
      method: HttpMethod.post,
      body: _corpoDoExercicio(exercicio),
    );
    return Exercicio.fromJson(corpo as Map<String, dynamic>);
  }

  @override
  Future<Exercicio> atualizar(Exercicio exercicio) async {
    final dynamic corpo = await _http.restRequest(
      path: Endpoints.exercicio(exercicio.id),
      method: HttpMethod.put,
      body: _corpoDoExercicio(exercicio),
    );
    return Exercicio.fromJson(corpo as Map<String, dynamic>);
  }

  @override
  Future<void> excluir(String id) async {
    await _http.restRequest(
      path: Endpoints.exercicio(id),
      method: HttpMethod.delete,
    );
  }

  Map<String, dynamic> _corpoDoExercicio(Exercicio exercicio) {
    return <String, dynamic>{
      'nome': exercicio.nome,
      'grupoPrimario': exercicio.grupoPrimario.slug,
      'gruposSecundarios': exercicio.gruposSecundarios
          .map((GrupoMuscular g) => g.slug)
          .toList(),
      'equipamento': exercicio.equipamento,
      'instrucoes': exercicio.instrucoes,
    };
  }
}
