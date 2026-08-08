import 'package:get/get.dart';

import '../../../../enum/grupo_muscular.dart';
import '../../../../models/exercicio.dart';

/// Contrato do controller da tela 8 (lista de exercicios de um grupo).
abstract class ExerciciosControllerInterface {
  /// Grupo muscular selecionado na tela anterior (`ExerciciosArgs`).
  GrupoMuscular get grupo;

  RxList<Exercicio> get exercicios;

  RxString get busca;

  RxBool get carregando;

  /// Catalogo do grupo atual filtrado pelo texto de [busca].
  List<Exercicio> get filtrados;

  /// Ids dos exercicios ja adicionados ao treino em edicao.
  Set<String> get adicionadosIds;

  void buscar(String texto);
}
