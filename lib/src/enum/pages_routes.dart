/// Centraliza as strings de rota do app (specs/02-infrastructure/navigation.md).
///
/// Nenhum callsite deve usar string literal de rota.
enum PagesRoutes {
  splash('/splash'),
  login('/login'),
  esqueciSenha('/esqueci-senha'),
  cadastro('/cadastro'),
  home('/home'),
  treinoIa('/montar-ia'),
  treinoIaEquipamentos('/montar-ia/equipamentos'),
  treinoIaLesoes('/montar-ia/lesoes'),
  treinoIaFoco('/montar-ia/foco'),
  treinoIaPrevia('/montar-ia/previa'),
  treinoIaAdicionarExercicio('/montar-ia/exercicios'),
  treinar('/treinar'),
  treinoExecucaoLista('/treinar/exercicios'),
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
