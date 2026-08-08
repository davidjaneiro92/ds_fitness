# Autenticação e Tratamento de Requisições HTTP

**Projeto de origem:** `controle_separacao_aplicativo`
**Data de extração:** 2026-06-24
**Finalidade deste documento:** Preservação fiel do mecanismo de autenticação e do tratamento de requisições para reuso no Template Corporativo Flutter.
**Postura:** Documentar o que **existe e funciona em produção**. Stack preservada: Dio + Hive + GetX.

---

## Sumário

1. [Visão Geral da Estratégia](#1-visão-geral-da-estratégia)
2. [Arquitetura dos Arquivos Envolvidos](#2-arquitetura-dos-arquivos-envolvidos)
3. [Fluxo de Login](#3-fluxo-de-login)
4. [Armazenamento do Token no Hive](#4-armazenamento-do-token-no-hive)
5. [Injeção do Token em Cada Requisição](#5-injeção-do-token-em-cada-requisição)
6. [Fluxo de Refresh Token (renovação automática)](#6-fluxo-de-refresh-token-renovação-automática)
7. [Logout / signOut](#7-logout--signout)
8. [O "Interceptor" do Projeto — Padrão Adotado](#8-o-interceptor-do-projeto--padrão-adotado)
9. [Endpoints de Autenticação](#9-endpoints-de-autenticação)
10. [Interfaces e Contratos](#10-interfaces-e-contratos)
11. [Pontos Fortes para Reuso](#11-pontos-fortes-para-reuso)
12. [Achados de Segurança](#12-achados-de-segurança)
13. [Classificação de Preservação](#13-classificação-de-preservação)

---

## 1. Visão Geral da Estratégia

O projeto utiliza **autenticação baseada em Bearer Token (JWT ou similar)**, com renovação automática via **Refresh Token**, armazenamento local em **Hive** e transporte via header HTTP `Authorization`.

| Aspecto | Valor |
|---|---|
| Tipo de autenticação | Bearer Token (token no header HTTP) |
| Biblioteca HTTP | `dio` (+ `dio/io` para configuração de SSL) |
| Armazenamento local | `hive` — box `Cache_aplicativo`, chave `Autenticacao` |
| Gerenciamento de estado/DI | `get` (GetX) |
| Renovação de token | Refresh Token automático ao receber HTTP 401 |
| Logout por expiração | Automático quando o refresh falha |
| Interceptor Dio formal | **Não existe** — lógica embutida em `restRequest` |

---

## 2. Arquitetura dos Arquivos Envolvidos

```
lib/src/
├── constants/
│   └── Endpoints.dart                          ← URLs de autenticação (login, refresh-token)
├── models/
│   └── login_model.dart                        ← Modelo de credenciais (usuario, senha)
├── enum/
│   └── pages_routes.dart                       ← Rota '/login' para redirect no signOut
├── core/
│   ├── abstracts/
│   │   ├── http_manager_interfaces.dart        ← Contrato de HttpManager (restRequest)
│   │   └── Hive_services_interface.dart        ← Contrato de HiveServices (get/set/delete)
│   ├── services/
│   │   ├── http_manager.dart                   ← NÚCLEO: Dio, token(), _tryRefreshToken(), signOut()
│   │   └── Hive_services.dart                  ← Implementação Hive (box 'Cache_aplicativo')
│   └── features/login/
│       ├── abstracts/
│       │   ├── login_repository_interface.dart ← Contrato: login() + Refreshtoken()
│       │   └── login_controller_interface.dart ← Contrato: signIn() + loginSettings()
│       ├── repository/
│       │   └── login_repository.dart           ← Chamadas HTTP + persistência do token
│       ├── controller/
│       │   └── login_controller.dart           ← Lógica de UI + orquestração
│       └── view/
│           └── login.dart                      ← Tela de login (formulário + validação)
```

---

## 3. Fluxo de Login

### 3.1 Passo a Passo

1. O usuário preenche `usuario` e `senha` na tela `Login` (`login.dart`).
2. O `Form` valida os campos (ambos obrigatórios).
3. Ao confirmar (botão "Entrar" ou teclado), chama `controller.signIn(usuario, password)`.
4. `LoginController.signIn()` instancia `LoginModel` e delega para `repository.login(loginModel)`.
5. `LoginRepository.login()` serializa o modelo via `jsonDecode(jsonEncode(login))` e chama `_httpManager.restRequest()` com método **PATCH** para `Endpoints.login`.
6. A API responde com HTTP 200 e um JSON contendo (ao menos) o campo `accessToken`.
7. O repository serializa todo o body de resposta como string JSON e o grava no Hive: `hiveServices.setCache(nameFild: 'Autenticacao', values: jsonEncode(result.data))`.
8. `login()` retorna `true`; o controller navega para a rota principal (`PagesRoutes.nfsPedidos`).
9. Em caso de falha HTTP (não-200) ou exceção, `login()` retorna `false` e o controller não navega.

### 3.2 Diagrama — Fluxo de Login

```
┌─────────────────┐
│  Tela Login.dart│
│  (StatelessWidget│
│   + Form)       │
└────────┬────────┘
         │ usuarioController.text
         │ passwordController.text
         │ _formkey.currentState.validate()
         ▼
┌─────────────────────────────┐
│  LoginController.signIn()   │
│  (GetxController)           │
│  isLoading = true           │
│  LoginModel(usuario, senha) │
└────────────┬────────────────┘
             │ repository.login(loginModel)
             ▼
┌──────────────────────────────────────────┐
│  LoginRepository.login()                 │
│  jsonDecode(jsonEncode(loginModel))      │
│  _httpManager.restRequest(               │
│    url: Endpoints.login,                 │
│    method: HttpMethods.patch,            │
│    body: {...}                           │
│  )                                       │
└──────────────────┬───────────────────────┘
                   │ HTTP PATCH /api/v1/autenticacao/login
                   │ Body: { "usuario": "...", "senha": "..." }
                   ▼
          ┌─────────────────┐
          │   API REST      │
          └────────┬────────┘
                   │ HTTP 200 OK
                   │ { "accessToken": "...", ... }
                   ▼
┌──────────────────────────────────────────┐
│  LoginRepository (continuação)           │
│  hiveServices.setCache(                  │
│    nameFild: 'Autenticacao',             │
│    values: jsonEncode(result.data)       │
│  )  ← persiste TODO o body da resposta  │
│  return true                             │
└──────────────────┬───────────────────────┘
                   │ true
                   ▼
┌──────────────────────────────────────────┐
│  LoginController.signIn() (continuação)  │
│  Get.offNamed(PagesRoutes.nfsPedidos)    │
│  isLoading = false                       │
└──────────────────────────────────────────┘
```

### 3.3 Código-fonte do Fluxo de Login

**`login_repository.dart` — método `login()`:**
```dart
Future<bool> login(LoginModel login) async {
  final loadingController = Get.find<LoadingController>();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    loadingController.showLoading();
  });
  try {
    final result = await _httpManager.restRequest(
      url: Endpoints.login,
      method: HttpMethods.patch,
      body: jsonDecode(jsonEncode(login)),  // serializa LoginModel para Map
    );
    if (result.statusCode == 200) {
      hiveServices.setCache(
          nameFild: 'Autenticacao', values: jsonEncode(result.data));
      return true;
    } else {
      // log de erro
      return false;
    }
  } catch (e) {
    // log de exceção
    return false;
  } finally {
    loadingController.hideLoading();
  }
}
```

**`login_controller.dart` — método `signIn()`:**
```dart
Future<void> signIn({required String usuario, required String password}) async {
  isLoading.value = true;
  LoginModel login = LoginModel(usuario: usuario, senha: password);
  if (await repository.login(login)) {
    Get.offNamed(PagesRoutes.nfsPedidos.path);
  }
  isLoading.value = false;
}
```

---

## 4. Armazenamento do Token no Hive

### 4.1 Estrutura de Persistência

| Parâmetro | Valor |
|---|---|
| Box Hive aberta | `Cache_aplicativo` |
| Chave (`nameFild`) | `'Autenticacao'` |
| Tipo do valor armazenado | `String` (JSON serializado) |
| Serialização | `jsonEncode(result.data)` — todo o body da resposta da API |
| Campo de leitura do token | `obj['accessToken']` |

### 4.2 O Hive Box e a Implementação

O `HiveServices` opera sobre uma única box global chamada `Cache_aplicativo`:

```dart
// Hive_services.dart
class HiveServices implements HiveServicesInterface {
  final Box box = Hive.box('Cache_aplicativo');

  void setCache({required String nameFild, required dynamic values}) async {
    await box.put(nameFild, values);
  }

  Future<dynamic?> getCache({required String nameFild}) async {
    return await box.get(nameFild);
  }

  void deleteCache({required String nameFild}) async {
    await box.delete(nameFild);
  }

  void limparTodoCache() async {
    await box.clear();
  }
}
```

### 4.3 O que é Salvo e Como é Lido

**Escrita (no login — `LoginRepository`):**
```dart
// Todo o body da resposta é serializado como String JSON
hiveServices.setCache(
  nameFild: 'Autenticacao',
  values: jsonEncode(result.data),  // ex: '{"accessToken":"eyJ...","usuario":"joao"}'
);
```

**Leitura (em toda requisição — função `token()` em `http_manager.dart`):**
```dart
Future<String> token() async {
  final HiveServicesInterface hiveServices = Get.find();
  var json = await hiveServices.getCache(nameFild: 'Autenticacao');
  if (json != null) {
    var obj = jsonDecode(json);
    return obj['accessToken'];  // extrai apenas o accessToken
  } else {
    return '';  // sem token = requisição sem Authorization header
  }
}
```

**Escrita parcial (no refresh — `LoginRepository.Refreshtoken()`):**
```dart
// Atualiza apenas o accessToken, preserva demais campos do objeto
obj['accessToken'] = result.data['accessToken'];
hiveServices.setCache(
  nameFild: 'Autenticacao',
  values: jsonEncode(obj),
);
```

> **Nota importante:** Ao realizar o refresh, o código preserva o objeto completo (incluindo dados do usuário e outros campos retornados no login original) e apenas substitui o valor de `accessToken`. Isso é uma decisão de design intencional para manter dados de sessão sem re-executar o login completo.

---

## 5. Injeção do Token em Cada Requisição

O token é injetado automaticamente em **todas** as chamadas a `restRequest()`, sem necessidade de o chamador se preocupar com isso.

```dart
// http_manager.dart — dentro de restRequest()
Future<Response> restRequest({
  required String url,
  required String method,
  Map? headers,
  Map? body,
}) async {
  try {
    String authorization = await token();  // ← lê do Hive
    final defaulHeaders = headers?.cast<String, String>() ?? {}
      ..addAll({
        'content-type': 'application/json',
        'accept': 'application/json',
        if (authorization.isNotEmpty) 'Authorization': 'Bearer $authorization',
        ...?headers?.cast<String, String>(),
      });

    Response response = await dio.request(
      url,
      options: Options(
        headers: defaulHeaders,
        method: method,
      ),
      data: body,
    );
    return response;
  }
  // ...
}
```

### Comportamento de Injeção

| Situação | Comportamento |
|---|---|
| Token presente no Hive | Header `Authorization: Bearer <token>` adicionado |
| Token ausente (Hive vazio ou null) | `token()` retorna `''`; condição `if (authorization.isNotEmpty)` é `false`; header **não** é enviado |
| Headers customizados pelo chamador | Mesclados via spread (`...?headers?.cast<String, String>()`), com precedência dos customizados sobre os defaults |

---

## 6. Fluxo de Refresh Token (Renovação Automática)

### 6.1 Passo a Passo

1. `restRequest()` executa a chamada normalmente.
2. A API retorna HTTP **401 Unauthorized** (token expirado).
3. O bloco `on DioException` captura o erro e verifica `error.response?.statusCode == 401`.
4. Chama `_tryRefreshToken()` (função de nível de arquivo em `http_manager.dart`).
5. `_tryRefreshToken()` delega para `login.Refreshtoken()` (instância de `LoginRepository` também em nível de arquivo).
6. `LoginRepository.Refreshtoken()`:
   a. Lê o token expirado do Hive (chave `'Autenticacao'`, campo `accessToken`).
   b. Envia HTTP **PATCH** para `Endpoints.refreshToken` com body `{ "accessToken": "<token_expirado>" }`.
   c. Se HTTP 200: atualiza apenas `accessToken` no objeto do Hive e retorna `true`.
   d. Se não-200 ou exceção: retorna `false`.
7. **Se refresh bem-sucedido (`true`):** `restRequest()` se auto-chama recursivamente com os mesmos parâmetros (retry transparente).
8. **Se refresh falhou (`false`):** chama `signOut()`, exibe alerta "Sessão expirada" e lança exceção.

### 6.2 Diagrama — Fluxo de Refresh Token

```
restRequest(url, method, headers, body)
         │
         ▼
    HTTP request
         │
    ┌────┴────┐
    │ 401?    │
    └────┬────┘
         │ SIM
         ▼
_tryRefreshToken()
         │
         ▼
login.Refreshtoken()
  ┌──────────────────────────────────┐
  │ 1. Lê token expirado do Hive     │
  │ 2. PATCH /api/v1/.../refresh-token│
  │    body: { accessToken: "..." }  │
  └──────────────────────────────────┘
         │
    ┌────┴─────────────────┐
    │ HTTP 200?            │ HTTP não-200 / exceção
    └────┬─────────────────┘
         │ SIM              │ NÃO
         ▼                  ▼
  Atualiza Hive        return false
  (accessToken novo)        │
  return true               ▼
         │            signOut()
         ▼            ├── deleteCache('Autenticacao')
  RETRY restRequest() └── Get.offAllNamed('/login')
  (recursivo, mesmos       +
   parâmetros)        customAlertMessage("Sessão expirada...")
         │            + throw Exception(...)
         ▼
  Retorna Response
  (com novo token)
```

### 6.3 Código-fonte do Refresh

**Tratamento 401 em `restRequest()`:**
```dart
on DioException catch (error) {
  if (error.response?.statusCode == 401) {
    bool refreshed = await _tryRefreshToken();

    if (refreshed) {
      // RETRY transparente — a mesma chamada original é refeita
      return await restRequest(url: url, method: method, headers: headers, body: body);
    } else {
      signOut();
      customAlertMessage(title: "Atenção", message: "Sessão expirada, faça login novamente.");
      throw Exception("Sessão expirada, faça login novamente.");
    }
  }
  // outros erros...
}
```

**`_tryRefreshToken()` — função de arquivo:**
```dart
Future<bool> _tryRefreshToken() async {
  try {
    return await login.Refreshtoken();
  } catch (e) {
    print("Falha ao renovar o token: $e");
    return false;
  }
}
```

**`LoginRepository.Refreshtoken()`:**
```dart
Future<bool> Refreshtoken() async {
  try {
    var json = await hiveServices.getCache(nameFild: 'Autenticacao');
    var obj = jsonDecode(json);
    Map<String, dynamic> tokenVencido = {
      'accessToken': obj['accessToken']  // envia apenas o token expirado
    };
    final result = await _httpManager.restRequest(
      url: Endpoints.refreshToken,
      method: HttpMethods.patch,
      body: tokenVencido,
    );
    if (result.statusCode == 200) {
      obj['accessToken'] = result.data['accessToken'];  // atualiza apenas accessToken
      hiveServices.setCache(nameFild: 'Autenticacao', values: jsonEncode(obj));
      return true;
    } else {
      return false;
    }
  } catch (e) {
    return false;
  }
}
```

---

## 7. Logout / signOut

O `signOut()` é uma função de nível de arquivo em `http_manager.dart`, chamada automaticamente quando o refresh falha, ou potencialmente chamável de qualquer parte da aplicação via `import`.

```dart
// http_manager.dart
Future<void> signOut() async {
  final HiveServicesInterface hiveServices = Get.find();
  hiveServices.deleteCache(nameFild: 'Autenticacao');  // apaga token do Hive
  Get.offAllNamed(PagesRoutes.login.path);             // navega para login, limpa stack
}
```

| Ação | Detalhe |
|---|---|
| Limpeza de sessão | `deleteCache('Autenticacao')` — remove apenas a chave de autenticação |
| Navegação | `Get.offAllNamed('/login')` — remove **toda** a pilha de rotas |
| Cache geral | Demais chaves do Hive (`Cache_aplicativo`) **não** são apagadas no signOut |
| Trigger automático | Chamado por `restRequest()` quando `_tryRefreshToken()` retorna `false` |

> **Observação:** A função `HiveServices.limparTodoCache()` existe mas **não** é chamada no fluxo de signOut. Apenas a chave `'Autenticacao'` é removida. Dados de cache de outras features permanecem no dispositivo após o logout.

---

## 8. O "Interceptor" do Projeto — Padrão Adotado

### 8.1 Fato: Não Há Interceptor Dio Formal

O projeto **não utiliza o sistema de Interceptors do Dio** (`dio.interceptors.add(...)`). O único interceptor que existia, o `LogInterceptor`, está **comentado no código** e nunca é registrado em produção:

```dart
// http_manager.dart — trecho do construtor HttpManager()
//// Adiciona logs para depuração
//dio.interceptors.add(
//  LogInterceptor(
//    requestBody: true,
//    responseBody: true,
//    requestHeader: true,
//    responseHeader: false,
//    error: true,
//  ),
//);
```

### 8.2 Como a Lógica de "Interceptação" Funciona

Em vez do sistema de interceptors, toda a lógica de pré/pós-processamento das requisições está **embutida diretamente dentro do método `restRequest()`**, que atua como um ponto único de entrada para todas as chamadas HTTP da aplicação:

```
Antes da request:  token()         → injeta Authorization Bearer
Após a request:    catch 401       → tenta refresh → retry ou signOut
Após a request:    _handleDioError → mapeia tipos de erro para mensagens PT-BR
Após a request:    customAlertMessage → exibe alertas ao usuário
```

### 8.3 Comparação com o Padrão Dio Interceptor

| Aspecto | Padrão Interceptor Dio | Implementação do Projeto |
|---|---|---|
| Injeção de header | `onRequest` do interceptor | Início do `try` em `restRequest()` |
| Tratamento de 401 | `onError` do interceptor | `on DioException` em `restRequest()` |
| Retry após refresh | `handler.resolve()` no interceptor | Chamada recursiva de `restRequest()` |
| Separação de responsabilidades | Interceptors são classes isoladas | Tudo em um único método |
| Testabilidade | Interceptors são testáveis individualmente | Requer mock do `dio` inteiro |
| LogInterceptor | Disponível e ativo | Comentado — **desativado em produção** |

### 8.4 Justificativa para o Template Corporativo

Este padrão "interceptor embutido em `restRequest()`" é uma escolha de design **válida e funcional** para projetos de escopo controlado. O contrato de interface (`HttpManagerInterfaces`) garante que qualquer reimplementação — incluindo uma com interceptors formais — seja transparente para os consumidores.

---

## 9. Endpoints de Autenticação

```dart
// Endpoints.dart
String? baseUrl = 'http://192.168.1.192:7021';  // URL base (configurável em runtime)

abstract class Endpoints {
  static String get login =>
      '${baseUrl}/api/v1/autenticacao/login';
  static String get refreshToken =>
      '${baseUrl}/api/v1/autenticacao/login/refresh-token';
}
```

| Endpoint | Método HTTP | Uso |
|---|---|---|
| `/api/v1/autenticacao/login` | PATCH | Login inicial com credenciais |
| `/api/v1/autenticacao/login/refresh-token` | PATCH | Renovação do token expirado |

> **Detalhe de design:** Ambas as operações usam o método HTTP **PATCH**, não POST. Isso é uma convenção da API do backend, não do Flutter.

> **baseUrl dinâmica:** A `baseUrl` é uma variável de arquivo inicializada com um IP fixo de desenvolvimento (`192.168.1.192:7021`). Em produção, ela é sobrescrita por `initializeApp()` que busca a URL configurada via `SettingsAppRepository.getBaseUrl()`. Os getters de `Endpoints` são computados dinamicamente (não `const`), garantindo que a URL atualizada seja sempre utilizada.

---

## 10. Interfaces e Contratos

### 10.1 `HttpManagerInterfaces`

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

### 10.2 `HiveServicesInterface`

```dart
abstract class HiveServicesInterface {
  void setCache({required String nameFild, required dynamic values});
  Future<dynamic?> getCache({required String nameFild});
  void deleteCache({required String nameFild});
  void limparTodoCache();
}
```

### 10.3 `LoginRepositoryInterface`

```dart
abstract class LoginRepositoryInterface {
  Future<bool> login(LoginModel login);
  Future<bool> Refreshtoken();
}
```

### 10.4 `LoginControllerInterface`

```dart
abstract class LoginControllerInterface {
  RxBool isLoading = false.obs;
  Future<void> signIn({required String usuario, required String password});
  void loginSettings({required String usuario, required String senha, required BuildContext context});
}
```

Todos os componentes do sistema de autenticação dependem de **abstrações (interfaces)**, não de implementações concretas. Isso é o padrão de injeção de dependência do GetX (`Get.find<Interface>()`).

---

## 11. Pontos Fortes para Reuso

| # | Ponto Forte | Descrição |
|---|---|---|
| 1 | **Refresh automático e transparente** | Qualquer chamada HTTP que receba 401 terá o token renovado e será repetida sem nenhuma ação do chamador. O fluxo é completamente opaco para as camadas superiores (Controllers, Views). |
| 2 | **Contrato por interface** | `HttpManagerInterfaces`, `HiveServicesInterface` e `LoginRepositoryInterface` permitem substituição de implementações em testes ou em novas versões sem alterar os consumidores. |
| 3 | **Ponto único de entrada HTTP** | Todo tráfego passa por `restRequest()`. Não há chamadas diretas ao `dio` espalhadas pela aplicação, tornando manutenção e auditoria simples. |
| 4 | **Mapeamento de erros em PT-BR** | `_handleDioError()` traduz todos os tipos de `DioExceptionType` para mensagens amigáveis ao usuário, centralizadas em um único lugar. |
| 5 | **Preservação parcial no refresh** | O refresh atualiza apenas `accessToken` no objeto do Hive, preservando demais dados da sessão (ex.: dados do usuário retornados no login). |
| 6 | **Logout com limpeza de stack** | `Get.offAllNamed('/login')` garante que nenhuma tela de área autenticada permaneça na pilha de navegação após a expiração da sessão. |
| 7 | **baseUrl configurável em runtime** | A URL base é carregada dinamicamente via settings, permitindo troca de ambiente (dev/staging/prod) sem recompilação. |

---

## 12. Achados de Segurança

> **POSTURA DESTE DOCUMENTO:** Os itens abaixo são **fatos observados no código de produção**. São apresentados como "melhorias possíveis sem alterar o comportamento funcional" e "considerações futuras". Não constituem plano de migração de stack.

### 12.1 Tabela de Achados

| # | Achado | Arquivo | Linha | Severidade | Tipo |
|---|---|---|---|---|---|
| S-01 | `badCertificateCallback` aceita qualquer certificado SSL | `http_manager.dart` | 25 | 🔴 Alta | Segurança de transporte |
| S-02 | Token armazenado em Hive sem criptografia | `Hive_services.dart` + `login_repository.dart` | 14, 38 | 🟠 Média | Segurança de dados em repouso |
| S-03 | Retry recursivo sem limite de tentativas | `http_manager.dart` | 71-72 | 🟡 Baixa | Robustez / DoS local |
| S-04 | Credencial de admin hardcoded em código | `login_controller.dart` | 47 | 🟠 Alto | Segurança de acesso |
| S-05 | `baseUrl` inicializada com IP fixo de rede local | `Endpoints.dart` | 8 | 🟡 Baixa | Configuração de ambiente |
| S-06 | `LogInterceptor` comentado — sem logging em produção | `http_manager.dart` | 29-38 | 🔵 Info | Observabilidade |

---

### 12.2 Detalhamento dos Achados

#### S-01 — SSL Bypass Universal (Severidade: 🔴 Alta)

**Fato observado:**
```dart
// http_manager.dart — construtor HttpManager()
(dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
    (HttpClient client) {
  client.badCertificateCallback = (cert, host, port) => true;  // aceita QUALQUER certificado
  return client;
};
```

**Contexto:** Este bypass foi introduzido para permitir comunicação com o servidor backend em ambiente de rede local (intranet) que utiliza certificado SSL autoassinado ou sem HTTPS válido (nota: a `baseUrl` usa `http://`, não `https://`).

**Melhoria possível sem alterar comportamento funcional:**
- Condicionar o bypass apenas a builds de desenvolvimento: `if (kDebugMode) { client.badCertificateCallback = ...; }`
- Ou: aceitar apenas certificados de hosts específicos (ex.: verificar `host == '192.168.1.192'`)

**Consideração futura:**
- Em ambiente de produção com HTTPS válido, remover completamente o callback ou implementar certificate pinning.

---

#### S-02 — Token Hive Não Criptografado (Severidade: 🟠 Média)

**Fato observado:**
```dart
// login_repository.dart
hiveServices.setCache(nameFild: 'Autenticacao', values: jsonEncode(result.data));
// Armazena string JSON em plaintext na box 'Cache_aplicativo'
```

O Hive, sem configuração de cipher, persiste os dados em arquivo binário no sistema de arquivos do dispositivo **sem criptografia**.

**Melhoria possível sem alterar comportamento funcional:**
- Hive suporta `HiveAesCipher` nativamente. Seria possível abrir a box com chave de criptografia derivada de `FlutterSecureStorage` sem alterar nenhuma das interfaces ou chamadores.
- A interface `HiveServicesInterface` permanece intacta — apenas a inicialização da box mudaria.

**Consideração futura:**
- Em dispositivos com acesso root ou backups habilitados, o arquivo do Hive é legível por outros processos. Para tokens de acesso a sistemas corporativos, criptografia em repouso é recomendada.

---

#### S-03 — Retry Recursivo Sem Limite (Severidade: 🟡 Baixa)

**Fato observado:**
```dart
// http_manager.dart
if (refreshed) {
  return await restRequest(url: url, method: method, headers: headers, body: body);
  // Se o novo token também gerar 401, haverá nova tentativa de refresh
  // Se o refresh também gerar 401, o ciclo pode se repetir
}
```

Na prática atual, se o refresh falha ele retorna `false` e o ciclo para. Porém, se a API retornar 401 mesmo após um refresh bem-sucedido (cenário de race condition ou bug no backend), a recursão aconteceria indefinidamente.

**Melhoria possível sem alterar comportamento funcional:**
```dart
// Adicionar contador de retry como parâmetro opcional
Future<Response> restRequest({
  required String url,
  required String method,
  Map? headers,
  Map? body,
  int retryCount = 0,       // novo parâmetro com default = 0
}) async {
  // ...
  if (error.response?.statusCode == 401 && retryCount < 1) {  // máximo 1 retry
    bool refreshed = await _tryRefreshToken();
    if (refreshed) {
      return await restRequest(
        url: url, method: method, headers: headers, body: body,
        retryCount: retryCount + 1,  // incrementa
      );
    }
  }
}
```

---

#### S-04 — Credencial de Admin Hardcoded (Severidade: 🟠 Alto)

**Fato observado:**
```dart
// login_controller.dart
void loginSettings({required String usuario, required String senha, required BuildContext context}) {
  if (usuario == 'admin' && senha == 'KeyMaster') {  // credencial em texto puro no código
    Navigator.of(context).pop();
    Get.toNamed(PagesRoutes.settingsApp.path);
  }
}
```

Credencial de acesso à tela de configurações do aplicativo (`SettingsApp`) está hardcoded no código-fonte. Qualquer pessoa com acesso ao APK decompilado ou ao repositório tem acesso à credencial.

**Melhoria possível sem alterar comportamento funcional:**
- Armazenar o hash (ex.: SHA-256) da senha no código e comparar com o hash da entrada.
- Ou: mover a validação para o servidor.

**Consideração futura:**
- Em uma evolução, a tela de Settings poderia ser protegida pelo mesmo mecanismo de autenticação JWT da aplicação, exigindo uma role/permissão específica.

---

#### S-05 — IP Fixo como baseUrl Padrão (Severidade: 🟡 Baixa)

**Fato observado:**
```dart
// Endpoints.dart
String? baseUrl = 'http://192.168.1.192:7021';  // IP de rede local exposto
```

**Contexto:** Este IP é o fallback antes de `initializeApp()` carregar a URL das configurações. Em produção o valor é sobrescrito. O risco real é se `initializeApp()` falhar silenciosamente e o app usar o IP hardcoded.

**Melhoria possível:**
- Inicializar `baseUrl` como `null` e lançar erro explícito se `restRequest()` for chamado sem URL configurada.

---

#### S-06 — Ausência de Logging HTTP em Produção (Severidade: 🔵 Info)

**Fato observado:**
```dart
// Código comentado — nunca registrado no dio.interceptors
//dio.interceptors.add(LogInterceptor(...));
```

Não há logging de requisições em produção. Diagnóstico de problemas depende de `print()` statements e do `LogServices` para erros de alto nível.

**Consideração futura:**
- Reativar o `LogInterceptor` apenas em builds de debug (`kDebugMode`) é seguro e não altera comportamento em produção.

---

## 13. Classificação de Preservação

### 🟢 Reutilizar com Melhorias

**Justificativa:**

O mecanismo de autenticação e tratamento de requisições do `controle_separacao_aplicativo` é **funcional, coeso e bem estruturado** para os requisitos de um sistema corporativo de intranet. Os seguintes aspectos o qualificam diretamente para reuso no Template Corporativo:

1. **Arquitetura por interfaces** — todos os contratos estão abstraídos, permitindo reimplementações sem quebrar consumidores.
2. **Refresh transparente** — o ciclo 401 → refresh → retry funciona corretamente e é completamente invisível para as camadas de negócio.
3. **Ponto único de controle HTTP** — `restRequest()` é o único portão de entrada, simplificando auditoria e evolução.
4. **Separação Controller/Repository/View** — o padrão GetX com interfaces está corretamente aplicado ao domínio de autenticação.

As melhorias identificadas (limitar retry, isolar SSL bypass em dev, criptografar Hive, remover credencial hardcoded) podem ser aplicadas **incrementalmente** sem alterar o comportamento funcional existente e sem migração de stack.

**O que preservar como está:**
- Estrutura de pastas e nomenclatura de abstrações
- Fluxo `restRequest()` → 401 → `_tryRefreshToken()` → retry / signOut
- Persistência em Hive com atualização parcial no refresh
- `Get.offAllNamed('/login')` no signOut

**O que melhorar antes de usar no template:**
- Limitar recursão de retry a 1 tentativa (S-03)
- Condicionar SSL bypass ao ambiente de dev (S-01)
- Substituir credencial hardcoded por hash ou validação server-side (S-04)

---

*Documento gerado em 2026-06-24 para o Template Corporativo Flutter — Direction App.*
*Fonte: análise estática do código-fonte de `controle_separacao_aplicativo` (somente leitura).*
