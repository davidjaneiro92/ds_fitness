import 'package:get/get.dart';

import '../abstracts/treino_form_controller_interface.dart';
import '../abstracts/treino_form_repository_interface.dart';
import '../controller/treino_form_controller.dart';
import '../repository/treino_form_repository.dart';

/// Binding de `/treinos/novo` e `/treinos/revisar`.
///
/// O [TreinoFormController] e o repository sao registrados como permanentes e
/// sobrevivem a toda a navegacao do fluxo (grupos, exercicios, configurar).
/// Se fossem presos a uma rota, sairiam do registro quando ela deixasse a
/// pilha — e a tela de revisao e recriada a cada exercicio acrescentado. O
/// controller so e recriado depois que [TreinoFormController.encerrar] o
/// remove do registro.
class TreinoFormBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<TreinoFormRepositoryInterface>()) {
      Get.put<TreinoFormRepositoryInterface>(
        TreinoFormRepository(),
        permanent: true,
      );
    }
    if (!Get.isRegistered<TreinoFormControllerInterface>()) {
      Get.put<TreinoFormControllerInterface>(
        TreinoFormController(),
        permanent: true,
      );
    }
  }
}
