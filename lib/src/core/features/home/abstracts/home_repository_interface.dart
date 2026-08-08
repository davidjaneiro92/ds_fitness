import '../../../../models/treino.dart';
import '../../../../models/usuario.dart';

/// Contrato do repository da Home — fala apenas com o [MockDatabaseInterface].
abstract class HomeRepositoryInterface {
  Future<Treino?> obterTreinoDoDia();

  Future<int> obterTreinosNaSemana();

  Future<Usuario> obterUsuario();
}
