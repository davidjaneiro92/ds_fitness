import '../../../../models/treino.dart';

/// Contrato do gerador: calcula uma prévia ou persiste o plano calculado.
abstract class TreinoIaRepositoryInterface {
  Future<List<Treino>> previa(Map<String, dynamic> preferencias);

  Future<List<Treino>> gerar(Map<String, dynamic> preferencias);
}
