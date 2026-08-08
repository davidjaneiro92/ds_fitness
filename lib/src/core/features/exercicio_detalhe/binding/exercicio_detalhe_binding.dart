import 'package:get/get.dart';

import '../abstracts/exercicio_detalhe_controller_interface.dart';
import '../abstracts/exercicio_detalhe_repository_interface.dart';
import '../controller/exercicio_detalhe_controller.dart';
import '../repository/exercicio_detalhe_repository.dart';

/// Injecao de dependencias da tela 19 — Detalhe do Exercicio.
class ExercicioDetalheBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ExercicioDetalheRepositoryInterface>(
      ExercicioDetalheRepository.new,
    );
    Get.lazyPut<ExercicioDetalheControllerInterface>(
      ExercicioDetalheController.new,
    );
  }
}
