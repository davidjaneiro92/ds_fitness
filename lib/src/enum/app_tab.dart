import 'pages_routes.dart';

/// Abas da navegacao inferior (`AppBottomNav`): Inicio, Treinos, Evolucao e
/// Perfil.
enum AppTab {
  home('Início', PagesRoutes.home),
  treinos('Treinos', PagesRoutes.treinos),
  evolucao('Evolução', PagesRoutes.estatisticas),
  perfil('Perfil', PagesRoutes.perfil);

  const AppTab(this.label, this.route);

  final String label;
  final PagesRoutes route;
}
