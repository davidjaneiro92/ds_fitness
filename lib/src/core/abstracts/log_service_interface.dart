/// Contrato de logging estruturado (specs/02-infrastructure/logging).
///
/// `print()` e proibido no projeto — use sempre este servico injetado.
abstract class LogServiceInterface {
  void debug(String message, {Object? data});

  void info(String message, {Object? data});

  void warning(String message, {Object? error});

  void error(String message, {Object? error, StackTrace? stackTrace});
}
