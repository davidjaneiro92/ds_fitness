# Injeção de Dependência — GetX Manual e Eager

> **Escopo T2 — Infraestrutura técnica apenas. Regras de negócio excluídas.**
> Projeto analisado: `controle_separacao_aplicativo` · Pacote: `get: 4.7.2` (versão resolvida no lock; declarada como `^4.6.6`)

---

## 1. Visão Geral

O projeto usa **DI 100% manual e eager** via `Get.put()` no `main()`. Não há `Bindings`, `lazyPut`, `putAsync` ou qualquer mecanismo de inicialização preguiçosa. Todos os ~20 controladores e serviços são instanciados **antes** de `runApp()`, na ordem exata declarada no `main.dart`.

---

## 2. Como Funciona Hoje

### 2.1 Bootstrap no `main.dart`

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('variaves_ambiente');

  // Serviços base (sem dependências)
  Get.put(LoadingController());
  Get.put<UtilsServicesInterfaces>(UtilsServices());
  Get.put<LogServicesInterface>(LogServices());

  await initializeApp();        // lê configuração do Hive

  await Hive.openBox('Cache_aplicativo');
  Get.put<HiveServicesInterface>(HiveServices());
  Get.put<HttpManagerInterfaces>(HttpManager());
  Get.put<FormatarValoresInterface>(FormatarValores());
  Get.put(CustomItemListViewController());

  // Controllers de features (dependem dos serviços acima)
  Get.put<SettingsAppControllerInterface>(SettingsAppController());
  Get.put<LoginControllerInterface>(LoginController());
  Get.put<ConferirMaterialEntradaControllerInterface>(ConferirMaterialEntradaController());
  Get.put<ItensNfEntradaControllerInterface>(ItensNfEntradaController());
  Get.put<NfsPedidosControllerInterfaces>(NfsPedidosController());
  Get.put<SelecionarMaterialEstoqueControllerInterfaces>(SelecionarMaterialEstoqueController());
  Get.put<ItensPedidoSaidaControllerInterface>(ItensPedidoSaidaController());
  Get.put<ConferirMaterialSaidaControllerInterface>(ConferirMaterialSaidaController());
  Get.put<ConsultaNfSaidaControllerInterface>(ConsultaNfSaidaController());
  Get.put<BuscarProdutosControllerInterface>(BuscarProdutosController());
  Get.put<ConferirMaterialTransferenciaControllerInterface>(ConferirMaterialTransferenciaController());
  Get.put<TrasferenciaIndustriaControllerInterface>(TrasferenciaIndustriaController());

  runApp(const MyApp());
}
```

**Total registrado**: 6 serviços/utilitários + 12 controllers de feature = **18 singletons globais**.

### 2.2 Ordem de Inicialização e Dependências Implícitas

A ordem de `Get.put()` é criticamente importante porque os controllers resolvem dependências em seus construtores via `Get.find()`:

```dart
// NfsPedidosController — Get.find() no campo (resolvido na construção)
class NfsPedidosController extends GetxController {
  final HiveServicesInterface hiveServices = Get.find();   // precisa de HiveServices
  final LogServicesInterface logservices = Get.find();     // precisa de LogServices
```

Se `HiveServices` ou `LogServices` não tiverem sido registrados antes de `NfsPedidosController`, o app crasha em runtime. A ordem correta existe no código, mas não é verificada em compile-time.

### 2.3 Resolução de Dependências nas Views

As views também chamam `Get.find()` diretamente nos campos da classe:

```dart
// Login (StatelessWidget)
final LoginControllerInterface controller = Get.find();
final UtilsServicesInterfaces utilsServices = Get.find();

// NfsPedidos (_NfsPedidosState)
final NfsPedidosControllerInterfaces controller = Get.find();
final FormatarValoresInterface formatarValor = Get.find();
final HiveServicesInterface hiveServices = Get.find();
```

Isso cria acoplamento implícito entre view e registro global, dificultando testes unitários das views.

### 2.4 Inconsistência: Controllers que Instanciam Repositórios com `new`

Enquanto **serviços** são injetados via `Get.find()`, os **repositórios** são instanciados diretamente com `new` dentro dos controllers, sem registro no container:

```dart
// LoginController — repositório instanciado diretamente (sem DI)
class LoginController extends GetxController {
  LoginRepositoryInterface repository = new LoginRepository();  // ← new explícito
```

```dart
// NfsPedidosController
final NfsPedidosRepositoryInterface repository = NfsPedidosRepository();

// ConferirMaterialSaidaController
ConferirMaterialSaidaRepositoryInterface repository = ConferirMaterialSaidaRepository();

// TrasferenciaIndustriaController — três repositórios instanciados
TrasferenciaIndustriaRepositoryInterface repository = TrasferenciaIndustriaRepository();
BuscarProdutosRepositoryInterface repositoryProduto = BuscarProdutosRepository();
TrasferenciaIndustriaRepositoryInterface repositoryTransf = TrasferenciaIndustriaRepository();
```

Consequências:
- Repositórios não podem ser substituídos por mocks em testes sem modificar o controller.
- `TrasferenciaIndustriaController` instancia **duas vezes** o mesmo repositório (`TrasferenciaIndustriaRepository`) em campos separados.
- O `new` explícito em `LoginController` é obsoleto no Dart moderno (keyword desnecessária desde o Dart 2).

### 2.5 Ausência de `Bindings` e `lazyPut`

GetX oferece `Bindings` para associar controllers a rotas e `lazyPut` para inicialização preguiçosa. O projeto não usa nenhum dos dois:

```dart
// O que o projeto NÃO faz (padrão GetX recomendado para rotas)
GetPage(
  name: '/login',
  page: () => Login(),
  binding: LoginBinding(), // ← ausente
)

// class LoginBinding extends Bindings {
//   @override
//   void dependencies() {
//     Get.lazyPut<LoginControllerInterface>(() => LoginController());
//   }
// }
```

### 2.6 Uso de Interfaces (Aspecto Positivo)

A maioria dos `Get.put()` registra **pela interface**, não pela implementação concreta:

```dart
Get.put<LoginControllerInterface>(LoginController());
Get.put<HiveServicesInterface>(HiveServices());
Get.put<HttpManagerInterfaces>(HttpManager());
```

Isso permite trocar implementações sem alterar o código consumidor — é a única abstração de DI efetiva no projeto.

---

## 3. Inventário e Classificação

| Item | Classificação | Justificativa |
|---|---|---|
| `Get.put<Interface>(Impl())` para serviços | 🟢 Reutilizar com melhorias | A abstração por interface é boa; o problema é ser eager e global |
| `Get.put<Interface>(Impl())` para controllers de feature | 🟠 Substituir | Controllers de feature deveriam ser lazy e com escopo de rota (Bindings ou lazyPut) |
| `Get.find()` nos controllers (para serviços) | 🟡 Refatorar | Funciona, mas a dependência é implícita; preferir injeção por construtor |
| `Get.find()` nas views | 🟡 Refatorar | Dificulta testes; preferir receber controller via construtor ou provider |
| Repositórios instanciados com `new` dentro de controllers | 🔴 Descartar | Anti-pattern: impede mocking, viola DI; repositórios devem ser injetados |
| `new` explícito (keyword obsoleta) | 🔴 Descartar | Obsoleto em Dart 2+; remover |
| Repositório duplicado em `TrasferenciaIndustriaController` | 🔴 Descartar | Duas instâncias do mesmo repositório sem razão; refatorar |
| Ausência de `Bindings` / `lazyPut` | 🟠 Substituir | Causa inicialização de ~12 controllers antes do primeiro frame; usar lazy loading |
| Registro por interface (padrão) | ✅ Reutilizar sem alterações | Correto e reutilizável; manter abstração por interface no template |
| Ordem de inicialização manual e frágil | 🟠 Substituir | Sem verificação em compile-time; um `Get.put` fora de ordem crasha em runtime |

---

## 4. Pontos Fortes (Manter)

- **Registro por interface**: `Get.put<Interface>(Impl())` é a única prática de DI correta do projeto. Permite substituição de implementação sem alterar consumidores.
- **Serviços compartilhados como singletons globais**: `HttpManager`, `HiveServices`, `LogServices` e `UtilsServices` fazem sentido como singletons de app — essa decisão é correta.
- **`LoadingController` como singleton global**: usado em toda a app via stack global no `builder` do `GetMaterialApp` — padrão válido para loading overlay.

---

## 5. Problemas e Dívidas

1. **Todos os 12 controllers de feature são eager**: o app inicializa controllers de telas que o usuário pode nunca visitar na sessão atual, desperdiçando memória e tempo de startup.
2. **Repositórios fora do container de DI**: não podem ser mockados em testes sem `Mockito` com `@GenerateMocks` nos controllers — o que não existe no projeto.
3. **Ordem de `Get.put` é uma convenção implícita**: qualquer desenvolvedor que reordenar as linhas sem conhecimento pode introduzir crash em runtime.
4. **`new` explícito**: `new LoginRepository()` — obsoleto e sinalizador de código legado.
5. **Controllers de feature registrados globalmente com `permanent: false` (padrão)**: mas nunca são explicitamente removidos via `Get.delete()` — ficam vivos durante toda a sessão mesmo após sair da tela.

---

## 6. Direção para o Template

### Opção A — GetX com Bindings (direção atual — preservar)

```dart
// main.dart — apenas serviços globais
void main() async {
  Get.put<HttpManagerInterfaces>(HttpManager());
  Get.put<HiveServicesInterface>(HiveServices());
  Get.put<LogServicesInterface>(LogServices());
  runApp(MyApp());
}

// Binding por rota
class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginRepositoryInterface>(() => LoginRepository());
    Get.lazyPut<LoginControllerInterface>(() => LoginController());
  }
}

GetPage(name: '/login', page: () => Login(), binding: LoginBinding())
```

**Vantagens**: baixo custo de migração, mantém GetX, resolve lazy loading e escopo de rota. **Esta é a direção atual do template** — ver [documentation-stance](../00-overview/documentation-stance.md).

> ⚠️ **Consideração futura (NÃO aplicar agora).** A direção atual é preservar a stack (ver [documentation-stance](../00-overview/documentation-stance.md)). O conteúdo abaixo é apenas conhecimento técnico para decisão futura.

### Opção B — `get_it` + `injectable` (alternativa futura, não a direção atual)

```dart
// Registros gerados por code generation com @injectable
@module
abstract class AppModule {
  @singleton
  HttpManager get httpManager;

  @lazySingleton
  LogService get logService;

  @factoryMethod
  LoginRepository loginRepository(HttpManager http) => LoginRepositoryImpl(http);
}
```

Vantagens desta alternativa futura:
- Verificação de dependências em compile-time (via `injectable`).
- Sem singleton global via `Get` — testável com `GetIt.instance.reset()`.
- Separação clara entre singleton de app e factory de feature.
- Compatível com qualquer solução de estado (Riverpod, Bloc, GetX).

Para a equipe atual já familiarizada com GetX DI, a Opção A (Bindings do próprio GetX) é suficiente e não exige nova biblioteca. A Opção B seria avaliada caso o time decida expandir o template para equipes maiores.
