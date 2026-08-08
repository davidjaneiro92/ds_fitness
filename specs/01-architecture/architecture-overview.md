# Visão Geral da Arquitetura

> Fonte: análise direta de `lib/` (não havia documentação arquitetural no projeto legado).

## 1. Resumo executivo da arquitetura

O aplicativo adota uma arquitetura **feature-first em camadas**, com **GetX** como espinha dorsal (estado reativo + injeção de dependência + navegação) e **contratos por interface** (abstracts) para quase todos os serviços e controllers — uma aplicação prática do **Dependency Inversion Principle**.

A camada de feature mais recente introduz o **Command Pattern** para encapsular operações de negócio, sinalizando uma evolução arquitetural deliberada.

> ⚠️ **Achado central:** o projeto está no meio de uma **migração arquitetural inacabada**. Duas árvores coexistem:
> - `lib/src/pages/` → **estrutura legada** (código morto — não referenciada por `main.dart`).
> - `lib/src/core/features/` → **estrutura ativa e alvo** (referenciada por `main.dart` e por `routes/app_pages.dart`).
>
> O template deve extrair **o destino da migração** (`core/features` + Command), não a média das duas.

## 2. Camadas

```
┌─────────────────────────────────────────────────────────────┐
│  VIEW (GetX)                                                  │
│  core/features/<feature>/view/*.dart                         │
│  Widgets + Obx/GetX reativos. Sem lógica de negócio.         │
└───────────────┬─────────────────────────────────────────────┘
                │ Get.find() / reatividade Rx
┌───────────────▼─────────────────────────────────────────────┐
│  CONTROLLER (GetxController + Interface)                      │
│  core/features/<feature>/controller/*.dart                   │
│  Estado reativo (Rx), orquestra Commands e Repository.       │
└───────────────┬─────────────────────────────────────────────┘
                │ instancia
┌───────────────▼─────────────────────────────────────────────┐
│  COMMAND (Command Pattern) — apenas features recentes        │
│  controller/commands/*.dart → .execute()                     │
│  Encapsula uma operação de negócio coesa.                    │
└───────────────┬─────────────────────────────────────────────┘
                │ usa
┌───────────────▼─────────────────────────────────────────────┐
│  REPOSITORY (+ Interface)                                     │
│  core/features/<feature>/repository/*.dart                   │
│  Abstrai a fonte de dados; chama o HttpManager.              │
└───────────────┬─────────────────────────────────────────────┘
                │ Get.find() / new
┌───────────────▼─────────────────────────────────────────────┐
│  SERVICES (core/services + abstracts)                         │
│  HttpManager (Dio) · HiveServices (cache) · LogServices      │
│  UtilsServices · FormatarValores                             │
└───────────────┬─────────────────────────────────────────────┘
                │
┌───────────────▼─────────────────────────────────────────────┐
│  MODELS (lib/src/models) — serialização manual fromJson/toJson│
└─────────────────────────────────────────────────────────────┘
```

## 3. Fluxo de dados (exemplo, sem regra de negócio)

```
View (botão) → Controller.acao()
              → Command.execute()
                 → Repository.metodo()
                    → HttpManager.restRequest()   [Dio + token Bearer do Hive]
                       → API REST
                    ← Response
                 ← Model.fromJson()
              ← atualiza estado Rx (.obs)
View reage via Obx/GetX e re-renderiza
```

## 4. Inicialização (`main.dart`)

`main()` faz **bootstrap manual e eager** de toda a aplicação:

1. `ErrorWidget.builder` → substitui a tela vermelha por `CustomErrorWidget` (mensagem amigável em produção).
2. `Hive.initFlutter()` + abertura das boxes `variaves_ambiente` e `Cache_aplicativo`.
3. **~20 chamadas `Get.put<Interface>(Impl())`** registrando serviços e **todos** os controllers de feature de forma **eager** (instanciados no boot, não sob demanda).
4. `runApp(GetMaterialApp(...))` com `LoadingWidget` global empilhado via `builder` (overlay de loading sobre toda a árvore).

> 🟡 **Pontos de atenção do bootstrap:** DI 100% manual e eager (não usa `Bindings`/`lazyPut` do GetX); `main.dart` com ~50 imports; controllers carregados todos no início (custo de memória/tempo de boot). Detalhe em [02-infrastructure/dependency-injection.md](../02-infrastructure/dependency-injection.md).

## 5. Pontos fortes da arquitetura (manter)

- ✅ **Separação por feature** com camadas claras (view/controller/repository).
- ✅ **Programação por interface** (abstracts) — facilita testes e troca de implementação.
- 🟢 **Command Pattern** para operações de negócio — coesão e testabilidade.
- 🟢 **Repository Pattern** isolando a fonte de dados.
- ✅ **ErrorWidget.builder** global para resiliência de UI.

## 6. Pontos a modernizar

- 🔴 **Remover a árvore legada `lib/src/pages/`** (código morto) e duplicações (`services` vs `core/services`, `Interfaces` vs `core/abstracts`, `routes` vs `pages_routes`).
- 🟠 **Padronizar DI** com `Bindings` + `lazyPut` (ou migrar p/ injeção mais explícita).
- 🟡 **Consistência:** alguns serviços instanciam dependências com `new` em vez de `Get.find()` (ex.: `LogServices` cria `HttpManager()` próprio), quebrando o ciclo de DI.

> Detalhamento de pastas em [folder-structure.md](folder-structure.md) e padrões em [design-patterns.md](design-patterns.md).
