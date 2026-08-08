import '../../../../models/exercicio.dart';
import '../../../../models/registro_carga.dart';

/// Contrato de acesso a dados do Detalhe do Exercicio (tela 19).
abstract class ExercicioDetalheRepositoryInterface {
  Future<Exercicio?> buscarExercicio(String id);

  Future<List<RegistroCarga>> registrosDeCarga(String exercicioId);

  Future<RegistroCarga?> recordePessoal(String exercicioId);

  Future<Exercicio> alternarFavorito(String id);

  Future<void> registrarAcesso(String id);
}
