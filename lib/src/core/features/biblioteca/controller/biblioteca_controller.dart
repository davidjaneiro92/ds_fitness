import 'package:get/get.dart';

import '../../../../enum/grupo_muscular.dart';
import '../../../../enum/pages_routes.dart';
import '../../../../enum/periodo_estatistica.dart';
import '../../../../models/exercicio.dart';
import '../../../../routes/route_args.dart';
import '../../../abstracts/log_service_interface.dart';
import '../abstracts/biblioteca_controller_interface.dart';
import '../abstracts/biblioteca_repository_interface.dart';

/// Controller da tela 18 — Biblioteca de Exercicios.
class BibliotecaController extends GetxController
    implements BibliotecaControllerInterface {
  final BibliotecaRepositoryInterface _repository = Get.find();
  final LogServiceInterface _log = Get.find();

  /// Ids na ordem de acesso mais recente, usados pelo filtro "Recentes".
  final List<String> _recentesIds = <String>[];

  @override
  final RxList<Exercicio> exercicios = <Exercicio>[].obs;

  @override
  final RxString busca = ''.obs;

  @override
  final Rx<BibliotecaFiltro> filtro = BibliotecaFiltro.todos.obs;

  @override
  final Rxn<GrupoMuscular> grupoFiltro = Rxn<GrupoMuscular>();

  @override
  final RxBool carregando = true.obs;

  @override
  void onInit() {
    super.onInit();
    carregar();
  }

  @override
  Future<void> carregar() async {
    carregando.value = true;
    try {
      final List<Exercicio> lista = await _repository.listarExercicios();
      final List<Exercicio> recentes = await _repository.listarRecentes();
      exercicios.value = lista;
      _recentesIds
        ..clear()
        ..addAll(recentes.map((Exercicio e) => e.id));
    } catch (e, s) {
      _log.error(
        'Falha ao carregar biblioteca de exercicios',
        error: e,
        stackTrace: s,
      );
    } finally {
      carregando.value = false;
    }
  }

  @override
  List<Exercicio> get filtrados {
    List<Exercicio> base = List<Exercicio>.of(exercicios);

    switch (filtro.value) {
      case BibliotecaFiltro.favoritos:
        base = base.where((Exercicio e) => e.favorito).toList();
      case BibliotecaFiltro.recentes:
        final List<String> ordem = _recentesIds;
        base = base.where((Exercicio e) => ordem.contains(e.id)).toList()
          ..sort(
            (Exercicio a, Exercicio b) =>
                ordem.indexOf(a.id).compareTo(ordem.indexOf(b.id)),
          );
      case BibliotecaFiltro.todos:
        break;
    }

    final GrupoMuscular? grupo = grupoFiltro.value;
    if (grupo != null && grupo != GrupoMuscular.todos) {
      base =
          base.where((Exercicio e) => e.todosGrupos.contains(grupo)).toList();
    }

    final String termo = busca.value.trim().toLowerCase();
    if (termo.isNotEmpty) {
      base = base
          .where((Exercicio e) => e.nome.toLowerCase().contains(termo))
          .toList();
    }

    return base;
  }

  @override
  void buscar(String termo) {
    busca.value = termo;
  }

  @override
  void selecionarFiltro(BibliotecaFiltro novo) {
    filtro.value = novo;
  }

  @override
  void selecionarGrupo(GrupoMuscular? grupo) {
    grupoFiltro.value = grupo;
  }

  @override
  Future<void> alternarFavorito(String id) async {
    try {
      final Exercicio atualizado = await _repository.alternarFavorito(id);
      final int index = exercicios.indexWhere((Exercicio e) => e.id == id);
      if (index != -1) {
        exercicios[index] = atualizado;
      }
    } catch (e, s) {
      _log.error('Falha ao alternar favorito', error: e, stackTrace: s);
    }
  }

  @override
  void abrirDetalhe(Exercicio exercicio) {
    _repository.registrarAcesso(exercicio.id);
    Get.toNamed<void>(
      PagesRoutes.exercicioDetalhe.path,
      arguments: ExercicioDetalheArgs(exercicio: exercicio),
    );
  }
}
