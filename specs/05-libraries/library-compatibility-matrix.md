# Matriz de Compatibilidade de Bibliotecas (referência técnica)
## Template Flutter Corporativo — Análise T7

> ⚠️ **POSTURA ATUAL (atualizada):** o template **preserva a stack atual** — ver [documentation-stance.md](../00-overview/documentation-stance.md). As recomendações de **substituição/modernização** abaixo são **conhecimento técnico ("consideração futura")**, **não** a direção atual. Para o uso real (motivo, onde, dependências, versões resolvidas), consulte o **[Catálogo Profundo de Bibliotecas](library-deep-catalog.md)**, que reflete a decisão de preservação. Trate as colunas "Alternativa moderna"/"Substituir" deste documento como informativas.

**Projeto legado:** `controle_separacao_aplicativo`
**SDK Dart:** `^3.5.3` (resolvido: `>=3.5.3 <4.0.0`)
**Flutter mínimo:** `>=3.24.0`
**Data da análise:** 2026-06-24
**Analista:** Engenharia Reversa T7

> **Nota sobre dados de versão:** As versões "últimas disponíveis" foram verificadas com base no conhecimento do modelo até agosto de 2025 e em padrões de release histórico. Dados marcados com ⚠️ devem ser confirmados manualmente em [pub.dev](https://pub.dev) antes de migração para produção.

---

## 1. Tabela Mestre de Compatibilidade

| Biblioteca | Versão no lock | Última versão (est. 2026) | Finalidade | Arquivos de uso principais | Manutenção | Compat. Flutter atual | Risco | Alternativa moderna | Classificação |
|---|---|---|---|---|---|---|---|---|---|
| `get` (GetX) | 4.7.2 | ~4.7.x (sem 5.x lançado) | Estado, DI, navegação, RxDart, snackbar | 60+ arquivos (`controllers`, `repositories`, `views`, `main.dart`) | ⚠️ Ativo mas controverso; sem breaking changes em 2025 | Compatível (Dart 3, null-safe) | **Alto** | `flutter_riverpod` + `go_router` + `get_it` | ✅ Reutilizar (substituição: consideração futura) |
| `dio` | 5.8.0+1 | ~5.8.x | Cliente HTTP, interceptors, cancelamento | `http_manager.dart` (core + legacy) | Ativo, bem mantido | ✅ Compatível | **Baixo** | — (manter) | ✅ Reutilizar |
| `hive` | 2.2.3 | 2.2.3 (sem nova versão) | Storage local key-value (NoSQL) | `Hive_services.dart`, `settings_app_repository.dart`, `main.dart` | 🔴 **Parado desde 2022** | ⚠️ Funciona mas sem suporte a Dart 3 futuro | **Alto** | `hive_ce` / `isar` / `drift` | ✅ Reutilizar (substituição: consideração futura — monitorar) |
| `hive_flutter` | 1.1.0 | 1.1.0 (sem nova versão) | Integração Hive com Flutter | `main.dart` | 🔴 **Parado** (co-dependente do hive) | ⚠️ Mesmas restrições do hive | **Alto** | `hive_ce_flutter` / `isar` | ✅ Reutilizar (substituição: consideração futura — monitorar) |
| `intl` | 0.19.0 | 0.19.0 | Formatação de datas, moedas, i18n | `formatar_valores.dart`, vários models e repositories | Ativo (equipe Dart/Flutter) | ✅ Compatível | **Baixo** | — (manter; monitorar 0.20) | ✅ Reutilizar |
| `json_annotation` | 4.9.0 | 4.9.0 | Anotações para serialização JSON | Declarado; provavelmente usado em models com `json_serializable` dev | Ativo (equipe Dart) | ✅ Compatível | **Baixo** | — | ✅ Reutilizar |
| `logger` | 2.5.0 | 2.5.0 | Logging colorido em console | `http_manager`, `log_services`, controllers, repositories (30+ arquivos) | Ativo | ✅ Compatível | **Baixo** | — (manter) | ✅ Reutilizar |
| `mask_text_input_formatter` | 2.9.0 | 2.9.0 | Máscara de texto em campos de input | `conferir_material_entrada.dart` (view) | Ativo | ✅ Compatível | **Baixo** | — | ✅ Reutilizar |
| `image_picker` | 1.1.2 | ~1.1.x | Seleção de imagens da galeria/câmera | `conferir_material_entrada_controller.dart` (2 arquivos) | Ativo (equipe Flutter) | ✅ Compatível | **Baixo** | — (manter) | ✅ Reutilizar |
| `barcode_scan2` | 4.5.1 | ~4.5.x | Scanner de código de barras | `conferir_material_saida_controller.dart` (2 arquivos) | ⚠️ Baixa atividade; última release 2023 | ⚠️ Funciona mas sem atualização ativa | **Médio** | `mobile_scanner` | 🟡 Refatorar (substituição: consideração futura) |
| `fluttertoast` | 8.2.12 | ~8.2.x | Toast nativo (Android/iOS) | `utils_services.dart` (2 arquivos) | ⚠️ Baixa atividade | ✅ Compatível | **Médio** | `oktoast` (já usado) ou `snackbar` nativo | 🟡 Refatorar |
| `oktoast` | 3.4.0 | 3.4.0 | Toast overlay puro Flutter | `utils_services.dart`, `custom_toast.dart`, `main.dart` | Moderada atividade | ✅ Compatível | **Baixo** | — (manter; consolidar com fluttertoast) | 🟢 c/ melhorias |
| `tab_container` | 3.5.3 | 3.5.3 | Widget de abas com animação personalizada | `nfs_pedidos.dart` (view, 2 arquivos) | Ativo | ✅ Compatível | **Baixo** | — | ✅ Reutilizar |
| `flutter_speed_dial` | 7.0.0 | 7.0.0 | FAB com menu de ações (speed dial) | `conferir_material_saida.dart`, `conferir_material_transferencia.dart`, `consulta_lotes_saida.dart` | Ativo | ✅ Compatível | **Baixo** | — | ✅ Reutilizar |
| `pluto_grid` | 8.0.0 | ~8.x | Data grid avançado com edição inline | `consulta_nf_saida_controller.dart`, `consulta_nf_saida.dart`, `nfs_pedidos.dart`, `models/consultar_nf_saida_model.dart` | ⚠️ Manutenção lenta; breaking changes frequentes | ✅ Funciona com Flutter 3.x | **Médio** | `data_table_2` / `syncfusion_flutter_datagrid` | 🟡 Refatorar |
| `cupertino_icons` | 1.0.8 | 1.0.8 | Ícones estilo iOS | Uso via `CupertinoIcons` | Ativo (equipe Flutter) | ✅ Compatível | **Baixo** | — | ✅ Reutilizar |
| **DEV:** `flutter_launcher_icons` | 0.13.1 | ~0.14.x ⚠️ | Geração de ícones do app | `pubspec.yaml` (build tool) | Ativo | ✅ Compatível | **Baixo** | — | ✅ Reutilizar |
| **DEV:** `test` | 1.25.7 | ~1.25.x | Framework de testes Dart | Dev only | Ativo (equipe Dart) | ✅ Compatível | **Baixo** | — | ✅ Reutilizar |
| **DEV:** `flutter_lints` | 4.0.0 | ~4.0.x | Regras de lint Flutter | `analysis_options.yaml` | Ativo (equipe Flutter) | ✅ Compatível | **Baixo** | — | ✅ Reutilizar |

---

## 2. Análise Detalhada por Biblioteca

### 2.1. `get` (GetX) — ✅ Reutilizar (preservar)

**Versão atual:** 4.7.2 | **Declarada:** ^4.6.6

**Uso no projeto:**
GetX está onipresente — aparece em mais de 60 arquivos. O projeto usa:
- **Gerenciamento de estado:** `Obx`, `RxTypes` (`.obs`, `RxString`, `RxBool`, etc.)
- **DI e controllers:** `Get.find<T>()`, `Get.put<T>()`, `Get.lazyPut<T>()`
- **Navegação:** `Get.to()`, `Get.back()`, `Get.offAll()`
- **Snackbar:** `Get.snackbar()`
- **MaterialApp:** `GetMaterialApp`
- **Validators:** via `Get.context`

**Análise de risco:**
GetX é uma biblioteca "all-in-one" que acumula funcionalidades de navegação, estado, DI, rede (GetConnect), i18n e mais. Isso cria acoplamento extremo — a aplicação inteira depende de um único pacote. Em 2024-2025:

- O mantenedor principal (Jonatas Borges) reduziu drasticamente a atividade de contribuição
- Versão 5.0 foi prometida há anos e nunca lançada formalmente
- Issues críticas ficam abertas por meses sem resposta
- A comunidade Flutter mainstream não recomenda GetX para novos projetos corporativos
- Uso de `Get.context` e `Get.find` dificultam testes unitários
- Breaking changes silenciosas entre minor versions foram registradas

**Riscos futuros:**
- Possível incompatibilidade com Dart 3.x futuro (macros, WASM) se o mantenedor não atualizar
- Dívida técnica: impossível testar controllers que usam `Get.find` sem setup completo do GetX
- Código de navegação e estado misturado dificultam arquitetura limpa

> ⚠️ **Consideração futura (NÃO aplicar agora).** A direção atual é preservar a stack (ver [documentation-stance](../00-overview/documentation-stance.md)). O conteúdo abaixo é apenas conhecimento técnico para decisão futura.

Uma alternativa futura seria substituir as responsabilidades do GetX por bibliotecas especializadas:

| Função GetX | Alternativa futura (não aplicar agora) |
|---|---|
| Estado (Obx/RxTypes) | `flutter_riverpod` (providers reativos) |
| DI (Get.find/put) | `get_it` (service locator simples) |
| Navegação (Get.to/off) | `go_router` (oficial Flutter) |
| Snackbar | `ScaffoldMessenger.of(context).showSnackBar` |
| GetMaterialApp | `MaterialApp.router` com `go_router` |

Esforço estimado de uma eventual migração: Alto — requer refatoração de toda a arquitetura.

---

### 2.2. `dio` — ✅ Reutilizar

**Versão atual:** 5.8.0+1 | **Declarada:** ^5.7.0

**Uso no projeto:**
Centralizado em `http_manager.dart` (versão legada em `lib/src/services/` e versão refatorada em `lib/src/core/services/`). Usado para todas as chamadas HTTP REST com:
- Interceptors de autenticação
- Configuração de base URL (settings via Hive)
- Timeout e error handling
- `dio/io.dart` para configuração de certificados SSL

**Análise:**
Dio 5.x é a versão estável mais moderna, com null-safety completo, Dart 3 compatível, suporte a WASM e manutenção ativa pela comunidade. A biblioteca é o padrão de fato para HTTP em Flutter corporativo.

**Recomendação:** Manter. Unificar os dois `http_manager.dart` em um único (o do `core/`).

---

### 2.3. `hive` + `hive_flutter` — ✅ Reutilizar (preservar; risco de longo prazo monitorado)

**Versão atual:** hive 2.2.3 + hive_flutter 1.1.0

**Uso no projeto:**
- `main.dart`: inicialização (`Hive.initFlutter()`, registro de adapters)
- `Hive_services.dart`: serviço de acesso às boxes (configurações, cache)
- `settings_app_repository.dart`: persistência de URL base e credenciais

**Análise — RISCO CRÍTICO:**
Hive 2.x é o caso mais crítico desta análise:

- **Última release de hive:** 2.2.3 (Setembro 2022 — mais de 3 anos sem atualização)
- **Última release de hive_flutter:** 1.1.0 (2022)
- O repositório oficial no GitHub tem centenas de issues abertas sem resposta
- Sem suporte declarado a Dart 3 macros ou WASM
- Sem suporte a `TypeAdapter` gerado via macros
- O mantenedor original (isar_creator) migrou o foco para o Isar

**Alternativas disponíveis em 2026:**

| Alternativa | Descrição | Indicado para |
|---|---|---|
| `hive_ce` | Fork comunitário ativo do hive 2.x com patches | Migração de curto prazo (drop-in replacement) |
| `isar` | DB NoSQL de alta performance (mesmo criador do hive) | Apps complexos com queries |
| `drift` | SQLite com type-safety e migrations | Apps com estrutura relacional |
| `shared_preferences` | Key-value simples | Somente configurações simples |
| `flutter_secure_storage` | Credenciais seguras (Keychain/KeyStore) | Dados sensíveis (tokens, URLs com credenciais) |

**Uso atual no projeto é simples** (URL base + credenciais de acesso). Hive funciona corretamente para os casos de uso atuais do projeto.

> ⚠️ **Consideração futura (NÃO aplicar agora).** A direção atual é preservar a stack (ver [documentation-stance](../00-overview/documentation-stance.md)). O conteúdo abaixo é apenas conhecimento técnico para decisão futura.

Uma alternativa futura seria migrar para `shared_preferences` (configurações) + `flutter_secure_storage` (credenciais). Se o projeto evoluir para cache complexo, `hive_ce` poderia ser um bridge temporário para `isar`. Porém, **essa migração não é a ação atual** — o Hive segue preservado enquanto funciona.

---

### 2.4. `intl` — ✅ Reutilizar

**Versão atual:** 0.19.0

**Uso no projeto:**
Amplamente usado em:
- `formatar_valores.dart` (formatação de moeda BRL, datas PT-BR)
- Models (`nf_model.dart`, `pedido_venda.dart`, `itens_nf_model.dart`, `transferenci_lote.dart`)
- Repositories de conferência e separação
- `log_services.dart` (timestamp de log)

**Análise:**
`intl 0.19.0` foi lançado com suporte a Dart 3 e é compatível com Flutter 3.x. A versão `0.20.x` pode trazer mudanças menores de API, mas 0.19 permanece funcional e segura.

**Recomendação:** Manter. Monitorar lançamento de `0.20.x` e migrar quando estável.

---

### 2.5. `json_annotation` — ✅ Reutilizar

**Versão atual (lock):** 4.9.0 | **Declarada:** ^4.4.0

**Uso no projeto:**
Declarado como dependência de runtime (necessário porque `json_serializable` — dev dependency que gera código — precisa das anotações em runtime). Provavelmente usado em models com `@JsonSerializable()`.

**Nota:** Não foi encontrado `json_serializable` no `pubspec.yaml` como dev dependency explícita, mas `json_annotation` no lock sugere uso ou planejamento. O arquivo `pubspec.yaml` pode ter omitido `json_serializable` das dev_dependencies ou os models usam `fromJson`/`toJson` manuais.

**Análise:** Biblioteca oficial da equipe Dart, sempre atualizada. 4.9.0 é compatível com Dart 3.

**Recomendação:** Manter. Confirmar se `json_serializable` está como dev dep ou se é geração manual.

---

### 2.6. `logger` — ✅ Reutilizar

**Versão atual:** 2.5.0

**Uso no projeto:**
Presente em 30+ arquivos. Centralizado via `log_services.dart` com interface `ILogServices`. Usado em:
- `http_manager.dart` (logs de requisições)
- Todos os controllers (erro, info, debug)
- Todos os repositories
- Commands pattern

**Análise:**
Logger 2.x tem null-safety completo, formatação customizável, níveis de log (verbose/debug/info/warning/error), e é amplamente adotado. Bem mantido pela comunidade.

**Recomendação:** Manter. A abstração via interface (`ILogServices`) está correta — permite trocar a implementação no futuro.

---

### 2.7. `mask_text_input_formatter` — ✅ Reutilizar

**Versão atual:** 2.9.0

**Uso no projeto:**
Usado em `conferir_material_entrada.dart` (view) para mascaramento de campos de input (possivelmente NF, lote, CNPJ).

**Análise:**
Biblioteca simples, estável e bem mantida. Sem riscos conhecidos. Compatível com Dart 3.

**Recomendação:** Manter.

---

### 2.8. `image_picker` — ✅ Reutilizar

**Versão atual:** 1.1.2

**Uso no projeto:**
Usado em `conferir_material_entrada_controller.dart` (2 arquivos: legado e core). Finalidade: captura de foto de documento/embalagem na conferência de entrada.

**Análise:**
Plugin oficial da equipe Flutter. Atualizado regularmente. 1.1.x tem null-safety, Dart 3 e suporte a Android/iOS/Web/Desktop.

**Recomendação:** Manter. Atualizar para a última minor quando disponível.

---

### 2.9. `barcode_scan2` — 🟡 Refatorar (substituição: consideração futura)

**Versão atual:** 4.5.1 | **Declarada:** ^4.3.3

**Uso no projeto:**
Usado em `conferir_material_saida_controller.dart` (2 arquivos: legado e core):
- `import 'package:barcode_scan2/platform_wrapper.dart'`
- `import 'package:barcode_scan2/barcode_scan2.dart'`

Finalidade: leitura de código de barras para conferência de material na saída.

**Análise:**
`barcode_scan2` é um fork do `barcode_scan` original que usa a câmera nativa para escanear. Problemas identificados:

- Última release significativa: 2023
- Usa abordagem de "scanner de câmera nativa via plugin" que requer configuração específica Android/iOS
- Não suporta câmera contínua (precisa abrir tela dedicada a cada scan)
- Não suporta overlay customizável
- Issues de compatibilidade com versões recentes do Android (permissions model)

**Alternativa recomendada: `mobile_scanner`**
- Mantido ativamente (2024-2025)
- Suporta scanner contínuo (stream de câmera)
- Overlay completamente customizável
- Suporta múltiplos formatos (QR, EAN, Code128, etc.)
- Compatível com Android/iOS/Web/Desktop
- API mais moderna e flexível

> ⚠️ **Consideração futura (NÃO aplicar agora).** A direção atual é preservar a stack (ver [documentation-stance](../00-overview/documentation-stance.md)). O conteúdo abaixo é apenas conhecimento técnico para decisão futura.

Uma alternativa futura seria substituir por `mobile_scanner ^5.x` ou `^6.x`. Por enquanto, `barcode_scan2` segue em uso pois funciona nos dispositivos do projeto.

---

### 2.10. `fluttertoast` — 🟡 Refatorar

**Versão atual:** 8.2.12 | **Declarada:** ^8.2.8

**Uso no projeto:**
Usado em `utils_services.dart` (2 arquivos: legado e core), junto com `oktoast`. As duas bibliotecas coexistem fazendo a mesma coisa — toasts de feedback para o usuário.

**Análise:**
`fluttertoast` usa o sistema de Toast **nativo** do Android e um overlay customizado no iOS. Isso significa:
- Comportamento inconsistente entre plataformas
- Não funciona em Web e Desktop
- Atividade de manutenção reduzida em 2024-2025
- Duplicidade de responsabilidade com `oktoast` já presente no projeto

**Recomendação:** Eliminar `fluttertoast` e consolidar todos os toasts em `oktoast` (que já está no projeto e é puro Flutter, multiplataforma). Alternativamente, usar `ScaffoldMessenger` com SnackBar (solução nativa Flutter, sem dependência externa).

---

### 2.11. `oktoast` — 🟢 c/ melhorias

**Versão atual:** 3.4.0

**Uso no projeto:**
Usado em `utils_services.dart`, `custom_toast.dart`, e inicializado em `main.dart` (`OKToast` widget no topo da árvore). Finalidade: toasts overlay puro Flutter.

**Análise:**
`oktoast` é uma solução 100% Flutter (não usa código nativo), funciona em todas as plataformas, tem API simples e é suficientemente mantida. Já está corretamente inicializado no `main.dart`.

**Melhoria sugerida:** Eliminar a duplicidade com `fluttertoast` e centralizar todos os feedbacks de toast em `oktoast` via o `custom_toast.dart` já existente.

**Recomendação:** Manter e consolidar (remover `fluttertoast`).

---

### 2.12. `tab_container` — ✅ Reutilizar

**Versão atual:** 3.5.3

**Uso no projeto:**
Usado em `nfs_pedidos.dart` (view, 2 arquivos: legado e core). Fornece abas animadas com visual customizado para separar NFs de Entrada e Pedidos de Saída.

**Análise:**
Biblioteca de UI com manutenção ativa, visual diferenciado das abas padrão Flutter. Compatível com Dart 3.

**Recomendação:** Manter se o design de abas for mantido no template. Avaliar se `DefaultTabController` nativo não atende — `tab_container` adiciona animação e estética customizada.

---

### 2.13. `flutter_speed_dial` — ✅ Reutilizar

**Versão atual:** 7.0.0

**Uso no projeto:**
Usado em 3 views:
- `conferir_material_saida.dart`
- `conferir_material_transferencia.dart`
- `consulta_lotes_saida.dart`

Finalidade: FAB expandível com múltiplas ações (confirmar conferência, imprimir etiqueta, dividir lote).

**Análise:**
`flutter_speed_dial` 7.x é bem mantido, tem null-safety e Dart 3 support, amplamente usado na comunidade Flutter.

**Recomendação:** Manter.

---

### 2.14. `pluto_grid` — 🟡 Refatorar

**Versão atual:** 8.0.0

**Uso no projeto:**
Usado em:
- `consulta_nf_saida_controller.dart` (PlutoGridStateManager)
- `consulta_nf_saida.dart` (view, PlutoGrid widget)
- `nfs_pedidos.dart` (view)
- `models/consultar_nf_saida_model.dart` (PlutoColumn, PlutoRow)
- `consulta_nf_saida_controller_interface.dart` (interface usa PlutoGridStateManager)

Finalidade: exibição de NFs de saída em grid tabular com sorting, filtragem e seleção de linha.

**Análise:**
`pluto_grid` 8.x funciona com Flutter 3.x, mas apresenta desafios:

- Breaking changes significativas entre major versions (6→7→8) com migrações não-triviais
- Manutenção dependente de um único mantenedor (bosskmk)
- Interface vaza tipos do pluto_grid para as abstrações do projeto (anti-pattern detectado: `PlutoGridStateManager` na interface `consulta_nf_saida_controller_interface.dart`)
- Performance pode degradar com grids muito grandes sem virtualização cuidadosa
- Licença MIT mas sem empresa/time por trás

**Recomendação para o template:**
- **Curto prazo:** Manter 8.0.0, mas encapsular atrás de uma abstração própria (remover `PlutoGridStateManager` das interfaces)
- **Médio prazo:** Avaliar `data_table_2` (mais simples) ou `syncfusion_flutter_datagrid` (licença comercial mas suporte garantido) para o template corporativo

---

### 2.15. `cupertino_icons` — ✅ Reutilizar

**Versão atual:** 1.0.8

**Análise:** Pacote oficial Flutter para ícones iOS. Sempre atualizado junto com o SDK.

**Recomendação:** Manter.

---

### 2.16. Dev: `flutter_launcher_icons` — ✅ Reutilizar

**Versão atual:** 0.13.1

**Análise:** Ferramenta de build para geração de ícones do app. Ativa e bem mantida. Configuração no `pubspec.yaml` cobre Android, iOS, Web, Windows e macOS.

**Recomendação:** Manter.

---

### 2.17. Dev: `test` + `flutter_lints` — ✅ Reutilizar

**Versões:** `test 1.25.7` | `flutter_lints 4.0.0`

**Análise:** Ambos são pacotes oficiais da equipe Dart/Flutter. Sempre atualizados.

**Observação importante:** O projeto **não possui testes escritos** além da estrutura básica gerada pelo SDK. O template corporativo deve incluir exemplos de testes unitários e de widget.

**Recomendação:** Manter e adicionar cobertura de testes.

---

## 3. Riscos Especiais Identificados

### 3.1. Dependência Circular hive ↔ get

O `Hive_services.dart` usa `Get.find()` para injetar dependências, e o `settings_app_repository.dart` usa tanto `hive` quanto `get`. Isso significa que a migração de qualquer um dos dois impacta o outro — devem ser migrados em conjunto.

### 3.2. Acoplamento pluto_grid nas interfaces

O arquivo `lib/src/core/features/consulta_nf_saida/abstracts/consulta_nf_saida_controller_interface.dart` importa diretamente `package:pluto_grid/pluto_grid.dart` na interface de abstração. Isso é um anti-pattern arquitetural — a interface vaza um tipo concreto de biblioteca externa, impossibilitando a troca do grid sem alterar a interface.

**Correção imediata:** Criar um DTO próprio (`GridRow`, `GridColumn`) e converter para tipos PlutoGrid apenas na implementação concreta.

### 3.3. Duplicação de Serviços (legacy vs core)

O projeto tem dois conjuntos paralelos de serviços:
- `lib/src/services/` (legado)
- `lib/src/core/services/` (refatorado)

Ambos são usados em paralelo, causando imports de ambas as versões em alguns módulos. O template deve consolidar em apenas uma estrutura.

### 3.4. Toast Duplicado (fluttertoast + oktoast)

`utils_services.dart` importa ambos `fluttertoast` e `oktoast` simultaneamente. Provável que tenham sido adicionados em momentos diferentes sem refatoração. Resulta em comportamento inconsistente (toast nativo vs overlay Flutter).

---

## 4. Stack para o Template Corporativo

> ⚠️ **Consideração futura (NÃO aplicar agora).** A direção atual é preservar a stack (ver [documentation-stance](../00-overview/documentation-stance.md)). As seções 4.1–4.3 e 4.5–4.7 abaixo são apenas conhecimento técnico para decisão futura — a stack atual (GetX, Hive, Dio) é a fundação preservada.

### 4.1. Estado e Gerenciamento Reativo

**Stack atual (preservar):** `get` (Obx/Rx/GetxController)

| Função | Biblioteca atual | Alternativa futura (não aplicar agora) | Justificativa |
|---|---|---|---|
| Estado global/reativo | `get` (Obx/Rx) | `flutter_riverpod ^2.x` | Testável, type-safe, sem singleton global |
| Estado local simples | `get` (GetxController) | `StatefulWidget` / `ValueNotifier` | Evitar overhead para estados simples |

### 4.2. Injeção de Dependência

**Stack atual (preservar):** `get` (Get.find/put)

| Função | Biblioteca atual | Alternativa futura (não aplicar agora) | Justificativa |
|---|---|---|---|
| DI / Service Locator | `get` (Get.find/put) | `get_it ^8.x` | Simples, testável, sem acoplamento ao framework |
| DI declarativa | — | `injectable ^2.x` (opcional) | Geração de código para DI com `get_it` |

### 4.3. Navegação

**Stack atual (preservar):** `get` (Get.to/off) + `app_pages.dart`

| Função | Biblioteca atual | Alternativa futura (não aplicar agora) | Justificativa |
|---|---|---|---|
| Rotas | `get` (Get.to/off) + `app_pages.dart` | `go_router ^14.x` | Oficial Flutter, deep linking, type-safe routes, shell routes |

### 4.4. HTTP e Rede

**Stack atual (preservar e reutilizar):** `dio ^5.x`

| Função | Biblioteca atual | Recomendação template | Justificativa |
|---|---|---|---|
| Cliente HTTP | `dio ^5.8.0+1` | `dio ^5.x` (manter) | Best-in-class para Flutter corporativo |

### 4.5. Storage Local

**Stack atual (preservar):** `hive` 2.x

| Função | Biblioteca atual | Alternativa futura (não aplicar agora) | Justificativa |
|---|---|---|---|
| Configurações simples | `hive` 2.x | `shared_preferences ^2.x` | Simples, oficial Flutter, sem setup |
| Credenciais/tokens | `hive` 2.x | `flutter_secure_storage ^9.x` | Usa Keychain/KeyStore nativo |
| Cache de dados | `hive` 2.x | `hive_ce ^2.x` (transitório) → `isar ^4.x` (definitivo) | hive_ce é drop-in; isar para complexidade maior |

### 4.6. Serialização JSON

**Stack atual (preservar):** serialização manual `fromJson`/`toJson`

| Função | Biblioteca atual | Alternativa futura (não aplicar agora) | Justificativa |
|---|---|---|---|
| Anotações | `json_annotation ^4.x` | Manter | Oficial Dart |
| Geração de código | (manual — padrão atual) | `json_serializable ^6.x` + `freezed` (dev) | Geração automática de fromJson/toJson |

### 4.7. Logging e Observabilidade

**Stack atual (preservar):** `logger ^2.x`

| Função | Biblioteca atual | Alternativa futura (não aplicar agora) | Justificativa |
|---|---|---|---|
| Logging de desenvolvimento | `logger ^2.x` | Manter | Simples, colorido, customizável |
| Crash reporting (prod) | — | `firebase_crashlytics` ou `sentry_flutter` | Necessário para apps corporativos em produção |

### 4.8. UI — Tabela/Grid

| Função | Biblioteca atual | Recomendação template | Justificativa |
|---|---|---|---|
| Data grid | `pluto_grid ^8.0` | `pluto_grid ^8.x` (manter) + encapsulamento | Funcional; encapsular atrás de abstração própria |

### 4.9. UI — Feedback ao Usuário

| Função | Biblioteca atual | Recomendação template | Justificativa |
|---|---|---|---|
| Toast overlay | `oktoast ^3.x` + `fluttertoast ^8.x` | `oktoast ^3.x` apenas | Eliminar fluttertoast; oktoast é puro Flutter |
| Snackbar de ação | `get` (Get.snackbar) | `ScaffoldMessenger` nativo | Sem dependência externa |

### 4.10. UI — Widgets Especiais

| Função | Biblioteca atual | Recomendação template | Justificativa |
|---|---|---|---|
| Speed Dial FAB | `flutter_speed_dial ^7.x` | Manter | Ativo e funcional |
| Tab customizada | `tab_container ^3.x` | Manter | Visual diferenciado |
| Máscaras de input | `mask_text_input_formatter ^2.x` | Manter | Simples e funcional |
| Ícones Cupertino | `cupertino_icons ^1.x` | Manter | Oficial |

### 4.11. Scanner

**Stack atual (preservar):** `barcode_scan2 ^4.x`

| Função | Biblioteca atual | Alternativa futura (não aplicar agora) | Justificativa |
|---|---|---|---|
| Barcode/QR Scanner | `barcode_scan2 ^4.x` | `mobile_scanner ^5.x` ou `^6.x` | Ativo, contínuo, multiplataforma |

### 4.12. Captura de Imagem

| Função | Biblioteca atual | Recomendação template | Justificativa |
|---|---|---|---|
| Câmera / galeria | `image_picker ^1.x` | Manter | Oficial Flutter |

### 4.13. i18n e Formatação

| Função | Biblioteca atual | Recomendação template | Justificativa |
|---|---|---|---|
| Formatação / i18n | `intl ^0.19.x` | Manter | Oficial Dart |

### 4.14. Testes

| Função | Biblioteca atual | Recomendação template | Justificativa |
|---|---|---|---|
| Testes unitários | `test ^1.x` | Manter + adicionar `flutter_test` | Oficial |
| Mocks | — | `mocktail ^1.x` | Mais simples que mockito, sem geração de código |

### 4.15. Build Tools

| Função | Biblioteca atual | Recomendação template | Justificativa |
|---|---|---|---|
| Ícones do app | `flutter_launcher_icons ^0.13.x` | Manter | Funcional |
| Lint | `flutter_lints ^4.x` | Manter | Oficial |
| Geração JSON | — | `json_serializable ^6.x` (dev) | Adicionar ao template |
| Build runner | — | `build_runner ^2.x` (dev) | Necessário para json_serializable |

---

## 5. Resumo Executivo — Classificações e Prioridades de Ação

### 5.1. Resumo de Classificações

> **Nota de postura:** As classificações abaixo refletem a direção atual de **preservar a stack**. Classificações "Substituir/Descartar" foram movidas para "Consideração futura". Ver [documentation-stance](../00-overview/documentation-stance.md).

| Classificação | Bibliotecas |
|---|---|
| ✅ Reutilizar (sem mudança) | `get` (GetX), `hive`, `hive_flutter`, `dio`, `intl`, `json_annotation`, `logger`, `mask_text_input_formatter`, `image_picker`, `tab_container`, `flutter_speed_dial`, `cupertino_icons`, `flutter_launcher_icons`, `test`, `flutter_lints` |
| 🟢 Reutilizar c/ melhorias | `oktoast` (consolidar, remover fluttertoast) |
| 🟡 Refatorar (manter mas melhorar uso) | `fluttertoast` (eliminar em favor de oktoast — sem nova lib), `pluto_grid` (encapsular interface), `barcode_scan2` (refatorar encapsulamento) |

### 5.2. Ações Atuais (sem migração de biblioteca)

| Prioridade | Ação | Impacto | Esforço |
|---|---|---|---|
| 🟠 P1 — Alto | Encapsular token em `HiveAesCipher` (dentro do próprio Hive) | Segurança — sem trocar biblioteca | Baixo-Médio |
| 🟠 P2 — Alto | Eliminar `fluttertoast`, consolidar em `oktoast` (já presente) | Consistência UI | Muito Baixo |
| 🟡 P3 — Médio | Encapsular `pluto_grid` por DTOs próprios nas interfaces | Arquitetura | Médio |
| 🟢 P4 — Melhoria | Refatorar boilerplate de serialização com `json_annotation` já presente | Produtividade | Baixo |

### 5.3. Considerações Futuras (NÃO aplicar agora)

> ⚠️ **Consideração futura (NÃO aplicar agora).** A direção atual é preservar a stack (ver [documentation-stance](../00-overview/documentation-stance.md)). O conteúdo abaixo é apenas conhecimento técnico para decisão futura.

| Item (futuro) | Substituição possível | Esforço estimado |
|---|---|---|
| `hive`/`hive_flutter` → se risco de compatibilidade Dart 4 se confirmar | `shared_preferences` + `flutter_secure_storage` (ou `hive_ce`) | Baixo-Médio |
| `barcode_scan2` → se surgir incompatibilidade de plataforma | `mobile_scanner ^5.x` | Baixo |
| `get` → para projeto com equipe maior e vida útil >3 anos | `riverpod` + `go_router` + `get_it` | Alto |
| Serialização manual → para reduzir boilerplate futuro | `json_serializable` + `freezed` | Médio |
| Crash reporting em produção | `firebase_crashlytics` ou `sentry_flutter` | Baixo |

---

*Documento gerado em: 2026-06-24 — Análise T7 — Template Flutter Corporativo*
*Verificação manual recomendada em pub.dev para versões mais recentes antes de migração para produção.*
