import 'package:get/get.dart';

import '../../../../components/feedback/app_snackbar.dart';
import '../../../../enum/objetivo_treino.dart';
import '../../../../models/registro_carga.dart';
import '../../../../models/usuario.dart';
import '../../../abstracts/log_service_interface.dart';
import '../../../utils/error_messages.dart';
import '../../auth/abstracts/auth_controller_interface.dart';
import '../abstracts/perfil_controller_interface.dart';
import '../abstracts/perfil_repository_interface.dart';

/// Controller da tela 20 — Perfil.
class PerfilController extends GetxController
    implements PerfilControllerInterface {
  final PerfilRepositoryInterface _repository = Get.find();
  final LogServiceInterface _log = Get.find();
  final AuthControllerInterface _auth = Get.find();

  @override
  final Rx<Usuario> usuario =
      Rx<Usuario>(const Usuario(id: '', nome: '', email: ''));

  @override
  final RxList<MedidaCorporal> medidas = <MedidaCorporal>[].obs;

  @override
  final RxBool carregando = true.obs;

  @override
  void onInit() {
    super.onInit();
    carregar();
  }

  @override
  Future<void> carregar() async {
    carregando.value = true;
    try {
      final (Usuario dadosUsuario, List<MedidaCorporal> dadosMedidas) = await (
        _repository.obterUsuario(),
        _repository.obterMedidas(),
      ).wait;
      usuario.value = dadosUsuario;
      medidas.value = dadosMedidas;
    } catch (e, s) {
      _log.error('Falha ao carregar perfil', error: e, stackTrace: s);
      AppSnackbar.erro(ErrorMessages.de(e));
    } finally {
      carregando.value = false;
    }
  }

  @override
  Future<bool> salvarObjetivo(ObjetivoTreino objetivo) async {
    try {
      final Usuario atualizado = await _repository
          .salvarUsuario(usuario.value.copyWith(objetivo: objetivo));
      usuario.value = atualizado;
      return true;
    } catch (e, s) {
      _log.error('Falha ao salvar objetivo', error: e, stackTrace: s);
      AppSnackbar.erro(ErrorMessages.de(e));
      return false;
    }
  }

  @override
  Future<void> sair() async {
    await _auth.sair();
  }
}
