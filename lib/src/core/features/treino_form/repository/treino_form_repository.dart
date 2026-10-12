import 'package:get/get.dart';

import '../../../../constants/endpoints.dart';
import '../../../../enum/http_method.dart';
import '../../../../models/exercicio.dart';
import '../../../../models/treino.dart';
import '../../../../models/treino_exercicio.dart';
import '../../../abstracts/http_manager_interface.dart';
import '../../../exceptions/api_exception.dart';
import '../../../utils/json_utils.dart';
import '../abstracts/treino_form_repository_interface.dart';

/// Repository da feature `treino_form` sobre a API (`/treinos` e
/// `/cadastro/exercicios`). O corpo do treino leva o dia da semana junto com o
/// nome, o objetivo, a descricao e os exercicios.
class TreinoFormRepository implements TreinoFormRepositoryInterface {
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
  Future<Treino> salvar(Treino treino) async {
    final bool novo = treino.id.isEmpty;
    final dynamic corpo = await _http.restRequest(
      path: novo ? Endpoints.treinos : Endpoints.treino(treino.id),
      method: novo ? HttpMethod.post : HttpMethod.put,
      body: _corpoDoTreino(treino),
    );
    return Treino.fromJson(corpo as Map<String, dynamic>);
  }

  @override
  Future<List<Exercicio>> listarExercicios() async {
    final dynamic corpo = await _http.restRequest(
      path: Endpoints.exercicios,
      method: HttpMethod.get,
    );
    return (corpo as List<dynamic>)
        .map((dynamic e) => Exercicio.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// A ordem dos itens e a ordem da lista. Item com id numerico ja existe no
  /// servidor (e e atualizado); item com id local e novo (e e criado).
  Map<String, dynamic> _corpoDoTreino(Treino treino) {
    return <String, dynamic>{
      'nome': treino.nome,
      'objetivo': treino.objetivo.slug,
      'descricao': treino.descricao,
      'diaSemana': treino.diaSemana,
      'exercicios': treino.exercicios.map(_corpoDoItem).toList(),
    };
  }

  Map<String, dynamic> _corpoDoItem(TreinoExercicio item) {
    final int? idDoServidor = JsonUtils.idDoServidor(item.id);
    return <String, dynamic>{
      if (idDoServidor != null) 'id': idDoServidor,
      'exercicioId': JsonUtils.idDoServidor(item.exercicioId),
      'series': item.series,
      'repeticoes': item.repeticoes,
      'cargaInicial': item.cargaInicial,
      'descansoSeg': item.descansoSeg,
      'observacao': item.observacao,
    };
  }
}
