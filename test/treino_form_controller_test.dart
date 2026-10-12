import 'package:ds_fitness/src/core/abstracts/log_service_interface.dart';
import 'package:ds_fitness/src/core/features/treino_form/abstracts/treino_form_controller_interface.dart';
import 'package:ds_fitness/src/core/features/treino_form/abstracts/treino_form_repository_interface.dart';
import 'package:ds_fitness/src/core/features/treino_form/controller/exercicios_controller.dart';
import 'package:ds_fitness/src/core/features/treino_form/controller/treino_form_controller.dart';
import 'package:ds_fitness/src/enum/dia_semana.dart';
import 'package:ds_fitness/src/enum/grupo_muscular.dart';
import 'package:ds_fitness/src/enum/objetivo_treino.dart';
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
  _RepositorioFake({this.guardado, this.catalogo = const <Exercicio>[]});

  Treino? guardado;
  final List<Exercicio> catalogo;
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
      diaSemana: treino.diaSemana,
      // O servidor troca os ids locais (novo_N) pelos seus.
      exercicios: <TreinoExercicio>[
        for (int i = 0; i < treino.exercicios.length; i++)
          TreinoExercicio(
            id: '${100 + i}',
            exercicio: treino.exercicios[i].exercicio,
            ordem: i,
            series: treino.exercicios[i].series,
            repeticoes: treino.exercicios[i].repeticoes,
            cargaInicial: treino.exercicios[i].cargaInicial,
            descansoSeg: treino.exercicios[i].descansoSeg,
            observacao: treino.exercicios[i].observacao,
          ),
      ],
    );
    return guardado!;
  }

  @override
  Future<List<Exercicio>> listarExercicios() async => catalogo;
}

const Exercicio _supino = Exercicio(
  id: '1',
  nome: 'Supino Reto',
  grupoPrimario: GrupoMuscular.peito,
  gruposSecundarios: <GrupoMuscular>[GrupoMuscular.triceps, GrupoMuscular.ombro],
  equipamento: 'Barra',
  imagem: 'pectorals/barbell-bench-press',
);

const Exercicio _crucifixo = Exercicio(
  id: '4',
  nome: 'Crucifixo',
  grupoPrimario: GrupoMuscular.peito,
  gruposSecundarios: <GrupoMuscular>[GrupoMuscular.ombro],
);

const Exercicio _triceps = Exercicio(
  id: '22',
  nome: 'Tríceps Pulley',
  grupoPrimario: GrupoMuscular.triceps,
);

const Exercicio _agachamento = Exercicio(
  id: '27',
  nome: 'Agachamento Livre',
  grupoPrimario: GrupoMuscular.pernas,
);

const Exercicio _maquina = Exercicio(
  id: '54',
  nome: 'Supino na Máquina',
  grupoPrimario: GrupoMuscular.peito,
);

/// Treino que o servidor ja tem: quarta-feira, com um exercicio.
const Treino _treinoGravado = Treino(
  id: '5',
  nome: 'Treino A',
  objetivo: ObjetivoTreino.forca,
  descricao: 'Peito pesado',
  diaSemana: 3,
  exercicios: <TreinoExercicio>[
    TreinoExercicio(
      id: '13',
      exercicio: _supino,
      ordem: 0,
      series: 5,
      repeticoes: 8,
      cargaInicial: 60,
      descansoSeg: 120,
      observacao: 'Controle.',
    ),
  ],
);

/// Abre o fluxo como a navegacao faz: [treinoId] nulo e treino novo.
Future<TreinoFormController> _abrir(
  _RepositorioFake repositorio, {
  String? treinoId,
  bool partiuDaLista = false,
}) async {
  Get.routing.args =
      TreinoFormArgs(treinoId: treinoId, partiuDaLista: partiuDaLista);
  Get.put<TreinoFormRepositoryInterface>(repositorio);
  Get.put<LogServiceInterface>(LogFake());
  final TreinoFormController controller =
      Get.put<TreinoFormController>(TreinoFormController());
  await pumpEventQueue();
  return controller;
}

/// Escolhe [exercicio] e confirma a configuracao, como o usuario faz nos
/// passos 3 e 4.
void _adicionar(
  TreinoFormController controller,
  Exercicio exercicio, {
  int series = 4,
  int repeticoes = 12,
  int descanso = 90,
}) {
  controller
    ..iniciarAdicao()
    ..escolherExercicio(exercicio)
    ..series.value = series
    ..repeticoes.value = repeticoes
    ..descansoSeg.value = descanso
    ..confirmarConfiguracao();
}

void main() {
  setUpAll(() => Get.testMode = true);

  tearDown(() {
    Get.routing.args = null;
    Get.reset();
  });

  group('Passo 1 — os dados do treino', () {
    test('comeca no dia de hoje, com o objetivo padrao e sem nome', () async {
      final TreinoFormController controller = await _abrir(_RepositorioFake());

      expect(controller.dia.value, DiaSemana.hoje());
      expect(controller.objetivo.value, ObjetivoTreino.hipertrofia);
      expect(controller.nome.value, isEmpty);
      expect(controller.existente, isFalse);
      expect(controller.alterado, isFalse, reason: 'rascunho vazio nao pede confirmacao');
    });

    test('so continua com o nome preenchido', () async {
      final TreinoFormController controller = await _abrir(_RepositorioFake());

      expect(controller.podeContinuar, isFalse);
      controller.nome.value = '   ';
      expect(controller.podeContinuar, isFalse);
      controller.nome.value = 'Treino A';
      expect(controller.podeContinuar, isTrue);
    });

    test('escolher o dia troca o dia, e o titulo o mostra', () async {
      final TreinoFormController controller = await _abrir(_RepositorioFake());
      controller
        ..nome.value = 'Treino A'
        ..escolherDia(DiaSemana.segunda);

      expect(controller.dia.value, DiaSemana.segunda);
      expect(controller.titulo, 'Treino A • Segunda');
      expect(controller.alterado, isTrue);
    });

    test('a descricao tem limite de 200 caracteres', () {
      expect(TreinoFormControllerInterface.limiteDaDescricao, 200);
    });
  });

  group('Passo 2 — os grupos musculares', () {
    test('cada toque marca ou desmarca o grupo', () async {
      final TreinoFormController controller = await _abrir(_RepositorioFake());

      controller
        ..alternarGrupo(GrupoMuscular.peito)
        ..alternarGrupo(GrupoMuscular.triceps)
        ..alternarGrupo(GrupoMuscular.ombro);
      expect(
        controller.gruposSelecionados,
        <GrupoMuscular>{
          GrupoMuscular.peito,
          GrupoMuscular.triceps,
          GrupoMuscular.ombro,
        },
      );

      controller.alternarGrupo(GrupoMuscular.triceps);
      expect(
        controller.gruposSelecionados,
        <GrupoMuscular>{GrupoMuscular.peito, GrupoMuscular.ombro},
      );
    });
  });

  group('Passos 3 e 4 — escolher e configurar o exercicio', () {
    test('acrescenta o exercicio com a configuracao e sem carga', () async {
      final TreinoFormController controller = await _abrir(_RepositorioFake());

      _adicionar(controller, _supino, series: 5, repeticoes: 8, descanso: 120);

      final TreinoExercicio item = controller.exercicios.single;
      expect(item.exercicioId, '1');
      expect(item.series, 5);
      expect(item.repeticoes, 8);
      expect(item.descansoSeg, 120);
      expect(item.cargaInicial, 0, reason: 'a carga se define na execucao');
      expect(item.ordem, 0);
      expect(item.id, startsWith('novo_'), reason: 'ainda nao tem id do servidor');
    });

    test('a configuracao de um exercicio novo parte dos padroes', () async {
      final TreinoFormController controller = await _abrir(_RepositorioFake());
      controller
        ..series.value = 9
        ..repeticoes.value = 3
        ..descansoSeg.value = 30
        ..escolherExercicio(_supino)
        ..iniciarAdicao();

      expect(controller.exercicioEscolhido.value, isNull);
      expect(controller.series.value, TreinoFormControllerInterface.seriesPadrao);
      expect(controller.repeticoes.value, TreinoFormControllerInterface.repeticoesPadrao);
      expect(controller.descansoSeg.value, TreinoFormControllerInterface.descansoPadraoSeg);
      expect(controller.editandoItem, isFalse);
    });

    test('o padrao e 4 series, 12 repeticoes e 90 s de descanso', () {
      expect(TreinoFormControllerInterface.seriesPadrao, 4);
      expect(TreinoFormControllerInterface.repeticoesPadrao, 12);
      expect(TreinoFormControllerInterface.descansoPadraoSeg, 90);
    });

    test('o mesmo exercicio nao entra duas vezes', () async {
      final TreinoFormController controller = await _abrir(_RepositorioFake());
      _adicionar(controller, _supino);

      expect(controller.jaAdicionado('1'), isTrue);
      controller
        ..iniciarAdicao()
        ..escolherExercicio(_supino);
      expect(controller.exercicioEscolhido.value, isNull, reason: 'a API recusaria');

      controller.confirmarConfiguracao();
      expect(controller.exercicios, hasLength(1));
    });

    test('confirmar duas vezes nao repete o exercicio', () async {
      final TreinoFormController controller = await _abrir(_RepositorioFake());
      _adicionar(controller, _supino);

      controller.confirmarConfiguracao();

      expect(controller.exercicios, hasLength(1));
    });

    test('editar um item muda a configuracao e preserva carga e observacao', () async {
      final _RepositorioFake servidor = _RepositorioFake(guardado: _treinoGravado);
      final TreinoFormController controller =
          await _abrir(servidor, treinoId: '5');

      controller
        ..iniciarEdicaoDe(controller.exercicios.single)
        ..series.value = 3
        ..descansoSeg.value = 60
        ..confirmarConfiguracao();

      final TreinoExercicio item = controller.exercicios.single;
      expect(controller.editandoItem, isTrue);
      expect(item.series, 3);
      expect(item.repeticoes, 8, reason: 'o que nao foi mexido fica como estava');
      expect(item.descansoSeg, 60);
      expect(item.cargaInicial, 60);
      expect(item.observacao, 'Controle.');
      expect(controller.exercicios, hasLength(1));
    });
  });

  group('Passo 5 — revisar', () {
    test('remover renumera a ordem dos que ficam', () async {
      final TreinoFormController controller = await _abrir(_RepositorioFake());
      _adicionar(controller, _supino);
      _adicionar(controller, _crucifixo);
      _adicionar(controller, _triceps);

      controller.removerExercicio(controller.exercicios[1].id);

      expect(
        controller.exercicios.map((TreinoExercicio e) => e.exercicioId).toList(),
        <String>['1', '22'],
      );
      expect(
        controller.exercicios.map((TreinoExercicio e) => e.ordem).toList(),
        <int>[0, 1],
      );
    });

    test('reordenar arrasta o item e renumera', () async {
      final TreinoFormController controller = await _abrir(_RepositorioFake());
      _adicionar(controller, _supino);
      _adicionar(controller, _crucifixo);
      _adicionar(controller, _triceps);

      // O ReorderableListView entrega o destino "antes de remover o item".
      controller.reordenar(0, 3);

      expect(
        controller.exercicios.map((TreinoExercicio e) => e.exercicioId).toList(),
        <String>['4', '22', '1'],
      );
      expect(
        controller.exercicios.map((TreinoExercicio e) => e.ordem).toList(),
        <int>[0, 1, 2],
      );
    });

    test('sem nome ou sem exercicio nao salva', () async {
      final _RepositorioFake servidor = _RepositorioFake();
      final TreinoFormController controller = await _abrir(servidor);

      expect(controller.podeSalvar, isFalse);
      expect(await controller.salvar(), isFalse);

      controller.nome.value = 'Treino A';
      expect(controller.podeSalvar, isFalse, reason: 'falta um exercicio');
      expect(await controller.salvar(), isFalse);

      _adicionar(controller, _supino);
      controller.nome.value = '';
      expect(controller.podeSalvar, isFalse, reason: 'falta o nome');
      expect(servidor.salvos, isEmpty);
    });
  });

  group('Salvar', () {
    test('treino novo vai ao servidor com o dia e os exercicios, uma vez so', () async {
      final _RepositorioFake servidor = _RepositorioFake();
      final TreinoFormController controller = await _abrir(servidor);
      controller
        ..nome.value = '  Treino A  '
        ..escolherDia(DiaSemana.sexta)
        ..objetivo.value = ObjetivoTreino.forca
        ..descricao.value = 'Peito pesado';
      _adicionar(controller, _supino, series: 5, repeticoes: 8, descanso: 120);

      expect(await controller.salvar(), isTrue);

      final Treino enviado = servidor.salvos.single;
      expect(enviado.id, isEmpty, reason: 'sem id = criar');
      expect(enviado.nome, 'Treino A');
      expect(enviado.diaSemana, 5);
      expect(enviado.objetivo, ObjetivoTreino.forca);
      expect(enviado.descricao, 'Peito pesado');
      expect(enviado.exercicios.single.series, 5);
      expect(controller.existente, isTrue);
      expect(controller.treinoId, '7');
      expect(
        controller.exercicios.single.id,
        '100',
        reason: 'os ids locais viram os do servidor',
      );

      // Sem mexer em nada, salvar de novo nao repete o envio.
      expect(await controller.salvar(), isTrue);
      expect(servidor.salvos, hasLength(1));

      // Editar depois de salvar envia de novo, agora para atualizar.
      controller.nome.value = 'Treino B';
      expect(await controller.salvar(), isTrue);
      expect(servidor.salvos, hasLength(2));
      expect(servidor.salvos.last.id, '7');
    });

    test('abrir um treino e salvar sem editar nada nao vai ao servidor', () async {
      final _RepositorioFake servidor = _RepositorioFake(guardado: _treinoGravado);
      final TreinoFormController controller =
          await _abrir(servidor, treinoId: '5');

      expect(controller.existente, isTrue);
      expect(controller.alterado, isFalse);
      expect(await controller.salvar(), isTrue);

      expect(servidor.salvos, isEmpty);
    });

    test('abrir um treino carrega os dados e marca os grupos dos exercicios', () async {
      final _RepositorioFake servidor = _RepositorioFake(guardado: _treinoGravado);
      final TreinoFormController controller =
          await _abrir(servidor, treinoId: '5', partiuDaLista: true);

      expect(controller.dia.value, DiaSemana.quarta);
      expect(controller.nome.value, 'Treino A');
      expect(controller.objetivo.value, ObjetivoTreino.forca);
      expect(controller.descricao.value, 'Peito pesado');
      expect(controller.titulo, 'Treino A • Quarta');
      expect(controller.gruposSelecionados, <GrupoMuscular>{GrupoMuscular.peito});
      expect(controller.partiuDaLista, isTrue);
    });

    test('editar um treino que ja existe nao apaga o dia da semana', () async {
      final _RepositorioFake servidor = _RepositorioFake(guardado: _treinoGravado);
      final TreinoFormController controller =
          await _abrir(servidor, treinoId: '5');
      controller.nome.value = 'Treino B';

      expect(await controller.salvar(), isTrue);

      final Treino enviado = servidor.salvos.single;
      expect(enviado.id, '5');
      expect(enviado.nome, 'Treino B');
      expect(enviado.diaSemana, 3, reason: 'sem devolver o dia, o servidor o apagaria');
    });

    test('mudar o dia de um treino que ja existe conta como edicao', () async {
      final _RepositorioFake servidor = _RepositorioFake(guardado: _treinoGravado);
      final TreinoFormController controller =
          await _abrir(servidor, treinoId: '5');

      controller.escolherDia(DiaSemana.domingo);

      expect(controller.alterado, isTrue);
      expect(await controller.salvar(), isTrue);
      expect(servidor.salvos.single.diaSemana, 7);
    });

    test('mudar a configuracao de um exercicio conta como edicao', () async {
      final _RepositorioFake servidor = _RepositorioFake(guardado: _treinoGravado);
      final TreinoFormController controller =
          await _abrir(servidor, treinoId: '5');

      controller
        ..iniciarEdicaoDe(controller.exercicios.single)
        ..repeticoes.value = 10
        ..confirmarConfiguracao();

      expect(controller.alterado, isTrue);
      expect(await controller.salvar(), isTrue);
      expect(servidor.salvos.single.exercicios.single.repeticoes, 10);
    });
  });

  group('Escolha do exercicio (passo 3)', () {
    const List<Exercicio> catalogo = <Exercicio>[
      _supino,
      _crucifixo,
      _maquina,
      _triceps,
      _agachamento,
    ];

    Future<ExerciciosController> abrirLista(
      TreinoFormController treinoForm,
      _RepositorioFake repositorio,
    ) async {
      Get.put<TreinoFormControllerInterface>(treinoForm);
      final ExerciciosController controller =
          Get.put<ExerciciosController>(ExerciciosController());
      await pumpEventQueue();
      return controller;
    }

    test('lista so os exercicios cujo grupo primario foi escolhido', () async {
      final _RepositorioFake servidor = _RepositorioFake(catalogo: catalogo);
      final TreinoFormController treinoForm = await _abrir(servidor);
      treinoForm
        ..alternarGrupo(GrupoMuscular.peito)
        ..alternarGrupo(GrupoMuscular.triceps);

      final ExerciciosController lista = await abrirLista(treinoForm, servidor);

      expect(
        lista.filtrados.map((Exercicio e) => e.nome).toList(),
        <String>['Supino Reto', 'Crucifixo', 'Supino na Máquina', 'Tríceps Pulley'],
        reason: 'perna fica de fora, e o triceps de apoio do supino nao puxa o supino para a lista de triceps',
      );
    });

    test('a busca ignora caixa e acento', () async {
      final _RepositorioFake servidor = _RepositorioFake(catalogo: catalogo);
      final TreinoFormController treinoForm = await _abrir(servidor);
      treinoForm.alternarGrupo(GrupoMuscular.peito);
      final ExerciciosController lista = await abrirLista(treinoForm, servidor);

      lista.buscar('SUPINO');
      expect(lista.filtrados.map((Exercicio e) => e.id).toList(), <String>['1', '54']);

      lista.buscar('maquina');
      expect(lista.filtrados.map((Exercicio e) => e.id).toList(), <String>['54']);

      lista.buscar('xyz');
      expect(lista.filtrados, isEmpty);
    });

    test('sem grupo escolhido mostra o catalogo todo', () async {
      final _RepositorioFake servidor = _RepositorioFake(catalogo: catalogo);
      final TreinoFormController treinoForm = await _abrir(servidor);

      final ExerciciosController lista = await abrirLista(treinoForm, servidor);

      expect(lista.filtrados, hasLength(5));
    });

    test('sabe quais exercicios ja estao no treino', () async {
      final _RepositorioFake servidor = _RepositorioFake(catalogo: catalogo);
      final TreinoFormController treinoForm = await _abrir(servidor);
      _adicionar(treinoForm, _supino);

      final ExerciciosController lista = await abrirLista(treinoForm, servidor);

      expect(lista.adicionadosIds, <String>{'1'});
    });
  });
}

