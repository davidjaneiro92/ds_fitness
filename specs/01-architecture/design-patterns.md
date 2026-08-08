# Design Patterns Identificados

> Levantamento dos padrões de projeto encontrados no código legado, com classificação para o template.

| Padrão | Onde | Como é usado | Classificação |
|--------|------|--------------|---------------|
| **Feature-first / Modular** | `core/features/<feature>` | Cada funcionalidade agrupa view/controller/repository/abstracts/commands | ✅ Reutilizar |
| **MVC reativo (GetX)** | controller ↔ view | `GetxController` com estado `Rx`; view reage via `Obx`/`GetX` | 🟢 Reutilizar c/ melhorias |
| **Command Pattern** | `controller/commands/*.dart` | Cada operação de negócio é uma classe com `execute()`; o controller orquestra | ✅ Reutilizar |
| **Repository Pattern** | `<feature>/repository` | Isola acesso a dados; controller/command não conhecem o HTTP | ✅ Reutilizar |
| **Dependency Inversion (interface-based)** | `core/abstracts`, `<feature>/abstracts` | Quase tudo tem contrato `abstract class` + impl; injetado via GetX | ✅ Reutilizar |
| **Service Locator** | `Get.put` / `Get.find` | DI por localizador de serviço (GetX) | 🟡 Refatorar (formalizar c/ Bindings) |
| **Adapter / Wrapper** | `HttpManager` (sobre Dio), `LogServices` (sobre logger) | Encapsula libs de terceiros atrás de interface própria | 🟢 Reutilizar c/ melhorias |
| **Singleton** | serviços via `Get.put` (permanentes) | Instância única compartilhada | 🟢 Reutilizar c/ melhorias |
| **Strategy (implícito)** | `_handleDioError` (switch por tipo de erro) | Mapeia tipos de erro Dio → mensagem | 🟡 Refatorar (extrair) |
| **Global Overlay** | `LoadingWidget` empilhado no `builder` do MaterialApp | Loading único controlado por `LoadingController` | 🟢 Reutilizar c/ melhorias |

## Boas práticas implementadas (manter)

- **Programação contra abstrações** em quase toda a base — alta testabilidade potencial.
- **Encapsulamento de bibliotecas de terceiros** atrás de interfaces (Dio, Hive, logger) — troca de fornecedor com baixo impacto.
- **Tratamento global de erros de widget** (`ErrorWidget.builder`).
- **Ciclo de vida tratado** nos controllers (`onClose` fecha streams `Rx` — evita leaks).
- **Refresh token automático** no fluxo HTTP (401 → refresh → retry → signOut).

## Anti-padrões / dívidas técnicas (corrigir no template)

| Anti-padrão | Evidência | Risco |
|-------------|-----------|-------|
| **DI inconsistente** | `LogServices` cria `HttpManager()` com `new` em vez de `Get.find()` | múltiplas instâncias, estado divergente |
| **`print()` espalhado** | `print(barcode)`, `print(e)` em serviços/controllers | logs não estruturados em produção |
| **Lógica de negócio em service de infra** | `HttpManager` chama `customAlertMessage` (UI) e navega (`Get.offAllNamed`) | acopla infra↔UI↔navegação |
| **Migração inacabada** | árvores `pages/` e `core/features/` coexistindo | confusão, código morto |
| **Serialização manual** | todos os models com `fromJson/toJson` à mão | boilerplate, erro humano |
| **Datas mágicas** | `DateTime.parse("2025-01-31...")` como default | bugs silenciosos |

> Recomendações de padrões para o template em [07-template-blueprint/recommended-stack.md](../07-template-blueprint/recommended-stack.md).
