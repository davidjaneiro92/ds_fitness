/// Contrato de persistencia local chave/valor (Hive).
abstract class StorageServiceInterface {
  T? read<T>(String key);

  Future<void> write(String key, Object? value);

  Future<void> remove(String key);

  Future<void> clear();
}

/// Chaves de armazenamento usadas pelo app.
abstract class StorageKeys {
  static const String token = 'auth_token';
  static const String usuario = 'usuario';
  static const String sessaoEmAndamento = 'sessao_em_andamento';
  static const String somDescanso = 'pref_som_descanso';
  static const String vibrarDescanso = 'pref_vibrar_descanso';
}
