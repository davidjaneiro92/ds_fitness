# Catálogo de Serviços Compartilhados — Controle de Separação (Legado)

> **Finalidade:** Preservação e reuso num Template Corporativo Flutter.
> **Postura:** documentar fielmente o que EXISTE e FUNCIONA; stack mantida (GetX · Dio · Hive · logger · intl).
> **Escopo:** somente serviços e utilitários compartilhados de `core/`. Regras de negócio não são documentadas.
> **Data de extração:** 2026-06-24

---

## Sumário

1. [Tabela Mestre](#1-tabela-mestre)
2. [HttpManager](#2-httpmanager)
3. [HiveServices](#3-hiveservices)
4. [LogServices](#4-logservices)
5. [FormatarValores](#5-formatarvalores)
6. [UtilsServices](#6-utilsservices)
7. [Validators (funções livres)](#7-validators-funções-livres)
8. [Mapa de Duplicações](#8-mapa-de-duplicações)

---

## 1. Tabela Mestre

| Serviço | Interface (contrato ativo) | Lib base | Responsabilidade central | Registro em `main.dart` | Classificação |
|---|---|---|---|---|---|
| `HttpManager` | `HttpManagerInterfaces` (`core/abstracts/`) | `dio` | Cliente HTTP único: montagem de headers, Bearer token, refresh automático, tratamento de erros Dio | `Get.put<HttpManagerInterfaces>(HttpManager())` | ✅ Preservar |
| `HiveServices` | `HiveServicesInterface` (`core/abstracts/`) | `hive` / `hive_flutter` | CRUD de cache local em caixa Hive já aberta | `Get.put<HiveServicesInterface>(HiveServices())` | ✅ Preservar (com ajuste de assinatura) |
| `LogServices` | `LogServicesInterface` (`core/abstracts/`) | `logger` | Log local via `logger` + envio remoto de erros e operações via HTTP | `Get.put<LogServicesInterface>(LogServices())` | 🟢 Preservar (com ajuste de instanciação) |
| `FormatarValores` | `FormatarValoresInterface` (`core/abstracts/`) | `intl` | Formatação e parsing de números/moedas/datas pt-BR | `Get.put<FormatarValoresInterface>(FormatarValores())` | ✅ Preservar |
| `UtilsServices` | `UtilsServicesInterfaces` (`core/abstracts/`) | — | Placeholder sem implementação efetiva | `Get.put<UtilsServicesInterfaces>(UtilsServices())` | 🟡 Manter casca; implementar no template |
| `Validators` (livre) | Nenhuma | `get` (extensões) | Validação de campos de formulário (email, senha, CPF, etc.) | Não registrado no GetX; uso direto | ✅ Preservar versão em `core/utils/validators.dart` |

---

## 2. HttpManager

### 2.1 Responsabilidade única

Encapsular toda comunicação HTTP da aplicação: montar cabeçalhos padrão, injetar token Bearer, executar o ciclo de refresh automático em caso de 401, tratar e mapear erros Dio para mensagens em português.

### 2.2 Contrato — `HttpManagerInterfaces`

**Arquivo ativo:** `lib/src/core/abstracts/http_manager_interfaces.dart`

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

| Método | Retorno | Parâmetros obrigatórios | Descrição |
|---|---|---|---|
| `restRequest` | `Future<Response>` | `url`, `method` | Executa qualquer verbo HTTP via Dio; headers e body são opcionais |

> **Nota de contrato:** a interface ativa retorna `Future<Response>` (objeto `dio.Response` completo), diferente da versão legada em `lib/src/Interfaces/` que retorna `Future<Map>`. Apenas a versão ativa deve ser usada.

### 2.3 Implementação

**Arquivo:** `lib/src/core/services/http_manager.dart`

**Dependências:**
- `dio` — cliente HTTP
- `get` — `Get.find<HiveServicesInterface>()` para recuperar o token de cache
- `logger` — importado mas não utilizado diretamente (uso apenas em `print`)

**Fluxo interno:**

```
restRequest()
  ├── token()               ← Get.find<HiveServicesInterface>().getCache('Autenticacao') → jsonDecode → accessToken
  ├── monta headers padrão  ← content-type, accept, Authorization: Bearer <token>
  ├── dio.request()
  │     ├── sucesso         → retorna Response
  │     └── DioException
  │           ├── status 401 → _tryRefreshToken()
  │           │                 ├── true  → re-executa restRequest() (1 tentativa)
  │           │                 └── false → signOut() + customAlertMessage + throw
  │           └── outros    → _handleDioError() → customAlertMessage + retorna Response vazia
  └── catch genérico        → throw Exception
```

**Funções de nível de arquivo (não são métodos da classe):**

| Função | Assinatura | Descrição |
|---|---|---|
| `token()` | `Future<String>` | Recupera `accessToken` do Hive via `Get.find<HiveServicesInterface>()` |
| `_tryRefreshToken()` | `Future<bool>` | Instancia `LoginRepository()` diretamente e chama `Refreshtoken()` |
| `signOut()` | `Future<void>` | Apaga cache de autenticação e redireciona para tela de login |
| `_handleDioError()` | `String` | Mapeia `DioExceptionType` para mensagem em português |

**Configuração SSL:**
```dart
(dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
    (HttpClient client) {
  client.badCertificateCallback = (cert, host, port) => true;
  return client;
};
```
Ignora validação de certificado SSL — aceitável em ambiente de rede local/legado; deve ser revisado em produção pública.

### 2.4 Registro em `main.dart`

```dart
Get.put<HttpManagerInterfaces>(HttpManager());
```

Registrado como singleton permanente. Depende que `HiveServices` já esteja registrado antes (o que ocorre — `HiveServices` é injetado anteriormente no `main.dart`).

### 2.5 Pontos fortes para reuso

- Único ponto de entrada HTTP — fácil para adicionar interceptors globais (logging, métricas).
- Refresh token automático transparente para os repositórios.
- Tratamento de erros centralizado com mensagens em português.

### 2.6 Dívidas observadas

| # | Dívida | Impacto | Melhoria sem troca de stack |
|---|---|---|---|
| D1 | `_tryRefreshToken()` instancia `LoginRepository()` com `new` (direto), sem GetX | Quebra o grafo de DI; `LoginRepository` pode não ter suas próprias dependências resolvidas | Registrar `LoginRepositoryInterface` no GetX e usar `Get.find()` |
| D2 | `badCertificateCallback = (cert, host, port) => true` desabilita validação SSL | Risco de segurança em redes públicas | Parametrizar via variável de ambiente; em homologação manter `true`, em produção `false` |
| D3 | `print(...)` misturado com tratamento de erro em vez de usar `LogServicesInterface` | Log inconsistente, sem nível | Substituir `print` por `Get.find<LogServicesInterface>().log(...)` |
| D4 | `LogInterceptor` comentado no construtor | Log HTTP desativado permanentemente | Ativar via flag de build (`kDebugMode`) |

### 2.7 Classificação

**✅ Preservar** — é o serviço de maior valor para reuso: implementa autenticação Bearer com refresh, tratamento rico de erros Dio e ponto único de saída HTTP.

---

## 3. HiveServices

### 3.1 Responsabilidade única

Abstrair o acesso ao cache local Hive (caixa `Cache_aplicativo`), fornecendo operações de leitura, escrita, remoção individual e limpeza total, com tratamento de erros e feedback visual ao usuário.

### 3.2 Contrato — `HiveServicesInterface`

**Arquivo ativo:** `lib/src/core/abstracts/Hive_services_interface.dart`

```dart
abstract class HiveServicesInterface {
  void setCache({required String nameFild, required dynamic values});
  Future<dynamic?> getCache({required String nameFild});
  void deleteCache({required String nameFild});
  void limparTodoCache();
}
```

| Método | Retorno | Parâmetros | Descrição |
|---|---|---|---|
| `setCache` | `void` | `nameFild`, `values` | Persiste qualquer valor na chave informada |
| `getCache` | `Future<dynamic?>` | `nameFild` | Recupera valor por chave; retorna `null` se não existir |
| `deleteCache` | `void` | `nameFild` | Remove uma chave específica do cache |
| `limparTodoCache` | `void` | — | Apaga todos os registros da caixa |

### 3.3 Implementação

**Arquivo:** `lib/src/core/services/Hive_services.dart`

**Dependências (Get.find):**
- `UtilsServicesInterfaces` — injetado mas não utilizado na implementação atual
- `LogServicesInterface` — usado para log de erros em cada método

**Fluxo interno de cada método:**

```
setCache()
  ├── await box.put(nameFild, values)
  └── catch → logservices.log(..., Level.error) + CustomToast.showToasts(status.error)

getCache()
  ├── return await box.get(nameFild)
  └── catch → logservices.log(...) + CustomToast + retorna null implicitamente

deleteCache()
  ├── await box.delete(nameFild)
  └── catch → logservices.log(...) + CustomToast

limparTodoCache()
  ├── await box.clear()
  └── catch → logservices.log(...) + CustomToast
```

**Caixa Hive usada:**

| Caixa | Abertura | Conteúdo conhecido |
|---|---|---|
| `Cache_aplicativo` | `main.dart` antes de `Get.put<HiveServicesInterface>` | Token de autenticação (`Autenticacao`), configurações de logger, dados de sessão |
| `variaves_ambiente` | `main.dart` antes de qualquer serviço | Variáveis de ambiente do servidor; lida diretamente por `SettingsAppRepository` sem passar por `HiveServices` |

### 3.4 Registro em `main.dart`

```dart
await Hive.openBox('Cache_aplicativo');        // pré-requisito
Get.put<HiveServicesInterface>(HiveServices());
```

A ordem é crítica: `HiveServices` pressupõe que a Box já esteja aberta.

### 3.5 Pontos fortes para reuso

- Isola completamente o Hive do resto da aplicação — fácil substituir ou adicionar criptografia (HiveAES) sem tocar nos consumidores.
- Tratamento de erros uniforme em todos os métodos.
- Interface simples e estável.

### 3.6 Dívidas observadas

| # | Dívida | Impacto | Melhoria sem troca de stack |
|---|---|---|---|
| D1 | `setCache`, `deleteCache` e `limparTodoCache` declaram retorno `void` mas contêm `await` internamente | O chamador não pode saber se a operação assíncrona concluiu ou falhou; awaits silenciosos podem gerar race conditions | Mudar retorno para `Future<void>` no contrato e na implementação |
| D2 | `UtilsServicesInterfaces` é injetado via `Get.find()` mas nunca utilizado | Dependência morta que força ordem de registro no `main.dart` | Remover do construtor de `HiveServices` |
| D3 | `getCache` não distingue "chave ausente" de "erro" — ambos retornam `null` | Dificulta diagnóstico de falhas silenciosas | Retornar um `Either<Failure, dynamic>` ou lançar exception tipada |

### 3.7 Classificação

**✅ Preservar** (com ajuste de assinatura `void` → `Future<void>`) — abstração de cache local essencial, bem estruturada, com cobertura de erros.

---

## 4. LogServices

### 4.1 Responsabilidade única

Prover logging estruturado em dois canais independentes: (1) log local de debug/erro via `Logger` e (2) envio remoto de logs de erros técnicos e de operações de usuário via HTTP para endpoints da API.

### 4.2 Contrato — `LogServicesInterface`

**Arquivo ativo:** `lib/src/core/abstracts/log_services_interface.dart`

```dart
abstract class LogServicesInterface {
  Future<void> log(String message, {Level level = Level.info});
  Future<bool> LogOperacoes(String mensagem);
}
```

| Método | Retorno | Parâmetros | Descrição |
|---|---|---|---|
| `log` | `Future<void>` | `message`, `level` (padrão `Level.info`) | Log local via `Logger` + envio remoto se `getLogger() == true` |
| `LogOperacoes` | `Future<bool>` | `mensagem` | Registra operação do usuário na API com dados de autenticação; retorna `true` em sucesso |

> **Atenção:** `LogOperacoes` usa convenção `PascalCase` que diverge do padrão Dart (`camelCase`). No contrato da versão legada (`lib/src/Interfaces/log_services_interface.dart`), este método não existe — é exclusivo da interface ativa.

### 4.3 Implementação

**Arquivo:** `lib/src/core/services/log_services.dart`

**Dependências:**
- `Logger` — instanciado diretamente (`Logger()`) — correto, pois é stateless
- `SettingsAppRepository` — instanciado diretamente (`SettingsAppRepository()`) — consulta flag `getLogger()` para decidir envio remoto
- `HttpManagerInterfaces` — **instanciado com `HttpManager()` diretamente**, não via `Get.find()` — dívida crítica de DI
- `HiveServicesInterface` — `Get.find()` — usado apenas em `LogOperacoes` para obter dados de autenticação
- `LoadingController` — `Get.find<LoadingController>()` — exibe/oculta loading durante envio remoto
- `intl` — `DateFormat` para formatar timestamp de operações

**Fluxo de `log()`:**

```
log(message, level)
  ├── _logger.e/w/d/i(message)    ← sempre executa
  ├── repository.getLogger()
  │     └── false → retorna sem envio remoto
  └── salvarLog({ timestamp, levelError, message })
        ├── loadingController.showLoading()
        ├── _httpManager.restRequest(Endpoints.logErrosAplicativo, POST, body)
        │     ├── 200 → hideLoading()
        │     └── outros → throw Exception
        └── finally → hideLoading()
```

**Fluxo de `LogOperacoes()`:**

```
LogOperacoes(mensagem)
  ├── hiveServices.getCache('Autenticacao') → jsonDecode → usuario
  ├── Formata data ISO com DateFormat
  ├── Cria LogOperacoesModel { mensagem, programa, usuario, data }
  ├── _httpManager.restRequest(Endpoints.logOperacoes, POST, body)
  │     ├── 200 → return true
  │     └── outros → return false
  └── catch → throw Exception
```

**Modelo utilizado:** `lib/src/models/log_operacoes_model.dart`

### 4.4 Registro em `main.dart`

```dart
Get.put<LogServicesInterface>(LogServices());
```

Registrado antes de `HiveServices` e `HttpManager`, o que força `LogServices` a instanciar `HttpManager` com `new` (não pode usar `Get.find` pois `HttpManager` ainda não foi registrado no momento de construção).

### 4.5 Pontos fortes para reuso

- Duplo canal (local + remoto) com flag de controle por configuração.
- Níveis de log (`Level.error`, `Level.warning`, `Level.debug`, `Level.info`) mapeados para `logger`.
- `LogOperacoes` com rastreabilidade de usuário e timestamp é valioso para auditoria.

### 4.6 Dívidas observadas

| # | Dívida | Impacto | Melhoria sem troca de stack |
|---|---|---|---|
| D1 | `_httpManager = HttpManager()` instanciado com `new` em vez de `Get.find()` | Cria instância paralela fora do grafo DI; se `HttpManager` tiver estado (ex.: interceptors configurados no singleton), a instância em `LogServices` não os terá | Reorganizar ordem de registro no `main.dart`: registrar `HttpManager` antes de `LogServices`, então usar `Get.find<HttpManagerInterfaces>()` |
| D2 | `SettingsAppRepository()` instanciado com `new` | Mesmo problema — DI quebrado para o repositório de configurações | Registrar `SettingsAppRepositoryInterface` no GetX e usar `Get.find()` |
| D3 | `LogOperacoes` usa convenção `PascalCase` (nome de classe, não de método) | Viola Dart style guide; IDEs podem sinalizar como warning | Renomear para `logOperacoes` na interface e implementação |
| D4 | `salvarLog` exibe `LoadingWidget` durante envio de log de erro | UX intrusiva — o usuário vê um spinner para cada erro logado | Envio de log deve ser silencioso (sem loading) |
| D5 | `var Autenticacao = jsonDecode(json)` usa `PascalCase` para variável local | Viola convenção Dart | Renomear para `autenticacao` |
| D6 | Ordem de registro no `main.dart` força dependência circular de instanciação | Fragilidade arquitetural | Ver D1 — resolver com ordem correta no `main.dart` |

### 4.7 Classificação

**🟢 Preservar** (com ajuste de instanciação e renomeação) — o padrão de log dual local+remoto com controle por flag é robusto; as dívidas são corrigíveis sem trocar bibliotecas.

---

## 5. FormatarValores

### 5.1 Responsabilidade única

Centralizar toda conversão e formatação de valores numéricos e datas para exibição no padrão brasileiro (pt-BR): moeda, número decimal, data/hora e parsing reverso.

### 5.2 Contrato — `FormatarValoresInterface`

**Arquivo ativo:** `lib/src/core/abstracts/formatar_valores_interface.dart`

```dart
abstract class FormatarValoresInterface {
  String priceToCurrency(double price);
  String formatvalueToBrasil(double values);
  String formatDateTime(DateTime dateTime);
  double convertBRLToUSD(String brlValue);
  double tratarValor(String valor);
}
```

| Método | Retorno | Parâmetros | Descrição |
|---|---|---|---|
| `priceToCurrency` | `String` | `price: double` | Formata double como moeda R$ pt-BR (ex.: `R$ 1.234,56`) |
| `formatvalueToBrasil` | `String` | `values: double` | Formata double como número decimal pt-BR sem símbolo (ex.: `1.234,56`) |
| `formatDateTime` | `String` | `dateTime: DateTime` | Formata data e hora no padrão pt-BR (ex.: `24/06/2026 14:30`) |
| `convertBRLToUSD` | `double` | `brlValue: String` | Faz parsing de string BRL e converte para double no formato USD |
| `tratarValor` | `double` | `valor: String` | Normaliza string numérica com ponto ambíguo (separador de milhar vs decimal) para double |

> **Nota de contrato:** a interface legada em `lib/src/Interfaces/formatar_valores_interface.dart` não contém `tratarValor` — este método foi adicionado exclusivamente na versão ativa.

### 5.3 Implementação

**Arquivo:** `lib/src/core/utils/formatar_valores.dart`

**Dependências:**
- `intl` — `NumberFormat`, `DateFormat`, `initializeDateFormatting`
- Sem dependência de GetX ou outros serviços

**Lógica de `tratarValor`:**

```dart
// Heurística: se o ponto está nas 2 ou 3 últimas posições → separador decimal
// caso contrário → separador de milhar (deve ser removido)
double tratarValor(String valor) {
  if (valor.contains('.')) {
    if (valor.indexOf('.') == valor.length - 2 || valor.indexOf('.') == valor.length - 3) {
      return double.parse(valor);       // ponto é decimal
    } else {
      return double.parse(valor.replaceAll('.', ''));  // ponto é milhar
    }
  } else {
    return double.parse(valor ?? '0');
  }
}
```

> **Atenção:** a heurística de `tratarValor` pode falhar em casos como `"1.000"` (que seria interpretado como `1000.0`) ou `"0.5"` (interpretado corretamente como `0.5`). Documentar os casos de uso esperados ao migrar.

### 5.4 Registro em `main.dart`

```dart
Get.put<FormatarValoresInterface>(FormatarValores());
```

Registrado após `HttpManager`. Não possui dependências de outros serviços — pode ser registrado em qualquer posição.

### 5.5 Pontos fortes para reuso

- Completamente stateless — sem efeitos colaterais.
- Zero dependências de infraestrutura (sem GetX, sem Hive, sem Dio).
- Cobertura dos casos mais comuns de formatação BR.
- Facilmente testável com testes unitários puros.

### 5.6 Dívidas observadas

| # | Dívida | Impacto | Melhoria sem troca de stack |
|---|---|---|---|
| D1 | `tratarValor` usa heurística posicional para distinguir separador decimal/milhar | Pode produzir resultado errado em valores como `"1.000"` | Documentar contrato claro: o método espera strings no formato de API (ponto sempre como decimal) ou especificar o locale de origem |
| D2 | `convertBRLToUSD` converte para USD mas não usa taxa de câmbio real | Nome engana — na prática faz apenas parsing BRL → double | Renomear para `parseBRLToDouble` ou documentar que "USD" refere-se ao formato numérico `en_US`, não à moeda |
| D3 | `valor ?? '0'` dentro de `double.parse()` com `valor` declarado `String` (não-nullable) | O operador `??` é inefetivo em tipo não-nullable; o código compila mas o `??` nunca é avaliado | Ajustar assinatura para `String? valor` ou remover o `?? '0'` |

### 5.7 Classificação

**✅ Preservar** — utilitário de alta reutilização, sem acoplamento, facilmente portável. Corrigir dívidas D2 e D3 antes de publicar no template.

---

## 6. UtilsServices

### 6.1 Responsabilidade única

Nenhuma efetiva no estado atual. A classe existe como placeholder para utilitários gerais compartilhados, com interface e implementação vazias.

### 6.2 Contrato — `UtilsServicesInterfaces`

**Arquivo ativo:** `lib/src/core/abstracts/utils_services_interfaces.dart`

```dart
abstract class UtilsServicesInterfaces {
  // vazio — nenhum método declarado
}
```

### 6.3 Implementação

**Arquivo:** `lib/src/core/utils/utils_services.dart`

```dart
class UtilsServices implements UtilsServicesInterfaces {
  // vazio — nenhum método implementado
}
```

**Importações presentes mas sem uso funcional:**
- `flutter/material.dart`
- `fluttertoast/fluttertoast.dart`
- `oktoast/oktoast.dart`

### 6.4 Registro em `main.dart`

```dart
Get.put<UtilsServicesInterfaces>(UtilsServices());
```

Registrado como **primeiro serviço** no `main.dart`, antes de `LogServices` e `HiveServices`. Isso é relevante pois `HiveServices` declara `Get.find<UtilsServicesInterfaces>()` no seu construtor (mesmo sem usar).

### 6.5 Pontos fortes para reuso

- A casca com interface registrada no GetX já está pronta para receber implementações.
- Posição de registro garante disponibilidade para qualquer serviço posterior.

### 6.6 Dívidas observadas

| # | Dívida | Impacto | Melhoria sem troca de stack |
|---|---|---|---|
| D1 | Interface e implementação completamente vazias | Serviço registrado ocupa slot no GetX sem oferecer valor | Definir responsabilidades no template (ex.: formatação de toast, debounce, geração de UUID) |
| D2 | `HiveServices` depende de `UtilsServicesInterfaces` sem usar | Acoplamento desnecessário — força ordem de registro | Remover `Get.find<UtilsServicesInterfaces>()` de `HiveServices` até que haja uso real |
| D3 | Importações não utilizadas na implementação | Gera warnings de lint | Remover `fluttertoast` e `oktoast` até haver implementação |

### 6.7 Classificação

**🟡 Manter casca; implementar no template** — a estrutura (interface + implementação + registro GetX) é válida; o conteúdo deve ser definido com base nas necessidades do template corporativo.

---

## 7. Validators (funções livres)

### 7.1 Responsabilidade única

Prover funções de validação de campos de formulário compatíveis com o padrão de `validator` do Flutter (`String? Function(String?)`), cobrindo os tipos de dado mais comuns da aplicação.

### 7.2 Contrato

Não há interface formal. São funções de nível de arquivo (top-level functions), sem classe nem registro GetX.

**Arquivo ativo:** `lib/src/core/utils/validators.dart`

| Função | Assinatura | Descrição |
|---|---|---|
| `emailValidator` | `String? Function(String? email)` | Verifica preenchimento e formato de e-mail via `String.isEmail` (GetX) |
| `passwordValidator` | `String? Function(dynamic password)` | Verifica preenchimento e comprimento mínimo de 3 caracteres |
| `nameValidator` | `String? Function(String? name)` | Verifica preenchimento e exige nome completo (pelo menos 2 palavras) |
| `UsuarioValidator` | `String? Function(String? usuario)` | Verifica preenchimento de nome de usuário |
| `loteValidator` | `String? Function(String? lote)` | Verifica preenchimento do campo lote |
| `pesoValidator` | `String? Function(String? peso)` | Verifica preenchimento do campo peso |
| `phoneValidator` | `String? Function(String? phone)` | Verifica comprimento e formato de telefone via `String.isPhoneNumber` (GetX) |
| `cpfvalidator` | `String? Function(String? cpf)` | Valida CPF via `String.isCpf` (GetX) |

> **Extensões GetX utilizadas:** `String.isEmail`, `String.isPhoneNumber`, `String.isCpf` — fornecidas pelo pacote `get`.

### 7.3 Uso

Injetadas diretamente nos campos `TextFormField.validator`:

```dart
TextFormField(
  validator: emailValidator,
  ...
)
```

### 7.4 Pontos fortes para reuso

- Compatíveis com o contrato nativo do Flutter sem adaptação.
- Sem dependências de estado ou GetX além das extensões de `String`.
- Cobertura dos campos mais comuns em apps corporativos.

### 7.5 Dívidas observadas

| # | Dívida | Impacto | Melhoria sem troca de stack |
|---|---|---|---|
| D1 | `passwordValidator` exige mínimo de 3 caracteres mas a mensagem diz "7 caracteres" | Inconsistência mensagem/lógica | Corrigir comprimento mínimo para 7 (ou ajustar a mensagem) |
| D2 | `UsuarioValidator` usa `PascalCase` (nome de classe) em vez de `usuarioValidator` | Viola Dart style guide | Renomear para `usuarioValidator` |
| D3 | `cpfvalidator` usa tudo em minúsculo sem separador | Inconsistência de nomenclatura | Renomear para `cpfValidator` |
| D4 | Sem interface formal | Não é injetável via GetX; não é mockável em testes unitários | No template, considerar encapsular em classe com interface se testabilidade for prioritária |

### 7.6 Classificação

**✅ Preservar** a versão em `lib/src/core/utils/validators.dart` — cobertura prática e uso direto simples.

---

## 8. Mapa de Duplicações

O projeto contém duas árvores paralelas com os mesmos serviços. A árvore ativa é `core/`; a outra é legada e deve ser descartada.

### 8.1 Tabela de Duplicações

| Ativo (preservar) | Legado (descartar) | Diferenças relevantes |
|---|---|---|
| `lib/src/core/services/http_manager.dart` | `lib/src/services/http_manager.dart` | Legado: retorna `Future<Map>`, sem SSL bypass, sem refresh token, sem tratamento de erros Dio, sem Bearer token |
| `lib/src/core/abstracts/http_manager_interfaces.dart` | `lib/src/Interfaces/http_manager_interfaces.dart` | Legado: `Future<Map>` vs ativo `Future<Response>` — contratos incompatíveis |
| `lib/src/core/services/Hive_services.dart` | `lib/src/services/Hive_services.dart` | Praticamente idênticos; legado importa de `Interfaces/` em vez de `core/abstracts/` |
| `lib/src/core/abstracts/Hive_services_interface.dart` | `lib/src/Interfaces/Hive_services_interface.dart` | Idênticos em conteúdo |
| `lib/src/core/services/log_services.dart` | `lib/src/services/log_services.dart` | Legado: sem `LogOperacoes`, verifica `res.length > 0` em vez de `statusCode == 200`, sem LoadingController no log |
| `lib/src/core/abstracts/log_services_interface.dart` | `lib/src/Interfaces/log_services_interface.dart` | Legado: sem `LogOperacoes` |
| `lib/src/core/utils/formatar_valores.dart` | `lib/src/services/formatar_valores.dart` | Legado: sem `tratarValor`; importa de `Interfaces/` |
| `lib/src/core/abstracts/formatar_valores_interface.dart` | `lib/src/Interfaces/formatar_valores_interface.dart` | Legado: sem `tratarValor` |
| `lib/src/core/utils/utils_services.dart` | `lib/src/services/utils_services.dart` | Idênticos em conteúdo (ambos vazios) |
| `lib/src/core/abstracts/utils_services_interfaces.dart` | `lib/src/Interfaces/utils_services_interfaces.dart` | Idênticos em conteúdo (ambos vazios) |
| `lib/src/core/utils/validators.dart` | `lib/src/services/validators.dart` | **Idênticos byte a byte** |

### 8.2 Classificação das versões legadas

Todos os arquivos abaixo são classificados como **🔴 Descartar** — são cópias antigas ou versões menos completas dos serviços ativos em `core/`.

```
lib/src/services/http_manager.dart      🔴 Descartar
lib/src/services/log_services.dart      🔴 Descartar
lib/src/services/Hive_services.dart     🔴 Descartar
lib/src/services/formatar_valores.dart  🔴 Descartar
lib/src/services/utils_services.dart    🔴 Descartar
lib/src/services/validators.dart        🔴 Descartar

lib/src/Interfaces/http_manager_interfaces.dart     🔴 Descartar
lib/src/Interfaces/Hive_services_interface.dart     🔴 Descartar
lib/src/Interfaces/log_services_interface.dart      🔴 Descartar
lib/src/Interfaces/formatar_valores_interface.dart  🔴 Descartar
lib/src/Interfaces/utils_services_interfaces.dart   🔴 Descartar
```

> **Risco de migração:** verificar que nenhum arquivo fora de `core/` ainda importa de `lib/src/services/` ou `lib/src/Interfaces/` antes de remover. Realizar busca por `from '../services/` e `from '../Interfaces/` no projeto completo.

---

## Apêndice — Ordem de Registro no `main.dart`

A ordem de `Get.put` é funcional e deve ser preservada no template (dependências respeitadas):

```dart
// 1. Infraestrutura base (sem dependências de outros serviços)
Get.put(LoadingController());
Get.put<UtilsServicesInterfaces>(UtilsServices());
Get.put<LogServicesInterface>(LogServices());        // ⚠ instancia HttpManager com new

// 2. Hive já aberto antes deste ponto
await Hive.openBox('Cache_aplicativo');
Get.put<HiveServicesInterface>(HiveServices());

// 3. HTTP (depende de HiveServices via token())
Get.put<HttpManagerInterfaces>(HttpManager());

// 4. Utilitários puros
Get.put<FormatarValoresInterface>(FormatarValores());

// 5. Controllers de feature (não documentados neste catálogo)
Get.put<SettingsAppControllerInterface>(SettingsAppController());
// ...demais controllers
```

> **Melhoria de ordem:** mover `HttpManager` para **antes** de `LogServices` e ajustar `LogServices` para usar `Get.find<HttpManagerInterfaces>()`. Isso elimina a instanciação com `new HttpManager()` e torna o grafo DI coerente.
