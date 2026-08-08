# Auditoria 6 — Bibliotecas, Testes, Lint e Consistência Global entre Documentos

**Data:** 2026-06-24  
**Projeto legado:** `controle_separacao_aplicativo`  
**Documentação auditada:** `/specs` (todos os 35 `.md`)  
**Código auditado:** `pubspec.yaml`, `pubspec.lock` (via library-deep-catalog), `analysis_options.yaml`, `test/`

---

## 1. Completo — O que está totalmente coberto e consistente

### 1.1 Bibliotecas (Parte A)

| Item | Evidência |
|------|-----------|
| Todas as 19 deps de `pubspec.yaml` catalogadas em `library-deep-catalog.md` | Tabela Mestre lista: cupertino_icons, mask_text_input_formatter, get, dio, intl, json_annotation, tab_container, image_picker, barcode_scan2, fluttertoast, logger, hive, hive_flutter, oktoast, flutter_speed_dial, pluto_grid, flutter_launcher_icons, test, flutter_lints — 19/19 |
| Versões declaradas vs. resolvidas documentadas | `library-deep-catalog.md` inclui coluna "Versão declarada" e "Versão resolvida" para cada lib |
| Grafo de dependências internas documentado | Diagrama Mermaid completo em `library-deep-catalog.md` §Grafo |
| Dependências transitivas relevantes documentadas | Tabela de 7 transitivas (dio_web_adapter, path_provider, rxdart, image_picker_android/ios, cross_file, http_parser) |

### 1.2 Testes (Parte A)

| Item | Evidência |
|------|-----------|
| Estado real da pasta `test/` documentado fielmente | `testing-strategy.md` §1.1 confirma exatamente o que o código mostra: 1 arquivo (`widget_test.dart`), 0 testes reais, teste de counter inexistente no app |
| Ausência de mock libraries registrada | `testing-strategy.md` §1.2 lista explicitamente: `mocktail` ausente, `mockito` ausente, `integration_test` ausente, `golden_toolkit` ausente |
| Ausência de CI/CD documentada | §1.3 confirma zero arquivos de pipeline |
| Estratégia de testes recomendada completa | Pirâmide, estrutura de pastas, exemplos de código, roadmap por sprints |

### 1.3 Lint (Parte A)

| Item | Evidência |
|------|-----------|
| Configuração real de `analysis_options.yaml` transcrita | `conventions-and-lint.md` §1.1 transcreve o YAML exato com comentários |
| Versão `flutter_lints ^4.0.0` registrada | Corretamente identificada |
| Regras comentadas (`avoid_print`, `prefer_single_quotes`) documentadas | Registradas como desabilitadas com impacto no projeto (35+ violações de `avoid_print`) |
| Lint recomendado para template detalhado | `analysis_options.yaml` completo proposto em §4.2 com justificativa por regra |

---

## 2. Parcial — Coberto com lacunas

### 2.1 Bibliotecas — `library-compatibility-matrix.md`

**Coberto:** 19 libs na tabela mestre com risco, versão resolvida e alternativa moderna.  
**Lacunas:**
- A tabela afirma `json_annotation` declarada "provavelmente usada em models com `json_serializable`" (§2.5), mas `library-deep-catalog.md` confirma que **não há nenhum import** de `json_annotation` em `lib/` e **não há `build_runner`** — a matrix usa linguagem imprecisa ("provavelmente") para um fato confirmado.
- Versão resolvida de `flutter_lints` aparece como `(via flutter_test SDK)` em `library-deep-catalog.md` — imprecisa; o lock a registra diretamente como dependência de dev.

### 2.2 Testes — ausência de exemplos de teste falhando

`testing-strategy.md` documenta que `widget_test.dart` "jamais foi executado com sucesso" (§1.1), mas não confirma com saída real de `flutter test` — a afirmação é correta por análise do código (testa `MyApp` com um contador que não existe) mas não há evidência de execução.

### 2.3 Lint — conformidade real não medida

`conventions-and-lint.md` afirma "35+ ocorrências de `print()`" e "35+ violações" de `avoid_print`, mas não traz saída de `flutter analyze` para confirmar a contagem precisa. O número é consistente entre os docs mas não é rastreado a uma execução real.

---

## 3. Não documentado — Ausências identificadas

### 3.1 `pubspec.lock` — ausência formal de referência cruzada

Os documentos referem "extraídas de `pubspec.lock`" como fonte das versões resolvidas, mas o `pubspec.lock` em si não está incluído em `/specs` nem transcrito. A auditoria confirmou as versões declaradas vs. resolvidas na tabela de `library-deep-catalog.md`; qualquer divergência no lock real exigiria leitura direta do arquivo.

**Versões que a auditoria cruzou (pubspec.yaml → library-deep-catalog):**

| Lib | Declarado | Documentado como resolvido | Status cruzamento |
|-----|-----------|---------------------------|-------------------|
| get | ^4.6.6 | 4.7.2 | Consistente entre docs |
| dio | ^5.7.0 | 5.8.0+1 | Consistente entre docs |
| hive | ^2.2.3 | 2.2.3 | Consistente entre docs |
| json_annotation | ^4.4.0 | 4.9.0 | Consistente entre docs |
| barcode_scan2 | ^4.3.3 | 4.5.1 | Consistente entre docs |
| flutter_lints | ^4.0.0 | não especificado no lock | Parcialmente documentado |

### 3.2 `build_runner` e `json_serializable` ausentes do projeto

`local-storage.md` §7.1 e `testing-strategy.md` documentam que `json_annotation` está declarado mas sem `build_runner` e sem `json_serializable`. Isso está correto e documentado. O que não está documentado é **por que** `json_annotation` permanece em `dependencies` (não `dev_dependencies`) sem uso efetivo — é um resquício ou intencional para uso futuro? Nenhum doc esclarece.

### 3.3 SDK do Flutter — versão mínima não documentada na tabela de matriz

`library-compatibility-matrix.md` lista "Flutter mínimo: >=3.24.0" no cabeçalho, mas não há referência à versão do Flutter instalada no ambiente de build (apenas SDK Dart `>=3.5.3`). O `pubspec.yaml` confirma `sdk: ^3.5.3` mas sem constraint de Flutter.

---

## 4. Aprofundamento — Análises que merecem revisão ou complemento

### 4.1 `barcode_scan2` vs. postura de preservação

`library-compatibility-matrix.md` classifica `barcode_scan2` como `🟠 Substituir` com recomendação explícita de migrar para `mobile_scanner`. Porém, o mesmo doc traz aviso de postura no cabeçalho. Há tensão entre a análise técnica (substituir) e a postura oficial (preservar). O aprofundamento necessário é: a recomendação de substituição está isolada em bloco de "consideração futura"? **Resposta: NÃO** — está como recomendação ativa na tabela principal (ver Conflito 3 na Seção 7).

### 4.2 `fluttertoast` — duplicidade documentada em três lugares

A redundância de `fluttertoast` com `oktoast` é documentada em: `library-deep-catalog.md` §10, `library-compatibility-matrix.md` §2.10, e `recommended-stack.md` §4 (considerações futuras). A documentação fragmentada do mesmo achado dificulta saber qual é a posição oficial.

### 4.3 Estado da branch `core/` vs. `pages/` legada

`folder-structure.md` e `corporate-template-blueprint.md` documentam que `lib/src/pages/` é código morto, mas `testing-strategy.md` menciona "~90+ arquivos `.dart` em `lib/`" sem distinguir os ativos dos mortos. A contagem inflada pelo legado pode levar a conclusões erradas sobre o tamanho real da base ativa.

---

## 5. Inconsistências doc × código

### 5.1 `library-deep-catalog.md` §18 afirma "nenhum arquivo de teste encontrado"

> "Declarada como dev dependency; nenhum arquivo de teste encontrado em `test/`."

O código real possui `test/widget_test.dart` (confirmado pelo Glob). A afirmação está factualmente errada — há um arquivo, mas não há testes reais sobre o código de produção. A redação imprecisa pode levar a conclusões incorretas.

**Trecho exato:** `library-deep-catalog.md`, seção "18. test (dev)":
> "Declarada como dev dependency; nenhum arquivo de teste encontrado em `test/`."

**Código real:** `test/widget_test.dart` existe (verificado).

### 5.2 `library-deep-catalog.md` §19 — versão resolvida de `flutter_lints`

> "Versão resolvida: via flutter_test SDK"

`flutter_lints` é uma dependência de dev declarada explicitamente em `pubspec.yaml` como `flutter_lints: ^4.0.0`, com versão resolvida própria no lock (não é "via flutter_test SDK"). A confusão provavelmente vem de ter `flutter_test` listado como dependência do SDK, mas `flutter_lints` é um pacote independente.

### 5.3 `analysis_options.yaml` — ausência de leitura confirmada no doc

`library-deep-catalog.md` §19 afirma "ativadas via `analysis_options.yaml` do projeto (não lido, mas padrão do template)". A auditoria atual confirmou que o arquivo foi lido e corresponde exatamente ao que `conventions-and-lint.md` transcreve. A nota "não lido" está desatualizada — o doc de lint claramente baseia sua análise no arquivo real.

### 5.4 `api-configuration.md` — versão de Dio no cabeçalho vs. tabela

`api-configuration.md` §1 afirma: "O projeto utiliza o pacote **Dio 5.7.0**". A versão resolvida correta é `5.8.0+1` (documentada em `library-deep-catalog.md` e `library-compatibility-matrix.md`). A versão `5.7.0` é a declarada no `pubspec.yaml`, não a resolvida. Inconsistência menor mas relevante para rastreamento de versão.

---

## 6. Duplicações entre documentos

### 6.1 Tratamento de erros Dio — duplicado em 3 docs

A tabela de mapeamento de `DioExceptionType → mensagem` aparece de forma idêntica em:
1. `api-configuration.md` §4 (tabela de 7 tipos)
2. `error-handling.md` §3 (tabela idêntica com mesmas mensagens)

Não há problema de conflito (as duas tabelas são idênticas), mas é informação duplicada que deveria estar em um doc e referenciada pelo outro.

### 6.2 Classificação de libs — duplicado entre `technical-classification.md` e `library-deep-catalog.md`/`library-compatibility-matrix.md`

`technical-classification.md` §6 contém uma tabela de 12 libs com classificação `✅ Reutilizar`. `library-deep-catalog.md` contém a mesma classificação para cada lib em suas subseções. `library-compatibility-matrix.md` contém a coluna "Classificação" com a tabela mestre.

**Resultado:** a classificação de cada lib aparece em pelo menos 3 locais diferentes. Risco de divergência futura se uma tabela for atualizada e as outras não.

### 6.3 Aviso de postura de documentação — duplicado em 5 docs

O bloco de aviso de postura de preservação aparece (em variações) em:
1. `documentation-stance.md` (doc oficial)
2. `library-deep-catalog.md` (parágrafo inicial)
3. `library-compatibility-matrix.md` (cabeçalho ⚠️)
4. `corporate-template-blueprint.md` (parágrafo inicial)
5. `recommended-stack.md` (parágrafo inicial)
6. `migration-notes.md` (§ implícito)

Repetição protetora compreensível, mas cria ruído. Seria mais limpo ter o aviso apenas em `documentation-stance.md` e uma linha de link nos outros.

### 6.4 Catálogo de componentes — componentes descritos em `components-catalog.md` E `shared-widgets.md`

Não foi possível confirmar sobreposição total (ambos os arquivos foram listados no Glob), mas os títulos `components-catalog.md` e `shared-widgets.md` sugerem conteúdo potencialmente redundante. Este ponto requer verificação adicional dos dois docs.

### 6.5 Achado "Loading durante log — UX quebrada" duplicado

`logging-observability.md` §7 e `error-handling.md` (implícito via análise de `salvarLog`) documentam o mesmo problema. Aceitável como cross-reference, mas poderia ser explicitado com link.

---

## 7. Conflitos entre documentos — LISTA DETALHADA

Esta é a seção central da auditoria de consistência. Cada conflito é citado com doc + trecho exato.

---

### CONFLITO 1 — `library-compatibility-matrix.md` recomenda substituir GetX por Riverpod/go_router/get_it como ação, não como consideração futura

**Postura oficial:** `documentation-stance.md` determina que documentos NÃO devem recomendar trocar GetX → Riverpod, go_router, get_it como ação atual.

**Trecho conflitante:** `library-compatibility-matrix.md`, §2.1 `get (GetX) — 🟠 Substituir`:

> "**Recomendação de substituição:**
>
> | Função GetX | Alternativa Recomendada |
> |---|---|
> | Estado (Obx/RxTypes) | `flutter_riverpod` (providers reativos) |
> | DI (Get.find/put) | `get_it` (service locator simples) |
> | Navegação (Get.to/off) | `go_router` (oficial Flutter) |"

E na §5.1 "Resumo de Classificações":
> "🟠 Substituir (trocar biblioteca): `get` (→ riverpod + go_router + get_it)"

E na §5.2 "Prioridade de Ação":
> "🟠 P5 — Estratégico: Migrar `get` → `riverpod` + `go_router` + `get_it` | Toda arquitetura | Alto"

**Status do conflito:** ATIVO. O cabeçalho do doc traz o aviso de postura, mas o corpo inteiro do §2.1 e §5 trata a substituição de GetX como recomendação ativa de prioridade P5, não como "consideração futura". Isso contradiz diretamente `documentation-stance.md`, `ADR-0001`, `recommended-stack.md` e `corporate-template-blueprint.md`.

---

### CONFLITO 2 — `library-compatibility-matrix.md` classifica hive/hive_flutter como `🔴 Descartar` e recomenda substituir por `shared_preferences` + `flutter_secure_storage`

**Postura oficial:** `documentation-stance.md` proíbe classificar bibliotecas em produção como "Substituir/Descartar" por modernização. `ADR-0002` explicitamente decide manter Hive e apenas aplicar melhorias retrocompatíveis.

**Trecho conflitante:** `library-compatibility-matrix.md`, tabela mestre (linha hive):
> "| `hive` | 2.2.3 | ... | 🔴 **Parado desde 2022** | ... | **Alto** | `hive_ce` / `isar` / `drift` | 🔴 Descartar |"

E §2.3 `hive + hive_flutter — 🔴 Descartar`:
> "**Recomendação:** Migrar para `shared_preferences` (configurações) + `flutter_secure_storage` (credenciais). Se o projeto evoluir para cache complexo, usar `hive_ce` como bridge temporário para `isar`."

E §5.1:
> "🔴 Descartar (migrar urgente): `hive`, `hive_flutter` (→ shared_preferences + flutter_secure_storage)"

E §5.2:
> "🔴 P1 — Urgente: Migrar `hive`/`hive_flutter` → `shared_preferences` + `flutter_secure_storage`"

**Status do conflito:** ATIVO e GRAVE. `ADR-0002` decide explicitamente manter Hive. `recommended-stack.md` §4 trata a substituição como "consideração futura / não aplicar agora". `corporate-template-blueprint.md` §1 lista "Hive para cache e configuração" como princípio da fundação. A matrix trata isso como P1 urgente.

---

### CONFLITO 3 — `library-compatibility-matrix.md` recomenda substituir `barcode_scan2` por `mobile_scanner` como ação ativa (P2)

**Postura oficial:** `documentation-stance.md` §"O que esta documentação NÃO é" veda recomendações de substituição de stack como ação atual.

**Trecho conflitante:** `library-compatibility-matrix.md`, §2.9:
> "**Recomendação:** Substituir por `mobile_scanner ^5.x` ou `^6.x`"

E §5.2:
> "🟠 P2 — Alto: Substituir `barcode_scan2` → `mobile_scanner` | Funcionalidade futura | Baixo"

**Contraste:** `recommended-stack.md` §4 (Considerações futuras) trata corretamente o mesmo assunto:
> "`barcode_scan2` tem alternativas mais novas; avaliar somente se surgir incompatibilidade."

**Status do conflito:** ATIVO. A mesma questão é tratada como P2 urgente na matrix e como "avaliar somente se surgir incompatibilidade" no recommended-stack. Posições opostas.

---

### CONFLITO 4 — `library-compatibility-matrix.md` recomenda `flutter_secure_storage` e `drift/isar` como substituições de Hive

**Trecho conflitante:** `library-compatibility-matrix.md`, §2.3:
> "**Alternativas disponíveis em 2026:** ... `flutter_secure_storage` Credenciais seguras (Keychain/KeyStore)"
> **Classificação na tabela:** `🔴 Descartar`

**Contraste com local-storage.md:** `local-storage.md` §6 e §8 também recomendam `flutter_secure_storage` e `hive_ce`/`isar`/`drift` como substituições — porém dentro de um documento que foi gerado antes do ADR-0002. As recomendações de `local-storage.md` §8.1 propõem uma arquitetura completa com `flutter_secure_storage` para tokens e `hive_ce` para cache.

**Status:** O `local-storage.md` não tem aviso de postura tão explícito quanto a matrix, mas suas recomendações de §8 também conflitam com ADR-0002 ao propor trocar Hive por outras tecnologias como recomendação de template (não como "consideração futura").

---

### CONFLITO 5 — `library-compatibility-matrix.md` recomenda `freezed` para modelos

**Postura oficial:** `documentation-stance.md` veda recomendação de `freezed` como ação atual.

**Trecho conflitante:** `library-compatibility-matrix.md`, §4 "Stack Recomendada":
> "| Serialização JSON | `json_annotation ^4.x` | Manter | Oficial Dart |
>  | Geração de código | (implícito/manual) | `json_serializable ^6.x` (dev) | Geração automática de fromJson/toJson |"

E `local-storage.md` §7.5:
> "| Padrão `fromJson`/`toJson` manual | 🟠 Substituir | Funciona, mas gera boilerplate e bugs silenciosos; gerar com `freezed` + `json_serializable` |"

E `local-storage.md` §7.6 ("Stack recomendada"):
> "```yaml
> dependencies:
>   freezed_annotation: ^2.4.4
>   json_annotation: ^4.9.0
> dev_dependencies:
>   build_runner: ^2.4.13
>   freezed: ^2.5.7
>   json_serializable: ^6.8.0
> ```"

**Status:** ATIVO. `freezed` é explicitamente mencionado como nova dependência a adicionar em `local-storage.md` §7.6 e na matrix. `documentation-stance.md` cita `freezed` como um dos pacotes que este tipo de documentação NÃO recomenda.

---

### CONFLITO 6 — `library-compatibility-matrix.md` recomenda `sentry_flutter` como ação

**Trecho conflitante:** `library-compatibility-matrix.md`, §4.7:
> "| Crash reporting (prod) | — | `firebase_crashlytics` ou `sentry_flutter` | Necessário para apps corporativos em produção |"
> "🟢 P7 — Melhoria: Adicionar `firebase_crashlytics` ou `sentry_flutter` | Observabilidade produção | Baixo"

**Contraste:** `recommended-stack.md` §3 trata crash reporting como "melhoria dentro da stack" via `LogServices` plugável, sem citar `sentry_flutter` como nova dependência obrigatória. `migration-notes.md` §3 cita "crash reporting plugável no LogServices" como melhoria retrocompatível.

**Status:** Tensão entre "adicionar nova lib de crash reporting" (matrix) e "plugar no LogServices existente" (recommended-stack + migration-notes). Não é conflito de postura tão grave quanto os anteriores, mas cria ambiguidade sobre o que o template realmente inclui.

---

### CONFLITO 7 — `folder-structure.md` §3 propõe estrutura `domain/data/presentation` vs. `corporate-template-blueprint.md` usa `abstracts/controller/repository/view`

**Trecho conflitante:** `folder-structure.md` §3 "Estrutura ALVO proposta":
> "```
> features/
>   └── <feature>/
>       ├── domain/             # entidades + contratos (abstracts)
>       ├── data/               # models (DTO) + repository impl + datasource
>       └── presentation/       # controller/state + view + commands
> ```"

**Contraste direto:** `corporate-template-blueprint.md` §2 "Estrutura de pastas do template":
> "```
> core/features/<feature>/
>   ├── abstracts/
>   ├── controller/
>   │   └── commands/
>   ├── repository/
>   └── view/
> ```"

**Análise:** `folder-structure.md` propõe nomenclatura de Clean Architecture (`domain/data/presentation`) enquanto o blueprint adota a nomenclatura atual do legado (`abstracts/controller/repository/view`). São incompatíveis — a primeira introduz nova terminologia de camadas, a segunda preserva a terminologia existente.

**Status:** CONFLITO DIRETO entre dois documentos da mesma documentação. O blueprint afirma explicitamente preservar a stack e padrões existentes. `folder-structure.md` §3 propõe estrutura que muda os nomes das camadas. O blueprint deve prevalecer conforme a postura oficial.

---

### CONFLITO 8 — `state-management.md` §6 recomenda Riverpod + get_it + go_router como "opção moderna" de forma propositiva

**Trecho conflitante:** `state-management.md` §6:
> "### Migrar para Riverpod + get_it (opção moderna)
> Para um template corporativo de longo prazo, considerar:
> - **`flutter_riverpod`** (`StateNotifierProvider` ou `AsyncNotifierProvider`)...
> - **`get_it` + `injectable`**: DI explícita e lazy, sem singleton global via `Get`.
> - **`go_router`**: navegação declarativa com guards nativos."

**Contraste:** `documentation-stance.md`:
> "❌ Não recomenda trocar GetX → Riverpod, Hive → outro, go_router, get_it, etc."

E `ADR-0001` §"Alternativas consideradas":
> "Riverpod + go_router + get_it: registrado apenas como conhecimento ('consideração futura'). **Não adotado**."

**Status:** ATIVO. `state-management.md` §6 contém uma seção de "opção moderna" propositiva que vai além de "consideração futura / não aplicar agora" — usa verbos como "considerar" e "vale o custo de aprendizado", que podem ser lidos como recomendação ativa. O veredicto do parágrafo final ("Para equipe pequena... refatorar os pontos críticos do GetX atual é suficiente") mitiga parcialmente, mas a seção ainda nomeia as alternativas com estrutura de código em bloco.

---

### CONFLITO 9 — `local-storage.md` §6 classifica hive 2.2.3 como `🟠 Substituir` dentro da tabela de componentes

**Trecho conflitante:** `local-storage.md`, tabela §6 "Classificação dos Componentes de Persistência":
> "| Hive 2.2.3 para dados não-sensíveis | 🟠 Substituir | Migrar para `hive_ce` (fork ativo) ou `isar`/`drift` |"

**Contraste:** `technical-classification.md` §6 (doc mais recente, com postura explícita):
> "| hive / hive_flutter | 2.2.3 / 1.1.0 | ✅ Reutilizar | Cache e config de ambiente |"

**Status:** ATIVO. A classificação do mesmo artefato diverge entre dois documentos (`🟠 Substituir` vs. `✅ Reutilizar`). `technical-classification.md` é o doc consolidado e mais recente, com postura declarada — deve prevalecer.

---

### CONFLITO 10 — Versão de GetX divergente em `state-management.md` vs. demais docs

**Trecho conflitante:** `state-management.md` cabeçalho:
> "Pacote: `get: 4.6.6`"

**Versão correta (resolvida no lock):** `4.7.2` — documentada em `library-deep-catalog.md`, `library-compatibility-matrix.md`, `recommended-stack.md` e `ADR-0001`.

**Status:** INCONSISTÊNCIA FACTUAL. O cabeçalho de `state-management.md` usa a versão **declarada** em `pubspec.yaml` (`^4.6.6`) quando deveria usar a versão **resolvida** (`4.7.2`). Todos os outros docs usam a versão resolvida. Erro menor, mas cria confusão.

---

### CONFLITO 11 — Versão de Dio divergente em `api-configuration.md` vs. demais docs

**Trecho conflitante:** `api-configuration.md` §1:
> "O projeto utiliza o pacote **Dio 5.7.0**"

**Versão correta (resolvida no lock):** `5.8.0+1` — documentada em `library-deep-catalog.md` e `library-compatibility-matrix.md`.

**Status:** INCONSISTÊNCIA FACTUAL. Mesmo padrão do Conflito 10 — confunde versão declarada com versão resolvida.

---

## 8. Decisões não documentadas

### 8.1 Por que `json_annotation` está em `dependencies` e não em `dev_dependencies`

`json_annotation` em `dependencies` (não `dev`) implica que o app precisa da lib em runtime. Isso só faz sentido se houver anotações `@JsonSerializable` no código compilado. Como os modelos são manuais, a lib deveria estar em `dev_dependencies`. Nenhum documento explica essa escolha — se é intencional (planejamento futuro) ou esquecimento.

### 8.2 Por que `mask_text_input_formatter` permanece sendo usada no legado

`library-deep-catalog.md` §2 documenta que a camada `core/` já usa `FilteringTextInputFormatter` nativo, mas `mask_text_input_formatter` permanece como dependência para o código em `pages/` (legado). Se o blueprint exclui `pages/` do template, a lib poderia ser removida. Nenhum ADR ou nota documenta a decisão de mantê-la.

### 8.3 Ausência de `fluttertoast` no `recommended-stack.md`

`recommended-stack.md` lista na tabela de "Toast / feedback": "`oktoast` (+ `fluttertoast`)" — mantendo ambas. Mas `library-compatibility-matrix.md` §5.1 classifica `fluttertoast` como `🟡 Refatorar` (eliminar). Não há ADR documentando a decisão de manter ou remover.

### 8.4 `badCertificateCallback` — quando será corrigido

`recommended-stack.md` §3 e `migration-notes.md` §3 listam "Restringir `badCertificateCallback` a `kDebugMode`" como melhoria retrocompatível, mas nenhum documento define se isso é pré-condição para usar o template em produção ou apenas recomendação opcional.

---

## Estimativas de Cobertura

### Cobertura Parte A (Libs / Testes / Lint) — cruzamento código × docs

| Dimensão | Cobertura Estimada | Justificativa |
|----------|-------------------|---------------|
| Bibliotecas catalogadas vs. pubspec.yaml | **100%** | 19/19 libs documentadas com versão declarada, resolvida, uso e classificação |
| Versões resolvidas vs. pubspec.lock | **~90%** | Todas exceto `flutter_lints` (versão resolvida imprecisa no catalog); um erro de versão em `api-configuration.md` e outro em `state-management.md` |
| Testes — estado real vs. docs | **95%** | `testing-strategy.md` descreve corretamente o estado real, salvo afirmação imprecisa "nenhum arquivo encontrado" em `library-deep-catalog.md` |
| Lint — `analysis_options.yaml` vs. docs | **95%** | `conventions-and-lint.md` transcreve e analisa corretamente o arquivo; minor: afirmação desatualizada em library-deep-catalog |
| **Cobertura global Parte A** | **~95%** | Alta fidelidade com o código real |

### Nota Global de Consistência (Parte B)

| Dimensão | Nota | Justificativa |
|----------|------|---------------|
| Consistência de postura (preservar vs. substituir) | **5/10** | 9 conflitos ativos onde recomendações de substituição extrapolam a postura oficial, principalmente em `library-compatibility-matrix.md` e `local-storage.md` |
| Consistência de versões entre docs | **7/10** | 2 erros de versão confirmados (Dio, GetX) em docs de infraestrutura |
| Consistência de estrutura de pastas | **6/10** | Conflito direto entre `folder-structure.md` §3 (domain/data/presentation) e `corporate-template-blueprint.md` (abstracts/controller/repository/view) |
| Duplicação de conteúdo | **6/10** | 5 duplicações identificadas; algumas com risco de divergência futura |
| **Nota global de consistência** | **6/10** | Boa fundamentação técnica, mas conflitos de postura residuais significativos |

---

## Resumo Executivo

**Cobertura de bibliotecas/testes/lint vs. código: ~95%** — a documentação é fiel ao código real com erros menores de versão e uma afirmação imprecisa sobre a pasta `test/`.

**Conflitos de postura residuais com doc + trecho:**

1. `library-compatibility-matrix.md` §2.1 e §5 → GetX classificado `🟠 Substituir`; migração para Riverpod/go_router/get_it como P5 ativa
2. `library-compatibility-matrix.md` §2.3 e §5 → Hive classificado `🔴 Descartar`; migração para shared_preferences + flutter_secure_storage como P1 urgente
3. `library-compatibility-matrix.md` §2.9 e §5 → barcode_scan2 como P2 para substituir por mobile_scanner
4. `local-storage.md` §7.5-7.6 → freezed + json_serializable recomendados como nova stack de serialização
5. `local-storage.md` §6 → hive classificado `🟠 Substituir` (conflita com `technical-classification.md` que usa `✅ Reutilizar`)
6. `local-storage.md` §8 → arquitetura completa com flutter_secure_storage e hive_ce proposta como recomendação de template
7. `state-management.md` §6 → seção "Migrar para Riverpod + get_it" com código e justificativa propositiva
8. `folder-structure.md` §3 → nomenclatura domain/data/presentation conflita com abstracts/controller/repository/view do blueprint
9. `library-compatibility-matrix.md` §4.7 → sentry_flutter/firebase_crashlytics como nova dependência a adicionar (vs. migration-notes que propõe plugin no LogServices existente)

**Ação necessária:** `library-compatibility-matrix.md` é o documento com maior número de conflitos ativos (7 dos 9 acima). O cabeçalho traz o aviso de postura, mas o corpo contradiz sistematicamente a postura em todas as seções de recomendação/prioridade. O doc foi claramente gerado antes da postura de preservação ser consolidada e nunca foi alinhado internamente além do aviso de cabeçalho. `local-storage.md` §7.5-8 e `state-management.md` §6 precisam de isolamento explícito em bloco "Consideração futura (não aplicar agora)".

---

*Auditoria gerada em: 2026-06-24 | Cobertura estimada: 95% (libs/testes/lint) | Nota de consistência: 6/10*
