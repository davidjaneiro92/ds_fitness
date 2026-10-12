import 'package:get/get.dart';

import '../abstracts/home_controller_interface.dart';
import '../controller/home_controller.dart';

/// Injecao de dependencias da feature Home.
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeControllerInterface>(HomeController.new);
  }
}
