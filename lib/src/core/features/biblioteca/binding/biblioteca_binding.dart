import 'package:get/get.dart';

import '../abstracts/biblioteca_controller_interface.dart';
import '../abstracts/biblioteca_repository_interface.dart';
import '../controller/biblioteca_controller.dart';
import '../repository/biblioteca_repository.dart';

/// Injecao de dependencias da tela 18 — Biblioteca de Exercicios.
class BibliotecaBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BibliotecaRepositoryInterface>(BibliotecaRepository.new);
    Get.lazyPut<BibliotecaControllerInterface>(BibliotecaController.new);
  }
}
