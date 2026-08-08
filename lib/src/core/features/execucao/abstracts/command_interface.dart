/// Contrato do Command Pattern usado pela feature execucao
/// (specs/01-architecture/command-pattern-and-features.md).
///
/// Cada operacao de negocio da execucao (concluir serie, alterar carga,
/// finalizar treino) e encapsulada num command de vida curta: instanciado
/// pelo controller, executado com `await command.execute()` e descartado.
abstract class CommandInterface {
  Future<void> execute();
}
