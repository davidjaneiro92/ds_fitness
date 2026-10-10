import 'package:get/get.dart';

import '../abstracts/exercicio_form_controller_interface.dart';
import '../abstracts/exercicio_form_repository_interface.dart';
import '../controller/exercicio_form_controller.dart';
import '../repository/exercicio_form_repository.dart';

/// Injecao de dependencias de `/exercicio/novo` e `/exercicio/editar`.
class ExercicioFormBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ExercicioFormRepositoryInterface>(ExercicioFormRepository.new);
    Get.lazyPut<ExercicioFormControllerInterface>(ExercicioFormController.new);
  }
}
