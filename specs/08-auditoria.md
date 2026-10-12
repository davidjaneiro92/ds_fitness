# Auditoria Técnica

Auditoria feita em 2026-10-12, na frente de trabalho que redesenhou o fluxo do app a partir das telas de referência e trocou as imagens do Google Drive por imagens locais. Registra o estado encontrado, o que foi feito, o que ficou diferente do planejamento e o que continua pendente.

## Estado encontrado

O app estava com as telas do planejamento ligadas à API real desde 2026-10-10 (acesso, treinos, exercícios, execução, histórico, estatísticas e perfil), mas:

- **As imagens dos exercícios vinham do Google Drive.** A API informava `gifUrl` e `miniaturaUrl` e o app as baixava com `cached_network_image`. O Drive aplica cota por arquivo: as imagens falhavam e voltava a ilustração genérica.
- **O fluxo de criar treino era outro.** Um formulário único (nome, objetivo, descrição e a lista de exercícios), uma tela de grupos, uma lista de exercícios com um *sheet* de configuração de **cinco campos** (séries, repetições, carga, descanso e observação) e uma tela de edição separada. As telas de referência pedem cinco passos com três campos de configuração e uma revisão no fim.
- **A Início** mostrava o treino do dia, o progresso semanal e seis atalhos; a **biblioteca** era uma aba da barra inferior.
- **O login** habilitava o botão só com os campos válidos e não tinha entrada por conta externa.
- 29 testes no último commit (serviços, modelos e a ilustração), nenhum de tela com as rotas reais.

As telas de referência — duas imagens iguais com as sete telas — passaram a ser o fluxo do app, e a decisão de produto foi: usar as imagens locais (a pasta `assets/` já trazia GIFs, miniaturas e imagens dos músculos), **não construir o login social agora** mas manter os botões, e alterar o front e, se preciso, a API para encaixar.

## Problemas encontrados

| Problema | Onde | Impacto |
|---|---|---|
| Imagens pelo Drive falhavam | `ExerciseIllustration` + `Exercicio.gifUrl` / `miniaturaUrl` | GIFs e miniaturas não carregavam; resolvido trocando por assets e por uma chave `imagem` |
| Fluxo de criar treino diferente das telas de referência | `treino_form/` (formulário, edição, *sheet*) | Redesenhado em cinco passos |
| **`"TreinoFormControllerInterface" not found` ao salvar** | Telas do fluxo (`GetView`) | `encerrar()` remove o controller com as telas ainda animando a saída; elas se reconstroem, o `Get.find` falha e a tela de erro do Flutter aparece na transição. Duas exceções por salvamento no log remoto, mais um *overflow* de 99.228 px. Não aparecia em nenhum teste de controller. Corrigido: telas com `State` (R16) |
| **Lista de treinos mostrava o treino de antes de salvar** | `ExercicioConfigurarView._confirmar` | Num treino que já existe, trocar a revisão-base fazia o `Future` da lista terminar cedo e a lista recarregar antes do `PUT`. Corrigido: a revisão é a base e só se volta a ela (R17) |
| Texto 3 px acima do centro | `AppSearchField`, `AppDropdownField` | Campos de 52 px sem centralização vertical; corrigido |
| Botão *Entrar* desabilitado até os campos ficarem válidos | `LoginView` | Sem indicação do que faltava; agora fica ativo e os erros aparecem sob cada campo |
| Espera de tempo fixo em teste de decodificação | `exercise_illustration_test.dart` | Podia falhar com a máquina carregada; passou a esperar a imagem aparecer |
| Teste sensível a tempo **fora desta frente** | `error_reporter_test.dart` | Falhou uma vez sob carga (espera de 50 ms). Não alterado; ver [07-engenharia.md](07-engenharia.md#testes-e-verificação) |

Os dois defeitos em negrito foram achados **depois** de a tela parecer correta na verificação visual: o primeiro, pela tabela `LogErro` da API (o `ErrorReporter` já estava no ar); o segundo, ao notar que a requisição de listagem não vinha depois do `PUT`. Hoje ambos têm teste de fluxo que falha se a correção for desfeita.

## Ações tomadas

1. **API** (`ds_fitnes_back`): migração `M202610121000` troca as colunas `gifUrl`/`miniaturaUrl` pela coluna `imagem` (a chave), preenchida para os exercícios do catálogo; `M202610121010` acrescenta três exercícios ao catálogo (ids 53 a 55) para fechar os 55 empacotados. A resposta de exercício passa a ter `imagem`.
2. **Imagens locais**: `AppAssets` monta os caminhos; `ExerciseIllustration` mostra o GIF (telas cheias) ou a miniatura parada (listas), com `AssetFirstFrame` guardando o primeiro quadro; `GrupoMuscularImagem` usa os PNGs dos músculos. Só o catálogo (55 exercícios) é declarado no `pubspec.yaml`; `cached_network_image` foi removido.
3. **Fluxo de montar o treino**: *Novo treino* (dia, nome, objetivo, descrição), *Grupos musculares* (seleção múltipla), *Selecionar exercício* (busca sem acento, um por vez), *Configurar exercício* (três campos, com o GIF) e *Revisar e salvar*, sobre um único `TreinoFormController`. Telas e controller antigos (edição, *sheet*, grupos por exercício) foram removidos.
4. **Início, abas e telas de apoio**: a Início ficou com dois cartões; as abas viraram Início, Treinos, **Evolução** e Perfil; a biblioteca passou para o Perfil e o histórico para um ícone da Evolução. Novos componentes: `PageHeader`, `DiaSemanaChips`, `GrupoMuscularTile`, `ExercicioSelecaoTile`, `ExercicioResumoTile`, `AppAddCard`, `AppSocialButton`.
5. **Login**: marca com o lema, botão *Entrar* sempre ativo, *Esqueceu sua senha?* e os botões de Google, Apple e Facebook (por enquanto só avisam).
6. **Execução**: cada exercício sem carga começa na última carga usada nele (o treino montado no app não guarda carga).
7. **Correções**: R16 e R17.
8. **Testes**: de 29 (último commit) para 89 — rascunho do treino, componentes, tela de Evolução, fluxo com as rotas reais e o log de erros (este último da frente do log).
9. **Documentação**: este SDD reescrito no formato `specs/` (o rascunho anterior ficou em `docs/`, descartado), e o SDD da API atualizado.

## Planejamento × implementado

Todas as telas do [planejamento](../planejamento-ds-fitness.md) existem. O que ficou diferente:

| Tela / regra do plano | Como ficou |
|---|---|
| 1 Splash — 1,5 s | 1,8 s; só olha se há token |
| 2 Login — *Esqueci minha senha* e *Entrar com Google* | Avisam *"Em breve"*; Apple e Facebook também, por decisão de produto; o botão *Entrar* fica sempre ativo |
| 3 Cadastro — senha com regra visível | Mínimo de 8 caracteres (regra do servidor), com a dica sob o campo |
| 4 Início — treino do dia, progresso semanal, atalhos | **Redesenhada em 2026-10-12**: só *Montar meu treino* e *Treinar*. O treino do dia segue destacado na lista; progresso semanal e os atalhos *Peso* e *Calendário* saíram |
| 5 Meus treinos — *swipe* ou pressão longa | Só pressão longa; tocar abre a revisão |
| 6 Novo treino — nome, objetivo, descrição, exercícios | **Redesenhado**: dia da semana, nome, objetivo e descrição; os exercícios vêm nos passos seguintes |
| 7 Grupos — escolha de um grupo | **Seleção múltipla**, com as imagens dos músculos |
| 8–9 Exercícios do grupo e *sheet* de configuração (séries, repetições, carga, descanso, observação) | **Selecionar exercício** (um por vez, busca) e **Configurar exercício** (séries, repetições e descanso, com o GIF). A **carga** passou para a execução e **observação** só pelo menu da execução |
| 12 Descanso — vibra e toca som, configuráveis | Sempre vibra e toca o clique do sistema; as chaves `pref_som_descanso` e `pref_vibrar_descanso` existem e nada as usa |
| 16 Histórico — filtros *Todos* e *Treinos* | Os dois mostram a mesma lista; agora se abre pelo ícone de relógio da *Evolução* |
| 17 Estatísticas — gráfico | Limitado a 8 pontos; é a aba *Evolução* |
| 18 Biblioteca | Ganhou o filtro por grupo muscular e a criação de exercício; aberta pelo **Perfil** (não é mais aba) |
| 19 Detalhe — GIF com *pinch to zoom* | Sem zoom; GIF local |
| 20 Perfil — *Meus dados*, *Medidas* | Só leitura; *Fotos de progresso* e a câmera: *"Em breve"*; ganhou *Biblioteca de exercícios* |
| 21 Treino concluído — *Compartilhar* | Avisa *"Em breve"* |
| 23 Alterar carga — sugestão pela progressão do histórico | Sugestão fixa: carga atual + 2,5 kg |
| 24 Observações — abre ao concluir um exercício | Abre pelo menu ⋮ da execução |
| §7 Persistência local da sessão a cada série | Guarda só a **posição** (exercício e série) |
| §7 Offline — a execução funciona sem rede e sincroniza depois | Não: abrir e finalizar o treino exigem rede; as imagens são do pacote |
| §7 Volume = carga × repetições × séries | Calculado pelo servidor: Σ carga × repetições das séries concluídas |
| Imagens por URL | Imagens do pacote, por chave (`imagem`) |

Além do plano, existem o CRUD de exercício próprio, os filtros de favoritos e recentes vindos da API, o resumo por exercício no histórico e o log remoto de erros.

## Pendências conhecidas

| Pendência | Motivo / situação |
|---|---|
| Entrar com Google, Apple e Facebook | Botões na tela; a decisão de produto é fazer essa parte em breve |
| *Esqueceu sua senha?* | A API não tem o endpoint |
| Fotos de progresso e câmera do avatar | Sem endpoint nem armazenamento de imagem |
| *Compartilhar* o treino concluído | Sem decisão de formato |
| Imagem de fundo do login | A tela de referência mostra a marca sobre uma imagem; não há arquivo para ela |
| Armazenamento local não cifrado | Token e *refresh token* em texto no Hive; trocar por armazenamento seguro antes de produção |
| Proteção contra toque duplo na execução; *"—"* para peso e altura não informados | Já corrigidos na branch `fix/execucao-treino-perfil` (PR aberto), **ainda não integrados** a esta frente. Essa branch vai **conflitar** com o redesenho em `treino_form_controller.dart`, nos testes e fakes compartilhados (`test/support/fakes.dart`) e em `http_manager_test.dart` |
| Branch `feat/gifs-dos-exercicios` | Obsoleta: guarda a versão das imagens pelo Drive. O trabalho novo está no mesmo branch, sem commit |
| `assets/` (421 MB) fora do versionamento | Só 55 exercícios são empacotados; ver [07-engenharia.md](07-engenharia.md#imagens-dos-exercícios) |
| `flutter_localizations` ausente | O seletor de data e outros textos nativos do Material não estão em pt-BR |
| `flutter_launcher_icons` sem o pacote | Configuração no `pubspec.yaml`, pacote não declarado |
| Execução em *carregando* para sempre se o treino não carrega; falha em `alterarCarga` sem tratamento | Ver [07-engenharia.md](07-engenharia.md#débito-técnico-conhecido) |
| Contas de teste no banco de desenvolvimento | E-mails `…@dsfitness.test`, criados na verificação; limpar com o script de limpeza do ambiente de desenvolvimento |
| Teste sensível a tempo | `error_reporter_test.dart` |

## Resultado da validação

- `flutter analyze`: **No issues found!**
- `flutter test --concurrency=1`: **89 testes verdes** (eram 29 no último commit).
- **Verificação visual no navegador, contra a API real**: login (validação, botões sociais, cadastro), Início, Treinos (lista, treino do dia), o fluxo de criar treino do início ao fim, edição de um treino existente (dados, menu ⋮, remover, configurar, adicionar, salvar), biblioteca, detalhe (GIF e abas), execução, abandonar, Evolução (vazia), Perfil e sair. Cada tela foi comparada com a referência.
- **Tabela `LogErro` depois da correção**: nenhum erro novo no uso completo do fluxo.
- **Banco de desenvolvimento**: migrações aplicadas; os 55 exercícios do catálogo com `imagem`.
- **Não verificado**: Android e iOS em aparelho, Evolução e histórico **com dados** na tela real (cobertos por teste de widget com dados falsos), reordenar por arrastar na tela real (coberto no controller), e o login social (não existe).
