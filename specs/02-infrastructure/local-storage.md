# Persistência Local, Cache e Modelos/Serialização

> **Escopo T3 — Infraestrutura Técnica**
> Documento gerado por engenharia reversa do projeto `controle_separacao_aplicativo`.
> Não contém regras de negócio.

---

## 1. Visão Geral

O projeto utiliza **Hive 2.2.3** como único mecanismo de persistência local. Não há SQLite, Drift, Isar ou SharedPreferences. Três boxes Hive são usados com propósitos distintos:

| Box Hive | Responsabilidade | Criado/acessado em |
|---|---|---|
| `Cache_aplicativo` | Cache genérico da aplicação — dados de sessão e autenticação (`Autenticacao` é uma chave neste box) | `HiveServices` |
| `variaves_ambiente` | Configurações do app (baseUrl, flag de logger) | `SettingsAppRepository` |

> **Correção factual:** `Autenticacao` **NÃO é um box separado** — é uma **chave** (`nameFild: 'Autenticacao'`) dentro do box `Cache_aplicativo`. Ver §4.2 e o código em `HiveServices.dart` (`Hive.box('Cache_aplicativo')`).

> **Atenção de segurança:** O token JWT é armazenado em texto plano no box `Cache_aplicativo` sob a chave `'Autenticacao'`, sem criptografia. Ver Seção 5.

---

## 2. Interface HiveServicesInterface

**Arquivo:** `lib/src/core/abstracts/Hive_services_interface.dart`

```dart
abstract class HiveServicesInterface {
  void setCache({required String nameFild, required dynamic values});
  Future<dynamic?> getCache({required String nameFild});
  void deleteCache({required String nameFild});
  void limparTodoCache();
}
```

A interface é minimalista e correta como contrato. Permite substituição da implementação por mock em testes. Uso via `Get.find<HiveServicesInterface>()`.

---

## 3. Implementação — HiveServices

**Arquivo:** `lib/src/core/services/Hive_services.dart`

### 3.1 Operações CRUD

```dart
class HiveServices implements HiveServicesInterface {
  final Box box = Hive.box('Cache_aplicativo');

  // WRITE — não-async apesar de chamar await internamente
  void setCache({required String nameFild, required dynamic values}) async {
    try {
      await box.put(nameFild, values);
    } catch (e) {
      logservices.log('Erro ao salvar...', level: Level.error);
      CustomToast().showToasts(messagem: 'Erro ao salvar os dados no Cacher.', status: status.error);
    }
  }

  // READ — retorna dynamic?
  Future<dynamic?> getCache({required String nameFild}) async {
    try {
      return await box.get(nameFild);
    } catch (e) { ... }
  }

  // DELETE
  void deleteCache({required String nameFild}) async {
    try {
      await box.delete(nameFild);
    } catch (e) { ... }
  }

  // CLEAR ALL
  void limparTodoCache() async {
    try {
      await box.clear();
    } catch (e) { ... }
  }
}
```

### 3.2 Problemas Identificados

| # | Problema | Impacto |
|---|---|---|
| H1 | `setCache` e `deleteCache` e `limparTodoCache` declaram `void` mas executam `await` — chamador não pode aguardar conclusão nem capturar erros | Alto (race conditions, dados inconsistentes) |
| H2 | `getCache` retorna `Future<dynamic?>` — sem tipagem, requer cast/decode manual no ponto de uso | Médio (erros em runtime) |
| H3 | Todos os métodos usam o box `Cache_aplicativo`, mas autenticação e configurações usam boxes diferentes acessados diretamente — não há abstração unificada | Médio (fragmentação) |
| H4 | Erros mostram `CustomToast` dentro do serviço de persistência — acoplamento com UI | Médio (testabilidade) |
| H5 | Nenhum mecanismo de TTL (time-to-live) para entradas do cache | Baixo |
| H6 | Hive 2.2.3 — versão antiga; `hive_ce` (community edition) mantém ativa | Baixo-Médio |

---

## 4. Boxes Separados Fora do HiveServices

### 4.1 Box `variaves_ambiente` — SettingsAppRepository

**Arquivo:** `lib/src/core/features/settings_app/repository/settings_app_repository.dart`

```dart
final Box box = Hive.box('variaves_ambiente');

void setBaseUrl({required String url}) async => await box.put('baseUrl', url);
Future<String?> getBaseUrl() async => box.get('baseUrl');

void setLogger({required bool logger}) async => await box.put('logger', logger);
Future<bool?> getLogger() async => box.get('logger');
```

**Problema:** o repositório de configurações abre o box diretamente, sem passar pelo `HiveServices`. Quebra a abstração — há dois padrões diferentes de acesso ao Hive no mesmo projeto.

### 4.2 Chave `'Autenticacao'` dentro do box `Cache_aplicativo`

> **Correção factual:** `Autenticacao` **não é um box separado**. É a chave (`nameFild`) usada para gravar e ler o JSON do token dentro do box `Cache_aplicativo` (o único box gerenciado pelo `HiveServices`).

O token é salvo no box `Cache_aplicativo` com a chave `'Autenticacao'`:

```dart
// Em LoginRepository (após login bem-sucedido):
hiveServices.setCache(nameFild: 'Autenticacao', values: jsonEncode(result.data));

// Em token() — função global no http_manager.dart:
var json = await hiveServices.getCache(nameFild: 'Autenticacao');
var obj = jsonDecode(json);
return obj['accessToken'];

// Em NfsPedidosRepository — leitura do campo 'setor':
var json = await hiveServices.getCache(nameFild: 'Autenticacao');
var obj = jsonDecode(json);
setor = obj['setor'];
```

**Problemas:** a chave `'Autenticacao'` é uma string mágica repetida em pelo menos 6 arquivos diferentes. O JSON é armazenado como string e decodificado manualmente em cada ponto de uso. Campo `setor` é lido do token de autenticação nos repositórios (lógica duplicada).

---

## 5. Risco de Segurança — Token em Hive Não Criptografado

> **RISCO CRÍTICO — Remeter ao documento de segurança do projeto.**

O `accessToken` JWT é armazenado em texto plano no box Hive `Cache_aplicativo`. Hive sem `HiveAesCipher` não aplica qualquer criptografia ao banco de dados local (arquivo `.hive` no diretório de dados do app).

**Cenários de risco:**
- Em dispositivos com root/jailbreak, qualquer app pode ler o arquivo `.hive`.
- Backups automáticos do Android (se não configurado `android:allowBackup="false"`) podem expor o arquivo.
- Análise forense extrai o token em texto claro.

**Recomendação para o template moderno:**
Usar `flutter_secure_storage` para tokens de autenticação — armazena no Keychain (iOS) e EncryptedSharedPreferences/Android Keystore (Android), sem acesso por outras apps mesmo com root.

```dart
// Substituição recomendada
final storage = FlutterSecureStorage();
await storage.write(key: 'accessToken', value: token);
final token = await storage.read(key: 'accessToken');
```

---

## 6. Classificação dos Componentes de Persistência

| Componente | Classificação | Justificativa |
|---|---|---|
| Interface `HiveServicesInterface` (conceito) | 🟢 Reutilizar com melhorias | Boa abstração; adicionar generics e retornos async corretos |
| `HiveServices` — implementação atual | 🟡 Refatorar | Corrigir assinaturas void/async, remover UI, adicionar tipagem |
| Box `variaves_ambiente` via SettingsAppRepository | 🟡 Refatorar | Unificar padrão de acesso; usar abstração única |
| Token em Hive sem criptografia | 🟡 Refatorar | Adicionar `HiveAesCipher` ao box existente — **sem trocar biblioteca** |
| Hive 2.2.3 para dados não-sensíveis | ✅ Reutilizar (preservar) | Funciona em produção; monitorar compatibilidade Dart 4 (consideração futura) |
| Chave string mágica `'Autenticacao'` | 🟡 Refatorar | Centralizar em constantes tipadas (sem trocar biblioteca) |
| Leitura de `setor` do token nos repositórios | 🟡 Refatorar | Extrair para `SessionRepository` — sem trocar tecnologia |

---

## 7. Seção: Modelos e Serialização

### 7.1 Padrão de Serialização Adotado

Todos os 26 modelos do projeto usam **serialização manual** com `fromJson` e `toJson` escritos à mão. O `pubspec.yaml` declara `json_annotation: ^4.4.0`, mas **não há `build_runner`** nos `dev_dependencies` e nenhum arquivo `.g.dart` gerado — `json_annotation` está declarado mas não utilizado.

### 7.2 Anatomia dos Modelos

**Padrão típico** (todos os modelos seguem esta estrutura):

```dart
class NfModel {
  final int empresaCod;
  final DateTime dhEmissao;
  final Fornecedor fornecedor;      // objeto aninhado

  NfModel({required this.empresaCod, ...});

  factory NfModel.fromJson(Map<String, dynamic> json) {
    return NfModel(
      empresaCod: json['empresaCod'] ?? 0,
      dhEmissao: DateTime.parse(json['dhEmissao']),
      fornecedor: Fornecedor.fromJson(json['fornecedor']),  // recursivo
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'empresaCod': empresaCod,
      'dhEmissao': DateFormat("yyyy-MM-dd").format(dhEmissao),
      'fornecedor': fornecedor.toJson(),
    };
  }

  Map<String, dynamic> toMap() { return toJson(); }  // duplicata — alias sem utilidade
}
```

### 7.3 Modelos Encontrados

| Arquivo | Classe | Observações |
|---|---|---|
| `login_model.dart` | `LoginModel` | Simples, apenas usuario/senha |
| `nf_model.dart` | `NfModel` | Aninhado (Fornecedor), DateTime manual |
| `pedidos_model.dart` | `PedidosModel` | Sem fromJson — somente toMap |
| `itens_pedido_model.dart` | `ItensPedidoModel` | `?? false` em campos já non-nullable (redundante) |
| `produto_model.dart` | `Produto` | Lista aninhada de `Conferencias` |
| `empresas_model.dart` | `EmpresasModel` | Simples |
| `pedido_venda.dart` | `PedidoVenda` | Usado com paginação (`result.data['data']`) |
| `itens_nf_model.dart` | `ItenNotaFiscal` | — |
| `nf_lotes_model.dart` | `NfLotesModel` | — |
| `grupo_model.dart` | `Grupo` | Sub-modelo de Produto |
| `fornecedor_model.dart` | `Fornecedor` | Sub-modelo de NfModel |
| `estagio_model.dart` | `Estagio` | — |
| `conferencias_model.dart` | `Conferencias` | Lista aninhada em Produto |
| `log_operacoes_model.dart` | `LogOperacoesModel` | — |
| `buscar_produtos_model.dart` | `BuscarProdutosModel` | — |
| `consultar_nf_saida_model.dart` | `ConsultarNfSaidaModel` | — |
| `nota_compra_lotes_etiquetas.dart` | `NotaCompraLotesEtiquetas` | — |
| `transferenci_lote.dart` | `TransferenciaLote` | Typo no nome do arquivo |
| `tansf_mov_lote.dart` | `TansfMovLote` | Typo no nome do arquivo (nome da classe preserva o typo do legado) |
| `selecionar_material_estoque_model.dart` | `SelecionarMaterialEstoqueModel` | — |
| `itens_pedido_nf_lotes_model.dart` | `ItensPedidoNfLotesModel` | — |
| `pedido_completo_model.dart` | `PedidoCompleto` | — |
| `nf_pagas_model.dart` | `NfPagasModel` | — |
| `item_model.dart` | `Item` | — |

### 7.4 Problemas da Serialização Manual

| # | Problema | Impacto |
|---|---|---|
| S1 | `toMap()` duplica `toJson()` sem razão — boilerplate puro | Baixo |
| S2 | Sem `copyWith()` — dificulta atualização imutável de estado | Médio |
| S3 | Sem `==` / `hashCode` — comparações de modelos sempre falsas | Médio |
| S4 | `json_annotation` declarado mas não usado — confusão intencional ou esquecimento | Baixo |
| S5 | Campos `non-nullable` com `?? false` em `toJson` (ex: `impresso ?? false`) — código Dart inválido semanticamente mas compila | Baixo |
| S6 | DateTime serializado com `DateFormat("yyyy-MM-dd")` em `toJson` — perde horas/minutos (pode causar bugs) | Médio |
| S7 | Nenhum modelo tem `toString()` adequado — debug difícil | Baixo |
| S8 | Typos nos nomes de arquivo (`transferenci_lote`, `tansf_mov_lote`) | Baixo (manutenibilidade) |
| S9 | Sem validação de tipos em `fromJson` — erro em runtime se API mudar formato | Alto |

### 7.5 Classificação dos Modelos

| Componente | Classificação | Justificativa |
|---|---|---|
| Padrão `fromJson`/`toJson` manual | ✅ Reutilizar (preservar) | Padrão atual funcionando em produção; automatização é consideração futura |
| `toMap()` como alias de `toJson()` | 🟡 Refatorar | Redundante; padronizar em `toJson()` apenas — sem nova biblioteca |
| Estrutura de modelos aninhados | 🟢 Reutilizar com melhorias | Conceito correto; apenas automatizar geração futuramente |
| Tipo de retorno `dynamic` nos repositórios | 🟡 Refatorar | Adicionar tipagem forte com generics — sem nova biblioteca |

### 7.6 Direção de Serialização no Template

**Padrão atual (preservar):** `fromJson`/`toJson` manuais com `json_annotation` já presente.

As melhorias internas aplicáveis **sem novas bibliotecas**:
- Remover `toMap()` redundante.
- Adicionar `==`, `hashCode` e `toString()` manualmente nos modelos principais.
- Adicionar `copyWith()` onde necessário.
- Centralizar parsing de DateTime para evitar perda de horas/minutos.

> ⚠️ **Consideração futura (NÃO aplicar agora).** A direção atual é preservar a stack (ver [documentation-stance](../00-overview/documentation-stance.md)). O conteúdo abaixo é apenas conhecimento técnico para decisão futura.

Uma alternativa futura seria adotar geração automática de código:

```yaml
# Futuro (não aplicar agora)
dependencies:
  freezed_annotation: ^2.4.4
  json_annotation: ^4.9.0

dev_dependencies:
  build_runner: ^2.4.13
  freezed: ^2.5.7
  json_serializable: ^6.8.0
```

Benefícios técnicos dessa alternativa futura: `fromJson`/`toJson` gerados, `copyWith()`, `==`/`hashCode` e `toString()` automáticos, imutabilidade garantida, union types para estados.

---

## 8. Direção de Persistência para o Template

### 8.1 Persistência Local (direção atual — preservar stack)

```
Hive (hive 2.2.3 + HiveAesCipher)  →  todos os dados (token, cache, config)
```

A melhoria de segurança aplicável **sem trocar biblioteca** é ativar `HiveAesCipher` no box `Cache_aplicativo`. A chave de cifragem pode ser gerada uma vez e armazenada em memória ou em `SharedPreferences` (já disponível transitivamente).

### 8.2 Arquitetura Sugerida (compatível com stack atual)

```
StorageModule
├── HiveServices (hive + HiveAesCipher)     →  cache de tela, autenticação (chave 'Autenticacao')
├── SettingsAppRepository (box variaves_ambiente)  →  baseUrl, flag de logger
└── SessionRepository (abstração nova, sobre HiveServices existente)
    ├── getAccessToken() → Future<String?>
    ├── saveSession(SessionModel) → Future<void>
    └── clearSession() → Future<void>
```

### 8.3 Chaves de Storage Centralizadas (melhoria interna)

```dart
abstract class StorageKeys {
  static const autenticacao  = 'Autenticacao';  // chave no box Cache_aplicativo
  static const baseUrl       = 'baseUrl';        // chave no box variaves_ambiente
  static const loggerEnabled = 'logger';         // chave no box variaves_ambiente
}
```

> ⚠️ **Consideração futura (NÃO aplicar agora).** A direção atual é preservar a stack (ver [documentation-stance](../00-overview/documentation-stance.md)). O conteúdo abaixo é apenas conhecimento técnico para decisão futura.

Uma alternativa futura seria separar tokens sensíveis em `flutter_secure_storage` (Keychain/Keystore) e mover configurações para `shared_preferences`. Esta separação eliminaria a dependência do Hive para casos de uso simples, mas exige migração de dados e nova dependência.

```
# Alternativa futura (não aplicar agora)
flutter_secure_storage   →  tokens e dados sensíveis (Keychain/Keystore)
shared_preferences       →  configurações simples (baseUrl, logger flag)
```

> **Catálogo completo de modelos:** ver [models-catalog.md](./models-catalog.md) para inventário detalhado dos 26 modelos.

---

## 9. Referências de Arquivos

| Arquivo | Papel |
|---|---|
| `lib/src/core/services/Hive_services.dart` | Implementação do cache genérico Hive |
| `lib/src/core/abstracts/Hive_services_interface.dart` | Contrato da persistência |
| `lib/src/core/features/settings_app/repository/settings_app_repository.dart` | Box `variaves_ambiente` — baseUrl e logger |
| `lib/src/core/features/login/repository/login_repository.dart` | Salva e lê token de autenticação |
| `lib/src/core/services/http_manager.dart` | Função `token()` — lê accessToken do Hive |
| `lib/src/models/` | 26 modelos com serialização manual |
| `pubspec.yaml` | Dependências: hive 2.2.3, json_annotation (sem build_runner) |
