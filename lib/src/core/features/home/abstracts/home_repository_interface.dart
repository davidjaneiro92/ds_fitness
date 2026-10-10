import '../../../../models/treino.dart';
import '../../../../models/usuario.dart';

/// Contrato do repository da Home — fala com a API (`/treinos/do-dia`,
/// `/execucao/estatisticas` e `/cadastro/perfil`).
abstract class HomeRepositoryInterface {
  Future<Treino?> obterTreinoDoDia();

  /// Quantos treinos o usuario fez nos ultimos 7 dias.
  Future<int> obterTreinosNaSemana();

  Future<Usuario> obterUsuario();
}
