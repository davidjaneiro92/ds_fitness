import 'dart:async';

import 'package:get/get.dart';

import '../../../../enum/grupo_muscular.dart';
import '../../../../models/exercicio.dart';
import '../../../../models/treino_exercicio.dart';
import '../../../../routes/route_args.dart';
import '../../../abstracts/log_service_interface.dart';
import '../abstracts/exercicios_controller_interface.dart';
import '../abstracts/treino_form_controller_interface.dart';
import '../abstracts/treino_form_repository_interface.dart';

/// Controller da tela 8: catalogo de exercicios de um grupo muscular, com
/// busca local e marcacao dos exercicios ja adicionados ao treino em edicao.
class ExerciciosController extends GetxController
    implements ExerciciosControllerInterface {
  final TreinoFormRepositoryInterface _repository = Get.find();
  final TreinoFormControllerInterface _treinoForm = Get.find();
  final LogServiceInterface _log = Get.find();

  late final GrupoMuscular _grupo;

  @override
  final RxList<Exercicio> exercicios = <Exercicio>[].obs;

  @override
  final RxString busca = ''.obs;

  @override
  final RxBool carregando = true.obs;

  @override
  GrupoMuscular get grupo => _grupo;

  @override
  void onInit() {
    super.onInit();
    final Object? args = Get.arguments;
    _grupo = args is ExerciciosArgs ? args.grupo : GrupoMuscular.todos;
    unawaited(_carregar());
  }

  Future<void> _carregar() async {
    carregando.value = true;
    try {
      final List<Exercicio> lista = await _repository.exerciciosPorGrupo(_grupo);
      exercicios.assignAll(lista);
    } catch (erro, stackTrace) {
      _log.error(
        'Falha ao carregar exercicios do grupo',
        error: erro,
        stackTrace: stackTrace,
      );
    } finally {
      carregando.value = false;
    }
  }

  @override
  List<Exercicio> get filtrados {
    final String termo = busca.value.trim().toLowerCase();
    if (termo.isEmpty) {
      return exercicios;
    }
    return exercicios
        .where((Exercicio e) => e.nome.toLowerCase().contains(termo))
        .toList();
  }

  @override
  Set<String> get adicionadosIds => _treinoForm.exercicios
      .map((TreinoExercicio e) => e.exercicioId)
      .toSet();

  @override
  void buscar(String texto) => busca.value = texto;
}
