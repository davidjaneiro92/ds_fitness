import 'dart:async';

import 'package:get/get.dart';

import '../../../../../core/abstracts/mock_database_interface.dart';
import '../../../../../core/abstracts/storage_service_interface.dart';
import '../../../../../enum/pages_routes.dart';
import '../../../../../models/registro_carga.dart';
import '../../../../../models/serie_executada.dart';
import '../../../../../models/sessao.dart';
import '../../../../../models/treino.dart';
import '../../../../../models/treino_exercicio.dart';
import '../../../../../routes/route_args.dart';
import '../../abstracts/command_interface.dart';
import '../../abstracts/execucao_repository_interface.dart';

/// Monta a [Sessao] finalizada, salva no mock, limpa a sessao em andamento
/// e navega para a tela de treino concluido.
class FinalizarTreinoCommand implements CommandInterface {
  FinalizarTreinoCommand({
    required this.treino,
    required this.seriesExecutadas,
    required this.duracaoSeg,
    required this.tempoDescansoSeg,
  });

  final Treino treino;
  final List<SerieExecutada> seriesExecutadas;
  final int duracaoSeg;
  final int tempoDescansoSeg;

  final ExecucaoRepositoryInterface _repository = Get.find();
  final MockDatabaseInterface _db = Get.find();
  final StorageServiceInterface _storage = Get.find();

  @override
  Future<void> execute() async {
    final List<SerieExecutada> concluidas =
        seriesExecutadas.where((SerieExecutada s) => s.concluida).toList();

    final double volumeTotal = concluidas.fold<double>(
      0,
      (double soma, SerieExecutada s) => soma + s.volume,
    );

    final int calorias = ((duracaoSeg / 60) * 8).round();

    final List<String> recordes = <String>[];
    for (final TreinoExercicio item in treino.exercicios) {
      final List<SerieExecutada> doExercicio = concluidas
          .where((SerieExecutada s) => s.exercicioId == item.exercicioId)
          .toList();
      if (doExercicio.isEmpty) {
        continue;
      }
      final double maiorCarga = doExercicio
          .map((SerieExecutada s) => s.carga)
          .reduce((double a, double b) => a > b ? a : b);
      final RegistroCarga? recordeAnterior = _repository.recorde(item.exercicioId);
      if (recordeAnterior == null || maiorCarga > recordeAnterior.carga) {
        recordes.add(item.exercicio.nome);
      }
    }

    final Sessao sessao = Sessao(
      id: _db.novoId('s'),
      treinoId: treino.id,
      treinoNome: treino.nome,
      iniciadoEm: DateTime.now().subtract(Duration(seconds: duracaoSeg)),
      finalizadoEm: DateTime.now(),
      duracaoSeg: duracaoSeg,
      tempoDescansoSeg: tempoDescansoSeg,
      volumeTotal: volumeTotal,
      calorias: calorias,
      series: concluidas,
      recordes: recordes,
    );

    await _repository.salvarSessao(sessao);
    await _storage.remove(StorageKeys.sessaoEmAndamento);

    unawaited(
      Get.offNamed<void>(
        PagesRoutes.execucaoConcluido.path,
        arguments: ExecucaoConcluidoArgs(sessao: sessao),
      ),
    );
  }
}
