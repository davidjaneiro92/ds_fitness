# Catálogo de Assets de Imagem

> **Projeto legado:** `controle_separacao_aplicativo`
> **Data de geração:** 2026-06-25
> **Escopo:** somente leitura — nenhum código ou asset foi alterado.

---

## 1. Visão Geral das Pastas

| Pasta no disco | Caminho declarado no pubspec | Observação |
|---|---|---|
| `assets/Img/` | `assets/img/` | **RISCO DE CASING** — ver seção 5 |
| `assets/icon/` | `assets/icon/icon.png` (flutter\_launcher\_icons) | Ícone do app, fora do escopo de telas |

---

## 2. Tabela Mestre de Assets

> Tamanhos obtidos via `Get-ChildItem` no Windows. Casing real no disco: `assets/Img/` (I maiúsculo).

| Asset | Tamanho (bytes) | Tamanho (legível) | Usado em (arquivo : linha) | Em uso? | Observação |
|---|---|---|---|---|---|
| `assinatura.png` | 15 383 | ~15 KB | — | **Não** | Nenhuma referência encontrada em `lib/` |
| `erro3.png` | 1 170 234 | ~1,1 MB | `lib/src/components/custom_error_widget.dart:22` | **Sim** | Imagem de tela de erro; arquivo PNG pesado (>1 MB) |
| `logo-ok.png` | 22 017 | ~21 KB | — | **Não** | Nenhuma referência encontrada em `lib/` |
| `logo-ok-1.png` | 14 125 | ~14 KB | — | **Não** | Nenhuma referência encontrada em `lib/` |
| `logo-ok-2.png` | 25 045 | ~24 KB | — | **Não** | Nenhuma referência encontrada em `lib/` |
| `logo-ok-3.png` | 25 458 | ~25 KB | Ver seção 3 abaixo | **Sim** | Logo principal do app; asset mais referenciado |
| `simbolo-ok.png` | 15 447 | ~15 KB | — | **Não** | Nenhuma referência encontrada em `lib/` |
| `simbolo-ok-1.png` | 11 429 | ~11 KB | — | **Não** | Nenhuma referência encontrada em `lib/` |

**Adicionalmente** — ícone do launcher (fora da pasta `Img/`):

| Asset | Tamanho (bytes) | Tamanho (legível) | Declarado em | Em uso? |
|---|---|---|---|---|
| `assets/icon/icon.png` | 66 385 | ~65 KB | `flutter_launcher_icons` no pubspec | **Sim** (build-time) |

---

## 3. Asset Mais Usado — `logo-ok-3.png`

Referenciado em **5 arquivos distintos**, totalizando **7 ocorrências**:

| # | Arquivo | Linha | Contexto |
|---|---|---|---|
| 1 | `lib/src/components/custom_app_bar.dart` | 24 | AppBar customizada (global) |
| 2 | `lib/src/components/custom_Scaffold/view/custom_Scaffold_view.dart` | 44 | Scaffold customizado (global) |
| 3 | `lib/src/core/features/login/view/login.dart` | 65 | Tela de login (módulo core) |
| 4 | `lib/src/core/features/splash_screen/splash_screen.dart` | 53 | Splash screen (módulo core) |
| 5 | `lib/src/pages/login/view/login.dart` | 70 | Tela de login (pasta pages) |
| 6 | `lib/src/pages/splash_screen/splash_screen.dart` | 52 | Splash screen (pasta pages) |

> **Nota:** existem dois conjuntos paralelos de arquivos (`lib/src/core/features/` e `lib/src/pages/`). Isso indica que o projeto possui duplicação de telas — ambas as versões referenciam o mesmo asset.

---

## 4. Asset com Referência — `erro3.png`

| Arquivo | Linha | Contexto |
|---|---|---|
| `lib/src/components/custom_error_widget.dart` | 22 | Widget de erro genérico; comentário inline: `// Substitua com o caminho da imagem no projeto` |

> **Observação:** o comentário no código sugere que o caminho pode ser provisório. O asset está em uso ativo mas o código indica que a imagem pode ser substituída no futuro. Peso de ~1,1 MB é elevado para uma imagem inline — avaliar compressão ao migrar.

---

## 5. Assets Sem Referência no Código

Os itens abaixo **não foram encontrados** em nenhum arquivo `.dart` dentro de `lib/`:

| Asset | Tamanho | Situação |
|---|---|---|
| `assinatura.png` | ~15 KB | Sem referência em `lib/` |
| `logo-ok.png` | ~21 KB | Sem referência em `lib/` |
| `logo-ok-1.png` | ~14 KB | Sem referência em `lib/` |
| `logo-ok-2.png` | ~24 KB | Sem referência em `lib/` |
| `simbolo-ok.png` | ~15 KB | Sem referência em `lib/` |
| `simbolo-ok-1.png` | ~11 KB | Sem referência em `lib/` |

> **Fato documentado** — esta lista é resultado de busca estática (`grep`) em `lib/`. Não foi investigado uso dinâmico (strings montadas em tempo de execução, geração de código, etc.). A decisão de remover ou reter esses assets é responsabilidade do time.

---

## 6. Risco de Casing: `assets/Img/` vs `assets/img/`

### Situação atual

| Camada | Valor |
|---|---|
| Nome real da pasta no disco (Windows) | `assets/Img/` (I **maiúsculo**) |
| Declaração no `pubspec.yaml` (`flutter > assets`) | `assets/img/` (i **minúsculo**) |
| Referências no código Dart | `assets/img/…` (i **minúsculo**) |

### Por que funciona no Windows

O sistema de arquivos NTFS (Windows) é **case-insensitive** por padrão. `assets/Img/` e `assets/img/` são tratados como o mesmo caminho, portanto o build local e os testes no Windows não falham.

### Por que quebraria em CI/build Linux

O sistema de arquivos ext4/Linux é **case-sensitive**. Em ambientes de integração contínua (GitHub Actions, GitLab CI, Docker, etc.) que rodam sobre Linux:

- O Flutter tentará resolver `assets/img/logo-ok-3.png`
- O caminho real no disco é `assets/Img/logo-ok-3.png`
- O build falhará com erro de asset não encontrado

### Recomendação de documentação (sem alterar o projeto legado)

Ao replicar no template, escolha **um** casing e aplique-o de forma consistente nos três lugares:
1. Nome da pasta no disco
2. Declaração no `pubspec.yaml`
3. Strings de caminho no código Dart

O padrão recomendado por convenção Flutter é **tudo minúsculo**: `assets/img/`.

---

## 7. Declaração no `pubspec.yaml`

### Trecho atual (linha 102–103)

```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/img/
```

A declaração usa a notação de **pasta inteira** (`assets/img/` com barra final), o que faz o Flutter incluir automaticamente **todos os arquivos** presentes nessa pasta no bundle do app. Isso inclui os assets sem referência no código (seção 5), que serão empacotados no binário mesmo sem uso.

### Como replicar no template

```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/img/   # pasta única; todos os arquivos .png são incluídos automaticamente
```

> Se quiser controle granular (incluir apenas assets em uso), substitua a entrada de pasta por entradas individuais:
>
> ```yaml
> assets:
>   - assets/img/logo-ok-3.png
>   - assets/img/erro3.png
> ```
>
> Essa alteração reduziria o tamanho do bundle, mas é uma decisão do time — **não** foi aplicada ao projeto legado.

---

## 8. Classificação para Migração ao Template

| Asset | Classificação | Justificativa |
|---|---|---|
| `logo-ok-3.png` | Reutilizar | Em uso em AppBar, Scaffold, Login e Splash Screen |
| `erro3.png` | Reutilizar (com ressalva) | Em uso no widget de erro; avaliar compressão (1,1 MB) |
| `assinatura.png` | Verificar antes de levar | Sem referência encontrada no código |
| `logo-ok.png` | Verificar antes de levar | Sem referência encontrada no código |
| `logo-ok-1.png` | Verificar antes de levar | Sem referência encontrada no código |
| `logo-ok-2.png` | Verificar antes de levar | Sem referência encontrada no código |
| `simbolo-ok.png` | Verificar antes de levar | Sem referência encontrada no código |
| `simbolo-ok-1.png` | Verificar antes de levar | Sem referência encontrada no código |

---

## 9. Resumo Executivo

- **Total de assets em `assets/Img/`:** 8 arquivos PNG
- **Em uso (referência estática confirmada):** 2 — `logo-ok-3.png` e `erro3.png`
- **Sem referência encontrada:** 6 — `assinatura.png`, `logo-ok.png`, `logo-ok-1.png`, `logo-ok-2.png`, `simbolo-ok.png`, `simbolo-ok-1.png`
- **Asset mais crítico:** `logo-ok-3.png` (identidade visual, 7 referências em 5 arquivos)
- **Asset de maior peso:** `erro3.png` (~1,1 MB — candidato a otimização de compressão)
- **Risco identificado:** casing `Img` vs `img` — invisível no Windows, fatal em CI Linux
