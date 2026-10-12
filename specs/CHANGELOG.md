# Changelog

Registro de alterações relevantes do projeto. Toda alteração de negócio ou arquitetura deve ser registrada aqui, com a data (mais recente primeiro).

## 2026-10-12 (2) — Correção: *"not found"* ao salvar o treino e a lista que mostrava o treino de antes de salvar

Achados na verificação visual do fluxo novo, depois de a tela já parecer correta. Nenhum dos dois aparecia em teste de controller.

**1. `"TreinoFormControllerInterface" not found` ao salvar.** Reportado pelo próprio app: a tabela `LogErro` da API recebeu, a cada salvamento, duas exceções *"… not found"* e um *"A RenderFlex overflowed by 99228 pixels"* (a tela de erro do Flutter desenhada na transição). **Causa**: salvar chama `encerrar()`, que remove o `TreinoFormController` permanente do registro, e só depois a navegação sai do fluxo — com as telas ainda **animando a saída**. Salvar acabara de mexer na lista de exercícios, então a tela de revisão se reconstruía nesse intervalo, e o `GetView` fazia `Get.find` de novo: o controller já não existia. **Correção**: as quatro telas do fluxo (`TreinoFormView`, `GruposView`, `ExercicioConfigurarView`, `TreinoRevisarView`) deixaram de ser `GetView` e passaram a ser `StatefulWidget` com `final … _controller = Get.find();` no `State` (R16). A nota está também na interface do controller.

**2. A lista de treinos mostrava o treino de antes de salvar.** Abrir um treino que já existe, acrescentar um exercício e salvar devolvia a lista com o treino antigo (*"Seg · 2 exercícios"* em vez de *"Ter · 1 exercício"*, nos testes). **Causa**: a lista abre o fluxo com `await Get.toNamed(revisar)` e recarrega quando esse `Future` termina — mas ao confirmar a configuração de um exercício, o app **substituía** a revisão (`offNamedUntil`), o `Future` terminava ali, a lista recarregava **antes** do `PUT` e nunca mais. Num treino novo isso não acontecia, porque a base do fluxo era o formulário, que ficava na pilha. **Correção**: num treino que já existe, a revisão é a base e `ExercicioConfigurarView` volta a ela com `Get.until(revisar)`; só o treino novo recria a revisão (R17).

**Regressão coberta** por [test/treino_fluxo_test.dart](../test/treino_fluxo_test.dart): três testes com o `GetMaterialApp` e `AppPages.pages` reais e um servidor falso — treino novo do formulário até salvar; treino existente + exercício + salvar (a lista mostra *"2 exercícios"* e recarrega uma vez); sair sem mexer em nada. Foi conferido que **desfazer cada correção faz o teste falhar** (o primeiro reproduz exatamente o erro do log).

**Também nesta entrega**: [test/estatisticas_view_test.dart](../test/estatisticas_view_test.dart) (a tela de Evolução com dados falsos: carregando, vazia, com dados e troca de período), o campo de busca com o texto centralizado na altura, e a espera da decodificação do GIF em `exercise_illustration_test.dart` trocada por uma consulta repetida (a espera fixa de 1 s podia falhar com a máquina carregada).

## 2026-10-12 — Redesenho do fluxo a partir das telas de referência e imagens locais

O usuário enviou as sete telas de referência do app e pediu que **todas as telas seguissem esse fluxo**, que as imagens da pasta `assets/` substituíssem as do Google Drive (que davam erro), e que os botões de login por Google, Apple e Facebook ficassem na tela **sem função por enquanto**. O front foi alterado inteiro e a API, no que era preciso.

**Fluxo.** Login → Início (*Montar meu treino* / *Treinar*) → Novo treino (dia da semana, nome, objetivo, descrição de até 200 caracteres) → Grupos musculares (seleção múltipla, com as imagens dos músculos) → Selecionar exercício (busca sem acento, um por vez) → Configurar exercício (GIF, séries 4, repetições 12, descanso 90 s) → Revisar e salvar (*"Treino A • Segunda"*, menu ⋮ de cada exercício, *Adicionar exercício* tracejado). Tudo sobre um único `TreinoFormController` permanente; o treino que já existe abre direto a revisão, com *Iniciar treino* e *Salvar treino*. Regras em [05-regras-de-negocio.md](05-regras-de-negocio.md#montar-um-treino), diagramas em [06-fluxos.md](06-fluxos.md#montar-um-treino).

**Telas e navegação.** A Início ficou com dois cartões; as abas viraram **Início, Treinos, Evolução e Perfil**; a biblioteca de exercícios passou para o Perfil e o histórico para um ícone da Evolução. O login ganhou o lema, o botão *Entrar* sempre ativo (os erros aparecem sob cada campo) e os três botões sociais. A execução passou a começar cada exercício sem carga na **última carga usada**, já que o treino montado no app não guarda carga. Removidos: o formulário único, a tela de edição, o *sheet* de configuração de cinco campos, o controller de grupos, o repository e os atalhos da Início.

**Imagens locais.** `AppAssets` monta o caminho dos GIFs (`assets/img/gifs/<chave>.gif`), das miniaturas (`assets/img/imagens_estaticas/<chave>.thumb.webp`) e das imagens dos músculos (`assets/img/muscles/<slug>.png`). As miniaturas são animações curtas: as listas mostram só o primeiro quadro (`AssetFirstFrame`). Só os **55 exercícios do catálogo** são declarados no `pubspec.yaml` (a pasta tem 1.323 e passa de 400 MB). `cached_network_image` foi removido. Como incluir outro exercício: [07-engenharia.md](07-engenharia.md#imagens-dos-exercícios).

**API.** `Exercicio` deixou de ter `gifUrl` e `miniaturaUrl` e passou a ter `imagem`, a chave. Migração `M202610121000_TrocarLinksDoDrivePelaChaveDaImagem` (cria a coluna, preenche as chaves do catálogo, remove as duas colunas antigas) e `M202610121010_AcrescentarExerciciosAoCatalogo` (os ids 53 a 55: Supino com Halteres, Supino na Máquina e Crucifixo Inclinado). Aplicadas no banco de desenvolvimento e conferidas pela API. Detalhes no SDD da API, documentos 09, 12 e 13.

**Componentes novos**: `PageHeader`, `DiaSemanaChips`, `GrupoMuscularTile`, `GrupoMuscularImagem`, `ExercicioSelecaoTile`, `ExercicioResumoTile`, `AppAddCard`, `AppSocialButton`, `AssetFirstFrame`; tokens de tipografia `pageTitle` e `fieldLabel`; `TextoUtils` (busca sem caixa nem acento); enum `DiaSemana`. Ver [04-componentes.md](04-componentes.md).

**Testes**: 24 do rascunho do treino, 12 de componentes, a reescrita dos de imagem e ilustração e os casos novos de modelo (chave da imagem, dia da semana, título e resumo do item). Cada tela foi comparada com a referência no navegador, contra a API real.

**Documentação.** Este SDD foi reescrito no formato `specs/`; as pastas `00-overview` a `08-audit` ficam como referência do template legado ([README.md](README.md)). O `README.md` da raiz, que ainda descrevia o template, foi atualizado.

## 2026-10-10/11 — Log de erros do aplicativo

Frente de trabalho própria, registrada aqui porque está no código do app e foi **a ferramenta que achou os defeitos de 2026-10-12**. Módulo Log na API (`POST /api/v1/log/erros`, tabela `LogErro` na base de autenticação) e, no app, o `ErrorReporter`: fila local no Hive (até 100 erros, 30 s de espera depois de uma falha, 4xx descartado), `Dio` próprio (o envio do log nunca renova sessão nem gera outro log), versão e plataforma junto com o erro. `LogService.error` e toda requisição que falhou de vez (`LogService.requisicaoFalhou`, chamado pelo `HttpManager`) vão para ele; o `main()` liga `FlutterError.onError` e `PlatformDispatcher.onError` ao mesmo log. Testes em `test/error_reporter_test.dart`. Ver [02-arquitetura.md](02-arquitetura.md#erros-e-observabilidade).

## 2026-10-10 — Imagens dos exercícios pelo Google Drive (obsoleta)

Branch `feat/gifs-dos-exercicios`: a API informava `gifUrl` e `miniaturaUrl` apontando para uma pasta pública do Drive, e o app as baixava com `cached_network_image`. **Abandonado em 2026-10-12**: a cota por arquivo do Drive derrubava as imagens. A solução atual (imagens do pacote, chave na API) está na entrada de 2026-10-12.

## 2026-10-10 — Correções da execução e do perfil (branch `fix/execucao-treino-perfil`, PR aberto)

Ainda **não integradas** a esta frente. O toque em *Finalizar treino* e o avanço automático da série concluída podiam chamar `avancarAposSerieConcluida` duas vezes: com o envio em andamento isso gravava a sessão duas vezes, e um toque tardio no *overlay* finalizava o treino antes da hora; agora o avanço só vale com a série concluída em pé e uma trava impede dois envios. Abrir um treino e iniciar ou voltar sem editar não faz mais `PUT`, e o `PUT` devolve o `diaSemana` carregado (antes mandava `null` e o servidor apagava o dia). Peso e altura não informados (0 no servidor) aparecem como *"—"*. Testes do controller da execução, do formulário de treino e do `Usuario`, com `StorageFake` e `LogFake` compartilhados em `test/support`. Esta branch **conflita** com o redesenho (o `TreinoFormController` foi reescrito, e os testes e fakes mudaram).

## 2026-10-10 — Integração com a API

Commit `d23e233`. As telas do planejamento foram ligadas ao `ds_fitnes_back`: acesso (login, cadastro, renovação do token), treinos, exercícios (biblioteca, detalhe, formulário, favoritos, recentes), execução (série a série, descanso, retomada, sessão e recordes calculados pelo servidor), histórico, estatísticas e perfil. `HttpManager` com renovação antes de vencer e depois do 401, uma renovação por vez; `ApiException`; serviços de armazenamento, log e formatação; tokens de design e o catálogo de componentes. Padrão interface → controller → repository → view sobre GetX.

## 2026-08-08 — Início do projeto

Repositório criado a partir do template corporativo `direction_app1` (GetX, Dio, Hive), com o domínio de logística removido e a documentação do template preservada em `specs/00-overview` a `specs/08-audit`.
