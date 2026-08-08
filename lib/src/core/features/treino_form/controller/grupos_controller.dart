import 'package:get/get.dart';

import '../../../../enum/grupo_muscular.dart';
import '../../../../enum/pages_routes.dart';
import '../../../../routes/route_args.dart';

/// Controller simples da tela 7: lista os grupos musculares e navega para
/// a lista de exercicios do grupo escolhido. Nao possui repository proprio.
class GruposController extends GetxController {
  /// Grupos exibidos no grid (inclui o atalho "Todos").
  List<GrupoMuscular> get grupos => GrupoMuscular.grid;

  void selecionar(GrupoMuscular grupo) {
    Get.toNamed<void>(
      PagesRoutes.exercicios.path,
      arguments: ExerciciosArgs(grupo: grupo),
    );
  }
}
