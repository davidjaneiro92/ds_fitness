import 'package:hive_flutter/hive_flutter.dart';

import '../abstracts/storage_service_interface.dart';

/// Implementacao de [StorageServiceInterface] sobre uma box Hive.
class StorageService implements StorageServiceInterface {
  StorageService(this._box);

  /// Nome da box aberta no bootstrap (`main.dart`).
  static const String boxName = 'ds_fitness_app';

  final Box<dynamic> _box;

  @override
  T? read<T>(String key) {
    final dynamic value = _box.get(key);
    return value is T ? value : null;
  }

  @override
  Future<void> write(String key, Object? value) => _box.put(key, value);

  @override
  Future<void> remove(String key) => _box.delete(key);

  @override
  Future<void> clear() async {
    await _box.clear();
  }
}
