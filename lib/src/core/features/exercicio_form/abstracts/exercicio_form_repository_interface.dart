import '../../../../models/exercicio.dart';

/// Contrato do repository do formulario de exercicio — fala com a API
/// (`/cadastro/exercicios`).
abstract class ExercicioFormRepositoryInterface {
  /// Cria um exercicio do usuario e devolve a versao gravada (com o id).
  Future<Exercicio> criar(Exercicio exercicio);

  /// Substitui os dados de um exercicio do proprio usuario.
  Future<Exercicio> atualizar(Exercicio exercicio);

  /// Exclui um exercicio do proprio usuario. A exclusao e logica no servidor:
  /// o historico de treinos ja feitos continua integro.
  Future<void> excluir(String id);
}
