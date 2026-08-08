import 'dart:convert';

import 'package:get/get.dart';

import '../../../../components/feedback/app_snackbar.dart';
import '../../../../enum/pages_routes.dart';
import '../../../../models/usuario.dart';
import '../../../abstracts/log_service_interface.dart';
import '../../../abstracts/storage_service_interface.dart';
import '../abstracts/auth_controller_interface.dart';
import '../abstracts/auth_repository_interface.dart';

const Usuario _usuarioVazio = Usuario(id: '', nome: '', email: '');

/// Controller de autenticacao (permanente — planejamento §6).
class AuthController extends GetxController implements AuthControllerInterface {
  final AuthRepositoryInterface _repository = Get.find();
  final StorageServiceInterface _storage = Get.find();
  final LogServiceInterface _log = Get.find();

  @override
  final Rx<Usuario> usuario = Rx<Usuario>(_usuarioVazio);

  @override
  final RxBool carregando = false.obs;

  @override
  void onInit() {
    super.onInit();
    _restaurarSessao();
  }

  /// Restaura o usuario salvo localmente (se houver sessao ativa) para que
  /// `usuario` reflita o login atual assim que o app abre.
  void _restaurarSessao() {
    final String? usuarioJson = _storage.read<String>(StorageKeys.usuario);
    if (usuarioJson == null) {
      return;
    }
    try {
      final Map<String, dynamic> mapa =
          jsonDecode(usuarioJson) as Map<String, dynamic>;
      usuario.value = Usuario.fromJson(mapa);
    } catch (erro, pilha) {
      _log.error('Falha ao restaurar sessao', error: erro, stackTrace: pilha);
    }
  }

  @override
  bool get logado => _storage.read<String>(StorageKeys.token) != null;

  @override
  Future<bool> login({required String email, required String senha}) async {
    carregando.value = true;
    try {
      final Usuario? encontrado = await _repository.autenticar(
        email: email,
        senha: senha,
      );
      if (encontrado == null) {
        AppSnackbar.erro('E-mail ou senha inválidos');
        return false;
      }
      await _persistirSessao(encontrado);
      await Get.offAllNamed<void>(PagesRoutes.home.path);
      return true;
    } catch (erro, pilha) {
      _log.error('Falha no login', error: erro, stackTrace: pilha);
      AppSnackbar.erro('Não foi possível entrar. Tente novamente.');
      return false;
    } finally {
      carregando.value = false;
    }
  }

  @override
  Future<bool> cadastrar({
    required String nome,
    required String email,
    required String senha,
    required DateTime dataNascimento,
    required String sexo,
  }) async {
    carregando.value = true;
    try {
      final Usuario novo = await _repository.registrar(
        nome: nome,
        email: email,
        dataNascimento: dataNascimento,
        sexo: sexo,
      );
      await _persistirSessao(novo);
      await Get.offAllNamed<void>(PagesRoutes.home.path);
      return true;
    } catch (erro, pilha) {
      _log.error('Falha no cadastro', error: erro, stackTrace: pilha);
      AppSnackbar.erro('Não foi possível criar sua conta. Tente novamente.');
      return false;
    } finally {
      carregando.value = false;
    }
  }

  @override
  Future<void> loginComGoogle() async {
    carregando.value = true;
    try {
      await Future<void>.delayed(const Duration(milliseconds: 700));
      final Usuario? encontrado = await _repository.autenticar(
        email: 'conta.google@dsfitness.com',
        senha: 'mock-google',
      );
      if (encontrado == null) {
        AppSnackbar.erro('Não foi possível entrar com o Google');
        return;
      }
      await _persistirSessao(encontrado);
      await Get.offAllNamed<void>(PagesRoutes.home.path);
    } catch (erro, pilha) {
      _log.error('Falha no login com Google', error: erro, stackTrace: pilha);
      AppSnackbar.erro('Não foi possível entrar com o Google');
    } finally {
      carregando.value = false;
    }
  }

  @override
  Future<void> sair() async {
    await _storage.remove(StorageKeys.token);
    await _storage.remove(StorageKeys.usuario);
    usuario.value = _usuarioVazio;
  }

  Future<void> _persistirSessao(Usuario usuarioLogado) async {
    usuario.value = usuarioLogado;
    await _storage.write(StorageKeys.token, 'mock-token-ds');
    await _storage.write(
      StorageKeys.usuario,
      jsonEncode(usuarioLogado.toJson()),
    );
  }
}
