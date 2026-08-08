import '../enum/grupo_muscular.dart';

/// Exercicio do catalogo (planejamento §5).
class Exercicio {
  const Exercicio({
    required this.id,
    required this.nome,
    required this.grupoPrimario,
    this.gruposSecundarios = const <GrupoMuscular>[],
    this.instrucoes = const <String>[],
    this.equipamento = '',
    this.favorito = false,
  });

  factory Exercicio.fromJson(Map<String, dynamic> json) {
    return Exercicio(
      id: json['id'] as String,
      nome: json['nome'] as String,
      grupoPrimario: GrupoMuscular.fromSlug(json['grupoPrimario'] as String?),
      gruposSecundarios: (json['gruposSecundarios'] as List<dynamic>? ??
              <dynamic>[])
          .map((dynamic e) => GrupoMuscular.fromSlug(e as String?))
          .toList(),
      instrucoes: (json['instrucoes'] as List<dynamic>? ?? <dynamic>[])
          .map((dynamic e) => e as String)
          .toList(),
      equipamento: json['equipamento'] as String? ?? '',
      favorito: json['favorito'] as bool? ?? false,
    );
  }

  final String id;
  final String nome;
  final GrupoMuscular grupoPrimario;
  final List<GrupoMuscular> gruposSecundarios;
  final List<String> instrucoes;
  final String equipamento;
  final bool favorito;

  /// Grupo primario seguido dos secundarios, sem repeticao.
  List<GrupoMuscular> get todosGrupos => <GrupoMuscular>[
        grupoPrimario,
        ...gruposSecundarios.where((g) => g != grupoPrimario),
      ];

  /// Ex.: "Peito, Tríceps, Ombro" — usado como subtitulo dos cards.
  String get gruposLabel => todosGrupos.map((g) => g.label).join(', ');

  Exercicio copyWith({
    String? nome,
    GrupoMuscular? grupoPrimario,
    List<GrupoMuscular>? gruposSecundarios,
    List<String>? instrucoes,
    String? equipamento,
    bool? favorito,
  }) {
    return Exercicio(
      id: id,
      nome: nome ?? this.nome,
      grupoPrimario: grupoPrimario ?? this.grupoPrimario,
      gruposSecundarios: gruposSecundarios ?? this.gruposSecundarios,
      instrucoes: instrucoes ?? this.instrucoes,
      equipamento: equipamento ?? this.equipamento,
      favorito: favorito ?? this.favorito,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'nome': nome,
        'grupoPrimario': grupoPrimario.slug,
        'gruposSecundarios':
            gruposSecundarios.map((g) => g.slug).toList(),
        'instrucoes': instrucoes,
        'equipamento': equipamento,
        'favorito': favorito,
      };

  @override
  bool operator ==(Object other) =>
      other is Exercicio && other.id == id && other.favorito == favorito;

  @override
  int get hashCode => Object.hash(id, favorito);
}
