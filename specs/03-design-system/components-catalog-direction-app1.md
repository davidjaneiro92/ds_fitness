# Catálogo de Componentes — Estado Atual (`direction_app1`)

> **Escopo:** `lib/src/components/` — estado real, implementado e em produção no template
> Flutter `direction_app1`, **não** o app legado `controle_separacao_aplicativo`.
> **Data:** 2026-07-13 (última atualização: 2026-07-18 — ver nota em §1)
> **Relação com o catálogo legado:** [components-catalog.md](./components-catalog.md) e
> [shared-widgets.md](./shared-widgets.md) documentam a engenharia reversa do app legado (fonte
> histórica que informou o design inicial do template). Este documento é o inventário **vivo** dos
> componentes que existem hoje em `direction_app1` — em caso de divergência sobre "o que existe
> agora", este documento prevalece; para "de onde veio a ideia", os catálogos do legado continuam
> a referência.

---

## 1. Contexto da atualização

Uma auditoria (motivada por um bug visual de contorno em inputs) encontrou `TextField` duplicado em
13 arquivos de tela, um widget de estado vazio/erro duplicado em 7 arquivos, e um card de cliente
quase-idêntico em 2 arquivos. `components/` também estava com boa parte dos arquivos soltos direto
na raiz, sem categorização. Este trabalho:

1. Reorganizou `components/` em pastas por categoria (ver
   [folder-structure.md §3](../01-architecture/folder-structure.md)).
2. Extraiu 6 componentes novos cobrindo as duplicações reais encontradas.
3. Substituiu as 22 implementações duplicadas pelos componentes correspondentes, preservando o
   comportamento visual exato de cada tela (cores/tamanhos são parâmetros, não valores forçados).

Nenhuma regra de negócio, estado, API ou navegação foi alterada nesse trabalho — só organização e
componentização.

> **Atualização (2026-07-18):** durante as correções da tela de Orçamento e do stepper de
> Cadastro de Cliente, mais uma duplicação foi encontrada e eliminada, no mesmo espírito da
> auditoria acima: duas classes privadas quase-idênticas `_Stepper` (uma em `orcamento_view.dart`,
> outra em `cadastro_cliente_view.dart`) foram substituídas por um único componente,
> `AppStepIndicator`, em uma nova categoria de pasta, `steppers/` (ver §2.4). Diferente da rodada
> original, essa mudança veio acompanhada de mudanças reais de comportamento de
> navegação/conclusão de etapa nos dois fluxos — não é só extração de UI — detalhadas em §2.4.

---

## 2. Componentes novos

### 2.1 `text_fields/` — 4 famílias de campo de texto

O app tem 4 estilos visuais de campo de texto realmente distintos (cores/fundo diferentes). Cada
um virou um componente próprio; ajustar cor/borda/radius de um estilo agora é uma mudança em um
único arquivo.

| Componente | Arquivo | Estilo | Usado em |
|---|---|---|---|
| `LoginTextField` | `text_fields/login_text_field.dart` | Fundo navy translúcido, borda focável azul | Tela de Login (usuário + senha) |
| `HeaderSearchTextField` | `text_fields/header_search_text_field.dart` | Branco 15% opacidade sobre `GradientHeader` navy | Busca no topo da tela Clientes |
| `SurfaceTextField` | `text_fields/surface_text_field.dart` | Branco (`surfLight`) + borda (`borderLight`) | Busca no topo da tela Pedidos |
| `GrayTextField` | `text_fields/gray_text_field.dart` | Fundo cinza claro (`ColorTokens.surf3Light`), sem borda — suporta ícone de busca, prefixo/sufixo de texto (ex. "R$", "%") e modo textarea multilinha | 8 campos no fluxo de Orçamento (sheets de desconto/filtro/item/responsável, steps de cliente/produtos/transportadora/observação) |

`text_fields/custom_text_field.dart` (o `CustomTextField` genérico, baseado em `TextFormField` com
suporte a senha/validação/foco encadeado) **não pertence a nenhuma das 4 famílias** — continua
existindo como está, usado só pelo modal de reautenticação (`confirmar_acesso.dart`), só realocado
de pasta.

### 2.2 `empty_states/empty_state_message.dart` — `EmptyStateMessage`

Unifica dois padrões de "ícone + título + subtítulo opcional" que existiam como widgets privados
duplicados (`_StatusMessage` em Home/Pedidos/Clientes/Agenda; `_Mensagem` no fluxo de Orçamento).

Parâmetros de estilo (`iconSize`, `iconColor`, `verticalPadding`, `titleTextAlign`, `mainAxisSize`,
`paddingOutsideCenter`, `requireNonEmptySubtitle`) existem porque as duas famílias tinham pequenas
diferenças reais entre si (tamanho de ícone, cor, alinhamento) — os defaults batem com o uso mais
comum (Home/Pedidos/Clientes).

### 2.3 `cards/client_list_tile.dart` — `ClientListTile`

Unifica o card de cliente (avatar de iniciais + nome + subtítulo + linha extra + trailing) usado na
tela de Clientes (`_ClientCard`, com sombra e localidade+tag inline) e no seletor de cliente do
Orçamento (`_ClienteTile`, sem sombra, com um badge de status em pill). A linha "extra" (o que cada
tela mostra abaixo do subtítulo — localidade+tag vs. um badge) é passada como slot de widget
(`extra:`), não fixada no componente, porque o conteúdo realmente difere entre as duas telas.

### 2.4 `steppers/app_step_indicator.dart` — `AppStepIndicator`

Unifica duas classes privadas quase-idênticas `_Stepper` que existiam em `orcamento_view.dart`
(fluxo de Orçamento) e `cadastro_cliente_view.dart` (fluxo de Cadastro de Cliente): mesma estrutura
visual (círculos numerados com check ao concluir, linha conectora), com uma pequena diferença real
de cor do dígito inativo entre as duas telas, unificada no componente.

| Componente | Arquivo | Estilo | Usado em |
|---|---|---|---|
| `AppStepIndicator` | `steppers/app_step_indicator.dart` | Círculos 28×28, preenchidos com `ColorTokens.navy800` quando ativos/concluídos, com borda `border2Light` quando pendentes; ícone `PhosphorIconsBold.check` quando concluído; linha conectora 2px em `navy800` (concluída) ou `border2Light` (pendente); número do dígito inativo em `ColorTokens.tx3Light` (cor unificada — antes o Orçamento usava `OrcamentoColors.textoApagado`) | Fluxo de Orçamento (`orcamento_view.dart`) e fluxo de Cadastro de Cliente (`cadastro_cliente_view.dart`) |

API: `total` (int, quantidade de etapas), `etapaAtual` (int, índice da etapa ativa), `concluidas`
(`Set<int>`, estado de conclusão fornecido por quem chama — o componente é só apresentação, **não**
deriva conclusão a partir do índice) e `onTapEtapa` (`ValueChanged<int>`, disparado com o índice
tocado).

**Mudança de comportamento — navegação sempre livre:** o `AppStepIndicator` chama `onTapEtapa` para
qualquer círculo tocado, em qualquer etapa, independentemente de ela já ter sido visitada. Antes,
nos dois fluxos, só era possível tocar em etapas já visitadas (`index <= etapaAtual`); agora a
navegação é livre em qualquer ordem (ex.: 1→4, 4→2, 2→1).

**Mudança de comportamento — conclusão passou a ser estado persistente, não derivado:** antes,
"concluída" era derivado de `index < etapaAtual` — voltar para a Etapa 1 apagava visualmente o check
das Etapas 2 e 3. Agora cada controller mantém seu próprio `RxSet<int> etapasConcluidas`
(`OrcamentoController` e `CadastroClienteController`), populado em `avancar()` somente quando a
validação da etapa passa; `irParaEtapa()` e `voltar()` nunca adicionam nem removem desse conjunto —
só `iniciar()`/reset o limpa.

---

## 3. Inalterados (só realocados de pasta)

Estes já existiam e continuam exatamente como estavam — nenhuma linha de lógica interna mudou,
só o caminho do arquivo/import:

| Componente | Pasta atual |
|---|---|
| `CustomAppBar` | `navbars/custom_app_bar.dart` |
| `AppBottomNavigation` | `navbars/app_bottom_navigation.dart` |
| `GradientHeader` | `headers/gradient_header.dart` |
| `CustomScaffoldView` + controller | `scaffolds/custom_scaffold/` |
| `CustomListTile`, `CustomListViewConteiner` + `CustomItemListView`, `CustomPlutoGridTable` | `lists/` |
| `customAlertQuestion`/`customAlertInformation`, `customAlertMessage` | `dialogs/` |
| `ClienteDetalheSheet` | `modals/cliente_detalhe_sheet.dart` |
| `AppBadge` | `badges/app_badge.dart` |
| `AppAvatar` | `avatars/app_avatar.dart` |
| `AppButton`, `AppIconButton` | `buttons/` |
| `CustomToast` | `toast/custom_toast.dart` |
| `CustomDropdownButton` | `dropdowns/custom_dropdown_button.dart` |
| `LoadingController` + `LoadingWidget` | `loading/` (sem mudança de pasta) |
| `CustomErrorWidget` | `empty_states/custom_error_widget.dart` |
| `AppDivider`, `Gap`, `AppProgressBar`, `SectionHeader` | `common/` (sem mudança de pasta) |

---

## 4. Fora de escopo (avaliado e descartado deliberadamente)

Ao investigar duplicação de widgets, alguns padrões repetidos foram encontrados mas **não**
extraídos nesta rodada, por não serem duplicação real (widgets de tela única, mesmo nome mas
estrutura diferente): `_OrderCard` (Home/Pedidos), `_CommissionCard`, `_EventoCard`, `_ItemCard`,
`_ProdutoMultiTile`, `_DescontoTile`, `_StatusTag` (a versão-widget em `etapa_cliente_view.dart`,
que renderiza um badge de pill — mantida como está, usada uma única vez). Extraí-los seria
refatoração não solicitada, sem ganho real de reuso hoje.
