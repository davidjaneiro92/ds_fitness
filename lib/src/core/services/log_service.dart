import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import '../abstracts/log_service_interface.dart';

/// Implementacao de [LogServiceInterface] sobre o pacote `logger`.
///
/// Em release o logger fica silencioso (nao ha backend remoto neste app).
class LogService implements LogServiceInterface {
  LogService()
      : _logger = Logger(
          filter: kReleaseMode ? ProductionFilter() : DevelopmentFilter(),
          printer: PrettyPrinter(
            methodCount: 0,
            errorMethodCount: 6,
            lineLength: 90,
            printEmojis: false,
          ),
        );

  final Logger _logger;

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
  }

  String _compose(String message, Object? data) =>
      data == null ? message : '$message | $data';
}
