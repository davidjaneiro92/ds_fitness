import 'dart:async';

import 'package:get/get.dart';

import '../../../../../core/abstracts/storage_service_interface.dart';
import '../../../../../enum/pages_routes.dart';
import '../../../../../models/serie_executada.dart';
import '../../../../../models/sessao.dart';
import '../../../../../models/treino.dart';
import '../../../../../routes/route_args.dart';
import '../../abstracts/command_interface.dart';
import '../../abstracts/execucao_repository_interface.dart';

/// Envia a sessao finalizada ao servidor, limpa a sessao em andamento e
/// navega para a tela de treino concluido.
///
/// O app informa so o que aconteceu (series feitas e tempos). Volume,
/// calorias e recordes pessoais sao calculados pelo servidor, que e quem
/// guarda o historico de cargas — por isso a tela de conclusao mostra a
/// sessao que ele devolve, e nao a que foi enviada.
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
  final StorageServiceInterface _storage = Get.find();

  @override
  Future<void> execute() async {
    final List<SerieExecutada> concluidas =
        seriesExecutadas.where((SerieExecutada s) => s.concluida).toList();

    final DateTime fim = DateTime.now();
    final Sessao enviada = Sessao(
      id: '',
      treinoId: treino.id,
      treinoNome: treino.nome,
      iniciadoEm: fim.subtract(Duration(seconds: duracaoSeg)),
      finalizadoEm: fim,
      duracaoSeg: duracaoSeg,
      tempoDescansoSeg: tempoDescansoSeg,
      series: concluidas,
    );

    final Sessao salva = await _repository.finalizarSessao(enviada);
    await _storage.remove(StorageKeys.sessaoEmAndamento);

    unawaited(
      Get.offNamed<void>(
        PagesRoutes.execucaoConcluido.path,
        arguments: ExecucaoConcluidoArgs(sessao: salva),
      ),
    );
  }
}
