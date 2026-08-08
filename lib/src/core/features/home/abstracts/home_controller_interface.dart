import 'package:get/get.dart';

import '../../../../models/treino.dart';
import '../../../../models/usuario.dart';

/// Contrato do controller da Home (planejamento §4).
abstract class HomeControllerInterface {
  RxBool get carregando;

  Rxn<Treino> get treinoDoDia;

  RxInt get treinosNaSemana;

  RxInt get metaSemanal;

  Rx<Usuario> get usuario;

  Future<void> carregar();

  void iniciarTreino();
}
