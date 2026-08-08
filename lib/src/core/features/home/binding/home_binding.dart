import 'package:get/get.dart';

import '../abstracts/home_controller_interface.dart';
import '../abstracts/home_repository_interface.dart';
import '../controller/home_controller.dart';
import '../repository/home_repository.dart';

/// Injecao de dependencias da feature Home.
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeRepositoryInterface>(HomeRepository.new);
    Get.lazyPut<HomeControllerInterface>(HomeController.new);
  }
}
