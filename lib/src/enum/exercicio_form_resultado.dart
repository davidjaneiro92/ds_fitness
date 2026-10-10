/// O que aconteceu na tela de formulario de exercicio, devolvido a quem a
/// abriu (`Get.back(result: ...)`) para ela atualizar o que mostra.
enum ExercicioFormResultado {
  /// O exercicio foi criado ou alterado.
  salvo,

  /// O exercicio foi excluido.
  excluido,
}
