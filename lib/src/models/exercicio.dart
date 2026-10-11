import 'package:flutter/foundation.dart' show listEquals;

import '../core/utils/json_utils.dart';
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
    this.personalizado = false,
    this.gifUrl = '',
    this.miniaturaUrl = '',
  });

  factory Exercicio.fromJson(Map<String, dynamic> json) {
    return Exercicio(
      id: JsonUtils.idParaTexto(json['id']),
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
      personalizado: json['personalizado'] as bool? ?? false,
      gifUrl: json['gifUrl'] as String? ?? '',
      miniaturaUrl: json['miniaturaUrl'] as String? ?? '',
    );
  }

  final String id;
  final String nome;
  final GrupoMuscular grupoPrimario;
  final List<GrupoMuscular> gruposSecundarios;
  final List<String> instrucoes;
  final String equipamento;
  final bool favorito;

  /// `true` quando o proprio usuario criou o exercicio — so ele pode alterar
  /// ou excluir. Os do catalogo do sistema sao somente leitura.
  final bool personalizado;

  /// Link do GIF que mostra o movimento. Vazio quando o exercicio nao tem
  /// imagem (os que o usuario cria): a tela mostra a ilustracao generica.
  final String gifUrl;

  /// Link da versao pequena do GIF, para as listas. Vazio quando nao ha.
  final String miniaturaUrl;

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
    bool? personalizado,
    String? gifUrl,
    String? miniaturaUrl,
  }) {
    return Exercicio(
      id: id,
      nome: nome ?? this.nome,
      grupoPrimario: grupoPrimario ?? this.grupoPrimario,
      gruposSecundarios: gruposSecundarios ?? this.gruposSecundarios,
      instrucoes: instrucoes ?? this.instrucoes,
      equipamento: equipamento ?? this.equipamento,
      favorito: favorito ?? this.favorito,
      personalizado: personalizado ?? this.personalizado,
      gifUrl: gifUrl ?? this.gifUrl,
      miniaturaUrl: miniaturaUrl ?? this.miniaturaUrl,
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
        'personalizado': personalizado,
        'gifUrl': gifUrl,
        'miniaturaUrl': miniaturaUrl,
      };

  /// Igualdade por valor: o `Rx` so notifica quando o valor muda, e editar o
  /// nome, os grupos ou o equipamento precisa contar como mudanca.
  @override
  bool operator ==(Object other) =>
      other is Exercicio &&
      other.id == id &&
      other.nome == nome &&
      other.grupoPrimario == grupoPrimario &&
      listEquals(other.gruposSecundarios, gruposSecundarios) &&
      listEquals(other.instrucoes, instrucoes) &&
      other.equipamento == equipamento &&
      other.favorito == favorito &&
      other.personalizado == personalizado &&
      other.gifUrl == gifUrl &&
      other.miniaturaUrl == miniaturaUrl;

  @override
  int get hashCode => Object.hash(
        id,
        nome,
        grupoPrimario,
        Object.hashAll(gruposSecundarios),
        Object.hashAll(instrucoes),
        equipamento,
        favorito,
        personalizado,
        gifUrl,
        miniaturaUrl,
      );
}
