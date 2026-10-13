/// Centraliza as strings de rota do app (specs/02-infrastructure/navigation.md).
///
/// Nenhum callsite deve usar string literal de rota.
enum PagesRoutes {
  splash('/splash'),
  login('/login'),
  esqueciSenha('/esqueci-senha'),
  cadastro('/cadastro'),
  home('/home'),
  treinos('/treinos'),
  treinoNovo('/treinos/novo'),
  treinoRevisar('/treinos/revisar'),
  grupos('/grupos'),
  exercicios('/exercicios'),
  exercicioConfigurar('/exercicios/configurar'),
  execucao('/execucao'),
  execucaoConcluido('/execucao/concluido'),
  historico('/historico'),
  estatisticas('/estatisticas'),
  biblioteca('/biblioteca'),
  exercicioDetalhe('/exercicio'),
  exercicioNovo('/exercicio/novo'),
  exercicioEditar('/exercicio/editar'),
  perfil('/perfil');

  const PagesRoutes(this.path);

  final String path;
}
