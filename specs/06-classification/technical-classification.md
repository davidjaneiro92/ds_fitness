# Classificação Técnica Consolidada

> Consolidação de todas as análises (T2–T7). Cada item da fundação técnica recebe uma classificação e uma justificativa, orientando o que levar (e como) para o Template Corporativo.

## Legenda

| Símbolo | Classificação | Ação no template |
|---------|---------------|------------------|
| ✅ | Reutilizar sem alterações | Copiar o conceito/código como está |
| 🟢 | Reutilizar com melhorias | Levar o conceito, ajustar a implementação |
| 🟡 | Refatorar | Manter a ideia, reescrever |
| 🟠 | Substituir | Trocar por solução moderna equivalente |
| 🔴 | Descartar | Não levar (morto, acoplado a negócio ou inseguro) |

---

## 1. Arquitetura & Padrões

| Item | Classificação | Justificativa |
|------|---------------|---------------|
| Arquitetura feature-first | ✅ | Organização por funcionalidade é moderna e escalável |
| Programação por interface (abstracts/DIP) | ✅ | Base ideal para testes e troca de implementação |
| Command Pattern (operações de negócio) | ✅ | Coesão e testabilidade; manter como padrão de feature |
| Repository Pattern | ✅ | Isola fonte de dados corretamente |
| Camadas view/controller/repository | 🟢 | Boas; formalizar como domain/data/presentation |
| Service Locator (GetX) | 🟡 | Formalizar com DI explícita (Bindings ou get_it) |
| Árvore legada `lib/src/pages/` | 🔴 | Código morto — não roteado |
| Duplicações (services, Interfaces, routes, config) | 🔴 | Resquício de migração inacabada |
| `HttpManager` chamando UI + navegação | 🔴 | Quebra de camadas; infra não pode tocar UI/router |

## 2. Gerenciamento de Estado / DI / Navegação

| Item | Classificação | Justificativa |
|------|---------------|---------------|
| Estado reativo `Rx`/`.obs` + `Obx` | ✅ | Uso correto e granular |
| Registro por interface `Get.put<I>(Impl)` | ✅ | Boa prática de DI |
| Loading overlay global via `builder` | 🟢 | Conceito ótimo; desacoplar de regra |
| Enum `PagesRoutes` centralizando rotas | 🟢 | Bom; evoluir para rotas tipadas |
| `GetxController` base | 🟢 | Manter se ficar em GetX; senão Notifier/Bloc |
| `onClose` com `.close()` manual redundante | 🟡 | Boilerplate desnecessário |
| `Get.find()` nas views | 🟡 | Acoplamento implícito; injetar |
| DI eager (todos controllers no boot) | 🟠 | Usar `lazyPut`/Bindings ou get_it |
| Argumentos de rota como `Map` não tipado | 🟠 | Usar objetos tipados |
| Ausência de route guards | 🟠 | Adicionar middleware/guard de auth |
| `Rx<T>` com objetos dummy/datas mágicas | 🟠 | Usar `Rx<T?>` nullable |
| Repositórios instanciados com `new` no controller | 🔴 | Fora do container — impossível mockar |
| `pages_routes/app_pages.dart` (rota morta) | 🔴 | Deletar |

## 3. API / Storage / Serialização

| Item | Classificação | Justificativa |
|------|---------------|---------------|
| Interface `HttpManagerInterfaces` | ✅ | Contrato limpo |
| Enum `HttpMethods` | ✅ | Reutilizável direto |
| Wrapper sobre Dio | 🟢 | Bom conceito; remover UI/nav de dentro |
| Refresh token automático (401→retry→signOut) | 🟢 | Boa ideia; mover p/ interceptor, limitar retries |
| Interface `HiveServices` | 🟢 | Boa abstração; tipar e tornar awaitable |
| `_handleDioError` (mapa de erros) | 🟡 | Extrair para mapeador de erros tipado |
| Endpoints em `constants` com IP hardcoded | 🟠 | Usar `AppConfig` + `--dart-define` por ambiente |
| Sem timeouts/interceptors/CancelToken | 🟠 | Configurar no cliente do template |
| Serialização manual `fromJson/toJson` | 🟠 | `freezed` + `json_serializable` |
| `toMap()` alias de `toJson()` | 🔴 | Inútil |
| `badCertificateCallback => true` | 🔴 | **Crítico de segurança** — remover |
| Token JWT em Hive não criptografado | 🔴 | **Crítico** — `flutter_secure_storage` |
| `hive` / `hive_flutter` (sem manutenção) | 🔴 | Substituir o backend de storage |

## 4. Design System

| Item | Classificação | Justificativa |
|------|---------------|---------------|
| Material 3 + seed color corporativa | ✅ | Boa base de tema |
| `LoadingWidget` + controller | 🟢 | Overlay global reutilizável |
| `CustomTextField`, `CustomToast` | 🟢 | Reutilizáveis com pequenos ajustes |
| `CustomListView`/`CustomItemListView` (lista configurável por colunas) | 🟢 | Componente de maior valor; generalizar |
| `CustomErrorWidget`, `CustomDropdownButton`, alertas | 🟡 | Reutilizáveis após desacoplar |
| `CustomAppBar` (logo hardcoded), `CustomListTile` (onTap vazio), `CustomPlutogridTable` | 🟠 | Generalizar/parametrizar |
| Duplicata `custom_colos.dart` | 🔴 | Remover duplicata + typo |
| Tema sem tipografia/spacing/dark mode/tokens | 🟠 | Criar design tokens + AppTheme light/dark |
| `CustomScaffoldView` (menu/rotas/auth fixos), `CustomExpansion` (dados fictícios) | 🔴 | Acoplados a negócio |

## 5. i18n / Qualidade

| Item | Classificação | Justificativa |
|------|---------------|---------------|
| `intl` para formatação pt_BR | ✅ | Manter |
| Localização inline do PlutoGrid | 🟡 | Extrair para constantes/arb |
| i18n estruturada (arb/gen-l10n) | 🟠 | **Ausente** — adicionar `flutter_localizations` |
| Strings de UI hardcoded (PT/EN misturado) | 🔴 | Externalizar para `.arb` |
| Testes (`test/` só com smoke default) | 🔴 | Cobertura 0% — criar estratégia real |
| Lint `flutter_lints` básico (avoid_print off) | 🟠 | `very_good_analysis` + regras |
| ~60 `print()` em produção | 🔴 | Substituir por logger estruturado |
| Typos sistêmicos (Trasferencia, colos, dropwn, nameFild) | 🔴 | Corrigir nomenclatura |

## 6. Bibliotecas — PRESERVAR a stack atual

> **Postura:** bibliotecas em produção são **preservadas** (ver [documentation-stance.md](../00-overview/documentation-stance.md)). Nenhuma recebe "Substituir/Descartar" por modernização. Riscos de longo prazo ficam em "Consideração futura". Detalhe em [library-deep-catalog.md](../05-libraries/library-deep-catalog.md).

| Lib | Versão resolvida | Classificação | Observação |
|-----|------------------|---------------|------------|
| get (GetX) | 4.7.2 | ✅ Reutilizar | Base de estado/DI/navegação — preservar |
| dio | 5.8.0 | ✅ Reutilizar | Cliente HTTP via `HttpManager` |
| hive / hive_flutter | 2.2.3 / 1.1.0 | ✅ Reutilizar | Cache e config de ambiente |
| logger | 2.5.0 | ✅ Reutilizar | Log local + remoto |
| intl | 0.19.0 | ✅ Reutilizar | Formatação pt_BR |
| json_annotation | 4.9.0 | ✅ Reutilizar | Serialização (padrão manual atual) |
| pluto_grid | 8.0.0 | ✅ Reutilizar | DataGrid; encapsular tipos é melhoria opcional |
| oktoast | 3.4.0 | ✅ Reutilizar | Mecanismo ativo de toasts |
| fluttertoast | 8.2.12 | ✅ Reutilizar | Manter; consolidação é consideração futura |
| barcode_scan2 | 4.5.1 | ✅ Reutilizar | Scanner de código de barras |
| image_picker, mask_text_input_formatter, tab_container, flutter_speed_dial, cupertino_icons | — | ✅ Reutilizar | Estáveis |
| flutter_launcher_icons, test, flutter_lints (dev) | — | ✅ Reutilizar | Ferramentas de dev |

> **Considerações futuras (não aplicar agora):** monitorar `hive` 2.x (manutenção); `fluttertoast` redundante com `oktoast`; alternativas de `barcode_scan2`. Apenas informativo.

---

## 7. Síntese — o que vai para o template

- **Levar (preservar):** stack atual completa (GetX, Hive, Dio, logger, pluto_grid, oktoast, intl…), feature-first, interfaces/DIP, Command, Repository, wrapper HTTP, overlay de loading, lista configurável, enum de rotas, refresh token, tela de erro amigável, Material 3 + seed, config de ambiente via Hive.
- **Melhorar dentro da stack (opcional, retrocompatível):** `Get.lazyPut`/`Bindings`, `Get.find()` consistente, `Rx<T?>`, guards via `GetMiddleware`, `HiveServices` awaitable, retry de refresh limitado, SSL só em debug, tema com tokens + dark, i18n `.arb`, testes, lint mais estrito, crash reporting.
- **Eliminar (interno):** árvore legada `pages/` e duplicações (`services/`, `Interfaces/`, `pages_routes/`, `config/`), acoplamento infra↔UI/navegação, credencial hardcoded, `print()`, typos, `toMap()` redundante.

> Nenhuma biblioteca em produção é eliminada. "Melhorar" usa sempre os mesmos pacotes.
