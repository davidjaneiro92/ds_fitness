import 'dart:async';

import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../components/feedback/app_snackbar.dart';
import '../../../../core/abstracts/log_service_interface.dart';
import '../../../../core/abstracts/storage_service_interface.dart';
import '../../../../enum/execucao_state.dart';
import '../../../../models/registro_carga.dart';
import '../../../../models/serie_executada.dart';
import '../../../../models/treino.dart';
import '../../../../models/treino_exercicio.dart';
import '../../../../routes/route_args.dart';
import '../../../utils/error_messages.dart';
import '../abstracts/execucao_controller_interface.dart';
import '../abstracts/execucao_repository_interface.dart';
import 'commands/alterar_carga_command.dart';
import 'commands/concluir_serie_command.dart';
import 'commands/finalizar_treino_command.dart';

/// Controller da execucao de treino — maquina de estados, cronometros e
/// orquestracao dos commands (planejamento §4 e §6).
class ExecucaoController extends GetxController
    implements ExecucaoControllerInterface {
  final ExecucaoRepositoryInterface _repository = Get.find();
  final LogServiceInterface _log = Get.find();
  final StorageServiceInterface _storage = Get.find();

  @override
  final Rx<ExecucaoState> estado = ExecucaoState.carregando.obs;

  @override
  final Rxn<Treino> treino = Rxn<Treino>();

  @override
  final RxInt indiceExercicio = 0.obs;

  @override
  final RxInt serieAtual = 1.obs;

  @override
  final RxInt segundosTreino = 0.obs;

  @override
  final RxInt segundosDescanso = 0.obs;

  @override
  final RxInt descansoTotal = 0.obs;

  @override
  final RxBool descansoPausado = false.obs;

  @override
  final RxList<SerieExecutada> seriesExecutadas = <SerieExecutada>[].obs;

  /// Carga atual por exercicio (id -> kg). Comeca com `cargaInicial` de
  /// cada [TreinoExercicio] e e sobrescrita por [alterarCarga].
  final RxMap<String, double> _cargas = <String, double>{}.obs;

  int _tempoDescansoTotal = 0;

  /// Observacao registrada antes de concluir a primeira serie do exercicio —
  /// aplicada na proxima serie concluida (ver [registrarObservacao]).
  String _observacaoPendente = '';
  int _dificuldadePendente = 0;

  Timer? _timerTreino;
  Timer? _timerDescanso;
  Timer? _timerSerieConcluida;
  Timer? _timerProximaSerie;

  @override
  TreinoExercicio? get exercicioAtual {
    final Treino? t = treino.value;
    if (t == null ||
        indiceExercicio.value < 0 ||
        indiceExercicio.value >= t.exercicios.length) {
      return null;
    }
    return t.exercicios[indiceExercicio.value];
  }

  @override
  int get totalSeries => exercicioAtual?.series ?? 0;

  @override
  double get cargaAtual {
    final TreinoExercicio? atual = exercicioAtual;
    if (atual == null) {
      return 0;
    }
    return _cargas[atual.exercicioId] ?? atual.cargaInicial;
  }

  @override
  void onInit() {
    super.onInit();
    final dynamic args = Get.arguments;
    if (args is ExecucaoArgs) {
      unawaited(
        carregarTreino(
          args.treinoId,
          indiceInicial: args.indiceExercicio,
        ),
      );
    } else {
      _log.warning('ExecucaoView aberta sem ExecucaoArgs valido');
    }
  }

  @override
  void onClose() {
    _cancelarTimers();
    super.onClose();
  }

  /// Carrega o treino pelo id e inicia a execucao no primeiro exercicio.
  Future<void> carregarTreino(
    String treinoId, {
    int indiceInicial = 0,
  }) async {
    estado.value = ExecucaoState.carregando;
    try {
      final Treino? carregado = await _repository.obterTreino(treinoId);
      treino.value = carregado;
      if (carregado == null) {
        _log.warning('Treino nao encontrado para execucao', error: treinoId);
        return;
      }
      _cargas.addEntries(
        carregado.exercicios.map(
          (TreinoExercicio te) =>
              MapEntry<String, double>(te.exercicioId, te.cargaInicial),
        ),
      );
      await _usarUltimasCargas(carregado);
      indiceExercicio.value = carregado.exercicios.isEmpty
          ? 0
          : indiceInicial.clamp(0, carregado.exercicios.length - 1).toInt();
      serieAtual.value = 1;
      _retomarSnapshot(carregado);
      estado.value = ExecucaoState.exercicio;
      _iniciarTimerTreino();
    } catch (erro, stackTrace) {
      _log.error('Falha ao carregar treino para execucao',
          error: erro, stackTrace: stackTrace);
      AppSnackbar.erro(ErrorMessages.de(erro));
    }
  }

  /// O treino montado no app nao guarda carga (ela se define na execucao): cada
  /// exercicio sem carga comeca na ultima que o usuario usou nele, e nao em
  /// zero. Nao conseguir buscar so deixa o exercicio em zero, como num exercicio
  /// que nunca foi feito.
  Future<void> _usarUltimasCargas(Treino carregado) async {
    final List<TreinoExercicio> semCarga = carregado.exercicios
        .where((TreinoExercicio te) => te.cargaInicial <= 0)
        .toList();
    await Future.wait(
      semCarga.map((TreinoExercicio item) async {
        try {
          final List<RegistroCarga> registros =
              await _repository.registrosDeCarga(item.exercicioId);
          if (registros.isNotEmpty && registros.last.carga > 0) {
            _cargas[item.exercicioId] = registros.last.carga;
          }
        } catch (erro) {
          _log.warning('Nao foi possivel buscar a ultima carga', error: erro);
        }
      }),
    );
  }

  @override
  Future<void> concluirSerie() async {
    final TreinoExercicio? atual = exercicioAtual;
    if (atual == null || estado.value != ExecucaoState.exercicio) {
      return;
    }
    final ConcluirSerieCommand command = ConcluirSerieCommand(
      treinoExercicio: atual,
      numeroSerie: serieAtual.value,
      totalSeries: totalSeries,
      carga: cargaAtual,
      seriesExecutadas: seriesExecutadas,
      estado: estado,
      descansoTotal: descansoTotal,
      segundosDescanso: segundosDescanso,
    );
    await command.execute();
    _aplicarObservacaoPendente();
    await _salvarSnapshot();

    if (estado.value == ExecucaoState.descanso) {
      _iniciarTimerDescanso();
    } else if (estado.value == ExecucaoState.serieConcluida) {
      _iniciarTimerSerieConcluida();
    }
  }

  @override
  void anterior() {
    if (indiceExercicio.value <= 0) {
      return;
    }
    indiceExercicio.value--;
    serieAtual.value = 1;
  }

  @override
  void proximo() {
    final Treino? t = treino.value;
    if (t == null || indiceExercicio.value >= t.exercicios.length - 1) {
      return;
    }
    indiceExercicio.value++;
    serieAtual.value = 1;
  }

  @override
  void pularDescanso() {
    if (estado.value != ExecucaoState.descanso) {
      return;
    }
    _timerDescanso?.cancel();
    segundosDescanso.value = 0;
    serieAtual.value++;
    estado.value = ExecucaoState.exercicio;
  }

  @override
  void ajustarDescanso(int segundos) {
    if (estado.value != ExecucaoState.descanso) {
      return;
    }
    final int novo = segundosDescanso.value + segundos;
    segundosDescanso.value = novo < 0 ? 0 : novo;
    if (segundosDescanso.value > descansoTotal.value) {
      descansoTotal.value = segundosDescanso.value;
    }
  }

  @override
  void alternarPausaDescanso() {
    descansoPausado.value = !descansoPausado.value;
  }

  @override
  Future<void> alterarCarga(double novaCarga) async {
    final TreinoExercicio? atual = exercicioAtual;
    if (atual == null) {
      return;
    }
    final AlterarCargaCommand command = AlterarCargaCommand(
      exercicioId: atual.exercicioId,
      novaCarga: novaCarga,
      cargas: _cargas,
    );
    await command.execute();
  }

  @override
  Future<void> abandonar() async {
    _cancelarTimers();
    await _storage.remove(StorageKeys.sessaoEmAndamento);
    Get.back<void>();
  }

  @override
  void registrarObservacao({
    required String texto,
    required int dificuldade,
  }) {
    final TreinoExercicio? atual = exercicioAtual;
    if (atual == null) {
      return;
    }
    final int indice = seriesExecutadas.lastIndexWhere(
      (SerieExecutada s) => s.exercicioId == atual.exercicioId,
    );
    if (indice == -1) {
      // Ainda nao concluiu nenhuma serie deste exercicio: guarda para aplicar
      // na proxima que for concluida.
      _observacaoPendente = texto;
      _dificuldadePendente = dificuldade;
      return;
    }
    seriesExecutadas[indice] = seriesExecutadas[indice].copyWith(
      observacao: texto,
      dificuldade: dificuldade,
    );
  }

  @override
  Future<List<RegistroCarga>> registrosDoExercicioAtual() async {
    final TreinoExercicio? atual = exercicioAtual;
    if (atual == null) {
      return const <RegistroCarga>[];
    }
    try {
      return await _repository.registrosDeCarga(atual.exercicioId);
    } catch (erro, stackTrace) {
      _log.error(
        'Falha ao carregar a evolucao de carga',
        error: erro,
        stackTrace: stackTrace,
      );
      AppSnackbar.erro(ErrorMessages.de(erro));
      return const <RegistroCarga>[];
    }
  }

  @override
  void avancarAposSerieConcluida() {
    _timerSerieConcluida?.cancel();
    final Treino? t = treino.value;
    if (t == null) {
      return;
    }
    final bool ultimoExercicio =
        indiceExercicio.value >= t.exercicios.length - 1;
    if (ultimoExercicio) {
      unawaited(_finalizarTreino());
    } else {
      indiceExercicio.value++;
      serieAtual.value = 1;
      estado.value = ExecucaoState.exercicio;
    }
  }

  Future<void> _finalizarTreino() async {
    final Treino? t = treino.value;
    if (t == null) {
      return;
    }
    final FinalizarTreinoCommand command = FinalizarTreinoCommand(
      treino: t,
      seriesExecutadas: seriesExecutadas,
      duracaoSeg: segundosTreino.value,
      tempoDescansoSeg: _tempoDescansoTotal,
    );
    try {
      await command.execute();
      _timerTreino?.cancel();
      estado.value = ExecucaoState.concluido;
    } catch (erro, stackTrace) {
      // Sem salvar, o treino nao pode ser dado como concluido: a tela segue
      // na ultima serie, e o botao "Proximo exercicio" tenta de novo.
      _log.error(
        'Falha ao salvar a sessao do treino',
        error: erro,
        stackTrace: stackTrace,
      );
      AppSnackbar.erro(
        'Não foi possível salvar o treino. ${ErrorMessages.de(erro)}',
      );
    }
  }

  /// Retoma a sessao interrompida (planejamento §7): se existe um snapshot do
  /// mesmo treino, volta ao exercicio/serie onde o usuario parou.
  ///
  /// O snapshot so sobrevive quando o app e fechado durante a execucao —
  /// abandonar ou finalizar o treino apagam a chave.
  void _retomarSnapshot(Treino carregado) {
    final Map<dynamic, dynamic>? snapshot =
        _storage.read<Map<dynamic, dynamic>>(StorageKeys.sessaoEmAndamento);
    if (snapshot == null || snapshot['treinoId'] != carregado.id) {
      return;
    }
    final int indice = (snapshot['indiceExercicio'] as int? ?? 0)
        .clamp(0, carregado.exercicios.length - 1);
    final int serieSalva = snapshot['serieAtual'] as int? ?? 1;
    final int totalDoExercicio = carregado.exercicios[indice].series;

    indiceExercicio.value = indice;
    // A serie salva e a que acabou de ser concluida: retoma na seguinte,
    // sem passar do total do exercicio.
    serieAtual.value = (serieSalva + 1).clamp(1, totalDoExercicio);
    AppSnackbar.info('Treino retomado de onde você parou');
  }

  void _aplicarObservacaoPendente() {
    if (_observacaoPendente.isEmpty && _dificuldadePendente == 0) {
      return;
    }
    if (seriesExecutadas.isEmpty) {
      return;
    }
    final int ultimo = seriesExecutadas.length - 1;
    seriesExecutadas[ultimo] = seriesExecutadas[ultimo].copyWith(
      observacao: _observacaoPendente,
      dificuldade: _dificuldadePendente,
    );
    _observacaoPendente = '';
    _dificuldadePendente = 0;
  }

  Future<void> _salvarSnapshot() async {
    final Treino? t = treino.value;
    if (t == null) {
      return;
    }
    await _storage.write(StorageKeys.sessaoEmAndamento, <String, dynamic>{
      'treinoId': t.id,
      'indiceExercicio': indiceExercicio.value,
      'serieAtual': serieAtual.value,
    });
  }

  void _iniciarTimerTreino() {
    _timerTreino?.cancel();
    _timerTreino = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      segundosTreino.value++;
    });
  }

  void _iniciarTimerDescanso() {
    _timerDescanso?.cancel();
    descansoPausado.value = false;
    _timerDescanso = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (descansoPausado.value) {
        return;
      }
      _tempoDescansoTotal++;
      if (segundosDescanso.value <= 1) {
        segundosDescanso.value = 0;
        timer.cancel();
        _finalizarDescanso();
      } else {
        segundosDescanso.value--;
      }
    });
  }

  /// Ao zerar o descanso: vibra, toca um clique e volta automaticamente
  /// para o estado `exercicio` apos um instante (tempo para a UI exibir
  /// "Hora da próxima série!").
  void _finalizarDescanso() {
    HapticFeedback.mediumImpact();
    SystemSound.play(SystemSoundType.click);
    _timerProximaSerie?.cancel();
    _timerProximaSerie = Timer(const Duration(milliseconds: 700), () {
      serieAtual.value++;
      estado.value = ExecucaoState.exercicio;
    });
  }

  void _iniciarTimerSerieConcluida() {
    _timerSerieConcluida?.cancel();
    _timerSerieConcluida =
        Timer(const Duration(seconds: 3), avancarAposSerieConcluida);
  }

  void _cancelarTimers() {
    _timerTreino?.cancel();
    _timerDescanso?.cancel();
    _timerSerieConcluida?.cancel();
    _timerProximaSerie?.cancel();
  }
}
