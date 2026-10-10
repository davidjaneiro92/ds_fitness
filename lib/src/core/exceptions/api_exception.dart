import 'package:dio/dio.dart';

/// Categoria do erro, para a UI decidir a mensagem sem inspecionar status.
enum ApiErrorType {
  /// Sem rede ou servidor fora do ar.
  semConexao,

  /// O servidor nao respondeu a tempo.
  tempoEsgotado,

  /// 401 — credenciais invalidas ou sessao expirada.
  naoAutenticado,

  /// 403 — autenticado, mas sem permissao para a operacao.
  semPermissao,

  /// 404 — recurso inexistente (ou de outro usuario).
  naoEncontrado,

  /// 409 — conflito (ex.: nome ja em uso).
  conflito,

  /// 400 — dado invalido; [ApiException.erros] traz o detalhe por campo.
  validacao,

  /// 5xx ou qualquer resposta inesperada.
  servidor,
}

/// Erro de comunicacao com a API (specs/02-infrastructure/error-handling.md).
///
/// O `HttpManager` converte toda falha de rede ou resposta nao-2xx nesta
/// excecao: quem chama nunca precisa conhecer `DioException`, e a UI nunca
/// e acionada de dentro da camada HTTP.
class ApiException implements Exception {
  const ApiException({
    required this.tipo,
    required this.mensagem,
    this.statusCode,
    this.erros = const <String>[],
  });

  /// Traduz uma [DioException] usando o corpo `{ error, errors[] }` que o
  /// backend devolve (`ExceptionHandlingMiddleware`).
  factory ApiException.deDio(DioException erro) {
    switch (erro.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return const ApiException(
          tipo: ApiErrorType.tempoEsgotado,
          mensagem: 'O servidor demorou para responder. Tente novamente.',
        );
      case DioExceptionType.connectionError:
        return const ApiException(
          tipo: ApiErrorType.semConexao,
          mensagem: 'Não foi possível conectar ao servidor. '
              'Verifique sua internet.',
        );
      case DioExceptionType.badResponse:
        return ApiException._deResposta(erro.response);
      case DioExceptionType.badCertificate:
      case DioExceptionType.cancel:
      case DioExceptionType.unknown:
        return ApiException(
          tipo: ApiErrorType.servidor,
          mensagem: 'Não foi possível completar a solicitação.',
          statusCode: erro.response?.statusCode,
        );
    }
  }

  factory ApiException._deResposta(Response<dynamic>? resposta) {
    final int? status = resposta?.statusCode;
    final dynamic corpo = resposta?.data;

    String? mensagem;
    final List<String> erros = <String>[];
    if (corpo is Map<String, dynamic>) {
      final dynamic principal = corpo['error'];
      if (principal is String && principal.isNotEmpty) {
        mensagem = principal;
      }
      final dynamic detalhes = corpo['errors'];
      if (detalhes is List<dynamic>) {
        erros.addAll(detalhes.whereType<String>());
      }
    }

    final ApiErrorType tipo = _tipoDoStatus(status);
    // Validacao: o detalhe util esta em `errors`, e `error` e so o titulo
    // generico em ingles ("One or more validation failures...").
    final String texto = tipo == ApiErrorType.validacao && erros.isNotEmpty
        ? erros.join('\n')
        : (mensagem ?? _mensagemPadrao(tipo));

    return ApiException(
      tipo: tipo,
      mensagem: texto,
      statusCode: status,
      erros: erros,
    );
  }

  final ApiErrorType tipo;
  final String mensagem;
  final int? statusCode;
  final List<String> erros;

  bool get ehNaoAutenticado => tipo == ApiErrorType.naoAutenticado;

  bool get ehNaoEncontrado => tipo == ApiErrorType.naoEncontrado;

  static ApiErrorType _tipoDoStatus(int? status) {
    switch (status) {
      case 400:
        return ApiErrorType.validacao;
      case 401:
        return ApiErrorType.naoAutenticado;
      case 403:
        return ApiErrorType.semPermissao;
      case 404:
        return ApiErrorType.naoEncontrado;
      case 409:
        return ApiErrorType.conflito;
      default:
        return ApiErrorType.servidor;
    }
  }

  static String _mensagemPadrao(ApiErrorType tipo) {
    switch (tipo) {
      case ApiErrorType.naoAutenticado:
        return 'Sessão expirada. Entre novamente.';
      case ApiErrorType.semPermissao:
        return 'Você não tem permissão para esta operação.';
      case ApiErrorType.naoEncontrado:
        return 'Registro não encontrado.';
      case ApiErrorType.conflito:
        return 'Esta operação conflita com um registro existente.';
      case ApiErrorType.validacao:
        return 'Dados inválidos.';
      case ApiErrorType.semConexao:
      case ApiErrorType.tempoEsgotado:
      case ApiErrorType.servidor:
        return 'Ocorreu um erro inesperado. Tente novamente.';
    }
  }

  @override
  String toString() => 'ApiException($statusCode, $tipo): $mensagem';
}
