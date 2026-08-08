import 'package:get/get.dart';

import '../abstracts/perfil_controller_interface.dart';
import '../abstracts/perfil_repository_interface.dart';
import '../controller/perfil_controller.dart';
import '../repository/perfil_repository.dart';

/// Injecao de dependencias da tela 20 — Perfil.
class PerfilBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PerfilRepositoryInterface>(PerfilRepository.new);
    Get.lazyPut<PerfilControllerInterface>(PerfilController.new);
  }
}
