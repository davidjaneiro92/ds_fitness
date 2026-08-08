# Auditoria de Cobertura Documental — Área 1: Arquitetura, Padrões e Rotas

**Data da auditoria:** 2026-06-24  
**Auditor:** Claude Code (Sonnet 4.6)  
**Código auditado:** `C:\Users\David\Desktop\controle_separacao\controle_separacao_aplicativo` (somente leitura)  
**Docs auditados:**
- `01-architecture/architecture-overview.md`
- `01-architecture/design-patterns.md`
- `01-architecture/folder-structure.md`
- `01-architecture/adr/0000-template.md`, `0001-state-management-and-di.md`, `0002-security-and-storage.md`
- `02-infrastructure/navigation.md`
- `07-template-blueprint/corporate-template-blueprint.md`
- `04-quality/conventions-and-lint.md`

---

## 1. Itens COMPLETAMENTE documentados

### 1.1 Arquitetura em camadas (View/Controller/Repository/Abstracts)
**Evidência no código:** estrutura `lib/src/core/features/<feature>/abstracts/`, `controller/`, `repository/`, `view/` confirmada em 12 features.  
**Evidência na doc:** `architecture-overview.md §2` descreve com diagrama ASCII exato as camadas VIEW → CONTROLLER → COMMAND → REPOSITORY → SERVICES. O mapeamento bate 100% com o código real.  
**Status: COMPLETAMENTE documentado.**

### 1.2 Migração inacabada: árvore legada `lib/src/pages/` vs. ativa `lib/src/core/features/`
**Evidência no código:** `lib/src/pages/` contém 44 arquivos; `lib/src/pages_routes/app_pages.dart` importa views de `lib/src/pages/`, enquanto `lib/src/routes/app_pages.dart` importa de `lib/src/core/features/`.  
**Evidência na doc:** `architecture-overview.md §1` (caixa de aviso central), `folder-structure.md §1` (tabela de duplicações), `conventions-and-lint.md §2.7` e `corporate-template-blueprint.md §2` (tabela "Itens removidos") — todos registram a dualidade e marcam `pages/` como descartável.  
**Status: COMPLETAMENTE documentado.**

### 1.3 Enum `PagesRoutes` como centralizador de rotas
**Evidência no código:** `lib/src/enum/pages_routes.dart` — enum com 14 valores, todos consumidos por `lib/src/routes/app_pages.dart`.  
**Evidência na doc:** `navigation.md §2.2` reproduz o enum completo com anotações por linha, incluindo as inconsistências de nomenclatura (`ConsultaNfSaida` em PascalCase, `Trasferencia` com typo, `settingsApp` com `/Settings_App` capitalizado).  
**Status: COMPLETAMENTE documentado.**

### 1.4 `AppPages` ativo (14 rotas) vs. legado (9 rotas)
**Evidência no código:** `lib/src/routes/app_pages.dart` tem 14 `GetPage`; `lib/src/pages_routes/app_pages.dart` tem 9 `GetPage` apontando para `lib/src/pages/`.  
**Evidência na doc:** `navigation.md §2.3` lista as 14 rotas ativas com código real; `navigation.md §2.4` classifica o arquivo legado como "LEGADO / morto".  
**Status: COMPLETAMENTE documentado.**

### 1.5 Repository Pattern
**Evidência no código:** toda feature tem `<feature>/repository/<feature>_repository.dart` implementando `<feature>/abstracts/<feature>_repository_interface.dart`. Exemplos: `conferir_material_saida_repository.dart` implementa `conferir_material_saida_repository_interface.dart`.  
**Evidência na doc:** `design-patterns.md` tabela linha "Repository Pattern"; `architecture-overview.md §2` diagrama; `corporate-template-blueprint.md §3` tabela de camadas.  
**Status: COMPLETAMENTE documentado.**

### 1.6 Service Locator / DI via GetX (`Get.put` / `Get.find`)
**Evidência no código:** commands usam `Get.find<LogServicesInterface>()`, `Get.find<HiveServicesInterface>()`, etc. Bootstrap em `main.dart` usa `Get.put<Interface>(Impl())`.  
**Evidência na doc:** `architecture-overview.md §4`, `design-patterns.md` linha "Service Locator", `corporate-template-blueprint.md §4`.  
**Status: COMPLETAMENTE documentado.**

### 1.7 Inconsistências de convenção / typos sistêmicos
**Evidência no código:** `lib/src/enum/pages_routes.dart:18` — `Trasferencia('/buscar_produtos')` (nome do enum ≠ path da rota); `soma_peso_command.dart:19` — `class SomaPesoComman` (typo). Pastas `lib/src/Interfaces/`, `lib/src/components/custom_Scaffold/`.  
**Evidência na doc:** `conventions-and-lint.md §2.4` tabela de typos, `folder-structure.md §2`, `navigation.md §2.2`.  
**Status: COMPLETAMENTE documentado.**

### 1.8 ADR-0001: GetX como base de estado, DI e navegação
**Evidência no código:** `GetMaterialApp`, `GetxController`, `Rx`/`.obs`, `Obx` em todas as features ativas.  
**Evidência na doc:** `adr/0001-state-management-and-di.md` — decisão aceita, alternativas registradas (Riverpod + go_router), consequências listadas.  
**Status: COMPLETAMENTE documentado.**

### 1.9 ADR-0002: Persistência (Hive) e rede (Dio)
**Evidência no código:** `HiveServicesInterface` injetada em commands (ex.: `ConfirmarConferenciaCommand`, `ConfirmarConferenciaTrasferenciaCommand`); `HttpManager` encapsula Dio.  
**Evidência na doc:** `adr/0002-security-and-storage.md` — decisão aceita, melhorias retrocompatíveis listadas.  
**Status: COMPLETAMENTE documentado.**

---

## 2. Itens PARCIALMENTE documentados (com indicação do que falta)

### 2.1 Command Pattern — conceito documentado; CONTRATO das interfaces NÃO detalhado
**Evidência no código:**  
- `lib/src/core/features/conferir_material_saida/abstracts/command_interface.dart` — `abstract class CommandInterface { Future<void> execute(); }`  
- `lib/src/core/features/conferir_material_transferencia/abstracts/transferencia_command_interface.dart` — `abstract class TransferenciaCommandInterface { Future<void> execute(); }`  
- São **duas interfaces separadas** com assinatura idêntica (`Future<void> execute()`), localizadas em features diferentes, **sem relação de herança entre elas**.

**Evidência na doc:** `design-patterns.md` tabela linha "Command Pattern" menciona "cada operação de negócio é uma classe com `execute()`"; `architecture-overview.md §2` diagrama cita "COMMAND (Command Pattern)"; `corporate-template-blueprint.md §3` tabela menciona a camada commands.

**O que falta:**
1. Nenhum documento nomeia explicitamente as **duas interfaces** (`CommandInterface` e `TransferenciaCommandInterface`) nem registra que elas são **duplicatas independentes** em vez de uma hierarquia.
2. Nenhum documento explica **por que há duas interfaces** com a mesma assinatura em vez de uma interface única compartilhada — esta é uma **decisão arquitetural não documentada** (ver seção 8).
3. Os **commands concretos** não são inventariados em nenhum documento: `ConfirmarConferenciaCommand`, `DividirLoteCommand`, `GetNotaCompraLotesCommand`, `SomaPesoComman`, `ImprimirEtiqueta`, `ConfirmarConferenciaTrasferenciaCommand`, `GetNotaCompraLotesTrasferenciaCommand`, `SomaPesoComman` (versão transferência).

**Status: PARCIALMENTE documentado.**

### 2.2 `splash_screen.dart` — existência mencionada nas rotas; comportamento e estrutura não detalhados
**Evidência no código:** `lib/src/core/features/splash_screen/splash_screen.dart` — `StatefulWidget` com `Future.delayed(2s)` → `Get.offNamed(PagesRoutes.login.path)`. **Não tem controller nem repository** — é a única feature sem sub-camadas.  
**Evidência na doc:** `navigation.md §2.3` lista a rota `SplashScreen` na tabela; `navigation.md §2.5` menciona `Get.offNamed(PagesRoutes.login.path)` na splash. Mas nenhum documento registra que a splash é a **única feature sem a estrutura abstracts/controller/repository** — desvio do padrão que merece nota.  
**Status: PARCIALMENTE documentado** (rota documentada; estrutura excepcional não registrada).

### 2.3 `confirmar_acesso.dart` — segunda view de login
**Evidência no código:** `lib/src/core/features/login/view/confirmar_acesso.dart` — **não é uma view tradicional**: é um arquivo com funções soltas (`showAlertLogin`, `dispose`) e variáveis globais de arquivo (`_formkeyModal`, `_usuarioModalController`). Contém `@override void dispose()` **sem classe** — código estruturalmente anômalo.  
**Evidência na doc:** `navigation.md §2.5` registra `Navigator.of(context).pop()` em `LoginController.loginSettings`, que é chamado via `confirmar_acesso.dart`. Mas **nenhum documento descreve a existência desta segunda view de login**, sua função (modal de reautenticação para acesso a settings) nem sua estrutura anômala (funções de arquivo em vez de widget).  
**Status: PARCIALMENTE documentado** (efeito colateral mencionado; arquivo e sua anomalia estrutural não documentados).

### 2.4 Estrutura de pastas — `selecionar_material_estoque` sem controller próprio referenciado pelo glob
**Evidência no código:** `lib/src/core/features/selecionar_material_estoque/` tem `controller/selecionar_material_estoque_controller.dart` e `repository/selecionar_material_estoque_repository.dart` mas **não tem controller_interface** — apenas `abstracts/selecionar_material_estoque_controller_interfaces.dart` e `abstracts/selecionar_material_estoque_repository_interfaces.dart`.  
**Evidência na doc:** `folder-structure.md §1` lista a pasta `selecionar_material_estoque` de forma genérica sem detalhar esta peculiaridade (pluralização `_interfaces` em vez de `_interface` nas abstracts).  
**Status: PARCIALMENTE documentado** (estrutura geral sim; desvio de nomenclatura nesta feature não registrado).

---

## 3. Itens NÃO documentados

### 3.1 Inventário completo das 12 features com status por feature
**Evidência no código:** 12 features em `lib/src/core/features/`: `buscar_produtos`, `conferir_material_entrada`, `conferir_material_saida`, `conferir_material_transferencia`, `consulta_nf_saida`, `itens_nf_entrada`, `itens_pedido_saida`, `login`, `nfs_pedidos`, `selecionar_material_estoque`, `settings_app`, `splash_screen`, `trasferencia_industria` (13 contando `trasferencia_industria`, não 12 como listado na tarefa).  
**Evidência na doc:** nenhum documento apresenta uma tabela com as features e o status de cada camada (quais têm commands, quais têm interfaces, quais têm repositórios). A documentação menciona features individualmente em exemplos, mas não inventaria todas.  
**Status: NÃO documentado.**

### 3.2 Feature `consulta_nf_saida` — segunda view (`consulta_lotes_saida.dart`)
**Evidência no código:** `lib/src/core/features/consulta_nf_saida/view/` tem **duas views**: `consulta_nf_saida.dart` e `consulta_lotes_saida.dart` — única feature com duas views. A rota `ConsultaLotesSaida` em `app_pages.dart:65` aponta para `ConsultaLotesSaida()`.  
**Evidência na doc:** `navigation.md §2.3` lista a rota `ConsultaLotesSaida` na tabela de rotas ativas, mas nenhum documento explica que `consulta_nf_saida` é a única feature com **duas views distintas** mapeadas em rotas separadas.  
**Status: NÃO documentado** (rota mapeada, mas a unicidade estrutural não registrada).

### 3.3 Catálogo dos commands por feature
**Evidência no código:**
- `conferir_material_saida/controller/commands/`: `confirmar_conferencia_command.dart`, `dividir_lote_command.dart`, `get_nota_compra_lotes_command.dart`, `imprimir_etiqueta.dart`, `soma_peso_command.dart` (5 commands)
- `conferir_material_transferencia/controller/commands/`: `confirmar_conferencia_trasferencia_command.dart`, `get_nota_compra_lotes_transferencia_command.dart`, `soma_peso_command.dart` (3 commands, mesmo nome de arquivo em dois locais)

**Evidência na doc:** nenhum documento lista os 8 commands concretos existentes, suas responsabilidades nem seus parâmetros de construtor.  
**Status: NÃO documentado.**

### 3.4 `imprimir_etiqueta.dart` — nome sem sufixo `Command`
**Evidência no código:** `lib/src/core/features/conferir_material_saida/controller/commands/imprimir_etiqueta.dart` — classe `ImprimirEtiqueta` implementa `CommandInterface` mas **não tem o sufixo `Command`** no nome (todos os outros têm: `ConfirmarConferenciaCommand`, `DividirLoteCommand`, `SomaPesoComman`). Além disso, `SomaPesoComman` tem typo (falta o `d`).  
**Evidência na doc:** `conventions-and-lint.md §2.2` registra `class SomaPesoComman` como typo. Mas `ImprimirEtiqueta` sem sufixo `Command` não é mencionado.  
**Status: NÃO documentado** (violação de convenção de nomeação não registrada).

### 3.5 `trasferencia_industria` — feature sem interface de controller documentada formalmente
**Evidência no código:** `lib/src/core/features/trasferencia_industria/abstracts/trasferencia_industria_controller_interface.dart` existe, mas a feature chama-se `trasferencia_industria` (com typo sistemático em toda a pasta, nome de classes e interfaces).  
**Evidência na doc:** o typo `trasferencia` é registrado em `conventions-and-lint.md §2.4` como ocorrência sistêmica, mas a feature `trasferencia_industria` não é descrita isoladamente em nenhum documento.  
**Status: NÃO documentado** como feature individual.

---

## 4. Itens que Precisam de Aprofundamento

### 4.1 Fluxo de navegação entre features (mapa de rotas)
A doc lista as rotas individualmente (`navigation.md §2.3`) mas não apresenta um **grafo de navegação** mostrando qual feature navega para qual, com que argumentos. O fluxo `Login → NfsPedidos → ItensNf → ConferirMaterialEntrada` (ou Saída, ou Transferência) é um caminho crítico que merece diagrama.

### 4.2 Passagem de argumentos entre rotas — contrato implícito
`navigation.md §2.6` documenta o problema (Map sem tipagem, string `'null'`), mas não documenta **quais chaves** cada rota receptora espera receber. Um mapa de contratos implícitos (rota → chaves esperadas → tipo real) seria necessário para completar a documentação.

### 4.3 ADR sobre a duplicação de `CommandInterface` vs `TransferenciaCommandInterface`
Há duas interfaces de Command com assinaturas idênticas em features diferentes. Não há ADR nem registro de decisão sobre por que não foi criada uma interface compartilhada em `core/abstracts/`.

---

## 5. Inconsistências entre Documentação e Código

### 5.1 CRÍTICA — `folder-structure.md §3` propõe `domain/data/presentation` que NÃO EXISTE no código ativo
**Evidência no código:** a estrutura real é `abstracts/controller/repository/view` (sem `domain/`, sem `data/`, sem `presentation/`).  
**Evidência na doc:** `folder-structure.md §3` ("Estrutura ALVO proposta") usa:
```
features/<feature>/
  ├── domain/
  ├── data/
  └── presentation/
```
Esta é uma **estrutura proposta para um template futuro**, não a estrutura do código atual. O documento **não deixa claro de forma suficiente** que essa seção descreve um alvo de template e não o estado atual. Um leitor desatento pode confundir com a descrição do código existente.

> **Nota:** o `corporate-template-blueprint.md §2` corretamente usa `abstracts/controller/commands/repository/view` — alinhado ao código real. A inconsistência está isolada em `folder-structure.md §3`.

### 5.2 `architecture-overview.md` cita "estrutura `domain/data/presentation`" como inexistente — correto, mas a menção implícita em `folder-structure.md §3` cria ambiguidade
`architecture-overview.md §1` afirma explicitamente que o código usa `abstracts/controller/repository/view`. O `corporate-template-blueprint.md §3` tabela de camadas também usa a nomenclatura correta. Mas `folder-structure.md §3` usa terminologia DDD (`domain`, `data`, `presentation`) que pode confundir um leitor que leia apenas esse documento.

### 5.3 Enum `PagesRoutes.Trasferencia` mapeia para `BuscarProdutos` — inconsistência nome/destino não totalmente explicada
**Evidência no código:** `lib/src/routes/app_pages.dart:69-71` — `GetPage(page: () => BuscarProdutos(), name: PagesRoutes.Trasferencia.path)`. O nome do enum diz "Trasferencia" mas o widget é `BuscarProdutos()` e o path é `/buscar_produtos`.  
**Evidência na doc:** `navigation.md §2.3` registra `GetPage(page: () => BuscarProdutos(), name: PagesRoutes.Trasferencia.path)` com o comentário `// ← widget ≠ nome da rota (confuso)`. **Documentado corretamente**, mas não há explicação de por que ocorreu este desvio (provavelmente a feature de busca de produtos foi reaproveitada no fluxo de transferência sem renomear).

---

## 6. Duplicações de Informação entre Documentos

### 6.1 Tabela de duplicações de pastas legado/ativo
A mesma tabela (legado vs. ativo) aparece em:
- `folder-structure.md §1` ("Duplicações confirmadas")
- `corporate-template-blueprint.md §2` ("Itens removidos vs. legado")
- `conventions-and-lint.md §2.7` (tabela de localização legada vs. nova)

Todos corretos e consistentes entre si, mas **repetidos em três documentos**. Poderia haver referência cruzada em vez de repetição.

### 6.2 Lista de typos sistêmicos
A lista de typos (`trasferencia`, `colos`, `dropwn`, etc.) aparece em:
- `conventions-and-lint.md §2.4` (tabela principal)
- `folder-structure.md §2` (parcialmente)
- `design-patterns.md §Anti-padrões` (menção a "Migração inacabada")

Novamente corretos e consistentes, mas com nível de detalhe desigual entre documentos.

### 6.3 Descrição do Command Pattern
O padrão é descrito em:
- `design-patterns.md` (tabela)
- `architecture-overview.md §2` (diagrama e §5)
- `corporate-template-blueprint.md §1` (princípios) e `§3` (tabela de camadas)

Consistentes, mas sem referência cruzada explícita — leitores podem não saber qual documento é a fonte primária.

---

## 7. Informações CONFLITANTES entre Documentos

### 7.1 Estrutura de feature no template: `corporate-template-blueprint.md` vs. `folder-structure.md §3`
**`corporate-template-blueprint.md §2`:**
```
features/<feature>/
  ├── abstracts/
  ├── controller/
  │   └── commands/
  ├── repository/
  └── view/
```
**`folder-structure.md §3` ("Estrutura ALVO para o Template"):**
```
features/<feature>/
  ├── domain/
  ├── data/
  └── presentation/
```
Estes dois documentos **propõem estruturas de feature incompatíveis** para o mesmo template. O `corporate-template-blueprint.md` preserva a estrutura do legado (correto conforme o `documentation-stance.md`); o `folder-structure.md §3` propõe uma reescrita DDD que contradiz a postura declarada de preservação.

**Gravidade: ALTA** — dois documentos do mesmo conjunto propõem arquiteturas de feature incompatíveis.

### 7.2 Recomendação de roteamento: `navigation.md §6` vs. `adr/0001`
**`navigation.md §6`** ("Opção B — go_router recomendada para template corporativo"): recomenda explicitamente `go_router` para o template.  
**`adr/0001`**: decide **manter GetX** para navegação, com `go_router` registrado apenas como "consideração futura, não adotada".

Os dois documentos conflitam diretamente na recomendação de roteamento para o template. O ADR tem precedência decisória, mas o `navigation.md` não menciona o ADR nem alinha sua recomendação à decisão já tomada.

**Gravidade: ALTA** — a recomendação de roteamento do `navigation.md` contradiz a decisão ratificada no `adr/0001`.

---

## 8. Decisões Arquiteturais NÃO Documentadas

### 8.1 Por que duas interfaces de Command independentes?
`CommandInterface` (em `conferir_material_saida/abstracts/`) e `TransferenciaCommandInterface` (em `conferir_material_transferencia/abstracts/`) têm a mesma assinatura `Future<void> execute()`. Não há ADR ou comentário explicando por que não existe uma interface compartilhada em `core/abstracts/`. Decisão de escopo de interface não documentada.

### 8.2 Por que `conferir_material_entrada` não tem commands, mas `conferir_material_saida` e `conferir_material_transferencia` têm?
A feature de entrada usa um controller monolítico; as features de saída e transferência usam Command Pattern. A decisão de aplicar o padrão seletivamente não está documentada.

### 8.3 Por que `splash_screen` não segue a estrutura abstracts/controller/repository/view?
`splash_screen.dart` é um `StatefulWidget` direto sem controller, sem repository, sem interfaces. É a única feature que quebra o padrão arquitetural. Nenhum documento justifica esta exceção.

### 8.4 Por que `confirmar_acesso.dart` é um arquivo de funções soltas em vez de um widget?
O arquivo contém funções de nível de arquivo, variáveis globais e um `@override void dispose()` sem classe. Esta escolha estrutural anômala não está documentada e pode causar confusão (o `dispose` fora de classe não será chamado pelo framework).

### 8.5 Instanciação direta de repositórios dentro dos commands
Os commands instanciam repositórios diretamente (`ConferirMaterialSaidaRepository()`, `ConferirMaterialTransferenciaRepository()`) em vez de recebê-los por injeção. Esta decisão quebra o ciclo de DI para repositórios dentro de commands e não está registrada como decisão consciente ou dívida técnica no contexto de commands.

---

## 9. Estimativa de Cobertura da Área

| Sub-área | Cobertura | Justificativa |
|---|---|---|
| Arquitetura em camadas (conceito geral) | 95% | Diagrama ASCII fiel ao código; fluxo de dados documentado |
| Estrutura de pastas (legado + ativo) | 90% | Tabela completa; desvios menores (selecionar_material_estoque, splash) não registrados |
| Design Patterns (conceitos) | 85% | Todos os padrões mapeados; catálogo de commands concretos ausente |
| Command Pattern (contrato de interface) | 50% | Conceito documentado; duas interfaces distintas e suas razões de existir não documentadas |
| Rotas (ativas + legadas) | 95% | Enum completo, 14 rotas, inconsistências anotadas; conflito com ADR-0001 na seção de recomendações |
| ADRs | 80% | ADR-0001 e ADR-0002 bem escritos; falta ADR sobre dualidade de CommandInterface |
| Convenções e lint | 90% | Tabela de typos completa; ImprimirEtiqueta sem sufixo Command não registrado |
| Features individuais (inventário) | 30% | Não existe tabela de inventário das 12-13 features com suas camadas |
| Decisões não documentadas | 0% | 5 decisões arquiteturais sem ADR ou registro |

**COBERTURA GERAL DA ÁREA: ~72%**

**Justificativa:** A base arquitetural (camadas, padrões, migração, rotas) está bem documentada e com alta fidelidade ao código. O gap principal está em três pontos: (1) inventário de features individuais ausente; (2) catálogo de commands concretos inexistente; (3) conflito crítico entre `folder-structure.md §3` (DDD) e `corporate-template-blueprint.md` (preservação do legado), que é a inconsistência mais grave da documentação e pode desorientar um desenvolvedor novo.

---

## Resumo Executivo (Achados-Chave)

1. **Arquitetura geral bem coberta:** camadas, fluxo de dados, migração legado→ativo, Repository Pattern e Service Locator estão documentados com fidelidade ao código real.

2. **CONFLITO CRÍTICO entre documentos:** `folder-structure.md §3` propõe estrutura de feature com `domain/data/presentation` (estilo DDD), enquanto `corporate-template-blueprint.md §2` propõe `abstracts/controller/commands/repository/view` (preservação do legado). São incompatíveis e representam a inconsistência mais grave do conjunto documental.

3. **CONFLITO de recomendação de roteamento:** `navigation.md §6` recomenda `go_router` como "escolha clara" para o template, contrariando diretamente o `adr/0001` que decide manter GetX para navegação. O `navigation.md` não cita o ADR.

4. **Command Pattern parcialmente documentado:** o conceito e o diagrama de camadas estão corretos, mas as duas interfaces (`CommandInterface` em saída e `TransferenciaCommandInterface` em transferência) não são nominadas e seus 8 commands concretos não são inventariados em nenhum documento.

5. **`confirmar_acesso.dart` invisível na documentação:** segunda view de login, com estrutura anômala (funções de arquivo com `@override` sem classe), não é documentada em nenhum ponto dos docs de referência.

6. **Inventário de features ausente:** nenhum documento lista as 12-13 features com suas camadas presentes/ausentes (quais têm commands, quais têm repositórios, quais seguem o padrão completo).

7. **5 decisões arquiteturais sem ADR:** dualidade de CommandInterface, aplicação seletiva do Command Pattern, splash sem controller, confirmar_acesso como funções soltas, instanciação direta de repositórios dentro de commands.

8. **Duplicações entre documentos:** tabela de pastas legado/ativo e lista de typos aparecem em 2-3 documentos cada. Corretas e consistentes, mas sem referência cruzada.

9. **Anomalia não registrada — `imprimir_etiqueta.dart`:** único command sem sufixo `Command` no nome da classe.

10. **Cobertura estimada: 72%** — alta fidelidade onde documenta, mas lacunas importantes em inventário de features, catálogo de commands e duas inconsistências de alta gravidade entre documentos.
