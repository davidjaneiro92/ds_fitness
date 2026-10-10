import '../../../../models/exercicio.dart';
import '../../../../models/registro_carga.dart';

/// Contrato de acesso a dados do Detalhe do Exercicio (tela 19) — fala com a
/// API.
abstract class ExercicioDetalheRepositoryInterface {
  /// `null` quando o exercicio nao existe mais (ex.: o usuario o excluiu).
  Future<Exercicio?> buscarExercicio(String id);

  /// Registros de carga do exercicio (ordem cronologica) e o recorde pessoal.
  Future<EvolucaoDeCarga> evolucaoDeCarga(String exercicioId);

  Future<Exercicio> alternarFavorito(String id);

  Future<void> registrarAcesso(String id);
}
