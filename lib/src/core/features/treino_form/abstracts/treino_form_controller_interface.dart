import 'package:get/get.dart';

import '../../../../enum/dia_semana.dart';
import '../../../../enum/grupo_muscular.dart';
import '../../../../enum/objetivo_treino.dart';
import '../../../../models/exercicio.dart';
import '../../../../models/treino_exercicio.dart';

/// Contrato do estado compartilhado do fluxo de montar um treino.
///
/// O fluxo tem sete passos, e uma unica instancia deste controller (veja
/// `TreinoFormBinding`) sobrevive a todos eles:
///
/// 1. **Novo treino** (`/treinos/novo`): dia, nome, objetivo, descricao;
/// 2. **Grupos musculares** (`/grupos`): um ou mais grupos;
/// 3. **Selecionar exercicio** (`/exercicios`): um exercicio dos grupos;
/// 4. **Configurar exercicio** (`/exercicios/configurar`): series, repeticoes,
///    descanso;
/// 5. **Revisar e salvar** (`/treinos/revisar`): a lista, e voltar ao passo 2
///    para acrescentar mais.
///
/// Editar um treino que ja existe abre direto o passo 5.
///
/// As telas do fluxo guardam a instancia ao serem criadas (num `State`), em vez
/// de usar `GetView`, que procura o controller no registro a cada uso. Salvar,
/// descartar e iniciar chamam [encerrar] com as telas ainda animando a saida, e
/// elas se reconstroem nesse meio tempo: com `GetView` o `Get.find` falharia
/// ("not found") e a tela de erro do Flutter apareceria na transicao.
abstract class TreinoFormControllerInterface {
  /// Padroes da configuracao de um exercicio novo.
  static const int seriesPadrao = 4;
  static const int repeticoesPadrao = 12;
  static const int descansoPadraoSeg = 90;

  /// Tamanho maximo da descricao do treino.
  static const int limiteDaDescricao = 200;

  RxBool get carregando;

  RxBool get salvando;

  // ---- Passo 1: os dados do treino ----------------------------------------

  /// Dia da semana; `null` num treino antigo que nao tem dia marcado.
  Rxn<DiaSemana> get dia;

  RxString get nome;

  Rx<ObjetivoTreino> get objetivo;

  RxString get descricao;

  /// `true` quando ha nome preenchido: o botao *Continuar* do passo 1.
  bool get podeContinuar;

  void escolherDia(DiaSemana novo);

  // ---- Passo 2: os grupos musculares --------------------------------------

  RxSet<GrupoMuscular> get gruposSelecionados;

  void alternarGrupo(GrupoMuscular grupo);

  // ---- Passos 3 e 4: escolher e configurar um exercicio -------------------

  /// O exercicio marcado na lista (e mostrado na tela de configurar).
  Rxn<Exercicio> get exercicioEscolhido;

  RxInt get series;

  RxInt get repeticoes;

  RxInt get descansoSeg;

  /// `true` quando a tela de configurar edita um exercicio que ja esta no
  /// treino, e nao um que esta entrando.
  bool get editandoItem;

  bool jaAdicionado(String exercicioId);

  void escolherExercicio(Exercicio exercicio);

  /// Prepara a escolha de um exercicio novo: nenhum marcado e a configuracao
  /// nos padroes. Os grupos selecionados ficam como estao.
  void iniciarAdicao();

  /// Carrega um exercicio que ja esta no treino na tela de configurar.
  void iniciarEdicaoDe(TreinoExercicio item);

  /// Acrescenta o exercicio escolhido ao treino com a configuracao atual, ou
  /// atualiza o item que esta sendo editado. A escolha so e limpa no proximo
  /// [iniciarAdicao], e confirmar de novo nao repete o exercicio.
  void confirmarConfiguracao();

  // ---- Passo 5: revisar e salvar ------------------------------------------

  RxList<TreinoExercicio> get exercicios;

  /// `true` quando o treino ja existe no servidor (foi aberto, e nao criado).
  bool get existente;

  /// Id do treino no servidor; `null` enquanto ele nao foi salvo.
  String? get treinoId;

  /// `true` quando o fluxo foi aberto pela lista de treinos (e deve voltar a
  /// ela ao terminar).
  bool get partiuDaLista;

  /// Ex.: "Treino A • Segunda".
  String get titulo;

  /// `true` quando ha nome e ao menos um exercicio.
  bool get podeSalvar;

  /// `true` quando algo mudou desde que o treino foi aberto ou salvo.
  bool get alterado;

  void removerExercicio(String treinoExercicioId);

  void reordenar(int oldIndex, int newIndex);

  /// Persiste o treino. Devolve `true` em caso de sucesso — e tambem quando
  /// nada mudou num treino que ja existe, caso em que nao ha o que enviar.
  Future<bool> salvar();

  /// Encerra o fluxo: descarta a instancia permanente do controller. Deve ser
  /// chamado antes de qualquer saida definitiva (salvar, descartar, iniciar o
  /// treino).
  void encerrar();
}
