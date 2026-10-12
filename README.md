# DS Fitness

Aplicativo Flutter para **montar treinos de musculação**, executá-los série a série (com cronômetro de descanso e o GIF do movimento) e acompanhar a evolução. É um cliente fino da API `ds_fitnes_back` (repositório irmão), que guarda as contas, os treinos, os exercícios e as sessões.

A documentação de projeto — arquitetura, regras de negócio, fluxos e contrato com a API — é o **SDD** em [`specs/`](specs/README.md), e é normativa. Este README cobre o essencial para rodar, entender a estrutura e gerar builds.

---

## Requisitos do Ambiente

- **Flutter**: `3.24.5` (canal stable) — **versão pinada**, não atualizar sem alinhar com o time.
- **Dart**: `3.5.4`
- **DevTools**: `2.37.3`
- A API `ds_fitnes_back` no ar (ver [Configuração de Ambiente / API](#configuração-de-ambiente--api)).

```bash
flutter --version
```

Caso precise instalar o Flutter, siga as instruções oficiais no [site do Flutter](https://flutter.dev/docs/get-started).

---

## Stack e Bibliotecas Principais

- **`get`**: gerenciamento de estado, injeção de dependência e navegação (GetX).
- **`dio`**: cliente HTTP, encapsulado em `HttpManager` (token, renovação da sessão, `ApiException`).
- **`hive` / `hive_flutter`**: armazenamento local (sessão, execução em andamento, fila de erros).
- **`logger`**: log no console; os erros também vão para o log da API (`ErrorReporter`).
- **`intl`**: formatação pt-BR (datas, números, durações).

Não há pacote de ícones, de fontes nem de gráficos: os ícones são do Material e o resto é desenhado com `CustomPainter`. As imagens são as de `assets/`. Detalhes e versões em [`specs/07-engenharia.md`](specs/07-engenharia.md).

---

## Estrutura do Projeto

```
lib/
├── main.dart              Bootstrap: Hive, serviços globais, handlers de erro, AuthController, rotas
└── src/
    ├── components/         Design system: widgets reutilizáveis, por categoria
    ├── constants/          Endpoints da API, ambiente (AppEnvironment) e imagens (AppAssets)
    ├── core/
    │   ├── abstracts/       Interfaces dos serviços (Http, Storage, Log, Format, ErrorReporter)
    │   ├── services/        Implementações (HttpManager, StorageService, LogService, ErrorReporter...)
    │   ├── theme/           Tokens (cor, espaçamento, tipografia) e AppTheme
    │   ├── utils/           ErrorMessages, JsonUtils, TextoUtils, Validators
    │   └── features/        Uma pasta por feature, cada uma com abstracts/binding/controller/repository/view:
    │       ├── auth/ splash/ home/ treinos/ treino_form/
    │       ├── biblioteca/ exercicio_detalhe/ exercicio_form/
    │       └── execucao/ historico/ estatisticas/ perfil/
    ├── enum/                Rotas, abas, dia da semana, grupos musculares...
    ├── models/              Modelos de dados (fromJson/toJson manuais)
    └── routes/              AppPages (rotas) e route_args (argumentos tipados)
assets/img/                  GIFs e miniaturas dos exercícios, imagens dos músculos
specs/                       SDD (documentação de projeto)
test/                        Testes automatizados
```

Cada feature segue o padrão **interface → controller → repository → view** (GetX), com `abstracts/` definindo o contrato (`XControllerInterface`, `XRepositoryInterface`) para permitir fakes em teste sem mocks pesados. A árvore completa, com o que cada pasta faz, está em [`specs/03-estrutura-pastas.md`](specs/03-estrutura-pastas.md).

---

## O Fluxo do App

Login → Início (*Montar meu treino* / *Treinar*) → **Novo treino** (dia da semana, nome, objetivo, descrição) → **Grupos musculares** (seleção múltipla) → **Selecionar exercício** → **Configurar exercício** (séries, repetições, descanso, com o GIF) → **Revisar e salvar**. A barra inferior tem Início, Treinos, Evolução e Perfil; a biblioteca de exercícios abre pelo Perfil e o histórico, pela Evolução. Os botões de entrar com Google, Apple e Facebook estão na tela de login e ainda não têm função. As regras de cada tela estão em [`specs/05-regras-de-negocio.md`](specs/05-regras-de-negocio.md) e os diagramas em [`specs/06-fluxos.md`](specs/06-fluxos.md).

---

## Configuração de Ambiente / API

O endereço da API (`lib/src/constants/app_environment.dart`) vem de `--dart-define=API_BASE_URL=...` e, sem ele, aponta para o servidor de desenvolvimento na própria máquina:

| Onde roda | Endereço padrão |
|---|---|
| Web, Windows, macOS, Linux, iOS simulator | `http://localhost:5270` |
| Android emulator | `http://10.0.2.2:5270` (o emulador enxerga o host por esse endereço) |
| Aparelho físico | informe `--dart-define=API_BASE_URL=http://<ip-do-pc>:5270` (mesma rede Wi-Fi) |

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.0.10:5270
```

`--dart-define=APP_VERSION=1.2.3` informa a versão que acompanha cada erro enviado ao log da API (padrão `1.0.0`). No desenvolvimento o CORS da API é aberto, o que permite rodar o app na web.

---

## Imagens dos Exercícios

Os GIFs e as miniaturas ficam **dentro do app**: a API informa só a chave da imagem de cada exercício (`imagem`, ex.: `pectorals/barbell-bench-press`) e o app monta o caminho do arquivo. A pasta `assets/img/` tem 1.323 exercícios (mais de 400 MB); só os do catálogo da API (55) estão declarados no `pubspec.yaml`. Para incluir outro, declare o GIF e a miniatura — ver [`specs/07-engenharia.md`](specs/07-engenharia.md#imagens-dos-exercícios).

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

# Rodar toda a suíte de testes (um por vez: em paralelo pode faltar memória)
flutter test --concurrency=1
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
Gerado em `build/macos/Build/Products/Release/ds_fitness.app`.

### 4.4 Rodar em outro Mac
Como o app não é assinado/notarizado pela Apple, o **Gatekeeper** vai
bloquear a primeira execução ("app de desenvolvedor não identificado"). No
Mac de destino: clique com o botão direito no `.app` > **Abrir** (em vez de
duplo clique) e confirme — ou, via terminal, remova o atributo de
quarentena:
```bash
xattr -cr ds_fitness.app
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

- **Build de release precisa do endereço da API.** Sem
  `--dart-define=API_BASE_URL=...`, o app aponta para o servidor de
  desenvolvimento (`localhost:5270`, ou `10.0.2.2` no emulador Android) — ver
  [Configuração de Ambiente / API](#configuração-de-ambiente--api). Confira
  também a pasta `assets/`, que o build exige completa (ver
  [Imagens dos Exercícios](#imagens-dos-exercícios)).
