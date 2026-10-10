import 'package:ds_fitness/src/core/abstracts/log_service_interface.dart';
import 'package:ds_fitness/src/core/features/treino_form/abstracts/treino_form_repository_interface.dart';
import 'package:ds_fitness/src/core/features/treino_form/controller/treino_form_controller.dart';
import 'package:ds_fitness/src/enum/grupo_muscular.dart';
import 'package:ds_fitness/src/models/exercicio.dart';
import 'package:ds_fitness/src/models/treino.dart';
import 'package:ds_fitness/src/models/treino_exercicio.dart';
import 'package:ds_fitness/src/routes/route_args.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'support/fakes.dart';

/// Servidor falso dos treinos: guarda o ultimo treino gravado e registra cada
/// ida ao servidor.
class _RepositorioFake implements TreinoFormRepositoryInterface {
  _RepositorioFake(this.guardado);

  Treino guardado;
  final List<Treino> salvos = <Treino>[];

  @override
  Future<Treino?> obterTreino(String id) async => guardado;

  @override
  Future<Treino> salvar(Treino treino) async {
    salvos.add(treino);
    guardado = Treino(
      id: treino.id.isEmpty ? '7' : treino.id,
      nome: treino.nome,
      objetivo: treino.objetivo,
      descricao: treino.descricao,
      exercicios: treino.exercicios,
      diaSemana: treino.diaSemana,
    );
    return guardado;
  }

  @override
  Future<List<Exercicio>> exerciciosPorGrupo(GrupoMuscular grupo) async =>
      const <Exercicio>[];
}

const Exercicio _supino = Exercicio(
  id: '1',
  nome: 'Supino Reto',
  grupoPrimario: GrupoMuscular.peito,
);

/// Treino que o servidor ja tem, com o dia da semana definido.
const Treino _treinoGravado = Treino(
  id: '5',
  nome: 'Treino A',
  diaSemana: 3,
  exercicios: <TreinoExercicio>[
    TreinoExercicio(id: '13', exercicio: _supino, ordem: 0),
  ],
);

/// Abre o formulario como a navegacao faz: [treinoId] nulo e treino novo.
Future<TreinoFormController> _abrir(
  _RepositorioFake repositorio, {
  String? treinoId,
}) async {
  Get.routing.args = TreinoFormArgs(treinoId: treinoId);
  Get.put<TreinoFormRepositoryInterface>(repositorio);
  Get.put<LogServiceInterface>(LogFake());
  final TreinoFormController controller =
      Get.put<TreinoFormController>(TreinoFormController());
  await pumpEventQueue();
  return controller;
}

void main() {
  setUpAll(() => Get.testMode = true);

  tearDown(() {
    Get.routing.args = null;
    Get.reset();
  });

  group('TreinoFormController.salvar', () {
    test('abrir o treino e salvar sem editar nada nao vai ao servidor',
        () async {
      final _RepositorioFake servidor = _RepositorioFake(_treinoGravado);
      final TreinoFormController controller =
          await _abrir(servidor, treinoId: '5');

      expect(await controller.salvar(), isTrue);

      expect(servidor.salvos, isEmpty);
    });

    test('editar e salvar envia o treino sem perder o dia da semana',
        () async {
      final _RepositorioFake servidor = _RepositorioFake(_treinoGravado);
      final TreinoFormController controller =
          await _abrir(servidor, treinoId: '5');
      controller.nome.value = 'Treino B';

      expect(await controller.salvar(), isTrue);

      expect(servidor.salvos, hasLength(1));
      expect(servidor.salvos.single.nome, 'Treino B');
      expect(
        servidor.salvos.single.diaSemana,
        3,
        reason: 'o servidor grava o que recebe: null apagaria o dia',
      );
    });

    test('salvar de novo, sem editar, nao repete o envio', () async {
      final _RepositorioFake servidor = _RepositorioFake(_treinoGravado);
      final TreinoFormController controller =
          await _abrir(servidor, treinoId: '5');
      controller.nome.value = 'Treino B';

      await controller.salvar();
      expect(await controller.salvar(), isTrue);

      expect(servidor.salvos, hasLength(1));
    });

    test('editar depois de salvar envia de novo', () async {
      final _RepositorioFake servidor = _RepositorioFake(_treinoGravado);
      final TreinoFormController controller =
          await _abrir(servidor, treinoId: '5');
      controller.nome.value = 'Treino B';
      await controller.salvar();

      controller.descricao.value = 'Foco em carga';
      await controller.salvar();

      expect(servidor.salvos, hasLength(2));
      expect(servidor.salvos.last.descricao, 'Foco em carga');
    });

    test('mudar um exercicio do treino conta como edicao', () async {
      final _RepositorioFake servidor = _RepositorioFake(_treinoGravado);
      final TreinoFormController controller =
          await _abrir(servidor, treinoId: '5');

      controller.atualizarExercicio(
        controller.exercicios.single,
        series: 5,
        repeticoes: 12,
        carga: 20,
        descansoSeg: 60,
      );
      await controller.salvar();

      expect(servidor.salvos, hasLength(1));
      expect(servidor.salvos.single.exercicios.single.series, 5);
    });

    test('treino novo e gravado na primeira vez e so nela', () async {
      final _RepositorioFake servidor =
          _RepositorioFake(const Treino(id: '', nome: ''));
      final TreinoFormController controller = await _abrir(servidor);
      controller.nome.value = 'Treino C';
      controller.adicionarExercicio(
        _supino,
        series: 4,
        repeticoes: 12,
        carga: 20,
        descansoSeg: 60,
      );

      expect(await controller.salvar(), isTrue);
      expect(servidor.salvos.single.id, isEmpty, reason: 'treino novo e criado');

      expect(await controller.salvar(), isTrue);
      expect(servidor.salvos, hasLength(1));
    });

    test('sem nome ou sem exercicios nao salva', () async {
      final _RepositorioFake servidor =
          _RepositorioFake(const Treino(id: '', nome: ''));
      final TreinoFormController controller = await _abrir(servidor);

      expect(await controller.salvar(), isFalse);

      controller.nome.value = 'Treino C';
      expect(await controller.salvar(), isFalse);
      expect(servidor.salvos, isEmpty);
    });
  });
}
