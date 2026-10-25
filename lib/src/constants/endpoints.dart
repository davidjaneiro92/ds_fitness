import 'app_environment.dart';

/// Rotas da API (specs/02-infrastructure/api-configuration.md).
///
/// Nenhum callsite deve montar URL na mao: use estas constantes e os
/// builders abaixo. Os caminhos sao relativos ao `baseUrl` do `HttpManager`.
abstract class Endpoints {
  static const String _prefixo = '/api/${AppEnvironment.versaoApi}';

  // ── Autenticacao ───────────────────────────────────────────────────────
  static const String login = '$_prefixo/autenticacao/login';
  static const String refreshToken =
      '$_prefixo/autenticacao/login/refresh-token';
  static const String logoff = '$_prefixo/autenticacao/login/logoff';
  static const String autoCadastro = '$_prefixo/autenticacao/auto-cadastro';
  static const String solicitarRecuperacaoSenha =
      '$_prefixo/autenticacao/recuperar-senha/solicitar';
  static const String redefinirSenha =
      '$_prefixo/autenticacao/recuperar-senha/redefinir';

  // ── Log ────────────────────────────────────────────────────────────────
  static const String logErros = '$_prefixo/log/erros';

  // ── Cadastro ───────────────────────────────────────────────────────────
  static const String exercicios = '$_prefixo/cadastro/exercicios';
  static const String perfil = '$_prefixo/cadastro/perfil';
  static const String medidas = '$_prefixo/cadastro/medidas';

  static String exercicio(String id) => '$exercicios/$id';

  static String favoritoDoExercicio(String id) => '$exercicios/$id/favorito';

  static String acessoAoExercicio(String id) => '$exercicios/$id/acesso';

  // ── Treinos ────────────────────────────────────────────────────────────
  static const String treinos = '$_prefixo/treinos';
  static const String treinoDoDia = '$_prefixo/treinos/do-dia';
  static const String calculoTreinoPrevia = '$_prefixo/calculo-treino/previa';
  static const String calculoTreinoGerar = '$_prefixo/calculo-treino/gerar';

  static String treino(String id) => '$treinos/$id';

  static String duplicarTreino(String id) => '$treinos/$id/duplicar';

  // ── Execucao ───────────────────────────────────────────────────────────
  static const String sessoes = '$_prefixo/execucao/sessoes';
  static const String cargas = '$_prefixo/execucao/cargas';
  static const String estatisticas = '$_prefixo/execucao/estatisticas';
  static const String resumoDeExercicios =
      '$_prefixo/execucao/exercicios/resumo';

  static String evolucaoDeCarga(String exercicioId) => '$cargas/$exercicioId';
}
