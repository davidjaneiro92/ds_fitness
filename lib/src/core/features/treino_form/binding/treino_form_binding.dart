import 'package:get/get.dart';

import '../abstracts/treino_form_controller_interface.dart';
import '../abstracts/treino_form_repository_interface.dart';
import '../controller/treino_form_controller.dart';
import '../repository/treino_form_repository.dart';

/// Binding de `/treinos/novo` e `/treinos/editar`.
///
/// O [TreinoFormController] e registrado como permanente e sobrevive a toda
/// a navegacao interna do fluxo (grupos, exercicios, sheet de adicionar).
/// So e recriado apos [TreinoFormController.encerrar] remove-lo do registro.
class TreinoFormBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TreinoFormRepositoryInterface>(TreinoFormRepository.new);
    if (!Get.isRegistered<TreinoFormControllerInterface>()) {
      Get.put<TreinoFormControllerInterface>(
        TreinoFormController(),
        permanent: true,
      );
    }
  }
}
