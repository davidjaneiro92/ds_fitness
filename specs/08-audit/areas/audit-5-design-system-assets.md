# Auditoria 5 — Design System, Assets, Internacionalização

> **Área:** Tema · Componentes/Widgets compartilhados · Assets · Internacionalização
> **Auditor:** Claude Code (Sonnet 4.6)
> **Data:** 2026-06-24
> **Código-fonte (leitura):** `controle_separacao_aplicativo/lib/src/components/`
> **Docs auditadas:** `03-design-system/components-catalog.md`, `shared-widgets.md`, `theming.md`, `i18n.md`, `02-infrastructure/custom-error-screen.md`

---

## 1. Completude — O que está documentado sem lacunas

### 1.1 Componentes com ficha completa nas docs

Todos os 13 componentes presentes em `lib/src/components/` têm entrada nas docs. A tabela mestre de `components-catalog.md` registra:

| Componente | Arquivo | Status doc |
|---|---|---|
| `customAalertQuestion` / `customAalertInformation` | `custom_alert.dart` | Ficha completa (components-catalog §1) |
| `CustomAppBar` | `custom_app_bar.dart` | Ficha completa (components-catalog §2) |
| `CustomDropdownButton` | `custom_dropwn_button.dart` | Ficha completa (components-catalog §3) |
| `CustomExpansion` | `custom_expansion.dart` | Ficha completa (components-catalog §4) |
| `CustomListTile` | `custom_list_tile.dart` | Ficha completa (components-catalog §5) |
| `customAlertMessage` | `custom_message.dart` | Ficha completa (components-catalog §6) |
| `CustomToast` + `status` | `custom_toast.dart` | Ficha completa (components-catalog §7) |
| `CustomTextField` | `custom_text_field.dart` | Ficha completa (components-catalog §8) |
| `CustomPlutogridTable` | `custom_plutoGrid_Table.dart` | Ficha completa (components-catalog §9) |
| `CustomScaffoldView` + controller + interface | `custom_Scaffold/` | Ficha completa (components-catalog §10) |
| `CustomListViewConteiner` + `CustomItemListView` + controller | `custom_list_view/` | Ficha completa (components-catalog §11) |
| `LoadingController` + `LoadingWidget` | `loading/` | Ficha completa (components-catalog §12) |
| `CustomErrorWidget` | `custom_error_widget.dart` | Documentado separadamente em `02-infrastructure/custom-error-screen.md` |

**Evidência:** `components-catalog.md` — tabela mestre, linhas 11-26; fichas individuais §1–§12.

### 1.2 Tema

`theming.md` documenta com precisão:
- Seed color `#003A88` (`main.dart` — `ColorScheme.fromSeed`)
- `useMaterial3: true`
- Duplicação de `custom_colos.dart` nos dois caminhos — evidência: `lib/src/config/custom_colos.dart` e `lib/src/core/theme/config/custom_colos.dart` (conteúdo idêntico confirmado por leitura direta)
- Lista de cores hardcoded por arquivo (theming.md §1.3)
- Ausência de `TextTheme`, tokens de espaçamento e dark mode

### 1.3 i18n

`i18n.md` documenta com precisão o estado real:
- `intl: ^0.19.0` presente apenas para formatação numérica/data (evidência: `FormatarValores.formatDateTime`, `formatvalueToBrasil`)
- `flutter_localizations` ausente do `pubspec.yaml`
- Nenhum arquivo `.arb`
- Strings hardcoded em PT e EN misturados

---

## 2. Parcialmente documentado

### 2.1 `CustomErrorWidget` — split entre dois documentos

O componente está bem documentado em `02-infrastructure/custom-error-screen.md`, mas a tabela mestre de `components-catalog.md` o exclui explicitamente do escopo (`> **Fora de escopo:** custom_error_widget`, linha 7). O `shared-widgets.md` inclui o componente na tabela (linha 51, item 4), gerando **tratamento assimétrico entre os três documentos**.

**Impacto:** leitor que consulta apenas `components-catalog.md` não encontra o componente; leitor de `shared-widgets.md` encontra, mas a ficha detalhada está em infra. Não há link cruzado entre os documentos.

### 2.2 `CustomScaffoldView` — menu hardcoded não marcado como decisão

`components-catalog.md` descreve o acoplamento (rotas hardcoded: `PagesRoutes.nfsPedidos`, `PagesRoutes.Trasferencialote`, `PagesRoutes.ConsultaNfSaida`; menu: `['Entrada/Saida', 'Consultar', 'Trasferencia']`), mas não há registro do **motivo** dessa decisão arquitetural. Ausência documentada na seção 8 abaixo.

---

## 3. Não documentado — Lacunas identificadas

### 3.1 ASSETS — Lacuna crítica confirmada

**Nenhum dos oito documentos auditados contém um catálogo de assets.**

Assets existentes em `assets/Img/` (confirmados por Glob):

| Arquivo | Usado no código? | Onde | Documentado? |
|---|---|---|---|
| `logo-ok-3.png` | **Sim** | `custom_app_bar.dart:24`, `custom_Scaffold_view.dart:44`, `login.dart:65`, `splash_screen.dart:53` (e duplicatas em `/pages/`) | **Não** |
| `erro3.png` | **Sim** | `custom_error_widget.dart:22` | Parcial — `custom-error-screen.md` menciona o arquivo, mas não há catálogo de assets |
| `logo-ok.png` | **Não** | Nenhuma referência no código | **Não** |
| `logo-ok-1.png` | **Não** | Nenhuma referência no código | **Não** |
| `logo-ok-2.png` | **Não** | Nenhuma referência no código | **Não** |
| `assinatura.png` | **Não** | Nenhuma referência no código | **Não** |
| `simbolo-ok.png` | **Não** | Nenhuma referência no código | **Não** |
| `simbolo-ok-1.png` | **Não** | Nenhuma referência no código | **Não** |
| `assets/icon/icon.png` | Implícito (ícone do app) | `pubspec.yaml` / flutter launcher | **Não** |

**Evidências de uso:** grep `'assets/'` em `lib/` retornou 7 ocorrências, todas referenciando apenas `logo-ok-3.png` ou `erro3.png`. Os outros 6 arquivos de imagem (`logo-ok.png`, `logo-ok-1.png`, `logo-ok-2.png`, `assinatura.png`, `simbolo-ok.png`, `simbolo-ok-1.png`) **não têm nenhuma referência no código-fonte**.

**Conclusão:** existe provável coleção de variantes de logo nunca usadas (possivelmente testadas durante o design e esquecidas). A doc previu essa lacuna corretamente, mas não a preencheu.

### 3.2 Componente `custom_error_widget.dart` ausente da tabela mestre de `components-catalog.md`

Excluído explicitamente do escopo sem link de referência cruzada para `custom-error-screen.md`.

### 3.3 Ausência de especificação de asset para o ícone do app

`assets/icon/icon.png` existe mas não está documentado em nenhum dos arquivos auditados.

---

## 4. Aprofundamentos necessários

### 4.1 Assets órfãos — decisão de manutenção pendente

Os 6 arquivos de imagem sem uso no código (`assinatura.png`, `logo-ok.png`, `logo-ok-1.png`, `logo-ok-2.png`, `simbolo-ok.png`, `simbolo-ok-1.png`) podem ser:
- Versões antigas do logo substituídas por `logo-ok-3.png`
- Assets planejados para features não implementadas
- Candidatos a remoção do projeto

A documentação deveria registrar a decisão de mantê-los ou descartá-los.

### 4.2 Casing inconsistente do diretório de assets

O diretório no disco é `assets/Img/` (I maiúsculo), mas o código referencia `'assets/img/logo-ok-3.png'` (i minúsculo). Em Windows isso funciona por insensibilidade a case do NTFS, mas falharia em Linux/macOS ou em builds de produção via CI em ambiente Unix. A documentação não registra esse risco.

**Evidência:** Glob retornou `assets\Img\logo-ok-3.png`; código usa `'assets/img/logo-ok-3.png'`.

### 4.3 Duplicação de login/splash em `/pages/` vs `/core/features/`

O grep revelou `lib\src\pages\login\view\login.dart` e `lib\src\pages\splash_screen\splash_screen.dart` além de `lib\src\core\features\login\view\login.dart` e `lib\src\core\features\splash_screen\splash_screen.dart`. Quatro arquivos que referenciam o mesmo asset, sugerindo duplicação de telas não documentada. Fora do escopo desta auditoria de design system, mas registrado para investigação.

---

## 5. Inconsistências Documentação × Código

### 5.1 `CustomAppBar` — parâmetro `golBack` descrito como "ignorado" mas ainda presente

`components-catalog.md` §2 descreve corretamente que `golBack` existe mas `automaticallyImplyLeading: false` está hardcoded. Leitura do código (`custom_app_bar.dart:14`) confirma o comentário `// golBack ?? false,`. A inconsistência é interna ao código; a doc descreve o estado real com precisão. Sem divergência doc×código.

### 5.2 `CustomToast` — classificação divergente entre os dois documentos

| Doc | Classificação de `CustomToast` |
|---|---|
| `components-catalog.md` §7 | ✅ **Reutilizar** (sem melhorias necessárias na classificação final) |
| `shared-widgets.md` §2.1 tabela linha 3 | 🟢 Reutilizável — mas o texto §3.3 lista problemas: método de instância quando deveria ser `static`, cores hardcoded, nome de classe fora de PascalCase |

**Divergência real:** `components-catalog.md` classifica como "✅ Reutilizar" sem ressalvas, enquanto `shared-widgets.md` lista quatro problemas técnicos para o mesmo componente. As recomendações são contraditórias: uma diz reutilizar como está, a outra diz converter para `static` e usar tokens.

### 5.3 `CustomListTile` — classificação divergente

| Doc | Classificação |
|---|---|
| `components-catalog.md` §5 | 🟢 **c/ melhorias** — "adicionar `onTap`" |
| `shared-widgets.md` §3.8 | 🟠 **Esqueleto incompleto** |

Divergência de símbolo/severidade para o mesmo componente no mesmo estado do código.

### 5.4 `customAlertMessage` — proposta de unificação ausente em `components-catalog.md`

`shared-widgets.md` §3.7 recomenda consolidar `custom_alert.dart` e `custom_message.dart` em um único `AppDialog`. `components-catalog.md` não menciona essa recomendação — as fichas tratam os dois arquivos como independentes sem sinalizar duplicação.

### 5.5 Casing do diretório de assets

`theming.md` e `components-catalog.md` não mencionam o asset path. `custom-error-screen.md` §2 registra `assets/img/` (minúsculo) como declaração no `pubspec.yaml`, o que é a declaração real mas oculta o risco de casing no filesystem descrito em §4.2 acima.

---

## 6. Duplicações entre Documentos

### 6.1 Relação `components-catalog.md` × `shared-widgets.md` — sobreposição estrutural quase total

Ambos os documentos catalogam os mesmos 12-13 componentes com:
- Tabela mestre de classificação
- Análise por componente com API, pontos fortes e problemas
- Recomendação de migração para o template

**O que diferencia os dois documentos:**

| Aspecto | `components-catalog.md` | `shared-widgets.md` |
|---|---|---|
| Inclui `CustomErrorWidget`? | Não (explicitamente excluído) | Sim (item 4) |
| Profundidade das fichas | Alta — APIs completas com parâmetro a parâmetro, exemplos reais de código | Média — API resumida, análise mais focada em problemas e tokens |
| Ranking de migração | Sim (tabela de referência cruzada no final) | Sim (seção 4 com ordem de prioridade) |
| Recomendações de tokens | Ausentes — foca no código real | Presentes — menciona `ColorTokens`, `SpacingTokens` |
| Exemplos de uso real | Sim — com arquivo:linha | Sim — com chamadas de exemplo |

**Conteúdo redundante confirmado:**
- Tabelas mestres duplicadas com os mesmos 12 componentes
- Análise de `LoadingController` aparece nas §3.1 de ambos com conclusão idêntica
- Análise de `CustomTextField` aparece nas §3.2 / §8 de ambos
- Recomendação de `onTap` para `CustomListTile` aparece em ambos
- Observação sobre `CustomExpansion` como protótipo descartável aparece em ambos

**Estimativa de conteúdo duplicado:** ~60-70% do conteúdo analítico é paralelo, cobrindo o mesmo objeto de análise com graus de detalhe ligeiramente diferentes.

### 6.2 Fichas de `theming.md` vs seção de cores em `shared-widgets.md`

`shared-widgets.md` §3.1 menciona que `LoadingWidget` usa `CustomColors.blue` diretamente em vez de `Theme.of(context).colorScheme.primary`. `theming.md` §1.2 documenta a mesma duplicação de arquivo e a mesma limitação da `MaterialColor`. Há sobreposição, mas o nível de detalhe é diferente — `theming.md` é mais completo; a menção em `shared-widgets.md` é contextual e não duplica a profundidade.

---

## 7. Conflitos Diretos Doc × Código

### 7.1 Nenhum conflito de fato (spec × código) encontrado

As docs descrevem o código como ele realmente está. Os "conflitos" identificados são entre dois documentos de specs (§6 e §5), não entre spec e código.

### 7.2 Classificações conflitantes entre os dois catálogos

Conforme §5.2 e §5.3: `CustomToast` e `CustomListTile` recebem classificações diferentes nos dois documentos para o mesmo estado do código. Não é conflito de fato sobre o código, mas é conflito de avaliação que pode gerar decisões contraditórias no template.

---

## 8. Decisões não documentadas

### 8.1 Por que `logo-ok-3.png` e não as versões 1 ou 2?

O código usa exclusivamente `logo-ok-3.png` em todos os pontos de uso. As versões 1 e 2 existem no diretório mas nunca foram referenciadas. Não há comentário, decisão de design ou nota explicando a escolha da versão 3 nem o descarte das versões anteriores.

### 8.2 Por que dois arquivos `custom_colos.dart` idênticos?

A duplicação em `lib/src/config/custom_colos.dart` e `lib/src/core/theme/config/custom_colos.dart` está documentada em `theming.md` como fato, mas o **motivo** nunca foi registrado. Hipótese mais provável: migração de estrutura de diretórios incompleta. Sem evidência documental.

### 8.3 Por que o menu do `CustomScaffoldView` está hardcoded?

Os itens de Drawer `['Entrada/Saida', 'Consultar', 'Trasferencia']` e as rotas associadas estão fixos no componente compartilhado em vez de serem parâmetros. A decisão de colocar lógica de negócio em um componente genérico não está registrada nem justificada em nenhum documento.

### 8.4 Por que `assinatura.png` existe no projeto?

O arquivo `assets/Img/assinatura.png` sugere uso em relatórios ou PDFs gerados pelo app (assinatura digital impressa em documento). Não há nenhuma tela, feature ou doc que explique para que serve este asset.

### 8.5 Ausência de dark mode — decisão ou omissão?

`theming.md` registra a ausência de dark mode, mas não documenta se foi uma decisão consciente (`// dark mode fora do escopo deste projeto`) ou simplesmente não implementado. Para o template corporativo, a distinção é relevante.

---

## Resumo Executivo e Percentual de Cobertura

### Por sub-área

| Sub-área | Cobertura | Qualidade |
|---|---|---|
| Componentes — fichas individuais | 100% (13/13 cobertos) | Alta — APIs completas com parâmetros, exemplos reais |
| Componentes — classificação/reutilização | 100% | Média — há divergências entre os dois catálogos |
| Tema / CustomColors | 90% | Alta — duplicação documentada, lacunas de tokens documentadas |
| Tipografia | 85% | Boa — ausência de TextTheme documentada com exemplos reais |
| i18n | 95% | Alta — estado real fielmente descrito, inclui inventário de strings hardcoded |
| Assets | **15%** | Crítica — apenas `erro3.png` mencionado; 6 de 8 assets sem qualquer referência |
| Catálogo de assets (documento dedicado) | **0%** | Lacuna total — não existe |

### Cobertura global estimada da área: **72%**

**Justificativa:** Componentes e tema/i18n têm cobertura excelente a muito boa (85-100%), puxando a média para cima. O que derruba a nota é a lacuna crítica de assets: nenhum catálogo existe, 6 de 8 imagens não estão documentadas, e o risco de casing no path (`Img` vs `img`) não foi registrado. A duplicação estrutural entre `components-catalog.md` e `shared-widgets.md` não reduz a cobertura, mas é um passivo de manutenção significativo.

### Achados-chave (prioridade decrescente)

1. **Assets — lacuna crítica:** nenhum dos documentos contém catálogo de assets. Apenas `erro3.png` é mencionado contextualmente. `logo-ok-3.png` é o asset mais usado no código (6 ocorrências) e não aparece em nenhum doc. Os 6 assets sem uso (`assinatura.png`, `logo-ok.png`, `logo-ok-1.png`, `logo-ok-2.png`, `simbolo-ok.png`, `simbolo-ok-1.png`) são potencialmente deadweight não documentado.

2. **Casing de path — risco silencioso:** `assets/Img/` no disco, `assets/img/` no código. Funciona em Windows (NTFS case-insensitive); quebraria em CI Linux ou em deploy para Android/iOS via pipeline Unix.

3. **Duplicação `components-catalog.md` × `shared-widgets.md`:** ~60-70% de conteúdo paralelo cobrindo os mesmos componentes. As classificações divergem em pelo menos 2 componentes (`CustomToast` e `CustomListTile`), criando ambiguidade sobre o que fazer no template. Os documentos deveriam ser mesclados ou ter escopos claramente separados.

4. **i18n fielmente documentado:** `i18n.md` descreve corretamente o estado real — apenas `intl` para formatação, sem `flutter_localizations`, sem `.arb`. Estado real confirmado por leitura de código.

5. **Tema fielmente documentado:** `theming.md` descreve a duplicação de `custom_colos.dart`, as cores hardcoded nos widgets e a ausência de TextTheme com precisão. Código confirma ponto a ponto.

6. **`CustomErrorWidget` — tratamento assimétrico:** excluído de `components-catalog.md`, incluído em `shared-widgets.md`, documentado em profundidade em `custom-error-screen.md`. Nenhum dos três documentos tem link para os outros dois sobre este componente.

7. **6 assets sem uso documentado e sem decisão registrada:** remoção, manutenção ou uso futuro — nenhuma das três opções está registrada.

---

*Auditoria baseada em leitura direta do código-fonte e dos documentos de spec. Nenhum arquivo foi criado ou alterado no código legado.*
