import '../../../../models/registro_carga.dart';
import '../../../../models/usuario.dart';

/// Contrato de acesso a dados do Perfil (tela 20).
abstract class PerfilRepositoryInterface {
  Future<Usuario> obterUsuario();

  Future<List<MedidaCorporal>> obterMedidas();

  Future<Usuario> salvarUsuario(Usuario usuario);
}
