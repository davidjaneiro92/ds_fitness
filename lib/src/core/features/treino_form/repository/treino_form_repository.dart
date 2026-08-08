import 'package:get/get.dart';

import '../../../../enum/grupo_muscular.dart';
import '../../../../models/exercicio.dart';
import '../../../../models/treino.dart';
import '../../../abstracts/mock_database_interface.dart';
import '../abstracts/treino_form_repository_interface.dart';

/// Implementacao mock (latencia simulada) de [TreinoFormRepositoryInterface].
class TreinoFormRepository implements TreinoFormRepositoryInterface {
  final MockDatabaseInterface _db = Get.find();

  @override
  Future<Treino?> obterTreino(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
    return _db.treinoPorId(id);
  }

  @override
  Future<Treino> salvar(Treino treino) async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
    return _db.salvarTreino(treino);
  }

  @override
  Future<List<Exercicio>> exerciciosPorGrupo(GrupoMuscular grupo) async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
    if (grupo == GrupoMuscular.todos) {
      return _db.exercicios;
    }
    return _db.exerciciosPorGrupo(grupo);
  }
}
