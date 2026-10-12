import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:ds_fitness/src/core/abstracts/error_reporter_interface.dart';
import 'package:ds_fitness/src/core/abstracts/storage_service_interface.dart';
import 'package:ds_fitness/src/core/services/error_reporter.dart';
import 'package:flutter_test/flutter_test.dart';

class _StorageFake implements StorageServiceInterface {
  final Map<String, Object?> dados = <String, Object?>{};

  @override
  T? read<T>(String key) {
    final Object? valor = dados[key];
    return valor is T ? valor : null;
  }

  @override
  Future<void> write(String key, Object? value) async => dados[key] = value;

  @override
  Future<void> remove(String key) async => dados.remove(key);

  @override
  Future<void> clear() async => dados.clear();
}

class _AdapterFake implements HttpClientAdapter {
  _AdapterFake(this.status);

  int? status;
  final List<RequestOptions> chamadas = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    chamadas.add(options);
    if (status == null) {
      throw DioException.connectionError(
        requestOptions: options,
        reason: 'sem rede',
      );
    }
    return ResponseBody.fromString(
      '{}',
      status!,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

ErroRegistrado _erro([String mensagem = 'falhou']) =>
    ErroRegistrado(tipo: TipoDeErro.aplicativo, mensagem: mensagem);

Future<void> _aguardar() => Future<void>.delayed(const Duration(milliseconds: 50));

void main() {
  late _StorageFake storage;
  late _AdapterFake servidor;

  ErrorReporter criar() {
    final Dio dio = Dio(BaseOptions(baseUrl: 'http://api.teste'))
      ..httpClientAdapter = servidor;
    return ErrorReporter(storage: storage, dio: dio);
  }

  setUp(() => storage = _StorageFake());

  group('ErrorReporter', () {
    test('envia o erro para o log da API com plataforma e versao', () async {
      servidor = _AdapterFake(200);
      criar().registrar(_erro('boom'));
      await _aguardar();

      expect(servidor.chamadas, hasLength(1));
      final RequestOptions chamada = servidor.chamadas.single;
      expect(chamada.path, '/api/v1/log/erros');
      final Map<String, dynamic> corpo = chamada.data as Map<String, dynamic>;
      expect(corpo['tipo'], 'aplicativo');
      expect(corpo['mensagem'], 'boom');
      expect(corpo['plataforma'], isNotEmpty);
      expect(corpo['versaoApp'], isNotEmpty);
      expect(storage.dados[StorageKeys.logsPendentes], isNull);
    });

    test('sem resposta da API, o erro fica na fila e sai depois', () async {
      servidor = _AdapterFake(null);
      final ErrorReporter reporter = criar()..registrar(_erro());
      await _aguardar();

      final String guardado =
          storage.dados[StorageKeys.logsPendentes]! as String;
      expect(jsonDecode(guardado) as List<dynamic>, hasLength(1));

      servidor.status = 200;
      await reporter.reenviarPendentes();

      expect(storage.dados[StorageKeys.logsPendentes], isNull);
      expect(servidor.chamadas.last.data, isA<Map<String, dynamic>>());
    });

    test('a fila sobrevive a um reinicio do app', () async {
      servidor = _AdapterFake(null);
      criar().registrar(_erro('antes'));
      await _aguardar();

      servidor.status = 200;
      await criar().reenviarPendentes();

      final Map<String, dynamic> corpo =
          servidor.chamadas.last.data as Map<String, dynamic>;
      expect(corpo['mensagem'], 'antes');
    });

    test('erro recusado com 4xx e descartado, para nao travar a fila', () async {
      servidor = _AdapterFake(400);
      criar().registrar(_erro());
      await _aguardar();

      expect(storage.dados[StorageKeys.logsPendentes], isNull);
    });

    test('envia o token quando ha sessao', () async {
      servidor = _AdapterFake(200);
      storage.dados[StorageKeys.token] = 'abc';
      criar().registrar(_erro());
      await _aguardar();

      expect(servidor.chamadas.single.headers['Authorization'], 'Bearer abc');
    });
  });
}
