import 'dart:async';

import 'package:get/get.dart';

import '../../../../components/feedback/app_snackbar.dart';
import '../../../../core/abstracts/log_service_interface.dart';
import '../../../../models/treino.dart';
import '../../../utils/error_messages.dart';
import '../abstracts/treinos_controller_interface.dart';
import '../abstracts/treinos_repository_interface.dart';

/// Controller de Meus Treinos — lista, duplica e exclui treinos.
class TreinosController extends GetxController
    implements TreinosControllerInterface {
  final TreinosRepositoryInterface _repository = Get.find();
  final LogServiceInterface _log = Get.find();

  @override
  final RxList<Treino> treinos = <Treino>[].obs;

  @override
  final RxBool carregando = true.obs;

  @override
  final Rxn<Treino> treinoDoDia = Rxn<Treino>();

  @override
  void onInit() {
    super.onInit();
    unawaited(carregar());
  }

  @override
  Future<void> carregar() async {
    carregando.value = true;
    try {
      final (List<Treino> lista, Treino? doDia) = await (
        _repository.listar(),
        _repository.obterTreinoDoDia(),
      ).wait;
      treinos.assignAll(lista);
      treinoDoDia.value = doDia;
    } catch (erro, stackTrace) {
      _log.error(
        'Falha ao carregar treinos',
        error: erro,
        stackTrace: stackTrace,
      );
      AppSnackbar.erro(ErrorMessages.de(erro));
    } finally {
      carregando.value = false;
    }
  }

  @override
  Future<void> duplicar(String id) async {
    try {
      await _repository.duplicar(id);
      AppSnackbar.success('Treino duplicado');
      await carregar();
    } catch (erro, stackTrace) {
      _log.error(
        'Falha ao duplicar treino',
        error: erro,
        stackTrace: stackTrace,
      );
      AppSnackbar.erro(ErrorMessages.de(erro));
    }
  }

  @override
  Future<void> excluir(String id) async {
    try {
      await _repository.excluir(id);
      AppSnackbar.success('Treino excluído');
      await carregar();
    } catch (erro, stackTrace) {
      _log.error(
        'Falha ao excluir treino',
        error: erro,
        stackTrace: stackTrace,
      );
      AppSnackbar.erro(ErrorMessages.de(erro));
    }
  }
}
