# Auditoria de Cobertura Documental — Área 4
## Hive/Persistência/Cache · Logs/Observabilidade · Models/Serialização · Serviços Compartilhados · Utils/Helpers/Extensions/Validators · Enum http_methods

> **Método:** Validação cruzada CÓDIGO × DOCUMENTAÇÃO (engenharia reversa).
> **Data:** 2026-06-24
> **Auditor:** Revisão automatizada com leitura direta dos arquivos-fonte.
> **Docs auditados:** `02-infrastructure/local-storage.md`, `02-infrastructure/services-catalog.md`, `02-infrastructure/logging-observability.md`
> **Código auditado:** `lib/src/models/` (26 arquivos), `lib/src/core/services/Hive_services.dart`, `lib/src/core/services/log_services.dart`, `lib/src/core/utils/formatar_valores.dart`, `lib/src/core/utils/utils_services.dart`, `lib/src/core/utils/validators.dart`, `lib/src/enum/http_methods.dart`, `lib/src/enum/pages_routes.dart`

---

## Legenda de Status

| Símbolo | Significado |
|---|---|
| COMPLETO | Doc cobre o código fielmente, sem lacunas relevantes |
| PARCIAL | Doc existe mas omite campos, comportamentos ou variações importantes |
| NAO_DOC | Componente existe no código, sem qualquer menção na documentação |
| CONFLITO | Doc afirma algo que o código contradiz diretamente |
| INCONSISTENCIA | Doc e código divergem em nomenclatura, contagem ou detalhe sem chegar a contradição total |
| LACUNA | Decisão de design/arquitetura não documentada em nenhum lugar |

---

## 1. Hive / Persistência / Cache

### 1.1 HiveServices — `lib/src/core/services/Hive_services.dart`

**Status: COMPLETO (com uma inconsistência menor)**

A documentação em `local-storage.md` e `services-catalog.md` cobre com precisão:
- Interface `HiveServicesInterface` (4 métodos, assinaturas corretas)
- Implementação `HiveServices` (box `Cache_aplicativo`, uso de `LogServicesInterface`, acoplamento com `CustomToast`)
- Todos os problemas H1–H6 identificados (void/async, tipagem dynamic, fragmentação, acoplamento UI, sem TTL, versão antiga)
- Dependência de `UtilsServicesInterfaces` injetada mas não utilizada (documentada em services-catalog.md §3.6/D2)

**Evidência — código confirma a doc:**
```
Hive_services.dart:10  final UtilsServicesInterfaces utilsServices = Get.find();
Hive_services.dart:11  final LogServicesInterface logservices = Get.find();
Hive_services.dart:15  void setCache(...) async {   // void declarado, await usado internamente
```

**Inconsistência menor (INCONSISTENCIA):**
- `local-storage.md` §4.2 afirma que o token é salvo no box `Cache_aplicativo` com chave `'Autenticacao'`. Essa é a leitura correta do código. Porém, o mesmo documento §1 lista o box `Autenticacao` como box separado — criando ambiguidade: há dois boxes (`Cache_aplicativo` e `Autenticacao`) ou apenas um com chave `'Autenticacao'`? O código confirma que é **um único box** (`Cache_aplicativo`) com a chave `'Autenticacao'`. A tabela §1 da doc é enganosa.
  - Localização: `local-storage.md` linha 17 vs linha 116.

### 1.2 Box `variaves_ambiente` — SettingsAppRepository

**Status: COMPLETO**

Documentado em `local-storage.md` §4.1 com código e problema identificado (bypass da abstração HiveServices). Código confirma.

### 1.3 Mecanismo de abertura de boxes em `main.dart`

**Status: COMPLETO**

`services-catalog.md` Apêndice documenta a ordem crítica de `Hive.openBox` → `Get.put<HiveServicesInterface>`. Confirmado no código.

---

## 2. LogServices / Observabilidade

### 2.1 LogServices — `lib/src/core/services/log_services.dart`

**Status: COMPLETO**

`logging-observability.md` e `services-catalog.md` §4 cobrem:
- Interface `LogServicesInterface` (métodos `log` e `LogOperacoes`)
- Fluxo dual local (Logger) + remoto (POST endpoints)
- Flag de controle `getLogger()`
- Problema de loading global durante envio de log
- Instanciação direta `HttpManager()` em vez de `Get.find()` (dívida D1)
- `~60 print()` espalhados

**Evidência — código confirma a doc:**
```
log_services.dart:22   final HttpManagerInterfaces _httpManager = HttpManager();  // instância direta — dívida D1
log_services.dart:58   loadingController.showLoading();  // loading durante log — problema crítico de UX
log_services.dart:83   Future<bool> LogOperacoes(String mensagem)  // PascalCase — dívida D3
log_services.dart:91   var Autenticacao = jsonDecode(json);  // PascalCase em variável — dívida D5
```

**Inconsistência (INCONSISTENCIA):**
- `logging-observability.md` §3 descreve o endpoint como `GET /api/v1/log-erros-aplicativo (POST)` — há um erro tipográfico: o verbo GET aparece onde deveria estar apenas o path. O código usa `HttpMethods.post`. Confuso para quem ler a doc isoladamente.
  - Localização: `logging-observability.md` linha 97.

### 2.2 `pages_routes.dart` como enum — não documentado em logging-observability.md

**Status: NAO_DOC** (ver seção 6 — enums)

---

## 3. Models / Serialização — ÁREA DE MAIOR LACUNA

### 3.1 Contagem real de models no código

O glob retorna **26 arquivos** em `lib/src/models/`. A documentação em `local-storage.md` §7.3 afirma "25 modelos". Há discrepância de 1 unidade.

**Evidência — contagem dos 26 arquivos:**

| # | Arquivo | Classe no código | Na doc (local-storage.md §7.3)? | Observações |
|---|---|---|---|---|
| 1 | `buscar_produtos_model.dart` | `BuscarProdutosModel` | Sim | — |
| 2 | `conferencias.dart` | `Conferencias` | **NAO** (omitido da tabela) | DUPLICATA — vide item 3 |
| 3 | `conferencias_model.dart` | `Conferencias` | Sim (como `conferencias_model.dart`) | DUPLICATA REAL — mesmo conteúdo byte a byte |
| 4 | `consultar_nf_saida_model.dart` | `ConsultarNfSaidaModel` | Sim | — |
| 5 | `empresas_model.dart` | `EmpresasModel` | Sim | — |
| 6 | `estagio_model.dart` | `EstagioModel` → código tem `Estagio` | Sim (como `EstagioModel`) | INCONSISTENCIA de nome: doc diz `EstagioModel`, classe real é `Estagio` |
| 7 | `fornecedorModel.dart` | `Fornecedor` | **NAO** (omitido da tabela) | DUPLICATA — vide item 8 |
| 8 | `fornecedor_model.dart` | `Fornecedor` | Sim (como `fornecedor_model.dart`) | DUPLICATA REAL — mesmo conteúdo byte a byte |
| 9 | `grupo_model.dart` | `Grupo` | Sim | — |
| 10 | `item_model.dart` | `Item` | Sim (como `ItemModel`) | INCONSISTENCIA: doc diz `ItemModel`, classe real é `Item` |
| 11 | `itens_nf_model.dart` | `ItenNotaFiscal` | Sim (como `ItensNfModel`) | INCONSISTENCIA: doc diz `ItensNfModel`, classe real é `ItenNotaFiscal` |
| 12 | `itens_pedido_model.dart` | `ItensPedidoModel` | Sim | — |
| 13 | `itens_pedido_nf_lotes_model.dart` | `ItensPedidoNfLotesModel` | Sim | — |
| 14 | `log_operacoes_model.dart` | `LogOperacoesModel` | Sim | Bug real: `json['data']?? DateTime.parse('2025-01-22')` — `??` sobre `String` não-nullable |
| 15 | `login_model.dart` | `LoginModel` | Sim | — |
| 16 | `nf_lotes_model.dart` | `NfLotesModel` | Sim | Helper estático `_parseDouble` não documentado |
| 17 | `nf_model.dart` | `NfModel` | Sim | — |
| 18 | `nf_pagas_model.dart` | `NfPagasModel` | Sim | Bug: `checked: json['checked'] ?? 0` — valor default `0` (int) em campo `bool` |
| 19 | `nota_compra_lotes_etiquetas.dart` | `NotaCompraLotesEtiquetas` | Sim | Classe mais complexa (23 campos, `late`, `checked`, `hasSubLote`, `isSublote`) — tabela da doc apenas lista o nome, sem observações |
| 20 | `pedido_completo_model.dart` | `PedidoCompleto` | Sim (como `PedidoCompletoModel`) | INCONSISTENCIA: doc diz `PedidoCompletoModel`, classe real é `PedidoCompleto` |
| 21 | `pedido_venda.dart` | `PedidoVenda` | Sim | — |
| 22 | `pedidos_model.dart` | `PedidosModel` | Sim | Doc registra "sem fromJson — somente toMap". Confirmado: sem `fromJson`. |
| 23 | `produto_model.dart` | `Produto` | Sim (como `Produto`) | Campos com `PascalCase` (`QtdTotalPesoLiqConferido`) não documentados |
| 24 | `selecionar_material_estoque_model.dart` | `SelecionarMaterialEstoqueModel` | Sim | Sem `fromJson` — apenas `toMap`. Não mencionado na doc. |
| 25 | `tansf_mov_lote.dart` | `TansfMovLote` | Sim (como `TransfMovLote`) | INCONSISTENCIA: doc diz classe `TransfMovLote`, código tem `TansfMovLote` (typo no arquivo E na classe) |
| 26 | `transferenci_lote.dart` | `TransferenciaLote` | Sim (como `TransferenciaLote`) | Arquivo tem typo (`transferenci`), classe está correta |

### 3.2 Duplicações reais identificadas no código (não documentadas individualmente)

**DUPLICACAO 1 — `conferencias.dart` vs `conferencias_model.dart`:**
- Ambos definem a classe `Conferencias` com exatamente o mesmo conteúdo (verificado linha a linha).
- Ao importar ambos no mesmo arquivo Dart, há conflito de nome de classe.
- A documentação menciona `conferencias_model.dart` na tabela mas não menciona `conferencias.dart` como duplicata separada — apenas lista 25 modelos omitindo o arquivo extra.
- **Decisão não documentada:** qual dos dois deve ser mantido? O padrão `_model.dart` no sufixo é o adotado no projeto, mas `conferencias.dart` (sem sufixo) existe como cópia.

**DUPLICACAO 2 — `fornecedorModel.dart` vs `fornecedor_model.dart`:**
- Ambos definem a classe `Fornecedor` com exatamente o mesmo conteúdo.
- `fornecedorModel.dart` usa convenção `camelCase` no nome do arquivo (violando o padrão `snake_case` adotado pelo projeto).
- A documentação menciona `fornecedor_model.dart` na tabela mas não menciona `fornecedorModel.dart` — omite a duplicata.
- **Decisão não documentada:** qual é o arquivo canônico? `itens_nf_model.dart` importa `fornecedor_model.dart` (snake_case), que parece ser o correto.

### 3.3 Inconsistências de nomenclatura classe×doc

| Doc afirma | Código real | Arquivo |
|---|---|---|
| `EstagioModel` | `Estagio` | `estagio_model.dart` |
| `ItemModel` | `Item` | `item_model.dart` |
| `ItensNfModel` | `ItenNotaFiscal` | `itens_nf_model.dart` |
| `PedidoCompletoModel` | `PedidoCompleto` | `pedido_completo_model.dart` |
| `TransfMovLote` | `TansfMovLote` | `tansf_mov_lote.dart` |

### 3.4 Bugs reais encontrados nos models — não documentados

A tabela §7.4 da doc lista problemas genéricos (S1–S9), mas não os bugs concretos por model. Bugs encontrados na leitura direta:

| Arquivo | Bug | Severidade |
|---|---|---|
| `nf_pagas_model.dart:18` | `checked: json['checked'] ?? 0` — default é `0` (int) para campo `bool`. Em Dart tipado isso é erro de tipo. | Alto |
| `log_operacoes_model.dart:19` | `data: json['data'] ?? DateTime.parse('2025-01-22')` — campo `data` é `String`, mas o default é um `DateTime`. Tipo errado. | Alto |
| `selecionar_material_estoque_model.dart` | Sem `fromJson` — model não pode ser construído a partir de resposta da API. | Médio |
| `pedidos_model.dart` | Sem `fromJson` — idem. | Médio |
| `item_model.dart:30–31` | `_parseDouble` remove qualquer `.` do valor (incluindo separador decimal) — pode zerar valores como `1.5` → `15`. | Alto |
| `nf_lotes_model.dart:50–51` | Mesmo problema de `_parseDouble` — `.replaceAll('.0', '').replaceAll('.', '')` pode corromper valores decimais. | Alto |
| `produto_model.dart:45` | `conferencias?.map((x) => x.toJson())?.toList()` — o segundo `?.` é inefetivo pois `map()` nunca retorna null. | Baixo |
| `transferenci_lote.dart:43–47` | `?? 0`, `?? ''` em campos `int` e `String` não-nullable (campos não têm `?`) — operadores `??` inefetivos. | Baixo |
| `itens_pedido_model.dart:62–66` | `impresso ?? false`, `conferenciaFinalizada ?? false` — campos não-nullable, `??` inefetivo. | Baixo |

### 3.5 Padrão de serialização

**Status: PARCIAL**

`local-storage.md` §7.2 documenta o padrão geral (fromJson/toJson manual, toMap alias). Correto.

**O que a doc NÃO documenta:**
- Dois models sem `fromJson` (`PedidosModel`, `SelecionarMaterialEstoqueModel`) — uso apenas como DTO de saída.
- Helpers estáticos `_parseDouble` em `NfLotesModel` e `Item` — lógica de conversão com bug potencial.
- O campo `PascalCase` em `Produto` (`QtdTotalPesoLiqConferido`, `QtdTotalPesoBrConferido`, `QtdTotalSaldoFaltaConferir`) violando convenção Dart — não mencionado.
- `NotaCompraLotesEtiquetas` usa campos `late` em vez de `final` — decisão arquitetural sem justificativa documentada.
- `ConsultarNfSaidaModel` importa `pluto_grid` — dependência de biblioteca de UI dentro de model (violação de camada). Não documentado.

---

## 4. Serviços Compartilhados

### 4.1 FormatarValores — `lib/src/core/utils/formatar_valores.dart`

**Status: COMPLETO**

`services-catalog.md` §5 cobre: interface, todos os 5 métodos com assinaturas, implementação, dívidas D1–D3, classificação. O código confirma todos os pontos.

**Única observação adicional (LACUNA):**
- `convertBRLToUSD` não usa taxa de câmbio — registrado como dívida D2. Porém a doc não explica o motivo pelo qual o método existe com esse nome enganoso, nem em qual contexto do app ele é chamado. Sem rastreabilidade de uso.

### 4.2 UtilsServices — `lib/src/core/utils/utils_services.dart`

**Status: COMPLETO**

Doc descreve corretamente que é placeholder vazio. Código confirma (9 linhas, sem implementação).

**Evidência:**
```
utils_services.dart:6   class UtilsServices implements UtilsServicesInterfaces {
utils_services.dart:8   }
```

### 4.3 HttpManager — `lib/src/core/services/http_manager.dart`

**Status: COMPLETO** (cobertura de outro documento — `services-catalog.md` §2)

Não é foco desta área, mas consta no catálogo com alta fidelidade.

---

## 5. Utils / Helpers / Extensions / Validators

### 5.1 Validators — `lib/src/core/utils/validators.dart`

**Status: PARCIAL**

`services-catalog.md` §7 documenta 8 funções com assinaturas e observações. O código confirma a existência de todas as 8.

**O que a doc registra corretamente:**
- Dívida D1: `passwordValidator` valida `< 3` mas mensagem diz "7 caracteres" — **confirmado no código** (`validators.dart:20-21`).
- Dívida D2: `UsuarioValidator` em PascalCase — confirmado (`validators.dart:39`).
- Dívida D3: `cpfvalidator` em minúsculo — confirmado (`validators.dart:75`).

**O que a doc NÃO documenta:**
- `passwordValidator` recebe `dynamic password` (não `String?`) — o código (`validators.dart:15`) usa `dynamic` sem type safety. A doc documenta a assinatura como `String? Function(dynamic password)` mas não destaca o risco de aceitar qualquer tipo sem cast.
- Não há documentação de quais telas/formulários consomem cada validator — rastreabilidade ausente.

### 5.2 Extensions e Helpers — `grep 'extension ' em lib/`

**Status: NAO_DOC (inexistência confirmada)**

O grep por `extension ` em todo `lib/` retornou zero resultados. O projeto **não possui nenhuma extension Dart própria**. As únicas "extensions" utilizadas são as do pacote `get` (`String.isEmail`, `String.isCpf`, `String.isPhoneNumber`) — usadas em `validators.dart`.

A documentação não menciona extensions porque não existem. Correto por omissão.

**Decisão não documentada (LACUNA):** Por que não foram criadas extensions (ex.: `DateTime.toFormatoBR()`) sendo que `FormatarValores` cumpre esse papel via serviço? A escolha por serviço injetável em vez de extension é uma decisão arquitetural sem registro.

---

## 6. Enum `http_methods.dart`

**Status: PARCIAL — com inconsistência estrutural**

`services-catalog.md` §1 e seções de `HttpManager` referenciam `HttpMethods.post`, `HttpMethods.get`, etc. O código é mencionado em contexto mas o arquivo `lib/src/enum/http_methods.dart` não recebe uma seção própria de documentação.

**Evidência do código:**
```dart
// http_methods.dart
abstract class HttpMethods {
  static const post = 'POST';
  static const put = 'PUT';
  static const patch = 'PATCH';
  static const delete = 'DELETE';
  static const get = 'GET';

  final String method;
  const HttpMethods(this.method);
}
```

**Inconsistências encontradas:**

1. **INCONSISTENCIA de tipagem:** `HttpMethods` é declarada como `abstract class` com constantes estáticas — não é um `enum` Dart real. O nome do arquivo é `http_methods.dart` e a tarefa de auditoria o chama de "enum http_methods", mas estruturalmente é uma classe abstrata usada como namespace de constantes. A doc nunca esclarece isso.

2. **Campo sem uso:** `final String method` e `const HttpMethods(this.method)` existem mas a classe é abstrata e nunca instanciada — o construtor e o campo são dead code. Não documentado.

3. **Colisão de nome:** `HttpMethods.get` colide potencialmente com `get` keyword do Dart em contextos de importação. Não documentado como risco.

4. **`pages_routes.dart` — enum real, não documentado:**
   - Arquivo `lib/src/enum/pages_routes.dart` define um `enum PagesRoutes` com 13 rotas.
   - **NAO_DOC:** Não há menção a este enum em nenhum dos três documentos auditados. A doc de navegação (`02-infrastructure/navigation.md`) poderia cobri-lo, mas não é escopo desta auditoria.

---

## 7. Resumo por Categoria

### 7.1 Completo

- `HiveServices` (interface + implementação + problemas) → `local-storage.md` + `services-catalog.md`
- `LogServices` (dual channel, fluxos, dívidas) → `logging-observability.md` + `services-catalog.md`
- `FormatarValores` (todos os métodos, dívidas) → `services-catalog.md`
- `UtilsServices` (placeholder, intenção) → `services-catalog.md`
- Padrão geral de serialização (`fromJson`/`toJson` manual, `toMap` alias, `json_annotation` sem uso) → `local-storage.md`
- Boxes Hive e suas responsabilidades → `local-storage.md`

### 7.2 Parcial

- `Validators` — funções documentadas, mas assinatura `dynamic` não destacada, sem rastreabilidade de uso
- Padrão de serialização — cobre o padrão geral, mas omite: 2 models sem `fromJson`, helpers `_parseDouble` com bug, campos `late` e `PascalCase`
- `http_methods.dart` — usado na doc mas sem seção própria, natureza de classe vs enum não esclarecida
- Lista de models — 24 dos 26 modelos listados, mas com 5 nomes de classe errados e sem colunas de campos

### 7.3 Não Documentado

| Item | Localização | Impacto |
|---|---|---|
| `conferencias.dart` (duplicata de `conferencias_model.dart`) | `lib/src/models/conferencias.dart` | Médio — conflito de classe se ambos forem importados |
| `fornecedorModel.dart` (duplicata de `fornecedor_model.dart`) | `lib/src/models/fornecedorModel.dart` | Médio — arquivo com convenção errada, conteúdo idêntico |
| `pages_routes.dart` (enum de rotas) | `lib/src/enum/pages_routes.dart` | Médio — enum central de navegação sem documentação |
| Bugs concretos por model (`NfPagasModel`, `LogOperacoesModel`, `_parseDouble`) | Vários arquivos em `lib/src/models/` | Alto — bugs silenciosos em runtime |
| `ConsultarNfSaidaModel` importa `pluto_grid` (violação de camada) | `consultar_nf_saida_model.dart:1` | Médio — acoplamento model-UI |
| Helpers estáticos `_parseDouble` em `NfLotesModel` e `Item` | `nf_lotes_model.dart`, `item_model.dart` | Alto — lógica de conversão com potencial de corromper valores |
| Extensions: nenhuma existe (decisão arquitetural) | — | Baixo — ausência documentada implicitamente |
| Dead code em `HttpMethods` (campo `method`, construtor) | `http_methods.dart:8-9` | Baixo |

### 7.4 Aprofundamento necessário

1. **`_parseDouble` nos models `NfLotesModel` e `Item`:** a lógica `.replaceAll('.0', '').replaceAll('.', '')` remove o separador decimal, convertendo `1.5` em `15`. Isso é um bug de alto impacto para um sistema de controle de peso/lote. A doc descreve o problema S6 (DateTime) mas não capturou este bug.

2. **Models sem `fromJson`:** `PedidosModel` e `SelecionarMaterialEstoqueModel` só têm `toMap()`. Isso significa que eles não são construídos a partir de resposta de API — provavelmente são DTOs de envio. Não está documentado esse papel distinto.

3. **`NotaCompraLotesEtiquetas` — complexidade não documentada:** 23 campos, campos de estado da UI (`checked`, `hasSubLote`, `isSublote`, `dividido`), campos `late` que viabilizam reatribuição. É o model mais complexo e recebe apenas uma linha na tabela da doc.

---

## 8. Inconsistências Doc × Código

| # | Inconsistência | Documento | Código | Severidade |
|---|---|---|---|---|
| I1 | Doc lista box `Autenticacao` como box separado na tabela §1, mas §4.2 confirma que é chave no box `Cache_aplicativo` | `local-storage.md` linhas 17 e 116 | `Hive_services.dart` — único box `Cache_aplicativo` | Média |
| I2 | Endpoint de log descrito com verbo errado `GET /api/v1/log-erros-aplicativo (POST)` | `logging-observability.md` linha 97 | `log_services.dart:65` — `HttpMethods.post` | Baixa |
| I3 | Doc afirma "25 modelos" | `local-storage.md` §7.1 | Glob retorna 26 arquivos | Média |
| I4 | Doc usa nome `EstagioModel` | `local-storage.md` §7.3 | Classe se chama `Estagio` | Baixa |
| I5 | Doc usa nome `ItemModel` | `local-storage.md` §7.3 | Classe se chama `Item` | Baixa |
| I6 | Doc usa nome `ItensNfModel` | `local-storage.md` §7.3 | Classe se chama `ItenNotaFiscal` | Baixa |
| I7 | Doc usa nome `PedidoCompletoModel` | `local-storage.md` §7.3 | Classe se chama `PedidoCompleto` | Baixa |
| I8 | Doc usa nome `TransfMovLote` | `local-storage.md` §7.3 | Classe se chama `TansfMovLote` | Baixa |
| I9 | `HttpMethods` referenciado como "enum" na tarefa e uso | Uso no código e tarefa | É `abstract class`, não `enum` | Baixa |

---

## 9. Duplicações Entre Docs

| Duplicação | Documentos envolvidos | Detalhes |
|---|---|---|
| D1 | `local-storage.md` §3 e `services-catalog.md` §3 | Ambos documentam `HiveServices` com nível similar de detalhe. `services-catalog.md` é mais completo (fluxo por método, tabela de dívidas). `local-storage.md` adiciona classificação por componente e recomendações para template. Conteúdo complementar, mas há sobreposição de ~40% no texto sobre contratos e implementação. |
| D2 | `local-storage.md` §7 e nenhum outro documento | Models documentados apenas em `local-storage.md` — não há duplicação, mas o escopo do documento é questionável: "Persistência Local, Cache e Modelos/Serialização" mistura infraestrutura de storage com catálogo de modelos de domínio. |
| D3 | `services-catalog.md` §4 e `logging-observability.md` | Ambos documentam `LogServices`. `services-catalog.md` é mais técnico (contrato, dívidas, fluxo de DI). `logging-observability.md` foca no comportamento (níveis, UX, lacunas de observabilidade). Complementares, sem conflito, mas ~30% de sobreposição no fluxo `log()`. |

---

## 10. Decisões Não Documentadas (LACUNA)

| # | Decisão | Onde deveria estar documentada |
|---|---|---|
| L1 | Por que existem dois arquivos `conferencias.dart` e `conferencias_model.dart` com conteúdo idêntico? | `local-storage.md` §7 ou ADR |
| L2 | Por que existem `fornecedorModel.dart` e `fornecedor_model.dart` com conteúdo idêntico? | `local-storage.md` §7 ou ADR |
| L3 | Por que `NotaCompraLotesEtiquetas` usa campos `late` ao invés de `final` (imutabilidade sacrificada)? | `local-storage.md` §7 |
| L4 | Por que `ConsultarNfSaidaModel` importa `pluto_grid` (lib de UI)? Qual campo ou método requer isso? | `local-storage.md` §7 |
| L5 | Escolha por serviço injetável (`FormatarValores`) em vez de extension Dart para formatação | `services-catalog.md` §5 ou ADR |
| L6 | Por que `HttpMethods` é `abstract class` em vez de `enum` Dart? O campo `method` no construtor jamais é usado. | `services-catalog.md` ou seção de enums |
| L7 | `PedidosModel` e `SelecionarMaterialEstoqueModel` não têm `fromJson` — são DTOs somente de envio? | `local-storage.md` §7 |
| L8 | Lógica `_parseDouble` em models de lote (remove ponto de milhar) — decisão de normalização de dados da API | `local-storage.md` §7 |

---

## 11. Percentual Estimado de Cobertura da Área

| Subárea | Cobertura Estimada | Justificativa |
|---|---|---|
| Hive / Persistência / Cache | **88%** | HiveServices, boxes, interface, problemas todos documentados. Desconto por ambiguidade da tabela de boxes (I1) e falta de TTL. |
| LogServices / Observabilidade | **85%** | Cobertura muito boa, dual channel documentado. Desconto por erro tipográfico no endpoint (I2) e ausência de rastreabilidade de `print()` por arquivo. |
| Models / Serialização — CATÁLOGO | **30%** | Padrão geral documentado. Mas: 2 duplicatas omitidas, 5 nomes de classe errados, bugs concretos não mapeados, `_parseDouble` não documentado, 2 models sem `fromJson` sem explicação, `ConsultarNfSaidaModel` importa UI. A tabela §7.3 lista nomes sem campos, sem papéis, sem anomalias por model. |
| Serviços Compartilhados (FormatarValores, UtilsServices) | **92%** | Excelente cobertura. Desconto mínimo por falta de rastreabilidade de uso de `convertBRLToUSD`. |
| Utils / Validators | **78%** | Todos os validators documentados com dívidas. Desconto por assinatura `dynamic` não destacada como risco e por ausência de rastreabilidade de uso. |
| Extensions / Helpers | **95%** | Inexistência de extensions confirmada. Grep sem resultados. Pequeno desconto por não documentar a decisão arquitetural de não usar extensions. |
| Enum `http_methods.dart` | **45%** | Referenciado em uso mas sem seção própria, natureza de classe vs enum não esclarecida, dead code não documentado. |
| Enum `pages_routes.dart` | **0%** | Não documentado em nenhum dos três docs auditados. |

**COBERTURA GLOBAL ESTIMADA DA ÁREA 4: ~68%**

**Justificativa:** A infraestrutura de serviços (Hive, Log, FormatarValores) está bem documentada (85–92%). O puxão para baixo é causado quase inteiramente pela seção de Models, que representa o maior volume de artefatos (26 classes) e tem cobertura de apenas ~30% em termos de fidelidade (nomes errados de classes, duplicatas omitidas, bugs concretos ausentes, campos e decisões não documentadas).

---

## 12. Tabela de Evidências Consolidada

| Achado | Arquivo de código | Arquivo de doc | Tipo |
|---|---|---|---|
| `void setCache()` com `await` interno | `Hive_services.dart:15` | `local-storage.md` §3.2/H1 | Completo |
| `UtilsServicesInterfaces` injetado e não usado em `HiveServices` | `Hive_services.dart:10` | `services-catalog.md` §3.6/D2 | Completo |
| `HttpManager()` instanciado diretamente em `LogServices` | `log_services.dart:22` | `services-catalog.md` §4.6/D1 | Completo |
| Loading global durante envio de log | `log_services.dart:58-79` | `logging-observability.md` §3 | Completo |
| `LogOperacoes` em PascalCase | `log_services.dart:83` | `services-catalog.md` §4.6/D3 | Completo |
| `passwordValidator` valida `< 3` mas mensagem diz 7 | `validators.dart:20-21` | `services-catalog.md` §7.5/D1 | Completo |
| Endpoint de log descrito como GET em vez de POST | `log_services.dart:65` | `logging-observability.md` linha 97 | CONFLITO |
| Box `Autenticacao` listada como box separado | `Hive_services.dart:13` | `local-storage.md` linha 17 | INCONSISTENCIA |
| 26 arquivos de model vs doc afirma 25 | `lib/src/models/` (glob) | `local-storage.md` §7.1 | INCONSISTENCIA |
| `conferencias.dart` duplicata byte-a-byte de `conferencias_model.dart` | Ambos em `lib/src/models/` | Ausente na doc | NAO_DOC/DUPLICACAO |
| `fornecedorModel.dart` duplicata de `fornecedor_model.dart` | Ambos em `lib/src/models/` | Ausente na doc | NAO_DOC/DUPLICACAO |
| `NfPagasModel.checked: json['checked'] ?? 0` — int em bool | `nf_pagas_model.dart:18` | Ausente na doc | NAO_DOC/BUG |
| `LogOperacoesModel.data: ?? DateTime.parse(...)` — DateTime em String | `log_operacoes_model.dart:19` | Ausente na doc | NAO_DOC/BUG |
| `_parseDouble` remove separador decimal, corrompe valores | `nf_lotes_model.dart:50`, `item_model.dart:30` | Ausente na doc | NAO_DOC/BUG |
| `ConsultarNfSaidaModel` importa `pluto_grid` (UI em model) | `consultar_nf_saida_model.dart:1` | Ausente na doc | NAO_DOC/LACUNA |
| `PedidosModel` e `SelecionarMaterialEstoqueModel` sem `fromJson` | Respectivos arquivos | Parcialmente (PedidosModel mencionado sem explicação do papel) | PARCIAL |
| `HttpMethods` é `abstract class`, não `enum` | `http_methods.dart:1` | Nunca esclarecido | NAO_DOC/LACUNA |
| `pages_routes.dart` — enum de rotas com 13 entradas | `lib/src/enum/pages_routes.dart` | Ausente nos 3 docs auditados | NAO_DOC |
| Sem extensions Dart próprias no projeto | grep lib/ sem resultado | Ausente (corretamente) | OK |
| Classe `Estagio` vs nome doc `EstagioModel` | `estagio_model.dart:1` | `local-storage.md` §7.3 | INCONSISTENCIA |
| Classe `Item` vs nome doc `ItemModel` | `item_model.dart:3` | `local-storage.md` §7.3 | INCONSISTENCIA |
| Classe `ItenNotaFiscal` vs nome doc `ItensNfModel` | `itens_nf_model.dart:8` | `local-storage.md` §7.3 | INCONSISTENCIA |
| Classe `PedidoCompleto` vs nome doc `PedidoCompletoModel` | `pedido_completo_model.dart:4` | `local-storage.md` §7.3 | INCONSISTENCIA |
| Classe `TansfMovLote` vs nome doc `TransfMovLote` | `tansf_mov_lote.dart:1` | `local-storage.md` §7.3 | INCONSISTENCIA |
