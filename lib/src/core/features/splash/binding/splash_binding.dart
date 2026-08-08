import 'package:get/get.dart';

import '../abstracts/splash_controller_interface.dart';
import '../controller/splash_controller.dart';

/// Injeta o controller da splash.
class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SplashControllerInterface>(SplashController.new);
  }
}
