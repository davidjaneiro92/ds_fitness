import '../enum/objetivo_treino.dart';

/// Usuario logado (planejamento §5).
class Usuario {
  const Usuario({
    required this.id,
    required this.nome,
    required this.email,
    this.dataNascimento,
    this.sexo = 'Masculino',
    this.peso = 0,
    this.altura = 0,
    this.objetivo = ObjetivoTreino.hipertrofia,
    this.fotoUrl = '',
    this.metaTreinosSemana = 6,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] as String,
      nome: json['nome'] as String,
      email: json['email'] as String,
      dataNascimento:
          DateTime.tryParse(json['dataNascimento'] as String? ?? ''),
      sexo: json['sexo'] as String? ?? 'Masculino',
      peso: (json['peso'] as num?)?.toDouble() ?? 0,
      altura: (json['altura'] as num?)?.toDouble() ?? 0,
      objetivo: ObjetivoTreino.fromSlug(json['objetivo'] as String?),
      fotoUrl: json['fotoUrl'] as String? ?? '',
      metaTreinosSemana: json['metaTreinosSemana'] as int? ?? 6,
    );
  }

  final String id;
  final String nome;
  final String email;
  final DateTime? dataNascimento;
  final String sexo;

  /// Peso em kg.
  final double peso;

  /// Altura em metros.
  final double altura;
  final ObjetivoTreino objetivo;
  final String fotoUrl;
  final int metaTreinosSemana;

  /// Primeiro nome — usado na saudacao da home.
  String get primeiroNome => nome.split(' ').first;

  /// Iniciais para o avatar sem foto.
  String get iniciais {
    final List<String> partes =
        nome.trim().split(' ').where((String p) => p.isNotEmpty).toList();
    if (partes.isEmpty) {
      return '?';
    }
    if (partes.length == 1) {
      return partes.first.substring(0, 1).toUpperCase();
    }
    return (partes.first.substring(0, 1) + partes.last.substring(0, 1))
        .toUpperCase();
  }

  /// Ex.: "Peso: 78 kg · Altura: 1,78 m".
  String get resumoFisico =>
      'Peso: ${peso.toStringAsFixed(0)} kg · Altura: '
      '${altura.toStringAsFixed(2).replaceAll('.', ',')} m';

  Usuario copyWith({
    String? nome,
    String? email,
    DateTime? dataNascimento,
    String? sexo,
    double? peso,
    double? altura,
    ObjetivoTreino? objetivo,
    String? fotoUrl,
    int? metaTreinosSemana,
  }) {
    return Usuario(
      id: id,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      dataNascimento: dataNascimento ?? this.dataNascimento,
      sexo: sexo ?? this.sexo,
      peso: peso ?? this.peso,
      altura: altura ?? this.altura,
      objetivo: objetivo ?? this.objetivo,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      metaTreinosSemana: metaTreinosSemana ?? this.metaTreinosSemana,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'nome': nome,
        'email': email,
        'dataNascimento': dataNascimento?.toIso8601String(),
        'sexo': sexo,
        'peso': peso,
        'altura': altura,
        'objetivo': objetivo.slug,
        'fotoUrl': fotoUrl,
        'metaTreinosSemana': metaTreinosSemana,
      };
}
