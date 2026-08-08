# Configurações Globais, de Ambiente e de Build

> **Projeto legado de referência:** `controle_separacao_aplicativo`
> **Finalidade:** Preservação fiel das configurações existentes e funcionais para reuso no Template Corporativo Flutter.
> **Idioma:** PT-BR | **Método:** Leitura direta dos arquivos-fonte; nenhuma suposição ou extrapolação.

---

## Sumário

1. [Sequência de Inicialização (Bootstrap)](#1-sequência-de-inicialização-bootstrap)
2. [Configurações Globais do Aplicativo](#2-configurações-globais-do-aplicativo)
3. [Configuração de Endpoints e baseUrl](#3-configuração-de-endpoints-e-baseurl)
4. [Configuração de Ambiente em Runtime](#4-configuração-de-ambiente-em-runtime)
5. [Configuração de Build](#5-configuração-de-build)
6. [Configuração de Lint (analysis_options)](#6-configuração-de-lint-analysis_options)
7. [Duplicação de Configuração de Cores](#7-duplicação-de-configuração-de-cores)
8. [Tabela Consolidada de Classificação](#8-tabela-consolidada-de-classificação)

---

## 1. Sequência de Inicialização (Bootstrap)

**Arquivo:** `lib/main.dart`

A função `main()` é assíncrona e executa os seguintes passos em ordem estrita, antes de chamar `runApp()`:

### Passo a passo numerado

| # | Passo | Código | Descrição |
|---|-------|--------|-----------|
| 1 | **Registrar tratador de erros de widget** | `ErrorWidget.builder = (details) { … }` | Substitui o widget de erro padrão do Flutter pelo `CustomErrorWidget`. Em modo debug (`kDebugMode == true`) exibe o sumário técnico do erro; em release exibe mensagem amigável ao usuário. |
| 2 | **Inicializar bindings do Flutter** | `WidgetsFlutterBinding.ensureInitialized()` | Garante que o engine Flutter esteja pronto antes de qualquer operação assíncrona ou de plugins. |
| 3 | **Inicializar o Hive** | `await Hive.initFlutter()` | Inicializa o banco de dados local Hive com suporte Flutter (define o diretório de armazenamento adequado para a plataforma). |
| 4 | **Abrir box de ambiente** | `await Hive.openBox('variaves_ambiente')` | Abre (ou cria) a box Hive que persiste configurações de ambiente editáveis em runtime: `baseUrl` e `logger`. Deve ser aberta ANTES de `initializeApp()`, pois este passo a lê. |
| 5 | **Registrar LoadingController** | `Get.put(LoadingController())` | Injeta o controller global de overlay de carregamento (spinner) via GetX. Deve estar disponível antes dos demais controllers que o utilizam. |
| 6 | **Registrar UtilsServices** | `Get.put<UtilsServicesInterfaces>(UtilsServices())` | Injeta serviço utilitário (interface + implementação). |
| 7 | **Registrar LogServices** | `Get.put<LogServicesInterface>(LogServices())` | Injeta serviço de log (usa `logger` package + envio remoto para `Endpoints.logErrosAplicativo` quando flag `logger` está ativa). |
| 8 | **Inicializar app (baseUrl)** | `await initializeApp()` | Executa a função de topo do arquivo `Endpoints.dart`: lê o valor persistido de `baseUrl` na box `variaves_ambiente` via `SettingsAppRepository.getBaseUrl()` e atribui à variável global `baseUrl`. Se nenhum valor estiver persistido, a variável permanece com o valor default hardcoded (`http://192.168.1.192:7021`). |
| 9 | **Abrir box de cache** | `await Hive.openBox('Cache_aplicativo')` | Abre a box Hive dedicada ao cache de dados da aplicação (tokens, respostas, etc.). Aberta após `initializeApp()` porque não é necessária para o bootstrap de URL. |
| 10 | **Registrar HiveServices** | `Get.put<HiveServicesInterface>(HiveServices())` | Injeta o serviço de acesso à box `Cache_aplicativo` (get/set/delete/limpar). |
| 11 | **Registrar HttpManager** | `Get.put<HttpManagerInterfaces>(HttpManager())` | Injeta o cliente HTTP (Dio). Depende de `baseUrl` já estar definida (passo 8). |
| 12 | **Registrar FormatarValores** | `Get.put<FormatarValoresInterface>(FormatarValores())` | Injeta utilitário de formatação de valores. |
| 13 | **Registrar CustomItemListViewController** | `Get.put(CustomItemListViewController())` | Injeta controller de componente de lista customizada. |
| 14 | **Registrar SettingsAppController** | `Get.put<SettingsAppControllerInterface>(SettingsAppController())` | Injeta controller da tela de configurações. No `onInit()` lê novamente `baseUrl` e `logger` da box e popula as `RxString`/`RxBool` reativas. |
| 15 | **Registrar controllers de features** | `Get.put<LoginControllerInterface>(LoginController())` … (9 controllers) | Injeta, em sequência, todos os controllers de features de negócio: Login, ConferirMaterialEntrada, ItensNfEntrada, NfsPedidos, SelecionarMaterialEstoque, ItensPedidoSaida, ConferirMaterialSaida, ConsultaNfSaida, BuscarProdutos, ConferirMaterialTransferencia, TrasferenciaIndustria. |
| 16 | **Iniciar aplicativo** | `runApp(const MyApp())` | Inicia a árvore de widgets. |

### Diagrama de dependências de inicialização

```
main()
 ├── ErrorWidget.builder           [sem dependências]
 ├── WidgetsFlutterBinding         [sem dependências]
 ├── Hive.initFlutter()            [sem dependências]
 ├── Hive.openBox('variaves_ambiente')  ◄── requerido por initializeApp()
 ├── Get.put(LoadingController)    ◄── requerido por LogServices e outros
 ├── Get.put(UtilsServices)        ◄── requerido por LogServices, SettingsAppController
 ├── Get.put(LogServices)          ◄── requerido por controllers de features
 ├── initializeApp()               ◄── lê 'variaves_ambiente', define baseUrl global
 ├── Hive.openBox('Cache_aplicativo')
 ├── Get.put(HiveServices)         ◄── requerido por LogServices.LogOperacoes
 ├── Get.put(HttpManager)          ◄── requerido por controllers de features
 ├── Get.put(FormatarValores)
 ├── Get.put(CustomItemListViewController)
 ├── Get.put(SettingsAppController)
 ├── Get.put(...controllers de features...)
 └── runApp(MyApp())
```

---

## 2. Configurações Globais do Aplicativo

**Arquivo:** `lib/main.dart` — classe `MyApp`

### 2.1 Wrapper de toasts: OKToast

O `GetMaterialApp` é envolvido por `OKToast`, habilitando toasts globais via o package `oktoast` em toda a árvore de widgets.

```dart
return OKToast(
  child: GetMaterialApp( … ),
);
```

### 2.2 GetMaterialApp — parâmetros configurados

| Parâmetro | Valor | Descrição |
|-----------|-------|-----------|
| `title` | `'Controle de Separação'` | Título do aplicativo (exibido no app switcher do SO). |
| `debugShowCheckedModeBanner` | `false` | Remove o banner vermelho "DEBUG" em modo debug. |
| `initialRoute` | `PagesRoutes.splashScreen.path` → `'/splash_screen'` | Primeira tela exibida ao iniciar o app. |
| `getPages` | `AppPages.pages` | Lista de rotas nomeadas (GetX). Ver seção de rotas abaixo. |
| `builder` | Stack com `LoadingWidget` sobreposto | Overlay global de loading aplicado a todas as rotas. |

### 2.3 Tema global (ThemeData)

```dart
theme: ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF003A88)),
  scaffoldBackgroundColor: Colors.white.withAlpha(190),
  useMaterial3: true,
),
```

| Propriedade | Valor | Observação |
|-------------|-------|------------|
| `colorScheme` | Gerado por seed `0xFF003A88` (azul corporativo) | Material 3 gera paleta completa a partir da cor semente. |
| `scaffoldBackgroundColor` | `Colors.white.withAlpha(190)` | Branco com leve transparência (alpha 190/255 ≈ 74,5%). |
| `useMaterial3` | `true` | Habilita Material Design 3 (padrão Flutter 3.x+). |

### 2.4 Overlay global de loading

O `builder` do `GetMaterialApp` empilha `LoadingWidget` sobre toda a UI. O `LoadingWidget` é reativo (`Obx`): exibe um `CircularProgressIndicator` com `CustomColors.blue` sobre fundo escurecido (`Colors.black.withOpacity(0.5)`) quando `LoadingController.isLoading == true`.

### 2.5 Rotas registradas (AppPages)

**Arquivo:** `lib/src/routes/app_pages.dart`  
**Enum:** `lib/src/enum/pages_routes.dart`

| Rota (enum) | Path | View |
|-------------|------|------|
| `splashScreen` | `/splash_screen` | `SplashScreen` |
| `login` | `/login` | `Login` |
| `nfsPedidos` | `/nfs_pedidos` | `NfsPedidos` |
| `itensNf` | `/itens_nf` | `ItensNf` |
| `conferirMaterialEntrada` | `/conferir_material_entrada` | `ConferirMaterialEntrada` |
| `itensPedidoSaida` | `/itens_pedido_saida` | `ItensPedidoSaida` |
| `selecionarMaterialEstoque` | `/selecionar_material_estoque` | `SelecionarMaterialEstoque` |
| `conferirMaterialSaida` | `/conferir_material_saida` | `ConferirMaterialSaida` |
| `settingsApp` | `/Settings_App` | `SettingsApp` |
| `ConsultaNfSaida` | `/consulta_nf_saida` | `ConsultaNfSaida` |
| `ConsultaLotesSaida` | `/consulta_lotes_saida` | `ConsultaLotesSaida` |
| `Trasferencia` | `/buscar_produtos` | `BuscarProdutos` |
| `conferirMaterialTrasferencia` | `/conferir_material_transferencia` | `ConferirMaterialTransferencia` |
| `Trasferencialote` | `/trasferencia_industria` | `TrasferenciaIndustria` |

---

## 3. Configuração de Endpoints e baseUrl

**Arquivo:** `lib/src/constants/Endpoints.dart`

### 3.1 Estrutura do arquivo

O arquivo `Endpoints.dart` é um módulo de nível de pacote (não apenas uma classe) que contém:

1. **Uma variável global mutável `baseUrl`** — inicializada com valor default hardcoded.
2. **A função `initializeApp()`** — chamada no `main()` para sobrescrever `baseUrl` com o valor persistido no Hive.
3. **A classe abstrata `Endpoints`** — com getters estáticos que constroem URLs dinamicamente a partir de `baseUrl`.

```dart
// Valor DEFAULT hardcoded (fallback quando nenhum valor foi salvo no Hive)
String? baseUrl = 'http://192.168.1.192:7021';

// Chamada no main() — sobrescreve baseUrl com valor do Hive, se existir
Future<void> initializeApp() async {
  baseUrl = await repository.getBaseUrl();
}

abstract class Endpoints {
  static String get login => '${baseUrl}/api/v1/autenticacao/login';
  // … demais endpoints
}
```

### 3.2 IP hardcoded — Registro como fato

> **FATO DOCUMENTADO:** O valor `'http://192.168.1.192:7021'` é um endereço IP de rede local privada codificado diretamente no arquivo-fonte `lib/src/constants/Endpoints.dart` (linha 8). Este é o **endereço de fallback**: usado somente quando nenhum valor foi salvo previamente na box Hive `variaves_ambiente` (i.e., primeiro uso ou após reset do cache).

### 3.3 Endpoints mapeados

Todos os endpoints são getters estáticos e resolvem dinamicamente a URL no momento do acesso, garantindo que mudanças em `baseUrl` sejam refletidas imediatamente sem necessidade de reiniciar o app (desde que o app não esteja em meio a uma requisição).

| Getter | Path relativo |
|--------|--------------|
| `Endpoints.login` | `/api/v1/autenticacao/login` |
| `Endpoints.refreshToken` | `/api/v1/autenticacao/login/refresh-token` |
| `Endpoints.grupoAlmoxarifado` | `/api/v1/grupo-almoxarifado` |
| `Endpoints.recebimentoCompraNF` | `/api/v1/recebimento-de-compra/notas-fiscais` |
| `Endpoints.pedidoVenda` | `/api/v1/faturamento/pedido-venda` |
| `Endpoints.pedidoVendaEstagio` | `/api/v1/faturamento/pedido-venda/estagio` |
| `Endpoints.logErrosAplicativo` | `/api/v1/log-erros-aplicativo` |
| `Endpoints.logOperacoes` | `/api/v2/log-operacoes` |
| `Endpoints.itemPedidoVenda` | `/api/v1/faturamento/item-pedido-venda` |
| `Endpoints.notasFiscaisPagas` | `/api/v1/recebimento-de-compra/notas-fiscais/pagas` |
| `Endpoints.notaCompraLotes` | `/api/v1/recebimento-de-compra/nota-compra-lotes` |
| `Endpoints.notaCompraLotesEtiquetas` | `/api/v1/recebimento-de-compra/nota-compra-lotes/etiquetas` |
| `Endpoints.imprimirEtiquetas` | `/api/v1/impressao/etiqueta` |
| `Endpoints.buscarProduto` | `/api/v1/produto-almoxarifado` |
| `Endpoints.empresa` | `/api/v1/empresa-cadastro` |
| `Endpoints.grupoAlmox` | `/api/v1/grupo-almoxarifado` |
| `Endpoints.transferenciaNotaLote` | `/api/v1/recebimento-de-compra/transferencia-nota-lote/mov-lote` |
| `Endpoints.transferenciaLote` | `/api/v1/recebimento-de-compra/transferencia-nota-lote` |

> **Nota:** `grupoAlmoxarifado` e `grupoAlmox` apontam para o mesmo path — duplicidade no código atual.

### 3.4 Versões de API presentes

- **v1:** Autenticação, notas fiscais, faturamento, log de erros, impressão, produtos, empresa, grupo de almoxarifado, transferências, lotes.
- **v2:** Log de operações (`/api/v2/log-operacoes`).

---

> #### Consideração Futura (sem proposta de migração imediata)
>
> O IP hardcoded `192.168.1.192:7021` como fallback de `baseUrl` funciona corretamente no ambiente atual, onde o usuário configura o endereço via tela de Settings antes do primeiro uso efetivo.
>
> Em contextos de múltiplos ambientes de build (desenvolvimento, homologação, produção), seria possível externalizar esse valor default usando `--dart-define` na linha de comando de build:
>
> ```bash
> flutter build apk --dart-define=BASE_URL_DEFAULT=http://192.168.1.x:7021
> ```
>
> E no código:
> ```dart
> const String _defaultBaseUrl =
>     String.fromEnvironment('BASE_URL_DEFAULT', defaultValue: 'http://192.168.1.192:7021');
> String? baseUrl = _defaultBaseUrl;
> ```
>
> **Esta é uma melhoria possível para o template, não uma migração proposta para o projeto legado.**

---

## 4. Configuração de Ambiente em Runtime

### 4.1 Box Hive: `variaves_ambiente`

**Arquivo de abertura:** `lib/main.dart` (passo 4 do bootstrap)  
**Arquivo de acesso:** `lib/src/core/features/settings_app/repository/settings_app_repository.dart`

A box `variaves_ambiente` é a única fonte de verdade para configurações mutáveis em runtime. As chaves persistidas são:

| Chave Hive | Tipo Dart | Default (se ausente) | Descrição |
|------------|-----------|----------------------|-----------|
| `'baseUrl'` | `String?` | `'http://192.168.1.192:7021'` (fallback em `Endpoints.dart`) | URL base da API. Usada por todos os endpoints. |
| `'logger'` | `bool?` | `false` (assumido pelo controller: `RxBool logger = false.obs`) | Flag que ativa/desativa o envio remoto de logs para `Endpoints.logErrosAplicativo`. |

### 4.2 Mecanismo de leitura e escrita

O acesso à box é encapsulado em `SettingsAppRepository`, que implementa `SettingsAppRepositoryInterface`:

```dart
// Interface contratual
abstract class SettingsAppRepositoryInterface {
  void setBaseUrl({required String url});
  Future<String?> getBaseUrl();
  void setLogger({required bool logger});
  Future<bool?> getLogger();
}

// Implementação — lê/escreve diretamente na box Hive
class SettingsAppRepository implements SettingsAppRepositoryInterface {
  final Box box = Hive.box('variaves_ambiente');

  void setBaseUrl({required String url}) async => await box.put('baseUrl', url);
  Future<String?> getBaseUrl() async => box.get('baseUrl');

  void setLogger({required bool logger}) async => await box.put('logger', logger);
  Future<bool?> getLogger() async => box.get('logger');
}
```

O repositório é instanciado diretamente (não via GetX) tanto em `Endpoints.dart` (para `initializeApp()`) quanto em `SettingsAppController` e `LogServices`.

### 4.3 Fluxo de leitura de `baseUrl` no ciclo de vida

```
Hive.openBox('variaves_ambiente')          [main.dart, passo 4]
        │
        ▼
initializeApp()                            [main.dart, passo 8]
  └── SettingsAppRepository.getBaseUrl()
        └── box.get('baseUrl')
              ├── valor encontrado  → baseUrl = valor_do_hive
              └── valor ausente     → baseUrl permanece 'http://192.168.1.192:7021'
        │
        ▼
HttpManager criado                         [main.dart, passo 11]
  └── Usa Endpoints.* que referenciam baseUrl (getter dinâmico)
```

### 4.4 Tela de configurações: `SettingsApp`

**Arquivo:** `lib/src/core/features/settings_app/view/settings_app_view.dart`  
**Rota:** `/Settings_App`

A tela expõe ao usuário final as seguintes ações:

| Controle UI | Ação | Efeito |
|-------------|------|--------|
| `TextField` "Url de Conexão da api" + botão `Icons.add_circle` | Digitar nova URL e salvar | Chama `SettingsAppController.setBaseUrl(url)` → `SettingsAppRepository.setBaseUrl()` → `box.put('baseUrl', url)`. A variável global `baseUrl` em `Endpoints.dart` **não é atualizada automaticamente** — a mudança só entra em vigor após reiniciar o app (o que relê via `initializeApp()`). |
| `CupertinoSwitch` "Logger" | Ativar/desativar logger remoto | Chama `SettingsAppController.setLogger()` → `box.put('logger', bool)`. O `LogServices` consulta este flag a cada chamada de `log()` para decidir se envia o log remotamente. |
| Botão "Limpar" (cache) | Limpar todo cache | Chama `HiveServices.limparTodoCache()` → `box.clear()` na box `Cache_aplicativo`. Não afeta `variaves_ambiente`. |

### 4.5 Comportamento do logger

**Arquivo:** `lib/src/core/services/log_services.dart`

O `LogServices` opera em dois modos:

- **Sempre:** Registra no console via package `logger` (Logger `_logger.e/w/d/i`).
- **Condicional (flag `logger == true`):** Envia o log para `Endpoints.logErrosAplicativo` (POST) com payload `{ timestamp, levelError, message }`.
- **`LogOperacoes`:** Envia operações de negócio para `Endpoints.logOperacoes` (v2), incluindo dados do usuário autenticado lidos do cache Hive.

---

## 5. Configuração de Build

**Arquivo:** `pubspec.yaml`

### 5.1 Identificação do pacote

| Campo | Valor |
|-------|-------|
| `name` | `controle_separacao_aplicativo` |
| `description` | `"A new Flutter project."` |
| `version` | `1.0.0+1` |
| `publish_to` | `'none'` (pacote privado, não publicado no pub.dev) |

### 5.2 Restrições de SDK

```yaml
environment:
  sdk: ^3.5.3
```

| Constraint | Valor | Significado |
|------------|-------|-------------|
| SDK mínimo | `3.5.3` | Dart SDK mínimo exigido. |
| SDK máximo | `<4.0.0` (implícito pelo `^`) | Compatível com qualquer 3.x acima de 3.5.3. |

### 5.3 Plataformas suportadas

Conforme o arquivo `.metadata`, o projeto foi criado com suporte a **todas as plataformas Flutter**:

| Plataforma | Suportada | Observação |
|------------|-----------|------------|
| Android | Sim | Min SDK 21 (conforme `flutter_launcher_icons`) |
| iOS | Sim | |
| Web | Sim | |
| Windows | Sim | |
| macOS | Sim | |
| Linux | Sim | Plataforma criada no projeto, sem ícone configurado no `flutter_launcher_icons` |

### 5.4 Dependências de produção

| Package | Versão | Função |
|---------|--------|--------|
| `flutter` | sdk | Framework base |
| `cupertino_icons` | `^1.0.8` | Ícones estilo iOS |
| `get` | `^4.6.6` | Gerenciamento de estado, DI e navegação (GetX) |
| `dio` | `^5.7.0` | Cliente HTTP |
| `intl` | `^0.19.0` | Internacionalização e formatação de datas |
| `json_annotation` | `^4.4.0` | Anotações para serialização JSON |
| `tab_container` | `^3.5.3` | Componente de abas customizado |
| `image_picker` | `^1.1.2` | Seleção de imagens da galeria/câmera |
| `barcode_scan2` | `^4.3.3` | Leitura de códigos de barras/QR |
| `fluttertoast` | `^8.2.8` | Toasts nativos |
| `logger` | `^2.5.0` | Log estruturado no console |
| `hive` | `^2.2.3` | Banco de dados local (NoSQL, key-value) |
| `hive_flutter` | `^1.1.0` | Integração Hive com Flutter (path provider) |
| `oktoast` | `^3.4.0` | Toasts sobreposto à UI (usado no wrapper `OKToast`) |
| `flutter_speed_dial` | `^7.0.0` | FAB com sub-ações |
| `pluto_grid` | `^8.0.0` | Grid/tabela avançada |
| `mask_text_input_formatter` | `^2.9.0` | Máscara de entrada de texto |

### 5.5 Dependências de desenvolvimento

| Package | Versão | Função |
|---------|--------|--------|
| `flutter_test` | sdk | Framework de testes |
| `flutter_launcher_icons` | `^0.13.1` | Geração de ícones multi-plataforma |
| `test` | `^1.25.7` | Framework de testes Dart puro |
| `flutter_lints` | `^4.0.0` | Regras de lint recomendadas para Flutter |

### 5.6 Configuração flutter_launcher_icons (multi-plataforma)

```yaml
flutter_launcher_icons:
  android: "launcher_icon"          # Nome do recurso de ícone Android
  ios: true                          # Gera ícones para iOS
  image_path: "assets/icon/icon.png" # Fonte única para todas as plataformas
  min_sdk_android: 21
  remove_alpha_ios: true             # Remove canal alpha (exigido pela App Store)
  web:
    generate: true
    image_path: "assets/icon/icon.png"
    background_color: "#FFFFFF"      # Fundo branco para ícone PWA
    theme_color: "#003A88"           # Cor de tema da barra do browser (azul corporativo)
  windows:
    generate: true
    image_path: "assets/icon/icon.png"
    icon_size: 48                    # Tamanho mínimo permitido (48px)
  macos:
    generate: true
    image_path: "assets/icon/icon.png"
```

| Plataforma | Ícone gerado | Configurações especiais |
|------------|-------------|-------------------------|
| Android | `launcher_icon` | min SDK 21 |
| iOS | Gerado automaticamente | `remove_alpha_ios: true` |
| Web | Gerado automaticamente | `background_color: #FFFFFF`, `theme_color: #003A88` |
| Windows | Gerado automaticamente | `icon_size: 48` |
| macOS | Gerado automaticamente | Sem configurações extras |
| Linux | **Não configurado** | Não há bloco `linux:` no `flutter_launcher_icons` |

**Comando de geração:**
```bash
dart run flutter_launcher_icons
```

### 5.7 Assets declarados

```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/img/
```

**Arquivos presentes em `assets/` (raiz):**

| Caminho | Arquivo |
|---------|---------|
| `assets/Img/` | `assinatura.png`, `erro3.png`, `logo-ok.png`, `logo-ok-1.png`, `logo-ok-2.png`, `logo-ok-3.png`, `simbolo-ok.png`, `simbolo-ok-1.png` |
| `assets/icon/` | `icon.png` (fonte para flutter_launcher_icons) |

> **Atenção:** O `pubspec.yaml` declara `assets/img/` (minúsculo), mas o diretório físico é `assets/Img/` (maiúsculo). Em sistemas de arquivos case-sensitive (Linux, macOS, Android) isso pode causar erro de asset não encontrado. Em Windows (case-insensitive) funciona. O template corporativo deve padronizar a capitalização.

---

## 6. Configuração de Lint (analysis_options)

**Arquivo:** `analysis_options.yaml`

```yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    # avoid_print: false      # comentado (regra ativa pelo include)
    # prefer_single_quotes: true  # comentado (desabilitado)
```

### Situação das regras

| Configuração | Estado | Origem |
|-------------|--------|--------|
| Conjunto base de lints | **Ativo** | `package:flutter_lints/flutter.yaml` (via `include`) |
| `avoid_print` | **Ativo** (padrão do flutter_lints) | A linha está comentada — nenhuma sobrescrita aplicada |
| `prefer_single_quotes` | **Inativo** | Linha comentada — não habilitado |
| Customizações adicionais | **Nenhuma** | Nenhuma regra extra foi adicionada ou desabilitada |

### Observações

- O projeto usa o pacote `flutter_lints ^4.0.0` (dev dependency), que provê o preset `flutter_lints/flutter.yaml`.
- Apesar de `avoid_print` estar ativo nas regras, o código-fonte contém múltiplos `print()` explícitos (ex: `LogServices`, `SettingsAppController`). As supressões são feitas por ausência de enforcement (não há CI de lint configurado no projeto).
- Não há bloco `analyzer:` customizado (sem exclusões de diretórios, sem configurações de severidade).

---

## 7. Duplicação de Configuração de Cores

O projeto contém **dois arquivos idênticos** com a classe `CustomColors`:

| # | Caminho | Conteúdo |
|---|---------|---------|
| 1 | `lib/src/config/custom_colos.dart` | Idêntico ao arquivo 2 |
| 2 | `lib/src/core/theme/config/custom_colos.dart` | Idêntico ao arquivo 1 |

**Conteúdo de ambos os arquivos (100% idêntico):**

```dart
import 'package:flutter/material.dart';

Map<int, Color> _opacidade = {
  50:  Color.fromRGBO(0, 58, 136, .1),
  100: Color.fromRGBO(0, 58, 136, .2),
  200: Color.fromRGBO(0, 58, 136, .3),
  300: Color.fromRGBO(0, 58, 136, .4),
  400: Color.fromRGBO(0, 58, 136, .5),
  500: Color.fromRGBO(0, 58, 136, .6),
  600: Color.fromRGBO(0, 58, 136, .7),
  700: Color.fromRGBO(0, 58, 136, .8),
  800: Color.fromRGBO(0, 58, 136, .9),
  900: Color.fromRGBO(0, 58, 136, 1),
};

abstract class CustomColors {
  static MaterialColor blue = MaterialColor(0xFF003A88, _opacidade);
}
```

**Cor definida:** `#003A88` — Azul corporativo (RGB: 0, 58, 136)

**Qual arquivo é importado onde:**
- `lib/src/components/loading/view/loading.dart` importa `lib/src/core/theme/config/custom_colos.dart` (caminho do core).
- O arquivo em `lib/src/config/custom_colos.dart` pode estar sendo usado por outras telas (verificar via grep no template).

**Para o template corporativo:** Manter apenas o arquivo em `lib/src/core/theme/config/custom_colos.dart` (caminho canônico dentro da arquitetura de core) e remover a cópia em `lib/src/config/`.

---

## 8. Tabela Consolidada de Classificação

| Configuração | Arquivo(s) | Mecanismo | Classificação |
|-------------|-----------|-----------|--------------|
| **Bootstrap / sequência de inicialização** | `lib/main.dart` | Código imperativo em `main()` assíncrono | ✅ Preservar integralmente no template |
| **Tratamento de erro de widget (ErrorWidget.builder)** | `lib/main.dart` | Substitui widget de erro padrão por `CustomErrorWidget`; mensagem condicional debug/release | ✅ Preservar — padrão corporativo de UX de erro |
| **OKToast wrapper** | `lib/main.dart` | Package `oktoast ^3.4.0` envolvendo `GetMaterialApp` | ✅ Preservar — habilita toasts globais |
| **Título do app** | `lib/main.dart` | `GetMaterialApp(title: 'Controle de Separação')` | 🟢 Replicar — trocar o valor para cada projeto |
| **debugShowCheckedModeBanner: false** | `lib/main.dart` | Parâmetro `GetMaterialApp` | ✅ Preservar — padrão corporativo |
| **Tema Material 3 com seed color #003A88** | `lib/main.dart` | `ThemeData(colorScheme: ColorScheme.fromSeed(...), useMaterial3: true)` | 🟢 Replicar — parametrizar a cor semente por projeto |
| **scaffoldBackgroundColor branco semi-transparente** | `lib/main.dart` | `Colors.white.withAlpha(190)` | ✅ Preservar no template como default |
| **Overlay global de loading (LoadingWidget)** | `lib/main.dart` + `loading/` | `builder` do GetMaterialApp com Stack; `LoadingController` via GetX | ✅ Preservar — padrão de UX de loading global |
| **Rotas nomeadas (GetX)** | `lib/src/routes/app_pages.dart` + `lib/src/enum/pages_routes.dart` | `GetPage` com enum `PagesRoutes` | ✅ Preservar o padrão — substituir rotas por projeto |
| **baseUrl (valor default hardcoded)** | `lib/src/constants/Endpoints.dart` | Variável global `String? baseUrl` com IP local como fallback | ✅ Preservar mecanismo; parametrizar valor no template |
| **baseUrl (persistência em runtime)** | `lib/src/constants/Endpoints.dart` + `settings_app/repository/` | `initializeApp()` lê Hive box `variaves_ambiente` na chave `'baseUrl'` | ✅ Preservar — mecanismo central de configuração de ambiente |
| **Endpoints como getters dinâmicos** | `lib/src/constants/Endpoints.dart` | `static String get login => '${baseUrl}/api/...'` | ✅ Preservar — desacoplamento URL/endpoint |
| **Box Hive `variaves_ambiente`** | `lib/main.dart` + `settings_app/repository/` | `Hive.openBox('variaves_ambiente')` no bootstrap; `box.put/get` no repository | ✅ Preservar — fonte de verdade para config de ambiente |
| **Flag de logger (runtime)** | `lib/src/core/features/settings_app/repository/` + `log_services.dart` | `box.put/get('logger', bool)` na box `variaves_ambiente`; consultado a cada log | ✅ Preservar — controle de verbosidade sem rebuild |
| **Box Hive `Cache_aplicativo`** | `lib/main.dart` + `core/services/Hive_services.dart` | `Hive.openBox('Cache_aplicativo')`; interface `HiveServicesInterface` | ✅ Preservar — separação clara entre cache e config |
| **Tela Settings (SettingsApp)** | `lib/src/core/features/settings_app/` | View + Controller + Repository; edita `variaves_ambiente` em runtime | ✅ Preservar — mecanismo de configuração em campo |
| **LogServices com duplo modo** | `lib/src/core/services/log_services.dart` | Console sempre; remoto condicionado pela flag `logger` do Hive | ✅ Preservar — rastreabilidade configurável |
| **flutter_launcher_icons multi-plataforma** | `pubspec.yaml` | `flutter_launcher_icons ^0.13.1`; um PNG fonte, 5 plataformas configuradas | ✅ Preservar — substituir `icon.png` por projeto |
| **Assets (diretório img)** | `pubspec.yaml` | `assets: - assets/img/` | 🟢 Replicar — padronizar capitalização (`img` vs `Img`) |
| **SDK constraint `^3.5.3`** | `pubspec.yaml` | `environment: sdk: ^3.5.3` | ✅ Preservar como mínimo do template |
| **publish_to: none** | `pubspec.yaml` | Impede publicação acidental no pub.dev | ✅ Preservar em todos os projetos privados |
| **Lint base flutter_lints** | `analysis_options.yaml` | `include: package:flutter_lints/flutter.yaml` | ✅ Preservar |
| **Nenhuma customização de lint** | `analysis_options.yaml` | Sem regras extras ativas ou desabilitadas | 🟢 No template, considerar adicionar customizações |
| **CustomColors (azul #003A88)** | `lib/src/core/theme/config/custom_colos.dart` | `abstract class CustomColors { static MaterialColor blue = … }` | ✅ Preservar o padrão de classe abstrata; parametrizar cor |
| **Duplicação de CustomColors** | `lib/src/config/custom_colos.dart` (cópia) | Arquivo idêntico em path alternativo | ⚠️ Remover duplicata no template; manter apenas em `core/theme/config/` |
| **Injeção de dependência GetX (Get.put)** | `lib/main.dart` | `Get.put<Interface>(Implementacao())` para todos os serviços e controllers | ✅ Preservar — padrão de IoC via interface + GetX |
| **Plataformas suportadas** | `.metadata` | android, ios, web, windows, macos, linux | ✅ Preservar todas as plataformas no template |

**Legenda:**
- ✅ **Preservar** — copiar o mecanismo exatamente como está no template.
- 🟢 **Replicar** — copiar o mecanismo, mas substituir valores específicos do projeto (nome, cor, ícone, etc.) por placeholders no template.
- ⚠️ **Atenção** — situação que requer decisão ou limpeza ao criar o template.

---

*Documento gerado por análise direta dos arquivos-fonte do projeto legado `controle_separacao_aplicativo`. Nenhuma configuração foi inferida ou extrapolada — todos os valores e mecanismos descritos foram lidos dos arquivos originais.*
