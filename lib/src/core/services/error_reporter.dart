import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../constants/app_environment.dart';
import '../../constants/endpoints.dart';
import '../abstracts/error_reporter_interface.dart';
import '../abstracts/storage_service_interface.dart';

/// Implementacao de [ErrorReporterInterface] sobre um Dio proprio.
///
/// O Dio e separado do `HttpManager` de proposito: o envio do log nao pode
/// renovar sessao, nem gerar outro log quando falha (seria um laco), e nunca
/// deve atrasar a chamada que deu erro.
class ErrorReporter implements ErrorReporterInterface {
  ErrorReporter({required StorageServiceInterface storage, Dio? dio})
      : _storage = storage,
        _dio = dio ?? _criarDio() {
    _fila.addAll(_lerFila());
  }

  static const int _limiteDaFila = 100;
  static const Duration _esperaAposFalha = Duration(seconds: 30);

  /// Versao enviada com o erro: `--dart-define=APP_VERSION=1.2.3`.
  static const String _versaoApp =
      String.fromEnvironment('APP_VERSION', defaultValue: '1.0.0');

  final StorageServiceInterface _storage;
  final Dio _dio;
  final List<ErroRegistrado> _fila = <ErroRegistrado>[];

  bool _enviando = false;
  DateTime? _proximaTentativa;

  static Dio _criarDio() {
    return Dio(
      BaseOptions(
        baseUrl: AppEnvironment.apiBaseUrl,
        connectTimeout: const Duration(seconds: 5),
        sendTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: <String, dynamic>{'Accept': 'application/json'},
      ),
    );
  }

  @override
  void registrar(ErroRegistrado erro) {
    _fila.add(erro);
    while (_fila.length > _limiteDaFila) {
      _fila.removeAt(0);
    }
    unawaited(_guardarFila());
    unawaited(_esvaziar());
  }

  @override
  Future<void> reenviarPendentes() {
    _proximaTentativa = null;
    return _esvaziar();
  }

  Future<void> _esvaziar() async {
    if (_enviando || _fila.isEmpty) {
      return;
    }
    final DateTime? espera = _proximaTentativa;
    if (espera != null && DateTime.now().isBefore(espera)) {
      return;
    }
    _enviando = true;
    try {
      while (_fila.isNotEmpty) {
        final bool seguir = await _enviar(_fila.first);
        if (!seguir) {
          _proximaTentativa = DateTime.now().add(_esperaAposFalha);
          break;
        }
        _fila.removeAt(0);
      }
    } finally {
      _enviando = false;
      await _guardarFila();
    }
  }

  /// `true` quando o erro saiu da fila: foi aceito, ou foi recusado por ser
  /// invalido (4xx) — reenviar nao adiantaria e travaria a fila. `false` para
  /// falha de rede ou 5xx, que merece nova tentativa.
  Future<bool> _enviar(ErroRegistrado erro) async {
    try {
      await _dio.post<dynamic>(
        Endpoints.logErros,
        data: <String, dynamic>{
          ...erro.paraJson(),
          'plataforma': _plataforma,
          'versaoApp': _versaoApp,
        },
        options: Options(headers: _cabecalhoDeSessao()),
      );
      return true;
    } on DioException catch (falha) {
      final int? status = falha.response?.statusCode;
      return status != null && status >= 400 && status < 500;
    } on Object {
      return false;
    }
  }

  /// Anexa o token, quando houver, so para o servidor saber de quem e o erro.
  Map<String, dynamic>? _cabecalhoDeSessao() {
    final String? token = _storage.read<String>(StorageKeys.token);
    return token == null
        ? null
        : <String, dynamic>{'Authorization': 'Bearer $token'};
  }

  String get _plataforma =>
      kIsWeb ? 'web' : defaultTargetPlatform.name.toLowerCase();

  List<ErroRegistrado> _lerFila() {
    try {
      final String? texto = _storage.read<String>(StorageKeys.logsPendentes);
      if (texto == null) {
        return <ErroRegistrado>[];
      }
      final List<dynamic> itens = jsonDecode(texto) as List<dynamic>;
      return itens
          .map((dynamic item) =>
              ErroRegistrado.deJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    } on Object {
      return <ErroRegistrado>[];
    }
  }

  Future<void> _guardarFila() async {
    try {
      if (_fila.isEmpty) {
        await _storage.remove(StorageKeys.logsPendentes);
        return;
      }
      await _storage.write(
        StorageKeys.logsPendentes,
        jsonEncode(_fila.map((ErroRegistrado e) => e.paraJson()).toList()),
      );
    } on Object {
      // O log nunca pode derrubar o app.
    }
  }
}
