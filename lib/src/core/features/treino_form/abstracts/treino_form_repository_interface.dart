import '../../../../enum/grupo_muscular.dart';
import '../../../../models/exercicio.dart';
import '../../../../models/treino.dart';

/// Contrato do repository da feature `treino_form`.
///
/// Fala apenas com [MockDatabaseInterface] — controllers nunca acessam o
/// mock diretamente para leitura/escrita de treinos.
abstract class TreinoFormRepositoryInterface {
  /// Devolve o treino salvo com o [id] informado, ou `null` se nao existir.
  Future<Treino?> obterTreino(String id);

  /// Insere ou atualiza o treino e devolve a versao persistida.
  Future<Treino> salvar(Treino treino);

  /// Catalogo filtrado por grupo muscular (`GrupoMuscular.todos` devolve o
  /// catalogo inteiro).
  Future<List<Exercicio>> exerciciosPorGrupo(GrupoMuscular grupo);
}
