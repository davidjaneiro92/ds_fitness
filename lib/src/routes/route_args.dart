import '../enum/grupo_muscular.dart';
import '../models/exercicio.dart';
import '../models/sessao.dart';

/// Argumentos tipados de navegacao.
///
/// specs/02-infrastructure/navigation.md §5 proibe `Map<String, dynamic>` solto
/// como argumento de rota — cada rota que recebe dados tem sua classe aqui.

/// `/treinos/novo` e `/treinos/editar`.
class TreinoFormArgs {
  const TreinoFormArgs({this.treinoId});

  /// `null` = criando um treino novo.
  final String? treinoId;

  bool get isEdicao => treinoId != null;
}

/// `/exercicios` — lista filtrada por grupo muscular.
class ExerciciosArgs {
  const ExerciciosArgs({required this.grupo});

  final GrupoMuscular grupo;
}

/// `/execucao` — treino a ser executado.
class ExecucaoArgs {
  const ExecucaoArgs({required this.treinoId});

  final String treinoId;
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
