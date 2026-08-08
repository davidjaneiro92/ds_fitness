import 'package:get/get.dart';

import '../../../../models/exercicio.dart';
import '../../../abstracts/mock_database_interface.dart';
import '../abstracts/biblioteca_repository_interface.dart';

/// Implementacao mock da Biblioteca de Exercicios (tela 18).
class BibliotecaRepository implements BibliotecaRepositoryInterface {
  final MockDatabaseInterface _db = Get.find();

  @override
  Future<List<Exercicio>> listarExercicios() async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
    return _db.exercicios;
  }

  @override
  Future<List<Exercicio>> listarFavoritos() async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
    return _db.favoritos;
  }

  @override
  Future<List<Exercicio>> listarRecentes() async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
    return _db.recentes;
  }

  @override
  Future<Exercicio> alternarFavorito(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
    return _db.alternarFavorito(id);
  }

  @override
  Future<void> registrarAcesso(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
    _db.registrarAcesso(id);
  }
}
