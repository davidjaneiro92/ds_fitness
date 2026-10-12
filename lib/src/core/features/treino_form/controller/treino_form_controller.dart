import 'dart:async';

import 'package:get/get.dart';

import '../../../../components/feedback/app_snackbar.dart';
import '../../../../enum/dia_semana.dart';
import '../../../../enum/grupo_muscular.dart';
import '../../../../enum/objetivo_treino.dart';
import '../../../../models/exercicio.dart';
import '../../../../models/treino.dart';
import '../../../../models/treino_exercicio.dart';
import '../../../../routes/route_args.dart';
import '../../../abstracts/log_service_interface.dart';
import '../../../utils/error_messages.dart';
import '../abstracts/treino_form_controller_interface.dart';
import '../abstracts/treino_form_repository_interface.dart';

/// Estado compartilhado do fluxo de montar um treino (ver a interface para os
/// passos).
///
/// Instancia unica e permanente (`Get.put(..., permanent: true)` em
/// `TreinoFormBinding`) que sobrevive a navegacao entre os passos. E descartada
/// explicitamente por [encerrar] ao sair do fluxo.
class TreinoFormController extends GetxController
    implements TreinoFormControllerInterface {
  final TreinoFormRepositoryInterface _repository = Get.find();
  final LogServiceInterface _log = Get.find();

  @override
  final RxBool carregando = false.obs;

  @override
  final RxBool salvando = false.obs;

  @override
  final Rxn<DiaSemana> dia = Rxn<DiaSemana>();

  @override
  final RxString nome = ''.obs;

  @override
  final Rx<ObjetivoTreino> objetivo = ObjetivoTreino.hipertrofia.obs;

  @override
  final RxString descricao = ''.obs;

  @override
  final RxList<TreinoExercicio> exercicios = <TreinoExercicio>[].obs;

  @override
  final RxSet<GrupoMuscular> gruposSelecionados = <GrupoMuscular>{}.obs;

  @override
  final Rxn<Exercicio> exercicioEscolhido = Rxn<Exercicio>();

  @override
  final RxInt series = TreinoFormControllerInterface.seriesPadrao.obs;

  @override
  final RxInt repeticoes = TreinoFormControllerInterface.repeticoesPadrao.obs;

  @override
  final RxInt descansoSeg = TreinoFormControllerInterface.descansoPadraoSeg.obs;

  String? _treinoIdAtual;

  bool _partiuDaLista = false;

  /// O item que a tela de configurar esta editando; `null` ao acrescentar.
  TreinoExercicio? _itemEmEdicao;

  /// Estado do formulario no ultimo carregamento ou salvamento (ou o rascunho
  /// vazio, num treino novo). Abrir um treino e sair sem editar nada nao
  /// precisa de uma ida ao servidor, e sair de um rascunho vazio nao precisa de
  /// confirmacao.
  String _estadoSalvo = '';

  /// Itens recem-adicionados ainda nao tem id do servidor: recebem um id local
  /// (`novo_N`), que o repository reconhece como "criar" ao salvar.
  int _proximoIdLocal = 1;

  @override
  void onInit() {
    super.onInit();
    final Object? args = Get.arguments;
    unawaited(_carregar(args is TreinoFormArgs ? args : null));
  }

  Future<void> _carregar(TreinoFormArgs? args) async {
    _treinoIdAtual = args?.treinoId;
    _partiuDaLista = args?.partiuDaLista ?? false;
    if (args?.treinoId == null) {
      dia.value = DiaSemana.hoje();
      _estadoSalvo = _estadoAtual();
      return;
    }

    carregando.value = true;
    try {
      final Treino? treino = await _repository.obterTreino(args!.treinoId!);
      if (treino == null) {
        _log.warning('Treino nao encontrado', error: args.treinoId);
        return;
      }
      dia.value = treino.dia;
      nome.value = treino.nome;
      objetivo.value = treino.objetivo;
      descricao.value = treino.descricao;
      exercicios.assignAll(treino.exercicios);
      gruposSelecionados
        ..clear()
        ..addAll(treino.grupos);
      _estadoSalvo = _estadoAtual();
    } catch (erro, stackTrace) {
      _log.error('Falha ao carregar treino', error: erro, stackTrace: stackTrace);
      AppSnackbar.erro(ErrorMessages.de(erro));
    } finally {
      carregando.value = false;
    }
  }

  // ---- Passo 1 ------------------------------------------------------------

  @override
  bool get podeContinuar => nome.value.trim().isNotEmpty;

  @override
  void escolherDia(DiaSemana novo) => dia.value = novo;

  // ---- Passo 2 ------------------------------------------------------------

  @override
  void alternarGrupo(GrupoMuscular grupo) {
    if (!gruposSelecionados.remove(grupo)) {
      gruposSelecionados.add(grupo);
    }
  }

  // ---- Passos 3 e 4 -------------------------------------------------------

  @override
  bool get editandoItem => _itemEmEdicao != null;

  @override
  bool jaAdicionado(String exercicioId) =>
      exercicios.any((TreinoExercicio e) => e.exercicioId == exercicioId);

  @override
  void escolherExercicio(Exercicio exercicio) {
    if (jaAdicionado(exercicio.id)) {
      return;
    }
    exercicioEscolhido.value = exercicio;
  }

  @override
  void iniciarAdicao() {
    _itemEmEdicao = null;
    exercicioEscolhido.value = null;
    series.value = TreinoFormControllerInterface.seriesPadrao;
    repeticoes.value = TreinoFormControllerInterface.repeticoesPadrao;
    descansoSeg.value = TreinoFormControllerInterface.descansoPadraoSeg;
  }

  @override
  void iniciarEdicaoDe(TreinoExercicio item) {
    _itemEmEdicao = item;
    exercicioEscolhido.value = item.exercicio;
    series.value = item.series;
    repeticoes.value = item.repeticoes;
    descansoSeg.value = item.descansoSeg;
  }

  @override
  void confirmarConfiguracao() {
    final TreinoExercicio? emEdicao = _itemEmEdicao;
    if (emEdicao != null) {
      final int indice =
          exercicios.indexWhere((TreinoExercicio e) => e.id == emEdicao.id);
      if (indice != -1) {
        // A carga e a observacao do item ficam como estavam: so a configuracao
        // da tela muda.
        exercicios[indice] = exercicios[indice].copyWith(
          series: series.value,
          repeticoes: repeticoes.value,
          descansoSeg: descansoSeg.value,
        );
      }
    } else {
      final Exercicio? escolhido = exercicioEscolhido.value;
      if (escolhido == null || jaAdicionado(escolhido.id)) {
        return;
      }
      exercicios.add(
        TreinoExercicio(
          id: 'novo_${_proximoIdLocal++}',
          exercicio: escolhido,
          ordem: exercicios.length,
          series: series.value,
          repeticoes: repeticoes.value,
          cargaInicial: 0,
          descansoSeg: descansoSeg.value,
        ),
      );
    }
    // A escolha fica como esta ate o proximo `iniciarAdicao`: a tela de
    // configurar ainda esta visivel durante a transicao e nao pode piscar para
    // "nenhum exercicio selecionado". Confirmar duas vezes tambem e inofensivo
    // — o exercicio so entra uma vez.
  }

  // ---- Passo 5 ------------------------------------------------------------

  @override
  bool get existente => _treinoIdAtual != null;

  @override
  String? get treinoId => _treinoIdAtual;

  @override
  bool get partiuDaLista => _partiuDaLista;

  @override
  String get titulo {
    final String nomeTreino = nome.value.trim();
    final DiaSemana? diaEscolhido = dia.value;
    return diaEscolhido == null ? nomeTreino : '$nomeTreino • ${diaEscolhido.nome}';
  }

  @override
  bool get podeSalvar => nome.value.trim().isNotEmpty && exercicios.isNotEmpty;

  @override
  bool get alterado => _estadoAtual() != _estadoSalvo;

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

  /// Resumo do que o formulario guarda, para saber se mudou desde o ultimo
  /// carregamento ou salvamento.
  String _estadoAtual() {
    return <String>[
      '${dia.value?.numero}',
      nome.value.trim(),
      objetivo.value.name,
      descricao.value.trim(),
      for (final TreinoExercicio item in exercicios)
        '${item.id}|${item.exercicioId}|${item.ordem}|${item.series}|'
            '${item.repeticoes}|${item.cargaInicial}|${item.descansoSeg}|'
            '${item.observacao}',
    ].join('\n');
  }

  @override
  Future<bool> salvar() async {
    if (!podeSalvar || salvando.value) {
      return false;
    }
    if (existente && !alterado) {
      return true;
    }
    salvando.value = true;
    try {
      final Treino treino = Treino(
        id: _treinoIdAtual ?? '',
        nome: nome.value.trim(),
        objetivo: objetivo.value,
        descricao: descricao.value.trim(),
        exercicios: exercicios.toList(),
        diaSemana: dia.value?.numero,
      );
      final Treino salvo = await _repository.salvar(treino);
      _treinoIdAtual = salvo.id;
      // Troca os ids locais pelos do servidor: salvar de novo atualiza os
      // itens existentes em vez de criar copias.
      exercicios.assignAll(salvo.exercicios);
      _estadoSalvo = _estadoAtual();
      return true;
    } catch (erro, stackTrace) {
      _log.error('Falha ao salvar treino', error: erro, stackTrace: stackTrace);
      AppSnackbar.erro(ErrorMessages.de(erro));
      return false;
    } finally {
      salvando.value = false;
    }
  }

  @override
  void encerrar() {
    Get.delete<TreinoFormControllerInterface>(force: true);
  }
}
