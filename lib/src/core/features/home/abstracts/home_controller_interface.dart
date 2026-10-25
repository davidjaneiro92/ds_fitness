import 'package:get/get.dart';

import '../../../../models/usuario.dart';

/// Contrato do controller da Home: saudacao e atalhos de treino.
abstract class HomeControllerInterface {
  /// O usuario logado (o mesmo do `AuthController`).
  Rx<Usuario> get usuario;

  /// Abre o fluxo de montar um treino novo.
  void montarTreino();

  /// Abre o gerador de treino por preferencias.
  void montarTreinoIa();

  /// Abre a lista de treinos, de onde se inicia um.
  void treinar();
}
