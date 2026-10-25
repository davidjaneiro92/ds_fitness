import 'package:get/get.dart';

import '../../../../enum/grupo_muscular.dart';
import '../../../../models/exercicio.dart';
import '../../../../models/plano_ia.dart';
import '../../../../models/treino.dart';
import '../../../../models/usuario.dart';

/// Estado e ações do fluxo de montagem de treino com IA.
abstract class TreinoIaControllerInterface {
  RxString get nivel;
  RxString get local;
  RxSet<String> get equipamentosSelecionados;
  RxSet<String> get areasComLesao;
  RxSet<GrupoMuscular> get foco;
  Rxn<Usuario> get usuario;
  RxList<Treino> get treinos;
  RxSet<int> get sessoesAlteradas;
  RxList<Exercicio> get catalogo;
  RxBool get carregandoPerfil;
  RxBool get carregandoPlano;
  RxBool get carregandoCatalogo;
  RxBool get salvando;

  /// Peso em kg e altura em metros da etapa "Seus dados" (0 = não informado).
  RxDouble get peso;
  RxDouble get altura;
  RxBool get salvandoDados;

  /// Avaliação corporal devolvida pelo servidor junto com a prévia.
  Rxn<AvaliacaoCorporal> get avaliacao;

  /// IMC dos dados digitados; nulo enquanto faltar peso ou altura.
  double? get imc;
  String? get classificacaoImc;

  /// Total de etapas: em casa há a de equipamentos (5); na academia, 4.
  int get totalEtapas;
  List<String> get areasDeLesao;
  Map<String, dynamic> get preferenciasApi;

  void definirPeso(double kg);
  void definirAltura(double metros);

  /// Valida peso e altura, guarda no perfil e segue para as preferências.
  Future<void> confirmarDados();
  void selecionarNivel(String valor);
  void selecionarLocal(String valor);
  void alternarEquipamento(String equipamento);
  void alternarLesao(String area);
  void limparLesoes();
  void alternarFoco(GrupoMuscular grupo);
  bool equipamentoSelecionado(String item);
  bool lesaoSelecionada(String area);
  bool focoSelecionado(GrupoMuscular grupo);
  Future<void> calcularPrevia();
  Future<void> carregarCatalogo();
  List<Exercicio> exerciciosParaTreino(int indiceTreino, String busca);
  void adicionarExercicio(int indiceTreino, Exercicio exercicio);
  void removerExercicio(int indiceTreino, int indiceExercicio);
  Future<void> salvarPlano();
  void cancelar();
  void descartarAoSair();
}
