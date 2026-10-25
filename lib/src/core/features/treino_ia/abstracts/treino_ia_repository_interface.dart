import '../../../../models/plano_ia.dart';

/// Contrato do gerador: calcula uma prévia ou persiste o plano calculado.
abstract class TreinoIaRepositoryInterface {
  Future<PlanoIa> previa(Map<String, dynamic> preferencias);

  Future<PlanoIa> gerar(Map<String, dynamic> preferencias);
}
