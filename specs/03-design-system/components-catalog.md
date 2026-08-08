# Catálogo de Componentes — Design System Corporativo

> **Projeto legado de referência:** `controle_separacao_aplicativo`
> **Data de levantamento:** 2026-06-24
> **Stack preservada:** Flutter · GetX · oktoast · pluto_grid · Hive
> **Escopo:** `lib/src/components/` — widgets compartilhados reutilizáveis
> **Fora de escopo:** `custom_error_widget` (documentada por agente separado)

> ℹ️ **Nota de atualização (2026-07-13):** este documento descreve a engenharia reversa do app
> **legado**. Para o estado atual e vivo de `lib/src/components/` no template `direction_app1`
> (estrutura de pastas por categoria, componentes novos como `EmptyStateMessage`/`ClientListTile`/
> famílias de `TextField`), ver
> [components-catalog-direction-app1.md](./components-catalog-direction-app1.md).

---

## Tabela Mestre

| Componente | Arquivo(s) principal(is) | Finalidade resumida | Depende de | Acoplamento | Classificação |
|---|---|---|---|---|---|
| `customAalertQuestion` / `customAalertInformation` | `custom_alert.dart` | Diálogos de confirmação e informação via `showDialog` | Flutter Material | Baixo | ✅ Reutilizar |
| `CustomAppBar` | `custom_app_bar.dart` | AppBar padronizada com logo + título + back via GetX | GetX · asset `logo-ok-3.png` | Médio (logo hardcoded) | 🟢 c/ melhorias |
| `CustomDropdownButton` | `custom_dropwn_button.dart` | Dropdown estilizado recebendo `Map<String,String>` | Flutter Material | Baixo | ✅ Reutilizar |
| `CustomExpansion` | `custom_expansion.dart` | Árvore expansível com dados mockados fixos | Flutter Material | Alto (dados hardcoded) | 🔴 Descartar |
| `CustomListTile` | `custom_list_tile.dart` | Item de lista com ícone, título e trailing | Flutter Cupertino/Material | Baixo | ✅ Reutilizar |
| `customAlertMessage` | `custom_message.dart` | Alerta via `Get.dialog` sem `BuildContext` | GetX | Baixo | ✅ Reutilizar |
| `CustomToast` / `status` | `custom_toast.dart` | Toast com três status (success/warning/error) | oktoast | Baixo | ✅ Reutilizar |
| `CustomTextField` | `custom_text_field.dart` | Campo de texto completo com suporte a senha, foco, formatação | Flutter Material | Baixo | ✅ Reutilizar |
| `CustomPlutogridTable` | `custom_plutoGrid_Table.dart` | Protótipo/exemplo de tabela PlutoGrid com dados mockados | pluto_grid · GetX Rx | Alto (dados hardcoded) | 🟡 Refatorar |
| `CustomScaffoldView` + `CustomScaffoldController` | `custom_Scaffold/` | Scaffold-padrão com Drawer de menu, AppBar corporativa e PopupMenu de usuário | GetX · Hive · asset · rotas hardcoded | Alto (menu e rotas do negócio) | 🟡 Refatorar |
| `CustomListViewConteiner` + `CustomItemListView` + `CustomItemListViewController` + `ColumnModel` | `custom_list_view/` | **Sistema de lista configurável por colunas tipadas** (TEXT/DATA/NUMEROS/ICONBUTTON/CHECKBOX/COLOR) | GetX · Hive · `FormatarValores` | Médio | 🟢 c/ melhorias |
| `LoadingController` + `LoadingWidget` | `loading/` | **Overlay global de loading** registrado no `builder` do `MaterialApp` | GetX | Baixo | ✅ Reutilizar |

---

## Fichas Técnicas Individuais

---

### 1. `customAalertQuestion` / `customAalertInformation`

**Arquivo:** `lib/src/components/custom_alert.dart`

#### Finalidade
Duas funções de nível superior que exibem diálogos modais via `showDialog`. `customAalertQuestion` exibe confirmação Sim/Não; `customAalertInformation` exibe apenas um botão OK.

#### API pública

```dart
void customAalertQuestion({
  required BuildContext context,
  required String title,
  required String message,
  required Function onPressedYes,
  Function? onPressedNot,   // opcional; chamado ao pressionar "Não"
})

void customAalertInformation({
  required BuildContext context,
  required String title,
  required String message,
})
```

| Parâmetro | Tipo | Obrig. | Descrição |
|---|---|---|---|
| `context` | `BuildContext` | Sim | Contexto Flutter para `showDialog` |
| `title` | `String` | Sim | Título do diálogo (fonte 30, bold) |
| `message` | `String` | Sim | Corpo do diálogo (fonte 20, largura fixa 500) |
| `onPressedYes` | `Function` | Sim | Callback ao confirmar |
| `onPressedNot` | `Function?` | Não | Callback ao negar (default fecha apenas) |

#### Dependências
- `package:flutter/material.dart` (apenas)

#### Exemplo de uso real
```dart
// lib/src/core/features/conferir_material_saida/view/conferir_material_saida.dart:727
customAalertQuestion(
  context: context,
  title: 'Atenção!',
  message: 'Deseja realmente confirmar?',
  onPressedYes: () => controller.confirmar(),
);

// lib/src/pages/conferir_material_entrada/view/conferir_material_entrada.dart:276
customAalertInformation(
  context: context,
  title: 'Atenção',
  message: 'Os valores não batem. Verifique os valores digitados.',
);
```

#### Grau de acoplamento
**Baixo** — funções puras sem referência a regra de negócio. O texto das mensagens vem de fora.

#### Reutilizável no template?
Sim, sem alterações. Apenas corrigir o typo do nome (`Aalert` → `Alert`) em refatoração futura opcional.

#### Classificacao
✅ **Reutilizar** — genérico, zero dependências externas, alto uso no projeto (20+ chamadas).

---

### 2. `CustomAppBar`

**Arquivo:** `lib/src/components/custom_app_bar.dart`

#### Finalidade
`AppBar` padronizada com logo da empresa à esquerda, título centralizado e botão de voltar via `Get.back()`. Implementa `PreferredSizeWidget` para uso direto em `Scaffold.appBar`.

#### API pública

```dart
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    this.tela,    // String? — título exibido no centro
    this.golBack, // bool?  — parâmetro presente, mas ignorado no código atual
  });
}
```

| Parâmetro | Tipo | Obrig. | Descrição |
|---|---|---|---|
| `tela` | `String?` | Não | Rótulo da tela exibido ao centro |
| `golBack` | `bool?` | Não | Declarado, mas `automaticallyImplyLeading: false` está hardcoded |

**Tamanho:** `Size.fromHeight(kToolbarHeight)` (56 dp padrão).

#### Dependências
- `package:get/get.dart` (para `Get.back()`)
- Asset `assets/img/logo-ok-3.png` (altura 45)
- Cor hardcoded `Color(0xFF003A88)`

#### Exemplo de uso real
```dart
// lib/src/core/features/conferir_material_saida/view/conferir_material_saida.dart:234
appBar: const CustomAppBar(tela: 'Saida'),

// lib/src/core/features/buscar_produtos/view/buscar_produtos.dart:112
appBar: CustomAppBar(tela: 'Buscar Produto'),
```

#### Grau de acoplamento
**Médio** — a cor e o asset de logo são hardcoded para a empresa atual. O parâmetro `golBack` está declarado mas não funcional.

#### Reutilizável no template?
Sim, com duas melhorias:
1. Receber `Color? backgroundColor` (default `Color(0xFF003A88)`)
2. Receber `String? logoAsset` (default `'assets/img/logo-ok-3.png'`)

Mantém GetX para `Get.back()`.

#### Classificacao
🟢 **c/ melhorias** — excelente padrão de AppBar; apenas parametrizar logo e cor.

---

### 3. `CustomDropdownButton`

**Arquivo:** `lib/src/components/custom_dropwn_button.dart`

#### Finalidade
Dropdown estilizado com borda arredondada (radius 18) e altura fixa de 50 dp. Aceita itens via `Map<String, String>` onde a chave é o rótulo exibido e o valor é o dado retornado.

#### API pública

```dart
class CustomDropdownButton extends StatefulWidget {
  const CustomDropdownButton({
    Key? key,
    this.underline,        // Widget? — substitui underline padrão (default Container vazio)
    this.icon,             // Widget? — ícone do dropdown
    this.style,            // TextStyle? — estilo do item selecionado
    this.hintStyle,        // TextStyle? — estilo do hint
    this.dropdownColor,    // Color? — cor do painel aberto
    this.iconEnabledColor, // Color? — cor do ícone
    required this.items,         // Map<String, String> — {label: value}
    required this.labe,          // String — texto de hint/placeholder
    required this.selectedItem,  // String? — valor atualmente selecionado
    required this.onChanged,     // void Function(String?) — callback de mudança
  });
}
```

| Parâmetro | Tipo | Obrig. | Descrição |
|---|---|---|---|
| `items` | `Map<String, String>` | Sim | Mapa label→value dos itens |
| `labe` | `String` | Sim | Placeholder (typo de `label`) |
| `selectedItem` | `String?` | Sim | Valor selecionado atual |
| `onChanged` | `void Function(String?)` | Sim | Callback de seleção |
| Demais | vários opcionais | Não | Estilização passthrough |

#### Dependências
- `package:flutter/material.dart` (apenas)

#### Exemplo de uso real
```dart
// lib/src/core/features/buscar_produtos/view/buscar_produtos.dart:142
return CustomDropdownButton(
  items: controller.empresas,
  labe: 'Empresa',
  selectedItem: controller.empresaSelecionada.value,
  onChanged: (value) => controller.setEmpresa(value),
);
```

#### Grau de acoplamento
**Baixo** — completamente genérico, sem referência a domínio.

#### Reutilizável no template?
Sim, sem alterações. Corrigir typo `labe` → `label` em refatoração menor.

#### Classificacao
✅ **Reutilizar** — widget genérico, bem parametrizado, em uso em múltiplas telas.

---

### 4. `CustomExpansion`

**Arquivo:** `lib/src/components/custom_expansion.dart`

#### Finalidade
Componente de lista expansível em dois níveis (Pedido → Item → Produto) com dados estáticos de demonstração hardcoded. Contém duas funções livres auxiliares: `_buildCustomExpansionTile` e `_buildCustomListTile`.

#### API pública

```dart
class CustomExpansion extends StatelessWidget {
  const CustomExpansion({super.key});
  // Nenhum parâmetro externo
}
```

As funções privadas auxiliares (não exportadas):

```dart
Widget _buildCustomExpansionTile({
  required String title,
  required List<Widget> items,
})

Widget _buildCustomListTile(String text)
```

#### Dependências
- `package:flutter/material.dart` (apenas)

#### Exemplo de uso real
Nenhuma chamada encontrada fora do próprio arquivo. Componente não está em uso no projeto.

#### Grau de acoplamento
**Alto** — dados mockados em PT-BR (`Pedido 001`, `Item A`, `Produto 1`) embutidos no widget. Sem parâmetros de entrada, é impossível alimentar dados reais.

#### Reutilizável no template?
As funções auxiliares `_buildCustomExpansionTile` e `_buildCustomListTile` têm bom design visual (bordas, sombra, cores). Para o template, extrai-las como funções/widgets parametrizados vale a pena. O `CustomExpansion` como classe não serve.

#### Classificacao
🔴 **Descartar** — nunca foi usado em produção, dados 100% hardcoded. Extrair os helpers visuais se necessário.

---

### 5. `CustomListTile`

**Arquivo:** `lib/src/components/custom_list_tile.dart`

#### Finalidade
`ListTile` padronizada com ícone à esquerda, título e trailing (default: seta `CupertinoIcons.forward`). `onTap` está presente mas sem callback externo — disparado sem ação.

#### API pública

```dart
class CustomListTile extends StatelessWidget {
  const CustomListTile({
    Key? key,
    required this.title,    // String — texto principal
    required this.icon,     // IconData — ícone leading
    this.trailing,          // Widget? — widget trailing (default: seta cupertino)
  });
}
```

| Parâmetro | Tipo | Obrig. | Descrição |
|---|---|---|---|
| `title` | `String` | Sim | Texto do tile |
| `icon` | `IconData` | Sim | Ícone à esquerda |
| `trailing` | `Widget?` | Não | Widget à direita (default seta) |

**Limitação:** `onTap` está hardcoded como `() {}` — não é parametrizado externamente.

#### Dependências
- `package:flutter/material.dart`
- `package:flutter/cupertino.dart`

#### Exemplo de uso real
```dart
// lib/src/core/features/settings_app/view/settings_app_view.dart:87
return CustomListTile(
  title: item.titulo,
  icon: item.icone,
  trailing: Switch(value: item.valor, onChanged: (v) {}),
);
```

#### Grau de acoplamento
**Baixo** — genérico.

#### Reutilizável no template?
Sim, com melhoria essencial: adicionar parâmetro `VoidCallback? onTap`.

#### Classificacao
🟢 **c/ melhorias** — adicionar `onTap` como parâmetro obrigatório ou opcional.

---

### 6. `customAlertMessage`

**Arquivo:** `lib/src/components/custom_message.dart`

#### Finalidade
Função de nível superior que exibe um `AlertDialog` via `Get.dialog` sem necessitar de `BuildContext`. Verifica `Get.isDialogOpen` para evitar diálogos duplos.

#### API pública

```dart
void customAlertMessage({
  required String title,
  required String message,
})
```

| Parâmetro | Tipo | Obrig. | Descrição |
|---|---|---|---|
| `title` | `String` | Sim | Título do diálogo |
| `message` | `String` | Sim | Mensagem de corpo |

**Diferencial:** não precisa de `BuildContext` — pode ser chamado de controllers e repositories.

#### Dependências
- `package:get/get.dart`

#### Exemplo de uso real
```dart
// lib/src/core/services/http_manager.dart:75
customAlertMessage(
  title: "Atenção",
  message: "Sessão expirada, faça login novamente.",
);

// lib/src/core/features/conferir_material_saida/controller/conferir_material_saida_controller.dart:192
customAlertMessage(
  title: "Atenção",
  message: "Esse item selecionado não pode ter sua seleção removida.",
);
```

#### Grau de acoplamento
**Baixo** — função genérica, textos sempre externos.

#### Reutilizável no template?
Sim, sem alterações. É o padrão recomendado para alertas disparados de controllers/services (não precisa de contexto).

#### Classificacao
✅ **Reutilizar** — complementa `custom_alert.dart` (que precisa de contexto) cobrindo o cenário de controllers/repositories.

---

### 7. `CustomToast` + `status`

**Arquivo:** `lib/src/components/custom_toast.dart`

#### Finalidade
Classe que encapsula `showToast` da biblioteca `oktoast` com três status semânticos: `success` (verde), `warner` (âmbar) e `error` (vermelho). Inclui a classe abstrata `status` com constantes.

#### API pública

```dart
class CustomToast {
  void showToasts({
    required String messagem, // Mensagem a exibir
    required dynamic status,  // 'success' | 'warner' | 'error'
  })
}

abstract class status {
  static const String success = 'success';
  static const String warner  = 'warner';
  static const String error   = 'error';
}
```

| Parâmetro | Tipo | Obrig. | Descrição |
|---|---|---|---|
| `messagem` | `String` | Sim | Texto do toast (typo de `mensagem`) |
| `status` | `dynamic` | Sim | Constante de `status.*` |

**Configurações fixas:** duração 5s, posição `bottom`, fontSize 16, radius 8, `dismissOtherToast: true`.

#### Dependências
- `package:oktoast/oktoast.dart` — requer `OKToast` como ancestral na árvore de widgets (já configurado no `main.dart` envolvendo o `GetMaterialApp`)

#### Exemplo de uso real
```dart
// lib/src/core/features/conferir_material_saida/controller/commands/confirmar_conferencia_command.dart:32
CustomToast().showToasts(messagem: 'Salvo com sucesso', status: status.success);

// lib/src/core/services/Hive_services.dart:23
CustomToast().showToasts(messagem: 'Erro ao salvar', status: status.error);
```

#### Grau de acoplamento
**Baixo** — completamente genérico.

#### Reutilizável no template?
Sim, sem alterações. O `OKToast` wrapper em `main.dart` já é o padrão correto.

#### Classificacao
✅ **Reutilizar** — padrão de feedback visual, altíssimo uso (50+ chamadas no projeto), consistente com a UX.

---

### 8. `CustomTextField`

**Arquivo:** `lib/src/components/custom_text_field.dart`

#### Finalidade
Campo de texto completo baseado em `TextFormField`. Suporta: modo senha com toggle de visibilidade, navegação de foco entre campos (`nextFocusNode`), formatadores, validação, `readOnly`, hint com ícone prefixado e borda arredondada.

#### API pública

```dart
class CustomTextField extends StatefulWidget {
  const CustomTextField({
    Key? key,
    this.icon,              // IconData? — ícone prefixo
    required this.label,    // String — label flutuante
    this.isSecret = false,  // bool — modo senha com toggle
    this.inputFormatters,   // List<TextInputFormatter>?
    this.initialValue,      // String?
    this.readOnly = false,  // bool
    this.validator,         // String? Function(String?)?
    this.controller,        // TextEditingController?
    this.focusNode,         // FocusNode?
    this.nextFocusNode,     // FocusNode? — ao submit, foca no próximo campo
    this.onSubmit,          // VoidCallback? — ao submit sem nextFocusNode
    this.keyboardType = TextInputType.text,
    this.enabled = true,    // bool?
    this.onTap,             // VoidCallback?
    this.onEditingComplete, // VoidCallback?
    this.onChanged,         // Function(String)?
    this.maxLength = 20,    // int
  });
}
```

| Parâmetro | Tipo | Obrig. | Default | Descrição |
|---|---|---|---|---|
| `label` | `String` | Sim | — | Label flutuante |
| `isSecret` | `bool` | Não | `false` | Modo senha + botão visibilidade |
| `maxLength` | `int` | Não | `20` | Limite de caracteres |
| `nextFocusNode` | `FocusNode?` | Não | `null` | Encadeia foco entre campos |
| `readOnly` | `bool` | Não | `false` | Somente leitura |
| `validator` | `String? Function(String?)?` | Não | `null` | Validação de formulário |

**Comportamento interno:** quando `isSecret == true`, gerencia `isObscure` localmente via `setState`. Quando `nextFocusNode != null`, `textInputAction` é `TextInputAction.next`; caso contrário, `done`.

#### Dependências
- `package:flutter/material.dart`
- `package:flutter/services.dart` (para `TextInputFormatter`)

#### Exemplo de uso real
```dart
// lib/src/core/features/login/view/login.dart:90
CustomTextField(
  label: 'Usuário',
  icon: Icons.person,
  controller: controller.usuarioController,
  focusNode: controller.usuarioFocus,
  nextFocusNode: controller.senhaFocus,
),
CustomTextField(
  label: 'Senha',
  icon: Icons.lock,
  isSecret: true,
  controller: controller.senhaController,
  focusNode: controller.senhaFocus,
  onSubmit: () => controller.login(),
),
```

#### Grau de acoplamento
**Baixo** — totalmente genérico, sem dependência de domínio.

#### Reutilizável no template?
Sim, sem alterações. Um dos widgets mais bem implementados do projeto. O comportamento de `nextFocusNode` encadeado é padrão de excelência para forms mobile.

#### Classificacao
✅ **Reutilizar** — componente de formulário completo, usado em 40+ locais no projeto.

---

### 9. `CustomPlutogridTable`

**Arquivo:** `lib/src/components/custom_plutoGrid_Table.dart`

#### Finalidade
Widget de demonstração/protótipo de uma tabela `PlutoGrid` com colunas de exemplo (genéricas: Id, Name, Age, Role, Joined, Salary) e um segundo conjunto de colunas de negócio (`columnsExemplo`: notaFiscal, serie, codProduto...) com dados mockados. Inclui paginação, filtro de coluna e locale PT-BR.

#### API pública

```dart
class CustomPlutogridTable extends StatelessWidget {
  CustomPlutogridTable({super.key});
  // Nenhum parâmetro externo — colunas e linhas hardcoded
}
```

O componente expõe internamente:
- `PlutoGridStateManager stateManager` (late, atribuído em `onLoaded`)
- `List<PlutoColumn> columns` — colunas genéricas de exemplo
- `RxList<PlutoColumn> columnsExemplo` — colunas de negócio (NF/produto)
- `List<PlutoRow> rows` — dados mockados
- Método comentado `getNotaCompraLotes(...)` mostrando intenção de uso real

#### Dependências
- `package:pluto_grid/pluto_grid.dart`
- `package:get/get_rx/...` (para `RxList` / `Obx`)

#### Exemplo de uso real
Nenhuma chamada encontrada fora do próprio arquivo. É um protótipo/template de referência, não usado em produção.

**Nota:** o comentário `toPlutoRow()` documenta o padrão de conversão Model → PlutoRow que deve ser aplicado nas models de negócio.

#### Grau de acoplamento
**Alto** — colunas `columnsExemplo` com nomes do domínio (notaFiscal, pesoLiquido, saldo). Dados hardcoded.

#### Reutilizável no template?
O valor está no padrão de configuração do `PlutoGrid` com locale PT-BR e paginação. Extrair como widget parametrizável:

```dart
class CustomPlutoGrid extends StatelessWidget {
  final List<PlutoColumn> columns;
  final List<PlutoRow> rows;
  final int pageSize;
  const CustomPlutoGrid({required this.columns, required this.rows, this.pageSize = 50});
}
```

#### Classificacao
🟡 **Refatorar** — o padrão de locale PT-BR e paginação é valioso; os dados hardcoded precisam ser removidos e as colunas precisam vir por parâmetro.

---

### 10. `CustomScaffoldView` + `CustomScaffoldController`

**Arquivos:**
- `lib/src/components/custom_Scaffold/view/custom_Scaffold_view.dart`
- `lib/src/components/custom_Scaffold/controller/custom_scaffold_controller.dart`
- `lib/src/components/custom_Scaffold/interfaces/custom_scaffold_controller_interface.dart`

#### Finalidade
Scaffold completo para telas principais (home-level) com: AppBar corporativa com logo, nome do usuário logado (lido do Hive) e avatar; Drawer de navegação lateral com menu fixo de módulos; PopupMenu com "Settings" e "Sign Out".

#### API pública — `CustomScaffoldView`

```dart
class CustomScaffoldView extends StatelessWidget {
  CustomScaffoldView({
    super.key,
    required this.body,                 // Widget — conteúdo principal
    this.floatingActionButton,          // Widget? — FAB
  });
}
```

| Parâmetro | Tipo | Obrig. | Descrição |
|---|---|---|---|
| `body` | `Widget` | Sim | Conteúdo da tela |
| `floatingActionButton` | `Widget?` | Não | Botão flutuante opcional |

#### API pública — `CustomScaffoldController`

```dart
class CustomScaffoldController extends GetxController
    implements CustomScaffoldControllerInterface {

  RxString usuario = ''.obs;      // Nome do usuário logado (reativo)

  void handleMenuAction(String item);   // Navega entre módulos
  void handleSignOut();                  // Sign-out (stub)
  void PopupMenuButton(String item, BuildContext context); // Settings/Sign Out
  Future<void> carregaUsuario();        // Lê nome do Hive cache 'Autenticacao'
}
```

#### Interface

```dart
abstract class CustomScaffoldControllerInterface {
  RxString usuario;
  void handleMenuAction(String item);
  void handleSignOut();
  void PopupMenuButton(String item, BuildContext context);
  Future<void> carregaUsuario();
}
```

#### Dependências
- `package:get/get.dart`
- `HiveServicesInterface` (via `Get.find()`)
- Rotas hardcoded: `PagesRoutes.nfsPedidos`, `PagesRoutes.Trasferencialote`, `PagesRoutes.ConsultaNfSaida`, `PagesRoutes.login`
- Menu hardcoded: `['Entrada/Saida', 'Consultar', 'Trasferencia']`
- Asset `assets/img/logo-ok-3.png`
- Cor `Color(0xFF003A88)`

#### Exemplo de uso real
```dart
// lib/src/core/features/nfs_pedidos/view/nfs_pedidos.dart:38
return CustomScaffoldView(
  body: /* conteúdo da tela de pedidos */,
);

// lib/src/core/features/trasferencia_industria/view/trasferencia_industria.dart:34
return CustomScaffoldView(
  body: /* conteúdo de transferência */,
);
```

#### Grau de acoplamento
**Alto** — itens do Drawer e rotas do PopupMenu são hardcoded com nomes de módulos do negócio (`Entrada/Saida`, `Trasferencia`, `PagesRoutes.*`). A leitura de usuário do Hive com chave `'Autenticacao'` também é específica do projeto.

#### Reutilizável no template?
Sim, com refatoração:
1. Receber `List<DrawerItem>` como parâmetro (item + ação)
2. Receber `String? logoAsset` e `Color? appBarColor`
3. Receber `String? cacheKeyUsuario` ou `RxString? usuario`
4. PopupMenu manter a estrutura, mas receber callbacks por parâmetro

#### Classificacao
🟡 **Refatorar** — estrutura sólida e padrão desejável para o template; o acoplamento está nos dados, não na arquitetura.

---

### 11. `CustomListViewConteiner` + `CustomItemListView` + `CustomItemListViewController` + `ColumnModel`

**Arquivos:**
- `lib/src/components/custom_list_view/view/custom_list_view_conteiner.dart`
- `lib/src/components/custom_list_view/view/custom_item_list_view.dart`
- `lib/src/components/custom_list_view/controller/custom_item_list_view_controller.dart`

> **Este e o sistema de loading global são os dois componentes de maior valor arquitetural do projeto.**

#### Finalidade
Sistema de lista de itens completamente configurável por declaração de colunas tipadas. Cada coluna é uma instância de `ColumnModel` que declara como aquele campo deve ser renderizado. O sistema resolve path aninhado (notação ponto: `"endereco.cidade"`), formata valores e gerencia estado de checkboxes.

#### Tipos de coluna suportados (`TypeEnum`)

| Tipo `typeWidget` | `typeText` aplicável | Renderiza |
|---|---|---|
| `"TEXT"` | `"TEXT"` | `Text` com tooltip e ellipsis |
| `"TEXT"` | `"DATA"` | Data formatada PT-BR via `FormatarValores.formatDateTime` |
| `"TEXT"` | `"NUMEROS"` | Número formatado PT-BR via `FormatarValores.formatvalueToBrasil` |
| `"ICONBUTTON"` | — | `IconButton` com `onPressed(item)` |
| `"CHECKBOX"` | — | `Checkbox` reativo com `Obx`; estado gerenciado pelo controller |
| `"COLOR"` | — | Não renderiza coluna; aplica cor de fundo ao card inteiro |

#### API pública — `CustomListViewConteiner`

```dart
class CustomListViewConteiner extends StatelessWidget {
  CustomListViewConteiner({
    super.key,
    required this.objectList,       // List<dynamic> — lista de objetos com .toMap()
    required this.clunm,            // List<ColumnModel> — definição das colunas
    this.onTapConteiner,            // Future<void> Function(dynamic)? — tap no item
  });
}
```

| Parâmetro | Tipo | Obrig. | Descrição |
|---|---|---|---|
| `objectList` | `List<dynamic>` | Sim | Lista de objetos que implementam `.toMap()` |
| `clunm` | `List<ColumnModel>` | Sim | Definição declarativa das colunas |
| `onTapConteiner` | `Future<void> Function(dynamic)?` | Não | Ação ao tocar no card |

**Estado vazio:** exibe `'Nenhum registro encontrado'` com altura 70% da tela.

#### API pública — `ColumnModel`

```dart
class ColumnModel {
  String name;         // Nome do campo no Map (suporta "a.b.c")
  String typeWidget;   // "TEXT" | "ICONBUTTON" | "CHECKBOX" | "COLOR"
  String? typeText;    // "TEXT" | "DATA" | "NUMEROS" (apenas para typeWidget=="TEXT")
  double? textFontSize;              // Tamanho da fonte (default: 10)
  IconData? icon;                    // Ícone (para ICONBUTTON)
  Color? color;                      // Cor de fundo (para COLOR)
  Future<void> Function(dynamic)? onPressed;  // Callback (para ICONBUTTON)
  Function(dynamic)? onChanged;               // Callback (para CHECKBOX, uso futuro)

  ColumnModel({
    required this.name,
    required this.typeWidget,
    this.typeText,
    this.onPressed,
    this.textFontSize,
    this.icon,
    this.color,
    this.onChanged,
  });
}
```

#### API pública — `CustomItemListViewController`

```dart
class CustomItemListViewController extends GetxController {
  var obj = [].obs;   // Lista de itens com checkbox marcado

  void setObj(checkboxStates, item, count);       // Registra estado checkbox
  String TextValues(columns, item, int i);        // Resolve e formata valor de coluna TEXT
  dynamic mapPontos(columns, int i, item);        // Resolve notação ponto em Map aninhado
  double tratarValor(String valor);               // Converte string numérica para double
}
```

#### Dependências
- `package:get/get.dart` (GetxController, Obx, RxMap)
- `HiveServicesInterface` (via `Get.find()`)
- `FormatarValoresInterface` / `FormatarValores` (formatação BR)
- Objetos na lista devem implementar `.toMap()` retornando `Map<String, dynamic>`

#### Exemplo de uso real

```dart
// lib/src/core/features/nfs_pedidos/view/nfs_pedidos.dart
// (controller define as colunas em RxList<ColumnModel>)
Obx(() => RefreshIndicator(
  onRefresh: () => controller.getPedidos(),
  child: CustomListViewConteiner(
    clunm: controller.clunmPedido.value,
    objectList: controller.pedidos.value,
    onTapConteiner: (pedido) => controller.onTapConteinerPedido(pedido),
  ),
))

// Exemplo de definição de colunas no controller:
RxList<ColumnModel> clunmPedido = <ColumnModel>[
  ColumnModel(name: 'numeroPedido', typeWidget: 'TEXT', typeText: 'TEXT'),
  ColumnModel(name: 'dataEmissao',  typeWidget: 'TEXT', typeText: 'DATA'),
  ColumnModel(name: 'valorTotal',   typeWidget: 'TEXT', typeText: 'NUMEROS'),
  ColumnModel(
    name: 'status',
    typeWidget: 'COLOR',
    color: Colors.green[100],
  ),
  ColumnModel(
    name: 'acoes',
    typeWidget: 'ICONBUTTON',
    icon: Icons.edit,
    onPressed: (item) async => controller.editar(item),
  ),
].obs;
```

```dart
// lib/src/core/features/selecionar_material_estoque/view/selecionar_material_estoque.dart:128
CustomListViewConteiner(
  clunm: controller.columns.value,
  objectList: controller.materiais.value,
  onTapConteiner: (item) => controller.selecionarMaterial(item),
),
```

#### Resolucao de path aninhado

O método `mapPontos` resolve campos como `"endereco.cidade"` em Maps aninhados:

```dart
// name: 'cliente.nomeFantasia' → item['cliente']['nomeFantasia']
dynamic mapPontos(dynamic columns, int i, dynamic item) {
  List<String> partes = columns[i].name.split('.');
  dynamic resultado = item;
  for (String parte in partes) {
    if (resultado != null && resultado.containsKey(parte)) {
      resultado = resultado[parte];
    } else {
      return null;
    }
  }
  return resultado;
}
```

#### Grau de acoplamento
**Médio** — o componente em si é genérico. O acoplamento existe via:
- Dependência de `HiveServicesInterface` no controller (pode ser removida sem impacto funcional)
- Dependência de `FormatarValores` (específica da empresa, mas facilmente substituível)
- Objetos na lista precisam implementar `.toMap()`

#### Reutilizável no template?
**Altamente reutilizável com melhorias menores:**
1. Remover `HiveServicesInterface` do controller (não é usada internamente)
2. Injetar `FormatarValoresInterface` via construtor para desacoplamento de implementação
3. Aceitar `List<Map<String, dynamic>>` diretamente (além de `List<dynamic>` com `.toMap()`)
4. Adicionar `textFontSize` default mais legível (atual: 10 — muito pequeno)
5. Tornar `TypeEnum` a forma preferencial de tipagem (substituir strings literais)

#### Classificacao
🟢 **c/ melhorias** — **componente de maior valor do projeto**. O padrão de lista configurável por declaração de `ColumnModel` é uma abstração elegante e madura que elimina duplicação de código em todas as telas de listagem.

---

### 12. `LoadingController` + `LoadingWidget` — Overlay Global de Loading

**Arquivos:**
- `lib/src/components/loading/controller/loading_controller.dart`
- `lib/src/components/loading/view/loading.dart`

> **Segundo componente de maior valor arquitetural do projeto — padrão de overlay global.**

#### Finalidade
Sistema de loading global que exibe um overlay semitransparente escuro com `CircularProgressIndicator` sobre toda a aplicação. O `LoadingController` é registrado uma única vez no `main.dart`; qualquer camada da aplicação (repository, service, controller) pode ativá-lo via `Get.find()` sem precisar de `BuildContext`.

#### Arquitetura de integração

```
main.dart
  └── Get.put(LoadingController())       ← registro global, uma única vez
  └── OKToast(
        child: GetMaterialApp(
          builder: (context, child) => Stack([
            child!,                       ← conteúdo da tela
            LoadingWidget(),              ← overlay sempre presente na árvore
          ])
        )
      )
```

O `LoadingWidget` fica sempre na árvore de widgets acima de todo conteúdo de tela. Como é um `Obx` reativo, só renderiza o overlay quando `isLoading == true`; caso contrário, retorna `SizedBox.shrink()` (custo zero).

#### API pública — `LoadingController`

```dart
class LoadingController extends GetxController {
  var isLoading = false.obs;   // Estado reativo do loading

  void showLoading();           // isLoading.value = true
  void hideLoading();           // isLoading.value = false
}
```

#### API pública — `LoadingWidget`

```dart
class LoadingWidget extends StatelessWidget {
  // Nenhum parâmetro — lê LoadingController via Get.find()
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Get.find<LoadingController>().isLoading.value
          ? Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: CircularProgressIndicator(color: CustomColors.blue),
              ),
            )
          : SizedBox.shrink();
    });
  }
}
```

**Cor do indicator:** `CustomColors.blue` = `Color(0xFF003A88)`.

#### Dependências
- `package:get/get.dart` (GetxController, Obx, Get.find)
- `custom_colos.dart` → `CustomColors.blue` (única dependência de projeto)

#### Padrão de uso nos repositories

```dart
// lib/src/core/features/conferir_material_saida/repository/conferir_material_saida_repository.dart:35
final loadingController = Get.find<LoadingController>();
WidgetsBinding.instance.addPostFrameCallback((_) {
  loadingController.showLoading();
});
try {
  final result = await _httpManager.restRequest(...);
  // processar resultado
} finally {
  loadingController.hideLoading();   // garantido mesmo em erro
}
```

O uso de `addPostFrameCallback` é necessário quando `showLoading` é chamado durante o build de um frame — evita o erro de "setState during build".

#### Grau de acoplamento
**Baixo** — apenas a cor `CustomColors.blue` é específica do projeto.

#### Reutilizável no template?
Sim, com melhoria mínima: parametrizar a cor do indicator:

```dart
class LoadingWidget extends StatelessWidget {
  final Color? indicatorColor;
  const LoadingWidget({this.indicatorColor});
  // usar: indicatorColor ?? Theme.of(context).colorScheme.primary
}
```

#### Classificacao
✅ **Reutilizar** — padrão arquitetural de excelência. O overlay global via `builder` do `MaterialApp` é a abordagem correta para loading que cobre toda a tela sem depender de contexto local. Usado em 30+ repositories/controllers.

---

## Referencia Cruzada — Componente vs Telas de Uso

| Componente | Qtd. de chamadas aprox. | Camadas que usam |
|---|---|---|
| `CustomToast` | 50+ | controllers, repositories, services |
| `CustomTextField` | 40+ | views |
| `customAalertInformation` | 20+ | views, controllers |
| `LoadingController` | 30+ | repositories, controllers |
| `CustomListViewConteiner` | 12+ | views |
| `CustomAppBar` | 14+ | views |
| `customAlertMessage` | 10+ | controllers, services, http_manager |
| `customAalertQuestion` | 8+ | views |
| `CustomDropdownButton` | 5+ | views |
| `CustomListTile` | 2 | views (settings) |
| `CustomScaffoldView` | 4 | views (home-level) |
| `CustomPlutogridTable` | 0 | — (protótipo não usado) |
| `CustomExpansion` | 0 | — (protótipo não usado) |

---

## Observacoes de Migração para o Template

### Convencoes de nomenclatura a corrigir
| Atual (legado) | Sugerido no template | Motivo |
|---|---|---|
| `customAalertQuestion` | `customAlertQuestion` | Typo (`Aalert`) |
| `labe` | `label` | Typo no `CustomDropdownButton` |
| `messagem` | `mensagem` | Typo no `CustomToast` |
| `clunm` | `columns` | Typo no `CustomListViewConteiner` |
| `golBack` | `showBackButton` | Nome sem significado claro |

### Dependencias externas a preservar
```yaml
# pubspec.yaml — preservar versões compatíveis
dependencies:
  get: ^4.x.x           # GetX — controller/routing/DI
  oktoast: ^3.x.x       # CustomToast
  pluto_grid: ^8.x.x    # CustomPlutogridTable (refatorado)
  hive_flutter: ^1.x.x  # CustomScaffoldController, CustomItemListViewController
```

### Padrao de inicializacao no main.dart

```dart
// Ordem obrigatória de Get.put para o template
Get.put(LoadingController());          // 1. Loading global — primeiro sempre
Get.put(CustomItemListViewController()); // 2. Controller da lista configurável
// ... demais controllers de negócio
```

```dart
// Builder obrigatório no GetMaterialApp
builder: (context, child) {
  return Stack(children: [child!, LoadingWidget()]);
},
```

```dart
// OKToast deve envolver o GetMaterialApp
OKToast(child: GetMaterialApp(...))
```
