# Gerenciamento de Estado — GetX Reactivo

> **Escopo T2 — Infraestrutura técnica apenas. Regras de negócio excluídas.**
> Projeto analisado: `controle_separacao_aplicativo` · Pacote: `get: 4.7.2` (versão resolvida no lock; declarada como `^4.6.6`)

---

## 1. Visão Geral

O projeto usa exclusivamente o **modelo reativo do GetX** para gerenciamento de estado. Cada feature possui um `GetxController` que expõe variáveis observáveis (`Rx`/`.obs`) consumidas nas views por `Obx()`. Não há uso de `StatefulWidget` para estado global — apenas para estado local de formulário (ex.: `TextEditingController`, `FocusNode`).

---

## 2. Como Funciona Hoje

### 2.1 Tipos Rx Utilizados

| Tipo Rx | Exemplos reais no projeto |
|---|---|
| `RxBool` | `RxBool isLoading = false.obs;` (LoginController) |
| `RxString` | `RxString lote = ''.obs;` (ConferirMaterialEntradaController) |
| `RxDouble` | `RxDouble totalPesoBr = 0.0.obs;` (ConferirMaterialEntradaController) |
| `RxInt` | `RxInt totalEmb = 0.obs;` (ConferirMaterialSaidaController) |
| `RxList<T>` | `RxList<NfModel> nfs = <NfModel>[].obs;` (NfsPedidosController) |
| `RxMap<K,V>` | `RxMap<String, dynamic> itemCache = <String, dynamic>{}.obs;` (NfsPedidosController) |
| `Rx<T>` (objeto complexo) | `Rx<Item> item = Item(...).obs;` (ConferirMaterialEntradaController) |
| `Rx<File?>` | `Rx<File?> _image = Rx<File?>(null);` (ConferirMaterialEntradaController) |

### 2.2 Padrão de Inicialização — Valores Mágicos

Objetos complexos (`Rx<T>`) são inicializados com objetos "dummy" preenchidos com valores sentinela, evitando `null` mas introduzindo valores mágicos:

```dart
// ConferirMaterialSaidaController
Rx<PedidoVenda> pedidosVendas = PedidoVenda(
  clienteCod: 0,
  clienteRazSoc: '',
  dataHoraUltimoEstagio: DateTime.parse("2025-01-31T17:48:56.445Z"), // ← data hardcoded
  empresaCod: 0,
  marcaCod: 0,
  pedido: 0,
  tipo: '',
  conferido: false,
  aVista: false,
).obs;

// ItensNfEntradaController
Rx<NfModel> objNf = NfModel(
  empresaCod: 0,
  marcaCod: 0,
  numero: 0,
  dhEmissao: DateTime.parse('2011-01-30'), // ← data sentinela hardcoded
  ...
).obs;
```

### 2.3 Atualização de Estado

Dois padrões coexistem para forçar notificação nos ouvintes:

```dart
// Padrão A — substituição de valor (primitivos e listas)
pedidos.value = pedidosVendas;

// Padrão B — refresh manual (objetos mutados internamente sem troca de referência)
item.refresh();          // ConferirMaterialEntradaController.submitForm
itensProdutos.refresh(); // ItensNfEntradaController.carregarCacher
NotaCompraLotes.refresh(); // ConferirMaterialSaidaController.SelecionarTudo
```

Ambos são corretos, mas a escolha entre eles não é consistente — alguns controladores usam `.value =` quando poderiam usar `.refresh()` e vice-versa.

### 2.4 Ciclo de Vida — `onInit`, `onReady`, `onClose`

Todos os controllers implementam os três ganchos, porém `onInit` e `onReady` raramente fazem algo além de chamar `super`:

```dart
// SettingsAppController — onInit com lógica real (exceção)
@override
void onInit() async {
  super.onInit();
  getUrl.value = (await repository.getBaseUrl())!;  // carrega URL salva
  logger.value = (await repository.getLogger())!;   // carrega flag de log
}
```

A maioria dos controllers carrega dados nas **views** (em `build` ou por callback do usuário), não em `onInit`, o que é uma escolha válida mas inconsistente.

### 2.5 Fechamento de Streams — `onClose`

Todos os controllers fecham explicitamente cada variável `Rx` em `onClose`. O padrão é completo, mas verboso:

```dart
// NfsPedidosController.onClose — 6 streams fechados manualmente
@override
void onClose() {
  super.onClose();
  nfs.close();
  nfsItens.close();
  NotaCompraLotes.close();
  pedidos.close();
  clunmPedido.close();
  itemCache.close();
}
```

> **Nota técnica:** No GetX 4.x, variáveis `.obs` gerenciadas por `GetxController` são automaticamente fechadas pelo framework quando o controller é removido do registro. O fechamento manual é redundante mas inofensivo.

### 2.6 Consumo nas Views — `Obx`

O padrão dominante é o widget `Obx(() => ...)` diretamente nas views:

```dart
// NfsPedidos — Obx envolvendo ListView
Obx(() {
  return RefreshIndicator(
    onRefresh: () async { await controller.getNF(); },
    child: controller.nfsItens.value.isEmpty
        ? Text('Nenhum registro encontrado')
        : ListView.builder(
            itemCount: controller.nfsItens.value.length,
            itemBuilder: (context, index) { ... },
          ),
  );
})
```

Não há uso de `GetX<T>` widget nem de `GetBuilder` — apenas `Obx`. O `Get.find()` é o mecanismo de acesso ao controller nas views.

### 2.7 Uso de `StatefulWidget` para Estado Local

Algumas telas usam `StatefulWidget` para estado estritamente local (controllers de texto, focus nodes), separando bem estado local de estado reativo compartilhado:

```dart
// ConferirMaterialEntrada — StatefulWidget com estado local
class _ConferirMaterialEntradaState extends State<ConferirMaterialEntrada> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _loteCorridaController = TextEditingController();
  // ... + Get.find() para o controller de negócio
}
```

---

## 3. Inventário e Classificação

| Item | Classificação | Justificativa |
|---|---|---|
| `GetxController` como classe base | 🟢 Reutilizar com melhorias | Funciona bem; no template moderno considerar `StateNotifier` (Riverpod) ou `Cubit` (Bloc) para maior testabilidade |
| Variáveis `Rx`/`.obs` (primitivos) | ✅ Reutilizar sem alterações | Limpas, idiomáticas, sem problemas |
| `RxList<T>` e `RxMap<K,V>` | 🟢 Reutilizar com melhorias | Funcionam; o padrão `.refresh()` manual pode ser evitado com imutabilidade |
| `Rx<T>` com objeto complexo | 🟡 Refatorar | Inicialização com valores mágicos/sentinela é frágil; substituir por `Rx<T?>` com null tratado ou por estado separado por campo |
| Datas hardcoded como sentinela | 🟠 Substituir | `DateTime.parse("2025-01-31T17:48:56.445Z")` e `'2011-01-30'` são dívidas; usar `Rx<T?>` nullable |
| `onClose` com `.close()` manual | 🟡 Refatorar | Redundante no GetX 4.x; manter apenas `super.onClose()` no template, reduzindo boilerplate |
| `onInit`/`onReady` vazios | 🟡 Refatorar | Remover overrides vazios; usar apenas quando há lógica real |
| `Obx()` nas views | ✅ Reutilizar sem alterações | Granular, eficiente, sem rebuild desnecessário |
| `Get.find()` nas views | 🟡 Refatorar | Acoplamento implícito; no template moderno preferir injeção via construtor ou `ref.watch` (Riverpod) |
| Carregamento de dados no `build` | 🟠 Substituir | `controller.getNF()` e `controller.getPedidos()` chamados dentro de `build()` em NfsPedidos causam re-fetch em cada rebuild; mover para `onInit`/`initState` |

---

## 4. Pontos Fortes (Manter)

- **Granularidade dos Obx**: cada widget reativo é individual, evitando rebuilds em cascata.
- **Separação de estado local vs. reativo**: uso correto de `StatefulWidget` para `TextEditingController` e `FocusNode`.
- **Interfaces nas abstractions**: todos os controllers têm interface (`*ControllerInterface`), permitindo mocking em testes.
- **Uso de `try/catch/finally`** nos controllers (com `finally` sempre fechando o loading).

---

## 5. Problemas e Dívidas

1. **Chamada de dados dentro de `build()`**: `NfsPedidos.build()` chama `controller.getNF()` e `controller.getPedidos()` diretamente, causando re-fetch a cada rebuild da árvore.
2. **Valores mágicos de inicialização**: `DateTime.parse("2025-01-31T17:48:56.445Z")` como placeholder é uma dívida de legibilidade e potencial bug se alguma lógica comparar essa data.
3. **`onInit` assíncrono sem await**: `BuscarProdutosController.onInit()` é declarado `async` mas não faz `await` de nada — é um padrão que pode gerar falsos positivos em análise estática.
4. **`.close()` redundante em onClose**: ~80 linhas de boilerplate desnecessário espalhadas pelos controllers.
5. **Mistura de `.value =` e `.refresh()`** sem critério claro documentado.

---

## 6. Direção para o Template

### Manter GetX (direção atual — preservar)

A direção atual do template é **manter `GetxController` + `Rx`/`.obs` + `Obx`**. As melhorias internas a aplicar **sem trocar a biblioteca** são:
- Usar `Rx<T?>` em vez de objetos dummy com valores sentinela.
- Carregar dados em `onInit` (não no `build`).
- Remover `onClose` com `.close()` manual (redundante no GetX 4.x).
- Adotar `lazyPut` / `Bindings` em vez de `Get.put` eager.

Ver [documentation-stance](../00-overview/documentation-stance.md) para a postura editorial.

> ⚠️ **Consideração futura (NÃO aplicar agora).** A direção atual é preservar a stack (ver [documentation-stance](../00-overview/documentation-stance.md)). O conteúdo abaixo é apenas conhecimento técnico para decisão futura.

Para um projeto novo com equipe maior e vida útil longa (>3 anos), uma alternativa futura seria:
- **`flutter_riverpod`** (`StateNotifierProvider` ou `AsyncNotifierProvider`): estado assíncrono tipado, `AsyncValue<T>` para loading/error/data sem flags manuais, testabilidade nativa com `ProviderContainer`.
- **`get_it` + `injectable`**: DI explícita e lazy, sem singleton global via `Get`.
- **`go_router`**: navegação declarativa com guards nativos.

Para a equipe atual já familiarizada com GetX, refatorar os pontos críticos do GetX preservado é suficiente e não exige aprendizado de nova biblioteca.
