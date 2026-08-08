import 'dart:async';

import 'package:get/get.dart';

import '../../../../enum/objetivo_treino.dart';
import '../../../../models/exercicio.dart';
import '../../../../models/treino.dart';
import '../../../../models/treino_exercicio.dart';
import '../../../../routes/route_args.dart';
import '../../../abstracts/log_service_interface.dart';
import '../../../abstracts/mock_database_interface.dart';
import '../abstracts/treino_form_controller_interface.dart';
import '../abstracts/treino_form_repository_interface.dart';

/// Estado compartilhado do fluxo de criacao/edicao de treino.
///
/// Instancia unica e permanente (`Get.put(..., permanent: true)` em
/// `TreinoFormBinding`) que sobrevive a navegacao interna do fluxo
/// (`/treinos/novo|editar → /grupos → /exercicios → sheet`). E descartada
/// explicitamente por [encerrar] ao sair do fluxo.
class TreinoFormController extends GetxController
    implements TreinoFormControllerInterface {
  final TreinoFormRepositoryInterface _repository = Get.find();
  final MockDatabaseInterface _db = Get.find();
  final LogServiceInterface _log = Get.find();

  @override
  final RxBool carregando = false.obs;

  @override
  final RxString nome = ''.obs;

  @override
  final Rx<ObjetivoTreino> objetivo = ObjetivoTreino.hipertrofia.obs;

  @override
  final RxString descricao = ''.obs;

  @override
  final RxList<TreinoExercicio> exercicios = <TreinoExercicio>[].obs;

  String? _treinoIdAtual;

  @override
  void onInit() {
    super.onInit();
    final Object? args = Get.arguments;
    unawaited(_carregar(args is TreinoFormArgs ? args : null));
  }

  Future<void> _carregar(TreinoFormArgs? args) async {
    _treinoIdAtual = args?.treinoId;
    if (args?.treinoId == null) {
      nome.value = '';
      objetivo.value = ObjetivoTreino.hipertrofia;
      descricao.value = '';
      exercicios.assignAll(<TreinoExercicio>[]);
      return;
    }

    carregando.value = true;
    try {
      final Treino? treino = await _repository.obterTreino(args!.treinoId!);
      if (treino == null) {
        _log.warning('Treino nao encontrado', error: args.treinoId);
        return;
      }
      nome.value = treino.nome;
      objetivo.value = treino.objetivo;
      descricao.value = treino.descricao;
      exercicios.assignAll(treino.exercicios);
    } finally {
      carregando.value = false;
    }
  }

  @override
  bool get podeSalvar => nome.value.trim().isNotEmpty && exercicios.isNotEmpty;

  @override
  bool jaAdicionado(String exercicioId) =>
      exercicios.any((TreinoExercicio e) => e.exercicioId == exercicioId);

  @override
  void adicionarExercicio(
    Exercicio exercicio, {
    required int series,
    required int repeticoes,
    required double carga,
    required int descansoSeg,
    String observacao = '',
  }) {
    final TreinoExercicio item = TreinoExercicio(
      id: _db.novoId('te'),
      exercicio: exercicio,
      ordem: exercicios.length,
      series: series,
      repeticoes: repeticoes,
      cargaInicial: carga,
      descansoSeg: descansoSeg,
      observacao: observacao,
    );
    exercicios.add(item);
  }

  @override
  void atualizarExercicio(
    TreinoExercicio item, {
    required int series,
    required int repeticoes,
    required double carga,
    required int descansoSeg,
    String observacao = '',
  }) {
    final int indice =
        exercicios.indexWhere((TreinoExercicio e) => e.id == item.id);
    if (indice == -1) {
      return;
    }
    exercicios[indice] = item.copyWith(
      series: series,
      repeticoes: repeticoes,
      cargaInicial: carga,
      descansoSeg: descansoSeg,
      observacao: observacao,
    );
  }

  @override
  void removerExercicio(String treinoExercicioId) {
    exercicios.removeWhere((TreinoExercicio e) => e.id == treinoExercicioId);
    _reordenarSequencial();
  }

  @override
  void reordenar(int oldIndex, int newIndex) {
    int destino = newIndex;
    if (oldIndex < newIndex) {
      destino -= 1;
    }
    final TreinoExercicio item = exercicios.removeAt(oldIndex);
    exercicios.insert(destino, item);
    _reordenarSequencial();
  }

  void _reordenarSequencial() {
    final List<TreinoExercicio> atualizados = <TreinoExercicio>[
      for (int i = 0; i < exercicios.length; i++)
        exercicios[i].copyWith(ordem: i),
    ];
    exercicios.assignAll(atualizados);
  }

  @override
  Future<bool> salvar() async {
    if (!podeSalvar) {
      return false;
    }
    final String id = _treinoIdAtual ?? _db.novoId('t');
    final Treino treino = Treino(
      id: id,
      nome: nome.value.trim(),
      objetivo: objetivo.value,
      descricao: descricao.value.trim(),
      exercicios: exercicios.toList(),
    );
    try {
      final Treino salvo = await _repository.salvar(treino);
      _treinoIdAtual = salvo.id;
      return true;
    } catch (erro, stackTrace) {
      _log.error('Falha ao salvar treino', error: erro, stackTrace: stackTrace);
      return false;
    }
  }

  @override
  void encerrar() {
    Get.delete<TreinoFormControllerInterface>(force: true);
  }
}
