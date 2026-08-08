import 'package:get/get.dart';

import '../../../../enum/objetivo_treino.dart';
import '../../../../models/exercicio.dart';
import '../../../../models/treino_exercicio.dart';

/// Contrato do estado compartilhado do fluxo de criacao/edicao de treino.
///
/// Uma unica instancia sobrevive a navegacao `/treinos/novo (ou editar) →
/// /grupos → /exercicios → (sheet) → volta` — veja `TreinoFormBinding`.
abstract class TreinoFormControllerInterface {
  RxBool get carregando;

  RxString get nome;

  Rx<ObjetivoTreino> get objetivo;

  RxString get descricao;

  RxList<TreinoExercicio> get exercicios;

  /// `true` quando ha nome preenchido e ao menos um exercicio adicionado.
  bool get podeSalvar;

  bool jaAdicionado(String exercicioId);

  void adicionarExercicio(
    Exercicio exercicio, {
    required int series,
    required int repeticoes,
    required double carga,
    required int descansoSeg,
    String observacao = '',
  });

  void atualizarExercicio(
    TreinoExercicio item, {
    required int series,
    required int repeticoes,
    required double carga,
    required int descansoSeg,
    String observacao = '',
  });

  void removerExercicio(String treinoExercicioId);

  void reordenar(int oldIndex, int newIndex);

  /// Persiste o treino atual. Devolve `true` em caso de sucesso.
  Future<bool> salvar();

  /// Encerra o formulario: descarta a instancia permanente do controller.
  /// Deve ser chamado antes de qualquer saida definitiva do fluxo
  /// (salvar, descartar ou iniciar o treino).
  void encerrar();
}
