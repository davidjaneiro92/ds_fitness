import '../../enum/grupo_muscular.dart';
import '../../models/exercicio.dart';
import '../../models/registro_carga.dart';
import '../../models/sessao.dart';
import '../../models/treino.dart';
import '../../models/usuario.dart';

/// Fonte de dados unica do app enquanto tudo e mockado.
///
/// Os repositories das features falam **somente** com este contrato — trocar
/// o mock por uma API real significa criar outra implementacao desta interface
/// (ou repositories que usem um `HttpManager`), sem tocar em controller/view.
abstract class MockDatabaseInterface {
  // ── Usuario ────────────────────────────────────────────────────────────
  Usuario get usuario;

  void salvarUsuario(Usuario novo);

  List<MedidaCorporal> get medidas;

  // ── Catalogo de exercicios ─────────────────────────────────────────────
  List<Exercicio> get exercicios;

  List<Exercicio> exerciciosPorGrupo(GrupoMuscular grupo);

  Exercicio? exercicioPorId(String id);

  /// Alterna o favorito e devolve o exercicio atualizado.
  Exercicio alternarFavorito(String exercicioId);

  List<Exercicio> get favoritos;

  List<Exercicio> get recentes;

  void registrarAcesso(String exercicioId);

  // ── Treinos ────────────────────────────────────────────────────────────
  List<Treino> get treinos;

  Treino? treinoPorId(String id);

  /// Treino sugerido para hoje (usado no card de destaque da home).
  Treino? get treinoDoDia;

  /// Insere (quando o id nao existe) ou atualiza; devolve o treino salvo.
  Treino salvarTreino(Treino treino);

  void excluirTreino(String id);

  /// Cria uma copia com sufixo "(cópia)" e devolve o novo treino.
  Treino duplicarTreino(String id);

  // ── Sessoes / historico ────────────────────────────────────────────────
  List<Sessao> get sessoes;

  Sessao? sessaoPorId(String id);

  void adicionarSessao(Sessao sessao);

  /// Quantidade de sessoes concluidas na semana corrente.
  int get treinosNaSemana;

  // ── Evolucao de carga ──────────────────────────────────────────────────
  List<RegistroCarga> registrosDeCarga(String exercicioId);

  void registrarCarga(RegistroCarga registro);

  /// Maior carga ja registrada para o exercicio (null se nunca treinado).
  RegistroCarga? recordePessoal(String exercicioId);

  // ── Utilitarios ────────────────────────────────────────────────────────
  /// Gera um id unico com o prefixo informado (ex.: `te_7`).
  String novoId(String prefixo);
}
