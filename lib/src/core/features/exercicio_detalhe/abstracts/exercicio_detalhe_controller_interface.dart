import 'package:get/get.dart';

import '../../../../models/exercicio.dart';
import '../../../../models/registro_carga.dart';

/// Contrato do controller da tela 19 — Detalhe do Exercicio.
abstract class ExercicioDetalheControllerInterface {
  Rx<Exercicio> get exercicio;

  RxList<RegistroCarga> get registros;

  Rxn<RegistroCarga> get recorde;

  RxBool get carregando;

  Future<void> carregar();

  Future<void> alternarFavorito();

  /// Abre o formulario de edicao (so para exercicio criado pelo usuario) e
  /// atualiza a tela quando ele volta. Se o exercicio foi excluido, fecha
  /// esta tela tambem.
  Future<void> editar();
}
