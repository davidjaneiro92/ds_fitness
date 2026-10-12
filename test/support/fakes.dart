import 'package:ds_fitness/src/core/abstracts/log_service_interface.dart';
import 'package:ds_fitness/src/core/abstracts/storage_service_interface.dart';

/// Armazenamento em memoria no lugar do Hive.
class StorageFake implements StorageServiceInterface {
  final Map<String, Object?> dados = <String, Object?>{};

  @override
  T? read<T>(String key) {
    final Object? valor = dados[key];
    return valor is T ? valor : null;
  }

  @override
  Future<void> write(String key, Object? value) async => dados[key] = value;

  @override
  Future<void> remove(String key) async => dados.remove(key);

  @override
  Future<void> clear() async => dados.clear();
}

/// Log que descarta tudo.
class LogFake implements LogServiceInterface {
  @override
  void debug(String message, {Object? data}) {}

  @override
  void info(String message, {Object? data}) {}

  @override
  void warning(String message, {Object? error}) {}

  @override
  void error(String message, {Object? error, StackTrace? stackTrace}) {}

  @override
  void requisicaoFalhou({
    required String method,
    required String path,
    required String mensagem,
    int? status,
    int? duracaoMs,
    String? detalhe,
  }) {}
}
