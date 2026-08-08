# ADR-0002: Persistência e segurança (preservar Hive/Dio, melhorar sem mudar comportamento)

- **Status:** Aceito
- **Data:** 2026-06-24
- **Decisores:** Time / Tech Lead / Segurança
- **Postura:** preservar a stack atual; aplicar apenas melhorias retrocompatíveis. Ver [documentation-stance.md](../../00-overview/documentation-stance.md).

## Contexto
O legado persiste cache, configurações de ambiente e o token de autenticação em **Hive** (`hive` 2.2.3), e faz rede com **Dio** (5.8.0). A engenharia reversa identificou achados de segurança factuais (SSL aceito sem validação; token em cache não criptografado; credencial `KeyMaster` hardcoded; IP de fallback hardcoded). O objetivo do template é **manter Hive e Dio** e tratar esses pontos como **melhorias que não alteram o comportamento funcional**.

## Decisão
1. **Persistência:** manter **Hive/hive_flutter** como camada de storage e config de ambiente (`variaves_ambiente`).
2. **Rede:** manter **Dio** encapsulado em `HttpManager` (com refresh token).
3. **Melhorias de segurança retrocompatíveis** (mesmas libs, comportamento preservado):
   - Restringir `badCertificateCallback` a `kDebugMode` (produção valida TLS).
   - Opcional: criptografar o cache sensível com `HiveAesCipher` (sem mudar a interface `HiveServices`).
   - Limitar a profundidade do retry de refresh token.
   - Remover credencial hardcoded; mover segredos/IP para config (mantendo o override por Hive já existente).

## Alternativas consideradas
- Trocar Hive por `flutter_secure_storage`/`shared_preferences`/`drift`: registrado como **consideração futura**, **não adotado** agora (contraria a preservação da stack).

## Consequências
- ➕ Mantém a stack dominada e validada; melhorias são incrementais e opcionais.
- ➕ Fecha os achados de segurança sem reescrever a camada de dados.
- 🔭 Reavaliar Hive apenas se houver incompatibilidade futura (ver [recommended-stack §4](../../07-template-blueprint/recommended-stack.md)).
