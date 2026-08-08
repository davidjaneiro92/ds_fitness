# Blueprint do Template Flutter Corporativo (baseado na fundação atual)

> Especificação da **fundação técnica do template**, derivada **fielmente** do legado `controle_separacao_aplicativo` e **preservando a stack e os padrões que já funcionam em produção**. As únicas mudanças são **higiene interna** (remover código morto/duplicado e corrigir typos) — **sem trocar bibliotecas**. Ver [documentation-stance.md](../00-overview/documentation-stance.md). **Zero regra de negócio.**

## 1. Princípios (preservados do legado)

1. **Feature-first** — cada funcionalidade em `core/features/<feature>/`.
2. **Programação por interface** (abstracts) para serviços, controllers e repositórios.
3. **Command Pattern** para operações de negócio (`controller/commands/`).
4. **Repository Pattern** isolando a fonte de dados.
5. **GetX** para estado + DI + navegação.
6. **Hive** para cache e configuração de ambiente em runtime.
7. **Dio** (via `HttpManager`) com refresh token transparente.
8. **Overlay de loading global** e **tela de erro amigável** globais.

## 2. Estrutura de pastas do template

> É a **estrutura ativa do legado** (`lib/src/core/...`), **sem** as árvores duplicadas/mortas. Nomes corrigidos (snake_case, sem typos).

```
lib/
├── main.dart                       # bootstrap + DI (Get.put) + GetMaterialApp
└── src/
    ├── core/
    │   ├── abstracts/              # contratos dos serviços (DIP)
    │   │   ├── http_manager_interface.dart
    │   │   ├── hive_services_interface.dart
    │   │   ├── log_services_interface.dart
    │   │   ├── formatar_valores_interface.dart
    │   │   └── utils_services_interface.dart
    │   ├── services/               # HttpManager (Dio), HiveServices, LogServices
    │   ├── utils/                  # FormatarValores, UtilsServices, validators
    │   ├── theme/config/           # custom_colors.dart (cor corporativa)
    │   └── features/
    │       └── <feature>/
    │           ├── abstracts/      # contratos do controller e do repository
    │           ├── controller/
    │           │   └── commands/   # Command Pattern (operações)
    │           ├── repository/     # acesso a dados (usa HttpManager)
    │           └── view/           # UI reativa (Obx/GetX)
    ├── components/                 # widgets compartilhados (design system)
    │   ├── loading/                #   overlay global (controller + view)
    │   ├── custom_list_view/       #   lista configurável por colunas (alto valor)
    │   ├── custom_scaffold/        #   scaffold base (parametrizar menu/rotas)
    │   ├── custom_error_widget.dart#   tela de erro amigável (ver doc dedicada)
    │   ├── custom_text_field.dart, custom_toast.dart, custom_alert.dart,
    │   ├── custom_app_bar.dart, custom_dropdown_button.dart,
    │   └── custom_pluto_grid_table.dart
    ├── constants/                  # endpoints.dart
    ├── enum/                       # pages_routes.dart, http_methods.dart
    ├── models/                     # DTOs (fromJson/toJson manual — padrão atual)
    └── routes/                     # app_pages.dart (GetPages)
```

### Itens removidos vs. legado (somente higiene, sem trocar stack)

| Removido | Motivo |
|----------|--------|
| `lib/src/pages/` | Árvore legada (código morto, não roteada) |
| `lib/src/services/` | Duplicata de `core/services/` |
| `lib/src/Interfaces/` | Duplicata de `core/abstracts/` |
| `lib/src/pages_routes/` | Rota morta (duplicata de `routes/`) |
| `lib/src/config/custom_colos.dart` | Duplicata de `core/theme/config/` |
| Typos (`Trasferencia`, `colos`, `dropwn`, `nameFild`, `custom_Scaffold`) | Padronização snake_case/camelCase |

## 3. Camadas e responsabilidades (como no legado)

| Camada | Pasta | Responsabilidade |
|--------|-------|------------------|
| **View** | `features/<f>/view` | UI + reatividade (`Obx`/`GetX`); sem regra |
| **Controller** | `features/<f>/controller` | Estado `Rx`, orquestra Commands e Repository |
| **Command** | `controller/commands` | Uma operação de negócio coesa (`execute()`) |
| **Repository** | `features/<f>/repository` | Acesso a dados via `HttpManager` |
| **Abstracts** | `*/abstracts`, `core/abstracts` | Contratos (interfaces) |
| **Services** | `core/services` | HTTP, cache/Hive, log |
| **Components** | `components/` | Widgets compartilhados |

## 4. Bootstrap do template (padrão atual preservado)

Replica a sequência do `main.dart` legado (ver [configuration.md](../02-infrastructure/configuration.md)):

```dart
void main() async {
  // 1) Tela de erro amigável global
  ErrorWidget.builder = (details) => CustomErrorWidget(
    errorMessage: kDebugMode ? details.summary.toString() : 'Mensagem amigável.',
  );

  WidgetsFlutterBinding.ensureInitialized();
  // 2) Hive + boxes (config de ambiente + cache)
  await Hive.initFlutter();
  await Hive.openBox('variaves_ambiente');
  await initializeApp(); // lê baseUrl do Hive → Endpoints

  // 3) DI por interface (Get.put). Preferir lazyPut/Bindings quando possível.
  Get.put<UtilsServicesInterface>(UtilsServices());
  Get.put<LogServicesInterface>(LogServices());
  await Hive.openBox('Cache_aplicativo');
  Get.put<HiveServicesInterface>(HiveServices());
  Get.put<HttpManagerInterface>(HttpManager());
  // ... demais controllers de feature

  // 4) App com overlay global de loading
  runApp(const MyApp()); // OKToast > GetMaterialApp(getPages, builder: LoadingWidget)
}
```

## 5. Configuração de ambiente (padrão atual = destaque)

O template **preserva** o mecanismo do legado: `baseUrl` e flags (ex.: `logger`) ficam na box Hive `variaves_ambiente`, **editáveis em runtime** pela tela de settings, sem rebuild. Fallback configurável. Detalhe em [configuration.md](../02-infrastructure/configuration.md).

## 6. O que vem pronto para reúso

Catálogo completo em [06-classification](../06-classification/technical-classification.md). Destaques: **tela de erro amigável**, **overlay de loading global**, **lista configurável (`custom_list_view`)**, **HttpManager com refresh token**, **HiveServices**, **LogServices**, **FormatarValores/validators**, **enum de rotas**, **tema Material 3 com cor corporativa**.

> Stack detalhada em [recommended-stack.md](recommended-stack.md); ajustes opcionais em [migration-notes.md](migration-notes.md).
