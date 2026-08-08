# Estratégia de Testes — Template Flutter Corporativo

**Escopo:** T6 — Qualidade: Testes  
**Fonte de análise:** `controle_separacao_aplicativo` (projeto legado, somente leitura)  
**Data:** 2026-06-24

---

## 1. Estado Atual dos Testes no Projeto Legado

### 1.1 Inventário da pasta `test/`

| Arquivo | Tipo | Conteúdo Real |
|---|---|---|
| `test/widget_test.dart` | Widget test (gerado pelo Flutter CLI) | Smoke test de "Counter increments" — teste padrão do `flutter create`, **nunca adaptado ao projeto real** |

**Total de arquivos de teste:** 1  
**Total de testes reais:** 0 (zero testes sobre código de produção)

O único arquivo existente importa `MyApp` e verifica um contador que não existe na aplicação — é evidência direta de que o arquivo jamais foi executado com sucesso. O projeto possui aproximadamente **90+ arquivos `.dart`** em `lib/` e **1 arquivo de teste não funcional**.

### 1.2 Dependências de teste declaradas no `pubspec.yaml`

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  test: ^1.25.7
  flutter_lints: ^4.0.0
```

**Ausências notáveis:**

| Pacote | Finalidade | Presente? |
|---|---|---|
| `mocktail` | Mocks tipados de interfaces | Não |
| `mockito` | Mocks com geração de código | Não |
| `bloc_test` | Testes de BLoC/Cubit | Não |
| `golden_toolkit` | Testes de regressão visual (golden) | Não |
| `integration_test` | Testes de integração end-to-end | Não |
| `flutter_test` | Testes de widget | Sim (SDK) |
| `test` | Testes unitários puros Dart | Sim |

### 1.3 Configuração de CI/CD

Nenhum arquivo de CI encontrado no projeto (`/.github/`, `/.gitlab-ci.yml`, `/.circleci/`, `Makefile` com targets de test). **Não há pipeline automatizado de testes.**

### 1.4 Menção a testes na documentação

O `CONTRIBUTING.md` lista o comando `flutter test` em uma seção "Dicas Extras", mas sem contexto, cobertura esperada ou obrigatoriedade:

```bash
# Para Roda os testes unitarios 
flutter test
```

Nota: o comentário contém erro gramatical ("Roda" em vez de "Rodar"), reforçando que a seção foi incluída como item genérico, não como prática real estabelecida.

### 1.5 Classificação do estado atual

**🔴 CRÍTICO** — Cobertura de testes: 0%. Nenhuma camada do sistema possui testes automatizados. O projeto tem estrutura arquitetural que favorece testes (interfaces/contratos), mas essa vantagem não foi aproveitada.

---

## 2. Por que a Arquitetura por Interfaces FAVORECE testes (mas não são feitos)

O projeto legado definiu interfaces/contratos abstratos para as camadas principais:

| Interface | Camada | Localização |
|---|---|---|
| `HiveServicesInterface` | Cache local | `core/abstracts/` |
| `HttpManagerInterfaces` | HTTP | `core/abstracts/` |
| `LogServicesInterface` | Log | `core/abstracts/` |
| `FormatarValoresInterface` | Utilitários | `core/abstracts/` |
| `LoginRepositoryInterface` | Repositório | `core/features/login/abstracts/` |
| `LoginControllerInterface` | Controller | `core/features/login/abstracts/` |
| `CommandInterface` | Command Pattern | `core/features/conferir_material_saida/abstracts/` |

**Vantagem arquitetural não aproveitada:** todo controller e repositório recebe suas dependências através de contratos abstratos (`Get.find<Interface>()`). Isso significa que, em testes, qualquer dependência poderia ser substituída por um mock que implemente a mesma interface — sem nenhuma mudança no código de produção.

**Exemplo concreto (potencial):**

```dart
// Sem mocktail: impossível testar ConfirmarConferenciaCommand isoladamente
// Com mocktail: bastaria registrar um FakeRepository no Get

class MockConferirMaterialSaidaRepository extends Mock 
    implements ConferirMaterialSaidaRepositoryInterface {}

test('execute deve salvar e exibir toast de sucesso', () async {
  final mockRepo = MockConferirMaterialSaidaRepository();
  when(() => mockRepo.postNotaCompraLotesEtiqueta(any())).thenAnswer((_) async => true);
  
  final command = ConfirmarConferenciaCommand([]);
  await command.execute();
  
  verify(() => mockRepo.postNotaCompraLotesEtiqueta(any())).called(1);
});
```

**Barreiras reais para teste que o template deve endereçar:**

1. Controllers resolvem dependências via `Get.find()` dentro do construtor — o template deve adotar injeção por construtor ou parâmetro para facilitar mocks.
2. Uso de `print()` em vez de logger injetável dificulta verificação de comportamento de erro em testes.
3. Mistura de lógica de negócio e chamadas de UI (ex: `CustomToast()` instanciado diretamente no `ConfirmarConferenciaCommand`) — viola SRP e impede testes unitários puros.

---

## 3. Estratégia de Testes Recomendada para o Template

### 3.1 Pirâmide de Testes

```
         /\
        /  \
       / E2E \        ← 5% — integration_test (fluxos críticos)
      /--------\
     /  Widget  \     ← 25% — flutter_test (componentes isolados)
    /------------\
   /    Unit      \   ← 70% — test + mocktail (lógica pura, comandos, repositórios)
  /--------------  \
```

### 3.2 Camadas e ferramentas recomendadas

| Camada | O que testar | Ferramenta | Exemplo de alvo |
|---|---|---|---|
| Unitário | Commands, validators, utils, formatadores | `test` + `mocktail` | `ConfirmarConferenciaCommand`, `emailValidator`, `FormatarValores` |
| Controller | Lógica de estado (GetX RxList/RxBool) | `test` + `mocktail` | `LoginController.login()`, `NfsPedidosController.carregarLista()` |
| Widget | Componentes visuais customizados | `flutter_test` | `CustomTextField`, `CustomToast`, `CustomScaffold` |
| Golden | Regressão visual de componentes-chave | `golden_toolkit` | Tela de login, tela de splash, cards de lista |
| Integração | Fluxo completo em device/emulator | `integration_test` | Login → Listagem → Conferência |

### 3.3 Dependências de teste para o template (`pubspec.yaml`)

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter
  test: ^1.25.7
  mocktail: ^1.0.4
  golden_toolkit: ^0.15.0
  flutter_lints: ^4.0.0
```

### 3.4 Estrutura de pastas de testes recomendada

```
test/
├── unit/
│   ├── core/
│   │   ├── services/
│   │   │   └── formatar_valores_test.dart
│   │   └── utils/
│   │       └── validators_test.dart
│   └── features/
│       └── login/
│           ├── controller/
│           │   └── login_controller_test.dart
│           └── repository/
│               └── login_repository_test.dart
├── widget/
│   ├── components/
│   │   ├── custom_text_field_test.dart
│   │   └── custom_toast_test.dart
│   └── features/
│       └── login/
│           └── login_view_test.dart
└── goldens/
    └── login_screen_golden_test.dart

integration_test/
└── app_flow_test.dart
```

### 3.5 Padrão de Mock com `mocktail`

O template deve adotar **injeção de dependência por construtor** para que mocks funcionem sem GetX:

```dart
// Padrão recomendado no template (controller testável)
class LoginController extends GetxController implements LoginControllerInterface {
  final LoginRepositoryInterface _repository;
  final LogServicesInterface _log;
  
  LoginController({
    required LoginRepositoryInterface repository,
    required LogServicesInterface log,
  })  : _repository = repository,
        _log = log;
}

// No teste:
class MockLoginRepository extends Mock implements LoginRepositoryInterface {}

void main() {
  late LoginController controller;
  late MockLoginRepository mockRepository;
  
  setUp(() {
    mockRepository = MockLoginRepository();
    controller = LoginController(repository: mockRepository, log: MockLogServices());
  });
  
  test('login bem-sucedido deve definir autenticado como true', () async {
    when(() => mockRepository.login(any())).thenAnswer((_) async => true);
    await controller.fazerLogin('user', 'pass');
    expect(controller.autenticado.value, isTrue);
  });
}
```

### 3.6 Testes de Widget

```dart
void main() {
  testWidgets('CustomTextField exibe label e aceita input', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CustomTextField(label: 'Usuário', hint: 'Digite o usuário'),
        ),
      ),
    );
    
    expect(find.text('Usuário'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'admin');
    expect(find.text('admin'), findsOneWidget);
  });
}
```

### 3.7 Cobertura mínima recomendada

| Camada | Cobertura Mínima | Cobertura Ideal |
|---|---|---|
| Unitário (commands, validators, utils) | 80% | 95% |
| Controllers | 70% | 85% |
| Repositórios (com mocks HTTP) | 60% | 80% |
| Widgets críticos | 50% | 70% |
| Geral do projeto | 60% | 75% |

Gerar relatório de cobertura:
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### 3.8 Pipeline de CI recomendado (GitHub Actions)

```yaml
# .github/workflows/quality.yml
name: Quality Gates

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.4'
          channel: 'stable'
      
      - name: Instalar dependências
        run: flutter pub get
      
      - name: Analisar código
        run: flutter analyze --fatal-infos
      
      - name: Verificar formatação
        run: dart format --output=none --set-exit-if-changed .
      
      - name: Rodar testes unitários e de widget
        run: flutter test --coverage
      
      - name: Verificar cobertura mínima (60%)
        run: |
          COVERAGE=$(lcov --summary coverage/lcov.info 2>&1 | grep "lines" | awk '{print $4}' | tr -d '%')
          if (( $(echo "$COVERAGE < 60" | bc -l) )); then
            echo "Cobertura abaixo do mínimo: $COVERAGE%"
            exit 1
          fi
      
      - name: Upload cobertura
        uses: codecov/codecov-action@v4
        with:
          file: coverage/lcov.info
```

### 3.9 Roadmap de adoção progressiva

| Fase | Prazo sugerido | Meta |
|---|---|---|
| Fase 1 | Sprint 1 | Adicionar `mocktail`, escrever testes para `validators.dart` e `formatar_valores.dart` (pure functions, zero dependências) |
| Fase 2 | Sprint 2 | Testes unitários de todos os Commands (Command Pattern facilita isolamento) |
| Fase 3 | Sprint 3 | Testes de Controller com mocks de repositório |
| Fase 4 | Sprint 4 | Widget tests dos componentes customizados |
| Fase 5 | Sprint 5-6 | Configurar CI, golden tests, integration_test para fluxo de login |

---

## 4. Resumo de Classificações

| Aspecto | Estado Atual | Classificação | Recomendação |
|---|---|---|---|
| Cobertura de testes | 0% (1 arquivo, 0 testes reais) | 🔴 CRÍTICO | Pirâmide: 70% unit / 25% widget / 5% E2E |
| Ferramentas de mock | Nenhuma | 🔴 CRÍTICO | Adicionar `mocktail ^1.0.4` |
| Testes de widget | Nenhum | 🔴 CRÍTICO | `flutter_test` com componentes isolados |
| Golden tests | Nenhum | 🔴 CRÍTICO | `golden_toolkit` para regressão visual |
| Integration tests | Nenhum | 🔴 CRÍTICO | `integration_test` SDK para fluxos E2E |
| Aproveitamento de interfaces | Potencial alto, uso zero | 🟠 ALTO RISCO | Injeção por construtor + mocktail |
| Pipeline CI | Inexistente | 🔴 CRÍTICO | GitHub Actions com quality gates |
| Documentação de testes | Menção superficial no CONTRIBUTING | 🔴 CRÍTICO | Guia de testes detalhado no template |
