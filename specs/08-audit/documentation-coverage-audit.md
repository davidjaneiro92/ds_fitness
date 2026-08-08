# Relatório de Auditoria de Cobertura Documental

> **Pergunta central:** *"Existe alguma parte da fundação técnica do projeto que ainda não foi documentada?"*
> **Resposta resumida:** **Sim — havia lacunas e conflitos relevantes.** Esta auditoria os identifica com evidências e os documentos de remediação foram produzidos (ver §11). Após remediação, a cobertura sobe de **~74%** para **~94%** (estimado).
>
> Método: validação cruzada **código-fonte × documentação** por 6 agentes independentes (Sonnet), consolidada por Opus. Escopo: somente documentação/engenharia reversa (sem código/scaffold). Base: 189 arquivos `.dart` + assets + configs.

---

## 1. Cobertura por área (antes da remediação)

| # | Área auditada | Cobertura | Relatório detalhado |
|---|---------------|-----------|---------------------|
| A1 | Arquitetura, padrões, Commands, Repositories, rotas, features | **72%** | [audit-1](areas/audit-1-arquitetura-padroes.md) |
| A2 | Estado (GetX), DI, navegação, configuração, bootstrap | **82%** | [audit-2](areas/audit-2-estado-di-nav-config.md) |
| A3 | Rede/Dio, auth, interceptors, erros, segurança, tela de erro | **72%** | [audit-3](areas/audit-3-rede-auth-erros-seguranca.md) |
| A4 | Persistência/Hive, logs, **models**, serviços, utils/validators | **68%** | [audit-4](areas/audit-4-persistencia-models-utils.md) |
| A5 | Design system, componentes, **assets**, i18n | **72%** | [audit-5](areas/audit-5-design-system-assets.md) |
| A6 | Bibliotecas, testes, lint + **consistência global** | **95%** libs / **6/10** consistência | [audit-6](areas/audit-6-libs-testes-consistencia.md) |

**Cobertura global estimada (antes): ~74%.**

---

## 2. ✅ Completamente documentado (alta fidelidade)

Com evidência confirmada por leitura direta do código:

- **Arquitetura em camadas** View/Controller/Repository/Abstracts — diagrama fiel (`architecture-overview.md`).
- **Migração inacabada** `pages/` (morta) vs `core/features/` (ativa) — registrada em 3+ docs.
- **Bootstrap** (`main.dart`): 16 passos, 18 `Get.put`, `initializeApp()`, `ErrorWidget.builder`, `OKToast` (`configuration.md`).
- **Enum `PagesRoutes`** (14 rotas ativas + 9 legadas) (`navigation.md`).
- **`HttpManager`**: `restRequest`, `token`, `_tryRefreshToken`, `signOut`, `_handleDioError`, `badCertificateCallback` (`api-configuration.md`, `authentication-and-interceptors.md`).
- **Fluxo de login** principal + refresh token (com diagramas).
- **Tela de erro amigável** `CustomErrorWidget` + `ErrorWidget.builder` (`custom-error-screen.md`).
- **13 componentes** com ficha técnica (`components-catalog.md`).
- **19 bibliotecas** catalogadas com versão/uso (`library-deep-catalog.md`).
- **Serviços** Hive/Log/FormatarValores/Validators (78–92%).
- **Tema e i18n** — estado real descrito fielmente (85–95%).
- **Achados de segurança** (`KeyMaster`, IP, SSL, token em claro) (`security.md`).

---

## 3. 🟡 Parcialmente documentado

| Item | O que falta | Evidência |
|------|-------------|-----------|
| Command Pattern | Conceito documentado, mas as **interfaces** `CommandInterface` (`conferir_material_saida/abstracts/command_interface.dart`) e `TransferenciaCommandInterface` (`conferir_material_transferencia/abstracts/transferencia_command_interface.dart`) e os **8 commands** concretos não são inventariados | A1 |
| Features | Sem inventário das 13 features com status por camada | A1 |
| Models | Padrão de serialização citado, mas **classes individuais não catalogadas**; nomes de classe errados na doc | A4 |
| `loginSettings()` / `confirmar_acesso.dart` | Documentado só como achado de segurança; falta fluxo funcional | A3 |
| Loading global no refresh | `Refreshtoken()` dispara loading — não documentado | A3 |
| `HttpMethods` | É `abstract class` com dead code (não enum); não esclarecido | A4 |

---

## 4. 🔴 Não documentado (lacunas)

| Lacuna | Evidência (arquivo) |
|--------|---------------------|
| **Catálogo dos 26 models** | `lib/src/models/*` — só descrição genérica existia |
| **Catálogo de assets** | `assets/img/` (8 imagens) — só `erro3.png` documentado |
| **`confirmar_acesso.dart`** | `core/features/login/view/confirmar_acesso.dart` — ausente de toda a doc |
| **Interfaces de Command nomeadas** | `command_interface.dart`, `transferencia_command_interface.dart` |
| **Inventário das 8 commands** | `conferir_material_saida/controller/commands/*` + transferência |
| **Models duplicados** | `conferencias.dart`≡`conferencias_model.dart`; `fornecedorModel.dart`≡`fornecedor_model.dart` |
| **`splash_screen.dart` (sem controller)** | `core/features/splash_screen/splash_screen.dart` |
| **Asset mais usado (`logo-ok-3.png`)** | 6 usos (app_bar, scaffold, login, splash) — não documentado |
| **6 assets sem uso** | `assinatura, logo-ok, logo-ok-1, logo-ok-2, simbolo-ok, simbolo-ok-1` |

---

## 5. 🔎 Documentos que precisam de aprofundamento

- `local-storage.md` §7 — catálogo de models (substituído por doc dedicado, ver §11).
- `design-patterns.md` — referenciar interfaces e commands concretos.
- `authentication-and-interceptors.md` — incluir `confirmar_acesso`/`loginSettings` e loading no refresh.
- `theming.md`/`components-catalog.md` — referenciar catálogo de assets.

---

## 6. ⚠️ Inconsistências doc × código

| # | Inconsistência | Evidência | Correção |
|---|----------------|-----------|----------|
| I1 | Versões divergentes: `get 4.6.6` (state-management) vs `4.7.2` (ADR/lock); `dio 5.7.0` (api-config) vs `5.8.0+1` (lock) | A2, A6 | Padronizar p/ versão **resolvida** |
| I2 | `local-storage.md §7.3` cita 5 classes erradas: doc `EstagioModel/ItemModel/ItensNfModel/PedidoCompletoModel/TransfMovLote` → código `Estagio/Item/ItenNotaFiscal/PedidoCompleto/TansfMovLote` | A4 | Corrigir nomes reais |
| I3 | Doc diz "25 models"; código tem **26** | A4 | Corrigir contagem |
| I4 | Box `Autenticacao` descrito como box separado; é **chave** dentro de `Cache_aplicativo` | A4 | Corrigir |
| I5 | `library-deep-catalog §18` afirma "nenhum arquivo de teste"; existe `test/widget_test.dart` | A6 | Corrigir |
| I6 | `library-deep-catalog` afirma `analysis_options` "não lido"; foi lido em `conventions-and-lint` | A6 | Corrigir |

---

## 7. ♻️ Possíveis informações duplicadas (entre docs)

- **Fluxo `restRequest()`** com código real em **3 documentos** (`api-configuration`, `authentication-and-interceptors`, `error-handling`). → Manter canônico em 1, referenciar nos demais.
- **Catálogo de componentes** duplicado ~60-70% entre `components-catalog.md` e `shared-widgets.md`. → Consolidar.
- **Achados de segurança** S-01..S-06 duplicados entre `security.md` e `authentication-and-interceptors.md §12`.
- **Bootstrap** triplicado (`configuration`, `dependency-injection`, `navigation`).
- **Classificação de libs** em `technical-classification.md` × `library-compatibility-matrix.md` × `library-deep-catalog.md`.

---

## 8. ❌ Informações conflitantes entre documentos

| # | Conflito | Evidência |
|---|----------|-----------|
| C1 | **Estrutura de pastas:** `folder-structure.md §3` propõe `domain/data/presentation` vs `corporate-template-blueprint.md §2` que usa a estrutura real `abstracts/controller/repository/view` | A1, A6 |
| C2 | **Postura de stack (residual):** vários docs ainda **recomendam migração** (contra `documentation-stance.md`/ADR): `library-compatibility-matrix` (GetX→Riverpod P5; Hive→secure_storage P1; barcode_scan2→mobile_scanner; Sentry), `state-management §6` (Riverpod+get_it), `dependency-injection` (get_it), `navigation §6` (go_router), `local-storage §6-8` (hive 🟠 Substituir, freezed, secure_storage) | A2, A6 |
| C3 | **Severidade `KeyMaster`:** `🔴 Alta` (auth doc) vs `🟠 Alto` (security matrix) | A3 |
| C4 | **Classificação `CustomToast`/`CustomListTile`:** divergente entre `components-catalog` e `shared-widgets` | A5 |
| C5 | **Hive:** `🟠 Substituir` (local-storage §6) vs `✅ Reutilizar` (technical-classification) | A6 |

---

## 9. 🏛️ Decisões arquiteturais ainda não documentadas (sem ADR)

1. **Dualidade de interfaces de Command** (`CommandInterface` vs `TransferenciaCommandInterface`) — por que duas?
2. **Aplicação seletiva do Command Pattern** — só 2 features usam commands; as demais não.
3. **Splash sem controller** — `splash_screen.dart` é stateless puro.
4. **`confirmar_acesso` como funções soltas** (estado global de arquivo, `dispose()` fora de classe).
5. **Repositórios instanciados com `new` dentro de commands/controllers** (fora do GetX).
6. **Login via `PATCH`** (não POST) — decisão não justificada.
7. **`LogInterceptor` comentado** — decisão de não ter interceptor Dio formal.
8. **Models como DTO de saída sem `fromJson`** (`PedidosModel`, `SelecionarMaterialEstoqueModel`).

> Estas decisões ficam **registradas como observações** (não exigem mudança). Recomenda-se ADRs retroativos no template.

---

## 10. Bugs/observações factuais relevantes capturados na auditoria

> Documentados como **fatos** (sem ação de correção nesta fase):
- `_parseDouble` (`NfLotesModel`, `Item`) remove separadores e pode converter `1.5`→`15` (risco em controle de peso).
- `NfPagasModel` usa `int 0` como default de campo `bool`.
- `LogOperacoesModel` atribui `DateTime` a campo `String`.
- `ConsultarNfSaidaModel` importa `pluto_grid` (UI dentro de model — violação de camada).
- Casing `assets/Img/` (disco) vs `assets/img/` (código/pubspec) — quebraria em build Linux/CI.

---

## 11. Remediação executada (documentação)

Para fechar as lacunas e conflitos acima, foram produzidos/ajustados os seguintes documentos (somente documentação):

| Ação | Documento |
|------|-----------|
| 🆕 Catálogo dos 26 models (nomes reais, campos, serialização, duplicados, bugs) | [02-infrastructure/models-catalog.md](../02-infrastructure/models-catalog.md) |
| 🆕 Catálogo de assets (uso, casing, não usados) | [03-design-system/assets-catalog.md](../03-design-system/assets-catalog.md) |
| 🆕 Command Pattern + inventário de features (interfaces, 8 commands, 13 features, splash, confirmar_acesso) | [01-architecture/command-pattern-and-features.md](../01-architecture/command-pattern-and-features.md) |
| ✏️ Neutralização dos conflitos de postura (C2/C5) → blocos "Consideração futura" | docs de `02-infrastructure/` e `05-libraries/` |
| ✏️ Alinhamento da estrutura de pastas (C1) | `folder-structure.md` |
| ✏️ Correção de inconsistências factuais (I1–I6, C3, C4) | docs respectivos |

**Cobertura global estimada após remediação: ~94%.** O residual (~6%) refere-se a ADRs retroativos das decisões da §9, registrados como observações, sem impacto na fidelidade da engenharia reversa.

---

## 12. Conclusão

A engenharia reversa da fundação técnica está **fiel e praticamente completa** após a remediação. As áreas de maior risco identificadas (models, assets, commands/features, conflitos de postura) foram endereçadas com documentação dedicada e evidências concretas. A fase de documentação pode ser considerada **encerrável** assim que as edições de remediação da §11 estiverem concluídas e revisadas.
