import '../../../../models/registro_carga.dart';
import '../../../../models/sessao.dart';
import '../../../../models/treino.dart';

/// Contrato do repository da execucao de treino — unico ponto de contato
/// com [MockDatabaseInterface] para esta feature.
abstract class ExecucaoRepositoryInterface {
  Future<Treino?> obterTreino(String id);

  Future<void> salvarSessao(Sessao sessao);

  Future<void> registrarCarga(RegistroCarga registro);

  /// Maior carga ja registrada para o exercicio (sincrono: apenas le o mock).
  RegistroCarga? recorde(String exercicioId);

  /// Historico de carga do exercicio — alimenta o modal de Evolucao de Carga
  /// (tela 22) aberto a partir da execucao.
  List<RegistroCarga> registrosDeCarga(String exercicioId);
}
