import 'pages_routes.dart';

/// Abas da navegacao inferior (planejamento §1 — `AppBottomNav`).
enum AppTab {
  home('Home', PagesRoutes.home),
  treinos('Treinos', PagesRoutes.treinos),
  exercicios('Exercícios', PagesRoutes.biblioteca),
  perfil('Perfil', PagesRoutes.perfil);

  const AppTab(this.label, this.route);

  final String label;
  final PagesRoutes route;
}
