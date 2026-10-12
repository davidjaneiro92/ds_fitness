import 'package:get/get.dart';

import '../../../../models/usuario.dart';

/// Contrato do controller da Home: a saudacao e as duas escolhas — montar um
/// treino ou treinar.
abstract class HomeControllerInterface {
  /// O usuario logado (o mesmo do `AuthController`).
  Rx<Usuario> get usuario;

  /// Abre o fluxo de montar um treino novo.
  void montarTreino();

  /// Abre a lista de treinos, de onde se inicia um.
  void treinar();
}
