import '../../../../models/exercicio.dart';

/// Contrato de acesso a dados da Biblioteca de Exercicios (tela 18) — fala
/// com a API (`/cadastro/exercicios`).
abstract class BibliotecaRepositoryInterface {
  /// O catalogo do sistema mais os exercicios criados pelo usuario.
  Future<List<Exercicio>> listarExercicios();

  Future<List<Exercicio>> listarFavoritos();

  /// Os ultimos exercicios abertos, do mais recente para o mais antigo.
  Future<List<Exercicio>> listarRecentes();

  Future<Exercicio> alternarFavorito(String id);
}
