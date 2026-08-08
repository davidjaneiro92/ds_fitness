import 'package:get/get.dart';

import '../../../../enum/periodo_estatistica.dart';
import '../../../../models/sessao.dart';

/// Resumo agregado das execucoes de um exercicio (aba "Exercícios" do
/// historico) — numero de vezes treinado e a maior carga ja registrada.
class ResumoExercicio {
  const ResumoExercicio({
    required this.nome,
    required this.execucoes,
    required this.melhorCarga,
  });

  final String nome;
  final int execucoes;
  final double melhorCarga;
}

/// Contrato do controller da tela de historico (tela 16).
abstract class HistoricoControllerInterface {
  RxList<Sessao> get sessoes;

  RxBool get carregando;

  RxBool get carregandoMais;

  RxBool get temMais;

  Rx<HistoricoFiltro> get filtro;

  RxList<ResumoExercicio> get resumoExercicios;

  Future<void> carregar();

  Future<void> carregarMais();

  void trocarFiltro(HistoricoFiltro filtro);

  String nomeExercicio(String id);
}
