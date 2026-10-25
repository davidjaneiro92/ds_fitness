import 'package:get/get.dart';

import '../../perfil/abstracts/perfil_repository_interface.dart';
import '../../perfil/repository/perfil_repository.dart';
import '../../treino_form/abstracts/treino_form_repository_interface.dart';
import '../../treino_form/repository/treino_form_repository.dart';
import '../abstracts/treino_ia_controller_interface.dart';
import '../abstracts/treino_ia_repository_interface.dart';
import '../controller/treino_ia_controller.dart';
import '../repository/treino_ia_repository.dart';

/// Dependencias compartilhadas por todas as telas do fluxo de IA.
class TreinoIaBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<PerfilRepositoryInterface>()) {
      Get.put<PerfilRepositoryInterface>(PerfilRepository(), permanent: true);
    }
    if (!Get.isRegistered<TreinoFormRepositoryInterface>()) {
      Get.put<TreinoFormRepositoryInterface>(
        TreinoFormRepository(),
        permanent: true,
      );
    }
    if (!Get.isRegistered<TreinoIaRepositoryInterface>()) {
      Get.put<TreinoIaRepositoryInterface>(TreinoIaRepository(),
          permanent: true);
    }
    // A rota de entrada sempre começa um fluxo novo. Se o anterior foi
    // interrompido sem cancelar (ex.: a sessão expirou e o app foi ao login),
    // o controller antigo ficaria com o perfil vazio e as escolhas velhas.
    if (Get.isRegistered<TreinoIaControllerInterface>()) {
      Get.delete<TreinoIaControllerInterface>(force: true);
    }
    Get.put<TreinoIaControllerInterface>(
      TreinoIaController(),
      permanent: true,
    );
  }
}
