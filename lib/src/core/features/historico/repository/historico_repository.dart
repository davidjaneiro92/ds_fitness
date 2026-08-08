import 'package:get/get.dart';

import '../../../../core/abstracts/mock_database_interface.dart';
import '../../../../models/serie_executada.dart';
import '../../../../models/sessao.dart';
import '../abstracts/historico_controller_interface.dart';
import '../abstracts/historico_repository_interface.dart';

/// Repository de historico — fala apenas com `MockDatabaseInterface`.
class HistoricoRepository implements HistoricoRepositoryInterface {
  final MockDatabaseInterface _db = Get.find();

  @override
  Future<List<Sessao>> obterSessoes({
    required int pagina,
    required int porPagina,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
    final List<Sessao> todas = List<Sessao>.of(_db.sessoes)
      ..sort((Sessao a, Sessao b) => b.iniciadoEm.compareTo(a.iniciadoEm));
    final int inicio = (pagina - 1) * porPagina;
    if (inicio >= todas.length) {
      return <Sessao>[];
    }
    final int fim = (inicio + porPagina).clamp(0, todas.length);
    return todas.sublist(inicio, fim);
  }

  @override
  Future<List<ResumoExercicio>> obterResumoExercicios() async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
    final Map<String, int> execucoes = <String, int>{};
    for (final Sessao sessao in _db.sessoes) {
      final Set<String> exerciciosDaSessao = sessao.series
          .map((SerieExecutada s) => s.exercicioId)
          .toSet();
      for (final String exercicioId in exerciciosDaSessao) {
        execucoes[exercicioId] = (execucoes[exercicioId] ?? 0) + 1;
      }
    }
    final List<ResumoExercicio> resultado = <ResumoExercicio>[];
    for (final MapEntry<String, int> entry in execucoes.entries) {
      final String nome = _db.exercicioPorId(entry.key)?.nome ?? 'Exercício';
      final double melhorCarga = _db.recordePessoal(entry.key)?.carga ?? 0;
      resultado.add(
        ResumoExercicio(
          nome: nome,
          execucoes: entry.value,
          melhorCarga: melhorCarga,
        ),
      );
    }
    resultado.sort(
      (ResumoExercicio a, ResumoExercicio b) =>
          b.execucoes.compareTo(a.execucoes),
    );
    return resultado;
  }

  @override
  String? nomeExercicio(String id) => _db.exercicioPorId(id)?.nome;
}
