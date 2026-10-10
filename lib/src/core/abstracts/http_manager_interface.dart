import '../../enum/http_method.dart';

/// Contrato do cliente HTTP (specs/02-infrastructure/api-configuration.md).
///
/// E o unico ponto de saida de rede do app: os repositories dependem desta
/// interface, nunca de `Dio`. Toda falha (rede, timeout, status nao-2xx) vira
/// `ApiException`.
abstract class HttpManagerInterface {
  /// Executa a requisicao e devolve o corpo ja decodificado (`Map`, `List`
  /// ou `null` para respostas sem corpo, como o 204).
  ///
  /// Com [autenticado], envia o access token e, se ele estiver vencido ou o
  /// servidor responder 401, renova a sessao e repete a chamada uma vez.
  Future<dynamic> restRequest({
    required String path,
    required HttpMethod method,
    Map<String, dynamic>? query,
    Object? body,
    bool autenticado = true,
  });

  /// Guarda o par de tokens recebido no login. O `HttpManager` e o dono do
  /// armazenamento dos tokens porque e ele quem os renova.
  Future<void> guardarSessao({
    required String accessToken,
    required String refreshToken,
    required DateTime accessTokenExpiraEm,
  });

  /// Apaga os tokens locais. Nao avisa o servidor: para isso existe o logoff.
  Future<void> limparSessao();

  /// Refresh token atual, ou `null` quando nao ha sessao.
  String? get refreshToken;

  /// Registra o que fazer quando a sessao nao pode mais ser renovada
  /// (refresh token expirado ou revogado). Quem registra decide a UI — o
  /// `HttpManager` nao navega nem mostra mensagem.
  void aoExpirarSessao(void Function() acao);
}
