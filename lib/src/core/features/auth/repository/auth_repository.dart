import 'package:get/get.dart';

import '../../../../constants/endpoints.dart';
import '../../../../enum/http_method.dart';
import '../../../../models/usuario.dart';
import '../../../abstracts/http_manager_interface.dart';
import '../../../exceptions/api_exception.dart';
import '../abstracts/auth_repository_interface.dart';

/// Repository de autenticacao sobre a API (planejamento §6).
class AuthRepository implements AuthRepositoryInterface {
  final HttpManagerInterface _http = Get.find();

  @override
  Future<Usuario?> autenticar({
    required String email,
    required String senha,
  }) async {
    try {
      await _entrar(email, senha);
    } on ApiException catch (erro) {
      if (erro.ehNaoAutenticado) {
        return null;
      }
      rethrow;
    }
    return _obterOuCriarPerfil(email);
  }

  @override
  Future<Usuario> registrar({
    required String nome,
    required String email,
    required String senha,
    required DateTime dataNascimento,
    required String sexo,
  }) async {
    await _http.restRequest(
      path: Endpoints.autoCadastro,
      method: HttpMethod.post,
      body: <String, dynamic>{'login': email, 'senha': senha},
      autenticado: false,
    );
    await _entrar(email, senha);
    return _salvarPerfil(
      Usuario(
        id: '',
        nome: nome,
        email: email,
        dataNascimento: dataNascimento,
        sexo: sexo,
      ),
    );
  }

  @override
  Future<void> encerrarSessao() async {
    final String? refreshToken = _http.refreshToken;
    try {
      if (refreshToken != null) {
        await _http.restRequest(
          path: Endpoints.logoff,
          method: HttpMethod.post,
          body: <String, dynamic>{
            'refreshToken': refreshToken,
            'encerrarTodasAsSessoes': false,
          },
          autenticado: false,
        );
      }
    } on ApiException {
      // Sem rede ou token ja revogado: o usuario sai do mesmo jeito.
    } finally {
      await _http.limparSessao();
    }
  }

  Future<void> _entrar(String email, String senha) async {
    final dynamic corpo = await _http.restRequest(
      path: Endpoints.login,
      method: HttpMethod.post,
      body: <String, dynamic>{'login': email, 'senha': senha},
      autenticado: false,
    );
    final Map<String, dynamic> sessao = corpo as Map<String, dynamic>;
    await _http.guardarSessao(
      accessToken: sessao['accessToken'] as String,
      refreshToken: sessao['refreshToken'] as String,
      accessTokenExpiraEm:
          DateTime.parse(sessao['accessTokenExpiraEm'] as String),
    );
  }

  /// A conta pode existir sem perfil (o cadastro cai entre o auto-cadastro e
  /// a gravacao do perfil): nesse caso o perfil e criado agora, com o que se
  /// sabe, e o usuario completa depois.
  Future<Usuario> _obterOuCriarPerfil(String email) async {
    try {
      final dynamic corpo = await _http.restRequest(
        path: Endpoints.perfil,
        method: HttpMethod.get,
      );
      return Usuario.fromJson(corpo as Map<String, dynamic>);
    } on ApiException catch (erro) {
      if (!erro.ehNaoEncontrado) {
        rethrow;
      }
      return _salvarPerfil(
        Usuario(id: '', nome: _nomeAPartirDoEmail(email), email: email),
      );
    }
  }

  Future<Usuario> _salvarPerfil(Usuario usuario) async {
    final Map<String, dynamic> corpo = usuario.toJson()..remove('id');
    final dynamic resposta = await _http.restRequest(
      path: Endpoints.perfil,
      method: HttpMethod.put,
      body: corpo,
    );
    return Usuario.fromJson(resposta as Map<String, dynamic>);
  }

  String _nomeAPartirDoEmail(String email) => email.split('@').first;
}
