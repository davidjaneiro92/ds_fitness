# Engenharia

## Regras de desenvolvimento

Regras **obrigatórias** para qualquer código novo do app. A numeração (R1, R2…) é estável: os outros documentos e as revisões citam por ela.

### R1 — Dependência em um sentido só

`View → Controller → Repository → HttpManager`, sempre pela interface. A tela não conhece o repository; o controller não conhece o `Dio`; o repository não conhece tela. A tabela completa está em [02-arquitetura.md](02-arquitetura.md#regra-de-dependência).

### R2 — Toda peça atrás de uma interface

Controller e repository têm interface em `abstracts/`, registrada no `Binding` da rota; quem usa pede a interface (`Get.find<HomeControllerInterface>()`). Serviços globais seguem a mesma regra e são registrados no `main()`. Não há exceção hoje.

### R3 — A rede termina no `HttpManager`

Só `http_manager.dart`, `error_reporter.dart` (que usa um `Dio` próprio, de propósito) e `api_exception.dart` importam `package:dio`. O repository chama `HttpManagerInterface.restRequest` e recebe o corpo já decodificado (`Map`, `List` ou `null`). Para as chamadas que precisam do token, `autenticado: true` (o padrão); só login, cadastro e logoff passam `false`.

### R4 — Falha vira `ApiException`; a UI mostra a mensagem

- O repository deixa a exceção subir. Só captura quando "não existe" é um resultado válido (o 404 de `obterTreino` e `buscarExercicio` vira `null`).
- O controller captura, registra no `LogService` e mostra `AppSnackbar.erro(ErrorMessages.de(erro))`. Erro que não é `ApiException` vira o texto genérico — nunca a mensagem técnica.
- O `HttpManager` **nunca** navega nem abre diálogo. O que fazer quando a sessão expira é um callback registrado por quem conhece a tela (`aoExpirarSessao`).

```dart
try {
  treinos.assignAll(await _repository.listar());
} catch (erro, stackTrace) {
  _log.error('Falha ao carregar treinos', error: erro, stackTrace: stackTrace);
  AppSnackbar.erro(ErrorMessages.de(erro));
} finally {
  carregando.value = false;
}
```

### R5 — O servidor calcula

O app envia **fatos** e recebe **resultados**. Volume, calorias, recordes pessoais, totais e distribuição das estatísticas vêm da API; o app não refaz a conta, nem para "adiantar" a tela. Se um número da tela diverge do servidor, o servidor está certo.

### R6 — Nenhum literal solto

| O quê | De onde vem |
|---|---|
| Rota | `PagesRoutes.<rota>.path` |
| Endereço da API | `Endpoints.<recurso>` (ou o builder, como `Endpoints.treino(id)`) |
| Caminho de imagem | `AppAssets` |
| Cor | `ColorTokens` |
| Espaçamento, raio, altura | `SpacingTokens` |
| Estilo de texto | `TypographyTokens` |
| Argumento de rota | Classe em `route_args.dart` (nunca `Map<String, dynamic>`) |
| Número, data e duração formatados | `FormatServiceInterface` |

Exceções declaradas: `Colors.transparent`, e `Colors.white` no cartão que recebe o GIF (os GIFs têm fundo branco) e no confete.

### R7 — JSON só no modelo; id é `String`; data tem formato

- A conversão de JSON mora em `fromJson`/`toJson` do modelo e em `JsonUtils`. O repository monta o corpo da requisição; nenhum controller ou tela lê `Map`.
- A API usa id numérico; o app guarda `String` (`JsonUtils.idParaTexto`) e converte de volta com `JsonUtils.idDoServidor`. Um id que **não** é número (`novo_1`) é um item local, ainda não salvo: o repository o envia como "criar".
- Instante vai e volta em **UTC com `Z`** (`JsonUtils.instanteParaApi`; `JsonUtils.dataHora` devolve no fuso do aparelho). Data sem hora é `aaaa-mm-dd` (`JsonUtils.dataParaApi`).
- Campo ausente no JSON assume um padrão (`?? ''`, `inteiro(..., padrao:)`). O app continua funcionando com uma API mais antiga.

### R8 — Operação com várias etapas é um *Command*

Quando uma ação do usuário muda estado, grava e navega, ela vira uma classe que implementa `CommandInterface`, instanciada pelo controller, executada com `await command.execute()` e descartada. Hoje: `ConcluirSerieCommand`, `AlterarCargaCommand` e `FinalizarTreinoCommand` ([05-regras-de-negocio.md](05-regras-de-negocio.md#execução-do-treino)). Ação simples de uma linha continua no controller.

### R9 — Snackbar depois do `Get.back()`

No GetX 4.7.3, `Get.back()` com um snackbar aberto **só fecha o snackbar** e não navega. Quando a tela fecha e avisa, a ordem é:

```dart
Get.back<void>();
AppSnackbar.success('Treino salvo!');
```

### R10 — Estado reativo

- Leia o `Rx` **dentro** do `Obx`, nunca num `itemBuilder` solto.
- `Rx<T>` de modelo só notifica quando `==` muda: o modelo implementa `==` e `hashCode` por valor (como `Exercicio`).
- Declare o `Rx` na interface do controller, para a tela e os testes enxergarem a mesma coisa.

### R11 — Sem `print`

Registro de execução vai por `LogServiceInterface` (`debug`, `info`, `warning`, `error`). O lint `avoid_print` está ligado. Todo `error` também vai ao log remoto ([02-arquitetura.md](02-arquitetura.md#erros-e-observabilidade)): use `warning` para o que é esperado (rede fora, 404 válido) e `error` só para o que é defeito.

### R12 — Tela com trabalho em andamento intercepta o voltar

Execução do treino, formulário e revisão de treino usam `PopScope(canPop: false)` e pedem confirmação (`showAppConfirmDialog`) antes de descartar. Nunca deixe o gesto de voltar jogar fora uma sessão ou um rascunho.

### R13 — Idioma e codificação

- Texto para o usuário: português do Brasil, **com acento**.
- Identificador (variável, classe, arquivo): português **sem acento** para o domínio (`treino`, `exercicio`), inglês só para o que é do Flutter.
- Comentário `///` em ASCII, sem acento (a exceção é citar um texto da tela, como `"Tríceps"`): explica o **porquê** (regra, armadilha, decisão), não o que a linha faz.
- Arquivo em UTF-8, fim de linha LF.

### R14 — Regra de controller tem teste

Controller com regra de negócio (decisão, estado, ordem de chamadas) ganha teste com *fakes* das interfaces, sem biblioteca de mock. Hoje está coberto o rascunho do treino; a execução tem teste só na branch `fix/execucao-treino-perfil` e os demais controllers só carregam e repassam dados ([Testes e verificação](#testes-e-verificação)).

### R15 — O SDD acompanha o código

Mudou camada, rota, endpoint, contrato com a API, regra de negócio, dependência ou pendência: o documento correspondente muda na mesma entrega, e o [CHANGELOG.md](CHANGELOG.md) ganha uma entrada datada.

### R16 — Tela de fluxo compartilhado guarda o controller ao ser criada

Quando várias rotas dividem um controller que é **descartado no meio da navegação** (hoje só o `TreinoFormController`, que `encerrar()` remove do registro ao salvar, descartar ou iniciar), a tela **não** usa `GetView`. Ela é um `StatefulWidget` e pega a instância uma vez:

```dart
class _TreinoRevisarViewState extends State<TreinoRevisarView> {
  // Guardado ao criar a tela, e nao procurado a cada uso.
  final TreinoFormControllerInterface _controller = Get.find();
  …
}
```

Motivo: o `Get.find` do `GetView` roda a cada reconstrução, e a tela que está **saindo** ainda se reconstrói durante a animação — depois de o controller já ter sido removido. O resultado é *"… not found"* e a tela de erro do Flutter na transição (e erro no log remoto). Cobertura: `test/treino_fluxo_test.dart` reproduz o defeito se o `State` voltar a procurar a cada uso.

### R17 — Quem abre um fluxo e recarrega ao voltar depende de a rota base não ser trocada

`TreinosView` abre o fluxo com `await Get.toNamed(...)` e chama `carregar()` quando o `Future` termina — isto é, quando a **primeira** rota do fluxo sai da pilha. Num fluxo com várias telas, a base não pode ser substituída por `offNamed`/`offNamedUntil`; as demais voltam a ela com `Get.until(base)`. Ver a tabela da pilha em [06-fluxos.md](06-fluxos.md#a-pilha-de-rotas-em-cada-passo).

## Estilo e lint

`flutter analyze` deve terminar com **No issues found!**. O `analysis_options.yaml` parte de `flutter_lints` e liga:

| Regra | Efeito |
|---|---|
| `prefer_single_quotes` | Aspas simples |
| `always_declare_return_types` | Tipo de retorno explícito |
| `avoid_print` | Proíbe `print` |
| `sort_constructors_first` | Construtor antes dos membros |
| `prefer_const_constructors`, `prefer_const_declarations` | `const` sempre que possível |
| `unawaited_futures` | Todo `Future` solto passa por `unawaited(...)` |
| `always_put_required_named_parameters_first` | `required` primeiro |
| `directives_ordering` | Imports ordenados: `dart:`, `package:`, relativos |

Convenções do código, sem lint:

- **Tipo explícito** em variável local e em `Get.find()`: `final HomeControllerInterface controller = Get.find();`.
- **Import relativo** dentro de `lib/`.
- `try { … } catch (erro, stackTrace) { … } finally { carregando.value = false; }` em todo carregamento.
- `unawaited(carregar())` no `onInit`; `await` em tudo o mais.

## Como verificar as regras

| Regra | Comando (na raiz do repositório) | Esperado |
|---|---|---|
| R3 | `grep -rl "package:dio" lib` | Só `http_manager.dart`, `error_reporter.dart` e `api_exception.dart` |
| R6 | `grep -rnE "Color\(0x\|Colors\.[a-z]+" lib \| grep -v color_tokens` | Só `Colors.transparent`/`white` declarados |
| R6 | `grep -rnE "https?://" lib` | Só `app_environment.dart` e comentários |
| R11 | `grep -rnE "(^\|[^a-zA-Z_.])print\(" lib` | Nada |
| R1 | `grep -rnE "import .*repository" lib/src/core/features/*/view lib/src/components` | Nada |
| R16 | `grep -rn "GetView<TreinoFormControllerInterface>" lib` | Nada |
| Lint | `flutter analyze` | *No issues found!* |
| Testes | `flutter test --concurrency=1` | Tudo verde |

## Como criar uma feature

Passo a passo para uma tela nova que lê dados da API. O exemplo usa um recurso **hipotético**, `Meta` (`GET /api/v1/cadastro/metas`), que não existe: troque os nomes pelos da sua feature. Antes de começar, confirme no SDD da API (documento 13) que o endpoint existe e qual é o contrato.

### 1. O contrato com a API

1. **Endpoint** — acrescente o caminho em `constants/endpoints.dart`. Nunca monte URL fora dali.

   ```dart
   static const String metas = '$_prefixo/cadastro/metas';

   static String meta(String id) => '$metas/$id';
   ```

2. **Modelo** — `models/meta.dart`, imutável, com `fromJson`, `toJson` e `copyWith`. Use `JsonUtils` para id, número e data, e dê um padrão a cada campo opcional:

   ```dart
   class Meta {
     const Meta({required this.id, required this.titulo, this.concluida = false});

     factory Meta.fromJson(Map<String, dynamic> json) {
       return Meta(
         id: JsonUtils.idParaTexto(json['id']),
         titulo: json['titulo'] as String,
         concluida: json['concluida'] as bool? ?? false,
       );
     }

     final String id;
     final String titulo;
     final bool concluida;
   }
   ```

   Se o modelo vai dentro de um `Rx<Meta>`, implemente `==` e `hashCode` por valor (R10).

### 2. As interfaces

`core/features/metas/abstracts/` — o estado que a tela lê (`Rx`) é declarado **na interface**:

```dart
// metas_repository_interface.dart
abstract class MetasRepositoryInterface {
  Future<List<Meta>> listar();
}

// metas_controller_interface.dart
abstract class MetasControllerInterface {
  RxList<Meta> get metas;
  RxBool get carregando;

  Future<void> carregar();
}
```

### 3. O repository

`core/features/metas/repository/metas_repository.dart`. Só monta a chamada e converte o JSON; não captura erro, não navega, não mostra mensagem:

```dart
class MetasRepository implements MetasRepositoryInterface {
  final HttpManagerInterface _http = Get.find();

  @override
  Future<List<Meta>> listar() async {
    final dynamic corpo = await _http.restRequest(
      path: Endpoints.metas,
      method: HttpMethod.get,
    );
    return (corpo as List<dynamic>)
        .map((dynamic e) => Meta.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
```

Se "não existe" é um resultado válido (um `GET` por id, por exemplo), capture `ApiException` e devolva `null` quando `erro.ehNaoEncontrado`; senão, `rethrow`.

### 4. O controller

`core/features/metas/controller/metas_controller.dart`. Carrega no `onInit`, expõe `carregando` e trata o erro como em R4:

```dart
class MetasController extends GetxController implements MetasControllerInterface {
  final MetasRepositoryInterface _repository = Get.find();
  final LogServiceInterface _log = Get.find();

  @override
  final RxList<Meta> metas = <Meta>[].obs;

  @override
  final RxBool carregando = true.obs;

  @override
  void onInit() {
    super.onInit();
    unawaited(carregar());
  }

  @override
  Future<void> carregar() async {
    carregando.value = true;
    try {
      metas.assignAll(await _repository.listar());
    } catch (erro, stackTrace) {
      _log.error('Falha ao carregar metas', error: erro, stackTrace: stackTrace);
      AppSnackbar.erro(ErrorMessages.de(erro));
    } finally {
      carregando.value = false;
    }
  }
}
```

Duas chamadas independentes na mesma tela rodam juntas com um *record*: `final (a, b) = await (_repository.x(), _repository.y()).wait;`. Operação com várias etapas (mudar estado, gravar, navegar) vira um *command* em `controller/commands/` (R8).

### 5. O binding

`core/features/metas/binding/metas_binding.dart`:

```dart
class MetasBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MetasRepositoryInterface>(MetasRepository.new);
    Get.lazyPut<MetasControllerInterface>(MetasController.new);
  }
}
```

### 6. A view

`core/features/metas/view/metas_view.dart`. Tela comum estende `GetView<Interface>`, monta tudo com `AppScaffold` e componentes, e lê o `Rx` dentro do `Obx` (tela de **fluxo compartilhado** segue a R16):

```dart
class MetasView extends GetView<MetasControllerInterface> {
  const MetasView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      navbar: const AppNavbar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const PageHeader(title: 'Metas'),
          Expanded(
            child: Obx(() {
              if (controller.carregando.value) {
                return const Center(
                  child: CircularProgressIndicator(color: ColorTokens.accent),
                );
              }
              if (controller.metas.isEmpty) {
                return const EmptyState(
                  icon: Icons.flag_outlined,
                  title: 'Nenhuma meta ainda',
                );
              }
              return ListView.separated(
                itemCount: controller.metas.length,
                separatorBuilder: (BuildContext context, int index) =>
                    const Gap(SpacingTokens.sm),
                itemBuilder: (BuildContext context, int index) =>
                    AppCard(child: Text(controller.metas[index].titulo)),
              );
            }),
          ),
        ],
      ),
    );
  }
}
```

Os três estados de toda lista — **carregando**, **vazio** e **com dados** — são obrigatórios.

### 7. A rota

1. `enum/pages_routes.dart`: `metas('/metas')`.
2. `routes/app_pages.dart`: um `GetPage` com a view, o binding e a transição.
3. Se a tela recebe dados, uma classe `MetasArgs` em `routes/route_args.dart`, lida com `Get.arguments`.
4. Se a tela é uma aba, `enum/app_tab.dart`; se não, quem navega usa `Get.toNamed<void>(PagesRoutes.metas.path)`.

### 8. Os testes

Controller com regra de negócio ganha teste (R14), com um repository falso escrito à mão e os serviços de `test/support/fakes.dart`. No `setUp`, registre os fakes com `Get.put`; no `tearDown`, `Get.reset()`. Se o modelo lê o JSON, acrescente o caso em `test/models_json_test.dart`. Se a tela tem lógica de navegação, um teste de widget com `GetMaterialApp(getPages: AppPages.pages)` e o servidor falso, como em `test/treino_fluxo_test.dart`.

### 9. Fechando

- [ ] `flutter analyze` sem apontamentos
- [ ] `flutter test --concurrency=1` verde
- [ ] A tela foi vista rodando contra a API ([Conferindo na tela](#conferindo-na-tela))
- [ ] Nenhum erro novo na tabela `LogErro` depois do uso
- [ ] SDD atualizado: [03-estrutura-pastas.md](03-estrutura-pastas.md) (pasta nova), [05-regras-de-negocio.md](05-regras-de-negocio.md) (regra e endpoint), [06-fluxos.md](06-fluxos.md) (rota e fluxo), [08-auditoria.md](08-auditoria.md) (se mudou o que está pronto) e o [CHANGELOG.md](CHANGELOG.md)

## Imagens dos exercícios

O app traz os GIFs e as miniaturas **dentro do pacote**. A pasta `assets/img/` tem os 1.323 exercícios da base de origem (uns 400 MB: `gifs/` 370 MB, `imagens_estaticas/` 27 MB, `muscles/` 24 MB) e **só os exercícios do catálogo da API** são declarados no `pubspec.yaml` — hoje 55 GIFs e 55 miniaturas, uns 20 MB. Um item de pasta em `flutter: assets:` não é recursivo e, de qualquer forma, empacotar tudo estouraria o app.

**Para incluir outro exercício** (por exemplo, um que o catálogo da API ganhou):

1. A API precisa devolver a chave no campo `imagem` (`pasta/arquivo`, sem extensão: `pectorals/dumbbell-bench-press`). No servidor isso é uma migração do catálogo (SDD da API, documentos 12 e 13).
2. Confira que existem os dois arquivos: `assets/img/gifs/<chave>.gif` e `assets/img/imagens_estaticas/<chave>.thumb.webp`.
3. Declare **os dois**, um a um, em `pubspec.yaml` (`flutter: assets:`).
4. Reinicie o app (assets entram no pacote na compilação; no Flutter web não há hot reload para eles).
5. Abra o exercício na biblioteca: se aparecer a ilustração genérica em vez do GIF, o arquivo não existe ou não foi declarado.

Para gerar as linhas a partir de uma lista de chaves (uma por linha, vinda da API ou do banco):

```bash
while read -r chave; do
  echo "    - assets/img/gifs/$chave.gif"
  echo "    - assets/img/imagens_estaticas/$chave.thumb.webp"
done < chaves.txt
```

A pasta `assets/` **não está versionada** no repositório (421 MB): quem clonar precisa recebê-la à parte, ou o build falha ao encontrar os arquivos declarados. Ver [08-auditoria.md](08-auditoria.md#pendências-conhecidas).

## Dependências e versões

| Pacote | Versão | Observação |
|---|---|---|
| Flutter SDK | 3.24.5 (stable) | Versão fixa; não atualizar sem alinhar |
| Dart SDK | 3.5.4 | `pubspec.yaml` declara `sdk: ^3.5.4` |
| `get` | ^4.6.6 (resolve 4.7.3) | Estado, injeção e navegação. Atenção à R9 (snackbar e `Get.back()`) |
| `dio` | ^5.11.1 | Cliente HTTP; só o `HttpManager` e o `ErrorReporter` o usam |
| `hive` / `hive_flutter` | ^2.2.3 / ^1.1.0 | Armazenamento local. **Não cifrado** |
| `logger` | ^2.5.0 | Log no console; silencioso em release |
| `intl` | ^0.19.0 | Formatação pt-BR (`initializeDateFormatting('pt_BR')` no `main()`) |
| `flutter_lints` (dev) | ^4.0.0 | Regras base do lint |
| `flutter_test` (dev) | SDK | |

Removida: `cached_network_image` (as imagens deixaram de vir da rede em 2026-10-12). A configuração do `flutter_launcher_icons` está no `pubspec.yaml`, mas o **pacote não foi declarado** como dependência de desenvolvimento, então o ícone nativo nunca é gerado — ver [08-auditoria.md](08-auditoria.md#pendências-conhecidas).

## Ambiente

- **Endereço da API**: `--dart-define=API_BASE_URL=http://…`. Sem ele, `http://localhost:5270` (e `10.0.2.2` no emulador Android). Aparelho físico: `flutter run --dart-define=API_BASE_URL=http://192.168.0.10:5270` (mesma rede Wi-Fi do PC).
- **Versão enviada ao log**: `--dart-define=APP_VERSION=1.2.3` (padrão `1.0.0`).
- **Web em desenvolvimento**: `flutter run -d web-server --web-port 8087 --web-hostname localhost` (a configuração `ds-fitness-web` do `.claude/launch.json`). O CORS da API de desenvolvimento é aberto. Esse servidor **não tem hot reload**: depois de editar, reinicie.
- **Memória**: na máquina de desenvolvimento o limite de memória do Windows é apertado (arquivo de paginação de 2 GB), e `flutter test` em paralelo pode falhar com *Out of memory* na VM do Dart. Use `flutter test --concurrency=1` e mate processos `flutter_tester.exe` órfãos depois de uma queda.

## Testes e verificação

### O que os testes cobrem

`flutter test --concurrency=1` — **89 testes**, todos verdes na data desta revisão.

| Arquivo | Testes | O que cobre |
|---|---|---|
| `widget_test.dart` | 7 | `FormatService` (cronômetro, duração, descanso) e `Validators` (e-mail, senha, senha nova de 8, idade mínima de 16 anos) |
| `http_manager_test.dart` | 12 | Token no cabeçalho (e sem token nas chamadas públicas), resposta 204, renovação antes de vencer e depois do 401, uma renovação por vez, refresh recusado expira a sessão, falha de rede ao renovar não derruba a sessão, e a conversão em `ApiException` (400 de validação, 409, 404, sem rede) |
| `error_reporter_test.dart` | 5 | Envio com plataforma e versão, fila quando a API não responde, fila que sobrevive ao reinício, 4xx descartado, token enviado |
| `models_json_test.dart` | 11 | Leitura do JSON da API nos modelos: `Exercicio` (id numérico, `personalizado`, igualdade por valor para o `Rx`, chave `imagem`, grupos separados por ponto), `Treino` (itens com o exercício embutido, título sem dia), `TreinoExercicio.resumo`, `DiaSemana`, `Sessao`, `Usuario` (data de nascimento sem deslocar o dia) e `EvolucaoDeCarga` |
| `components_test.dart` | 12 | Busca sem caixa nem acento, `DiaSemanaChips`, `GrupoMuscularTile`, `ExercicioSelecaoTile`, contador do `AppTextField` |
| `exercise_illustration_test.dart` | 10 | Caminhos de `AppAssets`, `ExerciseIllustration` (GIF, miniatura parada, substituto), `AssetFirstFrame`, `GrupoMuscularImagem` |
| `estatisticas_view_test.dart` | 5 | Tela de Evolução: carregando, vazia, com dados, filtro de período |
| `treino_form_controller_test.dart` | 24 | O rascunho do treino: padrões, dia, grupos, exercício escolhido e configurado, editar preservando carga e observação, reordenar e remover, quando salvar vai ao servidor e quando não, treino que já existe |
| `treino_fluxo_test.dart` | 3 | O fluxo de montar o treino **com as rotas e as telas de verdade** (`AppPages.pages`) e um servidor falso: treino novo do formulário até salvar; treino existente + exercício + salvar recarrega a lista; sair sem mexer em nada |

Os testes de fluxo existem porque **bug de navegação não aparece em teste de controller**. Os dois defeitos de 2026-10-12 — *"not found"* ao salvar (R16) e a lista que mostrava o treino de antes de salvar (R17) — passaram por todos os testes de controller e foram reproduzidos por `treino_fluxo_test.dart` (desfazer cada correção faz o teste falhar).

**Não cobertos**: a execução do treino (há teste na branch `fix/execucao-treino-perfil`), `Auth`, `Home`, `Treinos`, `Biblioteca`, detalhe e formulário de exercício, histórico, estatísticas (só a tela) e perfil — controllers que só carregam e repassam dados.

**Teste sensível a tempo.** `error_reporter_test.dart` espera 50 ms de relógio real (`_aguardar`) pelo envio assíncrono, e falhou uma vez com a máquina saturada (o erro ainda estava na fila). Se voltar a falhar de forma intermitente, troque a espera fixa por uma consulta repetida até a condição valer, como `exercise_illustration_test.dart` faz com a decodificação do GIF.

### Conferindo na tela

Teste automatizado não prova que a tela funciona. Para uma mudança de interface:

1. Suba a API (`dotnet run` em `App.Api`, com o banco pelos *User Secrets*) e o app web (`ds-fitness-web`, porta 8087).
2. O app desenha num *canvas*: a árvore de acessibilidade só aparece com a acessibilidade ligada. Em geral se clica **por coordenada** e se digita depois de focar o campo. Emulação de dispositivo no painel de navegador distorce as capturas: prefira uma moldura de 390 px de largura (um `iframe`) servida pela própria pasta `web/`, que deve ser **apagada** depois.
3. Percorra o fluxo do início ao fim, incluindo o **voltar** e o **cancelar**, não só o caminho feliz.
4. **Consulte o log remoto depois do uso.** O `ErrorReporter` grava no banco da API as exceções que a tela esconde (a tela vermelha do Flutter, o texto em branco numa transição). Na base de autenticação (`ds_fitness_auth`):

   ```sql
   SELECT id, tipo, LEFT(mensagem, 200) AS mensagem, dataOcorrencia
     FROM LogErro ORDER BY id DESC LIMIT 20;
   ```

   Linha nova com *"Erro do Flutter: …"* é defeito até prova em contrário. Foi assim que o *"not found"* ao salvar apareceu, duas vezes, numa verificação que parecia ter passado.
5. Contas de teste ficam no banco de desenvolvimento (e-mails `…@dsfitness.test`); limpe-as depois ([08-auditoria.md](08-auditoria.md#pendências-conhecidas)).

## Débito técnico conhecido

| Item | Onde | Descrição |
|---|---|---|
| Armazenamento local não cifrado | `StorageService` (Hive) | Token de acesso, *refresh token* e dados do usuário ficam em texto. Para produção, usar armazenamento seguro da plataforma |
| Execução sem proteção de toque duplo | `ExecucaoController` | O avanço da série concluída não é idempotente e o envio não tem trava; um toque tardio pode pular um exercício ou gravar duas sessões. Corrigido em `fix/execucao-treino-perfil` |
| Execução fica em *carregando* se o treino não carrega | `ExecucaoController.carregarTreino` | Treino inexistente ou falha de rede deixam o indicador para sempre; só há aviso no log e o snackbar |
| Falha ao trocar a carga não é tratada | `ExecucaoController.alterarCarga` | `POST /execucao/cargas` que falha propaga sem mensagem |
| Retomada só restaura a posição | `ExecucaoController._retomarSnapshot` | Não volta as séries concluídas, o cronômetro nem as cargas; a marca não expira |
| Chaves de preferência sem uso | `StorageKeys.somDescanso`, `vibrarDescanso` | Existem no armazenamento; o descanso sempre vibra e toca o clique do sistema |
| Sem `flutter_localizations` | `main.dart` | O seletor de data e outros textos nativos do Material seguem o idioma padrão do framework |
| `flutter_launcher_icons` não declarado | `pubspec.yaml` | A configuração existe; sem o pacote em `dev_dependencies`, o ícone nativo nunca é gerado |
| `assets/` fora do versionamento | repositório | 421 MB; o build depende de arquivos que o `git clone` não traz |
| Texto fixo de versão | `perfil_view.dart` | *"DS Fitness · v1.0.0"* escrito na tela, não lido do pacote |
| Formatos escritos à mão | `Usuario.resumoFisico` | O resumo de peso e altura monta o texto no modelo, fora do `FormatService` |
| Teste sensível a tempo | `error_reporter_test.dart` | Ver acima |

## Backlog (funcionalidades futuras)

1. Login por Google, Apple e Facebook (os botões já estão na tela).
2. Recuperar a senha.
3. Fotos de progresso e foto do avatar.
4. Compartilhar o treino concluído.
5. Empacotar mais exercícios do catálogo e, se o catálogo crescer muito, baixar sob demanda em vez de empacotar.
6. Preferências de descanso (som e vibração) usando as chaves que já existem.
7. Imagem de fundo na tela de login: a de referência mostra a marca sobre uma imagem, e não há arquivo para ela.
8. Testes dos demais controllers e do fluxo de execução.

## Riscos

| Risco | Impacto | Mitigação |
|---|---|---|
| Flutter 3.24.5 e Dart 3.5.4 fixos | Pacotes recentes podem exigir SDK mais novo; `pub get` resolve e o erro só aparece no build | Conferir a faixa de SDK do pacote antes de atualizar; subir o SDK em uma entrega própria |
| GetX 4.7.3 | `Get.back()` com snackbar aberto não navega (R9); mudanças de comportamento entre versões | Versão fixa pelo `pubspec.lock`; testes de fluxo com as rotas reais |
| Tamanho de `assets/` | Clone lento, builds pesados se alguém declarar a pasta inteira | Declarar arquivo a arquivo e só o catálogo; considerar armazenamento próprio para os binários |
| Dependência total da API | Sem rede, só a interface abre | Aviso claro por `ApiException`; o log não depende de sessão e usa fila local |
| Sessão no Hive sem cifra | Vazamento de token em aparelho comprometido | Pendência de segurança acima |
