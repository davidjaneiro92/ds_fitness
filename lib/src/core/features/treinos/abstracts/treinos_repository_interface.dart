import '../../../../models/treino.dart';

/// Contrato do repository de Meus Treinos — fala apenas com o
/// [MockDatabaseInterface].
abstract class TreinosRepositoryInterface {
  Future<List<Treino>> listar();

  Future<Treino> duplicar(String id);

  Future<void> excluir(String id);

  Future<Treino?> obterTreinoDoDia();
}
