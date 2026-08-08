# Shared Widgets — Catálogo de Componentes Compartilhados (T5)

> **Projeto legado analisado:** `controle_separacao_aplicativo`
> **Data da análise:** 2026-06-24
> **Escopo:** Infraestrutura técnica de UI — sem regras de negócio

> ℹ️ **Nota de consistência:** O catálogo **canônico** de componentes compartilhados é o [components-catalog.md](./components-catalog.md). Este documento (`shared-widgets.md`) é um inventário complementar de estrutura e arquivos. Em caso de divergência de classificação ou descrição entre os dois documentos, prevalecem as informações do `components-catalog.md`.

---

## 1. Visão Geral

O projeto concentra componentes reutilizáveis em `lib/src/components/`. A estrutura é:

```
lib/src/components/
├── custom_alert.dart
├── custom_app_bar.dart
├── custom_dropwn_button.dart      ← typo no nome (dropwn)
├── custom_expansion.dart
├── custom_list_tile.dart
├── custom_message.dart
├── custom_toast.dart
├── custom_error_widget.dart
├── custom_text_field.dart
├── custom_plutoGrid_Table.dart
├── custom_Scaffold/               ← pasta com MVC
│   ├── controller/custom_scaffold_controller.dart
│   ├── interfaces/custom_scaffold_controller_interface.dart
│   └── view/custom_Scaffold_view.dart
├── custom_list_view/              ← pasta com MVC
│   ├── controller/custom_item_list_view_controller.dart
│   ├── model/                     (implícito via ColumnModel em view)
│   └── view/
│       ├── custom_list_view_conteiner.dart
│       └── custom_item_list_view.dart
└── loading/                       ← pasta com MVC
    ├── controller/loading_controller.dart
    └── view/loading.dart
```

---

## 2. Catálogo Completo

### 2.1 Tabela de Classificação

| # | Widget/Componente | Arquivo(s) | Tipo | Reutilizável? | Acoplamento de Negócio | Qualidade | Classificação |
|---|---|---|---|---|---|---|---|
| 1 | `LoadingWidget` + `LoadingController` | `loading/view/loading.dart` + `loading/controller/` | Overlay global | ✅ Sim | Nenhum | Boa | 🟢 Reutilizável |
| 2 | `CustomTextField` | `custom_text_field.dart` | Formulário | ✅ Sim | Nenhum | Boa | 🟢 Reutilizável |
| 3 | `CustomToast` + `status` | `custom_toast.dart` | Feedback | ✅ Sim | Nenhum | Boa | 🟢 Reutilizável |
| 4 | `CustomErrorWidget` | `custom_error_widget.dart` | Erro global | ✅ Sim | Nenhum | Média | 🟡 Reutilizável c/ ajustes |
| 5 | `CustomDropdownButton` | `custom_dropwn_button.dart` | Formulário | ✅ Sim | Nenhum | Média | 🟡 Reutilizável c/ ajustes |
| 6 | `customAalertQuestion` / `customAalertInformation` | `custom_alert.dart` | Diálogo | ✅ Sim | Nenhum | Média | 🟡 Reutilizável c/ ajustes |
| 7 | `customAlertMessage` | `custom_message.dart` | Diálogo simples | ✅ Sim | Nenhum | Média | 🟡 Reutilizável c/ ajustes |
| 8 | `CustomListTile` | `custom_list_tile.dart` | Lista | ✅ Sim | Nenhum | Baixa | 🟠 Esqueleto incompleto |
| 9 | `CustomListViewConteiner` + `CustomItemListView` | `custom_list_view/` | Lista genérica | ⚠️ Parcial | Leve (usa `toMap()`, `toPlutoRow()`) | Alta | 🟡 Reutilizável c/ ajustes |
| 10 | `CustomAppBar` | `custom_app_bar.dart` | AppBar | ⚠️ Parcial | Leve (logo hardcoded) | Média | 🟠 Acoplado ao app |
| 11 | `CustomScaffoldView` + `CustomScaffoldController` | `custom_Scaffold/` | Scaffold completo | ❌ Não | Alto (menu, rotas, auth) | Média | 🔴 Acoplado ao negócio |
| 12 | `CustomExpansion` | `custom_expansion.dart` | Accordion | ❌ Não | Total (dados de pedido hardcoded) | Baixa | 🔴 Protótipo/demo |
| 13 | `CustomPlutogridTable` | `custom_plutoGrid_Table.dart` | Tabela de dados | ⚠️ Parcial | Médio (colunas de NF hardcoded) | Média | 🟠 Wrapper c/ dados fixos |

---

## 3. Análise Detalhada por Componente

### 3.1 🟢 `LoadingWidget` + `LoadingController`
**Finalidade:** Overlay de loading global que bloqueia toda a tela enquanto operações assíncronas ocorrem.

**Como funciona:**
```dart
// main.dart — o overlay é montado na raiz do app via builder
builder: (context, child) {
  return Stack(
    children: [
      child!,
      LoadingWidget(), // sempre presente, mas só visível quando isLoading = true
    ],
  );
},
```
```dart
// LoadingController — GetX observable
class LoadingController extends GetxController {
  var isLoading = false.obs;
  void showLoading() => isLoading.value = true;
  void hideLoading() => isLoading.value = false;
}
```

**Pontos fortes:**
- Arquitetura correta: controller separado da view.
- Padrão de overlay via `Stack` na raiz é o correto para loading global.
- Zero acoplamento de negócio.

**Problemas:**
- Cor do `CircularProgressIndicator` referencia `CustomColors.blue` diretamente em vez de `Theme.of(context).colorScheme.primary`.
- `Colors.black.withOpacity(0.5)` hardcoded em vez de `ColorTokens.overlayDark`.

**Recomendação para o template:** Manter estrutura. Substituir cores hardcoded por tokens.

---

### 3.2 🟢 `CustomTextField`
**Finalidade:** Campo de texto padronizado com suporte a senha, validação, formatadores, foco encadeado e modo somente leitura.

**Assinatura:**
```dart
CustomTextField({
  IconData? icon,
  required String label,
  bool isSecret = false,
  List<TextInputFormatter>? inputFormatters,
  String? initialValue,
  bool readOnly = false,
  String? Function(String?)? validator,
  TextEditingController? controller,
  FocusNode? focusNode,
  FocusNode? nextFocusNode,   // encadeia foco automaticamente
  VoidCallback? onSubmit,
  TextInputType keyboardType = TextInputType.text,
  bool? enabled = true,
  VoidCallback? onTap,
  VoidCallback? onEditingComplete,
  Function(String)? onChanged,
  int maxLength = 20,
})
```

**Pontos fortes:**
- API rica e completa para formulários.
- Suporte nativo a `isSecret` com toggle de visibilidade.
- Encadeamento de foco (`nextFocusNode`) implementado corretamente.
- Sem dependências de negócio.

**Problemas:**
- `maxLength: 20` como padrão é baixo — pode truncar inputs legítimos.
- `BorderRadius.circular(18)` hardcoded; deveria usar `SpacingTokens.radiusLg`.
- `padding: EdgeInsets.only(bottom: 15)` hardcoded; deveria usar `SpacingTokens.sm + xs`.
- `focusNode!.unfocus()` com `!` pode lançar NPE se `focusNode` for null e `onSubmit` for chamado.

**Recomendação para o template:** Componente de alta qualidade — migrar para o template com substituição de tokens.

---

### 3.3 🟢 `CustomToast` + `status`
**Finalidade:** Exibe notificações toast no rodapé da tela com três estados semânticos.

```dart
// Uso
CustomToast().showToasts(messagem: 'Salvo!', status: status.success);
CustomToast().showToasts(messagem: 'Atenção!', status: status.warner);
CustomToast().showToasts(messagem: 'Erro!', status: status.error);
```

**Pontos fortes:**
- Enum de status com constantes nomeadas (`success`, `warner`, `error`).
- `dismissOtherToast: true` — evita empilhamento de toasts.
- Duração e posição configuradas.

**Problemas:**
- Depende da lib `oktoast` que deve estar envolvida no widget raiz (`OKToast` em `main.dart`) — acoplamento de inicialização.
- Cores de feedback (`Colors.green`, `Colors.amberAccent`, `Colors.red`) hardcoded em vez de `ColorTokens.success/warning/error`.
- Classe `status` não segue convenção Dart de `PascalCase` para classes.
- `showToasts` é método de instância quando deveria ser `static`.

**Recomendação para o template:** Manter padrão. Converter método para `static`, usar `ColorTokens`, renomear classe para `ToastStatus`.

---

### 3.4 🟡 `CustomErrorWidget`
**Finalidade:** Widget de fallback para erros não capturados de Flutter, registrado via `ErrorWidget.builder` no `main.dart`.

```dart
// main.dart
ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
  return CustomErrorWidget(
    errorMessage: kDebugMode
        ? errorDetails.summary.toString()
        : 'Ocorreu um erro inesperado. Por favor, entre em contato com o suporte.',
  );
};
```

**Pontos fortes:**
- Padrão correto de uso via `ErrorWidget.builder`.
- Diferenciação debug/release da mensagem exibida.
- Estrutura simples e sem estado.

**Problemas:**
- `Image.asset('assets/img/erro3.png', height: 700)` — imagem de 700px hardcoded; em telas menores vai causar overflow.
- Cor `Colors.blueAccent` hardcoded para o texto "ERROR".
- String `'ERROR'` não está em PT-BR.
- String `'Ocorreu um erro inesperado...'` hardcoded — sem i18n.
- `Color(0xFFFFFFFF)` hardcoded em vez de `Theme.of(context).colorScheme.surface`.

**Recomendação para o template:** Manter padrão. Tornar a imagem parametrizável (`errorImage`), usar `Theme.of(context)` para cores.

---

### 3.5 🟡 `CustomDropdownButton`
**Finalidade:** Dropdown estilizado com borda arredondada, aceitando `Map<String, String>` como fonte de dados.

```dart
CustomDropdownButton(
  items: {'Opção A': 'A', 'Opção B': 'B'},
  labe: 'Selecione',        // typo: deveria ser "label"
  selectedItem: _selected,
  onChanged: (val) => setState(() => _selected = val),
)
```

**Pontos fortes:**
- Encapsula `DropdownButton` com estilo de borda consistente com `CustomTextField`.
- `Map<String, String>` como API permite separar label de valor.

**Problemas:**
- Parâmetro `labe` tem typo (deveria ser `label`).
- `height: 50` hardcoded; deveria usar `SpacingTokens.inputHeight`.
- `BorderRadius.circular(18)` hardcoded.
- Cor `Colors.black45` hardcoded para borda.
- `Container` desnecessário como wrapper (poderia usar `DecoratedBox`).

**Recomendação para o template:** Manter conceito. Corrigir typo, usar tokens, considerar migração para `DropdownButtonFormField` para compatibilidade com `Form`.

---

### 3.6 🟡 `customAalertQuestion` / `customAalertInformation`
**Finalidade:** Diálogos padronizados de confirmação (Sim/Não) e informação (OK).

```dart
customAalertQuestion(
  context: context,
  title: 'Confirmar',
  message: 'Deseja excluir este item?',
  onPressedYes: () => controller.delete(),
);
```

**Pontos fortes:**
- Cobre dois casos de uso comuns (confirmação e informação).
- Assinatura limpa com callbacks.

**Problemas:**
- Nome com typo duplo: `customAalert` (dois "a") em vez de `customAlert`.
- `Function? onPressedNot = null` — uso de `null` explícito desnecessário; usar `Function? onPressedNot`.
- `Container(width: 500, child: Text(...))` — largura fixa de 500px pode quebrar em dispositivos menores.
- Estilos inline hardcoded (`fontSize: 30`, `fontSize: 20`).
- Strings "Sim", "Não", "Ok" hardcoded em PT.
- Duplicação com `custom_message.dart` (que define `customAlertMessage` via GetX).

**Recomendação para o template:** Unificar `custom_alert.dart` e `custom_message.dart` em um único `AppDialog` com enum de tipo. Corrigir typos.

---

### 3.7 🟡 `customAlertMessage`
**Finalidade:** Versão GetX-aware do alerta de informação, com proteção contra dupla abertura.

```dart
customAlertMessage(title: 'Atenção', message: 'Operação realizada!');
```

**Pontos fortes:**
- `if (Get.isDialogOpen == true) return;` — proteção contra múltiplos diálogos empilhados.
- Não requer `BuildContext` — usa `Get.dialog`.

**Problemas:**
- Duplica funcionalidade de `customAalertInformation` em `custom_alert.dart`.
- String "OK" hardcoded.
- Sem parâmetro de callback para ação ao fechar.

**Recomendação para o template:** Consolidar com `custom_alert.dart`.

---

### 3.8 🟠 `CustomListTile`
**Finalidade:** Wrapper de `ListTile` com ícone leading e trailing padrão.

```dart
CustomListTile(
  title: 'Item',
  icon: Icons.folder,
  trailing: Switch(value: true, onChanged: (_) {}),
)
```

**Pontos fortes:**
- Simples e sem dependências.

**Problemas:**
- `onTap: () {}` — callback hardcoded vazio! O tile não faz nada ao ser tocado.
- Sem `onTap` exposto como parâmetro — o componente é inutilizável para navegação.
- `CupertinoIcons.forward` como trailing padrão mistura guidelines iOS/Material.
- Basicamente um esqueleto sem funcionalidade real.

**Recomendação para o template:** Adicionar parâmetro `onTap`, remover `CupertinoIcons` em favor de `Icons.chevron_right`.

---

### 3.9 🟡 `CustomListViewConteiner` + `CustomItemListView`
**Finalidade:** Lista genérica e configurável por colunas — o componente mais sofisticado do projeto.

**Funcionamento:**
```dart
// Define as colunas dinamicamente
List<ColumnModel> columns = [
  ColumnModel(name: 'nomeCliente', typeWidget: 'TEXT', typeText: 'TEXT'),
  ColumnModel(name: 'dataPedido', typeWidget: 'TEXT', typeText: 'DATA'),
  ColumnModel(name: 'valor', typeWidget: 'TEXT', typeText: 'NUMEROS'),
  ColumnModel(name: 'aprovado', typeWidget: 'COLOR', color: Colors.green),
  ColumnModel(name: 'editar', typeWidget: 'ICONBUTTON', icon: Icons.edit,
    onPressed: (item) => controller.editar(item)),
  ColumnModel(name: 'selecionado', typeWidget: 'CHECKBOX'),
];

CustomListViewConteiner(
  objectList: controller.pedidos,
  clunm: columns,
  onTapConteiner: (item) async => controller.abrirDetalhe(item),
)
```

**`ColumnModel` — tipos suportados:**

| typeWidget | typeText | Comportamento |
|---|---|---|
| `TEXT` | `TEXT` | Texto simples |
| `TEXT` | `DATA` | Formata como data PT-BR |
| `TEXT` | `NUMEROS` | Formata como número BR |
| `ICONBUTTON` | — | Botão de ação |
| `CHECKBOX` | — | Checkbox reativo (GetX) |
| `COLOR` | — | Altera cor do container da linha |

**Pontos fortes:**
- Abordagem de "colunas configuráveis" é genuinamente reutilizável.
- Suporta acesso a propriedades aninhadas via notação de ponto (`'cliente.nome'`).
- Formatação de datas e números integrada via `FormatarValores`.
- Estado de checkbox gerenciado de forma reativa.
- Empty state com mensagem ("Nenhum registro encontrado").

**Problemas:**
- Parâmetro `clunm` com typo (deveria ser `columns`).
- `objectList` requer que os objetos implementem `.toMap()` — contrato implícito não documentado.
- `Get.put(CustomItemListViewController())` dentro do construtor do `StatefulWidget` — pode causar conflitos de instância em listas longas.
- `shrinkWrap: true` dentro de `Flexible` pode causar problemas de layout.
- `TypeEnum` define `WidgetText` e `TextText` com mesmo valor `'TEXT'` — duplicata.
- Código comentado extensivamente (busca inline removida mas não apagada).

**Recomendação para o template:** É o componente mais valioso. Migrar com refatoração: corrigir typos, documentar contrato `.toMap()`, converter `TypeEnum` para uso nos `ColumnModel`.

---

### 3.10 🟠 `CustomAppBar`
**Finalidade:** AppBar com logo da empresa e botão de voltar padronizado.

```dart
CustomAppBar(tela: 'Nome da Tela')
```

**Pontos fortes:**
- Implementa `PreferredSizeWidget` corretamente.
- Exibe logo + título centralizado.

**Problemas:**
- `Color(0xFF003A88)` hardcoded — não usa `Theme.of(context).colorScheme.primary`.
- `Image.asset('assets/img/logo-ok-3.png')` — logo hardcoded ao app legado, não ao template.
- Parâmetro `golBack` existe mas está comentado (`automaticallyImplyLeading: false`).
- Usa `Get.back()` — acoplado ao GetX para navegação.

**Recomendação para o template:** Tornar `logoAsset` e `onBack` parametrizáveis. Usar `Theme.of(context)` para cores.

---

### 3.11 🔴 `CustomScaffoldView` + `CustomScaffoldController`
**Finalidade:** Scaffold completo com AppBar, Drawer de navegação e menu de perfil.

**Problemas críticos de acoplamento:**
- Menu hardcoded: `['Entrada/Saida', 'Consultar', 'Trasferencia']`.
- Rotas hardcoded: `Get.offNamed(PagesRoutes.nfsPedidos.path)`, `PagesRoutes.Trasferencialote.path`, `PagesRoutes.ConsultaNfSaida.path`.
- Lê `Autenticacao` diretamente do Hive para exibir usuário logado.
- Strings `'Settings'`, `'Sign Out'` hardcoded em inglês misturado com PT.
- `_ProfileIcon` instancia `CustomScaffoldController()` diretamente (sem GetX) — instância duplicada.
- Logo hardcoded: `'assets/img/logo-ok-3.png'`.

**Recomendação para o template:** NÃO migrar diretamente. Criar um `AppScaffold` parametrizável com `List<DrawerItem>`, `logoAsset`, `userDisplayName`, `onSignOut` como parâmetros.

---

### 3.12 🔴 `CustomExpansion`
**Finalidade:** Demonstração de ExpansionTile aninhado.

**Problemas:**
- Dados hardcoded: `'Pedido 001'`, `'Item A'`, `'Produto 1'` etc. — é um protótipo/demo, não um componente real.
- `_buildCustomExpansionTile` e `_buildCustomListTile` são funções privadas no arquivo, não reutilizáveis.
- `ThemeData()` instanciado inline para remover `dividerColor` — antipadrão.

**Recomendação para o template:** Descartar o widget atual. Extrair `_buildCustomExpansionTile` como widget real parametrizável.

---

### 3.13 🟠 `CustomPlutogridTable`
**Finalidade:** Wrapper do PlutoGrid com localização PT-BR e paginação.

**Pontos fortes:**
- Localização do PlutoGrid já configurada em PT-BR (dias da semana, filtros, etc.) — trabalho valioso.
- Demonstra o padrão de uso de `PlutoAggregateColumnFooter` com `sum`.
- Template de `toPlutoRow()` comentado mostrando como converter model em linha.

**Problemas:**
- Colunas de exemplo hardcoded (Id, Name, Age, Role...) misturadas com colunas de negócio (notaFiscal, serie...).
- `Colors.red.withOpacity(0.1)` de debug não removido.
- `RxList<PlutoColumn>` público mas não usado de forma reativa no `build`.
- `late PlutoGridStateManager stateManager` não inicializado no construtor — pode causar LateInitializationError.

**Recomendação para o template:** Extrair apenas a configuração de localização PT-BR como utilitário (`PlutoGridLocaleText`). Tornar colunas e linhas parâmetros obrigatórios.

---

## 4. Ranking por Prioridade de Migração para o Template

| Prioridade | Widget | Esforço de Migração | Valor para o Template |
|---|---|---|---|
| 1 | `LoadingWidget` + `LoadingController` | Baixo | Alto — padrão global essencial |
| 2 | `CustomTextField` | Baixo | Alto — formulários são universais |
| 3 | `CustomToast` + `status` | Baixo | Alto — feedback de UX essencial |
| 4 | `CustomListViewConteiner` + `CustomItemListView` | Médio | Muito Alto — componente único e sofisticado |
| 5 | Alertas unificados (`custom_alert` + `custom_message`) | Médio | Alto — substituir duplicação por `AppDialog` |
| 6 | `CustomErrorWidget` | Baixo | Alto — segurança de produção |
| 7 | `CustomDropdownButton` | Baixo | Médio — correção de typo + tokens |
| 8 | PlutoGrid locale PT-BR | Baixo | Médio — reutilizável como constante |
| 9 | `CustomAppBar` | Médio | Médio — precisa parametrizar logo |
| 10 | `CustomListTile` | Baixo | Baixo — precisa de `onTap` |
| 11 | `CustomExpansion` | Alto (refazer) | Baixo atual |
| 12 | `CustomScaffoldView` | Alto (refazer) | Baixo atual — muito acoplado |
