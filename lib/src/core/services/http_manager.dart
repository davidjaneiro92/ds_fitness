import 'package:dio/dio.dart';

import '../../constants/app_environment.dart';
import '../../constants/endpoints.dart';
import '../../enum/http_method.dart';
import '../abstracts/http_manager_interface.dart';
import '../abstracts/log_service_interface.dart';
import '../abstracts/storage_service_interface.dart';
import '../exceptions/api_exception.dart';

/// Implementacao de [HttpManagerInterface] sobre o Dio.
///
/// Responsabilidades:
/// * montar a URL (`AppEnvironment.apiBaseUrl`) e os timeouts;
/// * enviar o access token e renovar a sessao antes de vencer ou ao receber
///   401 — uma unica renovacao por vez, mesmo com varias chamadas em voo;
/// * converter toda falha em `ApiException`.
///
/// Diferente do legado, nao aceita certificado invalido, nao navega e nao
/// mostra dialogo (specs/01-architecture/adr/0002-security-and-storage.md).
class HttpManager implements HttpManagerInterface {
  HttpManager({
    required StorageServiceInterface storage,
    required LogServiceInterface log,
    Dio? dio,
    Dio? dioDeRenovacao,
  })  : _storage = storage,
        _log = log,
        _dio = dio ?? _criarDio(),
        _dioDeRenovacao = dioDeRenovacao ?? _criarDio();

  static const Duration _tempoDeConexao = Duration(seconds: 15);
  static const Duration _tempoDeResposta = Duration(seconds: 30);

  /// Renova o token um pouco antes de vencer, para a chamada seguinte nao
  /// chegar ao servidor ja expirada.
  static const Duration _margemDeRenovacao = Duration(seconds: 30);

  final StorageServiceInterface _storage;
  final LogServiceInterface _log;
  final Dio _dio;

  /// Dio sem nenhum interceptor de sessao: a propria chamada de renovacao
  /// nao pode disparar outra renovacao.
  final Dio _dioDeRenovacao;

  Future<bool>? _renovacaoEmAndamento;
  void Function()? _acaoDeSessaoExpirada;

  static Dio _criarDio() {
    return Dio(
      BaseOptions(
        baseUrl: AppEnvironment.apiBaseUrl,
        connectTimeout: _tempoDeConexao,
        sendTimeout: _tempoDeResposta,
        receiveTimeout: _tempoDeResposta,
        headers: <String, dynamic>{'Accept': 'application/json'},
      ),
    );
  }

  @override
  String? get refreshToken => _storage.read<String>(StorageKeys.refreshToken);

  @override
  void aoExpirarSessao(void Function() acao) {
    _acaoDeSessaoExpirada = acao;
  }

  @override
  Future<void> guardarSessao({
    required String accessToken,
    required String refreshToken,
    required DateTime accessTokenExpiraEm,
  }) async {
    await _storage.write(StorageKeys.token, accessToken);
    await _storage.write(StorageKeys.refreshToken, refreshToken);
    await _storage.write(
      StorageKeys.tokenExpiraEm,
      accessTokenExpiraEm.toUtc().toIso8601String(),
    );
  }

  @override
  Future<void> limparSessao() async {
    await _storage.remove(StorageKeys.token);
    await _storage.remove(StorageKeys.refreshToken);
    await _storage.remove(StorageKeys.tokenExpiraEm);
  }

  @override
  Future<dynamic> restRequest({
    required String path,
    required HttpMethod method,
    Map<String, dynamic>? query,
    Object? body,
    bool autenticado = true,
  }) async {
    final Stopwatch cronometro = Stopwatch()..start();
    try {
      if (autenticado) {
        await _renovarSeVencido();
      }
      final Response<dynamic> resposta =
          await _enviar(path, method, query, body, autenticado);
      _registrar(method, path, resposta.statusCode, cronometro);
      return _corpoDe(resposta);
    } on DioException catch (erro) {
      _registrar(method, path, erro.response?.statusCode, cronometro);
      if (autenticado && erro.response?.statusCode == 401) {
        return _repetirAposRenovar(path, method, query, body, erro);
      }
      throw ApiException.deDio(erro);
    }
  }

  Future<dynamic> _repetirAposRenovar(
    String path,
    HttpMethod method,
    Map<String, dynamic>? query,
    Object? body,
    DioException erroOriginal,
  ) async {
    final bool renovada = await _renovarSessao();
    if (!renovada) {
      _expirarSessao();
      throw ApiException.deDio(erroOriginal);
    }
    try {
      final Response<dynamic> resposta =
          await _enviar(path, method, query, body, true);
      return _corpoDe(resposta);
    } on DioException catch (erro) {
      throw ApiException.deDio(erro);
    }
  }

  Future<Response<dynamic>> _enviar(
    String path,
    HttpMethod method,
    Map<String, dynamic>? query,
    Object? body,
    bool autenticado,
  ) {
    final String? token =
        autenticado ? _storage.read<String>(StorageKeys.token) : null;
    return _dio.request<dynamic>(
      path,
      data: body,
      queryParameters: query,
      options: Options(
        method: method.valor,
        headers: token == null
            ? null
            : <String, dynamic>{'Authorization': 'Bearer $token'},
      ),
    );
  }

  /// Renova antes de enviar quando o token ja venceu (ou vai vencer). Falha
  /// de rede aqui e ignorada: a chamada em si vai falhar pelo mesmo motivo e
  /// devolve o erro certo ao usuario.
  Future<void> _renovarSeVencido() async {
    final String? texto = _storage.read<String>(StorageKeys.tokenExpiraEm);
    if (texto == null || refreshToken == null) {
      return;
    }
    final DateTime? expiraEm = DateTime.tryParse(texto);
    if (expiraEm == null) {
      return;
    }
    final DateTime limite = expiraEm.subtract(_margemDeRenovacao);
    if (DateTime.now().toUtc().isBefore(limite)) {
      return;
    }
    try {
      final bool renovada = await _renovarSessao();
      if (!renovada) {
        _expirarSessao();
      }
    } on ApiException catch (erro) {
      _log.warning('Renovacao antecipada da sessao falhou', error: erro);
    }
  }

  /// Uma renovacao por vez: chamadas simultaneas esperam a mesma resposta.
  /// Isso importa porque o refresh token e de uso unico — duas renovacoes
  /// paralelas revogariam uma a outra.
  Future<bool> _renovarSessao() {
    return _renovacaoEmAndamento ??=
        _executarRenovacao().whenComplete(() => _renovacaoEmAndamento = null);
  }

  /// `true` quando renovou, `false` quando o servidor recusou o refresh token
  /// (a sessao acabou). Falha de rede ou 5xx lanca [ApiException], porque ali
  /// nao se sabe se a sessao ainda vale e o usuario nao deve ser deslogado.
  Future<bool> _executarRenovacao() async {
    final String? atual = refreshToken;
    if (atual == null) {
      return false;
    }
    try {
      final Response<dynamic> resposta = await _dioDeRenovacao.post<dynamic>(
        Endpoints.refreshToken,
        data: <String, dynamic>{'refreshToken': atual},
      );
      final dynamic corpo = resposta.data;
      if (corpo is! Map<String, dynamic>) {
        return false;
      }
      await guardarSessao(
        accessToken: corpo['accessToken'] as String,
        refreshToken: corpo['refreshToken'] as String,
        accessTokenExpiraEm:
            DateTime.parse(corpo['accessTokenExpiraEm'] as String),
      );
      return true;
    } on DioException catch (erro) {
      final int? status = erro.response?.statusCode;
      if (status != null && status >= 400 && status < 500) {
        return false;
      }
      throw ApiException.deDio(erro);
    }
  }

  void _expirarSessao() {
    _log.info('Sessao expirada: refresh token recusado');
    _acaoDeSessaoExpirada?.call();
  }

  dynamic _corpoDe(Response<dynamic> resposta) {
    final dynamic corpo = resposta.data;
    if (corpo is String && corpo.isEmpty) {
      return null;
    }
    return corpo;
  }

  void _registrar(
    HttpMethod method,
    String path,
    int? status,
    Stopwatch cronometro,
  ) {
    _log.debug(
      '${method.valor} $path -> ${status ?? 'sem resposta'} '
      '(${cronometro.elapsedMilliseconds} ms)',
    );
  }
}
