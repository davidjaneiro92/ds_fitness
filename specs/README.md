# SDD — DS Fitness (aplicativo)

**SDD** (*Software Design Document*) do aplicativo Flutter **DS Fitness**: como o app é construído, quais regras valem para qualquer código novo e por que cada decisão foi tomada.

Este documento é **normativo**. Qualquer implementação futura — feita por uma pessoa ou por uma IA — segue o que está escrito aqui. Quando uma regra daqui conflitar com um hábito pessoal ou com um exemplo de outro projeto, vale o que está aqui. Mudou camada, rota, endpoint, regra de negócio, dependência ou pendência: o documento correspondente muda **na mesma entrega** (R15 em [07-engenharia.md](07-engenharia.md)).

O [README.md](../README.md) da raiz é o guia operacional (como rodar, testar e gerar builds). O SDD é o guia de **projeto**: arquitetura, estrutura, regras de negócio e contrato com a API.

O servidor tem o SDD próprio, no repositório `ds_fitnes_back` (`docs/SDD`). O contrato entre os dois é descrito dos dois lados: aqui em [05-regras-de-negocio.md](05-regras-de-negocio.md#contrato-com-a-api), lá no documento 13 (*Módulos de negócio*). Se os dois divergirem, o **código da API** decide, e o documento errado deve ser corrigido.

## Índice

| # | Documento | Conteúdo |
|---|---|---|
| 01 | [Visão geral](01-visao-geral.md) | O que o app é, o fluxo central, funcionalidades e roadmap |
| 02 | [Arquitetura](02-arquitetura.md) | Camadas, GetX (estado, injeção, navegação), sessão, erros, imagens, decisões |
| 03 | [Estrutura de pastas](03-estrutura-pastas.md) | Árvore do projeto, feature por feature, convenções de nome |
| 04 | [Componentes, temas e estilos](04-componentes.md) | Tokens, tema, componentes e a ilustração dos exercícios |
| 05 | [Regras de negócio](05-regras-de-negocio.md) | Regras de cada feature e o contrato com a API |
| 06 | [Fluxos](06-fluxos.md) | Mapa de rotas e os fluxos em diagramas (Mermaid) |
| 07 | [Engenharia](07-engenharia.md) | Regras de desenvolvimento (R1–R16), como criar uma feature, dependências, testes, observabilidade, débito técnico |
| 08 | [Auditoria](08-auditoria.md) | O que foi encontrado e feito, planejamento × implementado, pendências |
| — | [CHANGELOG](CHANGELOG.md) | Registro datado das alterações |

## O que **não** faz parte do SDD

- [`planejamento-ds-fitness.md`](../planejamento-ds-fitness.md) — o planejamento de telas que originou o app (julho/2026). O que ficou diferente dele está em [08-auditoria.md](08-auditoria.md#planejamento--implementado). O fluxo de montar o treino foi **redesenhado** a partir das telas de referência enviadas em 2026-10-12 e hoje segue o descrito em [06-fluxos.md](06-fluxos.md).
- As pastas `00-overview/` a `08-audit/` desta mesma pasta (`specs/`) — engenharia reversa do template corporativo de onde o projeto partiu (`direction_app1`, derivado de um app de logística). Descrevem **outro produto** e ficam só como referência histórica da fundação técnica (GetX, Dio, Hive e o padrão de feature). Em caso de conflito, o SDD acima vence.

## As cinco regras que não se negociam

1. **Dependência em um sentido só.** `View → Controller → Repository → HttpManager`, sempre por interface. A tela não conhece o repository; o controller não conhece o `Dio`; só o repository monta uma chamada de rede ([02-arquitetura.md](02-arquitetura.md), R1–R4).
2. **A rede termina no `HttpManager`.** Toda falha vira `ApiException`; a UI mostra `ErrorMessages.de(erro)`. A camada HTTP nunca navega e nunca abre diálogo.
3. **O servidor é a fonte da verdade.** O app informa o que aconteceu (séries feitas, tempos); volume, calorias, recordes e estatísticas voltam calculados.
4. **Nenhum literal solto.** Rota, endereço da API, caminho de imagem, cor, espaçamento e argumento de rota saem de `PagesRoutes`, `Endpoints`, `AppAssets`, dos tokens e de `route_args.dart`.
5. **O SDD acompanha o código.** E o que o código não consegue provar — a tela funcionando — se confere rodando o app contra a API ([07-engenharia.md](07-engenharia.md#testes-e-verificação)).
