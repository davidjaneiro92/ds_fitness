# Sumário Executivo

> Para Product Owners, Tech Leads e gestores. Visão de alto nível do que a engenharia reversa encontrou e o que recomendamos para o Template Flutter Corporativo.

## O que foi feito

Realizamos engenharia reversa **da fundação técnica** do app legado `controle_separacao_aplicativo` (189 arquivos, ~18.7k linhas, Flutter 3.24/Dart 3.5) — **ignorando deliberadamente as regras de negócio** — para produzir a base de um **template corporativo reutilizável**. A análise foi distribuída entre um agente arquiteto (Opus) e seis analistas paralelos (Sonnet), gerando a documentação em `/specs`.

## Veredito em uma frase

> A fundação do legado tem **bons conceitos de arquitetura** (feature-first, interfaces, Command, Repository) com algumas **dívidas internas** (migração inacabada, acoplamento infra↔UI, achados de segurança, zero testes). O template deve **preservar a stack e os padrões que funcionam** e apenas **limpar e refinar a execução, sem trocar bibliotecas**.

## Principais achados

### 🟢 Pontos fortes (preservar)
- Arquitetura **feature-first** com camadas claras.
- **Programação por interface** em quase tudo — base ideal para testes.
- Padrões **Command** e **Repository** bem aplicados.
- Wrapper de HTTP, overlay de loading global, refresh token, Material 3 corporativo.

### 🔴 Riscos críticos (corrigir antes de qualquer reuso)
| Risco | Severidade | Impacto |
|-------|-----------|---------|
| SSL desabilitado (`badCertificateCallback => true`) | **Crítico** | Vulnerável a interceptação (MITM) |
| Token JWT em armazenamento não criptografado | **Crítico** | Roubo de sessão em dispositivos comprometidos |
| Tráfego em claro + segredos hardcoded | **Crítico** | Exposição de dados e infraestrutura |
| **Cobertura de testes = 0%** | Alto | Sem rede de proteção para evoluir |
| Sem crash reporting/observabilidade | Alto | Falhas em produção invisíveis |

### 🟡 Dívidas internas (refinar dentro da stack)
- **Migração inacabada:** duas árvores coexistindo + código morto + duplicações → remover.
- **Acoplamento:** camada de rede chama diálogos e navega → desacoplar (mesma stack).
- **i18n** inexistente; **lint** permissivo; **serialização manual** → refinar mantendo libs.
- *Considerações futuras (sem prioridade):* manutenção de `hive`; debate sobre GetX.

## Recomendação estratégica

> **Postura atual (ver [documentation-stance.md](documentation-stance.md)):** preservar a stack e os padrões que já funcionam em produção. **Sem migração tecnológica** neste momento.

1. **Construir o template sobre a stack atual** — GetX + Hive + Dio + logger + pluto_grid + oktoast + intl. Blueprint em [07-template-blueprint](../07-template-blueprint/corporate-template-blueprint.md).
2. **Reaproveitar os ativos prontos:** tela de erro amigável, overlay de loading global, lista configurável, `HttpManager` com refresh token, serviços compartilhados, enum de rotas, tema Material 3.
3. **Higiene interna** (sem trocar libs): remover código morto/duplicado, corrigir typos, eliminar `print()`.
4. **Melhorias opcionais retrocompatíveis** (mesma stack): `lazyPut`/`Bindings`, `Get.find()` consistente, SSL só em debug, retry de refresh limitado — ver [migration-notes](../07-template-blueprint/migration-notes.md).
5. **Testabilidade já vem de graça** com as interfaces — investir na suíte de testes.
6. **Considerações futuras** (Riverpod, troca de Hive etc.) ficam registradas, **sem prioridade**.

## Esforço e risco

| Dimensão | Avaliação |
|----------|-----------|
| Qualidade conceitual do legado | Média-Alta (boa arquitetura) |
| Qualidade de execução | Baixa-Média (dívidas e riscos) |
| Reaproveitamento de **conceitos** | Alto |
| Reaproveitamento de **código** | Médio-Alto (após remover duplicação/código morto) |
| Prontidão para template corporativo | Alta — preservar a stack e limpar a base (este `/specs` é o guia) |

## Próximos passos sugeridos

1. Confirmar a postura de preservação da stack (ADR-0001/0002 já refletem isso).
2. Montar o template sobre a **estrutura ativa limpa** ([blueprint](../07-template-blueprint/corporate-template-blueprint.md)), removendo as árvores duplicadas/mortas.
3. Definir gates de qualidade (lint, testes) desde o dia 1, mantendo as libs atuais.
