import '../../../../models/registro_carga.dart';
import '../../../../models/sessao.dart';
import '../../../../models/treino.dart';

/// Contrato do repository da execucao de treino — fala com a API
/// (`/treinos` e `/execucao`).
abstract class ExecucaoRepositoryInterface {
  Future<Treino?> obterTreino(String id);

  /// Envia a sessao concluida (so as series feitas). O servidor calcula
  /// volume, calorias e recordes e devolve a sessao gravada: e ela, e nao a
  /// enviada, que a tela de treino concluido mostra.
  Future<Sessao> finalizarSessao(Sessao sessao);

  /// Registra a troca de carga feita durante o treino.
  Future<void> registrarCarga(RegistroCarga registro);

  /// Historico de carga do exercicio — alimenta o modal de Evolucao de Carga
  /// (tela 22) aberto a partir da execucao.
  Future<List<RegistroCarga>> registrosDeCarga(String exercicioId);
}
