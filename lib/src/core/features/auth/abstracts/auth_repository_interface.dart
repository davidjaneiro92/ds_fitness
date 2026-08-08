import '../../../../models/usuario.dart';

/// Contrato do repository de autenticacao — fala apenas com
/// `MockDatabaseInterface` (fonte de dados unica enquanto tudo e mockado).
abstract class AuthRepositoryInterface {
  /// Autentica o usuario. No mock, qualquer e-mail/senha validos autenticam.
  Future<Usuario?> autenticar({required String email, required String senha});

  /// Cria um novo usuario e o persiste no `MockDatabaseInterface`.
  Future<Usuario> registrar({
    required String nome,
    required String email,
    required DateTime dataNascimento,
    required String sexo,
  });
}
