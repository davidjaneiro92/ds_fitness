# DS Fitness — Planejamento de Telas

**Stack:** Flutter + GetX
**Tema:** Dark (#0D0D0D) com acento verde (#4CE660)
**Slogan:** "Sua jornada, seus resultados!"

---

## 1. Design Tokens

### Cores
| Token | Hex | Uso |
|---|---|---|
| `bgPrimary` | `#0D0D0D` | Fundo da tela |
| `bgSurface` | `#1A1A1A` | Cards, containers |
| `bgSurfaceAlt` | `#242424` | Inputs, chips inativos |
| `accent` | `#4CE660` | Botões primários, destaques, progresso |
| `accentDark` | `#2FA843` | Estado pressed do acento |
| `textPrimary` | `#FFFFFF` | Títulos, valores |
| `textSecondary` | `#9A9A9A` | Labels, subtítulos |
| `danger` | `#E64C4C` | Excluir, alertas |
| `warning` | `#E6B24C` | Estrelas, avisos |
| `divider` | `#2E2E2E` | Bordas, separadores |

### Tipografia
| Papel | Tamanho | Peso |
|---|---|---|
| Display (números grandes) | 42–48 | 800 |
| Título de tela | 20 | 700 |
| Título de card | 16 | 700 |
| Corpo | 14 | 400/600 |
| Label / caption | 11–12 | 600 |

### Espaçamento e forma
- Grid base: **8px**
- Padding lateral padrão: **16px**
- Raio de card: **16px**
- Raio de botão: **12px**
- Raio de chip / pill: **20px**
- Elevação: sem sombra — separação por contraste de superfície

### Componentes reutilizáveis
| Widget | Descrição |
|---|---|
| `AppScaffold` | Fundo dark + safe area + navbar opcional |
| `AppNavbar` | Topo com back, título centralizado e ação à direita |
| `AppBottomNav` | 4 abas: Home, Treinos, Exercícios, Perfil |
| `AppTextField` | Input sem borda em todos os estados, label acima |
| `AppButton` | Variantes: `primary` (verde), `outline`, `ghost`, `danger` |
| `ExerciseCard` | Thumb + nome + grupos + trailing (chevron / toggle / +) |
| `StatBox` | Valor grande + label pequeno, usado em resumos |
| `MuscleChips` | Bonecos anatômicos com músculo destacado |
| `SerieStepper` | Indicador de séries (1 2 3 4) com estados |
| `CircularTimer` | Anel de progresso + contador central |
| `AppModalSheet` | Bottom sheet padrão com handle e header |

---

## 2. Mapa de Rotas

```
/splash
/login
/cadastro
/home
├── /treinos                     (Meus Treinos)
│   ├── /treinos/novo            (Criar Treino)
│   │   ├── /grupos              (Grupos Musculares)
│   │   └── /exercicios/:grupo   (Lista de Exercícios)
│   │       └── [sheet] Adicionar Exercício
│   ├── /treinos/:id/editar      (Meu Treino - Edição)
│   └── /execucao/:treinoId
│       ├── [state] exercicio
│       ├── [state] descanso
│       ├── [state] serieConcluida
│       └── /execucao/concluido
├── /historico
├── /estatisticas
├── /biblioteca                  (Biblioteca de Exercícios)
└── /perfil
```

**Modais globais:** Evolução de Carga, Alterar Carga, Observações.

---

## 3. Especificação por Tela

---

### 1. Splash
**Rota:** `/splash` · **Controller:** `SplashController`

- Logo DS Fitness centralizado
- Slogan: "Sua jornada, seus resultados!"
- Loader circular verde

**Lógica:** verifica token salvo → `/home` se válido, `/login` se não. Timeout mínimo de 1,5s para não piscar.

---

### 2. Login
**Rota:** `/login` · **Controller:** `AuthController`

**Campos:** E-mail, Senha (com toggle de visibilidade)
**Ações:** Entrar · Esqueci minha senha · Entrar com Google · Criar conta

**Validação:** e-mail com formato válido, senha mínimo 6 caracteres. Botão desabilitado enquanto inválido.
**Estados:** idle, loading (spinner no botão), erro (mensagem abaixo do campo).

---

### 3. Cadastro
**Rota:** `/cadastro` · **Controller:** `AuthController`

**Campos:** Nome completo, E-mail, Senha, Data de nascimento (date picker), Sexo (chips Masculino/Feminino)
**Ação:** Criar conta

**Validação:** todos obrigatórios; idade mínima 16 anos; senha com regra visível.
**Pós-cadastro:** login automático → `/home`.

---

### 4. Home
**Rota:** `/home` · **Controller:** `HomeController`

**Blocos:**
1. Saudação "Olá, David! 👋" + avatar (abre `/perfil`)
2. Card destaque **Treino de hoje** — nome, contagem de exercícios, boneco muscular, botão `Iniciar treino`
3. **Progresso semanal** — "4 de 6 treinos" + barra verde, chevron para `/estatisticas`
4. **Grid de atalhos 3×2:** Meus Treinos · Histórico · Exercícios · Estatísticas · Peso · Calendário

**Bottom nav:** Home ativo.

---

### 5. Meus Treinos
**Rota:** `/treinos` · **Controller:** `TreinosController`

Lista de cards de treino: nome, grupos musculares, contagem de exercícios, chevron.
Card do treino do dia com borda verde.

**Ações:** tap no card → `/treinos/:id/editar` · botão `+ Novo treino` → `/treinos/novo`
**Swipe/long press:** Duplicar, Excluir (confirmação).
**Empty state:** ilustração + "Você ainda não criou nenhum treino" + CTA.

---

### 6. Criar Treino
**Rota:** `/treinos/novo` · **Controller:** `TreinoFormController`

**Campos:**
- Nome do treino (obrigatório)
- Objetivo (dropdown: Hipertrofia, Emagrecimento, Força, Resistência, Condicionamento)
- Descrição (opcional, multiline)
- Seção **Exercícios** com contador ("0 exercícios adicionados")

**Ações:** `+ Adicionar exercício` → `/grupos` · `Salvar treino` (habilitado só com nome + ≥1 exercício)

---

### 7. Grupos Musculares
**Rota:** `/grupos` · **Controller:** `GruposController`

Grid 3 colunas com 12 grupos: Peito, Costas, Ombro, Bíceps, Tríceps, Pernas, Abdômen, Glúteos, Panturrilha, Cardio, Antebraço, Todos.
Cada card: ícone anatômico + nome.

**Ação:** tap → `/exercicios/:grupo`

---

### 8. Lista de Exercícios
**Rota:** `/exercicios/:grupo` · **Controller:** `ExerciciosController`

- Busca no topo (filtro local por nome)
- Lista: thumb do GIF, nome, grupos secundários, botão `+` verde

**Ação:** tap no `+` → abre bottom sheet (tela 9)
**Estado:** exercício já adicionado mostra check em vez de `+`.

---

### 9. Adicionar Exercício (Bottom Sheet)
**Componente:** `AddExercicioSheet` · **Controller:** `TreinoFormController`

**Conteúdo:**
- Header: nome do exercício + botão fechar
- GIF ilustrativo
- Chips de músculos trabalhados (bonecos anatômicos)
- **Séries** — stepper `− 4 +`
- **Repetições** — stepper `− 12 +`
- **Carga inicial (kg)** — stepper `− 30 +`
- **Descanso** — dropdown (30s, 45s, 60s, 90s, 120s, 180s)
- **Observação** (opcional) — "Ex.: Execução controlada..."
- Botão `Adicionar ao treino`

**Comportamento:** ao confirmar, fecha o sheet e volta para a lista mantendo o grupo selecionado.

---

### 10. Meu Treino (Edição)
**Rota:** `/treinos/:id/editar` · **Controller:** `TreinoFormController`

- Header: nome do treino + ícone de editar + contagem de exercícios
- Lista ordenável (drag handle) com: índice, nome, resumo "4x 12 reps · 30 kg", ícone lixeira
- Botão `Iniciar treino` fixo no rodapé

**Ações:** reordenar (drag), excluir (confirmação), tap no item reabre o sheet da tela 9 em modo edição.

---

### 11. Execução do Exercício
**Rota:** `/execucao/:treinoId` · **Controller:** `ExecucaoController`

**Header:** back (confirma saída) + nome do exercício
**Chips:** `Série: 1 de 4` · `Descanso: 60s`
**Corpo:** GIF grande + chips de músculos (Peito, Ombro, Tríceps)
**Métricas:** Repetições `12` | Carga `30 kg`
**Ações:** `← Anterior` · `✓ Realizado` (primário) · `Próximo →` · `🔧 Alterar carga`

**Regra ao pressionar Realizado:**
- Marca série concluída
- Se **não** for a última série → vai para tela 12 (Descanso)
- Se **for** a última série → vai para tela 14 (Série Concluída)

---

### 12. Descanso (Cronômetro)
**Componente/estado:** `DescansoView` · **Controller:** `ExecucaoController`

**Corpo:**
- Anel circular verde com contagem regressiva `00:59`
- "Série 1 de 4 concluída!"
- "Próxima série: 2 de 4"
- Botões `−15s` · `Pausar` · `+15s`
- Botão `Pular descanso`

**Ao zerar:** vibra, toca som (configurável), exibe "Hora da próxima série!" e retorna automaticamente para a tela 11.

---

### 13. Próxima Série (após descanso)
**Componente/estado:** mesma view da tela 11 com dados atualizados

- Chip atualizado para `Série: 2 de 4`
- Cards de referência: Repetições `12` · Carga `30 kg`
- Mesmos botões de navegação

**Propósito:** confirmar visualmente que o app avançou de série sem navegação manual.

---

### 14. Última Série (Concluída)
**Componente:** `SerieConcluidaOverlay`

- Animação de confete
- Check verde grande
- "Série 4 de 4 — Concluída!"
- "Excelente! 💪"
- Botão `Próximo exercício`

**Regra:** aparece somente ao fechar a última série. Auto-dismiss em 3s ou tap no botão.
Se era o último exercício → vai para tela 21.

---

### 15. Próximo Exercício
**Componente/estado:** mesma view da tela 11, novo exercício carregado

- Reinicia contador de séries em `1 de N`
- Carrega GIF, músculos, repetições e carga do novo exercício
- Cronômetro geral do treino continua rodando

---

### 16. Histórico
**Rota:** `/historico` · **Controller:** `HistoricoController`

- Filtros em chips: `Todos` · `Treinos` · `Exercícios`
- Lista de sessões: nome do treino, data, duração, calorias
- Tap → detalhe da sessão (séries executadas, cargas, observações)

**Paginação:** scroll infinito, 20 por página.

---

### 17. Estatísticas
**Rota:** `/estatisticas` · **Controller:** `EstatisticasController`

- Dropdown de período: Esta semana · Este mês · 3 meses · Ano · Tudo
- Grid 2×2 de métricas: Treinos `13` · Tempo total `10h 25m` · Volume total `5.240 kg` · Calorias `8.450`
- Gráfico de linha **Evolução de volume (kg)** com pontos rotulados

**Fonte:** agregação das sessões do histórico no período selecionado.

---

### 18. Biblioteca de Exercícios
**Rota:** `/biblioteca` · **Controller:** `BibliotecaController`

- Busca no topo
- Chips: `Todos` · `Favoritos` · `Recentes`
- Lista: thumb, nome, grupos, ícone de estrela (favoritar)
- Tap → detalhe do exercício (GIF ampliado, músculos, instruções de execução)

---

### 19. Detalhe do Exercício
**Rota:** `/exercicio/:id` · **Controller:** `ExercicioDetalheController`

- GIF em tela cheia (com pinch to zoom)
- Nome + grupos musculares com bonecos anatômicos
- Aba **Execução**: passo a passo textual
- Aba **Músculos**: primários e secundários
- Aba **Histórico**: evolução de carga nesse exercício
- Botão favoritar

---

### 20. Perfil
**Rota:** `/perfil` · **Controller:** `PerfilController`

- Avatar com botão de câmera + nome
- Subtítulo: "Peso: 78 kg · Altura: 1,78 m"
- Menu: Meus dados · Objetivos (`Hipertrofia`) · Minha evolução · Fotos de progresso · Medidas corporais · Sair

**Sair:** confirmação, limpa token e volta para `/login`.

---

### 21. Treino Concluído
**Rota:** `/execucao/concluido` · **Controller:** `ExecucaoController`

- Troféu + "Treino Concluído!" + "Parabéns, você mandou bem!"
- Grid de métricas: Tempo total `48:25` · Exercícios `6` · Séries `24` · Volume total `4.250 kg` · Calorias `520 kcal`
- Recordes pessoais quebrados (se houver)
- Botões: `Compartilhar` · `Voltar para home`

**Ao salvar:** grava sessão no histórico e recalcula estatísticas.

---

### 22. Evolução de Carga (Modal)
**Componente:** `EvolucaoCargaModal`

- Título com nome do exercício
- Gráfico de linha "Evolução de carga" com marcadores de kg por data
- Rodapé: "Melhor carga `30 kg` — 15/07/2024"
- Botão `Fechar`

**Aberto de:** detalhe do exercício e da tela de execução.

---

### 23. Alterar Carga (Modal)
**Componente:** `AlterarCargaModal`

- "Carga atual" em display grande (`30 kg`)
- Stepper de nova carga: `− 30 +` com dropdown de incremento (0,5 / 1 / 2,5 / 5 kg)
- Linha de sugestão: "32,5 kg (+2,5 kg)" — baseada na progressão do histórico
- Botão `Salvar`

**Efeito:** atualiza a carga da série atual em diante e registra no histórico do exercício.

---

### 24. Observações (Modal)
**Componente:** `ObservacoesModal`

- "Como foi a execução?" — campo multiline
- **Dificuldade:** rating de 5 estrelas
- Botão `Salvar`

**Aberto:** opcionalmente após concluir um exercício ou pelo menu da execução.

---

## 4. Máquina de Estados da Execução

```
carregarTreino
      ↓
  [EXERCICIO] ←─────────────────┐
      ↓ Realizado               │
   última série? ──não──→ [DESCANSO]
      │                        ↓ timer = 0 / pular
      sim                      └──────────┘
      ↓
[SERIE_CONCLUIDA]
      ↓
  último exercício? ──não──→ carrega próximo → [EXERCICIO]
      │
      sim
      ↓
  [CONCLUIDO]
```

**Regra chave:** o descanso **nunca** aparece após a última série de um exercício.

---

## 5. Modelos de Dados

```
Usuario        { id, nome, email, dataNascimento, sexo, peso, altura, objetivo, fotoUrl }
Treino         { id, usuarioId, nome, objetivo, descricao, exercicios[], criadoEm }
TreinoExercicio{ id, exercicioId, ordem, series, repeticoes, cargaInicial, descansoSeg, observacao }
Exercicio      { id, nome, gifUrl, grupoPrimario, gruposSecundarios[], instrucoes[], favorito }
Sessao         { id, treinoId, iniciadoEm, finalizadoEm, duracaoSeg, tempoDescansoSeg,
                 volumeTotal, calorias, series[] }
SerieExecutada { id, exercicioId, numeroSerie, repeticoes, carga, concluida, dificuldade, observacao }
```

---

## 6. Controllers (GetX)

| Controller | Escopo | Responsabilidade |
|---|---|---|
| `AuthController` | permanente | Login, cadastro, token, logout |
| `HomeController` | lazy | Treino do dia, progresso semanal |
| `TreinosController` | lazy | Listagem, duplicar, excluir |
| `TreinoFormController` | lazy | Criação/edição, exercícios adicionados |
| `GruposController` | lazy | Grupos musculares |
| `ExerciciosController` | lazy | Lista por grupo, busca |
| `ExecucaoController` | lazy | Máquina de estados, cronômetros, séries |
| `HistoricoController` | lazy | Sessões paginadas |
| `EstatisticasController` | lazy | Agregações por período |
| `BibliotecaController` | lazy | Catálogo, favoritos |
| `PerfilController` | lazy | Dados do usuário, medidas |

---

## 7. Regras Transversais

- **Cronômetro geral** roda desde `Iniciar treino` até `Concluir`, visível no header.
- **Persistência local:** sessão em andamento salva a cada série; se o app fechar, retoma de onde parou.
- **Feedback ao fim do descanso:** vibração + som, ambos configuráveis no perfil.
- **Saída da execução:** sempre pede confirmação ("Deseja abandonar o treino?").
- **Cálculo de volume:** `carga × repetições × séries concluídas`.
- **Recorde pessoal:** maior carga registrada por exercício; ao ser superado, exibe badge na tela 21.
- **Offline:** GIFs em cache; execução funciona sem rede e sincroniza depois.

---

## 8. Ordem de Implementação Sugerida

1. Design tokens + componentes base (`AppScaffold`, `AppNavbar`, `AppTextField`, `AppButton`, `AppBottomNav`)
2. Splash, Login, Cadastro (fluxo de autenticação fechado)
3. Home + Meus Treinos (leitura)
4. Grupos → Exercícios → Sheet → Criar/Editar Treino (escrita)
5. Execução completa (telas 11–15, 21) — núcleo do produto
6. Modais 22, 23, 24
7. Histórico + Estatísticas
8. Biblioteca + Detalhe do exercício
9. Perfil e configurações
