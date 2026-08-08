import 'package:get/get.dart';

import '../abstracts/execucao_controller_interface.dart';
import '../abstracts/execucao_repository_interface.dart';
import '../controller/execucao_controller.dart';
import '../repository/execucao_repository.dart';

/// Injecao de dependencias da feature execucao.
class ExecucaoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ExecucaoRepositoryInterface>(ExecucaoRepository.new);
    Get.lazyPut<ExecucaoControllerInterface>(ExecucaoController.new);
  }
}
