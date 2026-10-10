import '../../../../models/sessao.dart';
import 'historico_controller_interface.dart';

/// Contrato do repository de historico — fala com a API (`/execucao`)
/// (tela 16).
abstract class HistoricoRepositoryInterface {
  /// Uma pagina do historico, da sessao mais recente para a mais antiga.
  Future<List<Sessao>> obterSessoes({
    required int pagina,
    required int porPagina,
  });

  /// Os exercicios que o usuario ja treinou, do mais executado para o menos.
  Future<List<ResumoExercicio>> obterResumoExercicios();
}
