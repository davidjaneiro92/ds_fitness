# Convenções de Desenvolvimento e Lint — Template Flutter Corporativo

**Escopo:** T6 — Qualidade: Convenções e Lint  
**Fonte de análise:** `controle_separacao_aplicativo` (projeto legado, somente leitura)  
**Data:** 2026-06-24

---

## 1. Estado Atual do Lint

### 1.1 Configuração de `analysis_options.yaml`

```yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    # avoid_print: false  # comentado = desabilitado
    # prefer_single_quotes: true  # comentado = desabilitado
```

**Classificação:** 🟠 INSUFICIENTE — Usa apenas `flutter_lints` no nível mínimo, sem nenhuma regra customizada ativa. As duas regras mais relevantes para o projeto (`avoid_print` e `prefer_single_quotes`) estão explicitamente deixadas como comentário, sinalizando que foram consideradas e descartadas.

### 1.2 Versão do `flutter_lints`

```yaml
flutter_lints: ^4.0.0
```

A versão 4.0.0 é a mais recente da série, o que é positivo. Porém, o conjunto de regras do `flutter_lints` é deliberadamente conservador e cobre apenas o básico. **Não há `very_good_analysis`, `lints` direto do SDK nem regras customizadas.**

---

## 2. Convenções Observadas vs. Recomendadas

### 2.1 Nomenclatura de Arquivos

**Observado no projeto legado:**

| Arquivo real encontrado | Problema |
|---|---|
| `lib/src/services/Hive_services.dart` | Letra maiúscula no início (`Hive_`) — viola `snake_case` |
| `lib/src/Interfaces/Hive_services_interface.dart` | Pasta `Interfaces/` com I maiúsculo |
| `lib/src/components/custom_Scaffold/` | Pasta com S maiúsculo no meio |
| `lib/src/components/custom_Scaffold/view/custom_Scaffold_view.dart` | Arquivo com S maiúsculo |
| `lib/src/core/services/Hive_services.dart` | Duplica o padrão errado |
| `lib/src/core/abstracts/Hive_services_interface.dart` | Duplica o padrão errado |
| `lib/src/components/custom_dropwn_button.dart` | Typo: `dropwn` em vez de `dropdown` |
| `lib/src/core/theme/config/custom_colos.dart` | Typo: `colos` em vez de `colors` |

**Padrão correto (Dart/Flutter):** todos os arquivos `.dart` devem usar exclusivamente `snake_case` minúsculo.

### 2.2 Nomenclatura de Classes

**Observado:**

| Classe real encontrada | Problema |
|---|---|
| `class SomaPesoComman` | Typo: `Comman` em vez de `Command` |
| `class TransferenciaSomaPesoComman` | Mesmo typo propagado |
| `class UsuarioValidator` | Função de validação com PascalCase — deveria ser `usuarioValidator` |
| `abstract class TrasferenciaIndustriaControllerInterface` | `Trasferencia` (typo) em vez de `Transferencia` |
| `class TrasferenciaIndustriaController` | Mesmo typo propagado |
| `class ConfirmarConferenciaTrasferenciaCommand` | Mesmo typo propagado |

**Padrão correto:** Classes em `PascalCase`, funções/métodos/variáveis em `camelCase`.

### 2.3 Nomenclatura de Métodos

**Observado:**

| Método real encontrado | Arquivo | Problema |
|---|---|---|
| `Future<bool> Refreshtoken()` | `login_repository_interface.dart` | Letra maiúscula (`R`) — viola `camelCase` |
| `void PopupMenuButton(String item, BuildContext context)` | `custom_scaffold_controller_interface.dart` | PascalCase em método — viola `camelCase` |
| `Future<void> CarregaCustomDropdownButton()` | `buscar_produtos_controller.dart` | PascalCase em método — viola `camelCase` |
| `String? UsuarioValidator(String?)` | `validators.dart` | PascalCase em função — viola `camelCase` |

### 2.4 Typos Propagados por Todo o Codebase

| Typo encontrado | Ocorrências (estimado) | Correto |
|---|---|---|
| `Trasferencia` / `trasferencia` | 20+ (pastas, classes, enums, routes) | `Transferencia` / `transferencia` |
| `colos` | 3 (arquivo `custom_colos.dart` e imports) | `colors` |
| `dropwn` | 5+ (arquivo `custom_dropwn_button.dart` e imports) | `dropdown` |
| `menssage` | 2 (`http_manager.dart`) | `message` |
| `messagem` | 10+ (`custom_toast.dart` e usos) | Inconsistente (mistura PT/EN) |
| `nameFild` | 8+ (interfaces e implementações) | `nameField` |
| `servido` | 1 (`http_manager.dart`: "o servido não responde") | `servidor` |
| `SomaPesoComman` | 2 (classes distintas) | `SomaPesoCommand` |
| `conteiner` | 3+ (métodos e arquivos) | `container` |
| `Cacher` | 4+ (strings de log) | `Cache` |

### 2.5 Mistura PT/EN (Bi-linguismo Não Controlado)

**Observado:** O projeto mistura Português e Inglês de forma inconsistente dentro do mesmo contexto técnico.

| Categoria | Exemplos em PT | Exemplos em EN | Problema |
|---|---|---|---|
| Nomes de métodos | `limparTodoCache()`, `carregaUsuario()` | `setCache()`, `getCache()`, `deleteCache()` | Sem critério definido |
| Parâmetros | `nameFild` (typo EN), `messagem` (PT) | `method`, `headers`, `body`, `url` | Mistura aleatória |
| Comentários | "Erro ao salvar...", "Atenção" | "Bearer", "content-type" | Aceitável para termos técnicos |
| Strings de UI | "Digite seu email!", "Salvo com sucesso" | — | PT — adequado para usuário brasileiro |
| Nomes de classes | `FormatarValores`, `HiveServices` | `LoginController`, `HttpManager` | Sem regra clara |

### 2.6 Uso de `print()` em Produção

**Evidência:** 35+ ocorrências de `print()` no código de produção.

Locais com `print()` identificados:

| Arquivo | Contexto |
|---|---|
| `http_manager.dart` | Depuração de erros HTTP (`print('chegue 1')`, `print(' chegue 2')`) |
| `Hive_services.dart` | Catch de exceção em setCache |
| `log_services.dart` | Debug de envio de logs |
| `buscar_produtos_repository.dart` | 4 ocorrências em catches |
| `itens_pedido_saida_controller.dart` | `print('Item clicado: $item')` |
| `selecionar_material_estoque_repository.dart` | `print()` fora de try/catch, no nível de método |
| `conferir_material_saida_controller.dart` | `print(barcode)` — dados possivelmente sensíveis |
| `conferir_material_entrada_controller.dart` | `print('Imagem em Base64: $_base64Image')` — dado sensível em log |

**Classificação:** 🔴 CRÍTICO — O projeto tem um `LogServices` com `logger` integrado (dependência `logger: ^2.5.0`), mas o `print()` é usado em paralelo, de forma inconsistente, inclusive em locais que expõem dados sensíveis (Base64 de imagem, barcode scanneado).

### 2.7 Estrutura de Pastas

**Observado:** O projeto tem **dois sistemas de pastas em coexistência** — um legado (`lib/src/pages/`, `lib/src/services/`, `lib/src/Interfaces/`) e um novo (`lib/src/core/features/`, `lib/src/core/abstracts/`, `lib/src/core/services/`). Muitos arquivos existem duplicados nas duas estruturas.

| Localização legada | Localização nova (core) |
|---|---|
| `lib/src/services/Hive_services.dart` | `lib/src/core/services/Hive_services.dart` |
| `lib/src/Interfaces/Hive_services_interface.dart` | `lib/src/core/abstracts/Hive_services_interface.dart` |
| `lib/src/pages/login/` | `lib/src/core/features/login/` |
| `lib/src/pages/settings_app/` | `lib/src/core/features/settings_app/` |

**Classificação:** 🔴 CRÍTICO — Duplicação de código, ambiguidade sobre qual versão é canônica, risco de manutenção divergente.

---

## 3. Tabela Consolidada de Inconsistências Reais

| # | Inconsistência | Categoria | Evidência (arquivo real) | Impacto |
|---|---|---|---|---|
| 1 | `Hive_services.dart` com H maiúsculo e underscore após | Capitalização de arquivo | `lib/src/services/Hive_services.dart` | Violação do padrão Dart |
| 2 | Pasta `Interfaces/` com I maiúsculo | Capitalização de pasta | `lib/src/Interfaces/` | Inconsistência no sistema de arquivos |
| 3 | Pasta `custom_Scaffold/` com S maiúsculo | Capitalização de pasta | `lib/src/components/custom_Scaffold/` | Violação do padrão Dart |
| 4 | Arquivo `custom_colos.dart` (typo) | Typo em nome de arquivo | `lib/src/config/custom_colos.dart` | Typo propagado em 3+ imports |
| 5 | Arquivo `custom_dropwn_button.dart` (typo) | Typo em nome de arquivo | `lib/src/components/custom_dropwn_button.dart` | Typo propagado em 5+ imports |
| 6 | `Trasferencia` em 20+ locais (typo) | Typo propagado | pastas, classes, enum, rotas | Typo sistêmico no domínio |
| 7 | `class SomaPesoComman` (typo) | Typo em nome de classe | `soma_peso_command.dart` | Duas classes com mesmo typo |
| 8 | `Future<bool> Refreshtoken()` (PascalCase) | camelCase violado em método | `login_repository_interface.dart` | Interface pública com nome errado |
| 9 | `void PopupMenuButton(...)` (PascalCase) | camelCase violado em método | `custom_scaffold_controller_interface.dart` | Interface pública com nome errado |
| 10 | `CarregaCustomDropdownButton()` (PascalCase) | camelCase violado em método | `buscar_produtos_controller.dart` | Método público com nome errado |
| 11 | `String? UsuarioValidator(...)` (PascalCase) | camelCase violado em função | `validators.dart` | Função pública com nome errado |
| 12 | `nameFild` em 8+ assinaturas | Typo em parâmetro de API | interfaces e serviços | API pública com typo |
| 13 | `messagem` (parâmetro) vs `message` | Bi-linguismo em parâmetro | `custom_toast.dart` e usos | Confunde nomes de parâmetros |
| 14 | `menssage` (variável) | Typo em variável local | `http_manager.dart:84` | Baixo impacto mas sinaliza descuido |
| 15 | `print()` em 35+ pontos | Uso de print em produção | múltiplos arquivos de serviço | Log não estruturado, dado sensível exposto |
| 16 | Dupla estrutura `pages/` + `core/features/` | Duplicação arquitetural | todo `lib/src/` | Ambiguidade sobre código canônico |
| 17 | `import 'package:get/get.dart' as Importgetx;` | Alias de import com PascalCase | `http_manager.dart:5` | Violação de convenção de alias |
| 18 | `Box box = Hive.box('Cache_aplicativo')` | Nome de box com underscore+maiúsculo | `Hive_services.dart:16` | Inconsistência em strings de chave |

---

## 4. Lint Recomendado para o Template

### 4.1 Comparação: `flutter_lints` vs. `very_good_analysis`

| Aspecto | `flutter_lints` (atual) | `very_good_analysis` (recomendado) |
|---|---|---|
| Regras de estilo | Básico | Extensivo (100+ regras) |
| `avoid_print` | Opcional (desligado) | Obrigatório |
| `prefer_single_quotes` | Opcional (desligado) | Obrigatório |
| `always_declare_return_types` | Não incluso | Obrigatório |
| `unawaited_futures` | Não incluso | Obrigatório |
| `prefer_final_fields` | Não incluso | Obrigatório |
| Maturidade | Alta (padrão Flutter) | Alta (Very Good Ventures) |
| Adoção corporativa | Universal | Crescente |

**Recomendação:** adotar `very_good_analysis` como base, com customizações.

### 4.2 `analysis_options.yaml` recomendado para o template

```yaml
# Template Flutter Corporativo — Lint Configuration
include: package:very_good_analysis/analysis_options.yaml

analyzer:
  exclude:
    - "**/*.g.dart"          # Arquivos gerados (json_serializable, hive)
    - "**/*.freezed.dart"    # Arquivos gerados (freezed)
    - "build/**"
  
  errors:
    # Tratar avisos como erros no CI
    missing_required_param: error
    missing_return: error
    dead_code: warning
    invalid_annotation_target: ignore  # Para json_annotation

linter:
  rules:
    # Estilo
    prefer_single_quotes: true
    always_declare_return_types: true
    avoid_print: true
    sort_constructors_first: true
    prefer_const_constructors: true
    prefer_const_declarations: true
    
    # Qualidade
    unawaited_futures: true
    always_put_required_named_parameters_first: true
    avoid_dynamic_calls: true
    avoid_void_async: false  # GetX usa void async em onInit
    
    # Organização de imports
    directives_ordering: true
    
    # Segurança
    avoid_catching_errors: true
    avoid_returning_null_for_void: true
    
    # Desabilitados deliberadamente (GetX e arquitetura do template)
    prefer_final_parameters: false  # Incompatível com GetX controllers
    one_member_abstracts: false     # Interfaces com 1 método são válidas no padrão do template
```

### 4.3 Regras de Lint por categoria de impacto

| Regra | Categoria | Impacto no projeto legado | Prioridade |
|---|---|---|---|
| `avoid_print` | Qualidade | 35+ violações | Alta |
| `always_declare_return_types` | Segurança | Vários métodos `void` async sem retorno explícito | Alta |
| `prefer_single_quotes` | Estilo | Mistura de aspas simples e duplas | Média |
| `unawaited_futures` | Segurança | `void setCache()` chama `await` sem retorno `Future` | Alta |
| `directives_ordering` | Organização | Imports fora de ordem em múltiplos arquivos | Média |
| `prefer_const_constructors` | Performance | Widgets sem `const` onde possível | Média |
| `avoid_dynamic_calls` | Segurança | `box.get()` retorna `dynamic` sem cast | Média |

### 4.4 Ordernação de imports recomendada

O template deve seguir a ordenação padrão do `import_sorter` ou da regra `directives_ordering`:

```dart
// 1. Imports do Dart SDK
import 'dart:async';
import 'dart:convert';

// 2. Imports de packages (pub.dev)
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// 3. Imports internos do projeto (package:nome_projeto/...)
import 'package:template_app/src/core/abstracts/http_manager_interfaces.dart';

// 4. Imports relativos (somente em casos justificados)
import '../abstracts/log_services_interface.dart';
```

---

## 5. Convenções de Nomenclatura Recomendadas para o Template

### 5.1 Tabela de regras de nomenclatura

| Artefato | Padrão | Exemplo correto | Exemplo errado (legado) |
|---|---|---|---|
| Arquivos `.dart` | `snake_case` minúsculo | `hive_services.dart` | `Hive_services.dart` |
| Pastas | `snake_case` minúsculo | `interfaces/`, `custom_scaffold/` | `Interfaces/`, `custom_Scaffold/` |
| Classes | `PascalCase` | `HiveServices`, `LoginController` | `TrasferenciaIndustria` (typo) |
| Interfaces/abstracts | `PascalCase` + sufixo `Interface` | `LoginRepositoryInterface` | `HttpManagerInterfaces` (plural) |
| Métodos públicos | `camelCase` | `refreshToken()`, `loadUser()` | `Refreshtoken()`, `CarregaCustomDropdownButton()` |
| Parâmetros e variáveis | `camelCase` | `nameField`, `message` | `nameFild`, `messagem` |
| Constantes | `lowerCamelCase` ou `SCREAMING_SNAKE` para constantes globais | `maxRetries`, `MAX_RETRIES` | `Cache_aplicativo` |
| Enums | `PascalCase` (tipo) + `camelCase` (valores) | `HttpMethod.get` | `PagesRoutes.Trasferencia` |
| Extensions | `PascalCase` | `StringExtension` | — |

### 5.2 Idioma do código

O template deve definir uma política clara de idioma:

| Contexto | Idioma recomendado | Justificativa |
|---|---|---|
| Nomes de classes, métodos, variáveis | **Inglês** | Padrão universal Dart/Flutter, compatível com ferramentas |
| Comentários de código | **Português (PT-BR)** | Time local, reduz barreira de leitura |
| Strings de UI | **Português (PT-BR)** | Usuário final brasileiro |
| Mensagens de log (técnico) | **Inglês** | Facilita busca em logs e ferramentas de monitoramento |
| Nomes de arquivos | **Inglês** | Consistência com ecossistema Flutter |

**Proibido:** misturar idiomas no mesmo identificador (ex: `postTrasferencia`, `messagem`, `nameFild`).

### 5.3 Política para `print()` vs. `logger`

O template já possui `logger: ^2.5.0` como dependência. A regra para o template:

```dart
// PROIBIDO no template:
print('Erro: $e');
print('Item clicado: $item');

// CORRETO — usar o LogService injetado:
_log.warning('Erro ao salvar cache', error: e);
_log.debug('Item selecionado', data: {'item': item.id});
```

Regra de lint que enforça isso: `avoid_print: true` no `analysis_options.yaml`.

---

## 6. Conventional Commits

O template deve adotar [Conventional Commits 1.0.0](https://www.conventionalcommits.org/):

### 6.1 Formato obrigatório

```
<tipo>(<escopo>): <descrição curta>

[corpo opcional]

[rodapé opcional: BREAKING CHANGE, closes #123]
```

### 6.2 Tipos válidos

| Tipo | Uso |
|---|---|
| `feat` | Nova funcionalidade |
| `fix` | Correção de bug |
| `refactor` | Refatoração sem mudança de comportamento |
| `test` | Adição ou correção de testes |
| `docs` | Documentação |
| `style` | Formatação, lint (sem mudança de lógica) |
| `chore` | Tarefas de manutenção (deps, CI, build) |
| `perf` | Melhoria de performance |

### 6.3 Escopos recomendados para o template

```
feat(login): adicionar refresh token automático
fix(http): corrigir timeout em conexões lentas
refactor(hive): renomear nameFild para nameField
test(validators): adicionar testes para emailValidator
chore(deps): atualizar flutter para 3.24.4
```

---

## 7. Pre-commit Hooks Recomendados

### 7.1 Instalação com `lefthook` (recomendado para Flutter)

```yaml
# lefthook.yml
pre-commit:
  parallel: false
  commands:
    format:
      glob: "*.dart"
      run: dart format --output=none --set-exit-if-changed {staged_files}
      
    analyze:
      run: flutter analyze --fatal-infos
      
    test-unit:
      run: flutter test test/unit/ --no-pub
      
commit-msg:
  commands:
    conventional:
      run: |
        MSG=$(cat {1})
        if ! echo "$MSG" | grep -qE "^(feat|fix|refactor|test|docs|style|chore|perf)(\(.+\))?: .{1,100}"; then
          echo "ERRO: Commit deve seguir Conventional Commits"
          echo "Exemplo: feat(login): adicionar autenticação por biometria"
          exit 1
        fi
```

### 7.2 Alternativa: `husky` + `commitlint` (se projeto usar Node.js no CI)

Para projetos com toolchain misto:

```json
// .commitlintrc.json
{
  "extends": ["@commitlint/config-conventional"],
  "rules": {
    "scope-enum": [2, "always", [
      "login", "http", "hive", "logger", "theme", "routing",
      "validators", "components", "ci", "deps"
    ]]
  }
}
```

---

## 8. Formatação

### 8.1 Padrão obrigatório

```bash
# Formatar todos os arquivos Dart:
dart format lib/ test/

# Verificar sem alterar (para CI):
dart format --output=none --set-exit-if-changed lib/ test/
```

### 8.2 Largura de linha

O template deve adotar **80 caracteres** (padrão Dart oficial). Configuração no `analysis_options.yaml`:

```yaml
# Nenhuma config necessária — 80 chars é o default do dart format
```

Para IDEs: configurar o formatar ao salvar (VS Code: `editor.formatOnSave: true`, `editor.defaultFormatter: "Dart-Code.dart-code"`).

---

## 9. Resumo de Classificações

| Aspecto | Estado Atual | Classificação | Recomendação Prioritária |
|---|---|---|---|
| Lint base (`flutter_lints`) | Mínimo, sem regras customizadas | 🟠 INSUFICIENTE | Migrar para `very_good_analysis` |
| `avoid_print` | Desabilitado; 35+ violações | 🔴 CRÍTICO | Ativar + substituir por logger injetado |
| Capitalização de arquivos/pastas | `Hive_services.dart`, `Interfaces/`, `custom_Scaffold/` | 🔴 CRÍTICO | Renomear para `snake_case` minúsculo |
| Typos sistêmicos | `trasferencia`, `colos`, `dropwn`, `nameFild` | 🔴 CRÍTICO | Renomear com busca e substituição global |
| PascalCase em métodos | `Refreshtoken()`, `PopupMenuButton()`, `CarregaCustomDropdownButton()` | 🔴 CRÍTICO | Renomear para `camelCase` |
| Bi-linguismo não controlado | Mistura PT/EN sem regra | 🟠 ALTO RISCO | Definir política: EN em código, PT em UI/comentários |
| Conventional Commits | Nenhuma menção | 🔴 CRÍTICO | Adotar + validar via pre-commit hook |
| Pre-commit hooks | Nenhum | 🔴 CRÍTICO | `lefthook` com format + analyze + commitlint |
| Ordenação de imports | Inconsistente, alias com PascalCase | 🟡 MODERADO | Ativar `directives_ordering` + `import_sorter` |
| Estrutura duplicada (`pages/` + `core/`) | 2 estruturas em coexistência | 🔴 CRÍTICO | Template deve definir estrutura única `core/features/` |
| Documentação de convenções | CONTRIBUTING genérico sem padrões técnicos | 🟠 ALTO RISCO | CONTRIBUTING detalhado com todos os padrões do template |
