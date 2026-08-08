import 'package:get/get.dart';

import '../../../../../models/registro_carga.dart';
import '../../abstracts/command_interface.dart';
import '../../abstracts/execucao_repository_interface.dart';

/// Atualiza a carga do exercicio atual em diante (mapa em memoria mantido
/// pelo controller) e registra o novo valor no historico de cargas.
class AlterarCargaCommand implements CommandInterface {
  AlterarCargaCommand({
    required this.exercicioId,
    required this.novaCarga,
    required this.cargas,
  });

  final String exercicioId;
  final double novaCarga;
  final RxMap<String, double> cargas;

  final ExecucaoRepositoryInterface _repository = Get.find();

  @override
  Future<void> execute() async {
    cargas[exercicioId] = novaCarga;
    await _repository.registrarCarga(
      RegistroCarga(
        exercicioId: exercicioId,
        data: DateTime.now(),
        carga: novaCarga,
      ),
    );
  }
}
