# Estrutura de Pastas — Atual vs. Alvo

## 1. Estrutura atual (legado)

```
lib/
├── main.dart                      # bootstrap manual + DI eager + GetMaterialApp
└── src/
    ├── Interfaces/                # 🔴 DUPLICADO de core/abstracts (legado)
    ├── components/                # widgets compartilhados (flat + 3 com sub-MVC)
    │   ├── custom_Scaffold/       #   controller/interfaces/view
    │   ├── custom_list_view/      #   controller/model/view
    │   ├── loading/               #   controller/view (overlay global)
    │   ├── custom_alert.dart, custom_app_bar.dart, custom_text_field.dart,
    │   ├── custom_dropwn_button.dart, custom_expansion.dart, custom_list_tile.dart,
    │   ├── custom_message.dart, custom_toast.dart, custom_error_widget.dart,
    │   └── custom_plutoGrid_Table.dart
    ├── config/
    │   └── custom_colos.dart      # 🔴 DUPLICADO de core/theme/config (typo "colos")
    ├── constants/
    │   └── Endpoints.dart         # URLs de API
    ├── core/                      # ✅ ÁRVORE ATIVA / ALVO DA MIGRAÇÃO
    │   ├── abstracts/             # contratos dos serviços (DIP)
    │   ├── features/<feature>/    # feature-first
    │   │   ├── abstracts/         #   contratos do controller e do repository
    │   │   ├── controller/        #   GetxController + Rx
    │   │   │   └── commands/      #   ✅ Command Pattern (operações de negócio)
    │   │   ├── repository/        #   acesso a dados
    │   │   └── view/              #   UI reativa
    │   ├── services/              # HttpManager, HiveServices, LogServices
    │   ├── theme/config/          # custom_colos.dart
    │   └── utils/                 # FormatarValores, UtilsServices
    ├── enum/                      # pages_routes.dart, http_methods.dart
    ├── models/                    # 26 models — serialização MANUAL fromJson/toJson
    ├── pages/                     # 🔴 ÁRVORE LEGADA (código morto, não roteada)
    ├── pages_routes/              # 🔴 rota legada (app_pages.dart morto)
    ├── routes/                    # ✅ app_pages.dart ATIVO (aponta p/ core/features)
    └── services/                  # 🔴 DUPLICADO de core/services (legado)
```

### Duplicações confirmadas (todas → 🔴 descartar a versão legada)

| Conceito | Versão ATIVA (manter) | Versão LEGADA (descartar) |
|----------|----------------------|---------------------------|
| Contratos de serviço | `core/abstracts/` | `Interfaces/` |
| Serviços | `core/services/` | `services/` |
| Rotas | `routes/app_pages.dart` | `pages_routes/app_pages.dart` |
| Telas | `core/features/*/view/` | `pages/*/view/` |
| Cores | `core/theme/config/` | `config/` |

## 2. Inconsistências de convenção observadas

- **Capitalização irregular:** `Interfaces/`, `Hive_services.dart`, `Endpoints.dart`, `custom_Scaffold/` (deveria ser snake_case e minúsculo conforme guia Dart).
- **Erros de digitação propagados:** `custom_colos.dart` (→ colors), `custom_dropwn_button.dart` (→ dropdown), `trasferencia` (→ transferencia), `consulta_nf_saida` x `ConsultaNfSaida` no enum.
- **Mistura de PT/EN** em nomes de identificadores e arquivos.

> Todas registradas em [04-quality/conventions-and-lint.md](../04-quality/conventions-and-lint.md).

## 3. Estrutura Oficial do Template Corporativo

> **Estrutura oficial:** a estrutura abaixo é derivada diretamente da árvore `core/` ativa do legado, conforme especificado em [corporate-template-blueprint.md](../07-template-blueprint/corporate-template-blueprint.md) §2. Mantém a stack e os padrões em produção (GetX, Hive, Dio, feature-first, abstracts/controller/repository/view).

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
    │   ├── text_fields/             #   LoginTextField, HeaderSearchTextField,
    │   │                            #   SurfaceTextField, GrayTextField, CustomTextField
    │   ├── navbars/                 #   CustomAppBar, AppBottomNavigation
    │   ├── headers/                 #   GradientHeader
    │   ├── scaffolds/               #   custom_scaffold/ (controller/view/model)
    │   ├── lists/                   #   CustomListTile, custom_list_view/, CustomPlutoGridTable
    │   ├── cards/                   #   ClientListTile
    │   ├── steppers/                #   AppStepIndicator
    │   ├── dialogs/                 #   custom_alert.dart, custom_message.dart
    │   ├── modals/                  #   ClienteDetalheSheet
    │   ├── badges/                  #   AppBadge
    │   ├── avatars/                 #   AppAvatar
    │   ├── buttons/                 #   AppButton, AppIconButton
    │   ├── toast/                   #   CustomToast
    │   ├── dropdowns/               #   CustomDropdownButton
    │   ├── loading/                 #   overlay global (controller + view)
    │   ├── empty_states/            #   CustomErrorWidget, EmptyStateMessage
    │   └── common/                  #   átomos sem categoria própria (AppDivider,
    │                                #   Gap, AppProgressBar, SectionHeader)
    ├── constants/                  # endpoints.dart
    ├── enum/                       # pages_routes.dart, http_methods.dart
    ├── models/                     # DTOs (fromJson/toJson manual — padrão atual)
    └── routes/                     # app_pages.dart (GetPages)
```

> **Atualização (2026-07-13):** `components/` foi reorganizado de estrutura plana para categorizada por
> tipo de widget, e a duplicação de `TextField`/estado-vazio/card-de-cliente entre telas foi eliminada.
> Ver [components-catalog-direction-app1.md](../03-design-system/components-catalog-direction-app1.md)
> para o catálogo atual (distinto do catálogo do legado em
> [components-catalog.md](../03-design-system/components-catalog.md)).
>
> **Atualização (2026-07-18):** nova categoria `steppers/`, com `AppStepIndicator` — unificou duas
> classes privadas `_Stepper` quase-idênticas (Orçamento e Cadastro de Cliente). Ver
> [components-catalog-direction-app1.md §2.4](../03-design-system/components-catalog-direction-app1.md).

Esta estrutura **remove apenas** as árvores duplicadas e mortas (ver §1), **sem trocar bibliotecas**. Ver [corporate-template-blueprint.md](../07-template-blueprint/corporate-template-blueprint.md) para mapeamento detalhado legado → template.

> ⚠️ **Consideração futura (NÃO aplicar agora).** A direção atual é preservar a stack (ver [documentation-stance](../00-overview/documentation-stance.md)). O conteúdo abaixo é apenas conhecimento técnico para decisão futura.

Uma estrutura alternativa futura com separação de camadas `domain/data/presentation` e bibliotecas modernas (Riverpod, go_router, get_it) poderia ser:

```
lib/
├── main.dart                      # apenas runApp + bootstrap delegado
├── bootstrap.dart                 # inicialização (env, DI, storage, error handlers)
└── src/
    ├── app/
    │   ├── app_widget.dart        # MaterialApp.router / GetMaterialApp
    │   ├── di/                    # módulos de injeção de dependência (Bindings)
    │   └── router/                # definição de rotas tipadas
    ├── core/                      # FUNDAÇÃO compartilhada (sem regra de negócio)
    │   ├── config/                # env, flavors, constantes de ambiente
    │   ├── error/                 # Failure/Exception, mapeamento de erros
    │   ├── network/               # cliente HTTP (Dio) + interceptors + Result
    │   ├── storage/               # storage seguro + cache local
    │   ├── logging/               # logger + observabilidade
    │   ├── theme/                 # design system (cores, tipografia, AppTheme)
    │   ├── i18n/                  # internacionalização
    │   ├── utils/                 # helpers, formatters, extensions
    │   └── widgets/               # widgets compartilhados (design system)
    ├── features/
    │   └── <feature>/
    │       ├── domain/            # entidades + contratos (abstracts)
    │       ├── data/              # models (DTO) + repository impl + datasource
    │       └── presentation/      # controller/state + view + commands
    └── shared/                    # tipos e contratos transversais
```
