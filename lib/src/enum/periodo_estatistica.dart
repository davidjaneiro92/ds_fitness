/// Periodos do filtro de estatisticas (planejamento — tela 17).
enum PeriodoEstatistica {
  semana('Esta semana', 7),
  mes('Este mês', 30),
  trimestre('3 meses', 90),
  ano('Ano', 365),
  tudo('Tudo', 3650);

  const PeriodoEstatistica(this.label, this.dias);

  final String label;
  final int dias;
}

/// Filtros da tela de historico (planejamento — tela 16).
enum HistoricoFiltro {
  todos('Todos'),
  treinos('Treinos'),
  exercicios('Exercícios');

  const HistoricoFiltro(this.label);

  final String label;
}

/// Filtros da biblioteca de exercicios (planejamento — tela 18).
enum BibliotecaFiltro {
  todos('Todos'),
  favoritos('Favoritos'),
  recentes('Recentes');

  const BibliotecaFiltro(this.label);

  final String label;
}
