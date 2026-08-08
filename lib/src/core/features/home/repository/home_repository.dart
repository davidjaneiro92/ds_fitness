import 'package:get/get.dart';

import '../../../../core/abstracts/mock_database_interface.dart';
import '../../../../models/treino.dart';
import '../../../../models/usuario.dart';
import '../abstracts/home_repository_interface.dart';

/// Implementacao mock do repository da Home (latencia simulada).
class HomeRepository implements HomeRepositoryInterface {
  final MockDatabaseInterface _db = Get.find();

  @override
  Future<Treino?> obterTreinoDoDia() async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
    return _db.treinoDoDia;
  }

  @override
  Future<int> obterTreinosNaSemana() async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
    return _db.treinosNaSemana;
  }

  @override
  Future<Usuario> obterUsuario() async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
    return _db.usuario;
  }
}
