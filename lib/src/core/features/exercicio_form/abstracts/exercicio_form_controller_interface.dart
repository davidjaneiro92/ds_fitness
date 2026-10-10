import 'package:get/get.dart';

import '../../../../enum/grupo_muscular.dart';

/// Contrato do controller do formulario de exercicio (criar e editar).
abstract class ExercicioFormControllerInterface {
  /// `true` quando edita um exercicio existente; `false` quando cria.
  bool get edicao;

  RxString get nome;

  Rx<GrupoMuscular> get grupoPrimario;

  /// Grupos trabalhados alem do primario (nunca contem o primario).
  RxList<GrupoMuscular> get gruposSecundarios;

  RxString get equipamento;

  /// Passos da execucao, na ordem. Passo em branco e descartado ao salvar.
  RxList<String> get instrucoes;

  RxBool get salvando;

  /// Equipamentos mais comuns, oferecidos como atalho no campo de texto.
  List<String> get equipamentosSugeridos;

  /// `true` com nome preenchido (o grupo primario sempre tem valor).
  bool get podeSalvar;

  void selecionarGrupoPrimario(GrupoMuscular grupo);

  void alternarGrupoSecundario(GrupoMuscular grupo);

  void adicionarInstrucao();

  void removerInstrucao(int indice);

  void atualizarInstrucao(int indice, String texto);

  /// Grava e fecha a tela devolvendo `ExercicioFormResultado.salvo`. Devolve
  /// `false` quando a gravacao falha (o motivo ja foi avisado ao usuario).
  Future<bool> salvar();

  /// Exclui e fecha a tela devolvendo `ExercicioFormResultado.excluido`.
  Future<bool> excluir();
}
