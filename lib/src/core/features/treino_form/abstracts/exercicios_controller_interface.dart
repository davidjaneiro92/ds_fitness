import 'package:get/get.dart';

import '../../../../models/exercicio.dart';

/// Contrato do controller da escolha de exercicio: os exercicios dos grupos
/// musculares selecionados, com busca por nome.
abstract class ExerciciosControllerInterface {
  RxList<Exercicio> get exercicios;

  RxString get busca;

  RxBool get carregando;

  /// Os exercicios cujo grupo primario esta entre os selecionados, filtrados
  /// pelo texto de [busca] (sem diferenciar caixa nem acento).
  List<Exercicio> get filtrados;

  /// Ids dos exercicios que ja estao no treino.
  Set<String> get adicionadosIds;

  Future<void> carregar();

  void buscar(String texto);
}
