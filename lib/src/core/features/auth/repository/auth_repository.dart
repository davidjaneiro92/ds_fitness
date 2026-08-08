import 'package:get/get.dart';

import '../../../../models/usuario.dart';
import '../../../abstracts/mock_database_interface.dart';
import '../abstracts/auth_repository_interface.dart';

/// Repository de autenticacao — implementacao mockada (planejamento §6).
class AuthRepository implements AuthRepositoryInterface {
  final MockDatabaseInterface _db = Get.find();

  @override
  Future<Usuario?> autenticar({
    required String email,
    required String senha,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    // Mock: qualquer e-mail/senha validos autenticam com o usuario da base.
    return _db.usuario;
  }

  @override
  Future<Usuario> registrar({
    required String nome,
    required String email,
    required DateTime dataNascimento,
    required String sexo,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    final Usuario novo = Usuario(
      id: 'u1',
      nome: nome,
      email: email,
      dataNascimento: dataNascimento,
      sexo: sexo,
      peso: 78,
      altura: 1.78,
    );
    _db.salvarUsuario(novo);
    return novo;
  }
}
