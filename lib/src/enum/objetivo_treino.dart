/// Objetivo de um treino / do usuario (planejamento — telas 6 e 20).
enum ObjetivoTreino {
  hipertrofia('hipertrofia', 'Hipertrofia'),
  emagrecimento('emagrecimento', 'Emagrecimento'),
  forca('forca', 'Força'),
  resistencia('resistencia', 'Resistência'),
  condicionamento('condicionamento', 'Condicionamento');

  const ObjetivoTreino(this.slug, this.label);

  final String slug;
  final String label;

  static ObjetivoTreino fromSlug(String? slug) {
    return ObjetivoTreino.values.firstWhere(
      (o) => o.slug == slug,
      orElse: () => ObjetivoTreino.hipertrofia,
    );
  }
}
