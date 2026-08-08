# Navegação — GetX Router

> **Escopo T2 — Infraestrutura técnica apenas. Regras de negócio excluídas.**
> Projeto analisado: `controle_separacao_aplicativo` · Pacote: `get: 4.7.2` (versão resolvida no lock; declarada como `^4.6.6`)

---

## 1. Visão Geral

O projeto usa `GetMaterialApp` com roteamento declarativo via `getPages`. As rotas são nomeadas (strings), centralizadas em um `enum PagesRoutes` e mapeadas em `AppPages`. A navegação ocorre via métodos estáticos do `Get` (`Get.toNamed`, `Get.offNamed`, `Get.back`). Não há route guards, rotas tipadas, deep links ou transições customizadas.

---

## 2. Como Funciona Hoje

### 2.1 Configuração do `GetMaterialApp`

```dart
// main.dart → MyApp
GetMaterialApp(
  title: 'Controle de Separação',
  debugShowCheckedModeBanner: false,
  initialRoute: PagesRoutes.splashScreen.path,   // '/splash_screen'
  getPages: AppPages.pages,
  builder: (context, child) {
    return Stack(
      children: [
        child!,
        LoadingWidget(),   // overlay global de loading
      ],
    );
  },
)
```

O `builder` do `GetMaterialApp` é usado para injetar o overlay global de loading acima de todas as rotas — padrão eficiente.

### 2.2 Enum `PagesRoutes` — Centralização das Strings de Rota

```dart
enum PagesRoutes {
  splashScreen('/splash_screen'),
  login('/login'),
  nfsPedidos('/nfs_pedidos'),
  itensNf('/itens_nf'),
  conferirMaterialEntrada('/conferir_material_entrada'),
  itensPedidoSaida('/itens_pedido_saida'),
  selecionarMaterialEstoque('/selecionar_material_estoque'),
  conferirMaterialSaida('/conferir_material_saida'),
  settingsApp('/Settings_App'),          // ← capital S inconsistente
  ConsultaNfSaida('/consulta_nf_saida'), // ← nome do enum em PascalCase (inconsistente)
  ConsultaLotesSaida('/consulta_lotes_saida'),
  Trasferencia('/buscar_produtos'),       // ← nome ≠ rota (confuso)
  conferirMaterialTrasferencia('/conferir_material_transferencia'),
  Trasferencialote('/trasferencia_industria');

  final String path;
  const PagesRoutes(this.path);
}
```

O enum é a única centralização de rotas — elimina strings literais espalhadas pelo código. Porém apresenta inconsistências de nomenclatura.

### 2.3 `AppPages` — Mapeamento Ativo de Rotas

```dart
// lib/src/routes/app_pages.dart (ATIVO — 14 rotas)
abstract class AppPages {
  static final pages = <GetPage>[
    GetPage(page: () => SplashScreen(), name: PagesRoutes.splashScreen.path),
    GetPage(page: () => Login(),        name: PagesRoutes.login.path),
    GetPage(page: () => NfsPedidos(),   name: PagesRoutes.nfsPedidos.path),
    GetPage(page: () => ItensNf(),      name: PagesRoutes.itensNf.path),
    GetPage(page: () => ConferirMaterialEntrada(), name: PagesRoutes.conferirMaterialEntrada.path),
    GetPage(page: () => ItensPedidoSaida(), name: PagesRoutes.itensPedidoSaida.path),
    GetPage(page: () => SelecionarMaterialEstoque(), name: PagesRoutes.selecionarMaterialEstoque.path),
    GetPage(page: () => ConferirMaterialSaida(), name: PagesRoutes.conferirMaterialSaida.path),
    GetPage(page: () => SettingsApp(),  name: PagesRoutes.settingsApp.path),
    GetPage(page: () => ConsultaNfSaida(), name: PagesRoutes.ConsultaNfSaida.path),
    GetPage(page: () => ConsultaLotesSaida(), name: PagesRoutes.ConsultaLotesSaida.path),
    GetPage(page: () => BuscarProdutos(), name: PagesRoutes.Trasferencia.path),  // ← widget ≠ nome da rota
    GetPage(page: () => ConferirMaterialTransferencia(), name: PagesRoutes.conferirMaterialTrasferencia.path),
    GetPage(page: () => TrasferenciaIndustria(), name: PagesRoutes.Trasferencialote.path),
  ];
}
```

### 2.4 Arquivo Legado / Morto

```
lib/src/pages_routes/app_pages.dart  ← LEGADO (9 rotas, aponta para lib/src/pages/ que é código morto)
lib/src/routes/app_pages.dart        ← ATIVO (14 rotas, aponta para lib/src/core/features/)
```

O arquivo legado (`pages_routes/app_pages.dart`) importa views de `lib/src/pages/` (pasta de código morto) e tem apenas 9 rotas. O `main.dart` importa corretamente o ativo. O arquivo legado não é referenciado pelo app em runtime, mas sua presença confunde a leitura do código.

### 2.5 Métodos de Navegação Utilizados

| Método | Onde é Usado | Comportamento |
|---|---|---|
| `Get.toNamed(path)` | Controllers e views | Empilha nova rota |
| `Get.toNamed(path, arguments: {...})` | Controllers | Empilha com argumentos `Map<String,dynamic>` |
| `Get.offNamed(path)` | `LoginController.signIn` | Substitui rota atual (sem voltar ao login) |
| `Get.back()` | Controllers e views | Desempilha (volta) |
| `Navigator.of(context).pop()` | `LoginController.loginSettings` | Flutter nativo misturado ao GetX |

#### Exemplos reais:

```dart
// LoginController — offNamed após login bem-sucedido
Get.offNamed(PagesRoutes.nfsPedidos.path);

// LoginController — Get.toNamed para settings + Navigator.pop misturado
Navigator.of(context).pop();        // fecha dialog (Flutter nativo)
Get.toNamed(PagesRoutes.settingsApp.path); // abre settings (GetX)

// NfsPedidosController — toNamed com argumentos Map
await Get.toNamed(PagesRoutes.itensNf.path, arguments: {
  'objNf': jsonDecode(jsonEncode(objNf)),
  'manterDadosCacher': 'null',      // ← string 'null' em vez de null real
});

// BuscarProdutosController — toNamed com três argumentos
await Get.toNamed(PagesRoutes.selecionarMaterialEstoque.path, arguments: {
  'tipoPocesso': 'Trasferencia',    // ← typo: "Pocesso" em vez de "Processo"
  'item': item,
  'objTransferencia': respTransf.first.toJson(),
});

// SplashScreen — offNamed após delay
Get.offNamed(PagesRoutes.login.path);

// ConferirMaterialEntradaController — Get.back()
Get.back();
```

### 2.6 Passagem de Argumentos

Argumentos são passados como `Map<String, dynamic>` sem tipagem. A tela receptora lê via `Get.arguments`:

```dart
// Receptor (inferido pelo padrão do projeto)
final args = Get.arguments as Map<String, dynamic>;
final objNf = args['objNf'];
final manterDadosCacher = args['manterDadosCacher']; // string 'null', 'true', 'false'
```

Problemas identificados:
- String `'null'` em vez de `null` literal — a tela receptora compara `== 'null'` (verificado em `ItensNfEntradaController.dadosCacher`).
- Typos nas chaves: `'tipoPocesso'` em vez de `'tipoProcesso'`.
- Sem contrato formal: a tela receptora pode receber `null` se a chave mudar no emissor.

### 2.7 Ausência de Route Guards

Não há middleware de autenticação em nenhuma rota. O fluxo de proteção é manual: `LoginController.signIn` navega para `nfsPedidos` apenas se o login for bem-sucedido. Se o usuário manipular a navegação (deep link ou back button), pode acessar telas sem autenticação.

```dart
// GetPage NÃO tem middlewares — o que seria o correto para auth
GetPage(
  name: PagesRoutes.nfsPedidos.path,
  page: () => NfsPedidos(),
  // middlewares: [AuthMiddleware()],  ← ausente
)
```

---

## 3. Inventário e Classificação

| Item | Classificação | Justificativa |
|---|---|---|
| `GetMaterialApp` com `getPages` | 🟢 Reutilizar com melhorias | Funciona; no template moderno preferir `go_router` para deep links e guards nativos |
| `enum PagesRoutes` como centralizador de strings | 🟢 Reutilizar com melhorias | Boa ideia; refatorar nomenclatura inconsistente (PascalCase nos valores do enum) |
| `Get.toNamed()` / `Get.back()` | 🟢 Reutilizar com melhorias | APIs simples e funcionais; manter se ficar em GetX, substituir por `context.go()` se migrar para go_router |
| `Get.offNamed()` para login/logout | ✅ Reutilizar sem alterações | Uso correto para limpar pilha de navegação após autenticação |
| Passagem de argumentos via `Map<String,dynamic>` | 🟠 Substituir | Sem tipagem, sem contrato; substituir por objetos tipados ou parâmetros de rota |
| String `'null'` em vez de `null` | 🔴 Descartar | Bug latente; substituir por `null` real com verificação nullable |
| Mistura de `Navigator.of(context)` e `Get` | 🟡 Refatorar | Inconsistente; padronizar em um único sistema |
| Ausência de route guards | 🟠 Substituir | Sem proteção de rotas autenticadas; implementar `GetMiddleware` (mesma lib) |
| Arquivo legado `pages_routes/app_pages.dart` | 🔴 Descartar | Código morto, confunde leitura; deletar |
| Typos nas chaves de argumentos (`tipoPocesso`) | 🔴 Descartar | Dívida de manutenção; corrigir e tipar |
| `GetPage` sem Bindings | 🟠 Substituir | Oportunidade perdida de lazy DI por rota; adicionar `Bindings` do GetX (mesma lib) |
| Overlay de loading via `builder` do GetMaterialApp | ✅ Reutilizar sem alterações | Padrão elegante e eficiente para loading global |

---

## 4. Pontos Fortes (Manter)

- **Enum `PagesRoutes`**: elimina strings literais espalhadas no código — todos os callsites usam o enum, não strings hardcoded.
- **`Get.offNamed` no fluxo de login**: uso correto para limpar o backstack após autenticação, impedindo que o usuário volte à splash/login com o botão Android.
- **`initialRoute` configurado**: o app define explicitamente a rota inicial, não dependendo de comportamento implícito.
- **Loading overlay via `builder`**: limpo e não intrusivo para as rotas individuais.

---

## 5. Problemas e Dívidas

1. **Ausência de route guards**: qualquer rota pode ser acessada diretamente via deep link sem autenticação.
2. **Argumentos como `Map<String,dynamic>` sem tipagem**: mudança de chave no emissor quebra o receptor em runtime sem erro em compile-time.
3. **String `'null'` como valor sentinela**: `arguments: {'manterDadosCacher': 'null'}` — o receptor compara `if (manterDadosCacher == 'null')`, frágil e confuso.
4. **Arquivo legado não deletado**: `lib/src/pages_routes/app_pages.dart` e `lib/src/pages/` são código morto que confunde novos desenvolvedores.
5. **Inconsistência de nomenclatura no enum**: valores como `ConsultaNfSaida`, `Trasferencia`, `Trasferencialote` misturam convenções (PascalCase com camelCase).
6. **`GetPage` sem Bindings**: controllers são resolvidos do singleton global, não do escopo da rota.
7. **Mistura de `Navigator` e `Get`**: `LoginController` usa `Navigator.of(context).pop()` para fechar dialog e `Get.toNamed()` para navegar — inconsistência desnecessária.
8. **Typo propagado**: `'tipoPocesso'` (em vez de `'tipoProcesso'`) aparece em dois controllers diferentes, indicando que foi copiado sem correção.

---

## 6. Direção para o Template

### Opção A — GetX com Middlewares (direção atual — preservar)

Adicionar `GetMiddleware` para autenticação e tipar argumentos, **mantendo a navegação GetX atual**. Esta é a direção do template — ver [documentation-stance](../00-overview/documentation-stance.md).

```dart
// Middleware de autenticação
class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final isLogged = Get.find<AuthService>().isLogged;
    return isLogged ? null : RouteSettings(name: PagesRoutes.login.path);
  }
}

// Rota protegida
GetPage(
  name: PagesRoutes.nfsPedidos.path,
  page: () => NfsPedidos(),
  middlewares: [AuthMiddleware()],
  binding: NfsPedidosBinding(),
)

// Argumentos tipados em vez de Map
class ItensNfArgs {
  final NfModel objNf;
  final bool? manterDadosCache;
  const ItensNfArgs({required this.objNf, this.manterDadosCache});
}
Get.toNamed(PagesRoutes.itensNf.path, arguments: ItensNfArgs(objNf: nf));
```

> ⚠️ **Consideração futura (NÃO aplicar agora).** A direção atual é preservar a stack (ver [documentation-stance](../00-overview/documentation-stance.md)). O conteúdo abaixo é apenas conhecimento técnico para decisão futura.

### Opção B — `go_router` (alternativa futura, não a direção atual)

```dart
final router = GoRouter(
  initialLocation: '/splash',
  redirect: (context, state) {
    final isLogged = ref.read(authProvider).isLogged;
    if (!isLogged && state.matchedLocation != '/login') return '/login';
    return null;
  },
  routes: [
    GoRoute(path: '/splash', builder: (_, __) => SplashScreen()),
    GoRoute(path: '/login',  builder: (_, __) => Login()),
    GoRoute(
      path: '/nfs-pedidos',
      builder: (_, __) => NfsPedidos(),
      routes: [
        GoRoute(
          path: 'itens-nf',
          builder: (_, state) => ItensNf(args: state.extra as ItensNfArgs),
        ),
      ],
    ),
  ],
);
```

**Vantagens do `go_router`**:
- Deep links nativos com URLs hierárquicas (`/nfs-pedidos/itens-nf`).
- `redirect` global como route guard declarativo.
- `state.extra` tipado ou parâmetros de path nomeados.
- Integração nativa com Flutter (parte do ecossistema oficial).
- Suporte a sub-rotas e shell routes para navegação aninhada (bottom nav).

Os benefícios técnicos do `go_router` incluem deep linking nativo, `redirect` global como route guard declarativo, `state.extra` tipado e suporte a sub-rotas e shell routes. Para a equipe atual já dominando o roteamento GetX, a Opção A com `GetMiddleware` é a evolução natural sem custo de reaprendizado.
