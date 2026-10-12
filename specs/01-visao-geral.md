# Visão Geral

## Objetivo do aplicativo

O **DS Fitness** é um aplicativo Flutter para **montar treinos de musculação**, executá-los série a série (com cronômetro de descanso e o GIF do movimento) e acompanhar a evolução (histórico, cargas, estatísticas). Na tela de login o lema é *"Disciplina hoje. Resultados sempre."*. O pacote se chama `ds_fitness` (versão `1.0.0+1`) e o tema é único: escuro, com acento verde. Todos os textos são pt-BR.

O app é um **cliente fino**: não tem regra de negócio própria sobre os dados. Os treinos, o catálogo de exercícios, as sessões e as estatísticas moram na API `ds_fitnes_back`, que é dona do banco e das contas. Localmente o app guarda só a sessão de login, uma marca da execução em andamento e a fila de erros ainda não enviados ao log da API.

## Problema que resolve

Troca a planilha e o caderno de treino por um fluxo curto: o usuário monta o treino em poucos toques (dia da semana, grupos musculares, exercício com GIF, séries, repetições e descanso), executa com cronômetro e o app guarda cargas, sessões e recordes. As contas — volume, calorias, recordes e estatísticas — são feitas pelo servidor, não pelo aparelho.

## Público-alvo

Praticantes de musculação (pessoa física) que treinam com ficha própria. Sem recursos de treinador/aluno, redes sociais, nutrição ou integração com dispositivos vestíveis.

## O fluxo central

O app gira em torno de sete telas, na ordem em que o usuário as percorre pela primeira vez. O detalhe de cada uma está em [05-regras-de-negocio.md](05-regras-de-negocio.md) e os diagramas em [06-fluxos.md](06-fluxos.md).

| # | Tela | Rota | O que faz |
|---|---|---|---|
| 1 | Login | `/login` | E-mail e senha, *Entrar*, *Esqueceu sua senha?*, entrar com Google/Apple/Facebook (botões presentes, ainda sem função) e *Cadastre-se* |
| 2 | Início | `/home` | *"Olá, {nome}! O que você quer fazer?"* com dois cartões: **Montar meu treino** e **Treinar** |
| 3 | Novo treino | `/treinos/novo` | Dia da semana (Seg–Dom), nome, objetivo e descrição (0/200); *Continuar* |
| 4 | Grupos musculares | `/grupos` | Grade de imagens dos músculos, seleção múltipla com visto; *Próximo* |
| 5 | Selecionar exercício | `/exercicios` | Busca e lista com miniatura; um exercício marcado; *Configurar exercício* |
| 6 | Configurar exercício | `/exercicios/configurar` | GIF do movimento e três campos — Séries (4), Repetições (12), Descanso (90 s); *Adicionar ao treino* |
| 7 | Revisar e salvar | `/treinos/revisar` | *"Treino A • Segunda"*, os exercícios com menu ⋮, *Adicionar exercício* tracejado; *Salvar treino* |

A barra inferior tem quatro abas — **Início · Treinos · Evolução · Perfil** — e as telas de formulário e execução não a mostram.

## Funcionalidades

### Implementadas

| Funcionalidade | Status | Descrição |
|---|---|---|
| Acesso | ✅ Completo | Criar conta (nome, e-mail, senha de 8+ caracteres, nascimento e sexo), entrar e sair. A sessão se renova sozinha (token de acesso + *refresh token*); se o servidor recusa a renovação, o app volta ao login. |
| Início | ✅ Completo (redesenhado em 2026-10-12) | Saudação pelo primeiro nome e dois cartões: *Montar meu treino* abre o fluxo de criação, *Treinar* abre a lista de treinos. Não consulta a API: o nome vem do usuário já logado. |
| Montar treino | ✅ Completo (redesenhado em 2026-10-12) | Os cinco passos (dados → grupos → exercício → configurar → revisar), com um único rascunho que sobrevive à navegação entre eles. O dia da semana define qual é o *treino do dia*. Detalhes em [06-fluxos.md](06-fluxos.md#montar-um-treino). |
| Meus treinos | ✅ Completo | Lista com o treino do dia destacado. Tocar abre a revisão (editar e iniciar); pressão longa oferece *Duplicar* e *Excluir*. |
| Exercícios | ✅ Completo | Biblioteca (aberta pelo **Perfil**) com busca, filtros *Todos/Favoritos/Recentes* e por grupo muscular; detalhe com GIF, passo a passo, músculos e evolução de carga; criar, editar e excluir exercício próprio. |
| Imagens dos exercícios | ✅ Completo (2026-10-12) | GIF e miniatura **dentro do app** (`assets/`), escolhidos pela chave `imagem` que a API devolve em cada exercício; imagens dos grupos musculares como ícone. Hoje estão empacotados os 55 exercícios do catálogo ([07-engenharia.md](07-engenharia.md#imagens-dos-exercícios)). |
| Execução do treino | ✅ Completo | Série a série, com descanso cronometrado, troca de carga (começa na última usada), observações, retomada de onde parou e resumo ao concluir, com os recordes batidos. |
| Evolução e histórico | ✅ Completo | A aba *Evolução* mostra números, gráfico de volume e distribuição por grupo, por período; o ícone de relógio abre o histórico de sessões (paginado, com detalhe) e o resumo por exercício. |
| Perfil | ✅ Completo | Dados e medidas (somente leitura), troca de objetivo, atalhos para a biblioteca e a evolução, sair. |
| Log de erros do app | ✅ Completo | Erros que o app não tratou e requisições que falharam vão para a API (`POST /log/erros`), com fila local quando não há rede. Ver [02-arquitetura.md](02-arquitetura.md#erros-e-observabilidade). |

### Reservado na interface (ainda sem função)

O toque mostra um aviso *"Em breve"* (ou equivalente): entrar com **Google, Apple e Facebook** (a decisão de produto é fazer essa parte mais adiante, mantendo os botões), **Esqueceu sua senha?**, **Fotos de progresso** e a câmera do avatar, e **Compartilhar** o treino concluído. A lista, com o motivo de cada item, está em [08-auditoria.md](08-auditoria.md#pendências-conhecidas).

### Fora do escopo

- Regra de negócio sobre treinos e estatísticas — é da API.
- Acesso offline completo: abrir e finalizar um treino exigem rede (as imagens são do pacote do app).
- Mais de um idioma ou mais de um tema.

## Roadmap resumido

1. **Fundação** (2026-08-08) — repositório criado a partir do template corporativo `direction_app1` (GetX, Dio, Hive, padrão interface → controller → repository → view), com o domínio do template removido.
2. **Integração com a API** (2026-10-10) — as telas do planejamento ligadas ao `ds_fitnes_back`: acesso, treinos, exercícios, execução, histórico, estatísticas e perfil.
3. **Imagens pelo Google Drive** (2026-10-10, branch `feat/gifs-dos-exercicios`) — a API informava o link do GIF no Drive. Abandonado: a cota por arquivo do Drive derrubava as imagens.
4. **Log de erros do aplicativo** (2026-10-10/11) — `ErrorReporter` no app e módulo Log na API; fila local, sem laço de erro.
5. **Redesenho do fluxo e imagens locais** (2026-10-12) — as sete telas de referência viram o fluxo do app; GIFs, miniaturas e imagens dos músculos passam a ser assets; a API troca `gifUrl`/`miniaturaUrl` pela chave `imagem`. Ver [CHANGELOG.md](CHANGELOG.md).
6. **Futuro** — login social, recuperar senha, fotos de progresso, compartilhar treino, empacotar mais exercícios do catálogo, cifrar o armazenamento local e testar os demais controllers. A lista viva está em [08-auditoria.md](08-auditoria.md#pendências-conhecidas) e em [07-engenharia.md](07-engenharia.md#débito-técnico-conhecido).
