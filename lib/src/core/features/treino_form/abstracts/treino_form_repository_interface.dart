import '../../../../models/exercicio.dart';
import '../../../../models/treino.dart';

/// Contrato do repository da feature `treino_form` — fala com a API.
abstract class TreinoFormRepositoryInterface {
  /// Devolve o treino salvo com o [id] informado, ou `null` se nao existir.
  Future<Treino?> obterTreino(String id);

  /// Cria (id vazio) ou atualiza o treino e devolve a versao gravada, com os
  /// ids que o servidor gerou.
  Future<Treino> salvar(Treino treino);

  /// O catalogo de exercicios que o usuario enxerga (os do sistema e os que
  /// ele criou). A escolha por grupo muscular e feita no app.
  Future<List<Exercicio>> listarExercicios();
}
