/// Ponto de evolucao de carga de um exercicio ao longo do tempo.
///
/// Alimenta o modal "Evolução de Carga" (tela 22) e a aba Historico do
/// detalhe do exercicio (tela 19).
class RegistroCarga {
  const RegistroCarga({
    required this.exercicioId,
    required this.data,
    required this.carga,
    this.repeticoes = 12,
  });

  factory RegistroCarga.fromJson(Map<String, dynamic> json) {
    return RegistroCarga(
      exercicioId: json['exercicioId'] as String,
      data: DateTime.parse(json['data'] as String),
      carga: (json['carga'] as num).toDouble(),
      repeticoes: json['repeticoes'] as int? ?? 12,
    );
  }

  final String exercicioId;
  final DateTime data;
  final double carga;
  final int repeticoes;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'exercicioId': exercicioId,
        'data': data.toIso8601String(),
        'carga': carga,
        'repeticoes': repeticoes,
      };
}

/// Medida corporal registrada no perfil (tela 20).
class MedidaCorporal {
  const MedidaCorporal({
    required this.nome,
    required this.valor,
    required this.unidade,
    this.variacao = 0,
  });

  final String nome;
  final double valor;
  final String unidade;

  /// Variacao em relacao a medida anterior (positivo = ganho).
  final double variacao;
}
