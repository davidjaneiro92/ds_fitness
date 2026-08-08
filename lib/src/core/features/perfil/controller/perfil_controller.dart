import 'package:get/get.dart';

import '../../../../enum/objetivo_treino.dart';
import '../../../../models/registro_carga.dart';
import '../../../../models/usuario.dart';
import '../../../abstracts/log_service_interface.dart';
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
      usuario.value = await _repository.obterUsuario();
      medidas.value = await _repository.obterMedidas();
    } catch (e, s) {
      _log.error('Falha ao carregar perfil', error: e, stackTrace: s);
    } finally {
      carregando.value = false;
    }
  }

  @override
  Future<void> salvarObjetivo(ObjetivoTreino objetivo) async {
    try {
      final Usuario atualizado = await _repository
          .salvarUsuario(usuario.value.copyWith(objetivo: objetivo));
      usuario.value = atualizado;
    } catch (e, s) {
      _log.error('Falha ao salvar objetivo', error: e, stackTrace: s);
      rethrow;
    }
  }

  @override
  Future<void> sair() async {
    await _auth.sair();
  }
}
