import 'package:get/get.dart';

import '../../../../core/abstracts/mock_database_interface.dart';
import '../../../../models/registro_carga.dart';
import '../../../../models/sessao.dart';
import '../../../../models/treino.dart';
import '../abstracts/execucao_repository_interface.dart';

/// Repository da execucao de treino — fala apenas com [MockDatabaseInterface].
class ExecucaoRepository implements ExecucaoRepositoryInterface {
  final MockDatabaseInterface _db = Get.find();

  @override
  Future<Treino?> obterTreino(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
    return _db.treinoPorId(id);
  }

  @override
  Future<void> salvarSessao(Sessao sessao) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    _db.adicionarSessao(sessao);
  }

  @override
  Future<void> registrarCarga(RegistroCarga registro) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    _db.registrarCarga(registro);
  }

  @override
  RegistroCarga? recorde(String exercicioId) => _db.recordePessoal(exercicioId);

  @override
  List<RegistroCarga> registrosDeCarga(String exercicioId) =>
      _db.registrosDeCarga(exercicioId);
}
