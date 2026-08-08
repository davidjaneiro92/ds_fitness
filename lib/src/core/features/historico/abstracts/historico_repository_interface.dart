import '../../../../models/sessao.dart';
import 'historico_controller_interface.dart';

/// Contrato do repository de historico — fala apenas com
/// `MockDatabaseInterface` (tela 16).
abstract class HistoricoRepositoryInterface {
  Future<List<Sessao>> obterSessoes({
    required int pagina,
    required int porPagina,
  });

  Future<List<ResumoExercicio>> obterResumoExercicios();

  String? nomeExercicio(String id);
}
