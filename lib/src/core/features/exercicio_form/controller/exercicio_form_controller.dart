import 'package:get/get.dart';

import '../../../../components/feedback/app_snackbar.dart';
import '../../../../enum/exercicio_form_resultado.dart';
import '../../../../enum/grupo_muscular.dart';
import '../../../../models/exercicio.dart';
import '../../../../routes/route_args.dart';
import '../../../abstracts/log_service_interface.dart';
import '../../../utils/error_messages.dart';
import '../abstracts/exercicio_form_controller_interface.dart';
import '../abstracts/exercicio_form_repository_interface.dart';

/// Controller do formulario de exercicio: cria um exercicio do usuario ou
/// edita (e exclui) um que ele ja criou. O catalogo do sistema nao passa por
/// aqui — o servidor o recusa com 403.
class ExercicioFormController extends GetxController
    implements ExercicioFormControllerInterface {
  final ExercicioFormRepositoryInterface _repository = Get.find();
  final LogServiceInterface _log = Get.find();

  static const List<String> _equipamentos = <String>[
    'Barra',
    'Halteres',
    'Máquina',
    'Cabo',
    'Peso corporal',
  ];

  Exercicio? _original;

  @override
  final RxString nome = ''.obs;

  @override
  final Rx<GrupoMuscular> grupoPrimario = GrupoMuscular.peito.obs;

  @override
  final RxList<GrupoMuscular> gruposSecundarios = <GrupoMuscular>[].obs;

  @override
  final RxString equipamento = ''.obs;

  @override
  final RxList<String> instrucoes = <String>[''].obs;

  @override
  final RxBool salvando = false.obs;

  @override
  bool get edicao => _original != null;

  @override
  List<String> get equipamentosSugeridos => _equipamentos;

  @override
  bool get podeSalvar => nome.value.trim().isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    final Object? args = Get.arguments;
    if (args is ExercicioFormArgs && args.exercicio != null) {
      _carregarOriginal(args.exercicio!);
    }
  }

  void _carregarOriginal(Exercicio exercicio) {
    _original = exercicio;
    nome.value = exercicio.nome;
    grupoPrimario.value = exercicio.grupoPrimario;
    gruposSecundarios.assignAll(exercicio.gruposSecundarios);
    equipamento.value = exercicio.equipamento;
    instrucoes.assignAll(
      exercicio.instrucoes.isEmpty ? <String>[''] : exercicio.instrucoes,
    );
  }

  @override
  void selecionarGrupoPrimario(GrupoMuscular grupo) {
    grupoPrimario.value = grupo;
    // O exercicio nao trabalha o mesmo grupo como primario e secundario.
    gruposSecundarios.remove(grupo);
  }

  @override
  void alternarGrupoSecundario(GrupoMuscular grupo) {
    if (grupo == grupoPrimario.value) {
      return;
    }
    if (gruposSecundarios.contains(grupo)) {
      gruposSecundarios.remove(grupo);
    } else {
      gruposSecundarios.add(grupo);
    }
  }

  @override
  void adicionarInstrucao() => instrucoes.add('');

  @override
  void removerInstrucao(int indice) {
    if (indice < 0 || indice >= instrucoes.length) {
      return;
    }
    instrucoes.removeAt(indice);
    if (instrucoes.isEmpty) {
      instrucoes.add('');
    }
  }

  @override
  void atualizarInstrucao(int indice, String texto) {
    if (indice < 0 || indice >= instrucoes.length) {
      return;
    }
    instrucoes[indice] = texto;
  }

  @override
  Future<bool> salvar() async {
    if (!podeSalvar || salvando.value) {
      return false;
    }
    salvando.value = true;
    try {
      final Exercicio paraSalvar = _montarExercicio();
      if (edicao) {
        await _repository.atualizar(paraSalvar);
      } else {
        await _repository.criar(paraSalvar);
      }
      Get.back<ExercicioFormResultado>(result: ExercicioFormResultado.salvo);
      // Depois de fechar a tela: com um snackbar aberto, o Get.back() so o
      // fecha e nao navega.
      AppSnackbar.success(
        edicao ? 'Exercício atualizado' : 'Exercício criado',
      );
      return true;
    } catch (erro, stackTrace) {
      _log.error('Falha ao salvar exercicio', error: erro, stackTrace: stackTrace);
      AppSnackbar.erro(ErrorMessages.de(erro));
      return false;
    } finally {
      salvando.value = false;
    }
  }

  @override
  Future<bool> excluir() async {
    final Exercicio? original = _original;
    if (original == null || salvando.value) {
      return false;
    }
    salvando.value = true;
    try {
      await _repository.excluir(original.id);
      // Sem snackbar aqui: o detalhe ainda precisa fechar, e quem recebe o
      // resultado final (a biblioteca) e quem avisa o usuario.
      Get.back<ExercicioFormResultado>(
        result: ExercicioFormResultado.excluido,
      );
      return true;
    } catch (erro, stackTrace) {
      _log.error('Falha ao excluir exercicio', error: erro, stackTrace: stackTrace);
      AppSnackbar.erro(ErrorMessages.de(erro));
      return false;
    } finally {
      salvando.value = false;
    }
  }

  Exercicio _montarExercicio() {
    return Exercicio(
      id: _original?.id ?? '',
      nome: nome.value.trim(),
      grupoPrimario: grupoPrimario.value,
      gruposSecundarios: gruposSecundarios.toList(),
      equipamento: equipamento.value.trim(),
      instrucoes: instrucoes
          .map((String passo) => passo.trim())
          .where((String passo) => passo.isNotEmpty)
          .toList(),
    );
  }
}
