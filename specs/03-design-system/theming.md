# Theming — Design System (T5)

> **Projeto legado analisado:** `controle_separacao_aplicativo`
> **Data da análise:** 2026-06-24
> **Escopo:** Infraestrutura técnica de UI — sem regras de negócio

---

## 1. Estado Atual do Tema

### 1.1 Configuração em `main.dart`

```dart
// lib/main.dart — trecho exato
theme: ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF003A88)),
  scaffoldBackgroundColor: Colors.white.withAlpha(190),
  useMaterial3: true,
),
```

**O que isso significa na prática:**
- Material 3 está ativado (`useMaterial3: true`).
- A cor semente corporativa é `#003A88` (azul escuro). O Material 3 deriva automaticamente toda a `ColorScheme` (primary, secondary, surface, etc.) a partir dessa única cor.
- `scaffoldBackgroundColor` é definido com `Colors.white.withAlpha(190)` — valor semitransparente hardcoded, fora da `ColorScheme`.
- Não há `darkTheme` configurado. Não há `ThemeMode`.
- Não há `TextTheme` customizado, nenhuma família tipográfica definida.
- Não há `InputDecorationTheme`, `AppBarTheme`, `ElevatedButtonTheme`, `CardTheme` centralizados — cada widget configura sua aparência localmente.

---

### 1.2 Arquivo de Cores Customizadas — `CustomColors`

Existem **dois arquivos idênticos** que definem a mesma classe:

| Caminho | Conteúdo |
|---|---|
| `lib/src/core/theme/config/custom_colos.dart` | `abstract class CustomColors { static MaterialColor blue = MaterialColor(0xFF003A88, _opacidade); }` |
| `lib/src/config/custom_colos.dart` | **Idêntico ao acima** — duplicata exata |

**Trecho real (ambos os arquivos):**

```dart
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

> **Problema técnico:** o mapa usa opacidade progressiva em vez de variações reais de luminosidade (como exige um `MaterialColor` correto para `Theme.of(context).primarySwatch`). Não há `red`, `green`, `orange` ou quaisquer outras cores semânticas.

---

### 1.3 Cores Hardcoded Fora do Sistema de Cores

Diversas cores aparecem diretamente nos widgets sem referência ao `Theme`:

| Arquivo | Valor hardcoded | Contexto |
|---|---|---|
| `custom_app_bar.dart` | `Color(0xFF003A88)` | backgroundColor do AppBar |
| `custom_Scaffold_view.dart` | `const Color(0xFF003A88)` | backgroundColor do AppBar interno |
| `custom_error_widget.dart` | `Color(0xFFFFFFFF)` | scaffoldBackgroundColor |
| `custom_error_widget.dart` | `Colors.blueAccent` | cor do texto "ERROR" |
| `custom_expansion.dart` | `Colors.blue[900]`, `Colors.grey[200]`, `Colors.blue[100]` | cores do ExpansionTile |
| `loading.dart` | `Colors.black.withOpacity(0.5)` | overlay de loading |
| `custom_plutoGrid_Table.dart` | `Colors.red.withOpacity(0.1)` | cor de debug, não removida |

---

### 1.4 Tipografia

- **Sem `TextTheme` customizado.** Todo `Text` usa o tamanho padrão do Material 3 ou define `TextStyle` inline.
- Exemplos de estilos inline encontrados:
  - `TextStyle(fontSize: 30, fontWeight: FontWeight.bold)` — título do alert
  - `TextStyle(fontSize: 20)` — corpo do alert
  - `TextStyle(fontSize: 32, fontWeight: FontWeight.bold)` — "ERROR" no error widget
  - `TextStyle(fontSize: 16, color: Colors.black54)` — mensagem do error widget
  - `TextStyle(fontSize: 16.0, color: Colors.white)` — texto do toast
- **Sem fonte customizada registrada** no `pubspec.yaml` (seção `fonts` vazia/comentada).

---

### 1.5 Espaçamentos e Bordas

Não há tokens centralizados. Valores aparecem hardcoded:

| Valor recorrente | Onde aparece |
|---|---|
| `BorderRadius.circular(18)` | `custom_text_field.dart`, `custom_dropwn_button.dart` |
| `BorderRadius.circular(12)` | `custom_expansion.dart` |
| `BorderRadius.circular(8)` | `custom_expansion.dart` (filhos) |
| `BorderRadius.circular(4)` | `custom_item_list_view.dart` |
| `padding: EdgeInsets.all(16)` | `custom_list_view_conteiner.dart`, `custom_error_widget.dart` |
| `margin: EdgeInsets.symmetric(vertical: 4)` | `custom_item_list_view.dart` |

---

### 1.6 Dark Mode

🔴 **Ausente.** Não há `darkTheme`, não há `ThemeMode.system`, não há condicionais de brilho nos componentes.

---

## 2. Diagnóstico e Classificação

| Aspecto | Situação Atual | Classificação |
|---|---|---|
| Material 3 ativado | Sim, via `useMaterial3: true` | ✅ Ponto forte |
| Seed color corporativa única | `#003A88` definida em um lugar no `main.dart` | 🟢 Adequado |
| Arquivo de cores centralizado | Existe, mas **duplicado** e incompleto | 🟠 Problema |
| Cores hardcoded nos widgets | Sim, em 6+ arquivos de componente | 🔴 Crítico |
| TextTheme / Tipografia | Inexistente — tudo inline | 🔴 Crítico |
| Tokens de espaçamento | Inexistentes | 🔴 Crítico |
| Dark mode | Ausente | 🟠 Problema |
| AppBarTheme, ButtonTheme centralizados | Ausentes | 🟠 Problema |
| Fonte customizada | Ausente | 🟡 Atenção |

---

## 3. Recomendação — Design System Tokenizado para o Template

### 3.1 Estrutura de Arquivos Proposta

```
lib/
└── core/
    └── theme/
        ├── app_theme.dart            ← ThemeData light + dark
        ├── tokens/
        │   ├── color_tokens.dart     ← todas as cores semânticas
        │   ├── typography_tokens.dart ← TextTheme completo
        │   └── spacing_tokens.dart   ← raios, padding, margin
        └── components/
            ├── app_bar_theme.dart
            ├── button_theme.dart
            ├── input_decoration_theme.dart
            └── card_theme.dart
```

### 3.2 `color_tokens.dart` — Modelo Recomendado

```dart
abstract class ColorTokens {
  // Primária corporativa
  static const Color primary        = Color(0xFF003A88);
  static const Color primaryLight   = Color(0xFF4F65B8);
  static const Color primaryDark    = Color(0xFF001F5A);

  // Semânticas
  static const Color success        = Color(0xFF2E7D32);
  static const Color warning        = Color(0xFFF57F17);
  static const Color error          = Color(0xFFB71C1C);
  static const Color info           = Color(0xFF01579B);

  // Neutras
  static const Color surface        = Color(0xFFFFFFFF);
  static const Color surfaceDim     = Color(0xFFF5F5F5);
  static const Color onSurface      = Color(0xFF1C1B1F);
  static const Color outline        = Color(0xFF79747E);

  // Overlay
  static const Color overlayDark    = Color(0x80000000); // 50% opacidade
}
```

### 3.3 `typography_tokens.dart` — Modelo Recomendado

```dart
abstract class TypographyTokens {
  static const TextTheme textTheme = TextTheme(
    displayLarge:  TextStyle(fontSize: 57, fontWeight: FontWeight.w400),
    headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
    headlineMedium:TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
    titleLarge:    TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
    titleMedium:   TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    bodyLarge:     TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
    bodyMedium:    TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
    labelLarge:    TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    labelSmall:    TextStyle(fontSize: 10, fontWeight: FontWeight.w400),
  );
}
```

### 3.4 `spacing_tokens.dart` — Modelo Recomendado

```dart
abstract class SpacingTokens {
  // Espaçamentos
  static const double xs  = 4.0;
  static const double sm  = 8.0;
  static const double md  = 16.0;
  static const double lg  = 24.0;
  static const double xl  = 32.0;
  static const double xxl = 48.0;

  // Raios de borda (tokens semânticos)
  static const double radiusXs = 4.0;   // cards pequenos, chips
  static const double radiusSm = 8.0;   // itens de lista
  static const double radiusMd = 12.0;  // cards, expansion tiles
  static const double radiusLg = 18.0;  // campos de texto, dropdowns
  static const double radiusFull = 50.0; // botões pill / FAB

  // Alturas fixas
  static const double inputHeight  = 50.0;
  static const double appBarHeight = 56.0;
}
```

### 3.5 `app_theme.dart` — Modelo Recomendado

```dart
abstract class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: ColorTokens.primary,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: ColorTokens.surface,
    textTheme: TypographyTokens.textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: ColorTokens.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
    ),
    inputDecorationTheme: InputDecorationTheme(
      isDense: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
      ),
    ),
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: ColorTokens.primary,
      brightness: Brightness.dark,
    ),
    textTheme: TypographyTokens.textTheme,
    // ... demais overrides para dark
  );
}
```

---

## 4. Pontos Fortes do Legado Aproveitáveis

1. **Seed color já está isolada em um único valor** — fácil migrar para `ColorTokens.primary`.
2. **Material 3 já está ativo** — sem necessidade de migração de sistema de design.
3. **`MaterialColor` com variações de opacidade** — padrão não ideal, mas estrutura de classe `CustomColors` pode ser convertida para `ColorTokens` sem ruptura.
4. **`scaffoldBackgroundColor` parametrizado** — já diferenciado do `surface` padrão do M3, indicando consciência de customização.
