import 'package:get/get.dart';

import '../../../../enum/pages_routes.dart';
import '../../../../models/usuario.dart';
import '../../../../routes/route_args.dart';
import '../../auth/abstracts/auth_controller_interface.dart';
import '../abstracts/home_controller_interface.dart';

/// Controller da Home. Nao busca nada na API: o nome da saudacao e o do usuario
/// logado, que o `AuthController` ja tem.
class HomeController extends GetxController implements HomeControllerInterface {
  final AuthControllerInterface _auth = Get.find();

  @override
  Rx<Usuario> get usuario => _auth.usuario;

  @override
  void montarTreino() {
    Get.toNamed<void>(
      PagesRoutes.treinoNovo.path,
      arguments: const TreinoFormArgs(),
    );
  }

  /// Abre o fluxo de iniciar um treino, separado da lista administrativa.
  @override
  void treinar() {
    Get.toNamed<void>(PagesRoutes.treinar.path);
  }
}
