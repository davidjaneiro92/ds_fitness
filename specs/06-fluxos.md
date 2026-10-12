# Fluxos

## Mapa de rotas

| Rota (`PagesRoutes`) | Tela | Controller | Binding | Recebe | Aba acesa |
|---|---|---|---|---|---|
| `/splash` | `SplashView` | `SplashController` | `SplashBinding` | — | — |
| `/login` | `LoginView` | `AuthController` (global) | — | — | — |
| `/cadastro` | `CadastroView` | `AuthController` (global) | — | — | — |
| `/home` | `HomeView` | `HomeController` | `HomeBinding` | — | Início |
| `/treinos` | `TreinosView` | `TreinosController` | `TreinosBinding` | — | Treinos |
| `/treinos/novo` | `TreinoFormView` | `TreinoFormController` (permanente) | `TreinoFormBinding` | `TreinoFormArgs(partiuDaLista)` | — |
| `/treinos/revisar` | `TreinoRevisarView` | `TreinoFormController` (permanente) | `TreinoFormBinding` | `TreinoFormArgs(treinoId, partiuDaLista)` | — |
| `/grupos` | `GruposView` | `TreinoFormController` | — | — | — |
| `/exercicios` | `ExerciciosView` | `ExerciciosController` + `TreinoFormController` | `ExerciciosBinding` | — | — |
| `/exercicios/configurar` | `ExercicioConfigurarView` | `TreinoFormController` | — | — | — |
| `/execucao` | `ExecucaoView` | `ExecucaoController` | `ExecucaoBinding` | `ExecucaoArgs(treinoId)` | — |
| `/execucao/concluido` | `TreinoConcluidoView` | — | — | `ExecucaoConcluidoArgs(sessao)` | — |
| `/estatisticas` | `EstatisticasView` | `EstatisticasController` | `EstatisticasBinding` | — | Evolução |
| `/historico` | `HistoricoView` | `HistoricoController` | `HistoricoBinding` | — | Evolução |
| `/biblioteca` | `BibliotecaView` | `BibliotecaController` | `BibliotecaBinding` | — | Perfil |
| `/exercicio` | `ExercicioDetalheView` | `ExercicioDetalheController` | `ExercicioDetalheBinding` | `ExercicioDetalheArgs(exercicio)` | — |
| `/exercicio/novo` | `ExercicioFormView` | `ExercicioFormController` | `ExercicioFormBinding` | — | — |
| `/exercicio/editar` | `ExercicioFormView` | `ExercicioFormController` | `ExercicioFormBinding` | `ExercicioFormArgs(exercicio)` | — |
| `/perfil` | `PerfilView` | `PerfilController` | `PerfilBinding` | — | Perfil |

A coluna *Aba acesa* diz qual item da barra inferior fica aceso. Telas sem aba (formulários, fluxo de montar o treino, execução, detalhe) não mostram a barra.

```mermaid
flowchart TD
    splash["/splash"] -->|com token| home["/home"]
    splash -->|sem token| login["/login"]
    login -->|Entrar| home
    login -->|Cadastre-se| cadastro["/cadastro"]
    cadastro -->|conta criada| home
    home -->|Montar meu treino| novo["/treinos/novo"]
    home -->|Treinar| treinos["/treinos"]
    treinos -->|Novo treino| novo
    treinos -->|tocar no treino| revisar["/treinos/revisar"]
    novo --> grupos["/grupos"]
    grupos --> exercicios["/exercicios"]
    exercicios --> configurar["/exercicios/configurar"]
    configurar --> revisar
    revisar -->|Adicionar exercício| grupos
    revisar -->|Iniciar treino| execucao["/execucao"]
    execucao --> concluido["/execucao/concluido"]
    concluido -->|Voltar para home| home
    home --- treinos
    home --- estatisticas["/estatisticas"]
    home --- perfil["/perfil"]
    estatisticas -->|ícone de relógio| historico["/historico"]
    perfil -->|Biblioteca de exercícios| biblioteca["/biblioteca"]
    biblioteca --> detalhe["/exercicio"]
    biblioteca -->|botão +| exForm["/exercicio/novo"]
    detalhe -->|lápis| exEditar["/exercicio/editar"]
    perfil -->|Sair| login
```

As linhas sem seta (`---`) ligam as quatro **abas**: trocar de aba zera a pilha (`Get.offAllNamed`).

## Splash → Início ou Login

```mermaid
flowchart LR
    A[App abre] --> B[SplashView]
    B -->|aguarda 1,8 s| C{Existe token salvo?}
    C -->|sim| D["Get.offAllNamed /home"]
    C -->|não| E["Get.offAllNamed /login"]
```

A splash mostra a marca e um indicador de carregamento. Não consulta o servidor: se o token estiver vencido, a primeira chamada autenticada o renova ou, se o *refresh token* também venceu, leva ao login.

## Acesso

### Login

```mermaid
flowchart TD
    A[LoginView] -->|Entrar| B{Campos válidos?}
    B -->|não| C["Erro sob cada campo"]
    B -->|sim| D["AuthController.login"]
    D --> E["POST /autenticacao/login"]
    E -->|credencial recusada| F["Snackbar: E-mail ou senha inválidos"]
    E -->|ok| G["GET /cadastro/perfil"]
    G --> H["Grava a sessão e o usuário"]
    H --> I["Get.offAllNamed /home"]
    A -->|Google, Apple, Facebook| J["Snackbar: estará disponível em breve"]
    A -->|Esqueceu sua senha?| K["Snackbar: Em breve"]
    A -->|Cadastre-se| L["/cadastro"]
```

### Cadastro

```mermaid
sequenceDiagram
    participant U as CadastroView
    participant A as AuthRepository
    participant S as API
    U->>A: registrar(nome, e-mail, senha, nascimento, sexo)
    A->>S: POST /autenticacao/auto-cadastro (login, senha)
    S-->>A: conta criada
    A->>S: POST /autenticacao/login
    S-->>A: accessToken, refreshToken
    A->>S: PUT /cadastro/perfil (nome, nascimento, sexo)
    S-->>A: perfil
    A-->>U: usuário
    U->>U: Get.offAllNamed /home
```

E-mail repetido (409) volta com *"Já existe uma conta com este e-mail."*, sem criar nada.

## Montar um treino

O fluxo central do app. As cinco telas dividem **um** `TreinoFormController`, e a pilha de rotas segue uma disciplina que o diagrama abaixo e a tabela depois dele resumem.

```mermaid
flowchart TD
    A["Início: Montar meu treino<br/>ou Treinos: Novo treino"] --> B["1 · Novo treino<br/>dia, nome, objetivo, descrição"]
    B -->|Continuar, com nome| C["2 · Grupos musculares<br/>seleção múltipla"]
    C -->|Próximo, com ao menos um grupo| D["3 · Selecionar exercício<br/>busca e um exercício marcado"]
    D -->|Configurar exercício| E["4 · Configurar exercício<br/>séries, repetições, descanso"]
    E -->|Adicionar ao treino| F["5 · Revisar e salvar"]
    F -->|Adicionar exercício| C
    F -->|menu ⋮ Editar| E
    F -->|menu ⋮ Remover, confirmado| F
    F -->|lápis| G["Sheet: Dados do treino"]
    G --> F
    F -->|Salvar treino| H{"podeSalvar:<br/>nome e ao menos um exercício"}
    H -->|sim| I["POST /treinos"]
    I --> J["encerrar: descarta o rascunho"]
    J --> K["Lista de treinos<br/>recarrega, Treino salvo!"]
    B -->|voltar com algo preenchido| L["Descartar treino?"]
    L -->|Descartar| J
```

### A pilha de rotas em cada passo

| Passo | Treino novo | Treino que já existe |
|---|---|---|
| Abre | `[…, novo]` (de `/home` ou de `/treinos`) | `[treinos, revisar]` (a revisão é a base) |
| Grupos | `[…, novo, grupos]` | `[treinos, revisar, grupos]` |
| Exercícios | `[…, novo, grupos, exercicios]` | `[treinos, revisar, grupos, exercicios]` |
| Configurar | `[…, novo, grupos, exercicios, configurar]` | `[treinos, revisar, grupos, exercicios, configurar]` |
| Confirma | `offNamedUntil(revisar, até novo)` → `[…, novo, revisar]` | `Get.until(revisar)` → `[treinos, revisar]` |
| Salva | `Get.until(treinos)` (aberto pela lista) ou `offAllNamed(treinos)` (aberto pela Início) | `Get.until(treinos)` |
| Iniciar treino | — (o botão é *Salvar treino*) | `offNamed(execucao)` → `[treinos, execucao]` |

Duas consequências, ambas cobertas por teste ([07-engenharia.md](07-engenharia.md#testes-e-verificação)): a rota base **não é trocada** (a lista só recarrega quando a base sai da pilha), e `encerrar()` roda com as telas ainda animando a saída (por isso elas guardam o controller no `State`, R16).

### Treino que já existe

```mermaid
sequenceDiagram
    participant L as TreinosView
    participant R as Revisar (base do fluxo)
    participant F as TreinoFormController
    participant S as API
    L->>R: await toNamed(revisar, treinoId)
    R->>F: onInit lê TreinoFormArgs
    F->>S: GET /treinos/{id}
    S-->>F: treino com os exercícios
    Note over R,F: edita dados, remove, reordena ou acrescenta exercícios
    R->>F: salvar()
    alt nada mudou
        F-->>R: true, sem ir ao servidor
    else mudou
        F->>S: PUT /treinos/{id} (com o diaSemana)
        S-->>F: treino gravado, com os ids do servidor
    end
    R->>F: encerrar()
    R-->>L: Get.until(treinos)
    L->>S: GET /treinos e /treinos/do-dia (recarrega)
```

## Meus treinos

```mermaid
flowchart TD
    A[TreinosView] --> B["carregar: GET /treinos e /treinos/do-dia"]
    B --> C{Lista vazia?}
    C -->|sim| D["EmptyState: Criar treino"]
    C -->|não| E["Cartões, o treino do dia com borda verde"]
    E -->|tocar| F["/treinos/revisar"]
    E -->|pressão longa| G["Sheet: Duplicar ou Excluir"]
    G -->|Duplicar| H["POST /treinos/{id}/duplicar"]
    G -->|Excluir, confirmado| I["DELETE /treinos/{id}"]
    H --> B
    I --> B
    D --> J["/treinos/novo"]
    E -->|Novo treino| J
    F -->|fluxo termina| B
    J -->|fluxo termina| B
```

## Execução do treino

```mermaid
stateDiagram-v2
    [*] --> carregando
    carregando --> exercicio: treino carregado
    exercicio --> descanso: Realizado, não é a última série
    exercicio --> serieConcluida: Realizado, última série
    descanso --> exercicio: zerou ou pulou
    serieConcluida --> exercicio: próximo exercício
    serieConcluida --> concluido: último exercício, envia a sessão
    concluido --> [*]
```

Implementado em [ExecucaoController](../lib/src/core/features/execucao/controller/execucao_controller.dart) e nos três *commands*. A **regra de ouro** — o descanso nunca vem depois da última série de um exercício — é estrutural: só o `ConcluirSerieCommand` atribui `ExecucaoState.descanso`. Os cronômetros, a carga, a retomada e o que vai ao servidor estão em [05-regras-de-negócio.md](05-regras-de-negocio.md#execução-do-treino).

```mermaid
flowchart TD
    A["Revisão: Iniciar treino"] --> B["salvar se mudou, offNamed /execucao"]
    B --> C["GET /treinos/{id}"]
    C --> D["Cada exercício sem carga começa na última usada<br/>GET /execucao/cargas/{exercicioId}"]
    D --> E["Exercício: série 1"]
    E -->|Realizado| F{Última série?}
    F -->|não| G["Descanso com anel<br/>±15 s, pausa, pular"]
    G --> E
    F -->|sim| H["Celebração, 3 s"]
    H --> I{Último exercício?}
    I -->|não| J["Próximo exercício"]
    J --> E
    I -->|sim| K["POST /execucao/sessoes"]
    K -->|falhou| L["Snackbar de erro, tenta de novo no botão"]
    L --> H
    K -->|ok| M["/execucao/concluido: números e recordes"]
```

## Sessão e renovação do token

```mermaid
sequenceDiagram
    participant C as Controller
    participant H as HttpManager
    participant S as API
    C->>H: restRequest (autenticado)
    opt token vence em menos de 30 s
        H->>S: POST /autenticacao/login/refresh-token
        S-->>H: novos tokens
    end
    H->>S: chamada com Bearer
    alt resposta 401
        H->>S: POST refresh-token (uma por vez)
        alt refresh aceito
            H->>S: repete a chamada
            S-->>H: resposta
            H-->>C: corpo
        else refresh recusado (4xx)
            H-->>C: ApiException e aoExpirarSessao
            Note over C: AuthController limpa a sessão e abre o login
        end
    else outra resposta
        H-->>C: corpo ou ApiException
    end
```

Falha de rede ou 5xx **na renovação** não derruba a sessão: vira `ApiException` e o usuário continua logado.

## Biblioteca de exercícios

```mermaid
flowchart TD
    A["Perfil: Biblioteca de exercícios"] --> B["carregar: GET /cadastro/exercicios e ?filtro=recentes"]
    B --> C["Lista: busca, Todos/Favoritos/Recentes, grupo"]
    C -->|estrela| D["POST …/favorito"]
    C -->|tocar| E["/exercicio: detalhe"]
    E --> F["POST …/acesso: alimenta Recentes"]
    E -->|abas| G["Execução, Músculos, Histórico: GET /execucao/cargas/{id}"]
    E -->|lápis, só exercício próprio| H["/exercicio/editar"]
    C -->|botão +| I["/exercicio/novo"]
    H -->|salvo ou excluído| C
    I -->|salvo| C
```

Favoritos, grupo e busca são aplicados **no app**, sobre a lista completa; a ordem de *Recentes* vem da API. Ao voltar do detalhe ou do formulário a lista recarrega sem piscar.

## Evolução e histórico

```mermaid
flowchart TD
    A["Aba Evolução"] --> B["GET /execucao/estatisticas?periodo="]
    B --> C{Há sessões no período?}
    C -->|não| D["Sem dados no período"]
    C -->|sim| E["Quatro números, gráfico de volume, distribuição por grupo"]
    A -->|filtro de período| B
    A -->|ícone de relógio| F["/historico"]
    F --> G["Sessões, 20 por página, rolagem infinita"]
    G -->|tocar| H["Detalhe da sessão"]
    F -->|chip Exercícios| I["GET /execucao/exercicios/resumo"]
```

## Erros e log remoto

```mermaid
flowchart LR
    A["Exceção que nenhum catch pegou<br/>FlutterError.onError e PlatformDispatcher.onError"] --> L["LogService.error"]
    B["catch do controller"] --> L
    C["Requisição que falhou de vez"] --> R["LogService.requisicaoFalhou"]
    L --> E["ErrorReporter: fila local no Hive"]
    R --> E
    E -->|"POST /log/erros"| API[("tabela LogErro")]
    E -->|"sem rede ou 5xx"| Q["Fica na fila: 30 s de espera, até 100 erros"]
    Q --> E
    E -->|"4xx"| D["Descartado, para não travar a fila"]
```

O 401 que a renovação resolve **não** é erro e não vai ao log. Detalhes em [02-arquitetura.md](02-arquitetura.md#erros-e-observabilidade).

## Compartilhamento e recursos adiados

*Compartilhar* o treino concluído, *Fotos de progresso*, a câmera do avatar, *Esqueceu sua senha?* e o login por Google, Apple e Facebook mostram um aviso *"Em breve"*. Não há compartilhamento nem upload em lugar nenhum do app.
