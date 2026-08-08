import 'package:get/get.dart';

import '../../../../models/registro_carga.dart';
import '../../../../models/usuario.dart';
import '../../../abstracts/mock_database_interface.dart';
import '../abstracts/perfil_repository_interface.dart';

/// Implementacao mock do Perfil (tela 20).
class PerfilRepository implements PerfilRepositoryInterface {
  final MockDatabaseInterface _db = Get.find();

  @override
  Future<Usuario> obterUsuario() async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
    return _db.usuario;
  }

  @override
  Future<List<MedidaCorporal>> obterMedidas() async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
    return _db.medidas;
  }

  @override
  Future<Usuario> salvarUsuario(Usuario usuario) async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
    _db.salvarUsuario(usuario);
    return usuario;
  }
}
