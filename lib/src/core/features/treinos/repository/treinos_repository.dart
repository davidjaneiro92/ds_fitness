import 'package:get/get.dart';

import '../../../../core/abstracts/mock_database_interface.dart';
import '../../../../models/treino.dart';
import '../abstracts/treinos_repository_interface.dart';

/// Implementacao mock do repository de Meus Treinos (latencia simulada).
class TreinosRepository implements TreinosRepositoryInterface {
  final MockDatabaseInterface _db = Get.find();

  @override
  Future<List<Treino>> listar() async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
    return _db.treinos;
  }

  @override
  Future<Treino> duplicar(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
    return _db.duplicarTreino(id);
  }

  @override
  Future<void> excluir(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
    _db.excluirTreino(id);
  }

  @override
  Future<Treino?> obterTreinoDoDia() async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
    return _db.treinoDoDia;
  }
}
