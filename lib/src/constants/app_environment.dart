import 'package:flutter/foundation.dart';

/// Configuracao de ambiente do app (specs/02-infrastructure/configuration.md).
///
/// A URL da API vem de `--dart-define=API_BASE_URL=...` e, quando ausente,
/// assume o servidor de desenvolvimento na maquina do dev:
///
/// * Android emulator enxerga o host em `10.0.2.2` (e nao em `localhost`);
/// * web, desktop e iOS simulator usam `localhost`.
///
/// Exemplo para aparelho fisico (mesma rede Wi-Fi do PC):
/// `flutter run --dart-define=API_BASE_URL=http://192.168.0.10:5270`
abstract class AppEnvironment {
  static const String _urlDefinida = String.fromEnvironment('API_BASE_URL');

  /// Porta HTTP da API no `launchSettings.json` do backend.
  static const int _portaDev = 5270;

  /// Versao da API, parte da rota (`/api/v1/...`).
  static const String versaoApi = 'v1';

  /// Endereco base da API, sem barra no final.
  static String get apiBaseUrl {
    if (_urlDefinida.isNotEmpty) {
      return _urlDefinida.endsWith('/')
          ? _urlDefinida.substring(0, _urlDefinida.length - 1)
          : _urlDefinida;
    }
    return 'http://$_hostDeDesenvolvimento:$_portaDev';
  }

  static String get _hostDeDesenvolvimento {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return '10.0.2.2';
    }
    return 'localhost';
  }
}
