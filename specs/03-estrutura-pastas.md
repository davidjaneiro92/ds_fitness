# Estrutura de Pastas

```
ds_fitness/
├── specs/                          # Esta documentação (SDD). 00-overview … 08-audit = template legado
├── planejamento-ds-fitness.md      # Planejamento de telas que originou o app (fora do SDD)
├── assets/
│   ├── icon/icon.png               # Ícone do app (config do flutter_launcher_icons no pubspec)
│   └── img/
│       ├── muscles/                # 11 PNGs dos grupos musculares (ícones); declarados por pasta
│       ├── gifs/<grupo>/<arq>.gif  # GIFs dos exercícios (1.323 na pasta; 55 declarados no pubspec)
│       ├── imagens_estaticas/<grupo>/<arq>.thumb.webp   # Miniaturas (idem)
│       └── erro3.png               # Imagem avulsa, sem uso e fora do pubspec
├── lib/
│   ├── main.dart                   # Bootstrap: Hive, serviços globais, handlers de erro, AuthController, GetMaterialApp
│   └── src/
│       ├── components/             # Design system: widgets reutilizáveis, por categoria
│       ├── constants/
│       │   ├── app_assets.dart         # Caminho dos GIFs, miniaturas e imagens dos músculos
│       │   ├── app_environment.dart    # Endereço da API por ambiente (--dart-define=API_BASE_URL)
│       │   └── endpoints.dart          # Todos os caminhos da API
│       ├── core/
│       │   ├── abstracts/          # Interfaces dos serviços (Http, Storage, Log, Format, ErrorReporter)
│       │   ├── exceptions/         # api_exception.dart
│       │   ├── features/           # As features do app (ver abaixo)
│       │   ├── services/           # Implementações: HttpManager, StorageService, LogService, FormatService, ErrorReporter
│       │   ├── theme/              # app_theme.dart e tokens/ (cor, espaçamento, tipografia)
│       │   └── utils/              # error_messages, json_utils, texto_utils, validators
│       ├── enum/                   # Enums do domínio e da navegação
│       ├── models/                 # Modelos de dado (fromJson/toJson manuais)
│       └── routes/
│           ├── app_pages.dart      # Mapa único de rotas (GetPage + Binding + transição)
│           └── route_args.dart     # Argumentos tipados de navegação
├── test/                           # Testes automatizados (ver abaixo)
├── web/                            # Arquivos da plataforma web (index.html, manifest, ícones)
├── .claude/launch.json             # Servidor de desenvolvimento web `ds-fitness-web` (porta 8087)
├── android/, windows/              # Boilerplate de plataforma do `flutter create` (ios, macos e linux não existem; `flutter create .` os gera)
├── pubspec.yaml                    # Dependências, versão e a lista de assets
├── analysis_options.yaml           # Lint (flutter_lints + regras do projeto)
└── README.md                       # Guia operacional: rodar, testar, gerar builds
```

## `lib/src/core/features/`

### Anatomia de uma feature

```
core/features/<feature>/
├── abstracts/    <feature>_controller_interface.dart, <feature>_repository_interface.dart
├── binding/      <feature>_binding.dart            registra repository e controller
├── controller/   <feature>_controller.dart         (+ commands/ na execução)
├── repository/   <feature>_repository.dart
└── view/         <feature>_view.dart               (+ widgets/ com as peças só desta tela)
```

Widget usado por **uma** tela mora em `view/widgets/`. Usado por duas ou mais vai para `components/`.

### As features

| Feature | O que tem | Particularidade |
|---|---|---|
| `auth` | Login, cadastro, `AuthController` global | Registrada no `main()`; sem binding. Os três botões de login social existem e só avisam "em breve" |
| `splash` | Espera mínima de 1,8 s e escolha da primeira rota | Sem repository |
| `home` | Saudação e os dois cartões (*Montar meu treino*, *Treinar*) | Sem repository: o nome vem do `AuthController` |
| `treinos` | Lista de treinos (aba *Treinos*); duplicar e excluir | Abre o fluxo de montar/editar e recarrega quando ele termina |
| `treino_form` | O fluxo de montar e revisar o treino: *Novo treino*, grupos, escolha e configuração do exercício, revisão | Cinco rotas e dois bindings dividem um `TreinoFormController` **permanente**; `ExerciciosController` é por rota. As telas são `StatefulWidget` (R16) |
| `biblioteca` | Busca, filtros, favoritos e recentes | Aberta pelo Perfil |
| `exercicio_detalhe` | Detalhe em abas (execução, músculos, histórico) | |
| `exercicio_form` | Criar, editar e excluir exercício próprio | |
| `execucao` | Execução do treino e resumo da sessão concluída | Única com `commands/`; o resumo não tem controller |
| `historico` | Sessões paginadas, detalhe, resumo por exercício | Aberto pelo ícone da *Evolução* |
| `estatisticas` | Totais, gráfico de volume e distribuição por grupo (aba *Evolução*) | |
| `perfil` | Dados, objetivo, medidas corporais, biblioteca e sair | |

## `components/` por categoria

| Pasta | Widgets |
|---|---|
| `anatomy/` | `GrupoMuscularImagem`, `MuscleChip` / `MuscleChipsRow` |
| `buttons/` | `AppButton` (variantes `primary`, `outline`, `ghost`, `danger`, `surface`), `AppSocialButton` |
| `cards/` | `AppCard`, `AppAddCard`, `ExerciseCard`, `ExercicioResumoTile`, `ExercicioSelecaoTile`, `GrupoMuscularTile`, `StatBox`, `TreinoCard` |
| `charts/` | `AppLineChart`, `ChartPoint` |
| `chips/` | `AppChip`, `AppChipBar`, `DiaSemanaChips` |
| `common/` | `Gap`, `PageHeader`, `SectionHeader`, `AppProgressBar` |
| `empty_states/` | `EmptyState` |
| `feedback/` | `AppSnackbar`, `showAppConfirmDialog`, `ConfettiBurst` |
| `inputs/` | `AppTextField`, `AppDropdownField`, `AppSearchField`, `StepperField` |
| `media/` | `ExerciseIllustration`, `AssetFirstFrame` |
| `modals/` | `AppModalSheet`, `showAlterarCargaModal`, `showEvolucaoCargaModal`, `showObservacoesModal` |
| `navbars/` | `AppNavbar` / `NavbarAction`, `AppBottomNav` |
| `scaffolds/` | `AppScaffold` |
| `steppers/` | `SerieStepper` |
| `timers/` | `CircularTimer` |

## `enum/`, `models/` e `core/utils/`

| Arquivo | Conteúdo |
|---|---|
| `enum/pages_routes.dart` | `PagesRoutes`: o caminho de cada rota |
| `enum/app_tab.dart` | `AppTab`: as quatro abas da barra inferior (Início, Treinos, Evolução, Perfil) |
| `enum/dia_semana.dart` | `DiaSemana`: segunda a domingo, com `numero` (1–7, o da API), `abreviacao` e `nome` |
| `enum/grupo_muscular.dart` | `GrupoMuscular`: onze grupos mais `todos`, com `slug` e `label`; `reais` exclui `todos` |
| `enum/objetivo_treino.dart` | `ObjetivoTreino`: cinco valores, com `slug` e `label` |
| `enum/execucao_state.dart` | `ExecucaoState`: os estados da execução |
| `enum/periodo_estatistica.dart` | `PeriodoEstatistica`, `HistoricoFiltro`, `BibliotecaFiltro` |
| `enum/exercicio_form_resultado.dart` | `ExercicioFormResultado`: `salvo` ou `excluido` |
| `enum/http_method.dart` | `HttpMethod`: `get`, `post`, `put`, `delete` |
| `models/usuario.dart` | `Usuario` |
| `models/exercicio.dart` | `Exercicio` (inclui `imagem`, a chave da imagem) |
| `models/treino.dart`, `treino_exercicio.dart` | `Treino` (com `dia` e `titulo`) e o item configurado dentro dele (com `resumo`) |
| `models/sessao.dart`, `serie_executada.dart` | `Sessao` e `SerieExecutada` |
| `models/registro_carga.dart` | `RegistroCarga`, `EvolucaoDeCarga`, `MedidaCorporal` |
| `core/utils/` | `ErrorMessages` (erro → texto para o usuário), `JsonUtils` (id, número, data), `TextoUtils` (busca sem acento nem caixa), `Validators` |

## `test/`

```
test/
├── widget_test.dart                  FormatService e Validators
├── http_manager_test.dart            HttpManager (token, renovação) e ApiException
├── error_reporter_test.dart          Fila e envio do log de erros
├── models_json_test.dart             Leitura do JSON da API nos modelos
├── components_test.dart              Chips de dia, tiles, campo de texto e busca sem acento
├── exercise_illustration_test.dart   Caminhos das imagens e a ilustração do exercício
├── estatisticas_view_test.dart       Tela de Evolução (carregando, vazio, com dados, período)
├── treino_form_controller_test.dart  Regras do rascunho do treino
├── treino_fluxo_test.dart            O fluxo de montar o treino, com as rotas e telas de verdade
└── support/fakes.dart                StorageFake e LogFake, compartilhados pelos testes
```

O que cada arquivo cobre está em [07-engenharia.md](07-engenharia.md#testes-e-verificação).

## O que cada pasta representa

- **`components/`** — qualquer widget usado por mais de uma tela. Recebe dados por parâmetro e não conhece nenhum controller nem feature.
- **`constants/`** — endereços e caminhos que o código não pode escrever à mão: a API (`Endpoints`, `AppEnvironment`) e as imagens (`AppAssets`).
- **`core/abstracts/` e `core/services/`** — capacidades transversais, sempre em par interface/implementação. Nenhum serviço conhece tela.
- **`core/features/<feature>/`** — cada funcionalidade do app é uma pasta isolada, com seu controller, repository e view. Adicionar ou remover uma feature não toca nas outras.
- **`core/theme/`** — o tema escuro e os três arquivos de tokens; nenhum widget declara cor, medida ou estilo de texto solto.
- **`enum/` e `models/`** — o vocabulário do domínio, compartilhado por controllers, repositories e componentes.
- **`routes/`** — o ponto único onde as rotas são registradas e onde os argumentos de navegação são tipados.
- **`assets/img/`** — as imagens do app. A pasta tem muito mais exercícios do que o app empacota: só os do catálogo da API estão declarados no `pubspec.yaml` ([07-engenharia.md](07-engenharia.md#imagens-dos-exercícios)).

## Convenções de nome

| Item | Regra | Exemplo |
|---|---|---|
| Arquivo | `snake_case.dart` | `treino_form_controller.dart` |
| Classe, enum | `PascalCase` | `TreinoFormController` |
| Interface | Sufixo `Interface`, em `abstracts/` | `HomeControllerInterface` |
| Controller, repository, binding, view | `<Feature>Controller`, `…Repository`, `…Binding`, `…View` | `HistoricoRepository` |
| Command | Verbo no infinitivo + objeto + `Command` | `ConcluirSerieCommand` |
| Argumento de rota | `<Tela>Args` | `ExecucaoArgs` |
| Domínio | Português, sem acento no identificador | `treino`, `exercicio`, `gruposSecundarios` |
| Texto para o usuário | Português do Brasil, com acento | `'Treino excluído'` |
