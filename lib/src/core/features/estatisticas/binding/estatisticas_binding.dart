import 'package:get/get.dart';

import '../abstracts/estatisticas_controller_interface.dart';
import '../abstracts/estatisticas_repository_interface.dart';
import '../controller/estatisticas_controller.dart';
import '../repository/estatisticas_repository.dart';

/// Injecao de dependencias da tela de estatisticas (tela 17).
class EstatisticasBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EstatisticasRepositoryInterface>(EstatisticasRepository.new);
    Get.lazyPut<EstatisticasControllerInterface>(EstatisticasController.new);
  }
}
