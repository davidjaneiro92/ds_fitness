# Configuração de API / HTTP

> **Escopo T3 — Infraestrutura Técnica**
> Documento gerado por engenharia reversa do projeto `controle_separacao_aplicativo`.
> Não contém regras de negócio.

---

## 1. Visão Geral da Camada HTTP

O projeto utiliza o pacote **Dio 5.8.0+1** como cliente HTTP (versão resolvida no lock; declarada como `^5.7.0`), encapsulado em uma classe `HttpManager` que implementa a interface `HttpManagerInterfaces`. Toda comunicação com a API REST passa por esse único ponto de entrada (`restRequest`).

---

## 2. Interface do HttpManager

**Arquivo:** `lib/src/core/abstracts/http_manager_interfaces.dart`

```dart
abstract class HttpManagerInterfaces {
  Future<Response> restRequest({
    required String url,
    required String method,
    Map? headers,
    Map? body,
  });
}
```

A abstração é correta e permite injeção de dependência via GetX (`Get.find()`). Os repositórios dependem apenas da interface, nunca da implementação concreta.

---

## 3. Implementação — HttpManager

**Arquivo:** `lib/src/core/services/http_manager.dart`

### 3.1 Inicialização do Dio e SSL

```dart
class HttpManager implements HttpManagerInterfaces {
  Dio dio = Dio();
  HttpManager() {
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      client.badCertificateCallback = (cert, host, port) => true; // ⚠️ RISCO
      return client;
    };
    // LogInterceptor comentado — inativo em produção
  }
}
```

**Problemas identificados:**
- `badCertificateCallback = true` desativa toda validação de certificado SSL/TLS, expondo o app a ataques MITM.
- O `LogInterceptor` está comentado: em desenvolvimento não há logs; em produção há `print()` soltos.
- Nenhum timeout configurado (connectTimeout, receiveTimeout, sendTimeout).

### 3.2 Método restRequest — Fluxo Completo

```dart
Future<Response> restRequest({
  required String url,
  required String method,
  Map? headers,
  Map? body,
}) async {
  try {
    String authorization = await token();           // 1. Lê token do Hive
    final defaulHeaders = headers?.cast<String, String>() ?? {}
      ..addAll({
        'content-type': 'application/json',
        'accept': 'application/json',
        if (authorization.isNotEmpty) 'Authorization': 'Bearer $authorization',
        ...?headers?.cast<String, String>(),        // 2. Merge de headers customizados
      });

    Response response = await dio.request(
      url,
      options: Options(headers: defaulHeaders, method: method),
      data: body,
    );
    return response;

  } on DioException catch (error) {
    if (error.response?.statusCode == 401) {
      bool refreshed = await _tryRefreshToken();    // 3. Tenta refresh
      if (refreshed) {
        return await restRequest(...);              // 4. Retry automático
      } else {
        signOut();                                  // 5. Desloga via GetX
        customAlertMessage(...);                    // 6. Exibe UI (acoplamento!)
        throw Exception("Sessão expirada...");
      }
    }
    // 7. Outros erros Dio → exibe UI (acoplamento!)
    customAlertMessage(title: "Atenção", message: errorMessage);
    return error.response ?? Response(requestOptions: ...);
  }
}
```

### 3.3 Recuperação de Token (função global)

```dart
Future<String> token() async {
  final HiveServicesInterface hiveServices = Get.find();
  var json = await hiveServices.getCache(nameFild: 'Autenticacao');
  if (json != null) {
    var obj = jsonDecode(json);
    return obj['accessToken'];
  }
  return '';
}
```

**Problema:** função global (fora da classe), não injetável, acoplada ao GetX.

### 3.4 Refresh Token

```dart
Future<bool> _tryRefreshToken() async {
  try {
    return await login.Refreshtoken();  // instância global LoginRepository
  } catch (e) {
    return false;
  }
}
```

**Problema:** `LoginRepository login = LoginRepository()` é uma instância global criada fora do ciclo de vida do GetX, quebrando a inversão de dependência.

### 3.5 Sign Out

```dart
Future<void> signOut() async {
  final HiveServicesInterface hiveServices = Get.find();
  hiveServices.deleteCache(nameFild: 'Autenticacao');
  Get.offAllNamed(PagesRoutes.login.path);  // ⚠️ Navega pela UI de dentro do serviço
}
```

**Problema grave:** a camada de serviço HTTP executa navegação diretamente via GetX router.

---

## 4. Tratamento de Erros — _handleDioError

**Arquivo:** `lib/src/core/services/http_manager.dart` (linhas 96–115)

| DioExceptionType | Mensagem retornada |
|---|---|
| `connectionTimeout` | "Tempo limite de conexão excedido." |
| `sendTimeout` | "Tempo limite ao enviar a solicitação." |
| `receiveTimeout` | "Tempo limite ao receber resposta." |
| `badResponse` | "Resposta inválida do servidor (statusCode)." |
| `cancel` | "Solicitação cancelada." |
| `connectionError` | "Falha na conexão com a internet ou o servidor não responde." |
| `unknown` | "Erro inesperado: message." |

O mapeamento cobre todos os tipos do Dio 5.x. O problema é que as mensagens são exibidas diretamente via `customAlertMessage()` dentro do serviço HTTP, misturando responsabilidades de transporte e apresentação.

---

## 5. Enum de Métodos HTTP

**Arquivo:** `lib/src/enum/http_methods.dart`

```dart
abstract class HttpMethods {
  static const post   = 'POST';
  static const put    = 'PUT';
  static const patch  = 'PATCH';
  static const delete = 'DELETE';
  static const get    = 'GET';
}
```

Simples e funcional. Uso nos repositórios: `method: HttpMethods.get`.

---

## 6. Gestão de Endpoints

**Arquivo:** `lib/src/constants/Endpoints.dart`

### 6.1 Como funciona

```dart
String? baseUrl = 'http://192.168.1.192:7021';  // IP hardcoded como fallback

Future<void> initializeApp() async {
  baseUrl = await repository.getBaseUrl();       // Lê do Hive (box 'variaves_ambiente')
}

abstract class Endpoints {
  static String get login         => '${baseUrl}/api/v1/autenticacao/login';
  static String get refreshToken  => '${baseUrl}/api/v1/autenticacao/login/refresh-token';
  static String get pedidoVenda   => '${baseUrl}/api/v1/faturamento/pedido-venda';
  // ... mais 12 endpoints
}
```

### 6.2 Endpoints mapeados

| Getter | Path |
|---|---|
| `login` | `/api/v1/autenticacao/login` |
| `refreshToken` | `/api/v1/autenticacao/login/refresh-token` |
| `grupoAlmoxarifado` | `/api/v1/grupo-almoxarifado` |
| `recebimentoCompraNF` | `/api/v1/recebimento-de-compra/notas-fiscais` |
| `pedidoVenda` | `/api/v1/faturamento/pedido-venda` |
| `pedidoVendaEstagio` | `/api/v1/faturamento/pedido-venda/estagio` |
| `logErrosAplicativo` | `/api/v1/log-erros-aplicativo` |
| `logOperacoes` | `/api/v2/log-operacoes` |
| `itemPedidoVenda` | `/api/v1/faturamento/item-pedido-venda` |
| `notasFiscaisPagas` | `/api/v1/recebimento-de-compra/notas-fiscais/pagas` |
| `notaCompraLotes` | `/api/v1/recebimento-de-compra/nota-compra-lotes` |
| `notaCompraLotesEtiquetas` | `/api/v1/recebimento-de-compra/nota-compra-lotes/etiquetas` |
| `imprimirEtiquetas` | `/api/v1/impressao/etiqueta` |
| `buscarProduto` | `/api/v1/produto-almoxarifado` |
| `empresa` | `/api/v1/empresa-cadastro` |
| `transferenciaNotaLote` | `/api/v1/recebimento-de-compra/transferencia-nota-lote/mov-lote` |
| `transferenciaLote` | `/api/v1/recebimento-de-compra/transferencia-nota-lote` |

### 6.3 Problemas

- IP `192.168.1.192` hardcoded como fallback — se o Hive estiver vazio, o app vai apontar para uma rede local específica.
- Sem distinção entre ambientes (dev / homologação / produção).
- `baseUrl` é uma variável global mutável (`String?`) — sem thread-safety.
- `initializeApp()` precisa ser chamado no bootstrap; se não for, usa o IP hardcoded silenciosamente.
- `grupoAlmox` e `grupoAlmoxarifado` apontam para o mesmo path — duplicata.

---

## 7. Como os Repositórios Usam o HttpManager

**Exemplo:** `lib/src/core/features/nfs_pedidos/repository/nfs_pedidos_repository.dart`

```dart
class NfsPedidosRepository implements NfsPedidosRepositoryInterface {
  final HttpManagerInterfaces _httpManager = Get.find();

  Future<List<NfModel>> getRecebimentoCompraNF() async {
    final result = await _httpManager.restRequest(
      url: Endpoints.recebimentoCompraNF + '?dhEntradaIni=2024-11-01&...',
      method: HttpMethods.get,
    );
    if (result.statusCode == 200) {
      return List<Map<String, dynamic>>.from(result.data['data'])
          .map((json) => NfModel.fromJson(json))
          .toList();
    }
    return [];
  }
}
```

**Padrão observado em todos os repositórios:**
1. Injeção via `Get.find<HttpManagerInterfaces>()`
2. Chamada direta ao `restRequest` com URL concatenada manualmente (query params inline como string)
3. Verificação de `statusCode == 200` (nunca trata 201, 204, etc.)
4. Retorna lista vazia em caso de erro (falha silenciosa — sem propagação de erro ao caller)
5. Acesso ao Hive dentro do repositório para ler dados de sessão (ex.: `setor`) — lógica duplicada

---

## 8. Problemas e Dívidas Técnicas

| # | Problema | Impacto | Classificação |
|---|---|---|---|
| P1 | `badCertificateCallback = true` — SSL desativado | Crítico (segurança) | 🔴 |
| P2 | `HttpManager` chama `customAlertMessage()` — acoplamento com UI | Alto (testabilidade) | 🔴 |
| P3 | `signOut()` chama `Get.offAllNamed()` — serviço navega pela UI | Alto (separação de camadas) | 🔴 |
| P4 | Sem timeouts (connectTimeout / receiveTimeout) | Médio (UX, produção) | 🟠 |
| P5 | `LogInterceptor` comentado — sem logs estruturados | Médio (debug/observabilidade) | 🟡 |
| P6 | Sem cancelamento de requests (`CancelToken`) | Médio (memory leaks) | 🟡 |
| P7 | `baseUrl` hardcoded com IP de rede local | Alto (ambiente) | 🔴 |
| P8 | Sem distinção de ambientes (dev/homol/prod) | Alto (deploy) | 🟠 |
| P9 | `LoginRepository login = LoginRepository()` global no http_manager | Alto (IoC quebrado) | 🔴 |
| P10 | Repositórios retornam lista vazia em erro (falha silenciosa) | Médio (confiabilidade) | 🟡 |
| P11 | Query params concatenados como string bruta | Baixo (legibilidade) | 🟡 |
| P12 | Duplicata de endpoint (`grupoAlmox` == `grupoAlmoxarifado`) | Baixo | 🟡 |

---

## 9. Classificação para o Template Moderno

| Componente | Classificação | Justificativa |
|---|---|---|
| Interface `HttpManagerInterfaces` | 🟢 Reutilizar com melhorias | Contrato correto; retorno `Response` acopla ao Dio — refatorar internamente sem trocar biblioteca |
| Enum `HttpMethods` | ✅ Reutilizar sem alterações | Simples, correto, sem acoplamento |
| Classe `HttpManager` (estrutura) | 🟡 Refatorar | Manter padrão wrapper + interface, mas extrair UI/navegação, adicionar interceptors e timeouts |
| Lógica SSL bypass | 🔴 Descartar | Risco de segurança; usar certificados válidos ou pinning adequado |
| Lógica de refresh token (conceito) | 🟢 Reutilizar com melhorias | Mover para `Interceptor` estruturado do Dio |
| `signOut` navegando pela UI | 🔴 Descartar | Usar EventBus ou stream para notificar a UI; nunca navegar da camada de serviço |
| Classe `Endpoints` (padrão getter) | 🟡 Refatorar | Boa ideia, mas eliminar global mutável; usar `AppConfig` injetável por ambiente |
| Query params concatenados | 🟠 Substituir | Usar `queryParameters` do próprio Dio (mesma lib) |

---

## 10. Direção para o Template Moderno

### 10.1 Stack (preservar Dio — direção atual)

```
Dio 5.8.0+1
  ├── AuthInterceptor     (injeta Bearer token automaticamente)
  ├── RefreshInterceptor  (retry + refresh + emit signOut event)
  ├── LogInterceptor      (ativo em debug, desativado em release)
  └── ErrorInterceptor    (mapeia DioException → tipo de erro interno, sem tocar UI)
```

Melhorias internas aplicáveis **sem novas bibliotecas**: mover lógica de UI para fora do `HttpManager`, usar `dart-define` para `baseUrl` por ambiente, ativar timeouts.

> ⚠️ **Consideração futura (NÃO aplicar agora).** A direção atual é preservar a stack (ver [documentation-stance](../00-overview/documentation-stance.md)). O conteúdo abaixo é apenas conhecimento técnico para decisão futura.

Alternativas técnicas futuras que poderiam complementar o Dio:

```
# Alternativas futuras (não aplicar agora)
Retrofit (retrofit_generator)  →  type-safe, query params declarativos
Result / Either (fpdart)       →  retorno explícito de erros sem exceções
flutter_dotenv                 →  gestão de variáveis de ambiente via .env
```

### 10.2 Estrutura de Interceptors

```dart
// AuthInterceptor — substitui token() global
class AuthInterceptor extends Interceptor {
  final TokenRepository _tokenRepo;
  AuthInterceptor(this._tokenRepo);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _tokenRepo.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}

// RefreshInterceptor — substitui lógica inline no restRequest
class RefreshInterceptor extends QueuedInterceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final refreshed = await _tryRefresh();
      if (refreshed) {
        handler.resolve(await _retry(err.requestOptions));
        return;
      }
      _authEventBus.emit(AuthEvent.sessionExpired); // UI reage ao evento
    }
    handler.next(err);
  }
}
```

### 10.3 Configuração Dio com Timeouts

```dart
Dio buildDio(AppConfig config) => Dio(BaseOptions(
  baseUrl: config.apiBaseUrl,
  connectTimeout: const Duration(seconds: 10),
  receiveTimeout: const Duration(seconds: 30),
  sendTimeout: const Duration(seconds: 15),
  headers: {'content-type': 'application/json', 'accept': 'application/json'},
))
  ..interceptors.addAll([
    AuthInterceptor(tokenRepo),
    RefreshInterceptor(authRepo, eventBus),
    if (kDebugMode) LogInterceptor(requestBody: true, responseBody: true),
    ErrorInterceptor(),
  ]);
```

### 10.4 Gestão de Ambientes (baseUrl)

```dart
// Exemplo com --dart-define
class AppConfig {
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.dev.exemplo.com',
  );
}
// Build: flutter build apk --dart-define=API_BASE_URL=https://api.prod.exemplo.com
```

---

## 11. Referências de Arquivos

| Arquivo | Papel |
|---|---|
| `lib/src/core/services/http_manager.dart` | Implementação principal — Dio, restRequest, refresh, signOut |
| `lib/src/core/abstracts/http_manager_interfaces.dart` | Contrato da camada HTTP |
| `lib/src/constants/Endpoints.dart` | Constantes de URL com baseUrl dinâmica |
| `lib/src/enum/http_methods.dart` | Constantes dos verbos HTTP |
| `lib/src/core/features/login/repository/login_repository.dart` | Uso do HttpManager + refresh token |
| `lib/src/core/features/nfs_pedidos/repository/nfs_pedidos_repository.dart` | Padrão típico de repositório |
| `lib/src/core/features/settings_app/repository/settings_app_repository.dart` | Persistência da baseUrl no Hive |
