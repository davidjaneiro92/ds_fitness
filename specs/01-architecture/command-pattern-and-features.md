# Command Pattern e Inventário de Features

> **Classificação:** Command Pattern e estrutura de features — Reutilizar (padrão atual a preservar)
>
> **Escopo:** leitura e documentação fiel ao código em `lib/src/core/features/`. Nenhuma alteração de código foi realizada; nenhuma troca de stack é proposta.

---

## Parte 1 — Command Pattern

### 1.1 As duas interfaces de comando

O projeto define **duas interfaces abstratas separadas** para o padrão Command, cada uma residindo no diretório `abstracts/` de sua respectiva feature:

#### `CommandInterface`

```
lib/src/core/features/conferir_material_saida/abstracts/command_interface.dart
```

```dart
abstract class CommandInterface {
  Future<void> execute();
}
```

#### `TransferenciaCommandInterface`

```
lib/src/core/features/conferir_material_transferencia/abstracts/transferencia_command_interface.dart
```

```dart
abstract class TransferenciaCommandInterface {
  Future<void> execute();
}
```

**Assinatura:** ambas declaram exatamente o mesmo método — `Future<void> execute()` — sem parâmetros. O tipo de retorno é `Future<void>` em ambas, o que garante que o controller pode fazer `await command.execute()` de forma uniforme.

**Por que existem DUAS interfaces?**
As duas interfaces são estruturalmente idênticas mas pertencem a contextos de domínio distintos (`saida` e `transferencia`). Cada feature cresceu de forma autônoma e gerou sua própria interface local, sem extrair uma interface compartilhada a nível de `core`. Essa dualidade é uma observação arquitetural factual: não há herança nem composição entre elas.

---

### 1.2 Os 8 commands concretos

#### Feature `conferir_material_saida` — 5 commands

---

##### 1. `ConfirmarConferenciaCommand`

**Arquivo:** `conferir_material_saida/controller/commands/confirmar_conferencia_command.dart`

**O que faz (técnico):** Envia via `repository.postNotaCompraLotesEtiqueta(notaCompraLotes)` a lista de lotes marcados pelo usuário. Exibe toast de sucesso ou erro via `CustomToast`.

**Dependências injetadas via `Get.find()`:**
- `UtilsServicesInterfaces`
- `LogServicesInterface`
- `HiveServicesInterface`
- `FormatarValoresInterface`

**Repositório instanciado com `new` (fora do GetX):**
```dart
ConferirMaterialSaidaRepositoryInterface repository =
    ConferirMaterialSaidaRepository();
```

**Parâmetro de construção:**
```dart
ConfirmarConferenciaCommand(this.notaCompraLotes);
// notaCompraLotes: List<NotaCompraLotesEtiquetas>
```

**Como o controller chama:**
```dart
var command = await ConfirmarConferenciaCommand(lotes);
await command.execute();
```

---

##### 2. `DividirLoteCommand`

**Arquivo:** `conferir_material_saida/controller/commands/dividir_lote_command.dart`

**O que faz (técnico):** Recebe um item de lote e verifica se `pedido == 0` (novo vínculo → `POST`) ou `pedido > 0` (atualização → `PUT`) via `repository`. Muda `pedido` e `tipoPedido` no objeto antes de enviar. Exibe toast de sucesso.

**Dependências injetadas via `Get.find()`:**
- `LogServicesInterface`
- `FormatarValoresInterface`

**Repositório instanciado com `new`:**
```dart
ConferirMaterialSaidaRepositoryInterface repository =
    ConferirMaterialSaidaRepository();
```

**Parâmetros de construção:**
```dart
DividirLoteCommand(this.itemNotaCompra, this.pedido, this.tipo);
// itemNotaCompra: NotaCompraLotesEtiquetas
// pedido: int
// tipo: String
```

**Como o controller chama:**
```dart
var command = DividirLoteCommand(
    notaCompraLote, itemPedido.value.pedido, pedidosVendas.value.tipo);
await command.execute();
```

---

##### 3. `GetNotaCompraLotesCommand`

**Arquivo:** `conferir_material_saida/controller/commands/get_nota_compra_lotes_command.dart`

**O que faz (técnico):** Limpa os acumuladores de peso, itera sobre `NfPagas` buscando lotes via `repository.getNotaCompraLotesEtiqueta(...)`, filtra lotes vinculados a outros pedidos ou com transferência ativa, restaura estado de seleção a partir de backup, e calcula `totalPesoBr`, `totalPesoLiq` e `totalSaldo`. Usa `LoadingController` para exibir/ocultar loading via `WidgetsBinding.instance.addPostFrameCallback`.

**Dependências injetadas via `Get.find()`:**
- `LogServicesInterface`
- `FormatarValoresInterface`

**Repositórios instanciados com `new`:**
```dart
ConferirMaterialSaidaRepositoryInterface repository =
    ConferirMaterialSaidaRepository();
final ItensPedidoSaidaRepositoryInterface repositoryItensPedidoSaida =
    ItensPedidoSaidaRepository();
```

**Parâmetros de construção:**
```dart
GetNotaCompraLotesCommand(
  this.totalPesoBr,   // RxDouble
  this.totalPesoLiq,  // RxDouble
  this.totalSaldo,    // RxDouble
  this.foifechadaModal, // RxBool
  this.itemPedido,    // Rx<ItensPedidoModel>
  this.NfPagas,       // RxList<NfPagasModel>
  this.NotaCompraLotes, // RxList<NotaCompraLotesEtiquetas>
  this.pedidosVendas, // Rx<PedidoVenda>
);
```

**Como o controller chama:**
```dart
var command = GetNotaCompraLotesCommand(
  totalPesoBr, totalPesoLiq, totalSaldo, foifechadaModal,
  itemPedido, NfPagas, NotaCompraLotes, pedidosVendas,
);
await command.execute();
```

---

##### 4. `ImprimirEtiqueta`

**Arquivo:** `conferir_material_saida/controller/commands/imprimir_etiqueta.dart`

**Observação:** o nome da classe não segue o sufixo `Command`, mas implementa `CommandInterface`.

**O que faz (técnico):** Calcula peso bruto e líquido residual do lote após divisão e chama `repository.postImprimirEtiqueta(...)` duas vezes — uma para a parte separada e outra para o resíduo — ambas com `qtdCopEdiqueta: 1`. Exibe toast de sucesso se ambas as chamadas retornarem `true`.

**Dependências injetadas via `Get.find()`:**
- `LogServicesInterface`

**Repositório instanciado com `new`:**
```dart
ConferirMaterialSaidaRepositoryInterface repository =
    ConferirMaterialSaidaRepository();
```

**Parâmetros de construção:**
```dart
ImprimirEtiqueta(this.loteNf, this.itemPedido, this.embalagem, this.pesoLiquido);
// loteNf: NotaCompraLotesEtiquetas
// itemPedido: ItensPedidoModel
// embalagem: double
// pesoLiquido: double
```

**Como o controller chama:**
```dart
var command = ImprimirEtiqueta(
  loteNf,
  itemPedido.value,
  double.parse(embalagem),
  double.parse(pesoLiquido),
);
await command.execute();
```

---

##### 5. `SomaPesoComman`

**Arquivo:** `conferir_material_saida/controller/commands/soma_peso_command.dart`

**Observação:** o nome da classe tem erro de digitação (`Comman` em vez de `Command`).

**O que faz (técnico):** Incrementa ou decrementa `totalPesoBr` e `totalPesoLiq` conforme o flag `checked` do lote recebido. Em seguida busca via `repository.getNotaCompraLotesEtiqueta(...)` os lotes já conferidos (filtro `somentePedidoFiltrado: true`) para somar sublotes e recalcular `totalSaldo`. Chama `.refresh()` nas três variáveis reativas ao final. Usa `LoadingController`.

**Dependências injetadas via `Get.find()`:**
- `FormatarValoresInterface`
- `LogServicesInterface`

**Repositório instanciado com `new`:**
```dart
final ItensPedidoSaidaRepositoryInterface repository =
    ItensPedidoSaidaRepository();
```

**Parâmetros de construção:**
```dart
SomaPesoComman(
  this.totalPesoBr,   // RxDouble
  this.totalPesoLiq,  // RxDouble
  this.totalSaldo,    // RxDouble
  this.nf,            // NotaCompraLotesEtiquetas
  this.checked,       // bool
  this.itemPedido,    // Rx<ItensPedidoModel>
  this.pedidosVendas, // Rx<PedidoVenda>
);
```

**Como o controller chama:**
```dart
var command = SomaPesoComman(
  totalPesoBr, totalPesoLiq, totalSaldo, nf, checked,
  itemPedido, pedidosVendas,
);
await command.execute();
```

---

#### Feature `conferir_material_transferencia` — 3 commands

---

##### 6. `ConfirmarConferenciaTrasferenciaCommand`

**Arquivo:** `conferir_material_transferencia/controller/commands/confirmar_conferencia_trasferencia_command.dart`

**Observação:** o nome da classe tem erro de digitação (`Trasferencia` em vez de `Transferencia`).

**O que faz (técnico):** Remove lotes divididos da lista (`removeWhere x.dividido == true`), chama `repository.postTraferenciaLotes(notaCompraLotes)`. Se `terminaConferencia == true`, monta um objeto `TransferenciLote` com data atual e chama `repository.putTraferenciaLotes(itens)` para finalizar a transferência. Exibe toast de sucesso ou erro.

**Dependências injetadas via `Get.find()`:**
- `UtilsServicesInterfaces`
- `LogServicesInterface`
- `HiveServicesInterface`
- `FormatarValoresInterface`

**Repositório instanciado com `new`:**
```dart
ConferirMaterialTransferenciaRepositoryInterface repository =
    ConferirMaterialTransferenciaRepository();
```

**Parâmetros de construção:**
```dart
ConfirmarConferenciaTrasferenciaCommand(
  this.notaCompraLotes,     // List<NotaCompraLotesEtiquetas>
  this.terminaConferencia,  // bool
);
```

**Como o controller chama:**
```dart
var command = await ConfirmarConferenciaTrasferenciaCommand(lotes, terminaConferencia);
await command.execute();
```

---

##### 7. `GetNotaCompraLotesTransferenciaCommand`

**Arquivo:** `conferir_material_transferencia/controller/commands/get_nota_compra_lotes_transferencia_command.dart`

**O que faz (técnico):** Análogo ao `GetNotaCompraLotesCommand` da saída, porém adaptado ao domínio de transferência: filtra por `transferencia` em vez de `pedido`, usa `repository.getTransferenciaNotaCompraLotesEtiqueta(...)` e calcula o saldo com base em `itemTransf.value.quantidade`. Usa `LoadingController` via `addPostFrameCallback`. Não usa `repositoryItensPedidoSaida` (a linha correspondente está comentada no código).

**Dependências injetadas via `Get.find()`:**
- `LogServicesInterface`
- `FormatarValoresInterface`

**Repositório instanciado com `new`:**
```dart
ConferirMaterialTransferenciaRepositoryInterface repository =
    ConferirMaterialTransferenciaRepository();
```

**Parâmetros de construção:**
```dart
GetNotaCompraLotesTransferenciaCommand(
  this.totalPesoBr,        // RxDouble
  this.totalPesoLiq,       // RxDouble
  this.totalSaldo,         // RxDouble
  this.foifechadaModal,    // RxBool
  this.NfPagas,            // RxList<NfPagasModel>
  this.itemBuscarProduto,  // Rx<BuscarProdutosModel>
  this.itemTransf,         // Rx<TransferenciLote>
  this.NotaCompraLotes,    // RxList<NotaCompraLotesEtiquetas>
);
```

**Como o controller chama:**
```dart
var command = GetNotaCompraLotesTransferenciaCommand(
  totalPesoBr, totalPesoLiq, totalSaldo, foifechadaModal,
  NfPagas, itemBuscarProduto, itemTransf, NotaCompraLotes,
);
await command.execute();
```

---

##### 8. `TransferenciaSomaPesoComman`

**Arquivo:** `conferir_material_transferencia/controller/commands/soma_peso_command.dart`

**Observação:** o nome da classe também usa `Comman` (mesmo padrão do homólogo em `saida`).

**O que faz (técnico):** Idêntico em lógica ao `SomaPesoComman` de saída, mas usa `repository.getTransferenciaNotaCompraLotesEtiqueta(...)` e referencia `itemTransf.value.quantidade` para o cálculo do saldo. Filtra sublotes por `lote.transferencia == nf.transferencia`. Usa `LoadingController`.

**Dependências injetadas via `Get.find()`:**
- `FormatarValoresInterface`
- `LogServicesInterface`

**Repositório instanciado com `new`:**
```dart
final ConferirMaterialTransferenciaRepositoryInterface repository =
    ConferirMaterialTransferenciaRepository();
```

**Parâmetros de construção:**
```dart
TransferenciaSomaPesoComman(
  this.totalPesoBr,       // RxDouble
  this.totalPesoLiq,      // RxDouble
  this.totalSaldo,        // RxDouble
  this.nf,                // NotaCompraLotesEtiquetas
  this.checked,           // bool
  this.itemBuscarProduto, // Rx<BuscarProdutosModel>
  this.itemTransf,        // Rx<TransferenciLote>
);
```

**Como o controller chama:**
```dart
var command = TransferenciaSomaPesoComman(
  totalPesoBr, totalPesoLiq, totalSaldo, nf, checked,
  itemBuscarProduto, itemTransf,
);
await command.execute();
```

---

### 1.3 Como os controllers orquestram os commands

Ambos os controllers (`ConferirMaterialSaidaController` e `ConferirMaterialTransferenciaController`) seguem o mesmo padrão de orquestração: cada método público do controller que executa uma ação significativa instancia o command correspondente, passa os dados de estado reativos como argumentos e aguarda `execute()`.

**Padrão observado em `ConferirMaterialSaidaController`:**

```dart
// conferir_material_saida_controller.dart

Future<void> postImprimirEtiqueta(NotaCompraLotesEtiquetas loteNf,
    String embalagem, String pesoLiquido) async {
  var command = ImprimirEtiqueta(
    loteNf, itemPedido.value,
    double.parse(embalagem), double.parse(pesoLiquido),
  );
  await command.execute();
  return Future.value();
}

Future<void> confirmarConferencia() async {
  // ... filtragem de lotes ...
  var command = await ConfirmarConferenciaCommand(lotes);
  await command.execute();
  Get.back();
}

Future<void> getNotaCompraLotes() async {
  var command = GetNotaCompraLotesCommand(
    totalPesoBr, totalPesoLiq, totalSaldo, foifechadaModal,
    itemPedido, NfPagas, NotaCompraLotes, pedidosVendas,
  );
  await command.execute();
}

void somaPeso(NotaCompraLotesEtiquetas nf, bool checked) async {
  var command = SomaPesoComman(
    totalPesoBr, totalPesoLiq, totalSaldo, nf, checked,
    itemPedido, pedidosVendas,
  );
  await command.execute();
}

Future<void> dividirLote(NotaCompraLotesEtiquetas notaCompraLote) async {
  var command = DividirLoteCommand(
      notaCompraLote, itemPedido.value.pedido, pedidosVendas.value.tipo);
  await command.execute();
  await getNotaCompraLotes(); // recarrega após dividir
}
```

O controller **não guarda referência** ao command após `execute()`. Commands são objetos de vida curta, criados por demanda e descartados.

---

### 1.4 Observação: instanciação de repositórios fora do GetX

Todos os 8 commands instanciam seus repositórios diretamente com `new` (construtor concreto), sem passar pela injeção de dependência do GetX:

```dart
// Padrão repetido em todos os commands:
ConferirMaterialSaidaRepositoryInterface repository =
    ConferirMaterialSaidaRepository();          // new implícito em Dart
```

Isso é uma observação factual sobre como o código está estruturado. O GetX é usado apenas para serviços transversais (`LogServicesInterface`, `FormatarValoresInterface`, etc.) via `Get.find()`.

---

## Parte 2 — Inventário de Features

### 2.1 Tabela geral

As 13 features em `lib/src/core/features/`:

| Feature | abstracts | controller | repository | view | commands |
|---|:---:|:---:|:---:|:---:|:---:|
| `buscar_produtos` | ✅ | ✅ | ✅ | ✅ | — |
| `conferir_material_entrada` | ✅ | ✅ | ✅ | ✅ | — |
| `conferir_material_saida` | ✅ | ✅ | ✅ | ✅ | ✅ (5) |
| `conferir_material_transferencia` | ✅ | ✅ | ✅ | ✅ | ✅ (3) |
| `consulta_nf_saida` | ✅ | ✅ | ✅ | ✅ (2) | — |
| `itens_nf_entrada` | ✅ | ✅ | ✅ | ✅ | — |
| `itens_pedido_saida` | ✅ | ✅ | ✅ | ✅ | — |
| `login` | ✅ | ✅ | ✅ | ✅ (2) | — |
| `nfs_pedidos` | ✅ | ✅ | ✅ | ✅ | — |
| `selecionar_material_estoque` | ✅ | ✅ | ✅ | ✅ | — |
| `settings_app` | ✅ | ✅ | ✅ | ✅ | — |
| `splash_screen` | — | — | — | ✅ (1 arquivo) | — |
| `trasferencia_industria` | ✅ | ✅ | ✅ | ✅ | — |

**Legenda:** ✅ = presente · — = ausente · (n) = quantidade de arquivos quando maior que 1

---

### 2.2 Aplicação seletiva do Command Pattern

O Command Pattern é aplicado **somente** nas duas features de conferência ativa de materiais:

- `conferir_material_saida` — 5 commands (operações sobre pedidos de venda)
- `conferir_material_transferencia` — 3 commands (operações sobre transferências entre unidades)

As outras 11 features **não usam commands**. A lógica de negócio nelas está diretamente nos métodos do controller, sem encapsulamento em objetos de command. Isso reflete uma aplicação seletiva do padrão: ele foi introduzido apenas nas features onde as operações do controller atingiram complexidade suficiente para justificar o encapsulamento em objeto separado.

---

### 2.3 `splash_screen` — widget sem controller e sem repository

**Arquivo:** `lib/src/core/features/splash_screen/splash_screen.dart`

A `splash_screen` é a única feature que consiste em um único arquivo de widget, sem nenhuma camada de abstração, controller ou repository. É um `StatefulWidget` simples:

- Em `initState()`, agenda um `Future.delayed(Duration(seconds: 2), ...)` que navega para `PagesRoutes.login.path` via `Get.offNamed(...)`.
- Em `build()`, renderiza um `Container` com gradiente azul, a logo do aplicativo (`assets/img/logo-ok-3.png`) dimensionada responsivamente, e um `CircularProgressIndicator` branco.

Não há estado mutável além do próprio widget Flutter. Não há chamada de API, persistência ou injeção de dependência. A feature é estritamente de apresentação e temporização.

---

### 2.4 `login` — duas views

A feature `login` possui duas views:

| Arquivo | Tipo | Função |
|---|---|---|
| `login/view/login.dart` | View principal | Tela de login do fluxo de entrada do app |
| `login/view/confirmar_acesso.dart` | Função utilitária (não é um Widget) | Dialog modal de acesso a Settings |

#### Detalhes técnicos de `confirmar_acesso.dart`

O arquivo **não define uma classe Widget**. Ele define uma função de nível superior `showAlertLogin(BuildContext context)` que exibe um `AlertDialog` via `showDialog(...)`. Esta é a segunda rota de acesso — acionada a partir da tela de Settings para reautenticar o usuário antes de permitir alterações de configuração.

**Estado global de arquivo:** as variáveis de estado e controllers são declaradas no escopo do arquivo (nível de arquivo), fora de qualquer classe:

```dart
// confirmar_acesso.dart — escopo de arquivo (variáveis globais de arquivo)
final _formkeyModal = GlobalKey<FormState>();
TextEditingController _usuarioModalController = TextEditingController();
TextEditingController _passwordModalController = TextEditingController();
final List<FocusNode> focusNodesModal = List.generate(2, (_) => FocusNode());
final LoginControllerInterface controller = Get.find();
final UtilsServicesInterfaces utilsServices = Get.find();
```

**`@override dispose()` fora de classe:** o arquivo declara `@override void dispose() { ... }` no escopo de arquivo — a anotação `@override` não tem efeito aqui, pois não há classe base sendo sobrescrita. Trata-se de uma função livre com nome `dispose`:

```dart
@override        // sem efeito: não há classe
void dispose() {
  for (var node in focusNodesModal) {
    node.dispose();
  }
}
```

**Título com erro de digitação:** o `AlertDialog` exibe o título `"Logn"` (faltando o `i`):

```dart
title: const Text("Logn"),
```

---

## Observações Arquiteturais

As seguintes observações são factuais, baseadas exclusivamente na leitura do código, e registradas sem proposta de mudança:

1. **Dualidade de interfaces (`CommandInterface` / `TransferenciaCommandInterface`):** as interfaces são estruturalmente idênticas. A duplicação resulta do crescimento independente das duas features. Não existe herança nem interface compartilhada no nível de `core`.

2. **Aplicação seletiva do Command Pattern:** 11 das 13 features não usam commands. O padrão foi adotado apenas onde o controller acumulou múltiplas operações assíncronas complexas com estado reativo compartilhado. Nas demais features, a lógica permanece diretamente nos métodos do controller GetX.

3. **Instanciação de repositórios nos commands:** cada command instancia seu próprio repositório concreto via construtor direto, não via GetX. Os serviços transversais (log, formatação, Hive, utils) são obtidos via `Get.find()`.

4. **Nomenclatura:** dois commands apresentam erro de digitação no nome da classe (`Comman` em vez de `Command`; `Trasferencia` em vez de `Transferencia`). O arquivo de `ImprimirEtiqueta` não usa o sufixo `Command` no nome da classe.

5. **`confirmar_acesso.dart` (login):** o arquivo usa estado global de arquivo em vez de estado encapsulado em classe. O `@override dispose()` no escopo de arquivo não sobrescreve nenhum método de ciclo de vida Flutter.
