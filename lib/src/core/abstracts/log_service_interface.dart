/// Contrato de logging estruturado (specs/02-infrastructure/logging).
///
/// `print()` e proibido no projeto — use sempre este servico injetado.
abstract class LogServiceInterface {
  void debug(String message, {Object? data});

  void info(String message, {Object? data});

  void warning(String message, {Object? error});

  void error(String message, {Object? error, StackTrace? stackTrace});

  /// Falha de uma chamada a API (sem resposta ou status de erro). Vai para o
  /// log remoto como erro de `requisicao`.
  void requisicaoFalhou({
    required String method,
    required String path,
    required String mensagem,
    int? status,
    int? duracaoMs,
    String? detalhe,
  });
}
