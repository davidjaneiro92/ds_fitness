/// Estados da maquina de execucao de treino (planejamento §4).
///
/// ```
/// [exercicio] --realizado--> ultima serie? --nao--> [descanso] --> [exercicio]
///                                          --sim--> [serieConcluida]
///                                                        |
///                                            ultimo exercicio? --sim--> [concluido]
/// ```
enum ExecucaoState {
  carregando,
  exercicio,
  descanso,
  serieConcluida,
  concluido,
}
