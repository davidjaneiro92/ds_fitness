import 'package:ds_fitness/src/components/cards/stat_box.dart';
import 'package:ds_fitness/src/components/charts/app_line_chart.dart';
import 'package:ds_fitness/src/core/abstracts/format_service_interface.dart';
import 'package:ds_fitness/src/core/features/estatisticas/abstracts/estatisticas_controller_interface.dart';
import 'package:ds_fitness/src/core/features/estatisticas/view/estatisticas_view.dart';
import 'package:ds_fitness/src/core/services/format_service.dart';
import 'package:ds_fitness/src/enum/periodo_estatistica.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

class _EstatisticasFake implements EstatisticasControllerInterface {
  @override
  final Rx<PeriodoEstatistica> periodo = PeriodoEstatistica.mes.obs;

  @override
  final RxBool carregando = false.obs;

  @override
  final RxInt totalTreinos = 0.obs;

  @override
  final RxInt tempoTotalSeg = 0.obs;

  @override
  final RxDouble volumeTotal = 0.0.obs;

  @override
  final RxInt calorias = 0.obs;

  @override
  final RxList<ChartPoint> pontosVolume = <ChartPoint>[].obs;

  @override
  final RxList<DistribuicaoGrupo> distribuicao = <DistribuicaoGrupo>[].obs;

  PeriodoEstatistica? periodoEscolhido;

  @override
  Future<void> carregar() async {}

  @override
  void trocarPeriodo(PeriodoEstatistica novo) {
    periodoEscolhido = novo;
    periodo.value = novo;
  }
}

Widget _tela() => const MaterialApp(home: EstatisticasView());

void main() {
  late _EstatisticasFake controller;

  setUp(() {
    controller = _EstatisticasFake();
    Get.put<EstatisticasControllerInterface>(controller);
    Get.put<FormatServiceInterface>(FormatService());
  });

  tearDown(Get.reset);

  group('EstatisticasView', () {
    testWidgets('mostra o titulo, o filtro de periodo e o atalho do historico', (WidgetTester tester) async {
      await tester.pumpWidget(_tela());

      expect(find.text('Evolução'), findsWidgets);
      expect(find.text('Este mês'), findsOneWidget);
      expect(find.byIcon(Icons.history_rounded), findsOneWidget);
    });

    testWidgets('enquanto carrega, mostra so o indicador', (WidgetTester tester) async {
      controller.carregando.value = true;
      await tester.pumpWidget(_tela());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Sem dados no período'), findsNothing);
    });

    testWidgets('sem treino no periodo, mostra o estado vazio', (WidgetTester tester) async {
      await tester.pumpWidget(_tela());

      expect(find.text('Sem dados no período'), findsOneWidget);
      expect(find.text('Volume total'), findsNothing);
    });

    testWidgets('com treinos, mostra os numeros, o grafico e a distribuicao por grupo', (WidgetTester tester) async {
      controller
        ..totalTreinos.value = 12
        ..tempoTotalSeg.value = 9 * 3600
        ..volumeTotal.value = 18500
        ..calorias.value = 4200
        ..pontosVolume.assignAll(const <ChartPoint>[
          ChartPoint(label: '01/10', value: 4200),
          ChartPoint(label: '03/10', value: 5100),
          ChartPoint(label: '05/10', value: 6400),
        ])
        ..distribuicao.assignAll(const <DistribuicaoGrupo>[
          DistribuicaoGrupo(nome: 'Peito', percentual: 0.4),
          DistribuicaoGrupo(nome: 'Costas', percentual: 0.35),
          DistribuicaoGrupo(nome: 'Pernas', percentual: 0.25),
        ]);

      await tester.pumpWidget(_tela());

      expect(find.text('Sem dados no período'), findsNothing);
      // "Treinos" tambem e o nome de uma aba da barra inferior: a busca e dentro
      // dos quadros de numeros.
      for (final String rotulo in <String>['Treinos', 'Tempo total', 'Volume total', 'Calorias']) {
        expect(find.widgetWithText(StatBox, rotulo), findsOneWidget);
      }
      expect(find.text('12'), findsOneWidget);
      expect(find.text('18.500 kg'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Distribuição por grupo muscular'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Evolução de volume (kg)'), findsOneWidget);
      expect(find.byType(AppLineChart), findsOneWidget);
      expect(find.text('Peito'), findsOneWidget);
      expect(find.text('40%'), findsOneWidget);
      expect(find.text('35%'), findsOneWidget);
      expect(find.text('25%'), findsOneWidget);
    });

    testWidgets('escolher outro periodo avisa o controller', (WidgetTester tester) async {
      await tester.pumpWidget(_tela());

      await tester.tap(find.text('Este mês'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Esta semana').last);
      await tester.pumpAndSettle();

      expect(controller.periodoEscolhido, PeriodoEstatistica.semana);
    });
  });
}
