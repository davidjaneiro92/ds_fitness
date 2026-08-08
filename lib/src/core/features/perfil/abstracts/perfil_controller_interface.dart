import 'package:get/get.dart';

import '../../../../enum/objetivo_treino.dart';
import '../../../../models/registro_carga.dart';
import '../../../../models/usuario.dart';

/// Contrato do controller da tela 20 — Perfil.
abstract class PerfilControllerInterface {
  Rx<Usuario> get usuario;

  RxList<MedidaCorporal> get medidas;

  RxBool get carregando;

  Future<void> carregar();

  Future<void> salvarObjetivo(ObjetivoTreino objetivo);

  Future<void> sair();
}
