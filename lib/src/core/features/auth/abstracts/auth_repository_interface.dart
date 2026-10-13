import '../../../../models/usuario.dart';

/// Contrato do repository de autenticacao — fala com a API de autenticacao
/// e de cadastro (`/autenticacao` e `/cadastro/perfil`).
abstract class AuthRepositoryInterface {
  /// Autentica o usuario e devolve o perfil dele. Devolve `null` quando o
  /// e-mail ou a senha estao errados; qualquer outra falha (rede, servidor)
  /// lanca `ApiException`.
  Future<Usuario?> autenticar({required String email, required String senha});

  /// Cria a conta (auto-cadastro), entra com ela e grava o perfil. O e-mail e
  /// o login de acesso.
  Future<Usuario> registrar({
    required String nome,
    required String email,
    required String senha,
    required DateTime dataNascimento,
    required String sexo,
  });

  Future<void> solicitarRecuperacaoSenha({required String email});

  Future<void> redefinirSenha({
    required String email,
    required String codigo,
    required String novaSenha,
  });

  /// Revoga o refresh token no servidor e apaga a sessao local. A falha de
  /// rede nao impede o usuario de sair: a sessao local sempre e apagada.
  Future<void> encerrarSessao();
}
