# Regras de Negócio

Regras efetivamente implementadas no código hoje. Sempre que uma nova regra for adicionada, este arquivo deve ser atualizado junto (R15 em [07-engenharia.md](07-engenharia.md)). O app é um cliente fino: onde a regra é da API, ela aparece aqui como **contrato** e o código da API decide.

## Acesso

### Sessão

1. A splash espera **1,8 s** (para não "piscar") e olha se existe token salvo: com token vai para `/home`, sem token para `/login`. Não consulta o servidor. Se o token estiver vencido, a primeira chamada autenticada o renova ou, se o *refresh token* também venceu, leva ao login.
2. O `HttpManager` envia `Authorization: Bearer {token}` em toda chamada autenticada. Renova **antes** de enviar quando o token vence em menos de 30 s e **depois** de um 401 (repetindo a chamada uma vez). Uma renovação por vez: chamadas simultâneas esperam a mesma resposta, porque o *refresh token* é de uso único.
3. Refresh token **recusado** (4xx) = a sessão acabou: o `AuthController` limpa o que é local, mostra *"Sua sessão expirou. Entre novamente."* e abre o login. Falha de rede ou 5xx na renovação **não** derruba a sessão.
4. *Sair* confirma, avisa o servidor (`logoff`, ignorando falha de rede), apaga a sessão local — token, usuário e a marca da execução em andamento — e abre o login.

### Login (`/login`)

E-mail e senha (com mostrar/ocultar). O botão *Entrar* fica **sempre ativo**: ao tocar, os campos são validados e o erro aparece sob cada um (*"Informe seu e-mail"*, *"Informe sua senha"*, e-mail com formato inválido, senha com menos de 6 caracteres; o tamanho **real** da senha quem decide é o servidor). Credencial errada mostra *"E-mail ou senha inválidos"*. Sucesso grava a sessão e abre a Início com `offAllNamed`.

*Esqueceu sua senha?* solicita um código de seis dígitos por e-mail, depois permite informar o código e uma nova senha (mínimo de 8 caracteres). O código vence em 10 minutos e após cinco tentativas incorretas precisa ser solicitado novamente. É possível voltar para trocar o e-mail ou solicitar outro código. No sucesso, a senha é atualizada e as sessões refresh são revogadas; o usuário retorna ao login. O servidor responde sem confirmar se o e-mail existe. O envio requer SMTP Gmail configurado no backend. Os botões **Google, Apple e Facebook** estão na tela e, por decisão de produto, **não têm função por enquanto**: cada um avisa *"Entrar com o … estará disponível em breve"*. *Cadastre-se* abre o cadastro.

### Cadastro (`/cadastro`)

Nome completo (nome e sobrenome), e-mail, senha (mínimo **8** caracteres, a regra do servidor, com a dica sob o campo), data de nascimento (`dd/mm/aaaa` com seletor; idade mínima de 16 anos) e sexo (chips Masculino e Feminino). O botão habilita quando todos os campos estão preenchidos; ao tocar, valida os formatos e mostra os erros nos campos. Por baixo:

1. cria a conta (`auto-cadastro`, só com e-mail e senha);
2. entra (`login`);
3. grava o perfil com nome, nascimento e sexo (`PUT /cadastro/perfil`);
4. abre a Início — o usuário já está logado.

E-mail repetido (409) mostra *"Já existe uma conta com este e-mail."*. Entrar numa conta que existe **sem perfil** (o cadastro caiu entre o passo 1 e o 3) cria o perfil na hora, com o nome tirado do e-mail.

## Início

*"Olá, {primeiro nome}!"* e *"O que você quer fazer?"*, com dois cartões:

- **Montar meu treino** abre `/treinos/novo` (um treino novo; ao terminar, o fluxo abre a lista de treinos);
- **Treinar** abre a lista de treinos (`offAllNamed`, porque é uma aba).

A Início não consulta a API: o nome é o do usuário que o `AuthController` já tem.

## Meus treinos (`/treinos`)

1. Lista os treinos do usuário (nome, grupos musculares dos exercícios, "N exercícios" e o dia da semana). O **treino do dia** vem com a borda verde: a API devolve o primeiro treino marcado para o dia da semana de hoje e, sem nenhum marcado para hoje, o **primeiro treino** do usuário — por isso um treino de outro dia pode aparecer destacado.
2. Tocar em um treino abre a **revisão** dele (editar, e *Iniciar treino*). **Pressão longa** abre *Duplicar* e *Excluir* (esta com confirmação, irreversível).
3. O botão fixo *Novo treino* abre o fluxo de montar. Lista vazia mostra *"Você ainda não criou nenhum treino"* com a ação *Criar treino*.
4. A lista **recarrega** quando o fluxo que ela abriu termina (ver [02-arquitetura.md](02-arquitetura.md#o-fluxo-de-montar-o-treino-estado-e-pilha)).

## Montar um treino

Cinco passos, um rascunho só (o `TreinoFormController`). O diagrama está em [06-fluxos.md](06-fluxos.md#montar-um-treino).

### 1. Novo treino (`/treinos/novo`)

- **Dia da semana**: sete botões, Seg a Dom; o padrão é **hoje**. É o dia que a API usa para escolher o treino do dia.
- **Nome**: obrigatório (sem contar espaços nas pontas). *Continuar* só habilita com nome.
- **Objetivo**: opcional; cinco opções (Hipertrofia, Emagrecimento, Força, Resistência, Condicionamento); padrão *Hipertrofia*.
- **Descrição**: opcional, até **200** caracteres, com o contador `0/200`.
- Sair com algo preenchido pergunta *"Descartar treino?"*; sem nada preenchido sai direto. Em ambos os casos o rascunho é descartado.

### 2. Grupos musculares (`/grupos`)

Os onze grupos (sem o atalho *Todos*), em grade de três colunas, cada um com a imagem do músculo. **Seleção múltipla**: o grupo escolhido ganha borda verde, imagem em cores e um visto; os outros ficam em cinza. *Próximo* só habilita com pelo menos um grupo. Os grupos escolhidos **ficam** entre uma adição e outra, e num treino que já existe vêm marcados com os grupos dos exercícios dele.

### 3. Selecionar exercício (`/exercicios`)

1. Mostra os exercícios cujo grupo **primário** foi escolhido (quem monta um treino de peito e tríceps quer os exercícios de peito e de tríceps, e não todo supino só porque o tríceps ajuda). Sem grupo escolhido, mostra o catálogo todo.
2. **Busca** local por nome, sem diferenciar maiúsculas nem acentos (`"MAQUINA"` encontra *"Supino na Máquina"*).
3. **Um** exercício marcado por vez (círculo com visto). O que **já está no treino** aparece apagado, com *No treino*, e não pode ser escolhido: a API não aceita o mesmo exercício duas vezes no treino.
4. *Configurar exercício* só habilita com um exercício marcado.

### 4. Configurar exercício (`/exercicios/configurar`)

O exercício escolhido (nome, grupos separados por ` • `, e o **GIF** do movimento) e três campos:

| Campo | Faixa | Passo | Padrão |
|---|---|---|---|
| Séries | 1 – 20 | 1 | 4 |
| Repetições | 1 – 100 | 1 | 12 |
| Descanso | 15 – 600 s | 15 s | 90 s |

A **carga não se define aqui**: ela é escolhida na execução. O botão é *Adicionar ao treino* (ou *Salvar alterações*, quando a tela edita um exercício que já está no treino). Confirmar acrescenta o item ao fim da lista (`ordem` = posição) com um id local (`novo_N`); confirmar duas vezes não repete o exercício; editar um item preserva a carga e a observação que ele já tinha.

### 5. Revisar e salvar (`/treinos/revisar`)

- Título **"{Nome} • {Dia}"** (só o nome, num treino antigo sem dia) e a lista dos exercícios, cada um com miniatura, nome e *"4 séries • 12 reps • 90 s"*.
- O menu ⋮ de cada exercício tem **Editar** (reabre o passo 4) e **Remover** (com confirmação). Remover e **reordenar** (segurar e arrastar) renumeram a `ordem` dos que ficam.
- *Adicionar exercício* (cartão tracejado) volta ao passo 2.
- O lápis da barra abre *Dados do treino*: dia, nome, objetivo e descrição, com *Concluir*.
- **Treino novo**: o botão é *Salvar treino* (habilita com nome e ao menos um exercício). Voltar leva ao formulário, que guarda o que foi preenchido.
- **Treino que já existe** (aberto pela lista): o botão principal é *Iniciar treino*, e *Salvar treino* (contorno verde) só habilita quando algo mudou. Voltar com mudança pergunta *"Descartar alterações?"*; sem mudança sai sem ir ao servidor.

### Salvar

1. Treino novo → `POST /treinos`; treino que existe → `PUT /treinos/{id}`. O corpo leva nome, objetivo, descrição, **dia da semana**, e os exercícios na ordem da lista (item com id numérico é atualizado, item com id local é criado).
2. **Nada mudou, nada é enviado.** Abrir um treino e iniciar ou voltar sem editar não faz `PUT`. "Mudou" compara dia, nome, objetivo, descrição e cada item (id, exercício, ordem, séries, repetições, carga, descanso, observação) com o que foi carregado ou salvo da última vez.
3. O `PUT` devolve o `diaSemana` que foi carregado — um treino antigo, sem dia, não perde o dia por ser editado.
4. Depois de salvar, os ids locais são trocados pelos do servidor, o fluxo é encerrado e o app volta à lista (se ela abriu o fluxo) ou abre a lista (se foi a Início), com o aviso *"Treino salvo!"*.
5. *Iniciar treino* **salva** (se mudou) e abre a execução, substituindo a revisão na pilha.

## Exercícios

### Biblioteca (`/biblioteca`, aberta pelo Perfil)

Busca por nome (sem caixa nem acento), chips *Todos / Favoritos / Recentes* e uma fileira de chips por grupo muscular. Cada linha: miniatura, nome, grupos e a estrela (favoritar). O `+` da barra abre o formulário de exercício. Tocar na linha abre o detalhe; ao voltar, a lista recarrega sem piscar.

A tela carrega **duas listas de uma vez**: todos os exercícios e os recentes (`?filtro=recentes`, que traz a ordem de acesso). Favoritos, grupo e busca são aplicados **no app**, sobre a lista completa.

### Detalhe (`/exercicio`)

Cabeçalho com o GIF (220 px), o nome, o equipamento e os grupos (com as imagens dos músculos). Três abas:

| Aba | Conteúdo |
|---|---|
| Execução | Passo a passo numerado; sem instruções, um estado vazio |
| Músculos | Grupo primário e secundários |
| Histórico | Gráfico da evolução de carga, a melhor carga e o botão *Ver evolução completa* |

Na barra: a estrela (favoritar) e, **só para exercício do próprio usuário**, o lápis (editar). Abrir o detalhe registra o acesso (`POST …/acesso`), o que alimenta *Recentes*; se essa chamada falhar, a tela não reclama.

### Formulário de exercício (`/exercicio/novo` e `/exercicio/editar`)

Nome, grupo primário, grupos secundários (o primário sai dos secundários), equipamento (sugestões: Barra, Halteres, Máquina, Cabo, Peso corporal) e os passos da execução (adicionar e remover). Na edição há *Excluir exercício*, com confirmação. O catálogo do sistema não chega aqui: o servidor o recusa com 403. Um exercício criado pelo usuário **não tem imagem** (`imagem` vazia): as telas mostram a ilustração genérica do grupo.

## Execução do treino

É o núcleo do produto e a única feature com máquina de estados, cronômetros e *commands* (`core/features/execucao/`). O mesmo `ExecucaoController` conduz `/execucao`; o resumo (`/execucao/concluido`) não tem controller e lê a sessão dos argumentos.

### Como se chega aqui

| De onde | Como |
|---|---|
| Revisão de um treino que existe, *Iniciar treino* | Salva (se mudou) e `offNamed(/execucao)`: a revisão sai da pilha |

No `onInit`, o controller lê o `ExecucaoArgs`, busca o treino (`GET /treinos/{id}`) e entra no primeiro exercício. Sem os argumentos, ou com treino inexistente, ele só registra um aviso no log e a tela fica em *carregando* ([08-auditoria.md](08-auditoria.md#pendências-conhecidas)).

### A máquina de estados

| Estado (`ExecucaoState`) | Tela | O que o usuário faz |
|---|---|---|
| `carregando` | Indicador de carregamento | Espera |
| `exercicio` | `ExercicioStepView` | Vê o GIF, os músculos e a carga; executa a série e toca em *Realizado*; pode trocar a carga, anotar, ver a evolução, ir ao exercício anterior ou ao próximo |
| `descanso` | `DescansoView` | Espera o anel zerar, ajusta ±15 s, pausa ou pula |
| `serieConcluida` | `SerieConcluidaOverlay` | Vê a celebração; segue em 3 s ou no botão (*Próximo exercício* / *Finalizar treino*) |
| `concluido` | Indicador (a tela já saiu para o resumo) | — |

O diagrama está em [06-fluxos.md](06-fluxos.md#execução-do-treino).

> **Regra de ouro: o descanso nunca aparece depois da última série de um exercício.** Não depende de cuidado de quem edita a tela: o único lugar do código que atribui `ExecucaoState.descanso` é o ramo `else` do `ConcluirSerieCommand`, guardado por `numeroSerie >= totalSeries`. Depois da última série vem a celebração, e dela o exercício seguinte — sem descanso entre exercícios.

### Os comandos

| Comando | O que faz |
|---|---|
| `ConcluirSerieCommand` | Acrescenta a série concluída (com a carga corrente e as repetições planejadas) e decide o próximo estado: `serieConcluida` na última série, `descanso` nas demais, com o tempo de descanso do exercício |
| `AlterarCargaCommand` | Troca a carga do exercício atual **dali em diante** e registra a nova carga (`POST /execucao/cargas`) |
| `FinalizarTreinoCommand` | Monta a sessão só com as séries concluídas, envia (`POST /execucao/sessoes`), apaga a marca de retomada e abre o resumo com a sessão que o **servidor devolveu** |

### Carga

- O treino montado no app **não guarda carga** (`cargaInicial` = 0). Ao carregar, cada exercício sem carga **começa na última carga que o usuário usou nele** (`GET /execucao/cargas/{exercicioId}`, o registro mais recente); se não houver histórico ou a busca falhar, começa em 0 — como num exercício que nunca foi feito.
- **Alterar carga** abre um modal com a carga atual, o passo (0,5 / 1 / 2,5 / 5 kg) e a sugestão *carga + 2,5 kg*. A nova carga vale a partir da **próxima** série do exercício; as já feitas guardam a carga com que foram feitas.
- **Observações** (menu ⋮) guardam texto e dificuldade (1 a 5 estrelas) na **última série concluída do exercício atual**; sem série concluída dele, ficam pendentes e vão para a próxima.
- **Evolução de carga** (menu ⋮) abre o gráfico do exercício atual.

### Cronômetros

| Cronômetro | Cadência | Regra |
|---|---|---|
| Geral do treino | 1 s | Começa quando o treino carrega; só para ao finalizar ou sair. Inclui descansos e pausas — é o tempo de relógio da sessão |
| Descanso | 1 s | Não conta enquanto pausado. Ao chegar a zero **vibra** (`HapticFeedback.mediumImpact`), toca o **clique do sistema** e, 700 ms depois (a tela mostra *"Hora da próxima série!"*), volta ao exercício na série seguinte |
| Série concluída | 3 s | Dispara `avancarAposSerieConcluida`, o mesmo método do botão |

*Pular descanso* zera na hora e avança a série. *±15 s* só vale durante o descanso, nunca passa de zero e, se ultrapassar o total, o total cresce junto (o anel não estoura).

### Sair, falhar e retomar

- **Sair pede confirmação.** O botão e o gesto de voltar, no exercício e no descanso, abrem *"Abandonar o treino?"*. Confirmar apaga a marca de retomada e fecha **sem enviar nada**.
- **Se o envio falha, o treino não é dado como concluído.** A tela segue na última série, mostra *"Não foi possível salvar o treino. {motivo}"*, e o botão *Finalizar treino* tenta de novo. O progresso fica na memória enquanto o app estiver aberto.
- **Retomada.** Depois de cada série concluída o controller grava no armazenamento local (`sessao_em_andamento`): `treinoId`, `indiceExercicio` e `serieAtual`. Ao abrir de novo **o mesmo treino**, volta ao exercício em que parou, na série seguinte, e mostra *"Treino retomado de onde você parou"*. A marca some quando o treino é finalizado, abandonado ou quando o usuário sai da conta. **Não volta**: as séries já concluídas (a sessão enviada tem só as feitas depois da retomada), o cronômetro geral e as trocas de carga e observações. A marca também **não expira**.
- **Ainda sem proteção contra toque duplo.** Nesta branch o botão *Finalizar treino* e o avanço automático de 3 s podem chamar `avancarAposSerieConcluida` duas vezes, e cada envio grava uma sessão. A correção (avanço só com a série concluída em pé e uma trava no envio) está na branch `fix/execucao-treino-perfil`, ainda não integrada — [08-auditoria.md](08-auditoria.md#pendências-conhecidas).

### O que é enviado ao servidor

`POST /api/v1/execucao/sessoes`:

| Campo | Valor |
|---|---|
| `treinoId` | O treino executado |
| `iniciadoEm`, `finalizadoEm` | Instantes em UTC; o início é o fim menos a duração |
| `duracaoSeg` | O cronômetro geral |
| `tempoDescansoSeg` | Os segundos de descanso realmente vividos (sem as pausas) |
| `series[]` | Só as concluídas: `exercicioId`, `numeroSerie`, `repeticoes`, `carga`, `concluida`, `dificuldade`, `observacao` |

A resposta traz a sessão com **volume, calorias e recordes** calculados pelo servidor; a tela de conclusão mostra essa sessão: troféu e confete, *"Treino Concluído!"*, cinco números (tempo total, exercícios, séries, volume total, calorias) e os **recordes pessoais** batidos. *Compartilhar* avisa *"Em breve"*; *Voltar para home* fecha o fluxo.

## Evolução e histórico

### Evolução (`/estatisticas`, aba *Evolução*)

Lista de período (*Esta semana, Este mês, 3 meses, Ano, Tudo*; começa em *Este mês*), quatro números (treinos, tempo total, volume total, calorias), o gráfico *Evolução de volume (kg)* e a *Distribuição por grupo muscular* em barras. Sem sessão no período, mostra *"Sem dados no período"*. O gráfico mostra no máximo **8 pontos**: acima disso o app soma blocos consecutivos. O ícone de relógio do cabeçalho abre o histórico.

### Histórico (`/historico`)

Chips *Todos / Treinos / Exercícios*. *Todos* e *Treinos* mostram a mesma lista de sessões (treino, data, duração e calorias), **20 por página**, com rolagem infinita. Tocar numa sessão abre o detalhe: duração, volume, calorias, séries, e as séries agrupadas por exercício (nome, repetições, carga, dificuldade em estrelas e observação). *Exercícios* troca para o resumo: por exercício, quantas execuções e a melhor carga. O nome do exercício no histórico é o gravado **na hora do treino**.

## Perfil (`/perfil`)

Avatar com as iniciais, nome e o resumo *"Peso: 78 kg · Altura: 1,78 m"*. O menu:

| Item | O que faz |
|---|---|
| Meus dados | *Sheet* **somente leitura**: nome, e-mail, nascimento, sexo, peso e altura |
| Objetivos | Escolhe entre os cinco objetivos e grava (`PUT /cadastro/perfil`) |
| Biblioteca de exercícios | Abre a biblioteca |
| Minha evolução | Abre a Evolução |
| Fotos de progresso | *"Em breve"* |
| Medidas corporais | *Sheet* **somente leitura** com a medida mais recente de cada item e a variação |
| Sair | Confirma, avisa o servidor (logoff), apaga a sessão local e abre o login |

O botão de câmera do avatar também avisa *"Em breve"*. O rodapé mostra *"DS Fitness · v1.0.0"* (texto fixo na tela). Peso e altura não informados vêm **0** do servidor e aparecem como *"0 kg"* e *"0,00 m"* — a branch `fix/execucao-treino-perfil` os mostra como *"—"*.

## Contrato com a API

O app só conversa com `ds_fitnes_back`, sob o prefixo `/api/v1`. O endereço base vem de `--dart-define=API_BASE_URL=…` e, sem ele, assume a máquina de desenvolvimento (`http://localhost:5270`; `10.0.2.2` no emulador Android). No desenvolvimento o CORS da API é aberto, o que permite rodar o app na web.

### Endpoints consumidos

| Recurso | Método e caminho | Quem usa |
|---|---|---|
| Login | `POST /autenticacao/login` (`login`, `senha`) → `accessToken`, `refreshToken`, `accessTokenExpiraEm` | `AuthRepository` |
| Renovar sessão | `POST /autenticacao/login/refresh-token` (`refreshToken`) | `HttpManager` |
| Sair | `POST /autenticacao/login/logoff` (`refreshToken`, `encerrarTodasAsSessoes: false`) | `AuthRepository` |
| Criar conta | `POST /autenticacao/auto-cadastro` (`login`, `senha`) | `AuthRepository` |
| Perfil | `GET` e `PUT /cadastro/perfil` | `AuthRepository`, `PerfilRepository` |
| Medidas | `GET /cadastro/medidas` | `PerfilRepository` |
| Exercícios | `GET /cadastro/exercicios` (`?filtro=favoritos\|recentes`), `POST` | Biblioteca, fluxo de montar treino, formulário |
| Um exercício | `GET`, `PUT`, `DELETE /cadastro/exercicios/{id}` | Detalhe, formulário |
| Favoritar | `POST /cadastro/exercicios/{id}/favorito` | Biblioteca, detalhe |
| Registrar acesso | `POST /cadastro/exercicios/{id}/acesso` | Detalhe |
| Treinos | `GET`, `POST /treinos` | Lista, fluxo de montar |
| Um treino | `GET`, `PUT`, `DELETE /treinos/{id}` | Fluxo, execução, lista |
| Duplicar | `POST /treinos/{id}/duplicar` | Lista |
| Treino do dia | `GET /treinos/do-dia?diaSemana=` (1 = segunda … 7 = domingo) | Lista |
| Sessões | `GET /execucao/sessoes?pagina=&porPagina=` (resposta `{ data: [...] }`), `POST` | Histórico, execução |
| Cargas | `GET /execucao/cargas/{exercicioId}`, `POST /execucao/cargas` | Execução, detalhe |
| Estatísticas | `GET /execucao/estatisticas?periodo=` (`semana\|mes\|trimestre\|ano\|tudo`) | Evolução |
| Resumo por exercício | `GET /execucao/exercicios/resumo` | Histórico |
| Log de erros | `POST /log/erros` | `ErrorReporter` |

### Convenções do JSON

- **Ids.** A API usa id numérico; o app guarda `String` (`JsonUtils.idParaTexto`) e converte de volta com `JsonUtils.idDoServidor`. Um id que **não** é número (`novo_1`) é um item local, ainda não salvo: o repository o envia como "criar".
- **Datas.** Instante vai e volta em **UTC com `Z`**; data sem hora é `aaaa-mm-dd`.
- **Campo ausente** assume um padrão (`?? ''`, `inteiro(..., padrao:)`): o app continua funcionando com uma API mais antiga.
- **Slugs.** Grupos musculares e objetivos viajam como texto minúsculo sem acento (`peito`, `hipertrofia`), com `GrupoMuscular.fromSlug` / `ObjetivoTreino.fromSlug` e um padrão para o valor desconhecido.

**Exercício** — `id`, `nome`, `grupoPrimario`, `gruposSecundarios[]`, `instrucoes[]`, `equipamento`, `favorito`, `personalizado` (criado pelo usuário), `imagem` (a chave).

**Treino** — `id`, `usuarioId`, `nome`, `objetivo`, `descricao`, `diaSemana` (1–7, pode faltar em treino antigo), `criadoEm`, `exercicios[]`. Cada item: `id`, `exercicio` (o objeto acima), `ordem`, `series`, `repeticoes`, `cargaInicial`, `descansoSeg`, `observacao`. No `POST`/`PUT` o item leva só `exercicioId` no lugar do objeto, e `id` quando já existe.

**Sessão** — `id`, `treinoId`, `treinoNome`, `iniciadoEm`, `finalizadoEm`, `duracaoSeg`, `tempoDescansoSeg`, `volumeTotal`, `calorias`, `series[]` e `recordes[]` (os nomes dos exercícios em que um recorde pessoal foi batido). Volume, calorias e recordes são calculados pelo servidor.

**Evolução de carga** — `registros[]` (`exercicioId`, `data`, `carga`, `repeticoes`), em ordem cronológica, e o `recorde` (a maior carga). Exercício nunca treinado vem vazio.

### Imagens dos exercícios

A API devolve só a **chave** (`imagem`, ex.: `pectorals/barbell-bench-press`); não conhece caminho, pasta de assets nem formato. O app traduz a chave em arquivo ([02-arquitetura.md](02-arquitetura.md#imagens-dos-exercícios)). Se o catálogo da API ganhar um exercício com imagem, o GIF e a miniatura **precisam** estar em `assets/img/` **e** declarados no `pubspec.yaml`; sem isso, a tela cai na ilustração genérica ([07-engenharia.md](07-engenharia.md#imagens-dos-exercícios)).
