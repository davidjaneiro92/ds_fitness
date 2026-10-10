import 'dart:async';

import 'package:get/get.dart';

import '../../../../components/feedback/app_snackbar.dart';
import '../../../../core/abstracts/log_service_interface.dart';
import '../../../../enum/pages_routes.dart';
import '../../../../models/treino.dart';
import '../../../../models/usuario.dart';
import '../../../../routes/route_args.dart';
import '../../../utils/error_messages.dart';
import '../abstracts/home_controller_interface.dart';
import '../abstracts/home_repository_interface.dart';

/// Controller da Home — saudacao, treino do dia, progresso semanal e atalhos.
///
/// Desvio do contrato: `AuthControllerInterface` ainda nao existe no
/// codebase (feature `auth` em paralelo), entao o usuario e obtido sempre
/// via [HomeRepositoryInterface.obterUsuario].
class HomeController extends GetxController
    implements HomeControllerInterface {
  static const Usuario _usuarioVazio = Usuario(id: '', nome: '', email: '');

  final HomeRepositoryInterface _repository = Get.find();
  final LogServiceInterface _log = Get.find();

  @override
  final RxBool carregando = true.obs;

  @override
  final Rxn<Treino> treinoDoDia = Rxn<Treino>();

  @override
  final RxInt treinosNaSemana = 0.obs;

  @override
  final RxInt metaSemanal = 6.obs;

  @override
  final Rx<Usuario> usuario = _usuarioVazio.obs;

  @override
  void onInit() {
    super.onInit();
    unawaited(carregar());
  }

  @override
  Future<void> carregar() async {
    carregando.value = true;
    try {
      final (Treino? treino, int semana, Usuario dadosUsuario) = await (
        _repository.obterTreinoDoDia(),
        _repository.obterTreinosNaSemana(),
        _repository.obterUsuario(),
      ).wait;
      treinoDoDia.value = treino;
      treinosNaSemana.value = semana;
      usuario.value = dadosUsuario;
      metaSemanal.value = dadosUsuario.metaTreinosSemana;
    } catch (erro, stackTrace) {
      _log.error(
        'Falha ao carregar a home',
        error: erro,
        stackTrace: stackTrace,
      );
      AppSnackbar.erro(ErrorMessages.de(erro));
    } finally {
      carregando.value = false;
    }
  }

  @override
  void iniciarTreino() {
    final Treino? treino = treinoDoDia.value;
    if (treino == null) {
      return;
    }
    Get.toNamed<void>(
      PagesRoutes.execucao.path,
      arguments: ExecucaoArgs(treinoId: treino.id),
    );
  }
}
