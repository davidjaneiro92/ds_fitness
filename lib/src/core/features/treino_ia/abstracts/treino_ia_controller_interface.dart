import 'package:get/get.dart';

import '../../../../enum/grupo_muscular.dart';
import '../../../../models/exercicio.dart';
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
  List<String> get areasDeLesao;
  Map<String, dynamic> get preferenciasApi;

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
