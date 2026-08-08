import 'package:get/get.dart';

import '../abstracts/exercicios_controller_interface.dart';
import '../controller/exercicios_controller.dart';

/// Binding de `/exercicios`. Nao registra o [TreinoFormController] — ele ja
/// existe (registrado por `TreinoFormBinding` ao entrar no formulario).
class ExerciciosBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ExerciciosControllerInterface>(ExerciciosController.new);
  }
}
