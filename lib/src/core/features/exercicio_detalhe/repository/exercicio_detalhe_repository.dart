import 'package:get/get.dart';

import '../../../../models/exercicio.dart';
import '../../../../models/registro_carga.dart';
import '../../../abstracts/mock_database_interface.dart';
import '../abstracts/exercicio_detalhe_repository_interface.dart';

/// Implementacao mock do Detalhe do Exercicio (tela 19).
class ExercicioDetalheRepository implements ExercicioDetalheRepositoryInterface {
  final MockDatabaseInterface _db = Get.find();

  @override
  Future<Exercicio?> buscarExercicio(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
    return _db.exercicioPorId(id);
  }

  @override
  Future<List<RegistroCarga>> registrosDeCarga(String exercicioId) async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
    return _db.registrosDeCarga(exercicioId);
  }

  @override
  Future<RegistroCarga?> recordePessoal(String exercicioId) async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
    return _db.recordePessoal(exercicioId);
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
