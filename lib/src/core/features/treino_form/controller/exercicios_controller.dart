import 'dart:async';

import 'package:get/get.dart';

import '../../../../components/feedback/app_snackbar.dart';
import '../../../../enum/grupo_muscular.dart';
import '../../../../models/exercicio.dart';
import '../../../../models/treino_exercicio.dart';
import '../../../abstracts/log_service_interface.dart';
import '../../../utils/error_messages.dart';
import '../../../utils/texto_utils.dart';
import '../abstracts/exercicios_controller_interface.dart';
import '../abstracts/treino_form_controller_interface.dart';
import '../abstracts/treino_form_repository_interface.dart';

/// Controller da escolha de exercicio: traz o catalogo uma vez e mostra os
/// exercicios dos grupos que o usuario selecionou, com busca local por nome.
///
/// Entram so os exercicios cujo grupo **primario** foi selecionado: quem monta
/// um treino de peito e triceps quer os exercicios de peito e de triceps, e nao
/// todo supino so porque o triceps ajuda.
class ExerciciosController extends GetxController
    implements ExerciciosControllerInterface {
  final TreinoFormRepositoryInterface _repository = Get.find();
  final TreinoFormControllerInterface _treinoForm = Get.find();
  final LogServiceInterface _log = Get.find();

  @override
  final RxList<Exercicio> exercicios = <Exercicio>[].obs;

  @override
  final RxString busca = ''.obs;

  @override
  final RxBool carregando = true.obs;

  @override
  void onInit() {
    super.onInit();
    unawaited(carregar());
  }

  @override
  Future<void> carregar() async {
    carregando.value = true;
    try {
      exercicios.assignAll(await _repository.listarExercicios());
    } catch (erro, stackTrace) {
      _log.error(
        'Falha ao carregar exercicios',
        error: erro,
        stackTrace: stackTrace,
      );
      AppSnackbar.erro(ErrorMessages.de(erro));
    } finally {
      carregando.value = false;
    }
  }

  @override
  List<Exercicio> get filtrados {
    final Set<GrupoMuscular> grupos = _treinoForm.gruposSelecionados;
    return exercicios.where((Exercicio e) {
      final bool doGrupo = grupos.isEmpty || grupos.contains(e.grupoPrimario);
      return doGrupo && TextoUtils.contem(e.nome, busca.value);
    }).toList();
  }

  @override
  Set<String> get adicionadosIds => _treinoForm.exercicios
      .map((TreinoExercicio e) => e.exercicioId)
      .toSet();

  @override
  void buscar(String texto) => busca.value = texto;
}
