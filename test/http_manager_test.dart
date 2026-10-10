import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:ds_fitness/src/core/exceptions/api_exception.dart';
import 'package:ds_fitness/src/core/services/http_manager.dart';
import 'package:ds_fitness/src/enum/http_method.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fakes.dart';

/// Servidor falso: cada chamada passa pelo [resposta], que devolve o status e
/// o corpo, e fica registrada em [chamadas] para o teste conferir.
class _AdapterFake implements HttpClientAdapter {
  _AdapterFake(this.resposta);

  final FutureOr<({int status, Object? corpo})> Function(
    RequestOptions requisicao,
  ) resposta;
  final List<RequestOptions> chamadas = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    chamadas.add(options);
    final ({int status, Object? corpo}) saida = await resposta(options);
    return ResponseBody.fromString(
      saida.corpo == null ? '' : jsonEncode(saida.corpo),
      saida.status,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

const String _refresh = '/api/v1/autenticacao/login/refresh-token';

({int status, Object? corpo}) _renovado() => (
      status: 200,
      corpo: <String, dynamic>{
        'accessToken': 'novo-access',
        'accessTokenExpiraEm':
            DateTime.now().toUtc().add(const Duration(minutes: 5)).toIso8601String(),
        'refreshToken': 'novo-refresh',
        'refreshTokenExpiraEm':
            DateTime.now().toUtc().add(const Duration(hours: 2)).toIso8601String(),
      },
    );

void main() {
  late StorageFake storage;
  late _AdapterFake servidor;
  late HttpManager http;
  var sessaoExpirada = 0;

  HttpManager criar(_AdapterFake adapter) {
    final Dio dio = Dio(BaseOptions(baseUrl: 'http://api.teste'))
      ..httpClientAdapter = adapter;
    final Dio dioDeRenovacao = Dio(BaseOptions(baseUrl: 'http://api.teste'))
      ..httpClientAdapter = adapter;
    return HttpManager(
      storage: storage,
      log: LogFake(),
      dio: dio,
      dioDeRenovacao: dioDeRenovacao,
    )..aoExpirarSessao(() => sessaoExpirada++);
  }

  Future<void> logar({Duration validade = const Duration(minutes: 5)}) {
    return http.guardarSessao(
      accessToken: 'access-antigo',
      refreshToken: 'refresh-antigo',
      accessTokenExpiraEm: DateTime.now().toUtc().add(validade),
    );
  }

  setUp(() {
    storage = StorageFake();
    sessaoExpirada = 0;
  });

  group('HttpManager', () {
    test('envia o access token no header Authorization', () async {
      servidor = _AdapterFake((_) => (status: 200, corpo: <String, dynamic>{'ok': true}));
      http = criar(servidor);
      await logar();

      final dynamic corpo = await http.restRequest(
        path: '/api/v1/treinos',
        method: HttpMethod.get,
      );

      expect(corpo, <String, dynamic>{'ok': true});
      expect(servidor.chamadas.single.headers['Authorization'], 'Bearer access-antigo');
    });

    test('chamada sem autenticacao nao envia token', () async {
      servidor = _AdapterFake((_) => (status: 200, corpo: <String, dynamic>{}));
      http = criar(servidor);
      await logar();

      await http.restRequest(
        path: '/api/v1/autenticacao/login',
        method: HttpMethod.post,
        body: <String, dynamic>{'login': 'a'},
        autenticado: false,
      );

      expect(servidor.chamadas.single.headers.containsKey('Authorization'), isFalse);
    });

    test('resposta 204 sem corpo devolve null', () async {
      servidor = _AdapterFake((_) => (status: 204, corpo: null));
      http = criar(servidor);
      await logar();

      final dynamic corpo = await http.restRequest(
        path: '/api/v1/treinos/do-dia',
        method: HttpMethod.get,
      );

      expect(corpo, isNull);
    });

    test('401 renova a sessao e repete a chamada com o token novo', () async {
      servidor = _AdapterFake((RequestOptions r) {
        if (r.path == _refresh) {
          return _renovado();
        }
        final bool tokenNovo = r.headers['Authorization'] == 'Bearer novo-access';
        return tokenNovo
            ? (status: 200, corpo: <String, dynamic>{'ok': true})
            : (status: 401, corpo: null);
      });
      http = criar(servidor);
      await logar();

      final dynamic corpo = await http.restRequest(
        path: '/api/v1/treinos',
        method: HttpMethod.get,
      );

      expect(corpo, <String, dynamic>{'ok': true});
      expect(servidor.chamadas.map((RequestOptions r) => r.path).toList(), <String>[
        '/api/v1/treinos',
        _refresh,
        '/api/v1/treinos',
      ]);
      expect(http.refreshToken, 'novo-refresh', reason: 'o refresh token gira a cada uso');
      expect(sessaoExpirada, 0);
    });

    test('varias chamadas com 401 ao mesmo tempo renovam uma unica vez', () async {
      servidor = _AdapterFake((RequestOptions r) async {
        if (r.path == _refresh) {
          await Future<void>.delayed(const Duration(milliseconds: 30));
          return _renovado();
        }
        final bool tokenNovo = r.headers['Authorization'] == 'Bearer novo-access';
        return tokenNovo
            ? (status: 200, corpo: <String, dynamic>{'ok': true})
            : (status: 401, corpo: null);
      });
      http = criar(servidor);
      await logar();

      await Future.wait(<Future<dynamic>>[
        http.restRequest(path: '/api/v1/a', method: HttpMethod.get),
        http.restRequest(path: '/api/v1/b', method: HttpMethod.get),
        http.restRequest(path: '/api/v1/c', method: HttpMethod.get),
      ]);

      final int renovacoes =
          servidor.chamadas.where((RequestOptions r) => r.path == _refresh).length;
      expect(renovacoes, 1, reason: 'o refresh token e de uso unico');
    });

    test('refresh recusado expira a sessao e lanca 401', () async {
      servidor = _AdapterFake((RequestOptions r) {
        return r.path == _refresh
            ? (status: 401, corpo: <String, dynamic>{'error': 'Refresh token revogado.'})
            : (status: 401, corpo: null);
      });
      http = criar(servidor);
      await logar();

      await expectLater(
        http.restRequest(path: '/api/v1/treinos', method: HttpMethod.get),
        throwsA(
          isA<ApiException>().having(
            (ApiException e) => e.ehNaoAutenticado,
            'ehNaoAutenticado',
            isTrue,
          ),
        ),
      );
      expect(sessaoExpirada, 1);
    });

    test('falha de rede ao renovar nao derruba a sessao', () async {
      servidor = _AdapterFake((RequestOptions r) {
        if (r.path == _refresh) {
          throw DioException(
            requestOptions: r,
            type: DioExceptionType.connectionError,
          );
        }
        return (status: 401, corpo: null);
      });
      http = criar(servidor);
      await logar();

      await expectLater(
        http.restRequest(path: '/api/v1/treinos', method: HttpMethod.get),
        throwsA(
          isA<ApiException>().having(
            (ApiException e) => e.tipo,
            'tipo',
            ApiErrorType.semConexao,
          ),
        ),
      );
      expect(sessaoExpirada, 0, reason: 'sem rede nao se sabe se a sessao ainda vale');
      expect(http.refreshToken, 'refresh-antigo');
    });

    test('renova antes de enviar quando o token ja venceu', () async {
      servidor = _AdapterFake((RequestOptions r) {
        return r.path == _refresh
            ? _renovado()
            : (status: 200, corpo: <String, dynamic>{'ok': true});
      });
      http = criar(servidor);
      await logar(validade: const Duration(seconds: -10));

      await http.restRequest(path: '/api/v1/treinos', method: HttpMethod.get);

      expect(servidor.chamadas.first.path, _refresh);
      expect(servidor.chamadas.last.headers['Authorization'], 'Bearer novo-access');
    });
  });

  group('ApiException', () {
    DioException resposta(int status, Object? corpo) {
      final RequestOptions req = RequestOptions(path: '/x');
      return DioException(
        requestOptions: req,
        type: DioExceptionType.badResponse,
        response: Response<dynamic>(
          requestOptions: req,
          statusCode: status,
          data: corpo,
        ),
      );
    }

    test('400 de validacao junta as mensagens por campo', () {
      final ApiException erro = ApiException.deDio(
        resposta(400, <String, dynamic>{
          'error': 'One or more validation failures have occurred.',
          'errors': <String>['Informe o nome.', 'Informe o grupo.'],
        }),
      );

      expect(erro.tipo, ApiErrorType.validacao);
      expect(erro.mensagem, 'Informe o nome.\nInforme o grupo.');
    });

    test('409 usa a mensagem do servidor', () {
      final ApiException erro = ApiException.deDio(
        resposta(409, <String, dynamic>{'error': 'Já existe um exercício com este nome.'}),
      );

      expect(erro.tipo, ApiErrorType.conflito);
      expect(erro.mensagem, 'Já existe um exercício com este nome.');
    });

    test('404 sem corpo cai na mensagem padrao', () {
      final ApiException erro = ApiException.deDio(resposta(404, null));

      expect(erro.ehNaoEncontrado, isTrue);
      expect(erro.mensagem, 'Registro não encontrado.');
    });

    test('sem conexao e tempo esgotado tem tipos proprios', () {
      final RequestOptions req = RequestOptions(path: '/x');

      expect(
        ApiException.deDio(
          DioException(requestOptions: req, type: DioExceptionType.connectionError),
        ).tipo,
        ApiErrorType.semConexao,
      );
      expect(
        ApiException.deDio(
          DioException(requestOptions: req, type: DioExceptionType.receiveTimeout),
        ).tipo,
        ApiErrorType.tempoEsgotado,
      );
    });
  });
}
