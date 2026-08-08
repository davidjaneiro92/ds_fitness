import 'package:get/get.dart';

import '../controller/grupos_controller.dart';

/// Binding de `/grupos`. Nao registra o [TreinoFormController] — ele ja
/// existe (registrado por `TreinoFormBinding` ao entrar no formulario).
class GruposBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GruposController>(GruposController.new);
  }
}
