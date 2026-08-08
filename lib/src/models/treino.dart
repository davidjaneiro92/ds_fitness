import '../enum/grupo_muscular.dart';
import '../enum/objetivo_treino.dart';
import 'treino_exercicio.dart';

/// Treino montado pelo usuario (planejamento §5).
class Treino {
  const Treino({
    required this.id,
    required this.nome,
    this.usuarioId = 'u1',
    this.objetivo = ObjetivoTreino.hipertrofia,
    this.descricao = '',
    this.exercicios = const <TreinoExercicio>[],
    this.criadoEm,
    this.diaSemana,
  });

  factory Treino.fromJson(Map<String, dynamic> json) {
    return Treino(
      id: json['id'] as String,
      nome: json['nome'] as String,
      usuarioId: json['usuarioId'] as String? ?? 'u1',
      objetivo: ObjetivoTreino.fromSlug(json['objetivo'] as String?),
      descricao: json['descricao'] as String? ?? '',
      exercicios: (json['exercicios'] as List<dynamic>? ?? <dynamic>[])
          .map((dynamic e) =>
              TreinoExercicio.fromJson(e as Map<String, dynamic>))
          .toList(),
      criadoEm: DateTime.tryParse(json['criadoEm'] as String? ?? ''),
      diaSemana: json['diaSemana'] as int?,
    );
  }

  final String id;
  final String usuarioId;
  final String nome;
  final ObjetivoTreino objetivo;
  final String descricao;
  final List<TreinoExercicio> exercicios;
  final DateTime? criadoEm;

  /// 1 = segunda ... 7 = domingo. Usado para escolher o treino do dia.
  final int? diaSemana;

  int get totalExercicios => exercicios.length;

  int get totalSeries =>
      exercicios.fold<int>(0, (int soma, TreinoExercicio e) => soma + e.series);

  /// Grupos musculares primarios cobertos, na ordem de aparicao.
  List<GrupoMuscular> get grupos {
    final List<GrupoMuscular> resultado = <GrupoMuscular>[];
    for (final TreinoExercicio item in exercicios) {
      if (!resultado.contains(item.exercicio.grupoPrimario)) {
        resultado.add(item.exercicio.grupoPrimario);
      }
    }
    return resultado;
  }

  /// Ex.: "Peito, Ombro, Tríceps".
  String get gruposLabel =>
      grupos.isEmpty ? 'Sem exercícios' : grupos.map((g) => g.label).join(', ');

  /// Ex.: "6 exercícios".
  String get exerciciosLabel =>
      '$totalExercicios ${totalExercicios == 1 ? 'exercício' : 'exercícios'}';

  double get volumePlanejado => exercicios.fold<double>(
        0,
        (double soma, TreinoExercicio e) => soma + e.volumePlanejado,
      );

  Treino copyWith({
    String? nome,
    ObjetivoTreino? objetivo,
    String? descricao,
    List<TreinoExercicio>? exercicios,
    DateTime? criadoEm,
    int? diaSemana,
  }) {
    return Treino(
      id: id,
      usuarioId: usuarioId,
      nome: nome ?? this.nome,
      objetivo: objetivo ?? this.objetivo,
      descricao: descricao ?? this.descricao,
      exercicios: exercicios ?? this.exercicios,
      criadoEm: criadoEm ?? this.criadoEm,
      diaSemana: diaSemana ?? this.diaSemana,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'usuarioId': usuarioId,
        'nome': nome,
        'objetivo': objetivo.slug,
        'descricao': descricao,
        'exercicios':
            exercicios.map((TreinoExercicio e) => e.toJson()).toList(),
        'criadoEm': criadoEm?.toIso8601String(),
        'diaSemana': diaSemana,
      };
}
