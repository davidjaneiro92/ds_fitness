# Engenharia Reversa — Fundação Técnica para Template Flutter Corporativo

> **Objetivo deste repositório de documentação**
> Extrair, documentar e classificar a **fundação técnica** (arquitetura, infraestrutura, padrões, bibliotecas e convenções) do aplicativo legado `controle_separacao_aplicativo`, de modo a permitir a construção de um **Template Flutter Corporativo** reutilizável — **preservando a stack e os padrões que já funcionam em produção** e **sem nenhuma dependência das regras de negócio originais**.

> ⚠️ **LEIA PRIMEIRO:** [documentation-stance.md](documentation-stance.md) — define a postura de **preservação da stack atual** (GetX, Hive, Dio, etc.). Não há plano de migração tecnológica neste momento.

---

## Para quem é esta documentação

| Perfil | O que ler primeiro |
|--------|--------------------|
| **Product Owner / Gestor** | [Sumário Executivo](executive-summary.md) |
| **Arquiteto de Software** | [01-architecture/](../01-architecture/) + [07-template-blueprint/](../07-template-blueprint/) |
| **Tech Lead** | [06-classification/](../06-classification/) + [07-template-blueprint/](../07-template-blueprint/) |
| **Desenvolvedor** | [02-infrastructure/](../02-infrastructure/) + [03-design-system/](../03-design-system/) + [04-quality/conventions-and-lint.md](../04-quality/conventions-and-lint.md) |
| **QA** | [04-quality/testing-strategy.md](../04-quality/testing-strategy.md) |
| **Novo integrante** | Este README → [Sumário Executivo](executive-summary.md) → [Blueprint](../07-template-blueprint/corporate-template-blueprint.md) |

---

## Mapa da documentação

```
specs/
├── 00-overview/              Visão geral, método, sumário executivo
├── 01-architecture/          Arquitetura, pastas, design patterns, ADRs
├── 02-infrastructure/        Estado, DI, navegação, API, storage, erros, logs, segurança
├── 03-design-system/         Tema, widgets compartilhados, i18n
├── 04-quality/               Estratégia de testes, convenções e lint
├── 05-libraries/             Matriz de compatibilidade de bibliotecas
├── 06-classification/        Classificação técnica (Reutilizar/Refatorar/Substituir/Descartar)
└── 07-template-blueprint/    Blueprint do template, stack preservada, ajustes opcionais
```

### Documentos de destaque (aprofundados)

- ⭐ **[Tela de erro amigável](../02-infrastructure/custom-error-screen.md)** — substituição da tela vermelha do Flutter (item de alto valor).
- **[Catálogo profundo de bibliotecas](../05-libraries/library-deep-catalog.md)** — motivo, onde, dependências, versões, impacto de atualização.
- **[Catálogo de serviços](../02-infrastructure/services-catalog.md)** e **[catálogo de componentes (legado)](../03-design-system/components-catalog.md)**.
- **[Catálogo de componentes — estado atual](../03-design-system/components-catalog-direction-app1.md)** — inventário vivo de `lib/src/components/` no `direction_app1` (categorizado por pasta, componentes novos).
- **[Autenticação e interceptors](../02-infrastructure/authentication-and-interceptors.md)** — fluxo de login, token, refresh, signOut.
- **[Configurações e ambiente](../02-infrastructure/configuration.md)** — bootstrap + `baseUrl` editável em runtime via Hive.
- **[Referência de engenharia consolidada](engineering-reference.md)** — visão única de toda a fundação.

---

## Sistema de classificação técnica

Todo item analisado recebe uma das classificações abaixo (detalhe em [06-classification/](../06-classification/technical-classification.md)):

| Classificação | Significado |
|---------------|-------------|
| ✅ **Reutilizar sem alterações** | Sólido e moderno; copiar para o template como está. |
| 🟢 **Reutilizar com melhorias** | Conceito bom; ajustes pontuais antes de reutilizar. |
| 🟡 **Refatorar** | Ideia válida, implementação a reescrever. |
| 🟠 **Substituir** | Trocar por biblioteca/abordagem moderna equivalente. |
| 🔴 **Descartar** | Não levar para o template (acoplado a regra de negócio, morto ou inseguro). |

---

## Identificação do projeto-fonte

| Item | Valor |
|------|-------|
| Nome | `controle_separacao_aplicativo` |
| Domínio (descartável) | Controle de separação de materiais (WMS/logística) |
| Flutter alvo (legado) | 3.24.4 (stable) · Dart 3.5.4 · SDK `^3.5.3` |
| Tamanho | 189 arquivos Dart · ~18.7k LOC |
| Plataformas | Android, iOS, Windows, macOS, Linux, Web |
| Data da análise | 2026-06-24 |

> **Nota:** este documento descreve a **fundação técnica**. O domínio de negócio (NFs, pedidos, lotes, estoque) é explicitamente **descartado** e serve apenas como contexto de exemplo.
