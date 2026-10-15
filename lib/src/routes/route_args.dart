import '../models/exercicio.dart';
import '../models/sessao.dart';
import '../models/treino.dart';

/// Argumentos tipados de navegacao.
///
/// specs/02-infrastructure/navigation.md §5 proibe `Map<String, dynamic>` solto
/// como argumento de rota — cada rota que recebe dados tem sua classe aqui.

/// `/treinos/novo` e `/treinos/revisar`: o primeiro passo do fluxo de montar um
/// treino, ou a revisao de um treino que ja existe.
class TreinoFormArgs {
  const TreinoFormArgs({this.treinoId, this.partiuDaLista = false});

  /// `null` = criando um treino novo.
  final String? treinoId;

  /// `true` quando o fluxo foi aberto pela lista de treinos: ao terminar, volta
  /// a ela (e ela recarrega). Aberto pela pagina inicial, termina abrindo a
  /// lista.
  final bool partiuDaLista;

  bool get isEdicao => treinoId != null;
}

/// `/execucao` — treino a ser executado.
class ExecucaoArgs {
  const ExecucaoArgs({required this.treinoId, this.indiceExercicio = 0});

  final String treinoId;

  /// Exercício selecionado na lista do treino (0-based).
  final int indiceExercicio;
}

/// `/treinar/exercicios` — treino selecionado para iniciar.
class TreinoExecucaoListaArgs {
  const TreinoExecucaoListaArgs({required this.treino});

  final Treino treino;
}

/// `/execucao/concluido` — resumo da sessao finalizada.
class ExecucaoConcluidoArgs {
  const ExecucaoConcluidoArgs({required this.sessao});

  final Sessao sessao;
}

/// `/exercicio` — detalhe de um exercicio do catalogo.
class ExercicioDetalheArgs {
  const ExercicioDetalheArgs({required this.exercicio});

  final Exercicio exercicio;
}

/// `/exercicio/novo` e `/exercicio/editar` — formulario de exercicio.
class ExercicioFormArgs {
  const ExercicioFormArgs({this.exercicio});

  /// `null` = criando um exercicio novo.
  final Exercicio? exercicio;

  bool get isEdicao => exercicio != null;
}
