import 'package:get/get.dart';

import '../../../../models/treino.dart';

/// Contrato do controller de Meus Treinos (planejamento §5).
abstract class TreinosControllerInterface {
  RxList<Treino> get treinos;

  RxBool get carregando;

  Rxn<Treino> get treinoDoDia;

  Future<void> carregar();

  Future<void> duplicar(String id);

  Future<void> excluir(String id);
}
