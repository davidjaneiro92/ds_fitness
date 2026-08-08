# Referência de Engenharia Consolidada

> Visão **única e consistente** de toda a fundação técnica do legado `controle_separacao_aplicativo`, consolidada a partir das análises detalhadas. **Postura:** preservar a stack atual (ver [documentation-stance.md](documentation-stance.md)). Cada seção aponta para o documento aprofundado correspondente.

## 1. Identidade técnica

| Item | Valor |
|------|-------|
| Flutter / Dart (legado) | 3.24.x / 3.5.x · SDK `^3.5.3` |
| Tamanho | 189 arquivos Dart · ~18.7k LOC |
| Plataformas | Android, iOS, Windows, macOS, Linux, Web |
| Espinha dorsal | **GetX** (estado + DI + navegação) |
| Rede / dados | **Dio** (`HttpManager`) · **Hive** (cache/config) |
| Arquitetura | Feature-first + interfaces + Command + Repository |

## 2. Arquitetura (resumo)

Camadas: **View → Controller → Command → Repository → Services → Models**, com **contratos por interface** em quase tudo. Árvore ativa: `lib/src/core/...`. Existe uma árvore legada **morta** (`lib/src/pages/`) e duplicações que o template remove.
→ [architecture-overview](../01-architecture/architecture-overview.md) · [folder-structure](../01-architecture/folder-structure.md) · [design-patterns](../01-architecture/design-patterns.md)

## 3. Estado, DI e navegação (GetX) — preservar

- **Estado:** `Rx`/`.obs` + `Obx`/`GetX` em `GetxController`.
- **DI:** `Get.put<Interface>(Impl)` no `main.dart` (eager) — melhoria opcional: `lazyPut`/`Bindings`.
- **Navegação:** `GetMaterialApp` + `getPages` + enum `PagesRoutes`.
→ [state-management](../02-infrastructure/state-management.md) · [dependency-injection](../02-infrastructure/dependency-injection.md) · [navigation](../02-infrastructure/navigation.md) · [ADR-0001](../01-architecture/adr/0001-state-management-and-di.md)

## 4. Rede, autenticação e dados — preservar

- **`HttpManager` (Dio):** monta headers + Bearer, mapeia erros, **refresh token transparente** no 401.
- **Autenticação:** login via `PATCH /api/v1/autenticacao/login`; token guardado em Hive (`Cache_aplicativo` → `Autenticacao`); injeção via `token()`; `signOut()` limpa e redireciona.
- **Sem Interceptor Dio formal** (lógica dentro de `restRequest`; `LogInterceptor` comentado).
- **Persistência:** `HiveServices` (cache genérico) + box `variaves_ambiente` (config).
- **Models:** `fromJson`/`toJson` manual (padrão atual mantido).
→ [api-configuration](../02-infrastructure/api-configuration.md) · [authentication-and-interceptors](../02-infrastructure/authentication-and-interceptors.md) · [local-storage](../02-infrastructure/local-storage.md) · [services-catalog](../02-infrastructure/services-catalog.md)

## 5. Configuração e ambiente — destaque

`baseUrl` e flags (`logger`) ficam na box Hive `variaves_ambiente`, **editáveis em runtime** pela tela de settings (sem rebuild). `initializeApp()` lê `baseUrl` no bootstrap; fallback hardcoded (melhoria opcional: `--dart-define`).
→ [configuration](../02-infrastructure/configuration.md)

## 6. Tratamento de erros, logs e segurança

- **Tela de erro amigável** via `ErrorWidget.builder` → `CustomErrorWidget` (⭐ alto valor).
- **Logs:** `LogServices` (pacote `logger`) com envio remoto condicional + auditoria de operações.
- **Segurança (achados factuais):** SSL aceito sem validação; token em cache não criptografado; credencial `KeyMaster` hardcoded — tratados como **melhorias retrocompatíveis**, não migração.
→ [custom-error-screen](../02-infrastructure/custom-error-screen.md) · [error-handling](../02-infrastructure/error-handling.md) · [logging-observability](../02-infrastructure/logging-observability.md) · [security](../02-infrastructure/security.md) · [ADR-0002](../01-architecture/adr/0002-security-and-storage.md)

## 7. Design system, componentes e i18n

- **Tema:** Material 3 + seed corporativa `#003A88` (sem dark mode / tokens — melhoria opcional).
- **Componentes de alto valor:** overlay de loading global (`LoadingController`+`LoadingWidget`), **lista configurável** (`custom_list_view`, colunas TEXT/DATA/NUMEROS/ICONBUTTON/CHECKBOX/COLOR), `CustomTextField`, `CustomToast`, alertas, `CustomDropdownButton`.
- **i18n:** apenas `intl` para formatação pt_BR; strings hardcoded (melhoria opcional: `.arb`).
→ [theming](../03-design-system/theming.md) · [components-catalog](../03-design-system/components-catalog.md) · [shared-widgets](../03-design-system/shared-widgets.md) · [i18n](../03-design-system/i18n.md)

## 8. Bibliotecas (preservadas)

Todas as libs de produção são **✅ Reutilizar**: `get`, `dio`, `hive`/`hive_flutter`, `logger`, `intl`, `json_annotation`, `pluto_grid`, `oktoast`, `fluttertoast`, `barcode_scan2`, `image_picker`, `mask_text_input_formatter`, `tab_container`, `flutter_speed_dial`, `cupertino_icons`.
→ [library-deep-catalog](../05-libraries/library-deep-catalog.md) · [library-compatibility-matrix](../05-libraries/library-compatibility-matrix.md) *(informativa)*

## 9. Qualidade

- **Testes:** cobertura efetiva 0% (só smoke default) — a arquitetura por interfaces facilita testes a criar.
- **Lint:** `flutter_lints` básico (`avoid_print` desativado; ~60 `print()`).
- **Convenções:** inconsistências e typos sistêmicos a padronizar.
→ [testing-strategy](../04-quality/testing-strategy.md) · [conventions-and-lint](../04-quality/conventions-and-lint.md)

## 10. Plano de reuso para o template

1. **Preservar** stack e padrões (seções 2–8).
2. **Limpar** (higiene interna): remover `pages/` e duplicações, corrigir typos, remover `print()`.
3. **Refinar** (opcional, mesma stack): `lazyPut`/`Bindings`, `Get.find()`, SSL só em debug, retry limitado, tokens/i18n/tema.
4. **Reaproveitar** os ativos prontos da seção 6–7.
→ [corporate-template-blueprint](../07-template-blueprint/corporate-template-blueprint.md) · [recommended-stack](../07-template-blueprint/recommended-stack.md) · [technical-classification](../06-classification/technical-classification.md)
