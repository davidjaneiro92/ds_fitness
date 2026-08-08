import 'dart:async';

import 'package:get/get.dart';

import '../../../../enum/pages_routes.dart';
import '../../auth/abstracts/auth_controller_interface.dart';
import '../abstracts/splash_controller_interface.dart';

/// Controller da splash — aguarda um tempo minimo (para nao "piscar"),
/// verifica a sessao salva e navega para `/home` ou `/login`.
class SplashController extends GetxController
    implements SplashControllerInterface {
  final AuthControllerInterface _auth = Get.find();

  static const Duration _tempoMinimo = Duration(milliseconds: 1800);

  @override
  void onInit() {
    super.onInit();
    unawaited(_iniciar());
  }

  Future<void> _iniciar() async {
    await Future<void>.delayed(_tempoMinimo);
    final String destino =
        _auth.logado ? PagesRoutes.home.path : PagesRoutes.login.path;
    await Get.offAllNamed<void>(destino);
  }
}
