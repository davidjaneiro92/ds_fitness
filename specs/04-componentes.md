# Componentes, Temas e Estilos

O visual do app é **escuro por definição**, com acento verde. Não existe tema claro, não existem fontes empacotadas nem pacote de ícones: ícones do Material e desenho próprio com `CustomPainter`. As únicas imagens são as de `assets/img/` (exercícios e grupos musculares). Tudo o que é cor, medida e tipografia sai de três arquivos de *tokens*, e nenhum widget declara valor solto (R6 em [07-engenharia.md](07-engenharia.md#regras-de-desenvolvimento)).

## Tokens

### Cores (`ColorTokens`)

| Token | Valor | Uso |
|---|---|---|
| `bgPrimary` | `#0D0D0D` | Fundo das telas |
| `bgSurface` | `#1A1A1A` | Cards, containers, sheets |
| `bgSurfaceAlt` | `#242424` | Inputs, chips inativos, botão *surface* |
| `accent` | `#4CE660` | Botão primário, destaques, progresso, visto de seleção |
| `accentDark` | `#2FA843` | Estado pressionado do acento |
| `accentSoft` | `#4CE660` a 10% | Fundo suave do acento (avatar, troféu, cartão *Adicionar exercício*) |
| `textPrimary` | `#FFFFFF` | Títulos e valores |
| `textSecondary` | `#9A9A9A` | Rótulos e subtítulos |
| `textOnAccent` | `#0D0D0D` | Texto sobre o verde |
| `textDisabled` | `#5C5C5C` | Desabilitado |
| `danger` | `#E64C4C` | Excluir, erro |
| `warning` | `#E6B24C` | Estrela de favorito e de dificuldade |
| `info` | `#4C9AE6` | Aviso informativo, ícone do Facebook |
| `muscle` | `#E64C4C` | Músculo em destaque nos desenhos |
| `bodyBase` | `#3D3D3D` | Silhueta do corpo (mais clara que os dois fundos de card) |
| `divider` | `#2E2E2E` | Bordas e separadores |
| `overlay`, `scrim` | preto a 80% / 60% | Camadas sobre conteúdo |
| `accentGradient`, `surfaceGradient` | listas de cor | Gradiente do acento e das superfícies elevadas |

### Espaçamento, raio e altura (`SpacingTokens`)

Grade base de **8 px**.

| Grupo | Tokens |
|---|---|
| Espaçamento | `xxs` 2 · `xs` 4 · `sm` 8 · `md` 16 · `lg` 24 · `xl` 32 · `xxl` 48 |
| Margem lateral das telas | `screenPadding` 16 |
| Raio | `radiusXs` 8 · `radiusSm` 10 · `radiusButton` 12 · `radiusCard` 16 · `radiusLg` 20 · `radiusPill` 100 |
| Altura fixa | `inputHeight` 52 · `buttonHeight` 52 · `buttonHeightSm` 40 · `navBarHeight` 56 · `bottomNavHeight` 68 |

Elevação: **nenhuma**. A separação entre superfícies vem do contraste de cor e da borda de `divider`, nunca de sombra.

### Tipografia (`TypographyTokens`)

| Estilo | Tamanho / peso | Papel |
|---|---|---|
| `display` | 44 / 800 | Números grandes (cronômetro de descanso, carga) |
| `displaySm` | 32 / 800 | Números de resumo |
| `pageTitle` | 28 / 800 | Título grande das telas do fluxo, abaixo da seta de voltar |
| `screenTitle` | 20 / 700 | Título da barra superior |
| `cardTitle` | 16 / 700 | Título de card e de seção |
| `fieldLabel` | 14 / 500 | Rótulo acima de um campo de formulário |
| `bodyStrong` | 14 / 600 | Corpo em destaque |
| `body` | 14 / 400 | Corpo |
| `bodyMuted` | 13 / 400, cinza | Texto de apoio |
| `label` | 12 / 600, cinza | Rótulo |
| `caption` | 11 / 600, cinza | Legenda |
| `button` | 15 / 700, sobre o acento | Texto de botão |

A fonte é a padrão da plataforma (Roboto no Android e na web); não há fonte empacotada nem baixada.

## Tema (`AppTheme.dark`)

Material 3, brilho escuro, e os componentes nativos (app bar, sheet, diálogo, snackbar, campo de texto, slider, indicador de progresso) já configurados com os tokens. O `main()` usa **só** esse tema (`themeMode: dark`) e limita o tamanho do texto do sistema entre **0,85× e 1,15×**, para o layout não quebrar com a fonte ampliada. A barra de status é transparente com ícones claros.

O app não declara `flutter_localizations`: os textos nativos do Material (por exemplo o seletor de data) seguem o idioma padrão do framework, e só os textos do app estão em pt-BR ([08-auditoria.md](08-auditoria.md#pendências-conhecidas)).

## Estrutura de tela

Toda tela de negócio usa o `AppScaffold`:

```
AppScaffold
 ├─ navbar      AppNavbar (opcional)         altura 56: seta de voltar, título centralizado e ação
 ├─ body        conteúdo, com 16 px de margem lateral (as telas do fluxo começam com um PageHeader)
 ├─ footer      área fixa acima da barra (opcional), p.ex. o botão principal
 └─ bottomNav   AppBottomNav (opcional)      altura 68, quatro abas
```

Sem `footer` o botão rola junto com o conteúdo; com ele, fica fixo no rodapé. As abas só aparecem nas telas listadas em [06-fluxos.md](06-fluxos.md#mapa-de-rotas).

## Widgets reutilizáveis (`lib/src/components/`)

### Estrutura e navegação

| Componente | Arquivo | Descrição | Observações |
|---|---|---|---|
| `AppScaffold` | [app_scaffold.dart](../lib/src/components/scaffolds/app_scaffold.dart) | Fundo, área segura, navbar, rodapé e barra inferior. | — |
| `AppNavbar` / `NavbarAction` | [app_navbar.dart](../lib/src/components/navbars/app_navbar.dart) | Topo: voltar, título e subtítulo, ação à direita. `showBack: false` esconde a seta (abas). | O *Perfil* usa `showBack: false`; `onBack` troca o comportamento do voltar (telas que pedem confirmação). |
| `AppBottomNav` | [app_bottom_nav.dart](../lib/src/components/navbars/app_bottom_nav.dart) | Quatro abas (Início, Treinos, Evolução, Perfil); trocar de aba zera a pilha (`Get.offAllNamed`). | Biblioteca e histórico não são abas: o *Perfil* e a *Evolução* ficam acesos nelas. |
| `PageHeader` | [page_header.dart](../lib/src/components/common/page_header.dart) | Título grande (`pageTitle`) com subtítulo opcional e uma ação à direita. | Abre as telas do fluxo e as abas. |
| `Gap` | [gap.dart](../lib/src/components/common/gap.dart) | Espaço vertical (`Gap(8)`) ou horizontal (`Gap.horizontal(8)`). | — |
| `SectionHeader` | [section_header.dart](../lib/src/components/common/section_header.dart) | Título de seção com ação à direita; junto vem o `AppProgressBar` (barra fina de 0 a 1). | — |

### Ação e entrada

| Componente | Arquivo | Descrição | Observações |
|---|---|---|---|
| `AppButton` | [app_button.dart](../lib/src/components/buttons/app_button.dart) | Variantes `primary` (verde), `outline`, `ghost`, `danger` e `surface`; tamanhos `small` e `medium`; `icon`, `loading`, `expanded`. | Sem `onPressed` (ou com `loading`) fica desabilitado. |
| `AppSocialButton` | [app_social_button.dart](../lib/src/components/buttons/app_social_button.dart) | Botão quadrado só com o ícone da marca (Google, Apple, Facebook), com rótulo para leitor de tela. | Na tela de login; por enquanto avisa que o recurso vem em breve. |
| `AppTextField` | [app_text_field.dart](../lib/src/components/inputs/app_text_field.dart) | Rótulo acima (opcional), sem borda em repouso, borda verde em foco, vermelha em erro; `isPassword` já traz o mostrar/ocultar; `prefixIcon`, `maxLines`, `maxLength` (mostra o contador `0/200`). | Texto centralizado na altura de 52 px. |
| `AppDropdownField<T>` | [app_dropdown_field.dart](../lib/src/components/inputs/app_dropdown_field.dart) | Lista suspensa no mesmo estilo e altura do campo de texto. | — |
| `AppSearchField` | [app_search_field.dart](../lib/src/components/inputs/app_search_field.dart) | Campo de busca com lupa e botão de limpar. | A comparação é feita pelo chamador com `TextoUtils.contem` (sem caixa nem acento). |
| `StepperField` | [stepper_field.dart](../lib/src/components/inputs/stepper_field.dart) | `[−] valor [+]` com `min`, `max`, `step`, ícone e sufixo. | Séries, repetições e descanso; a carga da execução usa o modal próprio. |
| `AppChip` / `AppChipBar` | [app_chip.dart](../lib/src/components/chips/app_chip.dart) | Pílula selecionável (filtros) ou informativa; `dense` para a versão compacta. | — |
| `DiaSemanaChips` | [dia_semana_chips.dart](../lib/src/components/chips/dia_semana_chips.dart) | Sete botões Seg–Dom em uma linha, um selecionado; `null` deixa todos apagados. | O leitor de tela lê o nome inteiro ("Quarta"), não a abreviação. |

### Conteúdo

| Componente | Arquivo | Descrição | Observações |
|---|---|---|---|
| `AppCard` | [app_card.dart](../lib/src/components/cards/app_card.dart) | Superfície padrão; `highlighted` põe a borda verde (treino do dia); aceita toque e pressão longa. | — |
| `TreinoCard` | [treino_card.dart](../lib/src/components/cards/treino_card.dart) | Linha de treino: nome, grupos, "N exercícios" e o dia da semana. | Usado na lista de treinos. |
| `ExerciseCard` | [exercise_card.dart](../lib/src/components/cards/exercise_card.dart) | Linha de exercício: miniatura, nome, grupos e ação. | Usado na biblioteca. |
| `ExercicioSelecaoTile` | [exercicio_selecao_tile.dart](../lib/src/components/cards/exercicio_selecao_tile.dart) | Linha da escolha de exercício: miniatura, nome, grupos e marca de seleção (um por vez). | Exercício que já está no treino fica travado, com o aviso *No treino*. |
| `ExercicioResumoTile` | [exercicio_resumo_tile.dart](../lib/src/components/cards/exercicio_resumo_tile.dart) | Exercício já configurado, na revisão: miniatura, nome, "4 séries • 12 reps • 90 s" e o menu ⋮ (Editar, Remover). | Tocar no cartão também edita. |
| `GrupoMuscularTile` | [grupo_muscular_tile.dart](../lib/src/components/cards/grupo_muscular_tile.dart) | Quadro de um grupo na escolha de grupos: imagem do músculo e nome. Selecionado: borda verde, imagem em cores e um visto no canto. | — |
| `AppAddCard` | [app_add_card.dart](../lib/src/components/cards/app_add_card.dart) | Cartão de borda tracejada verde com um `+` (*Adicionar exercício*). | Borda desenhada com `CustomPaint`. |
| `StatBox` | [stat_box.dart](../lib/src/components/cards/stat_box.dart) | Valor grande em verde com rótulo; `compact` para a versão menor. | — |
| `EmptyState` | [empty_state.dart](../lib/src/components/empty_states/empty_state.dart) | Ícone, título, mensagem e uma ação opcional. | Os três estados de toda lista — carregando, vazio, com dados — são obrigatórios. |
| `AppLineChart` / `ChartPoint` | [app_line_chart.dart](../lib/src/components/charts/app_line_chart.dart) | Gráfico de linha desenhado à mão: linha suave, área em gradiente, pontos e rótulos. | — |
| `SerieStepper` | [serie_stepper.dart](../lib/src/components/steppers/serie_stepper.dart) | Indicadores de série: concluída (verde com check), atual (borda verde), futura (cinza). | Execução. |
| `CircularTimer` | [circular_timer.dart](../lib/src/components/timers/circular_timer.dart) | Anel de contagem regressiva com `mm:ss` no centro, animado. | Descanso. |
| `GrupoMuscularImagem` | [grupo_muscular_imagem.dart](../lib/src/components/anatomy/grupo_muscular_imagem.dart) | Imagem do grupo muscular (corpo com o músculo em verde). `destacado: false` a deixa em tons de cinza. | `todos` não tem imagem: mostra só um ícone. Entra com `cacheWidth` (os PNGs passam de 1000 px). |
| `MuscleChip` / `MuscleChipsRow` | [muscle_chip.dart](../lib/src/components/anatomy/muscle_chip.dart) | Chips dos grupos de um exercício: a imagem do músculo e o nome. | Detalhe do exercício e execução. |
| `ExerciseIllustration` | [exercise_illustration.dart](../lib/src/components/media/exercise_illustration.dart) | O GIF (telas cheias) ou a miniatura parada (listas) do exercício — ver abaixo. | — |
| `AssetFirstFrame` | [asset_first_frame.dart](../lib/src/components/media/asset_first_frame.dart) | O primeiro quadro de uma imagem animada dos assets, decodificado uma vez e guardado em memória. | Base da miniatura nas listas. |

### Sobreposições e retorno

| Componente | Arquivo | Descrição | Observações |
|---|---|---|---|
| `AppModalSheet` / `showAppModalSheet<T>` | [app_modal_sheet.dart](../lib/src/components/modals/app_modal_sheet.dart) | Bottom sheet com alça, título, botão de fechar e conteúdo rolável, até 85% da altura; sobe com o teclado. | *Dados do treino*, *Meus dados*, *Objetivos*, *Medidas corporais*. |
| `showAppConfirmDialog` | [app_confirm_dialog.dart](../lib/src/components/feedback/app_confirm_dialog.dart) | Pergunta com *Cancelar* e *Confirmar* (`danger` deixa o confirmar vermelho). Devolve `bool`; tocar fora conta como `false`. | Excluir, descartar, abandonar, remover, sair. |
| `showAlterarCargaModal`, `showObservacoesModal`, `showEvolucaoCargaModal` | [modals/](../lib/src/components/modals/) | Os três modais da execução. | — |
| `AppSnackbar` | [app_snackbar.dart](../lib/src/components/feedback/app_snackbar.dart) | `success`, `erro` e `info`: flutuante, 2,5 s, ícone colorido. | Depois do `Get.back()`, nunca antes (R9). |
| `ConfettiBurst` | [confetti_burst.dart](../lib/src/components/feedback/confetti_burst.dart) | Confete da celebração e do resumo do treino. | — |

## A ilustração do exercício

`ExerciseIllustration` mostra o movimento do exercício, a partir da chave `imagem` (ex.: `pectorals/barbell-bench-press`). Tem dois modos:

| Modo | Onde | Arquivo | Tamanho |
|---|---|---|---|
| Compacto (`compact: true`) | Listas: seleção, revisão, biblioteca | `imagens_estaticas/<chave>.thumb.webp`, só o **primeiro quadro** (`AssetFirstFrame`) | 48 ou 56 px, cortada para preencher |
| Cheio | Configurar exercício (240 px), detalhe e execução (220) | `gifs/<chave>.gif`, animado | Largura total, inteira (sem cortar) |

- **Cartão branco.** Os GIFs e as miniaturas têm fundo branco; soltos sobre o tema escuro ficariam como um retângulo estranho. A imagem entra num cartão branco de cantos arredondados (`Colors.white` é uma das exceções declaradas de R6).
- **Substituto.** Sem chave (exercício criado pelo usuário), enquanto a miniatura decodifica ou se o arquivo não existir, aparece a ilustração genérica: gradiente, padrão geométrico sutil e um ícone coerente com o grupo muscular.
- **Miniatura parada.** O arquivo da miniatura é uma animação curta de 128 px; a lista decodifica só o primeiro quadro (`ui.instantiateImageCodec`), uma vez por arquivo, e o guarda num cache em memória — uma lista de dezenas de exercícios não anima nem decodifica a mesma imagem duas vezes.
- **Caminhos.** Saem de `AppAssets` ([app_assets.dart](../lib/src/constants/app_assets.dart)): `gifDoExercicio(chave)`, `miniaturaDoExercicio(chave)` e `musculo(grupo)`. Quem precisa de uma imagem nunca monta o caminho à mão.
- **Aviso conhecido.** No Flutter web, o console mostra *"VideoFrame was garbage collected without being closed"* ao animar GIFs. Vem do motor, não do app.

## As imagens dos grupos musculares

Onze PNGs em `assets/img/muscles/` — um por grupo (`peito.png`, `costas.png`, `ombro.png`, `biceps.png`, `triceps.png`, `pernas.png`, `abdomen.png`, `gluteos.png`, `panturrilha.png`, `cardio.png`, `antebraco.png`) —, o nome do arquivo é o `slug` do `GrupoMuscular`. Mostram o corpo com o músculo em verde. Servem de ícone em dois lugares: a grade de grupos (cinza quando não escolhido, colorido e com visto quando escolhido) e os chips de músculo do detalhe e da execução. A pasta é declarada inteira no `pubspec.yaml`.

## Acrescentando um componente

1. Vai em `components/<categoria>/`; se a categoria não existe, cria.
2. Recebe dados por parâmetro. **Nunca** importa controller ou feature.
3. Usa só tokens para cor, espaço, raio e texto, e `AppAssets` para imagem.
4. Se for usado por uma única tela, fica em `view/widgets/` da feature.
5. Texto lido por leitor de tela: botões e itens selecionáveis levam `Semantics` (com `excludeSemantics` quando o filho repete o rótulo).
6. Atualiza a tabela desta página e a de [03-estrutura-pastas.md](03-estrutura-pastas.md#components-por-categoria).
