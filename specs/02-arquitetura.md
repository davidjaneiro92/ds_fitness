# Arquitetura

## Stack

- **Flutter** 3.24.5 (channel stable) / **Dart** 3.5.4 — versões fixas; não atualizar sem alinhar
- **GetX** (`package:get`, 4.7.3) — gerenciamento de estado, injeção de dependência e navegação, tudo pela mesma biblioteca
- **dio** (5.11.1) — cliente HTTP, encapsulado no `HttpManager`
- **hive** + **hive_flutter** — armazenamento local chave/valor (sessão, marca da execução em andamento, fila de erros)
- **logger** — log estruturado no console (silencioso em release)
- **intl** — números, datas e durações em pt-BR (`FormatService`)

Não há pacote de ícones, de fontes, de imagens de rede nem de gráficos: os ícones são do Material, e o corpo humano, os pictogramas, o gráfico de linha, o cronômetro circular e o confete são desenhados com `CustomPainter`. As únicas imagens do app são os arquivos de `assets/` ([Imagens dos exercícios](#imagens-dos-exercícios)).

## Padrão de organização: feature-first com MVC sobre GetX

Cada tela de negócio ganha uma pasta de feature, e a chamada de rede sempre desce pelas mesmas quatro camadas:

```
 ┌────────┐  Rx / Obx   ┌────────────┐   Future   ┌────────────┐  restRequest  ┌─────────────┐
 │  View  │ ◄─────────► │ Controller │ ─────────► │ Repository │ ────────────► │ HttpManager │ ──► Dio ──► API
 └────────┘             └────────────┘            └────────────┘               └─────────────┘
  widgets               estado (Rx),              monta a chamada,             token, renovação,
                        regra de tela,            lê e escreve JSON,           ApiException
                        navegação                 devolve modelos
```

Cada seta é uma **interface** (`abstracts/`): a tela fala com a interface do controller; o controller, com a do repository; o repository, com `HttpManagerInterface`. Quem liga a interface à implementação é o `Binding` da rota (ou o `main.dart`, para o que é global). Isso permite trocar qualquer peça por um *fake* nos testes, sem biblioteca de mock.

### Responsabilidade de cada camada

| Camada | Pasta | Responsabilidade | Não faz |
|---|---|---|---|
| **View** | `<feature>/view/` | Desenha. Lê `Rx` dentro de `Obx` e chama métodos do controller. | Chamar repository, montar URL, decidir regra de negócio |
| **Controller** | `<feature>/controller/` | Guarda o estado da tela (`Rx`), orquestra o repository, navega, mostra o resultado (`AppSnackbar`). | Importar `Dio`, montar URL, desenhar widget |
| **Command** | `<feature>/controller/commands/` | Uma operação de negócio com mais de um passo, de vida curta (`CommandInterface`). Hoje só a execução do treino usa. | Guardar estado entre execuções |
| **Repository** | `<feature>/repository/` | Monta a chamada (`Endpoints` + `HttpMethod` + corpo), converte JSON em modelo e devolve o modelo. | Navegar, mostrar mensagem, capturar erro genérico |
| **Model** | `models/` | Dado imutável com `fromJson`/`toJson` manuais e `copyWith`. | Chamar rede ou serviço |
| **Service** | `core/services/` | Capacidade transversal: HTTP, armazenamento, formatação, log, envio de erros. Cada uma tem interface em `core/abstracts/`. | Conhecer tela ou feature |
| **Component** | `components/` | Widget reutilizável do design system, sem conhecer nenhum controller. | Importar controller ou feature |

### Regra de dependência

| Camada | Pode depender de | Nunca depende de |
|---|---|---|
| View | Interface do controller, componentes, tokens, modelos, enums, `route_args`, `AppAssets`, `FormatServiceInterface` | Repository, `Dio`, implementação do controller |
| Controller | Interface do repository, `LogServiceInterface`, `StorageServiceInterface`, modelos, `AppSnackbar`, `route_args` | `Dio`, `Endpoints`, widget de tela |
| Repository | `HttpManagerInterface`, `Endpoints`, modelos, `JsonUtils`, `ApiException` | Controller, view, navegação, snackbar |
| `HttpManager` | `Dio`, `StorageServiceInterface`, `LogServiceInterface`, `Endpoints` (só o refresh) | Navegação, diálogo, qualquer widget |
| `ErrorReporter` | Um `Dio` próprio, `StorageServiceInterface`, `Endpoints.logErros` | `HttpManager` (o envio do log não pode renovar sessão nem gerar outro log) |
| Model | `JsonUtils`, enums | Serviços |
| Component | Tokens, modelos, enums, `AppAssets`, serviços por interface | Controller, feature |

Só três arquivos de `lib/` importam `package:dio`: `http_manager.dart`, `error_reporter.dart` e `api_exception.dart` (mais os dois testes que montam o adaptador falso). É uma regra verificável com `grep` ([07-engenharia.md](07-engenharia.md#como-verificar-as-regras)).

## Injeção de dependência

O GetX é o contêiner. Há dois escopos.

### Global (registrado no `main()`, `permanent: true`)

Em [main.dart](../lib/main.dart), nesta ordem — a ordem importa, cada registro usa o anterior:

| Registro (por interface) | Implementação | Observação |
|---|---|---|
| `StorageServiceInterface` | `StorageService` | Box Hive `ds_fitness_app`, aberta antes do `runApp` |
| `ErrorReporterInterface` | `ErrorReporter` | Fila de erros para o log da API |
| `LogServiceInterface` | `LogService` | Sobre o pacote `logger`; todo `error` também vai ao `ErrorReporter` |
| `FormatServiceInterface` | `FormatService` | Números, cargas, datas e durações em pt-BR |
| `HttpManagerInterface` | `HttpManager` | Dono dos tokens e da renovação |
| `AuthRepositoryInterface` | `AuthRepository` | |
| `AuthControllerInterface` | `AuthController` | Vive o app inteiro: guarda o usuário logado |

Esses são os **únicos** registros imediatos. O resto é preguiçoso.

### Por rota (`Binding`)

Cada rota em [app_pages.dart](../lib/src/routes/app_pages.dart) aponta para um `Binding` que registra repository e controller com `Get.lazyPut`: a instância nasce no primeiro `Get.find` e morre quando a rota sai da pilha.

```dart
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeControllerInterface>(HomeController.new);
  }
}
```

Casos que fogem do padrão:

| Caso | Por quê |
|---|---|
| `/login` e `/cadastro` sem binding | Usam o `AuthController` global |
| `/execucao/concluido` sem controller | Só mostra a sessão que veio nos argumentos |
| `/home` sem repository | O nome da saudação é o do usuário que o `AuthController` já tem |
| `TreinoFormController` e `TreinoFormRepository` **permanentes** (`Get.put(..., permanent: true)`, uma vez só, por `isRegistered`) | Cinco telas dividem o mesmo rascunho de treino: `/treinos/novo`, `/grupos`, `/exercicios`, `/exercicios/configurar` e `/treinos/revisar`. Só as duas rotas de entrada (`/treinos/novo` e `/treinos/revisar`) têm o `TreinoFormBinding`; as outras reaproveitam a instância. O controller sobrevive à navegação interna e é descartado por `encerrar()` ao sair do fluxo |
| `ExerciciosBinding` **não** registra o `TreinoFormController` | Ele já existe, porque o fluxo começou antes. Abrir `/exercicios` ou `/grupos` direto, sem passar pela entrada do fluxo, falharia no `Get.find` |

## Estado

- O estado de cada tela é um conjunto de `Rx` declarados **na interface do controller** (`RxBool carregando`, `RxList<Treino> treinos`, `Rxn<Treino> treinoDoDia`…). A view só conhece a interface.
- A view lê o `Rx` **dentro** do `Obx`. Lido dentro de um `itemBuilder`, ele fica fora do escopo reativo e a tela não atualiza.
- `Rx<T>` de um modelo só notifica quando o valor muda segundo o `==`. Por isso `Exercicio` implementa `==` e `hashCode` por valor: editar o nome precisa contar como mudança.
- O controller carrega os dados no `onInit` (`unawaited(carregar())`) e expõe `carregando`. Quando a tela precisa de duas chamadas, elas rodam juntas, com *records* do Dart 3:

  ```dart
  final (List<Treino> lista, Treino? doDia) = await (
    _repository.listar(),
    _repository.obterTreinoDoDia(),
  ).wait;
  ```

## Navegação

- **Rotas** — `PagesRoutes` (enum com o caminho). Nenhuma chamada usa string literal.
- **Mapa** — `AppPages.pages`: `GetPage` + `Binding` + transição (cupertino, 260 ms). A rota inicial é a splash.
- **Argumentos** — uma classe por rota em [route_args.dart](../lib/src/routes/route_args.dart) (`TreinoFormArgs`, `ExecucaoArgs`, `ExercicioDetalheArgs`…). `Map<String, dynamic>` solto é proibido.
- **Resultado** — uma tela pode devolver um valor a quem a abriu com `Get.back(result: …)`. O formulário de exercício devolve `ExercicioFormResultado` (`salvo` ou `excluido`) para a biblioteca e o detalhe se atualizarem.
- **Pilha** — a barra inferior (`AppBottomNav`) usa `Get.offAllNamed`: trocar de aba zera a pilha. Login, cadastro e logout também. Telas de detalhe empilham com `toNamed`; a execução substitui a tela anterior com `offNamed` (da revisão para a execução, e da execução para o resumo), para o *voltar* não reabrir o que acabou.
- **Abas** — `AppTab`: Início, Treinos, Evolução (as estatísticas) e Perfil. O histórico se abre pelo ícone de relógio da *Evolução*; a biblioteca de exercícios, pelo *Perfil*.

O mapa completo, rota por rota, está em [06-fluxos.md](06-fluxos.md#mapa-de-rotas).

### O fluxo de montar o treino: estado e pilha

É o único fluxo em que várias rotas dividem um estado que ainda não foi salvo, e por isso tem regras próprias.

1. **Um rascunho só.** O `TreinoFormController` guarda dia, nome, objetivo, descrição, os exercícios já configurados, os grupos escolhidos e a configuração em andamento. O repository permanente fala com a API. As regras de cada passo estão em [05-regras-de-negocio.md](05-regras-de-negocio.md#montar-um-treino).
2. **A pilha é disciplinada.** Treino novo: `/treinos/novo` é a base e fica até o fim; `grupos → exercícios → configurar` empilham; ao confirmar, `Get.offNamedUntil(revisar, até /treinos/novo)` tira os três e coloca a revisão no lugar (recriada a cada exercício acrescentado). Treino que já existe: a **revisão é a base** (aberta pela lista), e acrescentar ou editar um exercício volta a ela com `Get.until(revisar)` — ela não é recriada.
3. **Por que a base não pode ser trocada.** A lista de treinos abre o fluxo com `await Get.toNamed(...)` e recarrega quando o `Future` termina, ou seja, quando a **primeira** rota do fluxo sai da pilha. Se essa rota fosse substituída no meio do caminho, a lista recarregaria cedo demais e mostraria o treino de antes de salvar (bug de 2026-10-12, [CHANGELOG.md](CHANGELOG.md)).
4. **Sair encerra o fluxo.** Salvar, descartar e iniciar o treino chamam `encerrar()`, que remove o controller permanente do registro; depois a navegação sai do fluxo (`Get.until(/treinos)` se a lista o abriu, `offAllNamed(/treinos)` se a Início abriu).
5. **As telas guardam o controller ao serem criadas.** `encerrar()` roda com as telas ainda **animando a saída**, e elas se reconstroem nesse meio tempo (salvar acabou de mexer na lista). Com `GetView`, o `Get.find` a cada uso falharia (*"not found"*) e a tela de erro do Flutter apareceria na transição. Por isso as telas do fluxo são `StatefulWidget` com `final … _controller = Get.find();` no `State` (R16).

## Sessão e autenticação

Resumo; o contrato está em [05-regras-de-negocio.md](05-regras-de-negocio.md#acesso).

1. A splash espera 1,8 s, olha se existe token salvo e vai para `/home` ou `/login`. Não consulta o servidor.
2. O `HttpManager` envia o token, renova **antes** de vencer (margem de 30 s) e **depois** de um 401, repete a chamada uma vez, e garante uma renovação por vez.
3. Se o servidor recusa o *refresh token*, o `HttpManager` não navega: chama o callback que o `AuthController` registrou (`aoExpirarSessao`), que limpa o que é local, avisa o usuário e leva ao login.
4. Falha de rede ou 5xx na renovação **não** derruba a sessão — não se sabe se ela ainda vale.

## Erros e observabilidade

```
Dio ─► HttpManager ─► ApiException ─► Repository (deixa subir) ─► Controller ─► AppSnackbar.erro(ErrorMessages.de(e))
                 │                                                    │
                 └──► LogService.requisicaoFalhou                     └──► LogService.error
                                       └────────► ErrorReporter ◄───────────────┘
                                                      │  fila local (Hive) + Dio próprio
                                                      ▼
                                              POST /api/v1/log/erros  ──►  tabela LogErro
```

- O `HttpManager` converte tudo em `ApiException` (tipo, mensagem, status, erros por campo).
- O repository só captura quando "não existe" é um resultado válido (`obterTreino` e `buscarExercicio` devolvem `null` no 404).
- O controller captura, registra no `LogService` e mostra a mensagem. Erro que não é `ApiException` vira o texto genérico, sem detalhe técnico na tela.
- **Log remoto.** Todo `LogService.error` e toda requisição que falhou **de vez** (o 401 que a renovação resolve não conta) vão para o `ErrorReporter`, que guarda na fila, tenta enviar e, se a API não responde, deixa o erro na fila (no máximo 100; 30 s de espera depois de uma falha; recusa 4xx descarta o erro para não travar a fila). Ele usa um `Dio` próprio — o envio do log nunca renova sessão, nunca gera outro log e nunca atrasa a chamada que deu erro. Na abertura do app, `reenviarPendentes()` esvazia o que sobrou.
- **Erros globais.** `main()` liga `FlutterError.onError` (build, layout, gestos) e `PlatformDispatcher.onError` (código assíncrono sem tratamento) ao mesmo log. Exceção que o Flutter só mostra como tela vermelha ou texto em branco aparece, por isso, na tabela `LogErro` da API — foi assim que o bug de 2026-10-12 foi achado ([07-engenharia.md](07-engenharia.md#testes-e-verificação)).

## O servidor é a fonte da verdade

O app não calcula o que a API calcula. Ao finalizar um treino ele envia **o que aconteceu** (treino, instantes, durações e as séries concluídas). Volume, calorias e recordes pessoais voltam na sessão salva, e é essa que a tela de conclusão mostra. As estatísticas chegam somadas e agrupadas. O app só ajusta o que é de apresentação (rótulo de data, no máximo oito pontos no gráfico).

## Imagens dos exercícios

A API informa só uma **chave** por exercício (`Exercicio.imagem`, ex.: `pectorals/barbell-bench-press`: pasta do grupo e nome do arquivo, sem extensão). O app monta o caminho dos arquivos em [app_assets.dart](../lib/src/constants/app_assets.dart) — trocar de pasta ou de formato é mudar só esse arquivo:

| Uso | Caminho | Onde aparece |
|---|---|---|
| GIF animado | `assets/img/gifs/<chave>.gif` | Configurar exercício, execução, detalhe |
| Miniatura | `assets/img/imagens_estaticas/<chave>.thumb.webp` | Listas (seleção, revisão, biblioteca) |
| Grupo muscular | `assets/img/muscles/<slug>.png` | Grade de grupos, chips de músculo |

- A miniatura é uma animação curta de 128 px; as listas mostram só o **primeiro quadro** (`AssetFirstFrame`, decodificado uma vez e guardado em memória).
- As imagens dos grupos são grandes: entram com `cacheWidth`, e o grupo não escolhido aparece em tons de cinza (`ColorFilter`).
- **Só os exercícios do catálogo da API entram no pacote** (55 GIFs + 55 miniaturas, uns 20 MB), declarados um a um no `pubspec.yaml`. A pasta `assets/` completa tem 1.323 exercícios e passa de 400 MB — empacotar tudo estouraria o app. Como incluir outro exercício: [07-engenharia.md](07-engenharia.md#imagens-dos-exercícios).
- Sem chave (exercício criado pelo usuário) ou com arquivo ausente, aparece a ilustração genérica do grupo muscular.

## Decisões e porquês

| Decisão | Motivo |
|---|---|
| GetX para estado, injeção e navegação | Herdado do template e dominado pelo time; um pacote só resolve os três |
| Interface para todo controller e repository | Os testes trocam a peça por um *fake* escrito à mão; nada de pacote de mock |
| `HttpManager` é dono dos tokens | É ele quem os renova; separar o armazenamento da renovação abriria corrida entre duas renovações |
| Renovação em uma única chamada em voo | O *refresh token* é de uso único; duas renovações paralelas revogariam uma a outra |
| Serialização manual (`fromJson`/`toJson`) | Poucos modelos, contrato pequeno e legível; sem gerador de código no build |
| Hive para o armazenamento local | Stack do template. Não é cifrado — ver [08-auditoria.md](08-auditoria.md#pendências-conhecidas) |
| Imagens dentro do app, chave na API | O Google Drive limitava a cota por arquivo e derrubava as imagens; pelo pacote não há download, cota nem cache a gerenciar. A API não conhece caminho de arquivo, só a chave |
| Só o catálogo empacotado | 1.323 exercícios têm mais de 400 MB; o app usa 55 |
| Um `TreinoFormController` permanente para o fluxo todo | Cinco rotas dividem um rascunho que ainda não existe no servidor; preso a uma rota, sairia do registro quando ela deixasse a pilha |
| `ErrorReporter` com `Dio` próprio e fila local | O log não pode depender da sessão nem do `HttpManager` (seria um laço), e não deve se perder sem rede |
| Tema único escuro, sem `flutter_localizations` | Escopo do produto; os textos nativos do Material (como o seletor de data) seguem o idioma do framework — pendência em [08-auditoria.md](08-auditoria.md#pendências-conhecidas) |
