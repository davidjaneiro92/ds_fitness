# Ajustes Opcionais e Lacunas Documentais

> **Postura:** nada aqui é troca de stack. São (a) lacunas de documentação a registrar e (b) melhorias **opcionais e retrocompatíveis** dentro da stack atual. Ver [documentation-stance.md](../00-overview/documentation-stance.md).

## 1. Lacunas documentais do projeto legado (registro)

| Lacuna | Situação | Recomendação |
|--------|----------|--------------|
| ADRs | Inexistentes | Adotar ADRs (ver `adr/`) no template |
| Diagrama de arquitetura | Inexistente | Manter diagramas (Mermaid) em `/specs` |
| README atualizado | Parcial/desatualizado (cita `shared_preferences` ausente; só descreve árvore legada) | README do template reflete a estrutura real |
| Documentação de API | Inexistente | Documentar contratos consumidos |
| Guia de contribuição técnico | Só build/release | Incluir convenções, lint, testes |
| Estratégia de testes | Inexistente (só smoke default) | Ver [testing-strategy.md](../04-quality/testing-strategy.md) |

## 2. Higiene interna (recomendada, sem trocar stack)

1. Remover árvore legada `pages/` e duplicações (`services/`, `Interfaces/`, `pages_routes/`, `config/`).
2. Corrigir typos sistêmicos (`Trasferencia`, `colos`, `dropwn`, `nameFild`).
3. Substituir `print()` por `LogServices`/`logger` (lint `avoid_print`).
4. Padronizar nomenclatura (snake_case de arquivos; camelCase de métodos).

## 3. Melhorias opcionais retrocompatíveis (mesma stack)

| Área | Melhoria | Tecnologia (inalterada) |
|------|----------|--------------------------|
| DI | `Get.lazyPut`/`Bindings` em vez de `Get.put` eager | GetX |
| DI | Injetar repositórios via `Get.find()` (não `new`) | GetX |
| Estado | `Rx<T?>` em vez de objetos/datas sentinela | GetX |
| Navegação | Guards via `GetMiddleware` | GetX |
| HTTP | Limitar profundidade do retry de refresh | Dio |
| Segurança | `badCertificateCallback` só em `kDebugMode` | Dio |
| Segurança | `HiveAesCipher` no cache sensível (interface preservada) | Hive |
| Storage | `HiveServices` métodos `Future<void>` (awaitable) | Hive |
| Config | `--dart-define` mantendo override por Hive | — |
| Tema | tokens de cor/tipografia/spacing + dark mode | Material 3 |
| i18n | `flutter_localizations` + `.arb` (mantendo `intl`) | intl |
| Observabilidade | crash reporting plugável no `LogServices` | logger |

## 4. Considerações futuras (NÃO aplicar agora)

> Apenas conhecimento para decisão posterior — fora da direção atual.
> - Monitorar manutenção de `hive` 2.x.
> - Consolidar `fluttertoast` em `oktoast`.
> - Avaliar alternativas de `barcode_scan2` só se houver incompatibilidade.
> - Alternativas de stack (Riverpod/go_router/get_it, freezed) ficam registradas sem prioridade.

## 5. Como evoluir esta documentação

- Trate `/specs` como fonte viva: cada decisão nova vira um ADR em `adr/`.
- Atualize o [catálogo de bibliotecas](../05-libraries/library-deep-catalog.md) a cada `flutter pub outdated` relevante.
- Mantenha o [blueprint](corporate-template-blueprint.md) sincronizado com a estrutura real.
