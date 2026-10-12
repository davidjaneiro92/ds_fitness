/// Grupos musculares suportados (planejamento — tela 7).
enum GrupoMuscular {
  peito('peito', 'Peito'),
  costas('costas', 'Costas'),
  ombro('ombro', 'Ombros'),
  biceps('biceps', 'Bíceps'),
  triceps('triceps', 'Tríceps'),
  pernas('pernas', 'Pernas'),
  abdomen('abdomen', 'Abdômen'),
  gluteos('gluteos', 'Glúteos'),
  panturrilha('panturrilha', 'Panturrilha'),
  cardio('cardio', 'Cardio'),
  antebraco('antebraco', 'Antebraço'),
  todos('todos', 'Todos');

  const GrupoMuscular(this.slug, this.label);

  final String slug;
  final String label;

  /// Grupos exibidos no grid de selecao (inclui o atalho "Todos").
  static List<GrupoMuscular> get grid => GrupoMuscular.values;

  /// Grupos reais, sem o atalho "Todos".
  static List<GrupoMuscular> get reais =>
      GrupoMuscular.values.where((g) => g != GrupoMuscular.todos).toList();

  static GrupoMuscular fromSlug(String? slug) {
    return GrupoMuscular.values.firstWhere(
      (g) => g.slug == slug,
      orElse: () => GrupoMuscular.todos,
    );
  }
}
