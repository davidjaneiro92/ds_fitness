import 'package:get/get.dart';

import '../../../../enum/execucao_state.dart';
import '../../../../models/registro_carga.dart';
import '../../../../models/serie_executada.dart';
import '../../../../models/treino.dart';
import '../../../../models/treino_exercicio.dart';

/// Contrato do controller da execucao de treino (planejamento §4 e §6).
///
/// A maquina de estados vive aqui: [estado] transita entre
/// `exercicio -> descanso -> exercicio` (series intermediarias) ou
/// `exercicio -> serieConcluida -> exercicio | concluido` (ultima serie de
/// cada exercicio). O descanso nunca aparece apos a ultima serie — a regra
/// e garantida estruturalmente em [ConcluirSerieCommand].
abstract class ExecucaoControllerInterface {
  Rx<ExecucaoState> get estado;

  Rxn<Treino> get treino;

  /// Indice do exercicio atual no treino (0-based).
  RxInt get indiceExercicio;

  /// Serie atual do exercicio em andamento (1-based).
  RxInt get serieAtual;

  /// Cronometro geral do treino, em segundos, contando desde o inicio.
  RxInt get segundosTreino;

  /// Contagem regressiva do descanso atual, em segundos.
  RxInt get segundosDescanso;

  /// Duracao total do descanso atual, em segundos (usado no anel de progresso).
  RxInt get descansoTotal;

  RxBool get descansoPausado;

  RxList<SerieExecutada> get seriesExecutadas;

  TreinoExercicio? get exercicioAtual;

  int get totalSeries;

  double get cargaAtual;

  /// Marca a serie atual como concluida e decide o proximo estado.
  Future<void> concluirSerie();

  /// Navega para o exercicio anterior (apenas visualizacao, nao mexe na
  /// maquina de estados de series).
  void anterior();

  /// Navega para o proximo exercicio (apenas visualizacao).
  void proximo();

  /// Encerra o descanso atual imediatamente e avanca para a proxima serie.
  void pularDescanso();

  /// Ajusta o descanso em `segundos` (positivo ou negativo), ex.: ±15.
  void ajustarDescanso(int segundos);

  void alternarPausaDescanso();

  /// Atualiza a carga do exercicio atual em diante e registra no historico.
  Future<void> alterarCarga(double novaCarga);

  /// Cancela timers, limpa a sessao em andamento e sai da execucao.
  Future<void> abandonar();

  /// Chamado ao tocar "Proximo exercicio"/"Finalizar treino" ou ao expirar
  /// o auto-dismiss da tela de serie concluida.
  void avancarAposSerieConcluida();

  /// Anexa observacao e dificuldade (1–5) a ultima serie concluida do
  /// exercicio atual (tela 24). Se ainda nao houver serie concluida, o
  /// registro fica pendente e e aplicado na proxima.
  void registrarObservacao({required String texto, required int dificuldade});

  /// Historico de carga do exercicio atual — abastece o modal de Evolucao de
  /// Carga (tela 22) aberto pelo menu da execucao.
  List<RegistroCarga> registrosDoExercicioAtual();
}
