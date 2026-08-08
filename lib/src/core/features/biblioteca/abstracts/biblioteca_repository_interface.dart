import '../../../../models/exercicio.dart';

/// Contrato de acesso a dados da Biblioteca de Exercicios (tela 18).
abstract class BibliotecaRepositoryInterface {
  Future<List<Exercicio>> listarExercicios();

  Future<List<Exercicio>> listarFavoritos();

  Future<List<Exercicio>> listarRecentes();

  Future<Exercicio> alternarFavorito(String id);

  Future<void> registrarAcesso(String id);
}
