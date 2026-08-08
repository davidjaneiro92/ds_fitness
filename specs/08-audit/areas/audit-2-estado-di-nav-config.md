# Auditoria — Área 2: GetX (Estado), Injeção de Dependência, Navegação, Configurações Globais e Bootstrap

> **Data:** 2026-06-24  
> **Auditor:** Claude Sonnet 4.6 (automático)  
> **Método:** Leitura direta dos arquivos-fonte do legado + comparação com os docs listados abaixo.  
> **Postura de referência:** `documentation-stance.md` e `ADR-0001` — preservar GetX; alternativas externas são "consideração futura", não recomendação ativa.

---

## Docs auditados

| Arquivo | Escopo |
|---------|--------|
| `02-infrastructure/state-management.md` | Estado reativo GetX |
| `02-infrastructure/dependency-injection.md` | DI via `Get.put` |
| `02-infrastructure/navigation.md` | Roteamento GetX |
| `02-infrastructure/configuration.md` | Bootstrap, endpoints, ambiente, cores |
| `01-architecture/adr/0001-state-management-and-di.md` | Decisão arquitetural oficial |

---

## Código inspecionado

- `lib/main.dart` (bootstrap completo)
- `lib/src/enum/pages_routes.dart`
- `lib/src/enum/http_methods.dart`
- `lib/src/constants/Endpoints.dart`
- `lib/src/core/features/settings_app/controller/settings_app_controller.dart`
- `lib/src/core/features/settings_app/repository/settings_app_repository.dart`
- `lib/src/core/features/settings_app/view/settings_app_view.dart`
- `lib/src/core/features/nfs_pedidos/controller/nfs_pedidos_controller.dart`
- `lib/src/core/features/conferir_material_saida/controller/conferir_material_saida_controller.dart`
- `lib/src/config/custom_colos.dart`
- `lib/src/core/theme/config/custom_colos.dart`

---

## Itens auditados

### Item 1 — Estado GetX: `Rx`/`.obs`/`Obx`

**Classificação: 1 — Completamente documentado.**

`state-management.md` cobre todos os tipos `Rx` utilizados (`RxBool`, `RxString`, `RxDouble`, `RxInt`, `RxList<T>`, `RxMap<K,V>`, `Rx<T>`, `Rx<File?>`), os dois padrões de atualização (`.value =` e `.refresh()`), o ciclo de vida `onInit`/`onReady`/`onClose`, o uso de `Obx` nas views, e o uso de `StatefulWidget` para estado local. Exemplos reais são extraídos dos arquivos corretos.

**Evidências de aderência:**  
- `NfsPedidosController:24-63` — `RxList`, `RxMap` usados exatamente como documentados.  
- `ConferirMaterialSaidaController:33-54` — `RxDouble`, `RxInt`, `RxBool`, `Rx<PedidoVenda>` com objeto dummy documentado.  
- `ConferirMaterialSaidaController:173-188` — `.refresh()` documentado na seção 2.3.

---

### Item 2 — Ciclo de vida: `onInit`/`onReady`/`onClose`

**Classificação: 1 — Completamente documentado.**

`state-management.md` secs. 2.4 e 2.5 documentam o padrão de `onInit` assíncrono (apenas `SettingsAppController` tem lógica real), `onReady` vazio na maioria, e o `.close()` manual verboso em `onClose`.

**Evidências de aderência:**  
- `SettingsAppController:21-25` — `onInit` assíncrono carregando `baseUrl` e `logger`, exatamente como documentado.  
- `NfsPedidosController:66-84` — `onInit`/`onReady` vazios + `.close()` manual em 6 variáveis, descrito na seção 2.5.  
- `ConferirMaterialSaidaController:69-96` — `.close()` manual + reset de `.value` antes do close, padrão não explicitado no doc mas inofensivo (detalhe menor).

---

### Item 3 — Injeção de dependência: sequência de 18 `Get.put` no `main.dart`

**Classificação: 1 — Completamente documentado.**

`dependency-injection.md` reproduz a sequência exata de `Get.put`, nomeia todos os 18 singletons (6 serviços/utilitários + 12 controllers de feature) e explica as dependências implícitas de ordem. `configuration.md` desdobra a sequência em tabela com 16 passos numerados e diagrama de dependências.

**Evidências de aderência (código vs. doc):**

| Posição real em `main.dart` | O que é registrado | Documentado em `dependency-injection.md`? |
|---|---|---|
| Linha 68 | `Get.put(LoadingController())` | Sim (sem tag de interface — correto) |
| Linha 69 | `Get.put<UtilsServicesInterfaces>(UtilsServices())` | Sim |
| Linha 70 | `Get.put<LogServicesInterface>(LogServices())` | Sim |
| Linha 74 | `Get.put<HiveServicesInterface>(HiveServices())` | Sim |
| Linha 77 | `Get.put<HttpManagerInterfaces>(HttpManager())` | Sim |
| Linha 78 | `Get.put<FormatarValoresInterface>(FormatarValores())` | Sim |
| Linha 79 | `Get.put(CustomItemListViewController())` | Sim |
| Linhas 80–91 | 11 controllers de feature | Sim (todos os 11) |

A ordem documentada no doc coincide exatamente com a ordem real no arquivo.

**Lacuna menor:** O doc lista `TrasferenciaIndustriaController` como o 12.º e último controller (linha 91 do `main.dart`). A contagem de "12 controllers de feature" está correta, mas a tabela no doc não inclui a linha `Get.put<ItensPedidoSaidaControllerInterface>(ItensPedidoSaidaController())` (linha 86) explicitamente na lista numerada — ela está presente no bloco de código mas não na tabela textual. Impacto: mínimo.

---

### Item 4 — `initializeApp()` e sua posição no bootstrap

**Classificação: 1 — Completamente documentado.**

`configuration.md` passos 8 e 4 descrevem exatamente que `'variaves_ambiente'` deve ser aberta antes de `initializeApp()`, que esta função lê `SettingsAppRepository.getBaseUrl()` e atribui a `baseUrl` global em `Endpoints.dart`, e que o fallback é `'http://192.168.1.192:7021'`.

**Evidências de aderência:**  
- `Endpoints.dart:6-12` — `SettingsAppRepositoryInterface repository = SettingsAppRepository()` no escopo global + `Future<void> initializeApp()` lendo `repository.getBaseUrl()`, idêntico ao documentado.  
- `main.dart:67-71` — abertura de `'variaves_ambiente'` (linha 67) antes de `initializeApp()` (linha 71), confirmando o diagrama de dependências do doc.

---

### Item 5 — `GetMaterialApp`: parâmetros, `OKToast`, `builder`, tema

**Classificação: 1 — Completamente documentado.**

`configuration.md` sec. 2 lista todos os parâmetros configurados: `title`, `debugShowCheckedModeBanner`, `initialRoute`, `getPages`, `builder` com `LoadingWidget`, `OKToast` como wrapper externo, e `ThemeData` com `colorScheme`, `scaffoldBackgroundColor`, `useMaterial3`.

**Evidências de aderência:**  
- `main.dart:101-122` — todos os parâmetros batem com o documentado, sem divergência.

---

### Item 6 — `enum PagesRoutes` e `AppPages`

**Classificação: 1 — Completamente documentado.**

`navigation.md` secs. 2.1–2.4 reproduzem o enum completo (14 valores), a tabela de rotas com path e view associada, e documenta o arquivo legado `lib/src/pages_routes/app_pages.dart` como código morto.

**Evidências de aderência:**  
- `pages_routes.dart:5-24` — 14 valores no enum, idênticos à tabela do doc, incluindo as inconsistências de nomenclatura (`ConsultaNfSaida` em PascalCase, `Trasferencia` com nome ≠ path).

---

### Item 7 — `enum HttpMethods`

**Classificação: 3 — Não documentado nos docs desta área.**

`http_methods.dart` define `POST`, `PUT`, `PATCH`, `DELETE`, `GET` como constantes estáticas numa classe abstrata. Ele **não é mencionado** em nenhum dos cinco documentos auditados nesta área (`state-management.md`, `dependency-injection.md`, `navigation.md`, `configuration.md`, `ADR-0001`).

**Observação:** O arquivo é documentado em `02-infrastructure/api-configuration.md` (linha 167), que está **fora do escopo desta área de auditoria**. Dentro desta área, a lacuna existe.

**Evidência da ausência:** busca por `http_methods|HttpMethods` nos cinco documentos alvo retornou zero resultados.

---

### Item 8 — `Endpoints.dart`: `baseUrl`, IP hardcoded, getters dinâmicos

**Classificação: 1 — Completamente documentado.**

`configuration.md` sec. 3 descreve a variável global mutável `baseUrl`, o IP hardcoded `'http://192.168.1.192:7021'` como fallback, os getters estáticos dinâmicos, a função `initializeApp()`, e a duplicação entre `grupoAlmoxarifado` e `grupoAlmox`. A tabela de endpoints (sec. 3.3) lista todos os 18 getters.

**Evidências de aderência:**  
- `Endpoints.dart:8` — `String? baseUrl = 'http://192.168.1.192:7021'` — documentado.  
- `Endpoints.dart:14-34` — todos os 18 getters listados no doc. Confirmada a duplicidade `grupoAlmoxarifado` (linha 18) e `grupoAlmox` (linha 31) apontando para o mesmo path.

---

### Item 9 — `settings_app/`: troca de `baseUrl` e flag `logger` em runtime

**Classificação: 1 — Completamente documentado.**

`configuration.md` sec. 4 descreve a box `'variaves_ambiente'`, as chaves `'baseUrl'` e `'logger'`, a interface `SettingsAppRepositoryInterface` com os quatro métodos (`setBaseUrl`, `getBaseUrl`, `setLogger`, `getLogger`), o `SettingsAppController.onInit()` carregando os valores, e o efeito da view com `TextField` + `CupertinoSwitch`.

**Evidência crítica documentada:** O doc registra explicitamente que salvar a URL na view **não atualiza a variável global `baseUrl` imediatamente** — a mudança só entra em vigor no próximo boot do app. Isso é confirmado pelo código:  
- `settings_app_controller.dart:39-45` — `setBaseUrl()` chama `repository.setBaseUrl()` (persiste no Hive) mas nunca atualiza `baseUrl` em `Endpoints.dart`.  
- `Endpoints.dart:8` — variável global mutável, mas só lida em `initializeApp()` (chamada uma vez no `main()`).

---

### Item 10 — Padrão de controllers GetX: `NfsPedidosController` e `ConferirMaterialSaidaController`

**Classificação: 1 — Completamente documentado.**

Os dois controllers foram usados como amostras de verificação. Os padrões documentados em `state-management.md` e `dependency-injection.md` estão presentes:

- `Get.find()` em campos de instância para serviços (`HiveServicesInterface`, `LogServicesInterface`) ✓
- Repositório instanciado com `new` (sem DI) — documentado em `dependency-injection.md` sec. 2.4 como anti-pattern ✓  
  `NfsPedidosController:20`: `final NfsPedidosRepositoryInterface repository = NfsPedidosRepository();`  
  `ConferirMaterialSaidaController:65`: `ConferirMaterialSaidaRepositoryInterface repository = ConferirMaterialSaidaRepository();`
- `onInit`/`onReady` vazios + `onClose` com `.close()` manual ✓
- Ausência de `Bindings`/`lazyPut` ✓

---

### Item 11 — Duplicação de `CustomColors` (`custom_colos.dart`)

**Classificação: 1 — Completamente documentado.**

`configuration.md` sec. 7 identifica os dois arquivos, confirma que são byte-a-byte idênticos, indica qual o caminho canônico (`lib/src/core/theme/config/`), e recomenda remoção da cópia em `lib/src/config/`.

**Evidência:** Leitura direta dos dois arquivos confirma conteúdo 100% idêntico (20 linhas, mesma classe `CustomColors`, mesmo mapa `_opacidade` com a cor `#003A88`).

---

### Item 12 — ADR-0001: postura de preservar GetX

**Classificação: 5 — Inconsistências doc×código (entre documentos).**

O `ADR-0001` define que GetX é mantido como base e que Riverpod/go_router/get_it são registrados apenas como "conhecimento — não adotado". O `documentation-stance.md` reforça que alternativas externas ficam em blocos "Consideração futura", sem contaminar a direção atual.

**Conflito identificado nos docs auditados:**

Os três docs de infraestrutura (`state-management.md`, `dependency-injection.md`, `navigation.md`) contêm seções "Opção B" e "Veredictos" que **recomendam ativamente** a substituição da stack, contrariando o ADR-0001 e o `documentation-stance.md`:

| Arquivo | Trecho conflitante | Linha(s) |
|---------|-------------------|---------|
| `state-management.md` | Tabela linha `GetxController`: `"no template moderno considerar StateNotifier (Riverpod) ou Cubit"` | L149 |
| `state-management.md` | Tabela linha `Get.find()` nas views: `"preferir ... ref.watch (Riverpod)"` | L157 |
| `state-management.md` | Seção "Migrar para Riverpod + get_it" com código de exemplo completo | L190–196 |
| `state-management.md` | **Veredicto:** `"Se o projeto novo terá equipe maior... a migração para Riverpod + get_it + go_router vale o custo"` | L196 |
| `dependency-injection.md` | Seção "Opção B — get_it + injectable (recomendada para template corporativo)" | L211 |
| `dependency-injection.md` | **Veredicto:** `"get_it + injectable oferece a melhor combinação... Para um template corporativo reutilizável"` | L234 |
| `navigation.md` | Tabela linha `GetMaterialApp`: `"preferir go_router para deep links e guards nativos"` | L172 |
| `navigation.md` | Tabela linha `Get.toNamed`: `"substituir por context.go() se migrar para go_router"` | L174 |
| `navigation.md` | Tabela linha `GetPage sem Bindings`: `"migrar para go_router + get_it"` | L182 |
| `navigation.md` | Seção "Opção B — go_router (recomendada para template corporativo)" | L242–276 |
| `navigation.md` | **Veredicto:** `"Para um template corporativo novo, go_router é a escolha clara"` | L276 |

**Natureza do conflito:** Esses trechos não estão isolados em blocos "Consideração futura" — aparecem como recomendações principais nas seções de classificação e veredictos, com código completo de exemplo. O ADR-0001 (datado de 2026-06-24, mesma data que esta auditoria) claramente invalida essa orientação, mas os docs de infraestrutura não foram atualizados para refletir a decisão.

**Impacto:** Alto. Um desenvolvedor que leia `dependency-injection.md` receberá a recomendação `"get_it + injectable é recomendado para template corporativo"` sem saber que o ADR posterior revogou essa direção.

---

### Item 13 — Versão do GetX: divergência entre docs e `pubspec.yaml`

**Classificação: 5 — Inconsistência doc×código.**

| Fonte | Versão informada |
|-------|-----------------|
| `state-management.md` (cabeçalho) | `get: 4.6.6` |
| `dependency-injection.md` (cabeçalho) | `get: 4.6.6` |
| `navigation.md` (cabeçalho) | `get: 4.6.6` |
| `ADR-0001` (contexto) | `get 4.7.2` |
| `pubspec.yaml` (fonte da verdade) | `get: ^4.6.6` (constraint, não versão lockada) |

O ADR-0001 menciona `get 4.7.2`, enquanto o `pubspec.yaml` declara `^4.6.6`. A versão efetivamente instalada depende do `pubspec.lock` (não inspecionado), mas a divergência nos docs é factual: o ADR cita uma versão que não está no `pubspec.yaml`.

---

### Item 14 — Decisões não documentadas nesta área

**Classificação: 8 — Decisões não documentadas.**

As seguintes decisões de implementação existem no código sem correspondência nos docs desta área:

1. **`SettingsAppRepository` instanciado fora do container GetX em dois lugares:**  
   - `Endpoints.dart:6`: `SettingsAppRepositoryInterface repository = SettingsAppRepository()` (variável global de arquivo, fora de qualquer classe/container).  
   - `settings_app_controller.dart:16`: `SettingsAppRepositoryInterface repository = SettingsAppRepository()` (campo do controller).  
   Isso significa que existem **duas instâncias distintas** do repositório em runtime, mas ambas acessam a mesma box Hive — funcionalmente equivalentes, mas a razão arquitetural não está documentada.

2. **`onClose` de `ConferirMaterialSaidaController` reseta `.value` antes de fechar:**  
   ```dart
   // conferir_material_saida_controller.dart:81-84
   totalPesoBr.value = 0.0;
   totalPesoLiq.value = 0.0;
   totalSaldo.value = 0.0;
   totalEmb.value = 0;
   ```  
   Isso não está documentado em `state-management.md`. Pode ser um padrão defensivo ou redundante.

3. **`SettingsAppRepository` faz `Get.find<UtilsServicesInterfaces>()` sem usar o resultado:**  
   - `settings_app_repository.dart:11`: `final UtilsServicesInterfaces utilsServices = Get.find();` — campo declarado mas não usado no código visível. Comentários de log estão todos comentados. Cria dependência oculta de ordem de inicialização.

4. **`SettingsAppView` usa `StatelessWidget` mas lê `controller.getUrl.value` fora de `Obx`:**  
   - `settings_app_view.dart:22`: `_baseUrlController.text = controller.getUrl.value;` dentro de `build()`, sem `Obx`. O valor não atualiza reativamente se `getUrl` mudar enquanto a tela está aberta.

---

### Item 15 — Duplicações entre docs

**Classificação: 6 — Duplicações entre docs.**

A sequência do bootstrap (`main.dart`) é descrita em **três lugares distintos**:

| Doc | Seção | Nível de detalhe |
|-----|-------|-----------------|
| `configuration.md` | Sec. 1 (tabela com 16 passos + diagrama) | Principal — mais completo |
| `dependency-injection.md` | Sec. 2.1 (bloco de código completo) | Cópia parcial — foca nos `Get.put` |
| `navigation.md` | Sec. 2.1 (bloco de código da `MyApp`) | Cópia parcial — foca no `GetMaterialApp` |

A triplicação não é problemática desde que os três estejam sincronizados, mas qualquer mudança no `main.dart` exige atualizar três arquivos. Risco de divergência futura.

---

## Percentual estimado de cobertura da área

**Cobertura estimada: 82%**

**Justificativa:**

| Sub-área | Cobertura | Observação |
|----------|-----------|------------|
| Estado GetX (`Rx`/`Obx`/ciclo de vida) | 95% | Documentação muito fiel; falta detalhe do reset `.value` no `onClose` |
| DI (`Get.put`, ordem, interfaces) | 90% | Sequência completa; lacuna menor na tabela textual do `ItensPedidoSaidaController` |
| Navegação (rotas, enum, métodos) | 90% | Completa; arquivo legado documentado |
| Bootstrap / `initializeApp()` / `ErrorWidget` | 95% | Nível de detalhe exemplar em `configuration.md` |
| `Endpoints.dart` / `baseUrl` / settings | 90% | Completo; comportamento assíncrono do `setBaseUrl` bem registrado |
| `HttpMethods` (nesta área) | 0% | Não documentado nos 5 docs alvo desta área |
| Decisões implícitas (repo duplicado, `Get.find` sem uso) | 20% | Não registradas |
| **Conflito ADR × docs de infraestrutura** | Identificado | 11 trechos conflitantes não reconciliados |

O desconto de 18% vem de: `HttpMethods` ausente dos docs desta área (−5%), decisões não documentadas (−5%), e os conflitos ativos entre ADR-0001 e os três docs de infraestrutura que contêm recomendações de troca de stack não isoladas em blocos "Consideração futura" (−8%).

---

## Achados-chave (resumo executivo)

1. **Cobertura técnica é sólida (82%):** os cinco documentos auditados descrevem fielmente o código legado. A sequência de bootstrap, o padrão DI, os tipos `Rx`, o enum de rotas e o mecanismo `baseUrl`/Hive estão completamente documentados com evidências reais.

2. **Conflito crítico doc×ADR:** `state-management.md`, `dependency-injection.md` e `navigation.md` contêm **11 trechos** que recomendam ativamente Riverpod, get_it e go_router como direção para o template corporativo. O ADR-0001 e o `documentation-stance.md` revogam essa direção. Os docs de infraestrutura não foram atualizados após a publicação do ADR. Ação necessária: mover ou envolver esses trechos em blocos `> Consideração futura (não aplicar agora)`.

3. **Inconsistência de versão GetX:** ADR-0001 cita `get 4.7.2`; `pubspec.yaml` declara `^4.6.6`. Corrigir o ADR para referenciar a constraint real do `pubspec.yaml`.

4. **`HttpMethods` não documentado nesta área:** está coberto em `api-configuration.md`, fora do escopo desta área. Os docs `state-management.md`, `dependency-injection.md`, `navigation.md`, `configuration.md` e `ADR-0001` não o mencionam.

5. **Triplicação do bootstrap:** a sequência do `main.dart` aparece em três docs — `configuration.md` (completa), `dependency-injection.md` (parcial) e `navigation.md` (parcial). Sincronização necessária em futuras mudanças.

6. **Decisões implícitas não registradas:** (a) duas instâncias distintas de `SettingsAppRepository` em runtime; (b) campo `utilsServices` declarado mas não utilizado em `SettingsAppRepository`; (c) `SettingsAppView` lê `controller.getUrl.value` fora de `Obx`; (d) reset manual de `.value` no `onClose` de `ConferirMaterialSaidaController`.

7. **Duplicação de `CustomColors` documentada corretamente** — ambos os arquivos (`lib/src/config/custom_colos.dart` e `lib/src/core/theme/config/custom_colos.dart`) são de fato idênticos, conforme registrado em `configuration.md` sec. 7.
