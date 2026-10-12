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
    this.imagem = '',
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
      imagem: json['imagem'] as String? ?? '',
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

  /// Chave da imagem do exercicio (`pasta/arquivo`, sem extensao), a partir da
  /// qual o app monta o caminho do GIF e o da miniatura (`AppAssets`). Vazia
  /// quando o exercicio nao tem imagem (os que o usuario cria): a tela mostra
  /// a ilustracao generica.
  final String imagem;

  /// Grupo primario seguido dos secundarios, sem repeticao.
  List<GrupoMuscular> get todosGrupos => <GrupoMuscular>[
        grupoPrimario,
        ...gruposSecundarios.where((g) => g != grupoPrimario),
      ];

  /// Ex.: "Peito • Tríceps • Ombros" — usado como subtitulo dos cards.
  String get gruposLabel => todosGrupos.map((g) => g.label).join(' • ');

  Exercicio copyWith({
    String? nome,
    GrupoMuscular? grupoPrimario,
    List<GrupoMuscular>? gruposSecundarios,
    List<String>? instrucoes,
    String? equipamento,
    bool? favorito,
    bool? personalizado,
    String? imagem,
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
      imagem: imagem ?? this.imagem,
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
        'imagem': imagem,
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
      other.imagem == imagem;

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
        imagem,
      );
}
