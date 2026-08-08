# Postura da Documentação (LEIA PRIMEIRO)

> Esta nota define a **orientação editorial** de toda a documentação em `/specs`. Substitui qualquer recomendação anterior de modernização como direção principal.

## Princípio central

A finalidade desta documentação é **engenharia reversa fiel e preservação de conhecimento técnico** da fundação que **já existe e funciona em produção** no app legado `controle_separacao_aplicativo`.

> ✅ **A stack atual É a fundação do template.** GetX, Hive, Dio, logger, pluto_grid, barcode_scan2, oktoast, intl etc. são **decisões técnicas a preservar**, não a substituir.

## O que esta documentação É

- Um **catálogo profundo** do que existe: arquitetura, padrões, bibliotecas, serviços, componentes, fluxos, configurações.
- Um guia para **reconstruir um Template Flutter Corporativo** sobre as **mesmas** tecnologias e padrões já dominados pelo time.
- Um registro do **porquê** de cada decisão técnica observada.

## O que esta documentação NÃO é (neste momento)

- ❌ Não é um plano de migração de stack.
- ❌ Não recomenda trocar GetX → Riverpod, Hive → outro, go_router, get_it, etc.
- ❌ Não prioriza modernização tecnológica.

## Como interpretar as classificações

A escala (✅ Reutilizar / 🟢 Reutilizar com melhorias / 🟡 Refatorar / 🟠 Substituir / 🔴 Descartar) é aplicada **dentro da stack atual**:

| Classificação | Sentido nesta documentação |
|---------------|----------------------------|
| ✅ Reutilizar sem alterações | Levar para o template como está |
| 🟢 Reutilizar com melhorias | Levar, com ajustes que **não trocam a biblioteca** (ex.: usar `lazyPut` do próprio GetX) |
| 🟡 Refatorar | Reescrever a implementação, **mantendo a mesma tecnologia** |
| 🟠 Substituir | Reservado a itens **internos** (código duplicado/morto), **não** a bibliotecas em produção |
| 🔴 Descartar | Código morto, duplicado ou acoplado a regra de negócio |

> **Bibliotecas em produção não recebem "Substituir/Descartar" por modernização.** Quando houver risco de manutenção futura (ex.: `hive`), isso é documentado como **"Consideração futura / monitorar"** — informação para decisão posterior do time, **não** ação atual.

## Seção "Considerações futuras"

Onde a análise técnica identificar riscos de longo prazo ou alternativas, o conteúdo fica isolado em blocos rotulados **"Consideração futura (não aplicar agora)"**, para preservar o insight sem contaminar a direção atual.

## Melhorias sem mudar comportamento

Para itens valiosos (ex.: a tela de erro amigável), documentamos **melhorias possíveis que NÃO alteram o comportamento atual** — refinamentos opcionais, compatíveis com o que já funciona.
