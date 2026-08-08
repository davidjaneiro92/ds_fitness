# Logging e Observabilidade — Análise de Infraestrutura

> **Classificação geral: 🟠 Parcial — log local estruturado existe; log remoto custom; zero observabilidade de produção real**

---

## 1. Visão Geral

```
Evento/Erro
    ↓
LogServices.log(message, level)          ← logger local (pacote logger)
    ↓
[if repository.getLogger() == true]
    ↓
salvarLog(body) → POST /api/v1/log-erros-aplicativo   ← log remoto custom

Operação do usuário
    ↓
LogServices.LogOperacoes(mensagem) → POST /api/v2/log-operacoes  ← auditoria de ação

Em paralelo: print() espalhado por ~60 pontos no código
```

---

## 2. Pacote Logger

**Pacote:** `logger` (pub.dev)

Configurado em `lib/src/core/services/log_services.dart`:

```dart
final Logger _logger = Logger();
```

Instância padrão sem customização (sem `PrettyPrinter` configurado, sem `SimplePrinter`, sem `LogFilter` customizado).

### Níveis suportados (via switch)

| Level | Método | Uso no projeto |
|---|---|---|
| `Level.error` | `_logger.e(message)` | Erros de rede, falhas de cache |
| `Level.warning` | `_logger.w(message)` | Não usado ativamente |
| `Level.debug` | `_logger.d(message)` | Não usado ativamente |
| `Level.info` (padrão) | `_logger.i(message)` | Uso geral |

A interface define apenas dois métodos públicos:

```dart
abstract class LogServicesInterface {
  Future<void> log(String message, {Level level = Level.info});
  Future<bool> LogOperacoes(String mensagem);
}
```

### Pontos fortes

| Item | Avaliação |
|---|---|
| Abstração via interface (`LogServicesInterface`) | ✅ Permite substituir implementação |
| Nivéis de log mapeados | 🟢 |
| Uso via `Get.find<LogServicesInterface>()` — injetado | 🟢 |

### Problemas

| Problema | Impacto |
|---|---|
| `Logger()` sem configuração — sem controle de output em release | Médio |
| Nenhum filtro por nível em produção (tudo vai para console) | Médio |
| Mensagens de log hardcoded com número de linha ("Linha 24 Hive_services") | Baixo — desatualiza com refactoring |

---

## 3. LogServices — Envio Remoto de Logs de Erro

### Como funciona hoje

```dart
Future<void> log(String message, {Level level = Level.info}) async {
  // 1. Loga localmente via _logger
  _logger.e/w/d/i(message);

  // 2. Verifica flag de logger remoto habilitado
  if (await repository.getLogger() == false) return;

  // 3. Monta payload e envia
  final logData = {
    "timestamp": DateTime.now().toIso8601String(),
    "levelError": level.toString().split('.').last,
    "message": message,
  };
  salvarLog(logData);
}
```

**Endpoint:** `GET /api/v1/log-erros-aplicativo` (POST)

**Payload enviado:**
```json
{
  "timestamp": "2025-10-15T14:30:00.000",
  "levelError": "error",
  "message": "Erro ao salvar os dado no cacher. Linha 24 Hive_services"
}
```

### Loading global durante envio de log

```dart
Future<void> salvarLog(Map<String, dynamic> body) async {
  final loadingController = Get.find<LoadingController>();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    loadingController.showLoading(); // ← exibe loading global
  });
  try {
    final result = await _httpManager.restRequest(...);
    if (result.statusCode == 200) {
      loadingController.hideLoading();
      print('log Enviado com Sucesso');
    } else {
      loadingController.hideLoading();
      throw Exception("Erro ao enviar os log");
    }
  } catch (e) {
    print(e);
    throw Exception("Erro ao tentar obter os dados");
  } finally {
    loadingController.hideLoading();
  }
}
```

**Problema crítico de UX:** O envio de um log de erro aciona o loading global para o usuário — ou seja, o usuário vê um indicador de carregamento enquanto o sistema registra um erro, sem relação com sua ação.

---

## 4. LogOperacoes — Auditoria de Ações do Usuário

### Como funciona hoje

```dart
Future<bool> LogOperacoes(String mensagem) async {
  var json = await hiveServices.getCache(nameFild: 'Autenticacao');
  var Autenticacao = jsonDecode(json);
  var log = LogOperacoesModel(
    mensagem: mensagem,
    programa: 'Controle de Separação',
    usuario: Autenticacao['usuario'],
    data: DateFormat("yyyy-MM-ddTHH:mm:ss'Z'").format(DateTime.now()),
  );
  final result = await _httpManager.restRequest(
    url: Endpoints.logOperacoes,
    method: HttpMethods.post,
    body: jsonDecode(jsonEncode(log)),
  );
  return result.statusCode == 200;
}
```

**Endpoint:** `POST /api/v2/log-operacoes`

**Modelo enviado:**

| Campo | Origem |
|---|---|
| `mensagem` | Texto da ação (passado pelo caller) |
| `programa` | Hardcoded: `'Controle de Separação'` |
| `usuario` | Lido do Hive (`Autenticacao['usuario']`) |
| `data` | `DateTime.now()` formatado |

Também exibe loading global durante envio — mesmo problema de `salvarLog`.

---

## 5. `print()` Espalhado — Logging Não Estruturado

O grep identificou **~60 chamadas** `print()` em todo o projeto, distribuídas em:

| Categoria | Exemplos de arquivos | Contagem aproximada |
|---|---|---|
| Repositórios (catch de erros) | `buscar_produtos_repository.dart`, `conferir_material_saida_repository.dart`, `itens_nf_entrada_repository.dart` | ~30 |
| Services (`http_manager`, `log_services`, `Hive_services`) | `http_manager.dart`, `log_services.dart` | ~8 |
| Controllers | `itens_pedido_saida_controller.dart`, `nfs_pedidos_controller.dart` | ~6 |
| Views | `selecionar_material_estoque.dart`, `buscar_produtos.dart`, `conferir_material_saida.dart` | ~6 |
| Models | `nf_lotes_model.dart`, `item_model.dart` | ~2 |

### Exemplos representativos

```dart
// http_manager.dart — linha 79
print('Erro no Dio: ${error.message}');

// Hive_services.dart — linha 19
print(e);

// selecionar_material_estoque_repository.dart — linha 40
print(Endpoints.notasFiscaisPagas + '?dhEntradaIni=...');  // URL com parâmetros no log

// conferir_material_saida_repository.dart — linha 78
print(jsonEncode(novoJson));  // payload de requisição completo no log

// custom_scaffold_controller.dart
print('Usuário saiu!');
```

**Risco de segurança:** Alguns `print()` expõem URLs completas com parâmetros de query e payloads JSON completos — em modo debug, esses dados aparecem no logcat/console, acessível via `adb logcat` em dispositivos Android sem root.

---

## 6. O Que Existe vs. O Que Falta

### O que existe

| Capacidade | Status | Detalhes |
|---|---|---|
| Log local estruturado (níveis) | ✅ | Pacote `logger`, 4 níveis |
| Envio remoto de logs de erro | 🟡 Existe, mas frágil | POST para endpoint próprio; sem retry, sem fila |
| Auditoria de operações do usuário | 🟡 Existe | `LogOperacoes` → endpoint v2 |
| Flag on/off para log remoto | ✅ | Via `repository.getLogger()` |
| Abstração por interface | ✅ | `LogServicesInterface` |

### O que falta (gap de observabilidade)

| Capacidade Ausente | Impacto | Solução Recomendada |
|---|---|---|
| **Crash reporting automático** | Crítico — crashes em produção são invisíveis | Firebase Crashlytics ou Sentry Flutter SDK |
| **Stack trace nos logs remotos** | Alto — log envia só mensagem, sem stack | Incluir `StackTrace.current` no payload |
| **Analytics de uso** | Médio — sem métricas de tela/feature | Firebase Analytics ou Mixpanel |
| **Distributed tracing / correlation ID** | Médio — impossível correlacionar log de app com log de backend | Adicionar `X-Correlation-ID` nas requisições |
| **Métricas de performance** | Médio — sem APM | Firebase Performance ou OpenTelemetry |
| **Alertas e dashboards** | Alto — sem visibilidade operacional | Sentry alerts, Grafana + Loki |
| **Log offline / fila de envio** | Médio — falha de rede descarta o log | Fila local (Hive) + retry em background |
| **Sanitização de dados nos logs** | Alto — dados do usuário em `print()` | Substituir `print` por `_logger`, mascarar PII |

---

## 7. Problemas Identificados

| Problema | Severidade | Local |
|---|---|---|
| Loading global ao enviar log — UX quebrada | 🔴 Alto | `LogServices.salvarLog`, `LogOperacoes` |
| ~60 `print()` — logging não estruturado | 🟠 Médio-Alto | Todo o `lib/` |
| Payload JSON completo em `print()` — risco de vazamento | 🟠 Médio-Alto | Repositórios |
| Sem crash reporting — crashes invisíveis em prod | 🔴 Crítico | Ausente no projeto |
| Logger sem configuração — sem filtro de nível em release | 🟡 Médio | `LogServices` |
| `LogOperacoes` faz `new LogOperacoesModel` (keyword `new` obsoleta) | 🟢 Baixo | `log_services.dart` linha 96 |
| Programa hardcoded `'Controle de Separação'` no log de operações | 🟢 Baixo | Deve ser parametrizado no template |

---

## 8. Direção para o Template

### 8.1 Melhorias imediatas no Logger (sem nova biblioteca)

As melhorias abaixo são aplicáveis à stack atual sem novas dependências:
- Configurar `Logger` por ambiente (`DevelopmentFilter` / `ProductionFilter`).
- Substituir `print()` por `_logger.e/w/d/i()` em todos os arquivos.
- Remover loading global do fluxo de `salvarLog` / `LogOperacoes`.
- Incluir `StackTrace` no payload do log remoto.
- Adicionar Correlation ID nas requisições.

> ⚠️ **Consideração futura (NÃO aplicar agora).** A direção atual é preservar a stack (ver [documentation-stance](../00-overview/documentation-stance.md)). O conteúdo abaixo é apenas conhecimento técnico para decisão futura.

### 8.2 Crash Reporting (alternativa futura — nova dependência)

```dart
// Alternativa futura (requer firebase_crashlytics ou sentry_flutter)
void main() async {
  await Firebase.initializeApp();
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  ErrorWidget.builder = (details) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    return CustomErrorWidget(...);
  };
}
```

Alternativa: `Sentry.init(...)` com `SentryFlutter.init`.

### 8.3 Detalhes das melhorias imediatas (sem nova biblioteca)

**Substituir `print()` por Logger injetado:**
```dart
// Em vez de: print(e);
// Use:        _logger.e('Descrição do erro', error: e, stackTrace: s);
```

**Logger configurado por ambiente:**
```dart
final Logger _logger = Logger(
  filter: kReleaseMode ? ProductionFilter() : DevelopmentFilter(),
  printer: kReleaseMode ? SimplePrinter() : PrettyPrinter(),
  level: kReleaseMode ? Level.warning : Level.debug,
);
```

**Remover loading do fluxo de log:**
```dart
// Log deve ser fire-and-forget, sem bloquear o usuário
Future<void> salvarLog(Map<String, dynamic> body) async {
  // SEM loadingController
  try {
    await _httpManager.restRequest(...);
  } catch (_) {
    // falha silenciosa — não propagar para o usuário
  }
}
```

**Incluir stack trace no payload remoto:**
```dart
final logData = {
  "timestamp": DateTime.now().toIso8601String(),
  "levelError": level.name,
  "message": message,
  "stackTrace": stackTrace?.toString(), // novo campo
  "appVersion": packageInfo.version,
  "platform": Platform.operatingSystem,
};
```

**Correlation ID nas requisições:**
```dart
// Em HttpManager.restRequest
final correlationId = const Uuid().v4();
defaulHeaders['X-Correlation-ID'] = correlationId;
// Incluir nos logs: logData['correlationId'] = correlationId;
```

---

## Resumo de Classificações

| Componente | Classificação | Motivo |
|---|---|---|
| Logger local (pacote logger) | 🟢 Bom | Estruturado, com níveis, injetável |
| Interface `LogServicesInterface` | ✅ Ótimo | Abstração correta |
| Envio remoto de logs | 🟡 Adequado | Existe mas frágil (sem retry, sem stack trace) |
| `LogOperacoes` (auditoria) | 🟡 Adequado | Funcional; loading indevido |
| Loading durante log | 🔴 Problema | Bloqueia UX sem necessidade |
| `print()` espalhado | 🟠 Problemático | ~60 ocorrências; risco de vazamento |
| Crash reporting | 🔴 Ausente | Zero visibilidade de crashes em produção |
| Analytics/tracing/métricas | 🔴 Ausente | Nenhum instrumento de observabilidade |
