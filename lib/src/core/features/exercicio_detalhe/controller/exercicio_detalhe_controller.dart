import 'package:get/get.dart';

import '../../../../enum/grupo_muscular.dart';
import '../../../../models/exercicio.dart';
import '../../../../models/registro_carga.dart';
import '../../../../routes/route_args.dart';
import '../../../abstracts/log_service_interface.dart';
import '../abstracts/exercicio_detalhe_controller_interface.dart';
import '../abstracts/exercicio_detalhe_repository_interface.dart';

/// Controller da tela 19 — Detalhe do Exercicio.
class ExercicioDetalheController extends GetxController
    implements ExercicioDetalheControllerInterface {
  static Exercicio _exercicioInicial() {
    final Object? args = Get.arguments;
    if (args is ExercicioDetalheArgs) {
      return args.exercicio;
    }
    return const Exercicio(
      id: '',
      nome: '',
      grupoPrimario: GrupoMuscular.todos,
    );
  }

  final ExercicioDetalheRepositoryInterface _repository = Get.find();
  final LogServiceInterface _log = Get.find();

  @override
  final Rx<Exercicio> exercicio = Rx<Exercicio>(_exercicioInicial());

  @override
  final RxList<RegistroCarga> registros = <RegistroCarga>[].obs;

  @override
  final Rxn<RegistroCarga> recorde = Rxn<RegistroCarga>();

  @override
  final RxBool carregando = true.obs;

  @override
  void onInit() {
    super.onInit();
    if (exercicio.value.id.isEmpty) {
      carregando.value = false;
      return;
    }
    carregar();
  }

  @override
  Future<void> carregar() async {
    carregando.value = true;
    try {
      final String id = exercicio.value.id;
      final Exercicio? atualizado = await _repository.buscarExercicio(id);
      if (atualizado != null) {
        exercicio.value = atualizado;
      }
      registros.value = await _repository.registrosDeCarga(id);
      recorde.value = await _repository.recordePessoal(id);
      await _repository.registrarAcesso(id);
    } catch (e, s) {
      _log.error(
        'Falha ao carregar detalhe do exercicio',
        error: e,
        stackTrace: s,
      );
    } finally {
      carregando.value = false;
    }
  }

  @override
  Future<void> alternarFavorito() async {
    try {
      exercicio.value = await _repository.alternarFavorito(exercicio.value.id);
    } catch (e, s) {
      _log.error('Falha ao alternar favorito', error: e, stackTrace: s);
    }
  }
}
