import '../exceptions/api_exception.dart';

/// Texto de erro para o usuario a partir de qualquer excecao capturada.
///
/// `ApiException` ja traz a mensagem certa (rede, validacao, conflito...);
/// o resto vira um aviso generico, sem expor detalhe tecnico na tela.
abstract class ErrorMessages {
  static const String generica = 'Ocorreu um erro inesperado. Tente novamente.';

  static String de(Object erro) {
    if (erro is ApiException) {
      return erro.mensagem;
    }
    return generica;
  }
}
