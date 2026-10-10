import 'package:ds_fitness/src/enum/grupo_muscular.dart';
import 'package:ds_fitness/src/enum/objetivo_treino.dart';
import 'package:ds_fitness/src/models/exercicio.dart';
import 'package:ds_fitness/src/models/registro_carga.dart';
import 'package:ds_fitness/src/models/sessao.dart';
import 'package:ds_fitness/src/models/treino.dart';
import 'package:ds_fitness/src/models/usuario.dart';
import 'package:flutter_test/flutter_test.dart';

/// O servidor devolve ids numericos e instantes em UTC; os modelos guardam
/// ids como texto e datas no fuso do aparelho.
void main() {
  test('Exercicio le id numerico, grupos e a marca de personalizado', () {
    final Exercicio exercicio = Exercicio.fromJson(<String, dynamic>{
      'id': 7,
      'nome': 'Puxada Frontal',
      'grupoPrimario': 'costas',
      'gruposSecundarios': <String>['biceps'],
      'instrucoes': <String>['Sente-se.'],
      'equipamento': 'Cabo',
      'favorito': true,
      'personalizado': false,
    });

    expect(exercicio.id, '7');
    expect(exercicio.grupoPrimario, GrupoMuscular.costas);
    expect(exercicio.gruposSecundarios, <GrupoMuscular>[GrupoMuscular.biceps]);
    expect(exercicio.favorito, isTrue);
    expect(exercicio.personalizado, isFalse);
  });

  test('Exercicio editado nao e igual ao original (o Rx precisa notificar)', () {
    const Exercicio original = Exercicio(
      id: '7',
      nome: 'Remada',
      grupoPrimario: GrupoMuscular.costas,
      gruposSecundarios: <GrupoMuscular>[GrupoMuscular.biceps],
      instrucoes: <String>['Puxe.'],
      equipamento: 'Barra',
      personalizado: true,
    );

    expect(original.copyWith(), original);
    expect(original.copyWith().hashCode, original.hashCode);
    expect(original.copyWith(equipamento: 'Halteres'), isNot(original));
    expect(original.copyWith(nome: 'Remada curvada'), isNot(original));
    expect(
      original.copyWith(gruposSecundarios: <GrupoMuscular>[GrupoMuscular.ombro]),
      isNot(original),
    );
    expect(original.copyWith(instrucoes: <String>['Puxe.', 'Solte.']), isNot(original));
    expect(original.copyWith(favorito: true), isNot(original));
  });

  test('Treino le os itens com o exercicio embutido', () {
    final Treino treino = Treino.fromJson(<String, dynamic>{
      'id': 3,
      'nome': 'Peito e Tríceps',
      'objetivo': 'forca',
      'descricao': '',
      'diaSemana': 1,
      'criadoEm': '2026-10-10T12:00:00Z',
      'exercicios': <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 11,
          'ordem': 0,
          'series': 4,
          'repeticoes': 12,
          'cargaInicial': 32.5,
          'descansoSeg': 60,
          'observacao': 'Controle.',
          'exercicio': <String, dynamic>{
            'id': 1,
            'nome': 'Supino Reto',
            'grupoPrimario': 'peito',
            'gruposSecundarios': <String>['triceps', 'ombro'],
            'equipamento': 'Barra',
            'instrucoes': <String>[],
          },
        },
      ],
    });

    expect(treino.id, '3');
    expect(treino.objetivo, ObjetivoTreino.forca);
    expect(treino.diaSemana, 1);
    expect(treino.criadoEm!.isUtc, isFalse, reason: 'datas ficam no fuso do aparelho');
    expect(treino.exercicios.single.id, '11');
    expect(treino.exercicios.single.exercicioId, '1');
    expect(treino.exercicios.single.cargaInicial, 32.5);
    expect(treino.totalSeries, 4);
    expect(treino.gruposLabel, 'Peito');
  });

  test('Sessao le as series com o nome do exercicio e os recordes', () {
    final Sessao sessao = Sessao.fromJson(<String, dynamic>{
      'id': 5,
      'treinoId': 3,
      'treinoNome': 'Peito e Tríceps',
      'iniciadoEm': '2026-10-10T12:00:00Z',
      'finalizadoEm': '2026-10-10T12:45:00Z',
      'duracaoSeg': 2700,
      'tempoDescansoSeg': 600,
      'volumeTotal': 4200,
      'calorias': 360,
      'series': <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 1,
          'exercicioId': 1,
          'exercicioNome': 'Supino Reto',
          'numeroSerie': 1,
          'repeticoes': 10,
          'carga': 32.5,
          'concluida': true,
          'dificuldade': 3,
          'observacao': '',
        },
      ],
      'recordes': <String>['Supino Reto'],
    });

    expect(sessao.id, '5');
    expect(sessao.treinoId, '3');
    expect(sessao.volumeTotal, 4200.0);
    expect(sessao.series.single.exercicioNome, 'Supino Reto');
    expect(sessao.series.single.volume, 325.0);
    expect(sessao.recordes, <String>['Supino Reto']);
    expect(sessao.totalExercicios, 1);
  });

  test('Usuario le a data de nascimento sem deslocar o dia', () {
    final Usuario usuario = Usuario.fromJson(<String, dynamic>{
      'id': 1,
      'nome': 'David Silva',
      'email': 'david@dsfitness.com',
      'dataNascimento': '1992-03-14',
      'sexo': 'Masculino',
      'peso': 78.5,
      'altura': 1.78,
      'objetivo': 'hipertrofia',
      'fotoUrl': '',
      'metaTreinosSemana': 5,
    });

    expect(usuario.dataNascimento!.year, 1992);
    expect(usuario.dataNascimento!.month, 3);
    expect(usuario.dataNascimento!.day, 14);
    expect(usuario.toJson()['dataNascimento'], '1992-03-14');
    expect(usuario.primeiroNome, 'David');
  });

  test('Usuario sem peso e altura nao mostra zeros', () {
    final Usuario sem = Usuario.fromJson(<String, dynamic>{
      'id': 1,
      'nome': 'Ana',
      'email': 'ana@dsfitness.com',
      'peso': 0,
      'altura': 0,
    });
    final Usuario so = sem.copyWith(peso: 62);
    final Usuario completo = sem.copyWith(peso: 78.4, altura: 1.78);

    expect(sem.resumoFisico, 'Peso e altura não informados');
    expect(sem.pesoLabel, '—');
    expect(sem.alturaLabel, '—');
    expect(so.resumoFisico, 'Peso: 62 kg · Altura: —');
    expect(completo.resumoFisico, 'Peso: 78 kg · Altura: 1,78 m');
  });

  test('EvolucaoDeCarga le os registros e o recorde, ou vem vazia', () {
    final EvolucaoDeCarga evolucao = EvolucaoDeCarga.fromJson(<String, dynamic>{
      'registros': <Map<String, dynamic>>[
        <String, dynamic>{
          'exercicioId': 1,
          'data': '2026-10-01T10:00:00Z',
          'carga': 30,
          'repeticoes': 10,
        },
      ],
      'recorde': <String, dynamic>{
        'exercicioId': 1,
        'data': '2026-10-01T10:00:00Z',
        'carga': 30,
        'repeticoes': 10,
      },
    });
    final EvolucaoDeCarga vazia = EvolucaoDeCarga.fromJson(<String, dynamic>{
      'registros': <dynamic>[],
      'recorde': null,
    });

    expect(evolucao.registros.single.carga, 30.0);
    expect(evolucao.recorde!.exercicioId, '1');
    expect(vazia.registros, isEmpty);
    expect(vazia.recorde, isNull);
  });
}
