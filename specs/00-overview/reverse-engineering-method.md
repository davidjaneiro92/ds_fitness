# Método de Engenharia Reversa e Estratégia de Agentes

Este documento registra **como** a análise foi conduzida — para que o trabalho seja auditável, reproduzível e retomável.

---

## 1. Prioridade de fontes (do mais autoritativo ao menos)

1. **Documentação existente** → `README.md`, `CONTRIBUTING.md`
2. **Arquivos de arquitetura / ADRs / Wiki** → ❌ **inexistentes** (registrado como lacuna documental)
3. **Configuração** → `pubspec.yaml`, `pubspec.lock`, `analysis_options.yaml`
4. **Código-fonte** → `lib/` (fonte primária da verdade, dada a escassez documental)

> **Lacuna documental registrada:** o projeto não possui ADRs, diagramas de arquitetura nem wiki. O `README.md` está **parcialmente desatualizado** (ex.: cita `shared_preferences`, ausente no `pubspec.yaml`; descreve apenas a árvore legada `lib/src/pages/`). Recomendações de melhoria documental constam em [07-template-blueprint/migration-notes.md](../07-template-blueprint/migration-notes.md).

---

## 2. Estratégia de agentes

A análise foi otimizada para **qualidade, velocidade e economia de contexto**, distribuindo a leitura entre múltiplos agentes especializados em vez de um único agente monolítico.

### Divisão de papéis

| Agente | Modelo | Responsabilidade |
|--------|--------|------------------|
| **Orquestrador / Arquiteto** | **Opus** | Mapa arquitetural (T1), consolidação (T8), blueprint do template (T9), sumário executivo e revisão cruzada (T10). Tarefas de **síntese e julgamento**. |
| **Analistas de domínio técnico** | **Sonnet** (6 subagents paralelos) | Leitura profunda e documentação de fatias independentes da base (T2–T7). Tarefas de **extração e descrição**. |

### Por que múltiplos agentes

- **Economia de contexto:** cada subagent lê dezenas de arquivos e devolve apenas o documento final + classificações, preservando a janela do orquestrador para a síntese.
- **Velocidade:** as 6 análises independentes (Lote A) rodam em paralelo.
- **Qualidade:** o raciocínio arquitetural (onde está o valor do template) fica concentrado no modelo mais capaz (Opus), enquanto a extração mecânica é delegada.

---

## 3. Plano de tarefas (dependências, ordem, complexidade, paralelismo)

| # | Tarefa | Depende de | Complexidade | Paralelo | Agente |
|---|--------|-----------|--------------|----------|--------|
| T0 | Setup `/specs` + método | — | Baixa | — | Opus |
| T1 | Mapa arquitetural profundo | T0 | Alta | — | Opus |
| T2 | Estado + DI + Navegação (GetX) | T1 | Média | Lote A | Sonnet |
| T3 | API (Dio) + Storage (Hive) + Models | T1 | Média | Lote A | Sonnet |
| T4 | Erros + Logs + Observabilidade + Segurança | T1 | Média | Lote A | Sonnet |
| T5 | Design System: tema, widgets, i18n | T1 | Média | Lote A | Sonnet |
| T6 | Testes + convenções + lint | T1 | Baixa | Lote A | Sonnet |
| T7 | Matriz de compatibilidade de libs | T1 | Alta | Lote A | Sonnet (WebSearch) |
| T8 | Classificação técnica consolidada | T2–T7 | Média | — | Opus |
| T9 | Blueprint do template + stack + ADRs | T8 | Alta | — | Opus |
| T10 | Sumário executivo + revisão cruzada | T9 | Baixa | — | Opus |
| T11 | Scaffold mínimo do template (entregável extra) | T9 | Média | — | Opus |

**Ordem:** T0 → T1 → (T2…T7 em paralelo) → T8 → T9 → T10 → T11.

---

## 4. Decisões de escopo (definidas com o solicitante)

- **Idioma da documentação:** Português (PT-BR).
- **Entregável:** Documentação completa em `/specs` **+ scaffold mínimo** do template (fundação técnica sem regra de negócio).
- **Regras de negócio:** explicitamente **fora de escopo** — descartadas.

---

## 5. Controle de contexto

A documentação é escrita de forma **incremental e persistente**: cada tarefa concluída é gravada em disco antes de iniciar a próxima. Em caso de aproximação do limite de contexto, o progresso é salvo e reportado, sem reiniciar análises já concluídas.
