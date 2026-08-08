# Segurança — Análise de Infraestrutura

> **Classificação geral: 🔴 CRÍTICO — múltiplos achados de segurança graves em produção**
> Este documento lista achados ordenados por severidade. Os dois primeiros (SSL e token em claro) são **bloqueadores para qualquer ambiente com dados reais**.

---

## Índice de Achados

| # | Achado | Severidade |
|---|---|---|
| S-01 | `badCertificateCallback => true` — aceita qualquer certificado SSL | 🔴 Crítico |
| S-02 | Token de autenticação armazenado em Hive não criptografado | 🔴 Crítico |
| S-03 | `cleartext traffic` habilitado — HTTP em claro permitido | 🔴 Crítico |
| S-04 | Ausência de obfuscação de código Dart em release | 🟠 Alto |
| S-05 | `print()` expõe dados sensíveis em logcat | 🟠 Alto |
| S-06 | IP hardcoded como `baseUrl` padrão | 🟡 Médio |
| S-07 | Credenciais de login não validadas localmente antes do envio | 🟡 Médio |
| S-08 | Ausência de certificate pinning | 🟡 Médio |
| S-09 | Ausência de `flutter_secure_storage` para dados sensíveis | 🟠 Alto |
| S-10 | Permissão `WRITE_EXTERNAL_STORAGE` no Android | 🟡 Médio |

---

## S-01 — `badCertificateCallback => true` (MITM)

### Severidade: 🔴 CRÍTICO

### Como está hoje

`lib/src/core/services/http_manager.dart` (linhas 23–27):

```dart
HttpManager() {
  (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
      (HttpClient client) {
    client.badCertificateCallback = (cert, host, port) => true; // ← CRÍTICO
    return client;
  };
}
```

### Impacto

Esta configuração faz o app **aceitar qualquer certificado SSL**, incluindo:
- Certificados expirados
- Certificados autoassinados sem validação
- Certificados de atacantes em redes Wi-Fi públicas (Man-in-the-Middle)

Em um ataque MITM, o atacante pode:
1. Interceptar credenciais de login (usuário + senha)
2. Capturar o `accessToken` JWT em todas as requisições
3. Ler e modificar qualquer dado trafegado

O comentário no código (`// Ignorar SSL e aceitar HTTP`) confirma que é uma decisão deliberada, provavelmente para ambiente de desenvolvimento com certificado autoassinado — mas foi deixada em produção.

### Correção recomendada para o template

**Opção A — Remover o callback (solução mínima):**

```dart
// Simplesmente não defina onHttpClientCreate
// O Dio usa validação SSL padrão do Dart (correta)
HttpManager() {
  // sem badCertificateCallback
}
```

**Opção B — Certificate Pinning (solução recomendada para produção):**

```dart
// pubspec.yaml: dio, ssl_pinning_plugin ou http_certificate_pinning
HttpManager() {
  (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
      (HttpClient client) {
    // Aceita apenas certificados com SHA-256 específico
    client.badCertificateCallback = (X509Certificate cert, String host, int port) {
      final fingerprint = sha256.convert(cert.der).toString();
      return _allowedFingerprints.contains(fingerprint);
    };
    return client;
  };
}
const _allowedFingerprints = ['AA:BB:CC:...'];
```

**Para ambiente de dev com certificado autoassinado:**

```dart
// Usar dart-define para ativar apenas em debug/staging
final skipSsl = bool.fromEnvironment('SKIP_SSL_VALIDATION', defaultValue: false);
client.badCertificateCallback = (cert, host, port) => skipSsl;
```

---

## S-02 — Token de Autenticação em Hive Não Criptografado

### Severidade: 🔴 CRÍTICO

### Como está hoje

**Armazenamento** (`lib/src/core/features/login/repository/login_repository.dart`, linha 37–38):

```dart
hiveServices.setCache(
    nameFild: 'Autenticacao', values: jsonEncode(result.data));
```

**Leitura** (`lib/src/core/services/http_manager.dart`, linhas 119–126):

```dart
Future<String> token() async {
  var json = await hiveServices.getCache(nameFild: 'Autenticacao');
  if (json != null) {
    var obj = jsonDecode(json);
    return obj['accessToken']; // ← JWT em claro no Hive
  }
  return '';
}
```

**Box do Hive** (`lib/src/core/services/Hive_services.dart`, linha 13):

```dart
final Box box = Hive.box('Cache_aplicativo'); // ← Box não criptografada
```

O JSON armazenado contém (baseado no uso de `Autenticacao['usuario']` e `Autenticacao['accessToken']`):
```json
{
  "accessToken": "eyJhbGciOiJSUzI1NiIsInR5...",
  "usuario": "nome_do_usuario",
  "refreshToken": "..."  // provável
}
```

### Impacto

- Em dispositivos rooteados/com jailbreak: qualquer app pode ler o arquivo do Hive
- Em backups ADB sem criptografia: arquivo extraível sem root
- O `accessToken` JWT em claro permite impersonar o usuário sem senha

### Correção recomendada para o template

**Opção imediata — `HiveAesCipher` (sem trocar biblioteca):**

Ativar criptografia no próprio Hive, sem nova dependência. A chave AES pode ser gerada uma vez e persistida em `SharedPreferences` (já disponível transitivamente):

```dart
// Gerar chave uma vez e persistir
final encryptionKey = Hive.generateSecureKey();
// Persistir a chave em local seguro (ex: SharedPreferences criptografado)

// Abertura da box criptografada
final cipher = HiveAesCipher(encryptionKey);
await Hive.openBox('Cache_aplicativo', encryptionCipher: cipher);
```

> ⚠️ **Consideração futura (NÃO aplicar agora).** A direção atual é preservar a stack (ver [documentation-stance](../00-overview/documentation-stance.md)). O conteúdo abaixo é apenas conhecimento técnico para decisão futura.

**Alternativa futura — `flutter_secure_storage` (nova dependência):**

```dart
// Alternativa futura (requer nova dependência: flutter_secure_storage: ^9.0.0)
class SecureStorageService {
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  Future<void> saveToken(String token) =>
      _storage.write(key: 'access_token', value: token);

  Future<String?> getToken() =>
      _storage.read(key: 'access_token');

  Future<void> deleteToken() =>
      _storage.delete(key: 'access_token');
}
```

---

## S-03 — Cleartext Traffic Habilitado

### Severidade: 🔴 CRÍTICO

### Como está hoje

**AndroidManifest.xml** (linha 12–13):

```xml
android:usesCleartextTraffic="true"
android:networkSecurityConfig="@xml/network_security_config">
```

**network_security_config.xml**:

```xml
<network-security-config>
    <domain-config cleartextTrafficPermitted="true">
        <domain includeSubdomains="true">*.*</domain>           <!-- QUALQUER domínio -->
        <domain includeSubdomains="true">192.168.1.192:7021</domain>
    </domain-config>
</network-security-config>
```

O wildcard `*.*` permite tráfego HTTP sem criptografia para **qualquer domínio**, o que combinado com `badCertificateCallback => true` deixa toda a comunicação da app completamente vulnerável.

### Impacto

- Credenciais transmitidas em claro em redes Wi-Fi abertas
- `accessToken` JWT interceptável por qualquer dispositivo na mesma rede

### Correção recomendada para o template

```xml
<!-- network_security_config.xml (produção) -->
<network-security-config>
    <base-config cleartextTrafficPermitted="false">
        <trust-anchors>
            <certificates src="system"/>
        </trust-anchors>
    </base-config>
</network-security-config>
```

Para ambiente de desenvolvimento interno (IP local), criar um `network_security_config_debug.xml` e referenciar apenas no flavor de debug:

```xml
<!-- network_security_config_debug.xml -->
<network-security-config>
    <domain-config cleartextTrafficPermitted="true">
        <domain includeSubdomains="false">192.168.1.192</domain>
    </domain-config>
</network-security-config>
```

---

## S-04 — Ausência de Obfuscação do Código Dart

### Severidade: 🟠 Alto

### Como está hoje

Nenhum arquivo de configuração de build (`android/app/build.gradle`, `ios/`) contém flags de obfuscação Dart. A opção `--obfuscate --split-debug-info` não está configurada.

### Impacto

O bytecode Dart em release é reversível com ferramentas como `dart-decompiler`. Um atacante pode extrair:
- Nomes de endpoints hardcoded
- Lógica de negócio
- Strings e constantes internas

### Correção recomendada para o template

```bash
# Build de produção sempre com obfuscação
flutter build apk --release \
  --obfuscate \
  --split-debug-info=build/debug-info/

flutter build ipa --release \
  --obfuscate \
  --split-debug-info=build/debug-info/
```

Guardar os arquivos de `split-debug-info` para symbolication de stack traces em ferramentas como Crashlytics.

---

## S-05 — `print()` Expõe Dados Sensíveis no Logcat

### Severidade: 🟠 Alto

### Como está hoje

Exemplos de `print()` com dados potencialmente sensíveis:

```dart
// selecionar_material_estoque_repository.dart — linha 40
print(Endpoints.notasFiscaisPagas + '?dhEntradaIni=2024-11-01&marcaProduto=...');

// conferir_material_saida_repository.dart — linha 78
print(jsonEncode(novoJson)); // payload completo da requisição

// conferir_material_saida_repository.dart — linha 146
print(jsonEncode(novoJson)); // outra serialização

// http_manager.dart
print('Erro no Dio: ${error.message}'); // mensagem de erro de rede com URL
```

### Impacto

- Em Android: `adb logcat` lê todos os `print()` de qualquer app sem root (até Android 4.1) ou com root
- Payloads de operações do negócio ficam visíveis no console de ferramentas de debug (Charles, Proxyman com `adb logcat`)
- Em builds de release, `print()` **não é removido automaticamente** pelo Flutter — continua ativo

### Correção recomendada para o template

```dart
// Substituir todos os print() por logger injetado
// Configurar Logger para suprimir em release:
final Logger _logger = Logger(
  filter: kReleaseMode ? ProductionFilter() : DevelopmentFilter(),
);

// ProductionFilter suprime debug e info em release automaticamente
// Para error e warning, nunca usar print — usar _logger.e() que vai para Crashlytics
```

---

## S-06 — IP Hardcoded como `baseUrl` Padrão

### Severidade: 🟡 Médio

### Como está hoje

`lib/src/constants/Endpoints.dart` (linha 8):

```dart
String? baseUrl = 'http://192.168.1.192:7021';
```

O IP `192.168.1.192` é um endereço de rede local (192.168.x.x). É o fallback caso `repository.getBaseUrl()` falhe.

### Impacto

- Em produção distribuída (app público): IP interno exposto no código compilado
- Reversão do APK revela topologia de rede interna
- Sem HTTPS no endereço padrão (protocolo `http://`)

### Correção recomendada para o template

```dart
// Usar dart-define para injetar a URL sem expor no código-fonte
// build: flutter run --dart-define=BASE_URL=https://api.empresa.com

abstract class Endpoints {
  static const String _defaultBaseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://api.staging.empresa.com', // staging seguro
  );
  static String get baseUrl => _baseUrl ?? _defaultBaseUrl;
}
```

---

## S-07 — Fluxo de Login sem Validação Local das Credenciais

### Severidade: 🟡 Médio

### Como está hoje

`lib/src/core/features/login/repository/login_repository.dart`:

```dart
Future<bool> login(LoginModel login) async {
  final result = await _httpManager.restRequest(
    url: Endpoints.login,
    method: HttpMethods.patch,       // ← PATCH para login (incomum; POST é padrão REST)
    body: jsonDecode(jsonEncode(login)),
  );
  if (result.statusCode == 200) {
    hiveServices.setCache(nameFild: 'Autenticacao', values: jsonEncode(result.data));
    return true;
  }
  ...
}
```

### Observações

- Método HTTP PATCH para login (não padrão; esperado seria POST)
- Sem validação de formato de email/senha antes do envio
- Sem rate limiting no lado do app (multiple requests possíveis)
- Credenciais enviadas via `body` — OK em HTTPS, mas vulnerável com cleartext ativo (ver S-03)

### Correção recomendada

```dart
// Validar antes de enviar
if (email.isEmpty || !email.contains('@')) throw ValidationFailure('E-mail inválido');
if (password.length < 8) throw ValidationFailure('Senha muito curta');

// Trocar PATCH por POST
method: HttpMethods.post,
```

---

## S-08 — Ausência de Certificate Pinning

### Severidade: 🟡 Médio

### Como está hoje

Sem `badCertificateCallback` (após corrigi S-01), o app valida certificados pelo sistema operacional (CA store). Isso é correto mas insuficiente para apps corporativos: qualquer CA raiz comprometida na loja do dispositivo permite MITM.

### Correção recomendada para o template

Ver S-01 (Opção B). Para apps corporativos internos, pinning do certificado do servidor ou da CA privada é recomendado.

---

## S-09 — Token em Hive sem Criptografia (armazenamento em repouso)

### Severidade: 🟠 Alto

_(Coberto em S-02 — seção de solução)_

O projeto não aplica criptografia no box Hive onde o token é armazenado. A correção imediata é ativar `HiveAesCipher` (recurso nativo do próprio Hive) sem trocar de biblioteca. A adoção de `flutter_secure_storage` é uma consideração futura — ver S-02 para detalhes.

---

## S-10 — `WRITE_EXTERNAL_STORAGE` no AndroidManifest

### Severidade: 🟡 Médio

### Como está hoje

`android/app/src/main/AndroidManifest.xml` (linha 3):

```xml
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
```

### Impacto

- No Android 10+, essa permissão é ignorada (Scoped Storage), mas sua presença no manifest pode levar a revisão negativa em lojas
- Em Android 9 e anteriores: permite ao app escrever em armazenamento compartilhado, acessível por outros apps
- Outros apps mal-intencionados podem ler arquivos escritos pelo app

### Correção recomendada

```xml
<!-- Limitar ao máximo necessário e adicionar maxSdkVersion -->
<uses-permission
    android:name="android.permission.WRITE_EXTERNAL_STORAGE"
    android:maxSdkVersion="28" />
<!-- Android 10+ usa Scoped Storage, não precisa da permissão -->
```

---

## Matriz de Risco Consolidada

| # | Achado | Severidade | Explorabilidade | Dado em risco | Esforço de correção |
|---|---|---|---|---|---|
| S-01 | `badCertificateCallback => true` | 🔴 Crítico | Alta (rede Wi-Fi) | Credenciais, tokens, todos os dados | Baixo (remover linha) |
| S-02 | Token em Hive não criptografado | 🔴 Crítico | Média (root/backup) | `accessToken`, dados de sessão | Baixo (HiveAesCipher — sem trocar biblioteca) |
| S-03 | Cleartext traffic habilitado | 🔴 Crítico | Alta (rede) | Todo o tráfego | Baixo (config XML) |
| S-09 | Token sem criptografia em repouso | 🟠 Alto | Média | Dados de sessão | Baixo (HiveAesCipher) |
| S-04 | Sem obfuscação | 🟠 Alto | Baixa (requer APK) | Lógica, endpoints | Baixo (flag de build) |
| S-05 | `print()` com dados sensíveis | 🟠 Alto | Baixa (adb) | URLs, payloads | Médio (refactor) |
| S-06 | IP hardcoded | 🟡 Médio | Baixa | Topologia de rede | Baixo (dart-define) |
| S-07 | Sem validação local de login | 🟡 Médio | Baixa | — | Baixo |
| S-08 | Sem certificate pinning | 🟡 Médio | Média | Todo o tráfego | Médio-Alto |
| S-10 | `WRITE_EXTERNAL_STORAGE` | 🟡 Médio | Baixa | Arquivos do app | Baixo |

---

## Checklist de Segurança para o Template

**Ações imediatas (sem trocar biblioteca):**
```
[ ] Remover badCertificateCallback (ou limitar a dart-define de debug)
[ ] Ativar HiveAesCipher no box Cache_aplicativo (criptografia do token no Hive existente)
[ ] Desativar cleartext traffic no network_security_config.xml (produção)
[ ] Configurar --obfuscate --split-debug-info em todos os builds de release
[ ] Substituir todos os print() por Logger configurado (sem output em release)
[ ] Mover baseUrl para dart-define (sem hardcode de IP)
[ ] Adicionar validação de credenciais antes do envio
[ ] Revisar permissões Android (maxSdkVersion no WRITE_EXTERNAL_STORAGE)
```

**Considerações futuras (NÃO aplicar agora — ver [documentation-stance](../00-overview/documentation-stance.md)):**
```
[ ] Implementar flutter_secure_storage para tokens (substituição do Hive para dados sensíveis)
[ ] Implementar certificate pinning (para ambientes corporativos)
[ ] Configurar Crashlytics/Sentry para capturar erros sem expor dados
```
