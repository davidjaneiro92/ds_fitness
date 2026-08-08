# Catálogo de Models — controle_separacao_aplicativo

> **Fonte:** `lib/src/models/` — leitura direta do código-fonte legado.
> **Total de arquivos:** 26 (confirmado).
> **Idioma do catálogo:** PT-BR.
> **Padrão de serialização preservado:** manual (`fromJson` / `toJson` / `toMap` como alias).

---

## 1. Tabela Mestre

| # | Arquivo | Classe real | `fromJson` | `toJson` | Observações | Classificação |
|---|---------|-------------|:----------:|:--------:|-------------|---------------|
| 1 | `buscar_produtos_model.dart` | `BuscarProdutosModel` | ✔ | ✔ (`toMap` alias) | — | ✅ Reutilizar |
| 2 | `conferencias.dart` | `Conferencias` | ✔ | ✔ (`toMap` alias) | **DUPLICATA** — conteúdo byte-a-byte idêntico ao `conferencias_model.dart` | 🔴 Descartar |
| 3 | `conferencias_model.dart` | `Conferencias` | ✔ | ✔ (`toMap` alias) | Cópia canônica; importada em `produto_model.dart` | ✅ Reutilizar |
| 4 | `consultar_nf_saida_model.dart` | `ConsultarNfSaidaModel` | ✔ | ✔ (`toMap` alias) | **BUG:** `import 'package:pluto_grid/pluto_grid.dart'` (dependência de widget de UI dentro do model) | ✅ Reutilizar |
| 5 | `empresas_model.dart` | `EmpresasModel` | ✔ | ✔ (`toMap` alias) | — | ✅ Reutilizar |
| 6 | `estagio_model.dart` | `Estagio` | ✔ | ✔ (`toMap` alias) | Nome da classe diverge do arquivo (`estagio_model` → `Estagio`) | ✅ Reutilizar |
| 7 | `fornecedor_model.dart` | `Fornecedor` | ✔ | ✔ (`toMap` alias) | Cópia canônica em snake_case | ✅ Reutilizar |
| 8 | `fornecedorModel.dart` | `Fornecedor` | ✔ | ✔ (`toMap` alias) | **DUPLICATA** — conteúdo idêntico a `fornecedor_model.dart`; nome fora do padrão camelCase (`fornecedorModel`) | 🔴 Descartar |
| 9 | `grupo_model.dart` | `Grupo` | ✔ | ✔ (`toMap` alias) | Nome da classe diverge do arquivo (`grupo_model` → `Grupo`) | ✅ Reutilizar |
| 10 | `item_model.dart` | `Item` | ✔ | ✔ (`toMap` alias) | **BUG:** `_parseDouble` remove separadores decimais (ex.: `"1.5"` → `parse("15")` = `15.0`) | ✅ Reutilizar |
| 11 | `itens_nf_model.dart` | `ItenNotaFiscal` | ✔ | ✔ (`toMap` alias) | Nome da classe diverge do arquivo (`itens_nf_model` → `ItenNotaFiscal`); importa `fornecedor_model.dart` e `item_model.dart` | ✅ Reutilizar |
| 12 | `itens_pedido_model.dart` | `ItensPedidoModel` | ✔ | ✔ (`toMap` alias) | `toJson` chama `?? false` / `?? 0.0` em campos `bool`/`double` não-nulos (inofensivo mas redundante) | ✅ Reutilizar |
| 13 | `itens_pedido_nf_lotes_model.dart` | `ItensPedidoNfLotesModel` | ✔ | ✔ (`toMap` alias) | Campo `NfLotes` usa `PascalCase` (deveria ser `nfLotes`); composição com `PedidoVenda` e `NfLotesModel` | ✅ Reutilizar |
| 14 | `log_operacoes_model.dart` | `LogOperacoesModel` | ✔ | ✔ (`toMap` alias) | **BUG:** `data` declarado `String`; default do `fromJson` é `DateTime.parse('2025-01-22')` (retorna `DateTime`, atribuído a campo `String`) | ✅ Reutilizar |
| 15 | `login_model.dart` | `LoginModel` | ✔ | ✔ (`toMap` alias) | — | ✅ Reutilizar |
| 16 | `nf_lotes_model.dart` | `NfLotesModel` | ✔ | ✔ (`toMap` alias) | **BUG:** `_parseDouble` remove separadores (ex.: `1.5` → `15.0`); campos `notaFiscal` e `lote` ausentes no `toJson` | ✅ Reutilizar |
| 17 | `nf_model.dart` | `NfModel` | ✔ | ✔ (`toMap` alias) | `toJson` formata datas como `"yyyy-MM-dd"` (perde horário); importa `intl` | ✅ Reutilizar |
| 18 | `nf_pagas_model.dart` | `NfPagasModel` | ✔ | ✔ (`toMap` alias) | **BUG:** `checked: json['checked'] ?? 0` — default `int 0` para campo `bool`; `toJson` serializa `data` como objeto `NfModel` (não chama `.toJson()`) | ✅ Reutilizar |
| 19 | `nota_compra_lotes_etiquetas.dart` | `NotaCompraLotesEtiquetas` | ✔ | ✔ (`toMap` alias) | Campos `checked`, `hasSubLote`, `isSublote` omitidos no `fromJson` (usam defaults); `parseDate` lança `FormatException` se data nula | ✅ Reutilizar |
| 20 | `pedido_completo_model.dart` | `PedidoCompleto` | ✔ | ✔ (sem `toMap`) | Nome da classe diverge do arquivo (`pedido_completo_model` → `PedidoCompleto`); único model sem `toMap` | ✅ Reutilizar |
| 21 | `pedido_venda.dart` | `PedidoVenda` | ✔ | ✔ (`toMap` alias) | `dataHoraUltimoEstagio` formata como `"yyyy-MM-dd HH:mm"` no `toJson`; `DateTime.parse('')` lança exceção se campo ausente | ✅ Reutilizar |
| 22 | `pedidos_model.dart` | `PedidosModel` | ✗ (DTO de saída) | `toMap` apenas (`Map<String,String>`) | Sem `fromJson`; DTO de saída para formulários; `toMap` retorna `Map<String,String>`, diferente do padrão `Map<String,dynamic>` | ✅ Reutilizar |
| 23 | `produto_model.dart` | `Produto` | ✔ | ✔ (`toMap` alias) | Campos com `PascalCase` (`QtdTotalPesoLiqConferido`, etc.); importa `conferencias_model.dart` e `grupo_model.dart` | ✅ Reutilizar |
| 24 | `selecionar_material_estoque_model.dart` | `SelecionarMaterialEstoqueModel` | ✗ (DTO de saída) | `toMap` apenas | Sem `fromJson`; DTO de saída; único model onde `pesosLiquido` é `String` (não `double`) | ✅ Reutilizar |
| 25 | `tansf_mov_lote.dart` | `TansfMovLote` | ✔ | ✔ (sem `toMap`) | Nome do arquivo com erro tipográfico (`tansf` em vez de `transf`); classe `TansfMovLote` mantém o mesmo typo; sem `toMap` | ✅ Reutilizar |
| 26 | `transferenci_lote.dart` | `TransferenciLote` | ✔ | ✔ (`toMap` alias) | Nome do arquivo com erro tipográfico (`transferenci` em vez de `transferencia`); `codigoProd` declarado `int` mas `toJson` serializa como `''` (string) se nulo | ✅ Reutilizar |

---

## 2. Fichas por Model

### 2.1 `buscar_produtos_model.dart` → `BuscarProdutosModel`

| Campo | Tipo | Default |
|-------|------|---------|
| `codigoProd` | `String` | `''` |
| `empCodigo` | `String` | `''` |
| `codigoGrupo` | `int` | `0` |
| `marcaCodigo` | `int` | `0` |
| `descri` | `String` | `''` |
| `unidad` | `String` | `''` |
| `quantidade` | `double?` | `null` / `0` |

Serialização: `fromJson` ✔ · `toJson` ✔ · `toMap` = alias de `toJson`.

---

### 2.2 `conferencias.dart` e `conferencias_model.dart` → `Conferencias` (DUPLICATAS)

> Ambos os arquivos contêm exatamente o mesmo código-fonte.

| Campo | Tipo | Default |
|-------|------|---------|
| `sequencia` | `int` | `0` |
| `lote` | `String` | `''` |
| `pesoBr` | `double` | `0.0` |
| `emb` | `double` | `0.0` |
| `pesoLiq` | `double` | `0.0` |

Serialização: `fromJson` ✔ · `toJson` ✔ · `toMap` = alias.
Comentário: campo `fotoEtiqueta: String` existe mas está comentado em todo o arquivo.

---

### 2.3 `consultar_nf_saida_model.dart` → `ConsultarNfSaidaModel`

| Campo | Tipo | Default |
|-------|------|---------|
| `notaFiscal` | `int` | `0` |
| `serie` | `String` | `''` |
| `dataEmissao` | `DateTime` | obrigatório |
| `fornecedor` | `int` | `0` |
| `descFornecidor` | `String` | `''` |
| `empresaCod` | `int` | `0` |
| `marcaCod` | `int` | `0` |
| `grupoAlmox` | `int` | `0` |
| `produtoAlmox` | `String` | `''` |
| `produto` | `String` | `''` |
| `descProduto` | `String` | `''` |
| `sequenciaItem` | `int` | `0` |
| `sequenciaLote` | `int` | `0` |
| `lote` | `String` | `''` |
| `unidade` | `String` | `''` |
| `pesoLiquido` | `double` | `0.0` |
| `saldo` | `double` | `0.0` |
| `embalagemPeso` | `double` | `0.0` |
| `pedido` | `int` | `0` |
| `tipoPedido` | `String` | `''` |
| `dividido` | `bool` | `false` |

Serialização: `fromJson` ✔ · `toJson` ✔ · `toMap` = alias.
**Bug documentado:** `import 'package:pluto_grid/pluto_grid.dart'` — dependência de pacote de UI (widget de grade) dentro de um model de dados. O import não é usado em nenhum campo ou método do model, mas está presente no arquivo.

---

### 2.4 `empresas_model.dart` → `EmpresasModel`

| Campo | Tipo | Default |
|-------|------|---------|
| `empCodigo` | `int` | `0` |
| `empRazSoc` | `String` | `''` |

Serialização: `fromJson` ✔ · `toJson` ✔ · `toMap` = alias.

---

### 2.5 `estagio_model.dart` → `Estagio`

| Campo | Tipo | Default |
|-------|------|---------|
| `codigo` | `int` | obrigatório (sem null-safe em fromJson) |
| `nome` | `String` | obrigatório (sem null-safe em fromJson) |

Serialização: `fromJson` ✔ · `toJson` ✔ · `toMap` = alias.
Nota: `fromJson` não usa `?? 0` / `?? ''`; lança exceção se campos ausentes no JSON.

---

### 2.6 `fornecedor_model.dart` → `Fornecedor` (canônico)
### 2.7 `fornecedorModel.dart` → `Fornecedor` (DUPLICATA — descartar)

| Campo | Tipo | Default |
|-------|------|---------|
| `codigo` | `int` (final) | `0` |
| `razaoSocial` | `String` (final) | `''` |
| `nomeFantasia` | `String` (final) | `''` |
| `documentoNro` | `int` (final) | `0` |

Serialização: `fromJson` ✔ · `toJson` ✔ · `toMap` = alias.

---

### 2.8 `grupo_model.dart` → `Grupo`

| Campo | Tipo | Default |
|-------|------|---------|
| `codigo` | `int` | `0` |
| `nome` | `String` | `''` |

Serialização: `fromJson` ✔ · `toJson` ✔ · `toMap` = alias.

---

### 2.9 `item_model.dart` → `Item`

| Campo | Tipo | Default |
|-------|------|---------|
| `sequencia` | `int` (final) | `0` |
| `unidadeCod` | `String` (final) | `''` |
| `quantidade` | `double` (final) | via `_parseDouble` |
| `produto` | `Produto` (final) | obrigatório |

Serialização: `fromJson` ✔ · `toJson` ✔ · `toMap` = alias.
**Bug documentado:** `_parseDouble` remove `.` antes de `parse`:
- `value.replaceAll(RegExp(r'\.0$'), '').replaceAll('.', '')` converte `"1.5"` → `"15"` → `15.0`
- Valor `1.500` vira `1500.0`; separador de milhar e decimal são tratados igualmente.

---

### 2.10 `itens_nf_model.dart` → `ItenNotaFiscal`

| Campo | Tipo | Default |
|-------|------|---------|
| `numero` | `int` (final) | `0` |
| `serie` | `String` (final) | `''` |
| `empresaCod` | `int` (final) | `0` |
| `marcaCod` | `int` (final) | `0` |
| `dhEmissao` | `DateTime` (final) | obrigatório; lança `FormatException` se nulo |
| `dhDigitacao` | `DateTime` (final) | obrigatório; lança `FormatException` se nulo |
| `fornecedor` | `Fornecedor` (final) | composição |
| `itens` | `List<Item>` (final) | composição |

Serialização: `fromJson` ✔ · `toJson` ✔ · `toMap` = alias.
Importa: `intl`, `fornecedor_model.dart`, `item_model.dart`.

---

### 2.11 `itens_pedido_model.dart` → `ItensPedidoModel`

| Campo | Tipo | Default |
|-------|------|---------|
| `empresaCod` | `int` | `0` |
| `marcaCod` | `int` | `0` |
| `pedido` | `int` | `0` |
| `sequencia` | `int` | `0` |
| `produtoCod` | `String` | `''` |
| `produtoDescricao` | `String` | `''` |
| `quantidade` | `double` | `0.0` |
| `impresso` | `bool` | obrigatório |
| `conferenciaFinalizada` | `bool` | `false` |
| `conferenciaIniciada` | `bool` | `false` |
| `pesoUtrapasou` | `bool` | `false` |
| `corPadrao` | `bool` | `false` |
| `pesoLiquidoConferido` | `double` | `0.0` |

Serialização: `fromJson` ✔ · `toJson` ✔ · `toMap` = alias.

---

### 2.12 `itens_pedido_nf_lotes_model.dart` → `ItensPedidoNfLotesModel`

| Campo | Tipo | Default |
|-------|------|---------|
| `empresaCod` | `int` | `0` |
| `marcaCod` | `int` | `0` |
| `pedido` | `int` | `0` |
| `sequencia` | `int` | `0` |
| `produtoCod` | `String` | `''` |
| `produtoDescricao` | `String` | `''` |
| `quantidade` | `double` | `0.0` |
| `impresso` | `bool` | `false` |
| `pedidosVendas` | `PedidoVenda` | composição |
| `NfLotes` | `List<NfLotesModel>` | `[]` |

Serialização: `fromJson` ✔ · `toJson` ✔ · `toMap` = alias.
Nota: campo `NfLotes` usa `PascalCase` (convenção diverge de `camelCase`).

---

### 2.13 `log_operacoes_model.dart` → `LogOperacoesModel`

| Campo | Tipo | Default |
|-------|------|---------|
| `mensagem` | `String` | `''` |
| `usuario` | `String` | `''` |
| `programa` | `String` | `''` |
| `data` | `String` | `''` |

Serialização: `fromJson` ✔ · `toJson` ✔ · `toMap` = alias.
**Bug documentado:** `data: json['data'] ?? DateTime.parse('2025-01-22')` — o default retorna um objeto `DateTime`, atribuído a um campo declarado como `String`. Em Dart com null safety, isso causa erro de tipo em runtime se `json['data']` for nulo.

---

### 2.14 `login_model.dart` → `LoginModel`

| Campo | Tipo | Default |
|-------|------|---------|
| `usuario` | `String` | `''` |
| `senha` | `String` | `''` |

Serialização: `fromJson` ✔ · `toJson` ✔ · `toMap` = alias.

---

### 2.15 `nf_lotes_model.dart` → `NfLotesModel`

| Campo | Tipo | Default |
|-------|------|---------|
| `empresaCod` | `int` (final) | `0` |
| `marcaCod` | `int` (final) | `0` |
| `grupo` | `int` (final) | `0` |
| `produto` | `String` (final) | `''` |
| `notaFiscal` | `int` (final) | `0` |
| `serie` | `String` (final) | `''` |
| `lote` | `String` (final) | `''` |
| `pesoLiquido` | `double` (final) | via `_parseDouble` |
| `saldo` | `double` (final) | via `_parseDouble` |
| `embalagemPeso` | `double` (final) | `0` |
| `checked` | `bool` | `false` |

Serialização: `fromJson` ✔ · `toJson` ✔ · `toMap` = alias.
**Bug documentado (1):** `_parseDouble` usa `replaceAll('.0', '').replaceAll('.', '')` — remove ponto decimal e separador de milhar indistintamente (igual ao `Item`). Ex.: `"1.5"` → `15.0`.
**Bug documentado (2):** `toJson` omite os campos `notaFiscal` e `lote` que existem na classe.

---

### 2.16 `nf_model.dart` → `NfModel`

| Campo | Tipo | Default |
|-------|------|---------|
| `empresaCod` | `int` (final) | `0` |
| `marcaCod` | `int` (final) | `0` |
| `numero` | `int` (final) | `0` |
| `serie` | `String` (final) | `''` |
| `dhEmissao` | `DateTime` (final) | obrigatório |
| `dhDigitacao` | `DateTime` (final) | obrigatório |
| `fornecedor` | `Fornecedor` (final) | composição |
| `integradaEmCompras` | `bool` | `false` |
| `pesoLiquido` | `double` | `0` |

Serialização: `fromJson` ✔ · `toJson` ✔ · `toMap` = alias.
Nota: `toJson` formata datas com `DateFormat("yyyy-MM-dd")` (sem hora); importa `intl` e `fornecedor_model.dart`.

---

### 2.17 `nf_pagas_model.dart` → `NfPagasModel`

| Campo | Tipo | Default |
|-------|------|---------|
| `id` | `int` | `0` |
| `checked` | `bool` | `false` |
| `data` | `NfModel` | composição |

Serialização: `fromJson` ✔ · `toJson` ✔ · `toMap` = alias.
**Bug documentado (1):** `checked: json['checked'] ?? 0` — default é `int 0` para campo `bool`; em null safety, lança erro de tipo se `json['checked']` for nulo.
**Bug documentado (2):** `toJson` inclui `'data': data` sem chamar `.toJson()`, serializando o objeto `NfModel` diretamente — causa `JsonUnsupportedObjectError` na serialização JSON.

---

### 2.18 `nota_compra_lotes_etiquetas.dart` → `NotaCompraLotesEtiquetas`

| Campo | Tipo | Default |
|-------|------|---------|
| `notaFiscal` | `int` (final) | `0` |
| `serie` | `String` (final) | `''` |
| `dataEmissao` | `DateTime` (late) | obrigatório |
| `fornecedor` | `int` (late) | `0` |
| `empresaCod` | `int` (late) | `0` |
| `marcaCod` | `int` (late) | `0` |
| `grupoAlmox` | `int` (late) | `0` |
| `produtoAlmox` | `String` (late) | `''` |
| `produto` | `String` (late) | `''` |
| `sequenciaItem` | `int` (late) | `0` |
| `sequenciaLote` | `int` (late) | `0` |
| `lote` | `String` (late) | `''` |
| `unidade` | `String` (final) | `''` |
| `pesoLiquido` | `double` (late) | `0` |
| `pedido` | `int` (late) | `0` |
| `transferencia` | `int` (late) | `0` |
| `tipoPedido` | `String` (late) | `''` |
| `embalagemPeso` | `double` (late) | `0` |
| `checked` | `bool` (late) | `false` |
| `hasSubLote` | `bool` (late) | `false` |
| `isSublote` | `bool` (late) | `false` |
| `dividido` | `bool` (late) | `false` |

Serialização: `fromJson` ✔ · `toJson` ✔ · `toMap` = alias.
Nota: `checked`, `hasSubLote`, `isSublote` são omitidos no `fromJson` (usam defaults do construtor).

---

### 2.19 `pedido_completo_model.dart` → `PedidoCompleto`

| Campo | Tipo |
|-------|------|
| `pedido` | `PedidoVenda` |
| `usuario` | `String` |
| `estagio` | `Estagio` |

Serialização: `fromJson` ✔ · `toJson` ✔ · **sem `toMap`** (único model sem o alias).
Importa: `estagio_model.dart`, `pedido_venda.dart`.

---

### 2.20 `pedido_venda.dart` → `PedidoVenda`

| Campo | Tipo | Default |
|-------|------|---------|
| `empresaCod` | `int` (final) | `0` |
| `marcaCod` | `int` (final) | `0` |
| `pedido` | `int` (final) | `0` |
| `clienteCod` | `int` (final) | `0` |
| `clienteRazSoc` | `String` (final) | `''` |
| `tipo` | `String` (final) | `''` |
| `conferido` | `bool` (late) | `false` |
| `conferenciaIniciada` | `bool` | `false` |
| `aVista` | `bool` (final) | `false` |
| `dataHoraUltimoEstagio` | `DateTime` (late) | obrigatório |

Serialização: `fromJson` ✔ · `toJson` ✔ · `toMap` = alias.
Nota: `toJson` formata `dataHoraUltimoEstagio` com `"yyyy-MM-dd HH:mm"` (sem segundos); `DateTime.parse('')` lança exceção se campo ausente no JSON.

---

### 2.21 `pedidos_model.dart` → `PedidosModel` (DTO de saída)

| Campo | Tipo |
|-------|------|
| `pedidos` | `String` |
| `data` | `DateTime` |
| `cliente` | `String` |

Serialização: **sem `fromJson`** · `toMap` apenas (`Map<String,String>`, diverge do padrão `Map<String,dynamic>`).
Classificação: DTO de saída — usado para montar requisições, não para desserializar resposta.

---

### 2.22 `produto_model.dart` → `Produto`

| Campo | Tipo | Default |
|-------|------|---------|
| `codigo` | `String` | `''` |
| `nome` | `String` | `''` |
| `grupo` | `Grupo` | composição |
| `QtdTotalPesoLiqConferido` | `double` | `0` |
| `QtdTotalPesoBrConferido` | `double` | `0` |
| `QtdTotalSaldoFaltaConferir` | `double` | `0` |
| `conferencias` | `List<Conferencias>?` | `[]` |

Serialização: `fromJson` ✔ · `toJson` ✔ · `toMap` = alias.
Nota: campos de totais em `PascalCase` (padrão diverge do `camelCase` do restante do projeto).

---

### 2.23 `selecionar_material_estoque_model.dart` → `SelecionarMaterialEstoqueModel` (DTO de saída)

| Campo | Tipo |
|-------|------|
| `fornecedor` | `String` |
| `nf` | `String` |
| `data` | `String` |
| `pesosLiquido` | `String` |

Serialização: **sem `fromJson`** · `toMap` apenas.
Nota: `pesosLiquido` é `String` em vez de `double`; DTO de saída.

---

### 2.24 `tansf_mov_lote.dart` → `TansfMovLote`

| Campo | Tipo | Default |
|-------|------|---------|
| `codigoTransf` | `int` (final) | `0` |
| `codigoEmpr` | `int` (final) | `0` |
| `codigoMarc` | `int` (final) | `0` |
| `codigoGpx` | `int` (final) | `0` |
| `codigoProd` | `String` (final) | `''` |
| `notaFiscal` | `int` (final) | `0` |
| `codigoFornecedor` | `int` (final) | `0` |
| `serie` | `String` (final) | `''` |
| `lote` | `String` (final) | `''` |
| `pesoliquido` | `double` (final) | `0.0` |
| `pesoEmbalagem` | `double` (final) | `0.0` |

Serialização: `fromJson` ✔ · `toJson` ✔ · **sem `toMap`**.
Nota: nome do arquivo e da classe contêm erro tipográfico (`tansf` em vez de `transf`).

---

### 2.25 `transferenci_lote.dart` → `TransferenciLote`

| Campo | Tipo | Default |
|-------|------|---------|
| `codigo` | `int` | `0` |
| `codigoEmpr` | `int` | `0` |
| `codigoMarc` | `int` | `0` |
| `codigoGpx` | `int` | `0` |
| `codigoProd` | `int` | `0` |
| `quantidade` | `double` | `0` |
| `criadoEm` | `DateTime?` | `null` |
| `dataFinalizacao` | `DateTime?` | `null` |

Serialização: `fromJson` ✔ · `toJson` ✔ · `toMap` = alias.
**Bug documentado:** `codigoProd` declarado como `int`, mas `toJson` serializa o fallback como `''` (string vazia): `'codigoProd': codigoProd ?? ''`. Em Dart (null safety), `int ?? ''` não compila — indica que o campo pode ter sido `int?` originalmente ou o `toJson` foi copiado de outro model sem ajuste.
Nota: nome do arquivo com erro tipográfico (`transferenci` em vez de `transferencia`).

---

## 3. Padrão de Serialização (padrão do template — preservar)

O projeto adota **serialização manual** em todos os models. Este é o padrão a ser preservado em novos models.

### 3.1 Estrutura canônica

```dart
class NomeModel {
  TipoCampo campo;

  NomeModel({ required this.campo });

  /// Desserialização: JSON → objeto
  factory NomeModel.fromJson(Map<String, dynamic> json) {
    return NomeModel(
      campo: json['campo'] ?? valorDefault,
    );
  }

  /// Serialização: objeto → JSON
  Map<String, dynamic> toJson() {
    return {
      'campo': campo,
    };
  }

  /// Alias obrigatório pelo padrão do projeto
  Map<String, dynamic> toMap() {
    return toJson();
  }
}
```

### 3.2 Defaults por tipo

| Tipo Dart | Default padrão no `fromJson` |
|-----------|------------------------------|
| `int` | `json['campo'] ?? 0` |
| `double` | `json['campo'] ?? 0.0` |
| `String` | `json['campo'] ?? ''` |
| `bool` | `json['campo'] ?? false` |
| `DateTime` | `DateTime.parse(json['campo'])` |
| `List<T>` | `(json['campo'] as List<dynamic>).map((e) => T.fromJson(e)).toList()` |
| Composição | `T.fromJson(json['campo'])` |

### 3.3 `toMap` como alias

Todos os models — exceto `PedidoCompleto` e `TansfMovLote` — implementam `toMap()` como simples delegação a `toJson()`. Esse alias é parte do padrão do projeto e deve ser mantido.

### 3.4 DTOs de saída (sem `fromJson`)

Dois models funcionam exclusivamente como **DTOs de saída** (montam requisições, nunca desserializam respostas):

| Model | Método de saída |
|-------|----------------|
| `PedidosModel` | `toMap()` → `Map<String,String>` |
| `SelecionarMaterialEstoqueModel` | `toMap()` → `Map<String,dynamic>` |

---

## 4. Duplicações e Nomenclatura

### 4.1 Arquivos duplicados

| Par de duplicatas | Conteúdo | Ação |
|-------------------|----------|------|
| `conferencias_model.dart` ↔ `conferencias.dart` | Idêntico byte a byte | Manter `conferencias_model.dart` (✅); remover `conferencias.dart` (🔴) |
| `fornecedor_model.dart` ↔ `fornecedorModel.dart` | Idêntico byte a byte | Manter `fornecedor_model.dart` (✅); remover `fornecedorModel.dart` (🔴) |

**Impacto:** `conferencias_model.dart` é importado por `produto_model.dart`. `fornecedor_model.dart` é importado por `nf_model.dart`, `itens_nf_model.dart` e `nf_pagas_model.dart`. As versões canônicas já estão sendo usadas; os duplicados são órfãos.

### 4.2 Nomenclatura de arquivo fora do padrão

| Arquivo | Problema |
|---------|----------|
| `fornecedorModel.dart` | camelCase no nome do arquivo; padrão do projeto é `snake_case` |
| `tansf_mov_lote.dart` | Erro tipográfico (`tansf` → deveria ser `transf`) |
| `transferenci_lote.dart` | Erro tipográfico (`transferenci` → deveria ser `transferencia`) |

### 4.3 Nomes de classe que divergem do nome do arquivo

| Arquivo | Classe esperada (pelo nome do arquivo) | Classe real |
|---------|----------------------------------------|-------------|
| `estagio_model.dart` | `EstagioModel` | `Estagio` |
| `grupo_model.dart` | `GrupoModel` | `Grupo` |
| `fornecedor_model.dart` / `fornecedorModel.dart` | `FornecedorModel` | `Fornecedor` |
| `item_model.dart` | `ItemModel` | `Item` |
| `itens_nf_model.dart` | `ItensNfModel` | `ItenNotaFiscal` |
| `pedido_completo_model.dart` | `PedidoCompletoModel` | `PedidoCompleto` |
| `pedido_venda.dart` | `PedidoVenda` (sem sufixo `Model`) | `PedidoVenda` ✔ |
| `tansf_mov_lote.dart` | `TansfMovLoteModel` | `TansfMovLote` |
| `transferenci_lote.dart` | `TransferenciLoteModel` | `TransferenciLote` |
| `nota_compra_lotes_etiquetas.dart` | `NotaCompraLotesEtiquetasModel` | `NotaCompraLotesEtiquetas` |

---

## 5. Bugs Documentados (fatos — sem correção)

| Model | Bug |
|-------|-----|
| `NfPagasModel` | `checked: json['checked'] ?? 0` — default `int 0` para campo `bool` |
| `NfPagasModel` | `toJson` serializa `data` como objeto `NfModel` (falta `.toJson()`) |
| `LogOperacoesModel` | `data: json['data'] ?? DateTime.parse('2025-01-22')` — `DateTime` atribuído a campo `String` |
| `NfLotesModel` | `_parseDouble` remove `.` indistintamente: `"1.5"` → `15.0` |
| `NfLotesModel` | `toJson` omite `notaFiscal` e `lote` |
| `Item` | `_parseDouble` idêntico ao de `NfLotesModel`: `"1.5"` → `15.0` |
| `ConsultarNfSaidaModel` | `import 'package:pluto_grid/pluto_grid.dart'` — UI dentro de model de dados |
| `TransferenciLote` | `'codigoProd': codigoProd ?? ''` — `int ?? String` inconsistente |

---

## 6. Contagem Final

| Categoria | Quantidade |
|-----------|-----------|
| Total de arquivos em `lib/src/models/` | **26** |
| Models legítimos (`✅ Reutilizar`) | **24** |
| Duplicatas a descartar (`🔴 Descartar`) | **2** |
| Models sem `fromJson` (DTOs de saída) | **2** |
| Models sem `toMap` | **2** |
| Bugs documentados | **8** |
| Pares de duplicatas | **2** |
| Arquivos com erro tipográfico no nome | **2** |
| Classes com nome divergindo do arquivo | **9** |
