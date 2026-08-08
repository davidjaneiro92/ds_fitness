# Auditoria de Cobertura Documental — Área 3: Rede / Auth / Erros / Segurança

**Data:** 2026-06-24  
**Auditor:** Engenharia reversa cruzada (código × documentação)  
**Escopo de código:** `lib/src/core/services/http_manager.dart`, `lib/src/core/features/login/`, `lib/src/components/custom_error_widget.dart`, `lib/src/components/custom_message.dart`, `lib/src/components/custom_alert.dart`, `lib/src/components/custom_toast.dart`  
**Escopo documental:** `02-infrastructure/api-configuration.md`, `authentication-and-interceptors.md`, `error-handling.md`, `security.md`, `custom-error-screen.md`, `logging-observability.md` (parte de erros)

---

## Metodologia

Leitura integral de cada arquivo de código-fonte e confronto linha a linha com os documentos listados. Para cada símbolo, função e decisão de design identificados no código, verificou-se: (a) se existe entrada no(s) documento(s) correspondente(s); (b) se a descrição é precisa; (c) se há sobreposição ou conflito entre documentos; (d) se há decisões não documentadas.

---

## 1. `http_manager.dart` — Análise por símbolo

### 1.1 `restRequest()` — COMPLETO

**Evidência no código:** `http_manager.dart:41-94` — método principal com try/catch DioException, injeção de token, retry 401, tratamento de erro via `_handleDioError`, chamada a `customAlertMessage`.

**Cobertura documental:**
- `api-configuration.md` seção 3.2: documenta o fluxo completo com diagrama de chamadas e código real. Cobre injeção de headers, tratamento 401, retry recursivo, chamada a `signOut()`, chamada a `customAlertMessage`, retorno de `Response` vazia em erro não-401.
- `authentication-and-interceptors.md` seção 5: documenta o mesmo fluxo sob a ótica da injeção de token, com tabela de comportamentos.
- `error-handling.md` seção 3: documenta o mesmo fluxo sob a ótica do tratamento de erros, com tabela `DioExceptionType`.

**Avaliação:** Completo — três documentos cobrem o método sob ângulos complementares.

**Problema identificado (item 6 — duplicação):** O fluxo do `restRequest()` é descrito com nível de detalhe semelhante em três documentos distintos (`api-configuration.md`, `authentication-and-interceptors.md`, `error-handling.md`). O código de exemplo do bloco `on DioException catch (error)` aparece copiado integralmente em dois deles (`api-configuration.md:85-100` e `authentication-and-interceptors.md:375-392` e `error-handling.md:81-104`). Há triplicação de conteúdo sem referência cruzada entre os docs.

---

### 1.2 `token()` — COMPLETO

**Evidência no código:** `http_manager.dart:118-127` — função global de nível de arquivo (fora da classe), lê do Hive box `Cache_aplicativo`, chave `'Autenticacao'`, campo `obj['accessToken']`.

**Cobertura documental:**
- `api-configuration.md` seção 3.3: documenta a função global, código real, comportamento com token ausente.
- `authentication-and-interceptors.md` seção 4.2 e 5: detalha o que é salvo e como é lido, incluindo tabela de comportamentos de injeção.

**Avaliação:** Completo.

**Problema identificado (item 8 — decisão não documentada):** A função `token()` é definida fora da classe `HttpManager` (escopo de arquivo/biblioteca Dart), sendo tecnicamente uma função de nível de arquivo acessível por qualquer arquivo que importe `http_manager.dart`. Nenhum documento menciona ou justifica essa decisão de design. O ponto crítico — que rompe a injeção de dependência e impossibilita mock em testes — é citado como problema em `api-configuration.md` seção 3.3, mas a decisão de torná-la global em vez de método da classe não é explicada.

---

### 1.3 `_tryRefreshToken()` — COMPLETO

**Evidência no código:** `http_manager.dart:129-136` — função global de nível de arquivo, delega para `login.Refreshtoken()` onde `login` é instância global `LoginRepository login = LoginRepository()` (linha 17).

**Cobertura documental:**
- `authentication-and-interceptors.md` seção 6 (código e diagrama completo do fluxo de refresh).
- `api-configuration.md` seção 3.4: documenta o problema da instância global `LoginRepository`.

**Avaliação:** Completo.

**Problema identificado (item 8 — decisão não documentada):** A instância `LoginRepository login = LoginRepository()` na linha 17 de `http_manager.dart` (nível de arquivo, fora de qualquer classe) quebra a inversão de controle. Os documentos citam isso como problema técnico, mas não documentam a razão pela qual essa escolha foi feita (provavelmente impossibilidade de circular dependency com GetX — `LoginRepository` depende de `HttpManager`, que não pode obter `LoginRepository` via `Get.find()` sem criar dependência circular). Essa motivação técnica não está registrada em nenhum documento.

---

### 1.4 `signOut()` — COMPLETO

**Evidência no código:** `http_manager.dart:138-142` — função global, apaga chave `'Autenticacao'` do Hive, navega via `Get.offAllNamed(PagesRoutes.login.path)`.

**Cobertura documental:**
- `authentication-and-interceptors.md` seção 7: tabela completa com ações, nota sobre `limparTodoCache()` não chamado.
- `api-configuration.md` seção 3.5: cita o problema de navegação de dentro do serviço.

**Avaliação:** Completo.

**Problema identificado (item 2 — parcial):** A nota de que `HiveServices.limparTodoCache()` existe mas NÃO é chamado no signOut — dados de outras features permanecem no dispositivo após logout — está em `authentication-and-interceptors.md` seção 7. Porém, **nenhum documento avalia se isso é intencional** (pode haver features que devem manter cache entre sessões de usuário diferente, ou pode ser um bug latente). A decisão de fazer limpeza parcial não tem justificativa documentada.

---

### 1.5 `_handleDioError()` — COMPLETO

**Evidência no código:** `http_manager.dart:96-115` — switch sobre `DioExceptionType` com 7 casos mapeados para strings em PT-BR.

**Cobertura documental:**
- `api-configuration.md` seção 4: tabela completa com todos os 7 tipos e mensagens.
- `error-handling.md` seção 3: tabela idêntica.
- `authentication-and-interceptors.md` seção 8.3: menciona `_handleDioError` na comparação de padrões.

**Avaliação:** Completo.

**Problema identificado (item 6 — duplicação):** A tabela de mapeamento de `DioExceptionType` para mensagens aparece duplicada em `api-configuration.md` e `error-handling.md` sem referência cruzada.

---

### 1.6 `badCertificateCallback = (cert, host, port) => true` — COMPLETO

**Evidência no código:** `http_manager.dart:25` — `client.badCertificateCallback = (cert, host, port) => true;` no construtor do `HttpManager`.

**Cobertura documental:**
- `security.md` seção S-01: documentação mais completa, inclui impacto (MITM), contexto (rede interna com certificado autoassinado), opções de correção A e B.
- `authentication-and-interceptors.md` seção 12.1 (S-01): idêntico em nível de detalhe.
- `api-configuration.md` seção 3.1: mencionado com marcação de risco e remetido à seção de segurança.

**Avaliação:** Completo — três documentos cobrem o achado, com `security.md` sendo o mais aprofundado.

**Problema identificado (item 6 — duplicação):** O achado S-01 é descrito com nível de detalhe semelhante em `security.md` e `authentication-and-interceptors.md` seção 12, sem referência cruzada entre eles. Um leitor que ler só `authentication-and-interceptors.md` terá a mesma informação que leria em `security.md`, criando risco de os dois documentos divergirem em futuras edições.

---

### 1.7 `LogInterceptor` comentado — COMPLETO

**Evidência no código:** `http_manager.dart:29-38` — bloco comentado do `LogInterceptor` com todos os parâmetros.

**Cobertura documental:**
- `authentication-and-interceptors.md` seção 8.1: cita o código comentado explicitamente com snippet real.
- `api-configuration.md` seção 3.1: menciona que LogInterceptor está inativo em produção.
- `logging-observability.md` seção S-06: documenta como achado de observabilidade.
- `security.md` seção S-06 da tabela: mencionado.

**Avaliação:** Completo — quatro documentos mencionam o fato.

**Problema identificado (item 8 — decisão não documentada):** Nenhum documento registra POR QUE o `LogInterceptor` foi comentado. Foi comentado para evitar vazamento de dados em produção? Por ruído excessivo em desenvolvimento? Por impacto em performance? A motivação original não está registrada.

---

## 2. `lib/src/core/features/login/` — Análise por componente

### 2.1 `login_repository.dart` — `login()` e `Refreshtoken()` — COMPLETO

**Evidência no código:** `login_repository.dart:25-55` (`login()`) e `57-93` (`Refreshtoken()`).

**Cobertura documental:**
- `authentication-and-interceptors.md` seção 3.3: código real completo do `login()`.
- `authentication-and-interceptors.md` seção 6.3: código real completo do `Refreshtoken()`.

**Avaliação:** Completo.

**Problema identificado (item 5 — inconsistência doc × código):** O método `Refreshtoken()` no código também exibe o loading global (`loadingController.showLoading()` / `hideLoading()`) — isso é documentado corretamente em `logging-observability.md` seção 4 (carregamento durante log). Porém, o `login_repository.dart` também faz o mesmo durante o refresh, e **`authentication-and-interceptors.md` não menciona que o Refreshtoken() aciona o loading global**. O usuário experimenta um spinner durante a renovação silenciosa do token — comportamento não documentado em `authentication-and-interceptors.md`.

**Problema adicional (item 8 — decisão não documentada):** As mensagens de log em `login_repository.dart` linhas 42 e 48 contêm `"Linha 52 itens_nf_entrada_repository"` — texto claramente copiado de outro repositório (copy-paste) com referência incorreta ao arquivo. Esta anomalia não está documentada em nenhum dos docs auditados.

---

### 2.2 `login_controller.dart` — `signIn()` e `loginSettings()` — PARCIAL

**Evidência no código:** `login_controller.dart:35-42` (`signIn()`) e `45-58` (`loginSettings()`).

**Cobertura documental:**
- `authentication-and-interceptors.md` seção 3.3: documenta `signIn()` com código real.
- `authentication-and-interceptors.md` seção 12.1 (S-04): documenta `loginSettings()` com o hardcode de `'KeyMaster'`.
- `security.md` seção S-04: documenta `loginSettings()` com código real e impacto.

**Avaliação:** Parcial.

**O que falta:** O método `loginSettings()` é documentado apenas como achado de segurança (S-04). Não existe documentação funcional de que esse método constitui uma segunda "rota de autenticação" alternativa que dá acesso exclusivo à tela `SettingsApp`. O fluxo UX de acesso às configurações via `loginSettings()` — que usa o ícone de engrenagem na tela de login, abre `confirmar_acesso.dart` como dialog e redireciona para `PagesRoutes.settingsApp` — não está documentado como funcionalidade, apenas como achado de segurança.

---

### 2.3 `login_controller.dart` — keyword `new` obsoleta — NAO DOCUMENTADO

**Evidência no código:** `login_controller.dart:16` — `LoginRepositoryInterface repository = new LoginRepository();` — uso de `new` keyword removida do Dart moderno e do linter padrão Flutter (`unnecessary_new`).

**Cobertura documental:** Nenhum documento menciona isso. Menor que a instância global em `http_manager.dart`, mas igualmente indica ausência de `Get.find<LoginRepositoryInterface>()`.

**Avaliação:** Não documentado (dívida técnica menor).

---

### 2.4 `login.dart` (tela) — COMPLETO

**Evidência no código:** `login.dart:10-169` — `StatelessWidget`, `Form`, `_formkey`, dois `CustomTextField`, botão "Entrar", `_formkey.currentState.validate()`, `controller.signIn()`, `IconButton` com `showAlertLogin()`.

**Cobertura documental:**
- `authentication-and-interceptors.md` seção 3.1: descreve o passo a passo do formulário de login.
- `authentication-and-interceptors.md` seção 3.2: diagrama de sequência inclui "Tela Login.dart".

**Avaliação:** Completo para o fluxo principal de login.

**O que falta (item 2 — parcial):** O `IconButton` de configurações (ícone de engrenagem, `Icons.settings`, que chama `showAlertLogin()`) não está descrito na documentação da tela. Apenas `confirmar_acesso.dart` é referenciado indiretamente (via `showAlertLogin`), mas sem descrição do elemento visual na tela principal de login.

---

### 2.5 `confirmar_acesso.dart` — NAO DOCUMENTADO

**Evidência no código:** `confirmar_acesso.dart:29-107` — `showAlertLogin()`, função de nível de arquivo que exibe um `AlertDialog` com `Form`, dois `CustomTextField` (`_usuarioModalController`, `_passwordModalController`), botões "Fechar" e "Entrar". Chama `controller.loginSettings()`. Título do dialog: `"Logn"` (typo).

**Cobertura documental:**
- `authentication-and-interceptors.md`: não menciona `confirmar_acesso.dart` nem a função `showAlertLogin()` pelo nome.
- `api-configuration.md`: não menciona.
- `security.md`: menciona `loginSettings()` pelo código mas não o arquivo `confirmar_acesso.dart`.
- Nenhum outro documento auditado referencia este arquivo.

**Avaliação:** Nao documentado — arquivo inteiramente ausente da documentação.

**Problemas adicionais não documentados encontrados no código:**
- Título do dialog `"Logn"` (typo — falta a letra 'i'): `confirmar_acesso.dart:40`.
- Variáveis de estado e FocusNodes declarados como globais de arquivo (`_formkeyModal`, `_usuarioModalController`, `_passwordModalController`, `focusNodesModal`) em vez de locais ao `StatefulWidget` — causam vazamento de estado entre exibições do dialog.
- `dispose()` decorado com `@override` mas definido fora de qualquer classe — o override é sintaxe inválida/não funcional neste contexto.
- `controller` e `utilsServices` instanciados como globais de arquivo (fora de qualquer classe).

Nenhuma dessas anomalias está documentada.

---

### 2.6 Interfaces `LoginControllerInterface` e `LoginRepositoryInterface` — COMPLETO

**Evidência no código:** `abstracts/login_controller_interface.dart:4-10` e `abstracts/login_repository_interface.dart:3-6`.

**Cobertura documental:** `authentication-and-interceptors.md` seção 10.3 e 10.4: reproduz ambas as interfaces com código real.

**Avaliação:** Completo.

---

## 3. Componentes de erro e feedback

### 3.1 `custom_error_widget.dart` + `ErrorWidget.builder` em `main.dart` — COMPLETO

**Evidência no código:** `custom_error_widget.dart:3-50` — `CustomErrorWidget` com parâmetros, estrutura de widget; `main.dart:55-61` — registro do builder.

**Cobertura documental:**
- `custom-error-screen.md`: documentação mais completa e precisa — inclui código real (100% correto), tabela de estilos, diagrama Mermaid, escopo de captura, diferença debug/release, checklist de reuso, melhorias possíveis.
- `error-handling.md` seção 2: documenta o mesmo componente com código real.

**Avaliação:** Completo — dois documentos cobrem com código real.

**Problema identificado (item 6 — duplicação):** `error-handling.md` seção 2 reproduz parte do conteúdo de `custom-error-screen.md` sem referência cruzada. O trecho de código `ErrorWidget.builder` aparece copiado em ambos os documentos.

---

### 3.2 `custom_message.dart` / `customAlertMessage()` — COMPLETO

**Evidência no código:** `custom_message.dart:6-25` — função global `customAlertMessage()`, usa `Get.dialog`, guarda de `Get.isDialogOpen == true`.

**Cobertura documental:**
- `error-handling.md` seção 4: tabela de componentes inclui `customAlertMessage`, arquivo, uso, e avalia `Get.dialog` sem `BuildContext`.
- `api-configuration.md` seção 3.2 e seção 8 (P2): cita o acoplamento da UI.

**Avaliação:** Completo.

**Problema identificado (item 2 — parcial):** A guarda `if (Get.isDialogOpen == true) return;` (linha 10 de `custom_message.dart`) — que evita empilhamento de dialogs — não está documentada em nenhum dos docs. É um detalhe de comportamento relevante para quem for reimplementar o componente.

---

### 3.3 `custom_alert.dart` / `customAalertQuestion()` e `customAalertInformation()` — PARCIAL

**Evidência no código:** `custom_alert.dart:3-81` — duas funções com typo no nome (`customAalert`), assinaturas diferentes, `customAalertQuestion` com callback opcional `onPressedNot`.

**Cobertura documental:**
- `error-handling.md` seção 4: ambas as funções listadas na tabela de componentes com arquivo e uso.

**Avaliação:** Parcial.

**O que falta:**
- O typo `customAalert` (duplo 'a') nos nomes de ambas as funções não é mencionado — pode gerar dificuldade em encontrar as funções por quem lê a documentação e procura `customAlertQuestion` no código.
- O parâmetro `onPressedNot = null` (callback opcional do "Não") não está documentado.
- Diferença entre as duas funções — uma requer `BuildContext`, a outra usa `Get.dialog` — não é comparada ou explicada nos docs.

---

### 3.4 `custom_toast.dart` / `CustomToast.showToasts()` e `abstract class status` — COMPLETO

**Evidência no código:** `custom_toast.dart:6-32` — classe `CustomToast`, método `showToasts()`, classe abstrata `status` com constantes string `success`, `warner`, `error`.

**Cobertura documental:**
- `error-handling.md` seção 4: tabela lista `CustomToast.showToasts`, arquivo, uso; seção de problemas menciona que `status` usa `String` em vez de `enum`.

**Avaliação:** Completo.

---

## 4. Segredos e credenciais hardcoded

### 4.1 `'KeyMaster'` — COMPLETO

**Evidência no código:** `login_controller.dart:47` — `if (usuario == 'admin' && senha == 'KeyMaster')`.

**Cobertura documental:**
- `security.md` seção S-04: documenta o achado com código real, impacto (severidade Alta), sugestões de correção.
- `authentication-and-interceptors.md` seção 12.1 (S-04): mesma cobertura.

**Avaliação:** Completo — dois documentos cobrem o achado.

**Problema identificado (item 6 — duplicação):** O achado S-04 (credencial hardcoded) aparece com nível de detalhe semelhante em `security.md` e `authentication-and-interceptors.md` seção 12, criando duplicação. Em `authentication-and-interceptors.md`, seção 12.1 diz "Severidade: 🔴 Alta", enquanto `security.md` lista como "S-04 — 🟠 Alto" (grafias e ícones diferentes para o mesmo achado).

**Problema identificado (item 7 — conflito):** `authentication-and-interceptors.md` seção 12.1 S-04 classifica como `🔴 Alta`, enquanto a matriz de risco de `security.md` classifica S-04 como `🟠 Alto`. Há discrepância de severidade entre os dois documentos para o mesmo achado.

---

### 4.2 IP `192.168.1.192` hardcoded — COMPLETO

**Evidência no código:** `lib/src/constants/Endpoints.dart:8` — `String? baseUrl = 'http://192.168.1.192:7021';` (confirmado via documentação — arquivo não foi lido diretamente nesta auditoria, mas está referenciado em múltiplos docs com linha exata).

**Cobertura documental:**
- `security.md` seção S-06: documenta o achado, impacto, linha exata, correção.
- `authentication-and-interceptors.md` seção 9 e 12.1 (S-05): documenta o mesmo.
- `api-configuration.md` seção 6.1 e 6.3: documenta o fallback, a variável mutável global, problemas de thread-safety.

**Avaliação:** Completo — três documentos cobrem o achado.

---

## 5. Análise de sobreposições e conflitos entre documentos

### 5.1 Sobreposições identificadas (item 6 — Duplicações)

| Conteúdo | Documentos que duplicam |
|---|---|
| Código do `restRequest()` completo | `api-configuration.md` seção 3.2 + `authentication-and-interceptors.md` seção 5 + `error-handling.md` seção 3 |
| Tabela de `DioExceptionType` → mensagens | `api-configuration.md` seção 4 + `error-handling.md` seção 3 |
| Código do `ErrorWidget.builder` | `custom-error-screen.md` seção 3 + `error-handling.md` seção 2 |
| Achado S-01 (badCertificateCallback) | `security.md` seção S-01 + `authentication-and-interceptors.md` seção 12.1 |
| Achado S-04 (KeyMaster hardcoded) | `security.md` seção S-04 + `authentication-and-interceptors.md` seção 12.1 S-04 |
| Fluxo de refresh token (diagrama + código) | `authentication-and-interceptors.md` seção 6 + `api-configuration.md` seção 3.4 |

Todas as sobreposições ocorrem sem referência cruzada entre os documentos duplicadores. Risco de divergência futura em manutenção.

---

### 5.2 Conflitos identificados (item 7 — Conflitos)

| Conflito | Local no código | Doc A | Doc B |
|---|---|---|---|
| Severidade S-04 (KeyMaster) | `login_controller.dart:47` | `authentication-and-interceptors.md` seção 12.1: `🔴 Alta` | `security.md` matriz: `🟠 Alto` |
| Nome do campo de cache | `login_repository.dart:38` | `authentication-and-interceptors.md` seção 3.3 e 4.1: usa `'Autenticacao'` | `security.md` seção S-02 linha 103: referencia `login_repository.dart` linha 37-38 correto, mas `authentication-and-interceptors.md` seção 12.1 S-02 diz "Linha 14, 38" — linha 14 não existe no repositório; a operação de `setCache` está na linha 37-38. Discrepância de números de linha. |

---

## 6. Decisões não documentadas (item 8)

| # | Decisão | Evidência no código | Documentada? |
|---|---|---|---|
| D-01 | `token()` definida como função de arquivo global em vez de método de classe | `http_manager.dart:118` | Problema citado mas motivação não registrada |
| D-02 | `LoginRepository login = LoginRepository()` como instância global de arquivo em `http_manager.dart` — quebra IoC | `http_manager.dart:17` | Problema citado em `api-configuration.md` seção 3.4, mas razão (provável dependência circular GetX) não documentada |
| D-03 | `limparTodoCache()` não chamado no signOut — limpeza parcial intencional ou bug? | `http_manager.dart:139-141` | Mencionado como observação em `authentication-and-interceptors.md` seção 7 mas sem clareza se intencional |
| D-04 | `LogInterceptor` comentado — razão desconhecida | `http_manager.dart:29-38` | Não documentado |
| D-05 | Método HTTP PATCH para login (não POST) | `login_repository.dart:33` | Mencionado em `authentication-and-interceptors.md` seção 9 e `security.md` seção S-07 como "incomum" — mas razão não documentada (convenção do backend?) |
| D-06 | `Refreshtoken()` dispara loading global durante renovação silenciosa | `login_repository.dart:58-61` | Não documentado em `authentication-and-interceptors.md` |
| D-07 | Variáveis globais de arquivo em `confirmar_acesso.dart` (estado compartilhado entre exibições do dialog) | `confirmar_acesso.dart:12-17` | Não documentado |
| D-08 | `@override void dispose()` em nível de arquivo (sintaxe inválida) | `confirmar_acesso.dart:20-24` | Não documentado |

---

## 7. Aprofundamentos necessários (item 4)

### 7.1 `confirmar_acesso.dart` — arquivo inteiramente ausente da documentação

O arquivo implementa uma segunda rota de autenticação para acesso privilegiado à tela de Settings, com bugs estruturais sérios (estado global que vaza entre sessões do dialog, `dispose()` inefetivo). Merece seção própria na documentação, preferencialmente em `authentication-and-interceptors.md` como "Fluxo de Acesso às Configurações do App".

### 7.2 Retry recursivo sem limite — aprofundamento necessário em `error-handling.md`

O risco de loop infinito documentado em `error-handling.md` seção 3 e `authentication-and-interceptors.md` seção 12.1 S-03 cita um cenário hipotético ("se a API retornar 401 mesmo após um refresh bem-sucedido"). Um aprofundamento real deveria cobrir: há algum mecanismo do backend que possa causar isso? Há testes que provem o limite de profundidade na prática? A resposta hoje é: não há e não há.

### 7.3 Cleartext traffic (`network_security_config.xml`) — documentado em `security.md` mas não rastreado ao nível de `api-configuration.md`

O `api-configuration.md` documenta que `baseUrl` usa `http://` mas não conecta isso ao `network_security_config.xml`. Um leitor de `api-configuration.md` não saberá que o tráfego em claro é permitido no nível da configuração Android. O link entre os dois documentos está ausente.

---

## 8. Consolidado por item auditado

| Símbolo / Arquivo | Status | Documento(s) primário(s) | Lacunas |
|---|---|---|---|
| `restRequest()` | Completo | `api-configuration.md` §3.2, `authentication-and-interceptors.md` §5, `error-handling.md` §3 | Triplicação sem referência cruzada |
| `token()` | Completo | `api-configuration.md` §3.3, `auth-and-interceptors.md` §4.2 | Motivação do escopo global não registrada |
| `_tryRefreshToken()` | Completo | `authentication-and-interceptors.md` §6.3, `api-configuration.md` §3.4 | Motivação da dependência circular não registrada |
| `signOut()` | Completo | `authentication-and-interceptors.md` §7, `api-configuration.md` §3.5 | Intencionalidade da limpeza parcial não registrada |
| `_handleDioError()` | Completo | `api-configuration.md` §4, `error-handling.md` §3 | Duplicação da tabela |
| `badCertificateCallback => true` | Completo | `security.md` §S-01, `authentication-and-interceptors.md` §12.1 | Duplicação; razão original não documentada |
| `LogInterceptor` comentado | Completo | `authentication-and-interceptors.md` §8.1 | Razão do comentário não registrada |
| `login()` repository | Completo | `authentication-and-interceptors.md` §3.3 | Loading durante refresh não documentado em auth-doc |
| `Refreshtoken()` repository | Completo | `authentication-and-interceptors.md` §6.3 | Loading global durante refresh silencioso |
| `signIn()` controller | Completo | `authentication-and-interceptors.md` §3.3 | — |
| `loginSettings()` controller | Parcial | `security.md` §S-04, `authentication-and-interceptors.md` §12.1 | Fluxo funcional não documentado; apenas achado de segurança |
| `LoginControllerInterface` | Completo | `authentication-and-interceptors.md` §10.4 | — |
| `LoginRepositoryInterface` | Completo | `authentication-and-interceptors.md` §10.3 | — |
| `login.dart` (tela) | Completo | `authentication-and-interceptors.md` §3.1, §3.2 | Botão Settings na tela não descrito |
| `confirmar_acesso.dart` | Nao documentado | (ausente) | Arquivo inteiro sem cobertura documental |
| `CustomErrorWidget` | Completo | `custom-error-screen.md`, `error-handling.md` §2 | Duplicação entre os dois docs |
| `ErrorWidget.builder` em `main.dart` | Completo | `custom-error-screen.md` §4, `error-handling.md` §2 | Duplicação |
| `customAlertMessage()` | Completo | `error-handling.md` §4 | Guarda `Get.isDialogOpen` não documentada |
| `customAalertQuestion()` | Parcial | `error-handling.md` §4 | Typo no nome, callback opcional, não documentados |
| `customAalertInformation()` | Parcial | `error-handling.md` §4 | Typo no nome, diferença de contexto, não documentados |
| `CustomToast.showToasts()` + `class status` | Completo | `error-handling.md` §4 | — |
| `'KeyMaster'` hardcoded | Completo | `security.md` §S-04, `authentication-and-interceptors.md` §12.1 | Conflito de severidade entre os dois docs |
| IP `192.168.1.192` hardcoded | Completo | `security.md` §S-06, `api-configuration.md` §6.3 | — |

---

## 9. Percentual estimado de cobertura da área

**Cobertura estimada: 72%**

**Justificativa:**

A cobertura é alta para os componentes centrais (HttpManager, fluxo de login, refresh, signOut, error widget, segurança), que recebem documentação detalhada e correta em múltiplos documentos. A nota é puxada para baixo pelos seguintes itens não cobertos ou com cobertura insuficiente:

- `confirmar_acesso.dart` — arquivo inteiro sem documentação (representa a segunda rota de autenticação do app, com bugs estruturais sérios não capturados).
- `loginSettings()` — documentado apenas como achado de segurança, sem fluxo funcional.
- 8 decisões de design sem justificativa registrada (D-01 a D-08).
- Typo `"Logn"` e anomalias estruturais de `confirmar_acesso.dart` sem nenhum registro.
- Guarda `Get.isDialogOpen` em `customAlertMessage` não documentada.
- Comportamento de loading global durante `Refreshtoken()` não documentado em `authentication-and-interceptors.md`.
- Triplicação do fluxo `restRequest()` sem referência cruzada cria risco de divergência (não é ausência de cobertura, mas é um problema de qualidade documental que reduz a nota).

**Distribuição estimada:**
- Fluxo HTTP / Dio: 90%
- Autenticação / token / refresh: 85%
- Segurança: 85%
- Tela de erro customizada: 90%
- Feedback de erro (toast / alert): 75%
- `confirmar_acesso.dart` / loginSettings fluxo: 15%
- Decisões arquiteturais justificadas: 30%

---

## 10. Resumo executivo de achados-chave

1. **`confirmar_acesso.dart` totalmente ausente da documentação** — arquivo com fluxo de autenticação alternativa, 4 bugs estruturais (estado global, `dispose()` inefetivo, typo no título, `@override` fora de classe). Zero cobertura.

2. **`loginSettings()` documentado apenas como risco de segurança** — o fluxo funcional (acesso a Settings via login admin) não tem documentação funcional em nenhum documento.

3. **Triplicação do fluxo `restRequest()`** — descrito com código real em `api-configuration.md`, `authentication-and-interceptors.md` e `error-handling.md` sem referência cruzada. Risco de divergência.

4. **Conflito de severidade para credencial `'KeyMaster'`** — `authentication-and-interceptors.md` classifica como 🔴 Alta; `security.md` classifica como 🟠 Alto.

5. **Seção 12 de `authentication-and-interceptors.md`** replica os achados de segurança de `security.md` quase integralmente — duplicação de todo o catálogo de achados S-01 a S-06.

6. **8 decisões de design sem justificativa registrada** — incluindo razão da dependência circular `http_manager.dart` → `LoginRepository`, razão do PATCH em vez de POST no login, e razão do `LogInterceptor` comentado.

7. **Loading global durante `Refreshtoken()`** — comportamento não documentado em `authentication-and-interceptors.md`, causa experiência inesperada para o usuário durante renovação silenciosa de token.

8. **Guarda `Get.isDialogOpen`** em `customAlertMessage()` — comportamento relevante para reimplementação, não documentado.

9. **Cobertura dos componentes centrais é alta** — `HttpManager`, fluxo de login, `_handleDioError`, `CustomErrorWidget`, achados de segurança S-01 a S-10, e interfaces estão bem documentados com código real.

10. **Cobertura estimada da área: 72%** — penalizada principalmente por `confirmar_acesso.dart` (ausente), decisões arquiteturais sem justificativa, e duplicações sem referência cruzada que criam risco de divergência futura.

---

*Auditoria baseada em leitura integral de todos os arquivos de código-fonte citados no escopo e confronto com os 6 documentos listados. Todas as evidências são referenciadas por arquivo e símbolo/linha.*
