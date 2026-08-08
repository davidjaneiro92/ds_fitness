import 'package:get/get.dart';

import '../abstracts/historico_controller_interface.dart';
import '../abstracts/historico_repository_interface.dart';
import '../controller/historico_controller.dart';
import '../repository/historico_repository.dart';

/// Injecao de dependencias da tela de historico (tela 16).
class HistoricoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HistoricoRepositoryInterface>(HistoricoRepository.new);
    Get.lazyPut<HistoricoControllerInterface>(HistoricoController.new);
  }
}
