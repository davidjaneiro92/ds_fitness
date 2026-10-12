import 'package:get/get.dart';

import '../../../../models/usuario.dart';

/// Contrato do controller de autenticacao (permanente — planejamento §6).
abstract class AuthControllerInterface {
  Rx<Usuario> get usuario;

  RxBool get carregando;

  /// `true` quando ha um token de sessao valido salvo localmente.
  bool get logado;

  Future<bool> login({required String email, required String senha});

  Future<bool> cadastrar({
    required String nome,
    required String email,
    required String senha,
    required DateTime dataNascimento,
    required String sexo,
  });

  /// Entrar por uma conta externa: ainda nao ha suporte na API. Os botoes
  /// existem na tela de login, e tocar neles avisa que vem em breve.
  Future<void> loginComGoogle();

  Future<void> loginComApple();

  Future<void> loginComFacebook();

  Future<void> sair();
}
