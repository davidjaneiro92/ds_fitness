# Tratamento de Erros — Análise de Infraestrutura

> **Classificação geral: 🟠 Básico / Funcional com falhas estruturais**
> A camada de erros existe e cobre os casos críticos, mas está acoplada à UI, usa exceções genéricas sem tipagem e mistura responsabilidades.

---

## 1. Visão Geral da Arquitetura de Erros

```
[Widget crash]
      ↓
ErrorWidget.builder (main.dart)
      ↓
CustomErrorWidget (Scaffold com mensagem)

[Erro de rede]
      ↓
HttpManager.restRequest → on DioException
      ↓
_handleDioError → customAlertMessage (Get.dialog)
      ↓
(401) → _tryRefreshToken → retentar ou signOut

[Erro em serviço/repositório]
      ↓
try/catch genérico → print(e) + throw Exception(mensagem)
      ↓
(às vezes) logservices.log + CustomToast
```

---

## 2. ErrorWidget.builder Global

### Como funciona hoje

Configurado em `lib/main.dart` (linha 55–61):

```dart
ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
  return CustomErrorWidget(
    errorMessage: kDebugMode
        ? errorDetails.summary.toString()
        : 'Ocorreu um erro inesperado. Por favor, entre em contato com o suporte.',
  );
};
```

O `CustomErrorWidget` (`lib/src/components/custom_error_widget.dart`) renderiza um `Scaffold` centralizado com:
- Imagem de erro (`assets/img/erro3.png`) de altura fixa 700px
- Texto "ERROR" em azul
- Mensagem condicional (debug mostra stack summary; release mostra texto genérico)

### Pontos fortes

| Item | Avaliação |
|---|---|
| Cobertura de crash de widget | ✅ Captura qualquer crash em árvore de widgets |
| Distinção debug/release | ✅ Não expõe stack em produção |
| Feedback visual customizado | 🟢 Tela própria, não a tela vermelha padrão do Flutter |

### Problemas

| Problema | Impacto |
|---|---|
| Erro de widget **não é reportado** (sem Crashlytics/Sentry) | Alto — falhas em produção são invisíveis para a equipe |
| `errorDetails.summary.toString()` em debug pode expor lógica interna | Médio |
| Imagem com `height: 700` quebra em telas pequenas (sem `Expanded`/`Flexible`) | Baixo |
| Nenhuma ação de recuperação oferecida (botão "Reiniciar") | Médio |

---

## 3. Tratamento Centralizado de Erros HTTP (HttpManager)

### Como funciona hoje

`lib/src/core/services/http_manager.dart` — método `restRequest`:

```dart
} on DioException catch (error) {
  if (error.response?.statusCode == 401) {
    bool refreshed = await _tryRefreshToken();
    if (refreshed) {
      return await restRequest(...); // retenta
    } else {
      signOut();
      customAlertMessage(title: "Atenção", message: "Sessão expirada...");
      throw Exception("Sessão expirada, faça login novamente.");
    }
  }
  print('Erro no Dio: ${error.message}');
  String errorMessage = error.response?.data["error"] ?? 'null';
  if (errorMessage != 'null') {
    customAlertMessage(title: "Atenção", message: errorMessage);
  } else {
    var menssage = _handleDioError(error);
    customAlertMessage(title: "Atenção", message: menssage);
  }
  return error.response ?? Response(requestOptions: RequestOptions(path: url));
} catch (error) {
  print('Erro inesperado: $error');
  throw Exception(error);
}
```

Mapeamento de tipos de erro via `_handleDioError`:

| `DioExceptionType` | Mensagem retornada |
|---|---|
| `connectionTimeout` | "Tempo limite de conexão excedido." |
| `sendTimeout` | "Tempo limite ao enviar a solicitação." |
| `receiveTimeout` | "Tempo limite ao receber resposta." |
| `badResponse` | "Resposta inválida do servidor (statusCode)." |
| `cancel` | "Solicitação cancelada." |
| `connectionError` | "Falha na conexão com a internet ou o servidor não responde." |
| `unknown` | "Erro inesperado: {message}" |

### Pontos fortes

| Item | Avaliação |
|---|---|
| Ponto único de entrada para todos os erros HTTP | ✅ |
| Refresh token automático no 401 | ✅ |
| Mapeamento tipado de `DioExceptionType` | 🟢 |
| Mensagem amigável ao usuário via `customAlertMessage` | 🟢 |

### Problemas

| Problema | Impacto |
|---|---|
| `HttpManager` chama diretamente `customAlertMessage` (UI acoplada à infra) | Alto — viola separação de responsabilidades; dificulta testes |
| `throw Exception(error)` no catch genérico perde o tipo original do erro | Alto |
| `print('Erro no Dio: ...')` — logging não estruturado (ver seção de logs) | Médio |
| Retorna `Response` vazia em erros DioException — callers devem checar `statusCode` mas podem não checar | Médio |
| Retentativa de 401 sem limite de profundidade (risco de loop infinito) | Médio |

---

## 4. Feedback de Erro ao Usuário

### Componentes disponíveis

| Componente | Arquivo | Uso |
|---|---|---|
| `customAlertMessage` | `lib/src/components/custom_message.dart` | Dialog modal sem contexto (usa `Get.dialog`) — erros de rede |
| `customAalertQuestion` | `lib/src/components/custom_alert.dart` | Dialog com Sim/Não — confirmações |
| `customAalertInformation` | `lib/src/components/custom_alert.dart` | Dialog informativo — requer `BuildContext` |
| `CustomToast.showToasts` | `lib/src/components/custom_toast.dart` | Toast não bloqueante — 5 seg., `oktoast` |

### Lógica do CustomToast

```dart
// status é uma String (constante estática em abstract class status)
backgroundColor: status == 'success' ? Colors.green
    : status == 'warner'  ? Colors.amberAccent
    : Colors.red,         // qualquer outro valor → vermelho (erro)
```

| Ponto | Avaliação |
|---|---|
| Três canais de feedback (toast, dialog, alert) | 🟢 |
| `dismissOtherToast: true` — evita acúmulo de toasts | ✅ |
| `status` usa `String` em vez de `enum` — typo silencioso possível | 🟠 |
| `customAlertMessage` usa `Get.dialog` sem `BuildContext` — funciona mas exige GetX ativo | 🟡 |
| Nenhuma acessibilidade (sem `Semantics`) nos feedbacks | 🟡 |

---

## 5. Try/Catch nos Serviços e Repositórios

### Padrão observado (recorrente em ~20+ repositórios)

```dart
try {
  final result = await _httpManager.restRequest(...);
  if (result.statusCode == 200) {
    // sucesso
  } else {
    logservices.log('Api fora do ar ...', level: Level.error);
    return false; // ou throw Exception(...)
  }
} catch (e) {
  print(e);
  logservices.log('Erro ao tentar obter os dados: $e', level: Level.error);
  return false; // ou throw Exception("Erro ao tentar obter os dados")
} finally {
  loadingController.hideLoading();
}
```

### Problemas estruturais

| Problema | Impacto |
|---|---|
| Ausência de tipo de erro tipado (`Failure`/`Either`/`Result`) — exceções genéricas `throw Exception("texto")` | Alto — callers não sabem distinguir NetworkFailure de ValidationFailure |
| `print(e)` como log de erro — dados sensíveis podem vazar em logcat/console | Alto |
| Mensagens de log contêm número de linha hardcoded ("Linha 52") — ficam desatualizadas com refactoring | Médio |
| `try/catch` sem relançamento tipado — a stack original se perde | Médio |
| Comportamento inconsistente: alguns retornam `false`, outros fazem `throw Exception` para o mesmo tipo de falha | Médio |

---

## 6. Ausência de Tipo de Erro Tipado (Failure/Either)

O projeto **não usa** nenhuma abstração de resultado tipado. Não há `Either`, `Result`, `Failure`, nem pacote `fpdart`/`dartz`.

O retorno dos repositórios mistura:
- `bool` (sucesso/falha)
- `throw Exception(String)` (erro genérico)
- `Response` com statusCode (erros HTTP devolvidos como sucesso)

---

## 7. Direção para o Template

### 7.1 Melhorar tipagem de erros (sem nova biblioteca)

```dart
// Melhoria interna — sem nova dependência
sealed class AppFailure {
  final String message;
  const AppFailure(this.message);
}
class NetworkFailure extends AppFailure { ... }
class AuthFailure extends AppFailure { ... }
class ServerFailure extends AppFailure { ... }
class CacheFailure extends AppFailure { ... }

// Repositórios retornam resultado tipado simples
typedef AppResult<T> = ({T? data, AppFailure? failure});
```

### 7.2 Desacoplar UI do HttpManager (melhoria interna)

```dart
// HttpManager lança exceção tipada — a UI ou controller decide como exibir
class HttpManager {
  Future<Response> restRequest(...) async {
    ...
    on DioException catch (e) {
      throw NetworkFailure(_handleDioError(e)); // sem Get.dialog aqui
    }
  }
}
```

### 7.3 Adicionar limite de retry no 401 (melhoria interna)

```dart
Future<Response> restRequest({..., int retryCount = 0}) async {
  ...
  if (statusCode == 401 && retryCount == 0) {
    return restRequest(..., retryCount: 1);
  }
  throw AuthFailure("Sessão expirada");
}
```

### 7.4 Converter `status` em enum (melhoria interna)

```dart
enum FeedbackStatus { success, warning, error }
```

> ⚠️ **Consideração futura (NÃO aplicar agora).** A direção atual é preservar a stack (ver [documentation-stance](../00-overview/documentation-stance.md)). O conteúdo abaixo é apenas conhecimento técnico para decisão futura.

### 7.5 Reporte remoto de crashes (alternativa futura)

```dart
// Alternativa futura — requer nova dependência (firebase_crashlytics ou sentry_flutter)
ErrorWidget.builder = (FlutterErrorDetails details) {
  FirebaseCrashlytics.instance.recordFlutterFatalError(details);
  // ou: Sentry.captureException(details.exception, stackTrace: details.stack)
  return CustomErrorWidget(...);
};
```

### 7.6 Resultado tipado com biblioteca funcional (alternativa futura)

```dart
// Alternativa futura com fpdart — não aplicar agora
Future<Either<AppFailure, T>> fetchData();
```

---

## Resumo de Classificações

| Componente | Classificação | Motivo |
|---|---|---|
| `ErrorWidget.builder` global | 🟢 Bom | Existe e diferencia debug/release; falta reporte remoto |
| `HttpManager` centralizado | 🟡 Adequado | Cobre casos principais; UI acoplada; exceções genéricas |
| `_handleDioError` mapeado | 🟢 Bom | Mensagens por tipo de DioException |
| Refresh token 401 | 🟢 Bom | Automático; falta limite de retentativa |
| Feedback ao usuário (toast/dialog) | 🟡 Adequado | Múltiplos canais; `status` como String frágil |
| Tipo de erro (Failure/Either) | 🔴 Ausente | Exceções genéricas em todo o projeto |
| Try/catch nos repositórios | 🟠 Inconsistente | Padrão existe mas comportamento varia |
