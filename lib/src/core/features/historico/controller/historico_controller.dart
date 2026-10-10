import 'package:get/get.dart';

import '../../../../components/feedback/app_snackbar.dart';
import '../../../../core/abstracts/log_service_interface.dart';
import '../../../../enum/periodo_estatistica.dart';
import '../../../../models/sessao.dart';
import '../../../utils/error_messages.dart';
import '../abstracts/historico_controller_interface.dart';
import '../abstracts/historico_repository_interface.dart';

/// Controller da tela de historico (tela 16) — sessoes paginadas e resumo
/// por exercicio.
class HistoricoController extends GetxController
    implements HistoricoControllerInterface {
  final HistoricoRepositoryInterface _repository = Get.find();
  final LogServiceInterface _log = Get.find();

  static const int _porPagina = 20;

  @override
  final RxList<Sessao> sessoes = <Sessao>[].obs;
  @override
  final RxBool carregando = true.obs;
  @override
  final RxBool carregandoMais = false.obs;
  @override
  final RxBool temMais = true.obs;
  @override
  final Rx<HistoricoFiltro> filtro = HistoricoFiltro.todos.obs;
  @override
  final RxList<ResumoExercicio> resumoExercicios = <ResumoExercicio>[].obs;

  int _pagina = 1;

  @override
  void onInit() {
    super.onInit();
    carregar();
  }

  @override
  Future<void> carregar() async {
    carregando.value = true;
    _pagina = 1;
    temMais.value = true;
    try {
      if (filtro.value == HistoricoFiltro.exercicios) {
        resumoExercicios.value = await _repository.obterResumoExercicios();
      } else {
        final List<Sessao> pagina = await _repository.obterSessoes(
          pagina: _pagina,
          porPagina: _porPagina,
        );
        sessoes.value = pagina;
        temMais.value = pagina.length == _porPagina;
      }
    } catch (e, s) {
      _log.error('Erro ao carregar historico', error: e, stackTrace: s);
      AppSnackbar.erro(ErrorMessages.de(e));
    } finally {
      carregando.value = false;
    }
  }

  @override
  Future<void> carregarMais() async {
    if (carregandoMais.value ||
        !temMais.value ||
        filtro.value == HistoricoFiltro.exercicios) {
      return;
    }
    carregandoMais.value = true;
    try {
      final int proximaPagina = _pagina + 1;
      final List<Sessao> pagina = await _repository.obterSessoes(
        pagina: proximaPagina,
        porPagina: _porPagina,
      );
      sessoes.addAll(pagina);
      _pagina = proximaPagina;
      temMais.value = pagina.length == _porPagina;
    } catch (e, s) {
      _log.error('Erro ao carregar mais sessoes', error: e, stackTrace: s);
      AppSnackbar.erro(ErrorMessages.de(e));
    } finally {
      carregandoMais.value = false;
    }
  }

  @override
  void trocarFiltro(HistoricoFiltro novo) {
    if (filtro.value == novo) {
      return;
    }
    filtro.value = novo;
    carregar();
  }
}
