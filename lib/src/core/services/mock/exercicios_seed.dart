import '../../../enum/grupo_muscular.dart';
import '../../../models/exercicio.dart';

/// Catalogo mockado de exercicios (planejamento §5).
///
/// Cobre todos os [GrupoMuscular.reais] com pelo menos 4 exercicios cada.
/// Devolve uma lista nova e mutavel a cada chamada para que o
/// `MockDatabase` possa alterar favoritos sem afetar outras instancias.
List<Exercicio> buildExerciciosSeed() {
  return <Exercicio>[
    // ── Peito ────────────────────────────────────────────────────────────
    const Exercicio(
      id: 'ex_1',
      nome: 'Supino Reto',
      grupoPrimario: GrupoMuscular.peito,
      gruposSecundarios: <GrupoMuscular>[
        GrupoMuscular.triceps,
        GrupoMuscular.ombro,
      ],
      equipamento: 'Barra',
      favorito: true,
      instrucoes: <String>[
        'Deite no banco reto com os pés firmes no chão.',
        'Segure a barra um pouco mais aberta que a largura dos ombros.',
        'Desça a barra até tocar levemente o peito.',
        'Empurre a barra para cima até estender os cotovelos.',
      ],
    ),
    const Exercicio(
      id: 'ex_2',
      nome: 'Supino Inclinado',
      grupoPrimario: GrupoMuscular.peito,
      gruposSecundarios: <GrupoMuscular>[
        GrupoMuscular.triceps,
        GrupoMuscular.ombro,
      ],
      equipamento: 'Barra',
      instrucoes: <String>[
        'Ajuste o banco entre 30 e 45 graus.',
        'Retraia as escápulas antes de iniciar o movimento.',
        'Desça a barra até a parte superior do peito.',
        'Empurre a barra para cima sem travar os cotovelos.',
      ],
    ),
    const Exercicio(
      id: 'ex_3',
      nome: 'Supino Declinado',
      grupoPrimario: GrupoMuscular.peito,
      gruposSecundarios: <GrupoMuscular>[GrupoMuscular.triceps],
      equipamento: 'Barra',
      instrucoes: <String>[
        'Prenda os pés no suporte do banco declinado.',
        'Desça a barra até a linha inferior do peito.',
        'Empurre a barra de volta à posição inicial.',
        'Mantenha os ombros estáveis durante todo o movimento.',
      ],
    ),
    const Exercicio(
      id: 'ex_4',
      nome: 'Crucifixo',
      grupoPrimario: GrupoMuscular.peito,
      gruposSecundarios: <GrupoMuscular>[GrupoMuscular.ombro],
      equipamento: 'Halteres',
      instrucoes: <String>[
        'Deite no banco reto com um halter em cada mão.',
        'Abra os braços em arco mantendo leve flexão no cotovelo.',
        'Desça até sentir alongamento no peito.',
        'Traga os halteres de volta unindo sobre o peito.',
      ],
    ),
    const Exercicio(
      id: 'ex_5',
      nome: 'Cross Over',
      grupoPrimario: GrupoMuscular.peito,
      gruposSecundarios: <GrupoMuscular>[GrupoMuscular.ombro],
      equipamento: 'Cabo',
      instrucoes: <String>[
        'Posicione as polias acima da altura da cabeça.',
        'Incline levemente o tronco à frente.',
        'Puxe os cabos em arco até as mãos se encontrarem à frente do corpo.',
        'Retorne controlando o peso até o alongamento máximo.',
      ],
    ),
    const Exercicio(
      id: 'ex_6',
      nome: 'Peck Deck',
      grupoPrimario: GrupoMuscular.peito,
      gruposSecundarios: <GrupoMuscular>[GrupoMuscular.ombro],
      equipamento: 'Máquina',
      instrucoes: <String>[
        'Ajuste o banco para os apoios ficarem na altura do peito.',
        'Empurre as almofadas juntando-as à frente do corpo.',
        'Segure a contração por um instante.',
        'Retorne devagar até o alongamento controlado.',
      ],
    ),

    // ── Costas ───────────────────────────────────────────────────────────
    const Exercicio(
      id: 'ex_7',
      nome: 'Puxada Frontal',
      grupoPrimario: GrupoMuscular.costas,
      gruposSecundarios: <GrupoMuscular>[GrupoMuscular.biceps],
      equipamento: 'Cabo',
      favorito: true,
      instrucoes: <String>[
        'Sente-se e ajuste o apoio das pernas.',
        'Segure a barra mais aberta que os ombros.',
        'Puxe a barra até a altura do queixo levando os cotovelos para baixo.',
        'Retorne controlando o peso até o alongamento total.',
      ],
    ),
    const Exercicio(
      id: 'ex_8',
      nome: 'Remada Curvada',
      grupoPrimario: GrupoMuscular.costas,
      gruposSecundarios: <GrupoMuscular>[
        GrupoMuscular.biceps,
        GrupoMuscular.antebraco,
      ],
      equipamento: 'Barra',
      instrucoes: <String>[
        'Incline o tronco cerca de 45 graus mantendo a coluna reta.',
        'Segure a barra com pegada pronada.',
        'Puxe a barra em direção ao abdômen.',
        'Desça controlando até os braços estenderem.',
      ],
    ),
    const Exercicio(
      id: 'ex_9',
      nome: 'Remada Baixa',
      grupoPrimario: GrupoMuscular.costas,
      gruposSecundarios: <GrupoMuscular>[GrupoMuscular.biceps],
      equipamento: 'Cabo',
      instrucoes: <String>[
        'Sente-se com os joelhos levemente flexionados.',
        'Segure o triângulo com os braços estendidos.',
        'Puxe em direção ao abdômen mantendo o tronco ereto.',
        'Retorne devagar até o alongamento completo.',
      ],
    ),
    const Exercicio(
      id: 'ex_10',
      nome: 'Barra Fixa',
      grupoPrimario: GrupoMuscular.costas,
      gruposSecundarios: <GrupoMuscular>[
        GrupoMuscular.biceps,
        GrupoMuscular.antebraco,
      ],
      equipamento: 'Peso corporal',
      instrucoes: <String>[
        'Segure a barra com as mãos mais afastadas que os ombros.',
        'Puxe o corpo até o queixo ultrapassar a barra.',
        'Desça controlando até os braços estenderem totalmente.',
        'Evite balançar o corpo durante a execução.',
      ],
    ),
    const Exercicio(
      id: 'ex_11',
      nome: 'Pulldown',
      grupoPrimario: GrupoMuscular.costas,
      gruposSecundarios: <GrupoMuscular>[GrupoMuscular.triceps],
      equipamento: 'Cabo',
      instrucoes: <String>[
        'Fique em pé segurando a corda acima da cabeça.',
        'Mantenha os cotovelos próximos ao corpo.',
        'Puxe a corda para baixo até a altura das coxas.',
        'Retorne controlando até o alongamento total.',
      ],
    ),
    const Exercicio(
      id: 'ex_12',
      nome: 'Remada Cavalinho',
      grupoPrimario: GrupoMuscular.costas,
      gruposSecundarios: <GrupoMuscular>[
        GrupoMuscular.biceps,
        GrupoMuscular.ombro,
      ],
      equipamento: 'Barra',
      instrucoes: <String>[
        'Posicione a barra T entre as pernas.',
        'Incline o tronco mantendo a coluna neutra.',
        'Puxe a barra em direção ao abdômen.',
        'Desça controlando até o alongamento completo.',
      ],
    ),

    // ── Ombro ────────────────────────────────────────────────────────────
    const Exercicio(
      id: 'ex_13',
      nome: 'Desenvolvimento',
      grupoPrimario: GrupoMuscular.ombro,
      gruposSecundarios: <GrupoMuscular>[GrupoMuscular.triceps],
      equipamento: 'Halteres',
      favorito: true,
      instrucoes: <String>[
        'Sente-se com um halter em cada mão na altura dos ombros.',
        'Empurre os halteres para cima até quase estender os cotovelos.',
        'Desça controlando até a altura inicial.',
        'Mantenha o core contraído durante todo o movimento.',
      ],
    ),
    const Exercicio(
      id: 'ex_14',
      nome: 'Elevação Lateral',
      grupoPrimario: GrupoMuscular.ombro,
      equipamento: 'Halteres',
      instrucoes: <String>[
        'Fique em pé com um halter em cada mão ao lado do corpo.',
        'Eleve os braços lateralmente até a altura dos ombros.',
        'Mantenha leve flexão nos cotovelos.',
        'Desça controlando até a posição inicial.',
      ],
    ),
    const Exercicio(
      id: 'ex_15',
      nome: 'Elevação Frontal',
      grupoPrimario: GrupoMuscular.ombro,
      equipamento: 'Halteres',
      instrucoes: <String>[
        'Segure os halteres à frente das coxas.',
        'Eleve um braço por vez até a altura dos ombros.',
        'Evite usar impulso do tronco.',
        'Desça controlando até a posição inicial.',
      ],
    ),
    const Exercicio(
      id: 'ex_16',
      nome: 'Encolhimento',
      grupoPrimario: GrupoMuscular.ombro,
      gruposSecundarios: <GrupoMuscular>[GrupoMuscular.antebraco],
      equipamento: 'Halteres',
      instrucoes: <String>[
        'Fique em pé segurando um halter em cada mão.',
        'Eleve os ombros em direção às orelhas.',
        'Segure a contração por um instante.',
        'Desça controlando até a posição inicial.',
      ],
    ),
    const Exercicio(
      id: 'ex_17',
      nome: 'Remada Alta',
      grupoPrimario: GrupoMuscular.ombro,
      gruposSecundarios: <GrupoMuscular>[GrupoMuscular.triceps],
      equipamento: 'Barra',
      instrucoes: <String>[
        'Segure a barra com pegada fechada à frente do corpo.',
        'Puxe a barra verticalmente até a altura do peito.',
        'Mantenha os cotovelos acima das mãos durante a subida.',
        'Desça controlando até a posição inicial.',
      ],
    ),

    // ── Biceps ───────────────────────────────────────────────────────────
    const Exercicio(
      id: 'ex_18',
      nome: 'Rosca Direta',
      grupoPrimario: GrupoMuscular.biceps,
      gruposSecundarios: <GrupoMuscular>[GrupoMuscular.antebraco],
      equipamento: 'Barra',
      favorito: true,
      instrucoes: <String>[
        'Fique em pé segurando a barra com pegada supinada.',
        'Mantenha os cotovelos fixos ao lado do corpo.',
        'Flexione os braços levando a barra até os ombros.',
        'Desça controlando até a extensão completa.',
      ],
    ),
    const Exercicio(
      id: 'ex_19',
      nome: 'Rosca Alternada',
      grupoPrimario: GrupoMuscular.biceps,
      gruposSecundarios: <GrupoMuscular>[GrupoMuscular.antebraco],
      equipamento: 'Halteres',
      instrucoes: <String>[
        'Fique em pé com um halter em cada mão.',
        'Flexione um braço por vez girando o punho para cima.',
        'Desça controlando antes de iniciar o outro lado.',
        'Mantenha o cotovelo fixo durante toda a execução.',
      ],
    ),
    const Exercicio(
      id: 'ex_20',
      nome: 'Rosca Martelo',
      grupoPrimario: GrupoMuscular.biceps,
      gruposSecundarios: <GrupoMuscular>[GrupoMuscular.antebraco],
      equipamento: 'Halteres',
      instrucoes: <String>[
        'Segure os halteres com pegada neutra, palmas voltadas uma para outra.',
        'Flexione os braços mantendo os cotovelos fixos.',
        'Suba até a altura dos ombros.',
        'Desça controlando até a extensão completa.',
      ],
    ),
    const Exercicio(
      id: 'ex_21',
      nome: 'Rosca Scott',
      grupoPrimario: GrupoMuscular.biceps,
      gruposSecundarios: <GrupoMuscular>[GrupoMuscular.antebraco],
      equipamento: 'Barra',
      instrucoes: <String>[
        'Apoie os braços no banco scott.',
        'Segure a barra com pegada supinada.',
        'Flexione os braços sem tirar os tríceps do apoio.',
        'Desça controlando até quase a extensão total.',
      ],
    ),

    // ── Triceps ──────────────────────────────────────────────────────────
    const Exercicio(
      id: 'ex_22',
      nome: 'Tríceps Pulley',
      grupoPrimario: GrupoMuscular.triceps,
      equipamento: 'Cabo',
      instrucoes: <String>[
        'Segure a barra com pegada pronada próxima ao corpo.',
        'Mantenha os cotovelos fixos ao lado do tronco.',
        'Estenda os braços empurrando a barra para baixo.',
        'Retorne controlando até a flexão quase completa.',
      ],
    ),
    const Exercicio(
      id: 'ex_23',
      nome: 'Tríceps Testa',
      grupoPrimario: GrupoMuscular.triceps,
      equipamento: 'Barra',
      instrucoes: <String>[
        'Deite no banco segurando a barra acima do peito.',
        'Flexione os cotovelos descendo a barra até a testa.',
        'Mantenha os braços fixos durante o movimento.',
        'Estenda os cotovelos voltando à posição inicial.',
      ],
    ),
    const Exercicio(
      id: 'ex_24',
      nome: 'Tríceps Francês',
      grupoPrimario: GrupoMuscular.triceps,
      gruposSecundarios: <GrupoMuscular>[GrupoMuscular.ombro],
      equipamento: 'Halteres',
      instrucoes: <String>[
        'Sente-se segurando um halter com as duas mãos atrás da cabeça.',
        'Mantenha os cotovelos apontados para cima.',
        'Estenda os braços elevando o halter.',
        'Desça controlando até a flexão completa.',
      ],
    ),
    const Exercicio(
      id: 'ex_25',
      nome: 'Mergulho',
      grupoPrimario: GrupoMuscular.triceps,
      gruposSecundarios: <GrupoMuscular>[
        GrupoMuscular.peito,
        GrupoMuscular.ombro,
      ],
      equipamento: 'Peso corporal',
      instrucoes: <String>[
        'Apoie as mãos nas barras paralelas com os braços estendidos.',
        'Desça o corpo flexionando os cotovelos.',
        'Mantenha o tronco levemente inclinado à frente.',
        'Empurre o corpo de volta até estender os braços.',
      ],
    ),
    const Exercicio(
      id: 'ex_26',
      nome: 'Tríceps Coice',
      grupoPrimario: GrupoMuscular.triceps,
      gruposSecundarios: <GrupoMuscular>[GrupoMuscular.ombro],
      equipamento: 'Halteres',
      instrucoes: <String>[
        'Incline o tronco apoiando uma mão no banco.',
        'Mantenha o cotovelo fixo junto ao corpo.',
        'Estenda o braço para trás até a extensão total.',
        'Desça controlando até voltar ao ângulo de 90 graus.',
      ],
    ),

    // ── Pernas ───────────────────────────────────────────────────────────
    const Exercicio(
      id: 'ex_27',
      nome: 'Agachamento Livre',
      grupoPrimario: GrupoMuscular.pernas,
      gruposSecundarios: <GrupoMuscular>[GrupoMuscular.gluteos],
      equipamento: 'Barra',
      favorito: true,
      instrucoes: <String>[
        'Posicione a barra sobre os trapézios.',
        'Desça flexionando quadril e joelhos mantendo a coluna reta.',
        'Desça até as coxas ficarem paralelas ao chão.',
        'Suba empurrando o chão com os pés até a extensão total.',
      ],
    ),
    const Exercicio(
      id: 'ex_28',
      nome: 'Leg Press',
      grupoPrimario: GrupoMuscular.pernas,
      gruposSecundarios: <GrupoMuscular>[GrupoMuscular.gluteos],
      equipamento: 'Máquina',
      instrucoes: <String>[
        'Sente-se na máquina com os pés na plataforma na largura dos ombros.',
        'Destrave o carro e desça controlando até 90 graus.',
        'Empurre a plataforma até quase estender os joelhos.',
        'Evite travar completamente os joelhos no topo.',
      ],
    ),
    const Exercicio(
      id: 'ex_29',
      nome: 'Cadeira Extensora',
      grupoPrimario: GrupoMuscular.pernas,
      equipamento: 'Máquina',
      instrucoes: <String>[
        'Sente-se na máquina com os joelhos alinhados ao eixo de rotação.',
        'Estenda as pernas até quase a extensão total.',
        'Segure a contração por um instante no topo.',
        'Desça controlando até a posição inicial.',
      ],
    ),
    const Exercicio(
      id: 'ex_30',
      nome: 'Mesa Flexora',
      grupoPrimario: GrupoMuscular.pernas,
      equipamento: 'Máquina',
      instrucoes: <String>[
        'Deite de bruços na máquina com os joelhos na borda do banco.',
        'Flexione as pernas levando os calcanhares em direção aos glúteos.',
        'Segure a contração por um instante.',
        'Desça controlando até a extensão completa.',
      ],
    ),
    const Exercicio(
      id: 'ex_31',
      nome: 'Afundo',
      grupoPrimario: GrupoMuscular.pernas,
      gruposSecundarios: <GrupoMuscular>[GrupoMuscular.gluteos],
      equipamento: 'Halteres',
      instrucoes: <String>[
        'Fique em pé segurando um halter em cada mão.',
        'Dê um passo à frente flexionando ambos os joelhos a 90 graus.',
        'Empurre o pé da frente para retornar à posição inicial.',
        'Alterne as pernas mantendo o tronco ereto.',
      ],
    ),
    const Exercicio(
      id: 'ex_32',
      nome: 'Stiff',
      grupoPrimario: GrupoMuscular.pernas,
      gruposSecundarios: <GrupoMuscular>[GrupoMuscular.gluteos],
      equipamento: 'Barra',
      instrucoes: <String>[
        'Segure a barra à frente das coxas com os joelhos levemente flexionados.',
        'Incline o tronco à frente levando o quadril para trás.',
        'Desça a barra próxima às pernas até sentir o alongamento.',
        'Suba estendendo o quadril até a posição ereta.',
      ],
    ),

    // ── Abdomen ──────────────────────────────────────────────────────────
    const Exercicio(
      id: 'ex_33',
      nome: 'Abdominal Supra',
      grupoPrimario: GrupoMuscular.abdomen,
      equipamento: 'Peso corporal',
      instrucoes: <String>[
        'Deite com os joelhos flexionados e pés apoiados no chão.',
        'Coloque as mãos atrás da cabeça sem puxar o pescoço.',
        'Eleve o tronco contraindo o abdômen.',
        'Desça controlando até quase tocar o chão.',
      ],
    ),
    const Exercicio(
      id: 'ex_34',
      nome: 'Prancha',
      grupoPrimario: GrupoMuscular.abdomen,
      gruposSecundarios: <GrupoMuscular>[GrupoMuscular.ombro],
      equipamento: 'Peso corporal',
      instrucoes: <String>[
        'Apoie os antebraços e as pontas dos pés no chão.',
        'Mantenha o corpo alinhado da cabeça aos calcanhares.',
        'Contraia o abdômen e os glúteos durante toda a execução.',
        'Evite elevar ou baixar o quadril.',
      ],
    ),
    const Exercicio(
      id: 'ex_35',
      nome: 'Abdominal Infra',
      grupoPrimario: GrupoMuscular.abdomen,
      equipamento: 'Peso corporal',
      instrucoes: <String>[
        'Deite com as maos ao lado do corpo.',
        'Eleve as pernas estendidas em direcao ao teto.',
        'Contraia o abdomen ao elevar o quadril do chao.',
        'Desca controlando ate quase tocar o chao.',
      ],
    ),
    const Exercicio(
      id: 'ex_36',
      nome: 'Elevação de Pernas',
      grupoPrimario: GrupoMuscular.abdomen,
      equipamento: 'Peso corporal',
      instrucoes: <String>[
        'Pendure-se em uma barra com os braços estendidos.',
        'Eleve as pernas até a altura do quadril.',
        'Contraia o abdômen durante toda a subida.',
        'Desça controlando sem balançar o corpo.',
      ],
    ),

    // ── Gluteos ──────────────────────────────────────────────────────────
    const Exercicio(
      id: 'ex_37',
      nome: 'Elevação Pélvica',
      grupoPrimario: GrupoMuscular.gluteos,
      gruposSecundarios: <GrupoMuscular>[GrupoMuscular.pernas],
      equipamento: 'Barra',
      instrucoes: <String>[
        'Apoie as costas em um banco com a barra sobre o quadril.',
        'Mantenha os pés firmes no chão na largura dos ombros.',
        'Eleve o quadril até o corpo formar uma linha reta.',
        'Desça controlando sem tocar o chão com o quadril.',
      ],
    ),
    const Exercicio(
      id: 'ex_38',
      nome: 'Cadeira Abdutora',
      grupoPrimario: GrupoMuscular.gluteos,
      equipamento: 'Máquina',
      instrucoes: <String>[
        'Sente-se na máquina com as pernas apoiadas nas almofadas.',
        'Empurre as pernas para fora contra a resistência.',
        'Segure a contração por um instante.',
        'Retorne controlando até a posição inicial.',
      ],
    ),
    const Exercicio(
      id: 'ex_39',
      nome: 'Agachamento Sumô',
      grupoPrimario: GrupoMuscular.gluteos,
      gruposSecundarios: <GrupoMuscular>[GrupoMuscular.pernas],
      equipamento: 'Halteres',
      instrucoes: <String>[
        'Fique em pé com as pernas afastadas e pontas dos pés para fora.',
        'Segure um halter com as duas mãos à frente do corpo.',
        'Desça flexionando os joelhos mantendo a coluna reta.',
        'Suba estendendo quadril e joelhos até a posição inicial.',
      ],
    ),
    const Exercicio(
      id: 'ex_40',
      nome: 'Coice no Cabo',
      grupoPrimario: GrupoMuscular.gluteos,
      gruposSecundarios: <GrupoMuscular>[GrupoMuscular.pernas],
      equipamento: 'Cabo',
      instrucoes: <String>[
        'Prenda o cabo no tornozelo e fique de frente para a máquina.',
        'Apoie as mãos no aparelho para estabilidade.',
        'Estenda o quadril levando a perna para trás.',
        'Retorne controlando até a posição inicial.',
      ],
    ),

    // ── Panturrilha ──────────────────────────────────────────────────────
    const Exercicio(
      id: 'ex_41',
      nome: 'Panturrilha em Pé',
      grupoPrimario: GrupoMuscular.panturrilha,
      equipamento: 'Máquina',
      instrucoes: <String>[
        'Posicione os ombros sob as almofadas da máquina.',
        'Apoie a ponta dos pés na plataforma.',
        'Eleve os calcanhares o máximo possível.',
        'Desça controlando até sentir o alongamento.',
      ],
    ),
    const Exercicio(
      id: 'ex_42',
      nome: 'Panturrilha Sentado',
      grupoPrimario: GrupoMuscular.panturrilha,
      equipamento: 'Máquina',
      instrucoes: <String>[
        'Sente-se com os joelhos sob as almofadas da máquina.',
        'Apoie a ponta dos pés na plataforma.',
        'Eleve os calcanhares contraindo a panturrilha.',
        'Desça controlando até o alongamento máximo.',
      ],
    ),
    const Exercicio(
      id: 'ex_43',
      nome: 'Panturrilha no Leg Press',
      grupoPrimario: GrupoMuscular.panturrilha,
      equipamento: 'Máquina',
      instrucoes: <String>[
        'Sente-se no leg press com apenas a ponta dos pés na plataforma.',
        'Estenda os tornozelos empurrando a plataforma.',
        'Segure a contração por um instante.',
        'Desça controlando até o alongamento completo.',
      ],
    ),
    const Exercicio(
      id: 'ex_44',
      nome: 'Panturrilha Unilateral',
      grupoPrimario: GrupoMuscular.panturrilha,
      equipamento: 'Halteres',
      instrucoes: <String>[
        'Fique em pé sobre um step segurando um halter.',
        'Apoie apenas a ponta de um pé na borda do step.',
        'Eleve o calcanhar o máximo possível.',
        'Desça controlando até sentir o alongamento.',
      ],
    ),

    // ── Cardio ───────────────────────────────────────────────────────────
    const Exercicio(
      id: 'ex_45',
      nome: 'Esteira',
      grupoPrimario: GrupoMuscular.cardio,
      gruposSecundarios: <GrupoMuscular>[GrupoMuscular.pernas],
      equipamento: 'Máquina',
      favorito: true,
      instrucoes: <String>[
        'Ajuste a velocidade e a inclinação antes de iniciar.',
        'Mantenha a postura ereta durante a corrida ou caminhada.',
        'Respire de forma ritmada durante todo o percurso.',
        'Reduza a velocidade gradualmente ao final.',
      ],
    ),
    const Exercicio(
      id: 'ex_46',
      nome: 'Bicicleta Ergométrica',
      grupoPrimario: GrupoMuscular.cardio,
      gruposSecundarios: <GrupoMuscular>[GrupoMuscular.pernas],
      equipamento: 'Máquina',
      instrucoes: <String>[
        'Ajuste o banco na altura correta para os joelhos.',
        'Mantenha um ritmo constante de pedalada.',
        'Ajuste a carga conforme o objetivo do treino.',
        'Reduza o ritmo gradualmente antes de encerrar.',
      ],
    ),
    const Exercicio(
      id: 'ex_47',
      nome: 'Elíptico',
      grupoPrimario: GrupoMuscular.cardio,
      gruposSecundarios: <GrupoMuscular>[GrupoMuscular.pernas],
      equipamento: 'Máquina',
      instrucoes: <String>[
        'Posicione os pés nos pedais e segure os apoios móveis.',
        'Mantenha um movimento fluido entre braços e pernas.',
        'Ajuste a resistência conforme a intensidade desejada.',
        'Mantenha a postura ereta durante todo o exercício.',
      ],
    ),
    const Exercicio(
      id: 'ex_48',
      nome: 'Pular Corda',
      grupoPrimario: GrupoMuscular.cardio,
      gruposSecundarios: <GrupoMuscular>[GrupoMuscular.panturrilha],
      equipamento: 'Peso corporal',
      instrucoes: <String>[
        'Segure as extremidades da corda com os cotovelos próximos ao corpo.',
        'Gire a corda usando principalmente os punhos.',
        'Salte apenas o necessário para a corda passar sob os pés.',
        'Mantenha um ritmo constante durante as séries.',
      ],
    ),

    // ── Antebraco ────────────────────────────────────────────────────────
    const Exercicio(
      id: 'ex_49',
      nome: 'Rosca Punho',
      grupoPrimario: GrupoMuscular.antebraco,
      gruposSecundarios: <GrupoMuscular>[GrupoMuscular.biceps],
      equipamento: 'Barra',
      instrucoes: <String>[
        'Sente-se apoiando os antebraços nas coxas.',
        'Segure a barra com pegada pronada.',
        'Flexione os punhos elevando a barra.',
        'Desça controlando até o alongamento completo.',
      ],
    ),
    const Exercicio(
      id: 'ex_50',
      nome: 'Extensão de Punho',
      grupoPrimario: GrupoMuscular.antebraco,
      gruposSecundarios: <GrupoMuscular>[GrupoMuscular.biceps],
      equipamento: 'Barra',
      instrucoes: <String>[
        'Sente-se apoiando os antebraços nas coxas com as palmas para baixo.',
        'Segure a barra com pegada pronada.',
        'Estenda os punhos elevando a barra.',
        'Desça controlando até a flexão completa.',
      ],
    ),
    const Exercicio(
      id: 'ex_51',
      nome: 'Rosca Punho Invertida',
      grupoPrimario: GrupoMuscular.antebraco,
      gruposSecundarios: <GrupoMuscular>[GrupoMuscular.biceps],
      equipamento: 'Barra',
      instrucoes: <String>[
        'Sente-se apoiando os antebraços nas coxas com as palmas para baixo.',
        'Segure a barra com pegada pronada.',
        'Flexione os punhos elevando a barra para cima.',
        'Desça controlando até o alongamento completo.',
      ],
    ),
    const Exercicio(
      id: 'ex_52',
      nome: 'Caminhada do Fazendeiro',
      grupoPrimario: GrupoMuscular.antebraco,
      gruposSecundarios: <GrupoMuscular>[GrupoMuscular.pernas],
      equipamento: 'Halteres',
      instrucoes: <String>[
        'Segure um halter pesado em cada mão ao lado do corpo.',
        'Mantenha a postura ereta com os ombros para trás.',
        'Caminhe por uma distância ou tempo determinado.',
        'Evite balançar o tronco durante o percurso.',
      ],
    ),
  ];
}
