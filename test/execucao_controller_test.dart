import 'dart:async';

import 'package:ds_fitness/src/core/abstracts/log_service_interface.dart';
import 'package:ds_fitness/src/core/abstracts/storage_service_interface.dart';
import 'package:ds_fitness/src/core/features/execucao/abstracts/execucao_repository_interface.dart';
import 'package:ds_fitness/src/core/features/execucao/controller/execucao_controller.dart';
import 'package:ds_fitness/src/enum/execucao_state.dart';
import 'package:ds_fitness/src/enum/grupo_muscular.dart';
import 'package:ds_fitness/src/enum/pages_routes.dart';
import 'package:ds_fitness/src/models/exercicio.dart';
import 'package:ds_fitness/src/models/registro_carga.dart';
import 'package:ds_fitness/src/models/sessao.dart';
import 'package:ds_fitness/src/models/treino.dart';
import 'package:ds_fitness/src/models/treino_exercicio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'support/fakes.dart';

/// Servidor falso da execucao: guarda o que o controller enviou e so responde
/// quando o teste manda, para dar tempo de chegar um segundo toque.
class _RepositorioFake implements ExecucaoRepositoryInterface {
  _RepositorioFake(this.treino);

  final Treino treino;
  final List<Sessao> enviadas = <Sessao>[];
  final List<Completer<Sessao>> _esperando = <Completer<Sessao>>[];

  /// O proximo envio falha (sem conexao), como no aparelho sem rede.
  bool falharProximo = false;

  @override
  Future<Treino?> obterTreino(String id) async => treino;

  @override
  Future<Sessao> finalizarSessao(Sessao sessao) {
    enviadas.add(sessao);
    if (falharProximo) {
      falharProximo = false;
      return Future<Sessao>.error(Exception('sem conexao'));
    }
    final Completer<Sessao> resposta = Completer<Sessao>();
    _esperando.add(resposta);
    return resposta.future;
  }

  /// Responde os envios que estao esperando.
  void responder() {
    for (final Completer<Sessao> resposta in _esperando) {
      resposta.complete(
        Sessao(
          id: '9',
          treinoId: treino.id,
          treinoNome: treino.nome,
          iniciadoEm: DateTime(2026, 10, 10),
        ),
      );
    }
    _esperando.clear();
  }

  @override
  Future<void> registrarCarga(RegistroCarga registro) async {}

  @override
  Future<List<RegistroCarga>> registrosDeCarga(String exercicioId) async =>
      const <RegistroCarga>[];
}

/// Treino de [exercicios] exercicios com uma serie cada: a primeira serie ja
/// e a ultima, entao concluir uma serie abre o overlay de "serie concluida".
Treino _treino({required int exercicios}) {
  return Treino(
    id: '1',
    nome: 'Treino A',
    exercicios: <TreinoExercicio>[
      for (int i = 0; i < exercicios; i++)
        TreinoExercicio(
          id: '${i + 1}',
          exercicio: Exercicio(
            id: '${i + 1}',
            nome: 'Exercicio ${i + 1}',
            grupoPrimario: GrupoMuscular.peito,
          ),
          ordem: i,
          series: 1,
          repeticoes: 10,
          cargaInicial: 20,
          descansoSeg: 30,
        ),
    ],
  );
}

Future<ExecucaoController> _iniciar(_RepositorioFake repositorio) async {
  Get.put<ExecucaoRepositoryInterface>(repositorio);
  Get.put<LogServiceInterface>(LogFake());
  Get.put<StorageServiceInterface>(StorageFake());
  final ExecucaoController controller =
      Get.put<ExecucaoController>(ExecucaoController());
  await controller.carregarTreino('1');
  return controller;
}

void main() {
  setUpAll(() => Get.testMode = true);

  // Cancela os timers do controller entre um teste e outro.
  tearDown(Get.reset);

  group('ExecucaoController — fim da serie', () {
    test('tocar duas vezes em "Finalizar treino" grava a sessao uma vez',
        () async {
      final _RepositorioFake servidor =
          _RepositorioFake(_treino(exercicios: 1));
      final ExecucaoController controller = await _iniciar(servidor);
      await controller.concluirSerie();
      expect(controller.estado.value, ExecucaoState.serieConcluida);

      controller
        ..avancarAposSerieConcluida()
        ..avancarAposSerieConcluida();
      await pumpEventQueue();

      expect(
        servidor.enviadas,
        hasLength(1),
        reason: 'o segundo toque chegou com o primeiro envio em andamento',
      );

      servidor.responder();
      await pumpEventQueue();

      expect(servidor.enviadas, hasLength(1));
      expect(controller.estado.value, ExecucaoState.concluido);
    });

    test('um toque tardio no overlay nao pula para a finalizacao', () async {
      final _RepositorioFake servidor =
          _RepositorioFake(_treino(exercicios: 2));
      final ExecucaoController controller = await _iniciar(servidor);
      await controller.concluirSerie();

      // O auto-dismiss avanca para o 2o exercicio; o toque seguinte e de um
      // overlay que ainda estava na tela e nao pode contar como "finalizar".
      controller
        ..avancarAposSerieConcluida()
        ..avancarAposSerieConcluida();
      await pumpEventQueue();

      expect(controller.indiceExercicio.value, 1);
      expect(controller.estado.value, ExecucaoState.exercicio);
      expect(servidor.enviadas, isEmpty);
    });

    testWidgets('se o envio falha, "Finalizar treino" tenta de novo',
        (WidgetTester tester) async {
      // O erro de envio abre um snackbar, que precisa de um app com overlay, e
      // salvar com sucesso navega para a tela de treino concluido.
      await tester.pumpWidget(
        GetMaterialApp(
          home: const SizedBox(),
          getPages: <GetPage<void>>[
            GetPage<void>(
              name: PagesRoutes.execucaoConcluido.path,
              page: () => const SizedBox(),
            ),
          ],
        ),
      );
      final _RepositorioFake servidor = _RepositorioFake(_treino(exercicios: 1))
        ..falharProximo = true;
      final ExecucaoController controller = await _iniciar(servidor);
      await controller.concluirSerie();

      controller.avancarAposSerieConcluida();
      await tester.pump();

      expect(
        controller.estado.value,
        ExecucaoState.serieConcluida,
        reason: 'sem salvar, o treino nao esta concluido',
      );

      controller.avancarAposSerieConcluida();
      await tester.pump();
      servidor.responder();
      await tester.pump();

      expect(servidor.enviadas, hasLength(2));
      expect(controller.estado.value, ExecucaoState.concluido);

      await Get.delete<ExecucaoController>();
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });
  });
}
