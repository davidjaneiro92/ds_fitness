import 'dart:async';
import 'dart:convert';

import 'package:get/get.dart';

import '../../../../components/feedback/app_snackbar.dart';
import '../../../../enum/pages_routes.dart';
import '../../../../models/usuario.dart';
import '../../../abstracts/http_manager_interface.dart';
import '../../../abstracts/log_service_interface.dart';
import '../../../abstracts/storage_service_interface.dart';
import '../../../exceptions/api_exception.dart';
import '../abstracts/auth_controller_interface.dart';
import '../abstracts/auth_repository_interface.dart';

const Usuario _usuarioVazio = Usuario(id: '', nome: '', email: '');

/// Controller de autenticacao (permanente — planejamento §6).
class AuthController extends GetxController implements AuthControllerInterface {
  final AuthRepositoryInterface _repository = Get.find();
  final HttpManagerInterface _http = Get.find();
  final StorageServiceInterface _storage = Get.find();
  final LogServiceInterface _log = Get.find();

  @override
  final Rx<Usuario> usuario = Rx<Usuario>(_usuarioVazio);

  @override
  final RxBool carregando = false.obs;

  @override
  void onInit() {
    super.onInit();
    _http.aoExpirarSessao(_aoExpirarSessao);
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
    } on ApiException catch (erro) {
      _log.warning('Falha no login', error: erro);
      AppSnackbar.erro(erro.mensagem);
      return false;
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
        senha: senha,
        dataNascimento: dataNascimento,
        sexo: sexo,
      );
      await _persistirSessao(novo);
      await Get.offAllNamed<void>(PagesRoutes.home.path);
      return true;
    } on ApiException catch (erro) {
      _log.warning('Falha no cadastro', error: erro);
      AppSnackbar.erro(_mensagemDoCadastro(erro));
      return false;
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
    AppSnackbar.info('Entrar com o Google estará disponível em breve');
  }

  @override
  Future<void> sair() async {
    await _repository.encerrarSessao();
    await _limparSessaoLocal();
  }

  String _mensagemDoCadastro(ApiException erro) {
    if (erro.tipo == ApiErrorType.conflito) {
      return 'Já existe uma conta com este e-mail.';
    }
    return erro.mensagem;
  }

  /// O servidor recusou o refresh token: a sessao acabou. Limpa o que e local
  /// e leva o usuario ao login, sem apagar nada no servidor.
  Future<void> _aoExpirarSessao() async {
    await _http.limparSessao();
    await _limparSessaoLocal();
    AppSnackbar.info('Sua sessão expirou. Entre novamente.');
    unawaited(Get.offAllNamed<void>(PagesRoutes.login.path));
  }

  Future<void> _limparSessaoLocal() async {
    await _storage.remove(StorageKeys.usuario);
    await _storage.remove(StorageKeys.sessaoEmAndamento);
    usuario.value = _usuarioVazio;
  }

  Future<void> _persistirSessao(Usuario usuarioLogado) async {
    usuario.value = usuarioLogado;
    await _storage.write(
      StorageKeys.usuario,
      jsonEncode(usuarioLogado.toJson()),
    );
  }
}
