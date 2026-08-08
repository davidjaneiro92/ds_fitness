import 'package:get/get.dart';

import '../abstracts/treinos_controller_interface.dart';
import '../abstracts/treinos_repository_interface.dart';
import '../controller/treinos_controller.dart';
import '../repository/treinos_repository.dart';

/// Injecao de dependencias da feature Meus Treinos.
class TreinosBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TreinosRepositoryInterface>(TreinosRepository.new);
    Get.lazyPut<TreinosControllerInterface>(TreinosController.new);
  }
}
