import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import '../abstracts/error_reporter_interface.dart';
import '../abstracts/log_service_interface.dart';

/// Implementacao de [LogServiceInterface] sobre o pacote `logger`.
///
/// Em release o console fica silencioso. Todo `error` e toda falha de
/// requisicao tambem vao para o log remoto, via [ErrorReporterInterface].
class LogService implements LogServiceInterface {
  LogService({ErrorReporterInterface? reporter})
      : _reporter = reporter,
        _logger = Logger(
          filter: kReleaseMode ? ProductionFilter() : DevelopmentFilter(),
          printer: PrettyPrinter(
            methodCount: 0,
            errorMethodCount: 6,
            lineLength: 90,
            printEmojis: false,
          ),
        );

  final Logger _logger;
  final ErrorReporterInterface? _reporter;

  @override
  void debug(String message, {Object? data}) {
    _logger.d(_compose(message, data));
  }

  @override
  void info(String message, {Object? data}) {
    _logger.i(_compose(message, data));
  }

  @override
  void warning(String message, {Object? error}) {
    _logger.w(message, error: error);
  }

  @override
  void error(String message, {Object? error, StackTrace? stackTrace}) {
    _logger.e(message, error: error, stackTrace: stackTrace);
    _reporter?.registrar(
      ErroRegistrado(
        tipo: TipoDeErro.aplicativo,
        mensagem: error == null ? message : '$message: $error',
        detalhe: stackTrace?.toString(),
        contexto: message,
      ),
    );
  }

  @override
  void requisicaoFalhou({
    required String method,
    required String path,
    required String mensagem,
    int? status,
    int? duracaoMs,
    String? detalhe,
  }) {
    _reporter?.registrar(
      ErroRegistrado(
        tipo: TipoDeErro.requisicao,
        mensagem: mensagem,
        detalhe: detalhe,
        metodo: method,
        caminho: path,
        statusHttp: status,
        duracaoMs: duracaoMs,
      ),
    );
  }

  String _compose(String message, Object? data) =>
      data == null ? message : '$message | $data';
}
