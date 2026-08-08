# Stack do Template (= Stack Atual Preservada)

> **Postura:** o Template Corporativo é construído sobre **exatamente a mesma stack** que já funciona em produção no legado. Esta página documenta essa stack como **fundação oficial**. Nada aqui recomenda substituição por modernização. Ver [documentation-stance.md](../00-overview/documentation-stance.md).

## 1. Stack oficial do template (por função)

| Função | Biblioteca (preservada) | Versão resolvida | Papel no template |
|--------|-------------------------|------------------|-------------------|
| **Estado** | `get` (GetX) | 4.7.2 | Estado reativo `Rx`/`.obs` + `Obx` |
| **Injeção de dependência** | `get` (GetX) | 4.7.2 | `Get.put`/`Get.find` por interface |
| **Navegação** | `get` (GetX) | 4.7.2 | `GetMaterialApp` + `getPages` + enum de rotas |
| **HTTP** | `dio` | 5.8.0 | Cliente HTTP encapsulado em `HttpManager` |
| **Persistência / cache** | `hive` + `hive_flutter` | 2.2.3 / 1.1.0 | Cache local e configs de ambiente |
| **Serialização** | `json_annotation` + manual | 4.9.0 | `fromJson`/`toJson` (padrão manual atual) |
| **Logging** | `logger` | 2.5.0 | Log local + envio remoto (`LogServices`) |
| **Toast / feedback** | `oktoast` (+ `fluttertoast`) | 3.4.0 / 8.2.12 | Mensagens de toast |
| **Tabela / grid** | `pluto_grid` | 8.0.0 | DataGrid com filtros/paginação |
| **Scanner** | `barcode_scan2` | 4.5.1 | Leitura de código de barras |
| **Imagens** | `image_picker` | 1.1.2 | Captura/seleção de imagem |
| **Máscaras** | `mask_text_input_formatter` | 2.9.0 | Formatação de inputs |
| **Abas** | `tab_container` | 3.5.3 | Contêiner de abas animadas |
| **FAB expansível** | `flutter_speed_dial` | 7.0.0 | Menu de ação flutuante |
| **i18n / formatação** | `intl` | 0.19.0 | Formatação pt_BR (datas/números/moeda) |
| **Ícones** | `cupertino_icons` | 1.0.8 | Ícones iOS |
| **Ícones de app** | `flutter_launcher_icons` (dev) | 0.13.1 | Geração multiplataforma |
| **Testes** | `flutter_test` + `test` (dev) | — / 1.25.7 | Infraestrutura de testes |
| **Lint** | `flutter_lints` (dev) | ^4.0.0 | Regras padrão Flutter |

> Catálogo completo (motivo, onde, dependências entre libs, impacto de atualização) em [library-deep-catalog.md](../05-libraries/library-deep-catalog.md).

## 2. Padrões oficiais do template (preservados do legado)

- **Arquitetura feature-first** (`core/features/<feature>/`).
- **Programação por interface** (abstracts) para serviços, controllers e repositórios.
- **Command Pattern** para operações de negócio (`controller/commands/`).
- **Repository Pattern** isolando a fonte de dados.
- **Service Locator** via GetX (`Get.put<Interface>(Impl)` no `main.dart`).
- **Overlay de loading global** (`LoadingController` + `LoadingWidget` no `builder`).
- **Tela de erro amigável** via `ErrorWidget.builder` ([detalhe](../02-infrastructure/custom-error-screen.md)).
- **Refresh token transparente** no `HttpManager`.
- **Config de ambiente editável em runtime** via Hive (`variaves_ambiente`) + tela de settings.

## 3. Melhorias internas recomendadas (SEM trocar a stack)

São ajustes que usam os **mesmos** pacotes/padrões, apenas com implementação mais limpa:

| Melhoria | Como (dentro da stack atual) |
|----------|------------------------------|
| Remover duplicação/código morto | Apagar `pages/`, `services/`, `Interfaces/`, `pages_routes/`, `config/` legados |
| DI sob demanda | Usar `Get.lazyPut`/`Bindings` do próprio GetX em vez de `Get.put` eager |
| Injeção consistente | Trocar `new HttpManager()`/`new LoginRepository()` por `Get.find()` |
| `HiveServices` awaitable | Métodos `void`+`await` → `Future<void>` |
| Refresh token seguro | Limitar profundidade de retry (contador) |
| SSL | Restringir `badCertificateCallback` a `kDebugMode` |
| Token em cache | Opcional: `HiveAesCipher` (sem mudar interface) |
| Endpoints | Opcional: `--dart-define` mantendo o override por Hive |

## 4. Considerações futuras (NÃO aplicar agora)

> Bloco informativo para decisão posterior do time — **não é a direção atual**.
>
> - `hive` 2.x está em modo de manutenção; monitorar para futuras versões do Dart/Flutter.
> - `fluttertoast` é redundante com `oktoast` (consolidação possível no futuro).
> - `barcode_scan2` tem alternativas mais novas; avaliar somente se surgir incompatibilidade.
> - Alternativas de stack (Riverpod/go_router/get_it, freezed) ficam registradas apenas como conhecimento, sem prioridade.
