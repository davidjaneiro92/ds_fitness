import '../../enum/grupo_muscular.dart';
import '../../enum/objetivo_treino.dart';
import '../../models/exercicio.dart';
import '../../models/registro_carga.dart';
import '../../models/sessao.dart';
import '../../models/treino.dart';
import '../../models/treino_exercicio.dart';
import '../../models/usuario.dart';
import '../abstracts/mock_database_interface.dart';
import 'mock/exercicios_seed.dart';
import 'mock/sessoes_seed.dart';
import 'mock/treinos_seed.dart';

/// Implementacao mockada de [MockDatabaseInterface].
///
/// Fonte unica de dados em memoria enquanto o app nao tem backend real.
/// Todas as mutacoes (favoritos, treinos, sessoes, cargas) sao mantidas
/// apenas durante a vida do processo.
class MockDatabase implements MockDatabaseInterface {
  MockDatabase()
      : _usuario = Usuario(
          id: 'u1',
          nome: 'David Silva',
          email: 'david@dsfitness.com',
          dataNascimento: DateTime(1992, 3, 14),
          sexo: 'Masculino',
          peso: 78,
          altura: 1.78,
          objetivo: ObjetivoTreino.hipertrofia,
          metaTreinosSemana: 6,
        ),
        _exercicios = buildExerciciosSeed() {
    _treinos = buildTreinosSeed(_exercicios);
    _sessoes = buildSessoesSeed(_treinos);
    _registrosCarga = _construirRegistrosCarga();
  }

  Usuario _usuario;
  final List<Exercicio> _exercicios;
  late final List<Treino> _treinos;
  late final List<Sessao> _sessoes;
  late final Map<String, List<RegistroCarga>> _registrosCarga;

  final List<String> _recentesIds = <String>[];

  /// Contador incremental por prefixo, ja posicionado apos os ids usados
  /// no seed para nunca colidir com eles.
  final Map<String, int> _contadores = <String, int>{
    'ex': 53,
    'te': 26,
  };

  // ── Usuario ────────────────────────────────────────────────────────────
  @override
  Usuario get usuario => _usuario;

  @override
  void salvarUsuario(Usuario novo) {
    _usuario = novo;
  }

  @override
  List<MedidaCorporal> get medidas => List<MedidaCorporal>.unmodifiable(
        const <MedidaCorporal>[
          MedidaCorporal(nome: 'Braço', valor: 38.5, unidade: 'cm', variacao: 0.5),
          MedidaCorporal(nome: 'Peito', valor: 104, unidade: 'cm', variacao: 1.2),
          MedidaCorporal(nome: 'Cintura', valor: 82, unidade: 'cm', variacao: -1.0),
          MedidaCorporal(nome: 'Quadril', valor: 98, unidade: 'cm', variacao: 0),
          MedidaCorporal(nome: 'Coxa', valor: 60, unidade: 'cm', variacao: 0.8),
          MedidaCorporal(
            nome: 'Panturrilha',
            valor: 38,
            unidade: 'cm',
            variacao: 0.3,
          ),
        ],
      );

  // ── Catalogo de exercicios ─────────────────────────────────────────────
  @override
  List<Exercicio> get exercicios => List<Exercicio>.unmodifiable(_exercicios);

  @override
  List<Exercicio> exerciciosPorGrupo(GrupoMuscular grupo) {
    if (grupo == GrupoMuscular.todos) {
      return exercicios;
    }
    return List<Exercicio>.unmodifiable(
      _exercicios.where((Exercicio e) => e.todosGrupos.contains(grupo)),
    );
  }

  @override
  Exercicio? exercicioPorId(String id) {
    for (final Exercicio e in _exercicios) {
      if (e.id == id) {
        return e;
      }
    }
    return null;
  }

  @override
  Exercicio alternarFavorito(String exercicioId) {
    final int indice = _exercicios.indexWhere((Exercicio e) => e.id == exercicioId);
    if (indice == -1) {
      throw ArgumentError('Exercicio nao encontrado: $exercicioId');
    }
    final Exercicio atualizado =
        _exercicios[indice].copyWith(favorito: !_exercicios[indice].favorito);
    _exercicios[indice] = atualizado;
    return atualizado;
  }

  @override
  List<Exercicio> get favoritos => List<Exercicio>.unmodifiable(
        _exercicios.where((Exercicio e) => e.favorito),
      );

  @override
  List<Exercicio> get recentes => List<Exercicio>.unmodifiable(
        _recentesIds
            .map(exercicioPorId)
            .whereType<Exercicio>(),
      );

  @override
  void registrarAcesso(String exercicioId) {
    _recentesIds.remove(exercicioId);
    _recentesIds.insert(0, exercicioId);
    if (_recentesIds.length > 10) {
      _recentesIds.removeRange(10, _recentesIds.length);
    }
  }

  // ── Treinos ────────────────────────────────────────────────────────────
  @override
  List<Treino> get treinos => List<Treino>.unmodifiable(_treinos);

  @override
  Treino? treinoPorId(String id) {
    for (final Treino t in _treinos) {
      if (t.id == id) {
        return t;
      }
    }
    return null;
  }

  @override
  Treino? get treinoDoDia {
    if (_treinos.isEmpty) {
      return null;
    }
    final int hoje = DateTime.now().weekday;
    for (final Treino t in _treinos) {
      if (t.diaSemana == hoje) {
        return t;
      }
    }
    return _treinos.first;
  }

  @override
  Treino salvarTreino(Treino treino) {
    final Treino paraSalvar =
        treino.id.isEmpty ? _comNovoId(treino, novoId('t')) : treino;
    final int indice =
        _treinos.indexWhere((Treino t) => t.id == paraSalvar.id);
    if (indice == -1) {
      _treinos.add(paraSalvar);
    } else {
      _treinos[indice] = paraSalvar;
    }
    return paraSalvar;
  }

  @override
  void excluirTreino(String id) {
    _treinos.removeWhere((Treino t) => t.id == id);
  }

  @override
  Treino duplicarTreino(String id) {
    final Treino original = _treinos.firstWhere(
      (Treino t) => t.id == id,
      orElse: () => throw ArgumentError('Treino nao encontrado: $id'),
    );
    final String novoIdTreino = novoId('t');
    final Treino copia = Treino(
      id: novoIdTreino,
      usuarioId: original.usuarioId,
      nome: '${original.nome} (cópia)',
      objetivo: original.objetivo,
      descricao: original.descricao,
      exercicios: original.exercicios
          .map(
            (TreinoExercicio te) => TreinoExercicio(
              id: novoId('te'),
              exercicio: te.exercicio,
              ordem: te.ordem,
              series: te.series,
              repeticoes: te.repeticoes,
              cargaInicial: te.cargaInicial,
              descansoSeg: te.descansoSeg,
              observacao: te.observacao,
            ),
          )
          .toList(),
      criadoEm: DateTime.now(),
      diaSemana: original.diaSemana,
    );
    _treinos.add(copia);
    return copia;
  }

  // ── Sessoes / historico ────────────────────────────────────────────────
  @override
  List<Sessao> get sessoes => List<Sessao>.unmodifiable(_sessoes);

  @override
  Sessao? sessaoPorId(String id) {
    for (final Sessao s in _sessoes) {
      if (s.id == id) {
        return s;
      }
    }
    return null;
  }

  @override
  void adicionarSessao(Sessao sessao) {
    _sessoes.insert(0, sessao);
  }

  @override
  int get treinosNaSemana {
    final DateTime agora = DateTime.now();
    final DateTime hoje = DateTime(agora.year, agora.month, agora.day);
    final DateTime inicioSemana = hoje.subtract(const Duration(days: 6));
    return _sessoes
        .where((Sessao s) => !s.iniciadoEm.isBefore(inicioSemana))
        .length;
  }

  // ── Evolucao de carga ──────────────────────────────────────────────────
  @override
  List<RegistroCarga> registrosDeCarga(String exercicioId) =>
      List<RegistroCarga>.unmodifiable(
        _registrosCarga[exercicioId] ?? const <RegistroCarga>[],
      );

  @override
  void registrarCarga(RegistroCarga registro) {
    final List<RegistroCarga> lista =
        _registrosCarga.putIfAbsent(registro.exercicioId, () => <RegistroCarga>[]);
    lista.add(registro);
  }

  @override
  RegistroCarga? recordePessoal(String exercicioId) {
    final List<RegistroCarga>? lista = _registrosCarga[exercicioId];
    if (lista == null || lista.isEmpty) {
      return null;
    }
    return lista.reduce(
      (RegistroCarga a, RegistroCarga b) => b.carga > a.carga ? b : a,
    );
  }

  // ── Utilitarios ────────────────────────────────────────────────────────
  @override
  String novoId(String prefixo) {
    final int atual = _contadores[prefixo] ?? 1;
    _contadores[prefixo] = atual + 1;
    return '${prefixo}_$atual';
  }

  Map<String, List<RegistroCarga>> _construirRegistrosCarga() {
    final DateTime agora = DateTime.now();

    List<RegistroCarga> progressao(String exercicioId, List<double> cargas) {
      const List<int> diasAtras = <int>[90, 75, 60, 45, 30, 15, 5];
      return <RegistroCarga>[
        for (int i = 0; i < cargas.length; i++)
          RegistroCarga(
            exercicioId: exercicioId,
            data: agora.subtract(Duration(days: diasAtras[i])),
            carga: cargas[i],
            repeticoes: 10,
          ),
      ];
    }

    return <String, List<RegistroCarga>>{
      'ex_1': progressao('ex_1', <double>[20, 22.5, 25, 27.5, 30, 32.5]),
      'ex_27': progressao('ex_27', <double>[40, 45, 50, 55, 60, 65, 70]),
      'ex_28': progressao('ex_28', <double>[60, 70, 80, 90, 100]),
      'ex_7': progressao('ex_7', <double>[25, 28, 32, 35, 38, 40]),
      'ex_8': progressao('ex_8', <double>[20, 25, 28, 30, 33, 35]),
      'ex_18': progressao('ex_18', <double>[8, 9, 10, 11, 12, 13]),
      'ex_20': progressao('ex_20', <double>[8, 9, 10, 11, 11.5, 12]),
      'ex_22': progressao('ex_22', <double>[12, 14, 16, 17, 18, 20]),
      'ex_13': progressao('ex_13', <double>[8, 9, 10, 11, 12, 14]),
      'ex_14': progressao('ex_14', <double>[4, 5, 6, 6.5, 7, 8]),
      'ex_32': progressao('ex_32', <double>[25, 28, 30, 33, 35, 40]),
      'ex_29': progressao('ex_29', <double>[20, 24, 28, 30, 32, 35]),
      'ex_30': progressao('ex_30', <double>[15, 18, 20, 22, 25, 28]),
    };
  }

  Treino _comNovoId(Treino treino, String id) {
    return Treino(
      id: id,
      usuarioId: treino.usuarioId,
      nome: treino.nome,
      objetivo: treino.objetivo,
      descricao: treino.descricao,
      exercicios: treino.exercicios,
      criadoEm: treino.criadoEm,
      diaSemana: treino.diaSemana,
    );
  }
}
