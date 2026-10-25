import 'dart:async';

import 'package:get/get.dart';

import '../../../../components/feedback/app_snackbar.dart';
import '../../../../core/abstracts/log_service_interface.dart';
import '../../../../enum/grupo_muscular.dart';
import '../../../../enum/pages_routes.dart';
import '../../../../models/exercicio.dart';
import '../../../../models/plano_ia.dart';
import '../../../../models/treino.dart';
import '../../../../models/treino_exercicio.dart';
import '../../../../models/usuario.dart';
import '../../../utils/error_messages.dart';
import '../../perfil/abstracts/perfil_repository_interface.dart';
import '../../treino_form/abstracts/treino_form_repository_interface.dart';
import '../abstracts/treino_ia_controller_interface.dart';
import '../abstracts/treino_ia_repository_interface.dart';

/// Estado compartilhado do fluxo de gerar, revisar e salvar um plano.
class TreinoIaController extends GetxController
    implements TreinoIaControllerInterface {
  final TreinoIaRepositoryInterface _gerador = Get.find();
  final TreinoFormRepositoryInterface _treinoRepository = Get.find();
  final PerfilRepositoryInterface _perfilRepository = Get.find();
  final LogServiceInterface _log = Get.find();

  @override
  final RxString nivel = 'iniciante'.obs;
  @override
  final RxString local = 'casa'.obs;
  @override
  final RxSet<String> equipamentosSelecionados = <String>{}.obs;
  @override
  final RxSet<String> areasComLesao = <String>{}.obs;
  @override
  final RxSet<GrupoMuscular> foco = <GrupoMuscular>{}.obs;
  @override
  final Rxn<Usuario> usuario = Rxn<Usuario>();
  @override
  final RxList<Treino> treinos = <Treino>[].obs;
  @override
  final RxSet<int> sessoesAlteradas = <int>{}.obs;
  @override
  final RxList<Exercicio> catalogo = <Exercicio>[].obs;
  @override
  final RxBool carregandoPerfil = true.obs;
  @override
  final RxBool carregandoPlano = false.obs;
  @override
  final RxBool carregandoCatalogo = false.obs;
  @override
  final RxBool salvando = false.obs;
  @override
  final RxDouble peso = 0.0.obs;
  @override
  final RxDouble altura = 0.0.obs;
  @override
  final RxBool salvandoDados = false.obs;
  @override
  final Rxn<AvaliacaoCorporal> avaliacao = Rxn<AvaliacaoCorporal>();

  static const double _pesoMinimo = 20;
  static const double _pesoMaximo = 400;
  static const double _alturaMinima = 1;
  static const double _alturaMaxima = 2.5;

  bool _catalogoCarregado = false;

  /// Lesões anatômicas traduzidas para os slugs musculares aceitos pelo back.
  /// O contrato atual não recebe regiões articulares independentes.
  static const Map<String, List<String>> _mapeamentoLesoes =
      <String, List<String>>{
    'Pescoço': <String>['ombro', 'costas'],
    'Ombros': <String>['ombro'],
    'Cotovelos': <String>['biceps', 'triceps', 'antebraco'],
    'Punhos': <String>['antebraco'],
    'Costas': <String>['costas'],
    'Lombar': <String>['costas'],
    'Quadril': <String>['gluteos'],
    'Joelhos': <String>['pernas'],
    'Tornozelos': <String>['pernas', 'panturrilha'],
  };

  @override
  void onInit() {
    super.onInit();
    unawaited(_carregarPerfil());
  }

  Future<void> _carregarPerfil() async {
    try {
      usuario.value = await _perfilRepository.obterUsuario();
      _preencherDadosDoPerfil(usuario.value);
    } catch (erro, stackTrace) {
      _log.warning('Não foi possível carregar o perfil para o gerador',
          error: erro);
      _log.debug('Detalhe da falha ao consultar o perfil', data: stackTrace);
    } finally {
      carregandoPerfil.value = false;
    }
  }

  /// Só preenche o que o usuário ainda não digitou nesta tela.
  void _preencherDadosDoPerfil(Usuario? perfil) {
    if (perfil == null) {
      return;
    }
    if (peso.value <= 0 && perfil.peso > 0) {
      peso.value = perfil.peso;
    }
    if (altura.value <= 0 && perfil.altura > 0) {
      altura.value = perfil.altura > 3 ? perfil.altura / 100 : perfil.altura;
    }
  }

  @override
  double? get imc => AvaliacaoCorporal.calcularImc(peso.value, altura.value);

  @override
  String? get classificacaoImc {
    final double? valor = imc;
    return valor == null ? null : AvaliacaoCorporal.classificar(valor);
  }

  @override
  int get totalEtapas => local.value == 'casa' ? 5 : 4;

  @override
  void definirPeso(double kg) => peso.value = kg;

  @override
  void definirAltura(double metros) => altura.value = metros;

  @override
  Future<void> confirmarDados() async {
    if (salvandoDados.value) {
      return;
    }
    if (peso.value < _pesoMinimo || peso.value > _pesoMaximo) {
      AppSnackbar.erro('Informe um peso entre 20 e 400 kg.');
      return;
    }
    if (altura.value < _alturaMinima || altura.value > _alturaMaxima) {
      AppSnackbar.erro('Informe uma altura entre 100 e 250 cm.');
      return;
    }
    salvandoDados.value = true;
    try {
      await _guardarNoPerfil();
    } finally {
      salvandoDados.value = false;
    }
    await Get.toNamed<void>(PagesRoutes.treinoIaPreferencias.path);
  }

  /// O perfil passa a ter o peso e a altura atuais. Falhar aqui não impede o
  /// gerador: os valores seguem no pedido da prévia de qualquer forma.
  Future<void> _guardarNoPerfil() async {
    final Usuario? perfil = usuario.value;
    if (perfil == null ||
        (perfil.peso == peso.value && perfil.altura == altura.value)) {
      return;
    }
    try {
      usuario.value = await _perfilRepository.salvarUsuario(
        perfil.copyWith(peso: peso.value, altura: altura.value),
      );
    } catch (erro, stackTrace) {
      _log.warning('Não foi possível guardar peso e altura no perfil',
          error: erro);
      _log.debug('Detalhe da falha ao salvar o perfil', data: stackTrace);
    }
  }

  @override
  void selecionarNivel(String valor) => nivel.value = valor;

  @override
  void selecionarLocal(String valor) => local.value = valor;

  @override
  void alternarEquipamento(String equipamento) {
    if (!equipamentosSelecionados.add(equipamento)) {
      equipamentosSelecionados.remove(equipamento);
    }
  }

  @override
  void alternarLesao(String area) {
    if (!areasComLesao.add(area)) {
      areasComLesao.remove(area);
    }
  }

  @override
  void limparLesoes() => areasComLesao.clear();

  @override
  void alternarFoco(GrupoMuscular grupo) {
    if (!foco.add(grupo)) {
      foco.remove(grupo);
    }
  }

  @override
  bool equipamentoSelecionado(String item) =>
      equipamentosSelecionados.contains(item);

  @override
  bool lesaoSelecionada(String area) => areasComLesao.contains(area);

  @override
  bool focoSelecionado(GrupoMuscular grupo) => foco.contains(grupo);

  @override
  List<String> get areasDeLesao => _mapeamentoLesoes.keys.toList();

  @override
  Map<String, dynamic> get preferenciasApi {
    final Set<String> lesoes = <String>{};
    for (final String area in areasComLesao) {
      lesoes.addAll(_mapeamentoLesoes[area] ?? const <String>[]);
    }

    final List<String> equipamentos = local.value == 'academia'
        ? <String>[]
        : equipamentosSelecionados.map<String>(_equipamentoParaApi).toList();

    return <String, dynamic>{
      'nivel': nivel.value,
      'local': local.value,
      'equipamento': equipamentos,
      'lesoes': lesoes.toList(),
      'foco': foco.map<String>((GrupoMuscular grupo) => grupo.slug).toList(),
      if (peso.value > 0) 'peso': peso.value,
      if (altura.value > 0) 'altura': altura.value,
    };
  }

  String _equipamentoParaApi(String equipamento) {
    switch (equipamento) {
      case 'Halteres':
        return 'halteres';
      case 'Elástico':
        return 'elastico';
      case 'Banco':
        return 'banco';
      case 'Peso do corpo':
        return 'peso_corporal';
      default:
        return equipamento.toLowerCase();
    }
  }

  /// Monta a prévia do backend e abre a tela de revisão.
  @override
  Future<void> calcularPrevia() async {
    if (carregandoPlano.value) {
      return;
    }
    carregandoPlano.value = true;
    try {
      final PlanoIa plano = await _gerador.previa(preferenciasApi);
      if (plano.treinos.isEmpty) {
        AppSnackbar.erro('Não foi possível montar um plano com essas opções.');
        return;
      }
      treinos.assignAll(plano.treinos);
      avaliacao.value = plano.avaliacao;
      sessoesAlteradas.clear();
      await Get.toNamed<void>(PagesRoutes.treinoIaPrevia.path);
    } catch (erro, stackTrace) {
      _log.error(
        'Falha ao calcular a prévia do treino',
        error: erro,
        stackTrace: stackTrace,
      );
      AppSnackbar.erro(ErrorMessages.de(erro));
    } finally {
      carregandoPlano.value = false;
    }
  }

  @override
  Future<void> carregarCatalogo() async {
    if (_catalogoCarregado || carregandoCatalogo.value) {
      return;
    }
    carregandoCatalogo.value = true;
    try {
      catalogo.assignAll(await _treinoRepository.listarExercicios());
      _catalogoCarregado = true;
    } catch (erro, stackTrace) {
      _log.error(
        'Falha ao carregar exercícios para a prévia do gerador',
        error: erro,
        stackTrace: stackTrace,
      );
      AppSnackbar.erro(ErrorMessages.de(erro));
    } finally {
      carregandoCatalogo.value = false;
    }
  }

  @override
  List<Exercicio> exerciciosParaTreino(int indiceTreino, String busca) {
    if (indiceTreino < 0 || indiceTreino >= treinos.length) {
      return <Exercicio>[];
    }
    final Treino treino = treinos[indiceTreino];
    final Set<GrupoMuscular> grupos = treino.grupos.toSet();
    final Set<String> adicionados = treino.exercicios
        .map<String>((TreinoExercicio item) => item.exercicio.id)
        .toSet();
    final String termo = busca.trim().toLowerCase();

    return catalogo.where((Exercicio exercicio) {
      final bool correspondeAoGrupo =
          grupos.isEmpty || exercicio.todosGrupos.any(grupos.contains);
      final bool correspondeABusca =
          termo.isEmpty || exercicio.nome.toLowerCase().contains(termo);
      return correspondeAoGrupo &&
          correspondeABusca &&
          !adicionados.contains(exercicio.id);
    }).toList();
  }

  @override
  void adicionarExercicio(int indiceTreino, Exercicio exercicio) {
    if (indiceTreino < 0 || indiceTreino >= treinos.length) {
      return;
    }
    final Treino treino = treinos[indiceTreino];
    final List<TreinoExercicio> itens = <TreinoExercicio>[
      ...treino.exercicios,
      TreinoExercicio(
        id: '',
        exercicio: exercicio,
        ordem: treino.exercicios.length + 1,
        series: 3,
        repeticoes: 12,
        cargaInicial: 0,
        descansoSeg: 60,
      ),
    ];
    treinos[indiceTreino] = treino.copyWith(exercicios: itens);
    sessoesAlteradas.add(indiceTreino);
  }

  @override
  void removerExercicio(int indiceTreino, int indiceExercicio) {
    if (indiceTreino < 0 || indiceTreino >= treinos.length) {
      return;
    }
    final Treino treino = treinos[indiceTreino];
    if (indiceExercicio < 0 || indiceExercicio >= treino.exercicios.length) {
      return;
    }
    if (treino.exercicios.length == 1) {
      AppSnackbar.erro('Mantenha pelo menos um exercício em cada treino.');
      return;
    }
    final List<TreinoExercicio> itens = treino.exercicios
        .asMap()
        .entries
        .where((MapEntry<int, TreinoExercicio> entrada) =>
            entrada.key != indiceExercicio)
        .map<TreinoExercicio>((MapEntry<int, TreinoExercicio> entrada) =>
            entrada.value.copyWith(ordem: entrada.key + 1))
        .toList();
    treinos[indiceTreino] = treino.copyWith(exercicios: itens);
    sessoesAlteradas.add(indiceTreino);
  }

  /// Salva o plano pelo endpoint documentado e aplica as edições locais via PUT.
  /// O contrato atual de /gerar recalcula o plano; por isso as edições da prévia
  /// são enviadas logo depois como atualizações dos treinos recém-criados.
  @override
  Future<void> salvarPlano() async {
    if (salvando.value || treinos.isEmpty) {
      return;
    }
    salvando.value = true;
    bool planoCriado = false;
    try {
      final List<Treino> gerados =
          (await _gerador.gerar(preferenciasApi)).treinos;
      if (gerados.isEmpty) {
        throw StateError('O servidor não retornou os treinos gerados.');
      }
      planoCriado = true;

      for (final int indice in sessoesAlteradas.toList()..sort()) {
        final Treino rascunho = treinos[indice];
        final Treino? criado = _encontrarTreinoGerado(gerados, rascunho);
        if (criado == null || criado.id.isEmpty) {
          throw StateError(
              'Não foi possível localizar um treino gerado para atualizar.');
        }
        await _treinoRepository.salvar(
          Treino(
            id: criado.id,
            nome: rascunho.nome,
            objetivo: rascunho.objetivo,
            descricao: rascunho.descricao,
            diaSemana: rascunho.diaSemana,
            exercicios: rascunho.exercicios
                .map<TreinoExercicio>(
                  (TreinoExercicio item) => TreinoExercicio(
                    id: '',
                    exercicio: item.exercicio,
                    ordem: item.ordem,
                    series: item.series,
                    repeticoes: item.repeticoes,
                    cargaInicial: 0,
                    descansoSeg: item.descansoSeg,
                    observacao: item.observacao,
                  ),
                )
                .toList(),
          ),
        );
      }

      AppSnackbar.success('Plano salvo em Meus Treinos.');
      _sairDoFluxo();
      unawaited(Get.offAllNamed<void>(PagesRoutes.treinar.path));
    } catch (erro, stackTrace) {
      _log.error(
        planoCriado
            ? 'Plano criado, mas houve falha ao aplicar as alterações da prévia'
            : 'Falha ao salvar o plano gerado',
        error: erro,
        stackTrace: stackTrace,
      );
      if (planoCriado) {
        AppSnackbar.erro(
          'O plano foi criado, mas alguns ajustes não foram aplicados. '
          'Você pode revisá-lo em Meus Treinos.',
        );
        _sairDoFluxo();
        unawaited(Get.offAllNamed<void>(PagesRoutes.treinar.path));
      } else {
        AppSnackbar.erro(ErrorMessages.de(erro));
      }
    } finally {
      salvando.value = false;
    }
  }

  Treino? _encontrarTreinoGerado(
    List<Treino> gerados,
    Treino rascunho,
  ) {
    for (final Treino treino in gerados) {
      if (treino.nome == rascunho.nome &&
          treino.diaSemana == rascunho.diaSemana) {
        return treino;
      }
    }
    return null;
  }

  @override
  void cancelar() {
    descartarAoSair();
    Get.back<void>();
  }

  /// Libera o estado quando a primeira rota é fechada pelo botão do sistema.
  @override
  void descartarAoSair() => _sairDoFluxo();

  void _sairDoFluxo() {
    if (Get.isRegistered<TreinoIaControllerInterface>()) {
      Get.delete<TreinoIaControllerInterface>(force: true);
    }
    if (Get.isRegistered<TreinoIaRepositoryInterface>()) {
      Get.delete<TreinoIaRepositoryInterface>(force: true);
    }
  }
}
