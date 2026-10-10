import 'package:get/get.dart';

import '../../../../../enum/execucao_state.dart';
import '../../../../../models/serie_executada.dart';
import '../../../../../models/treino_exercicio.dart';
import '../../abstracts/command_interface.dart';

/// Registra a serie concluida e decide o proximo estado da maquina de
/// execucao.
///
/// **Regra de ouro (planejamento §4): o descanso nunca aparece apos a
/// ultima serie de um exercicio.** Isso e garantido estruturalmente aqui:
/// o unico ponto do codebase que atribui `ExecucaoState.descanso` a
/// [estado] e o ramo `else` abaixo, guardado por `!_ultimaSerie` — nao
/// existe outro caminho para o estado de descanso.
class ConcluirSerieCommand implements CommandInterface {
  ConcluirSerieCommand({
    required this.treinoExercicio,
    required this.numeroSerie,
    required this.totalSeries,
    required this.carga,
    required this.seriesExecutadas,
    required this.estado,
    required this.descansoTotal,
    required this.segundosDescanso,
  });

  final TreinoExercicio treinoExercicio;
  final int numeroSerie;
  final int totalSeries;
  final double carga;
  final RxList<SerieExecutada> seriesExecutadas;
  final Rx<ExecucaoState> estado;
  final RxInt descansoTotal;
  final RxInt segundosDescanso;

  bool get _ultimaSerie => numeroSerie >= totalSeries;

  @override
  Future<void> execute() async {
    final SerieExecutada serie = SerieExecutada(
      id: '${treinoExercicio.id}_$numeroSerie',
      exercicioId: treinoExercicio.exercicioId,
      numeroSerie: numeroSerie,
      repeticoes: treinoExercicio.repeticoes,
      carga: carga,
      concluida: true,
    );
    seriesExecutadas.add(serie);

    if (_ultimaSerie) {
      estado.value = ExecucaoState.serieConcluida;
    } else {
      descansoTotal.value = treinoExercicio.descansoSeg;
      segundosDescanso.value = treinoExercicio.descansoSeg;
      estado.value = ExecucaoState.descanso;
    }
  }
}
