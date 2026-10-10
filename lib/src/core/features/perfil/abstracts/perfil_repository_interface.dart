import '../../../../models/registro_carga.dart';
import '../../../../models/usuario.dart';

/// Contrato de acesso a dados do Perfil (tela 20) — fala com a API
/// (`/cadastro/perfil` e `/cadastro/medidas`).
abstract class PerfilRepositoryInterface {
  Future<Usuario> obterUsuario();

  /// A medida atual de cada item (a mais recente), com a variacao para a
  /// anterior. Vazio enquanto o usuario nao registrar nenhuma.
  Future<List<MedidaCorporal>> obterMedidas();

  Future<Usuario> salvarUsuario(Usuario usuario);
}
