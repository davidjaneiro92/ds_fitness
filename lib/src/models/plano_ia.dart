import '../core/utils/json_utils.dart';
import 'treino.dart';

/// Resposta do gerador de treino: as sessões da semana e a avaliação corporal
/// que explica como o IMC mudou o plano.
class PlanoIa {
  const PlanoIa({required this.treinos, required this.avaliacao});

  factory PlanoIa.fromJson(Map<String, dynamic> json) {
    final List<dynamic> treinos =
        json['treinos'] as List<dynamic>? ?? <dynamic>[];
    return PlanoIa(
      treinos: treinos
          .map((dynamic t) => Treino.fromJson(t as Map<String, dynamic>))
          .toList(),
      avaliacao: AvaliacaoCorporal.fromJson(
        json['avaliacao'] as Map<String, dynamic>?,
      ),
    );
  }

  final List<Treino> treinos;
  final AvaliacaoCorporal avaliacao;
}

/// IMC (nulo sem peso/altura), a faixa por extenso e o que o servidor ajustou
/// no treino por causa dela.
class AvaliacaoCorporal {
  const AvaliacaoCorporal({
    required this.classificacao,
    this.imc,
    this.ajustes = const <String>[],
  });

  factory AvaliacaoCorporal.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const AvaliacaoCorporal(classificacao: 'Não informado');
    }
    final Object? imc = json['imc'];
    return AvaliacaoCorporal(
      imc: imc == null ? null : JsonUtils.decimal(imc),
      classificacao: json['classificacao'] as String? ?? 'Não informado',
      ajustes: (json['ajustes'] as List<dynamic>? ?? <dynamic>[])
          .map((dynamic a) => a.toString())
          .toList(),
    );
  }

  final double? imc;
  final String classificacao;
  final List<String> ajustes;

  /// IMC = peso / altura². Altura em metros; aceita centímetros por engano.
  /// Nulo quando faltar peso ou altura.
  static double? calcularImc(double peso, double altura) {
    final double metros = altura > 3 ? altura / 100 : altura;
    if (peso <= 0 || metros <= 0) {
      return null;
    }
    return peso / (metros * metros);
  }

  /// Mesmas faixas da OMS usadas pelo servidor, para o retorno imediato na
  /// tela de dados. Quem decide os ajustes do treino é o servidor.
  static String classificar(double imc) {
    if (imc < 18.5) return 'Abaixo do peso';
    if (imc < 25) return 'Peso normal';
    if (imc < 30) return 'Sobrepeso';
    if (imc < 35) return 'Obesidade grau I';
    if (imc < 40) return 'Obesidade grau II';
    return 'Obesidade grau III';
  }
}
