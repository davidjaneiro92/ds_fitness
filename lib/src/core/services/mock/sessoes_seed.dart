import '../../../models/serie_executada.dart';
import '../../../models/sessao.dart';
import '../../../models/treino.dart';
import '../../../models/treino_exercicio.dart';

/// Historico mockado de sessoes (planejamento §5).
///
/// As datas sao calculadas a partir de `DateTime.now()` no momento da
/// chamada — assim "esta semana" e "ultimos 30 dias" ficam sempre
/// coerentes, independente de quando o app for executado. Distribuicao:
/// 4 sessoes na semana corrente, 13 nos ultimos 30 dias (incluindo as 4
/// da semana), e mais 21 espalhadas ate 365 dias atras — total de 34.
List<Sessao> buildSessoesSeed(List<Treino> treinos) {
  final DateTime agora = DateTime.now();

  // Dias atras de cada sessao: [semana corrente (4)] + [resto dos ultimos
  // 30 dias (9)] + [historico ate 365 dias (21)].
  final List<int> diasAtras = <int>[
    0, 2, 4, 6, //
    8, 10, 12, 14, 16, 19, 22, 25, 28, //
    for (int i = 0; i < 21; i++) 31 + i * 16,
  ];

  // Valores calculados para as 13 sessoes dos ultimos 30 dias, ajustados
  // para somar perto de ~10h25m de duracao, ~5.240 kg de volume medio por
  // sessao e ~8.450 kcal no total (aproximado).
  const List<int> duracoesRecentes = <int>[
    2700, 2850, 3000, 2950, 2800, 3100, 2750, 3200, 2900, 3050, 2650, 3150,
    2900,
  ];
  const List<double> volumesRecentes = <double>[
    5150, 5000, 5200, 4950, 5100, 4900, 5180, 5050, 4980, 5200, 4850, 5190,
    5080,
  ];
  const List<int> caloriasRecentes = <int>[
    600, 580, 610, 590, 570, 615, 595, 605, 580, 600, 575, 610, 595,
  ];

  // Valores ciclicos para as 21 sessoes mais antigas (31 a 365 dias atras).
  const List<int> duracoesAntigas = <int>[
    2500, 2650, 2800, 2950, 3100, 3250, 2450, 2700, 2900, 3050,
  ];
  const List<double> volumesAntigos = <double>[
    3900, 4100, 4300, 4500, 4700, 4900, 5100, 4000, 4200, 4400,
  ];
  const List<int> caloriasAntigas = <int>[
    400, 430, 460, 490, 520, 550, 580, 410, 440, 470,
  ];

  final List<Sessao> sessoes = <Sessao>[];

  for (int i = 0; i < diasAtras.length; i++) {
    final int dias = diasAtras[i];
    final Treino treino = treinos[i % treinos.length];
    final DateTime iniciadoEm =
        agora.subtract(Duration(days: dias, minutes: 5));

    final int duracaoSeg;
    final double volumeTotal;
    final int calorias;
    if (i < 13) {
      duracaoSeg = duracoesRecentes[i];
      volumeTotal = volumesRecentes[i];
      calorias = caloriasRecentes[i];
    } else {
      final int idx = (i - 13) % duracoesAntigas.length;
      duracaoSeg = duracoesAntigas[idx];
      volumeTotal = volumesAntigos[idx];
      calorias = caloriasAntigas[idx];
    }

    // Cargas ligeiramente menores em sessoes mais antigas, simulando a
    // progressao de carga ao longo do tempo.
    final double fatorCarga =
        (1 - (dias / 365) * 0.2).clamp(0.75, 1.05).toDouble();

    final List<String> recordes = <String>[];
    if (i == 0) {
      recordes.add('Supino Reto');
    } else if (i == 2) {
      recordes.add('Agachamento Livre');
    } else if (i == 15) {
      recordes.add('Puxada Frontal');
    } else if (i == 25) {
      recordes.add('Rosca Direta');
    }

    sessoes.add(_construirSessao(
      id: 's${i + 1}',
      treino: treino,
      iniciadoEm: iniciadoEm,
      duracaoSeg: duracaoSeg,
      volumeTotal: volumeTotal,
      calorias: calorias,
      fatorCarga: fatorCarga,
      recordes: recordes,
    ));
  }

  sessoes.sort((Sessao a, Sessao b) => b.iniciadoEm.compareTo(a.iniciadoEm));
  return sessoes;
}

Sessao _construirSessao({
  required String id,
  required Treino treino,
  required DateTime iniciadoEm,
  required int duracaoSeg,
  required double volumeTotal,
  required int calorias,
  required double fatorCarga,
  List<String> recordes = const <String>[],
}) {
  final List<SerieExecutada> series = _seriesDoTreino(id, treino, fatorCarga);
  return Sessao(
    id: id,
    treinoId: treino.id,
    treinoNome: treino.nome,
    iniciadoEm: iniciadoEm,
    finalizadoEm: iniciadoEm.add(Duration(seconds: duracaoSeg)),
    duracaoSeg: duracaoSeg,
    tempoDescansoSeg: (duracaoSeg * 0.35).round(),
    volumeTotal: volumeTotal,
    calorias: calorias,
    series: series,
    recordes: recordes,
  );
}

List<SerieExecutada> _seriesDoTreino(
  String sessaoId,
  Treino treino,
  double fatorCarga,
) {
  final List<SerieExecutada> lista = <SerieExecutada>[];
  int contador = 1;
  for (final TreinoExercicio te in treino.exercicios) {
    for (int n = 1; n <= te.series; n++) {
      lista.add(SerieExecutada(
        id: '${sessaoId}_s$contador',
        exercicioId: te.exercicioId,
        numeroSerie: n,
        repeticoes: te.repeticoes,
        carga:
            double.parse((te.cargaInicial * fatorCarga).toStringAsFixed(1)),
        concluida: true,
      ));
      contador++;
    }
  }
  return lista;
}
