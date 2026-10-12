import 'package:ds_fitness/src/core/abstracts/log_service_interface.dart';
import 'package:ds_fitness/src/core/features/treino_form/abstracts/treino_form_controller_interface.dart';
import 'package:ds_fitness/src/core/features/treino_form/abstracts/treino_form_repository_interface.dart';
import 'package:ds_fitness/src/core/features/treinos/abstracts/treinos_repository_interface.dart';
import 'package:ds_fitness/src/enum/grupo_muscular.dart';
import 'package:ds_fitness/src/enum/pages_routes.dart';
import 'package:ds_fitness/src/models/exercicio.dart';
import 'package:ds_fitness/src/models/treino.dart';
import 'package:ds_fitness/src/models/treino_exercicio.dart';
import 'package:ds_fitness/src/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'support/fakes.dart';

/// Servidor falso: uma base so, que a lista de treinos e o fluxo de montar o
/// treino enxergam — o que o fluxo salva e o que a lista mostra depois.
class _Servidor implements TreinoFormRepositoryInterface, TreinosRepositoryInterface {
  _Servidor({List<Treino> treinos = const <Treino>[]})
      : treinos = List<Treino>.of(treinos);

  final List<Treino> treinos;
  final List<Treino> salvos = <Treino>[];
  int listagens = 0;

  @override
  Future<Treino?> obterTreino(String id) async {
    for (final Treino treino in treinos) {
      if (treino.id == id) {
        return treino;
      }
    }
    return null;
  }

  @override
  Future<Treino> salvar(Treino treino) async {
    salvos.add(treino);
    final Treino gravado = Treino(
      id: treino.id.isEmpty ? '${treinos.length + 1}' : treino.id,
      nome: treino.nome,
      objetivo: treino.objetivo,
      descricao: treino.descricao,
      diaSemana: treino.diaSemana,
      exercicios: <TreinoExercicio>[
        for (int i = 0; i < treino.exercicios.length; i++)
          treino.exercicios[i].copyWith(ordem: i),
      ],
    );
    treinos
      ..removeWhere((Treino t) => t.id == gravado.id)
      ..add(gravado);
    return gravado;
  }

  @override
  Future<List<Exercicio>> listarExercicios() async => const <Exercicio>[_supino, _crucifixo];

  @override
  Future<List<Treino>> listar() async {
    listagens++;
    return List<Treino>.of(treinos);
  }

  @override
  Future<Treino?> obterTreinoDoDia() async => treinos.isEmpty ? null : treinos.first;

  @override
  Future<Treino> duplicar(String id) => throw UnimplementedError();

  @override
  Future<void> excluir(String id) async {}
}

const Exercicio _supino = Exercicio(
  id: '1',
  nome: 'Supino Reto',
  grupoPrimario: GrupoMuscular.peito,
);

const Exercicio _crucifixo = Exercicio(
  id: '4',
  nome: 'Crucifixo',
  grupoPrimario: GrupoMuscular.peito,
);

const Treino _treinoA = Treino(
  id: '5',
  nome: 'Treino A',
  diaSemana: 3,
  exercicios: <TreinoExercicio>[
    TreinoExercicio(
      id: '13',
      exercicio: _supino,
      ordem: 0,
      series: 4,
      repeticoes: 12,
      cargaInicial: 0,
      descansoSeg: 90,
    ),
  ],
);

/// O app com as rotas de verdade, a lista de treinos como tela inicial e o
/// servidor falso no lugar da API.
Future<_Servidor> _abrirApp(WidgetTester tester, {List<Treino> treinos = const <Treino>[]}) async {
  await tester.binding.setSurfaceSize(const Size(390, 844));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final _Servidor servidor = _Servidor(treinos: treinos);
  Get.put<TreinoFormRepositoryInterface>(servidor);
  Get.put<TreinosRepositoryInterface>(servidor);
  Get.put<LogServiceInterface>(LogFake());

  await tester.pumpWidget(
    GetMaterialApp(
      initialRoute: PagesRoutes.treinos.path,
      getPages: AppPages.pages,
    ),
  );
  await tester.pumpAndSettle();
  return servidor;
}

/// O snackbar "Treino salvo!" tem um temporizador proprio: deixa passar.
Future<void> _esperarOSnackbar(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 10));
  await tester.pumpAndSettle();
}

Future<void> _tocar(WidgetTester tester, Finder alvo) async {
  await tester.tap(alvo);
  await tester.pumpAndSettle();
}

void main() {
  tearDown(Get.reset);

  group('Fluxo de montar o treino, com as rotas e as telas de verdade', () {
    testWidgets('treino novo: do formulario ate salvar, e a lista mostra o treino', (WidgetTester tester) async {
      final _Servidor servidor = await _abrirApp(tester);
      expect(find.text('Você ainda não criou nenhum treino'), findsOneWidget);

      await _tocar(tester, find.text('Novo treino'));
      await tester.enterText(find.byType(TextField).first, 'Treino B');
      await tester.pump();
      await _tocar(tester, find.text('Continuar'));

      await _tocar(tester, find.text('Peito'));
      await _tocar(tester, find.text('Próximo'));

      await _tocar(tester, find.text('Crucifixo'));
      await _tocar(tester, find.text('Configurar exercício'));
      await _tocar(tester, find.text('Adicionar ao treino'));

      expect(find.textContaining('Treino B'), findsOneWidget);
      expect(find.text('Crucifixo'), findsOneWidget);

      // Salvar encerra o fluxo — e tira o controller do registro — enquanto as
      // telas ainda animam a saida: elas nao podem procura-lo de novo.
      await _tocar(tester, find.text('Salvar treino'));
      await _esperarOSnackbar(tester);

      expect(servidor.salvos, hasLength(1));
      expect(servidor.salvos.single.nome, 'Treino B');
      expect(find.text('Meus treinos'), findsOneWidget);
      expect(find.text('Treino B'), findsOneWidget);
      expect(find.text('1 exercício'), findsOneWidget);
      expect(Get.isRegistered<TreinoFormControllerInterface>(), isFalse);
    });

    testWidgets('treino que ja existe: acrescentar um exercicio e salvar recarrega a lista', (WidgetTester tester) async {
      final _Servidor servidor =
          await _abrirApp(tester, treinos: const <Treino>[_treinoA]);
      expect(find.text('1 exercício'), findsOneWidget);
      final int listagensAntes = servidor.listagens;

      await _tocar(tester, find.text('Treino A'));
      expect(find.text('Treino A • Quarta'), findsOneWidget);
      expect(find.text('Iniciar treino'), findsOneWidget);

      await _tocar(tester, find.text('Adicionar exercício'));
      // O treino ja tem exercicios de peito: o grupo vem marcado.
      await _tocar(tester, find.text('Próximo'));
      expect(find.text('No treino'), findsOneWidget);

      await _tocar(tester, find.text('Crucifixo'));
      await _tocar(tester, find.text('Configurar exercício'));
      await _tocar(tester, find.text('Adicionar ao treino'));

      // Voltou a mesma tela de revisao, agora com os dois exercicios.
      expect(find.text('Treino A • Quarta'), findsOneWidget);
      expect(find.text('Supino Reto'), findsOneWidget);
      expect(find.text('Crucifixo'), findsOneWidget);

      await _tocar(tester, find.text('Salvar treino'));
      await _esperarOSnackbar(tester);

      expect(servidor.salvos, hasLength(1));
      expect(servidor.salvos.single.exercicios, hasLength(2));
      expect(find.text('Meus treinos'), findsOneWidget);
      // A lista recarrega quando o fluxo termina (e nao quando a primeira tela
      // dele sai da pilha, o que mostraria o treino de antes de salvar).
      expect(find.text('2 exercícios'), findsOneWidget);
      expect(servidor.listagens, listagensAntes + 1);
    });

    testWidgets('treino que ja existe: sair sem mexer em nada nao salva nem pergunta', (WidgetTester tester) async {
      final _Servidor servidor =
          await _abrirApp(tester, treinos: const <Treino>[_treinoA]);

      await _tocar(tester, find.text('Treino A'));
      await _tocar(tester, find.byIcon(Icons.arrow_back_rounded));

      expect(find.text('Descartar alterações?'), findsNothing);
      expect(find.text('Meus treinos'), findsOneWidget);
      expect(servidor.salvos, isEmpty);
      expect(Get.isRegistered<TreinoFormControllerInterface>(), isFalse);
    });
  });
}
