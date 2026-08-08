# direction_app1 — Template Flutter Corporativo

Template Flutter corporativo reutilizável, construído por engenharia reversa do
aplicativo legado `controle_separacao_aplicativo` — **preservando a stack e os
padrões que já funcionam em produção** (GetX, Dio, Hive), sem acoplamento às
regras de negócio originais.

A documentação profunda de arquitetura, infraestrutura, design system e
convenções vive em [`specs/`](specs/00-overview/README.md). Este README cobre
o essencial para rodar, entender a estrutura e gerar builds.

---

## Requisitos do Ambiente

- **Flutter**: `3.24.5` (canal stable) — **versão pinada**, não atualizar sem alinhar com o time.
- **Dart**: `3.5.4`
- **DevTools**: `2.37.3`

```bash
flutter --version
```

Caso precise instalar o Flutter, siga as instruções oficiais no [site do Flutter](https://flutter.dev/docs/get-started).

---

## Stack e Bibliotecas Principais

Stack oficial preservada do legado (ver `specs/07-template-blueprint/`):

- **`get`**: gerenciamento de estado, injeção de dependência e navegação (GetX).
- **`dio`**: cliente HTTP, encapsulado em `HttpManager`.
- **`hive` / `hive_flutter`**: persistência/cache local e configuração de ambiente em runtime.
- **`connectivity_plus`**: detecção de conectividade (online/offline) para o fluxo de sincronização.
- **`logger`**: logging estruturado (local + remoto via `LogServices`).
- **`oktoast` / `fluttertoast`**: feedback e mensagens de toast.
- **`pluto_grid`**: data grid com filtros/paginação.
- **`phosphor_flutter`**: ícones (identidade visual Direction).
- **`google_fonts`**: tipografia Sora/Manrope (Design System Direction).
- **`intl`**: i18n e formatação pt-BR (datas, números, moeda).
- **`url_launcher`**: ações de contato (`tel:`, `wa.me`, `mailto:`).
- **`barcode_scan2`**, **`image_picker`**, **`mask_text_input_formatter`**, **`tab_container`**, **`flutter_speed_dial`**: utilitários pontuais.

Catálogo completo e motivação de cada biblioteca:
[`specs/05-libraries/library-deep-catalog.md`](specs/05-libraries/library-deep-catalog.md).

---

## Estrutura do Projeto

```
lib/
├── main.dart              Bootstrap: Hive, DI (Get.put/lazyPut), rotas
└── src/
    ├── components/         Widgets reutilizáveis (app, common, home, loading, scaffold...)
    ├── constants/          Endpoints da API, ambientes (AppEnvironment/AppConfig)
    ├── core/
    │   ├── abstracts/       Interfaces dos services transversais (Http, Hive, Log, Sync...)
    │   ├── services/        Implementações dos services (HttpManager, HiveServices...)
    │   ├── theme/           Design tokens e tema (ColorTokens, AppTheme)
    │   ├── utils/           Utilitários gerais
    │   └── features/        Features por domínio, cada uma com controller/repository/view/abstracts:
    │       ├── login/          Autenticação (JWT + refresh)
    │       ├── home/           Dashboard (resumo do dia, comissão, urgentes)
    │       ├── orcamento/       Fluxo de Novo Orçamento (5 etapas — ver abaixo)
    │       ├── catalogo/        Catálogo de produtos (sincronização incremental)
    │       ├── clientes/        Carteira de clientes do usuário logado
    │       ├── pedidos/         Lista e detalhe de pedidos
    │       ├── comissoes/       Comissões do representante
    │       ├── agenda/          Eventos de agenda (somente leitura)
    │       ├── novo_pedido/     Estado de carrinho legado (em descontinuação)
    │       └── splash_screen/   Tela de splash inicial
    ├── enum/                Enums (rotas, status, etc.)
    ├── models/              Modelos de dados (fromJson/toJson manual)
    └── routes/              Definição de rotas (GetPages)
```

Cada feature segue o padrão **interface → controller → repository → view**
(GetX), com `abstracts/` definindo o contrato (`XControllerInterface`,
`XRepositoryInterface`) para permitir fakes em teste sem mocks pesados.

---

## Fluxo de Orçamento

A feature principal do app é o fluxo de **Novo Orçamento**
(`lib/src/core/features/orcamento/`), em 5 etapas dentro de um único
`IndexedStack` (sem troca de rota):

1. **Cliente** — seleção/busca do cliente responsável pelo orçamento.
2. **Itens** — escolha de produtos (busca + filtros + multi-seleção) e ajuste
   de quantidade/desconto individual por item.
3. **Transportadora** — opcional; não bloqueia avanço se não houver nenhuma cadastrada.
4. **Forma de pagamento** — opcional; mesma regra de não bloqueio.
5. **Observação** — texto livre opcional, seguido de "Finalizar".

Descontos negociados (gerais, aplicados a todos os itens) são **somados** ao
desconto individual de cada item (modelo aditivo), com lista de descontos
aplicados e opção de exclusão. Todos os endpoints consumidos são os mesmos da
API Direction real (REST/JWT) — sem mocks.

---

## Configuração de Ambiente / API

A URL base da API (`lib/src/constants/app_environment.dart`) é resolvida
**automaticamente** por plataforma e modo de build (`AppConfig.active`):

| Onde roda | Ambiente usado |
|---|---|
| Celular físico (Android/iOS) | **Produção** (`api.directionsolution.com.br`), sempre — mesmo em build debug. |
| Web / Windows / macOS / Linux, `flutter run` (debug) | **Local** (`http://localhost:5162`) — para desenvolver com a API rodando na própria máquina. |
| Web / Windows / macOS / Linux, build `--release` | **Produção** — evita apontar um build distribuído para um cliente ao `localhost`. |

Essa resolução automática pode ser sobrescrita, em ordem de prioridade:

1. Build: `flutter run --dart-define=API_BASE_URL=https://...`
2. Runtime: valor salvo na box Hive `variaves_ambiente` (chave `baseUrl`) —
   base para uma futura tela de seleção de ambiente/cliente.

Detalhes: [`specs/02-infrastructure/configuration.md`](specs/02-infrastructure/configuration.md).

---

## Rodando e Testando

```bash
# Instalar dependências
flutter pub get

# Rodar (Windows / Chrome / Android)
flutter run -d windows
flutter run -d chrome
flutter run -d android-emulator

# Analisar (deve retornar "No issues found!")
flutter analyze

# Rodar toda a suíte de testes
flutter test
```

---

# Guia de Build / Distribuição

Antes de publicar em qualquer loja (Play Store / App Store), teste sempre
localmente nos aparelhos/plataformas de destino. Esta seção cobre as duas
situações: **rodar/instalar direto para teste** (sem loja) e **gerar o
artefato final** para publicação.

Ver o que está conectado/disponível a qualquer momento:
```bash
flutter devices
```

---

## 1. Android

### 1.1 Preparar o ambiente
- Android Studio instalado e configurado, com o Android SDK atualizado.
- No aparelho: ative **Opções do desenvolvedor** (tocar 7x em "Número da
  versão" em Configurações > Sobre o telefone) e depois **Depuração USB**
  dentro de Opções do desenvolvedor.
- Conecte o aparelho por cabo USB e autorize a depuração no popup que aparece
  no celular. Confirme que ele aparece em `flutter devices`.

### 1.2 Testar direto no celular (jeito mais rápido — sem gerar arquivo)
Com o aparelho conectado e reconhecido:
```bash
flutter run -d <device_id>       # debug (hot reload disponível)
flutter run -d <device_id> --release   # release (performance real, sem hot reload)
```
Isso compila, instala e abre o app automaticamente no aparelho. Ideal para o
ciclo rápido de testes antes de gerar qualquer APK.

### 1.3 Gerar o APK (debug)
```bash
flutter build apk --debug
```
Gerado em `build/app/outputs/flutter-apk/app-debug.apk`.

### 1.4 Gerar o APK (release, sem assinatura de loja)
```bash
flutter build apk --release
```
Gerado em `build/app/outputs/flutter-apk/app-release.apk`. **Este é o arquivo
para distribuir e testar em quantos aparelhos quiser, sem passar pela Play
Store.**

> `--split-per-abi` gera um APK menor por arquitetura (`arm64-v8a`,
> `armeabi-v7a`, `x86_64`) em vez de um único "fat APK":
> ```bash
> flutter build apk --release --split-per-abi
> ```
> Útil para reduzir tamanho, mas exige instalar o APK certo para cada
> aparelho — para testes simples, prefira o APK único (sem essa flag).

### 1.5 Instalar o APK gerado no aparelho
- **Com o cabo conectado** (mais simples):
  ```bash
  flutter install -d <device_id>
  # ou, direto via adb:
  adb install -r build/app/outputs/flutter-apk/app-release.apk
  ```
- **Sem cabo** (enviar o arquivo `.apk` por WhatsApp, Drive, e-mail, etc.):
  1. Transfira o `.apk` para o aparelho e abra o arquivo pelo gerenciador de arquivos do celular.
  2. Na primeira instalação, o Android vai pedir para permitir **"Instalar apps de fontes desconhecidas"** (ou "Instalar app desconhecido") — permita para o app usado para abrir o arquivo (Arquivos, Chrome, WhatsApp, etc.).
  3. Toque em **Instalar**.
- Para reinstalar uma versão mais nova por cima da anterior, repita o mesmo
  processo (não precisa desinstalar antes, a menos que troque a assinatura).

### 1.6 Assinar o APK/AAB (somente quando for publicar na Play Store)
```bash
keytool -genkey -v -keystore ~/key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias key
```
Configure `android/app/build.gradle`:
```gradle
signingConfigs {
    release {
        storeFile file('key.jks')
        storePassword 'sua-senha'
        keyAlias 'key'
        keyPassword 'sua-senha'
    }
}
buildTypes {
    release {
        signingConfig signingConfigs.release
    }
}
```
Depois, rebuilde com `flutter build apk --release`. Para a Play Store, o
formato exigido é o **App Bundle**, não o APK:
```bash
flutter build appbundle --release
```
Gerado em `build/app/outputs/bundle/release/app-release.aab`. **O `.aab` não
é instalável diretamente num aparelho** — ele só serve para upload na Play
Store (que gera os APKs otimizados por aparelho). Para testes locais, use
sempre o `.apk` da seção 1.4/1.5.

---

## 2. iOS

> Build/instalação em iOS só é possível a partir de um **Mac com Xcode**
> instalado (limitação da Apple, não do Flutter).

### 2.1 Preparar o ambiente
- Xcode instalado (via App Store) e `flutter doctor` sem erros na seção iOS.
- Uma conta Apple (pode ser gratuita/pessoal para testes locais — não precisa
  ser a conta paga de desenvolvedor ainda).
- Abra `ios/Runner.xcworkspace` no Xcode pelo menos uma vez para configurar o
  **Team** em *Signing & Capabilities* do target `Runner`.

### 2.2 Testar direto no iPhone (sem TestFlight/App Store)
Conecte o iPhone por cabo, confie no Mac quando solicitado no aparelho, e:
```bash
flutter devices                      # confirma que o iPhone aparece
flutter run -d <device_id>           # debug
flutter run -d <device_id> --release # release
```
No próprio aparelho, em **Ajustes > Geral > VPN e Gerenciamento de
Dispositivo**, pode ser necessário confiar manualmente no certificado de
desenvolvedor na primeira execução.

> **Conta Apple gratuita**: o app instalado expira em **7 dias** e precisa
> ser reinstalado (rodar `flutter run` de novo). Uma conta Apple Developer
> paga (US$ 99/ano) remove esse limite e permite gerar builds ad-hoc/TestFlight
> válidos por mais tempo.

### 2.3 Gerar um `.ipa` para instalar sem manter o Mac conectado
```bash
flutter build ipa --release
```
Gerado em `build/ios/ipa/`. Para instalar em um aparelho a partir do `.ipa`
(sem TestFlight):
- Xcode > **Window > Devices and Simulators**, selecionar o aparelho e
  arrastar o `.ipa` para a lista de apps; ou
- Ferramentas de distribuição ad-hoc (ex.: Apple Configurator, Diawi) para
  gerar um link de instalação temporário.

### 2.4 Simulador (alternativa sem aparelho físico)
```bash
flutter run -d ios   # ou selecionar o simulador em `flutter devices`
```
Não expira em 7 dias, mas não substitui o teste em aparelho real (câmera,
sensores, performance, etc. são diferentes).

---

## 3. Windows

### 3.1 Preparar o ambiente
```bash
flutter doctor
```
Certifique-se de que as ferramentas de desenvolvimento desktop do Visual
Studio estão instaladas (workload "Desktop development with C++").

### 3.2 Testar direto (sem gerar executável)
```bash
flutter run -d windows
flutter run -d windows --release
```

### 3.3 Gerar o executável
```bash
flutter build windows
```
Gerado em `build/windows/x64/runner/Release`.

### 3.4 Testar em outro PC Windows (sem instalar Flutter lá)
Copie **toda a pasta** `Release` (o `.exe` sozinho não roda — precisa das
DLLs e da pasta `data/` junto) para o outro PC e execute o `.exe`
diretamente. Não é necessário instalador para teste local; use um instalador
(ex.: **Inno Setup**) só na hora de distribuir para o cliente final.

---

## 4. macOS

### 4.1 Preparar o ambiente
```bash
flutter doctor
```
Xcode instalado (mesmo requisito do iOS, já que o build macOS também passa
por ele).

### 4.2 Testar direto
```bash
flutter run -d macos
flutter run -d macos --release
```

### 4.3 Gerar o app
```bash
flutter build macos
```
Gerado em `build/macos/Build/Products/Release/direction_app1.app`.

### 4.4 Rodar em outro Mac
Como o app não é assinado/notarizado pela Apple, o **Gatekeeper** vai
bloquear a primeira execução ("app de desenvolvedor não identificado"). No
Mac de destino: clique com o botão direito no `.app` > **Abrir** (em vez de
duplo clique) e confirme — ou, via terminal, remova o atributo de
quarentena:
```bash
xattr -cr direction_app1.app
```

---

## 5. Web

### 5.1 Testar direto no navegador
```bash
flutter run -d chrome
```

### 5.2 Gerar build estático
```bash
flutter build web
# ou, com o renderer HTML (mais previsível para depuração visual):
flutter build web --web-renderer html
```
Gerado em `build/web` — arquivos estáticos, podem ser servidos por qualquer
servidor HTTP:
```bash
python -m http.server 8080 --directory build/web
```

---

## 6. Linux

### 6.1 Preparar o ambiente
```bash
flutter doctor
```
Requer as bibliotecas de desenvolvimento GTK (`clang`, `cmake`, `ninja-build`,
`libgtk-3-dev`, conforme `flutter doctor` indicar).

### 6.2 Testar direto
```bash
flutter run -d linux
```

### 6.3 Gerar o executável
```bash
flutter build linux
```
Gerado em `build/linux/x64/release/bundle` (copie a pasta `bundle` inteira
para rodar em outra máquina Linux compatível).

---

## Dicas Extras

- **Limpar o projeto antes de buildar** (evita erros acumulados):
  ```bash
  flutter clean
  flutter pub get
  ```

- **Build de release usa a API de produção automaticamente** (ver
  [Configuração de Ambiente / API](#configuração-de-ambiente--api)) — não
  esqueça de testar contra produção antes de distribuir, não só contra o
  `localhost` do `flutter run` em debug.

Se tiver mais atualizações do projeto, coloque aqui! 🚀
