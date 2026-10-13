import 'package:get/get.dart';

import '../core/features/auth/view/cadastro_view.dart';
import '../core/features/auth/view/esqueci_senha_view.dart';
import '../core/features/auth/view/login_view.dart';
import '../core/features/biblioteca/binding/biblioteca_binding.dart';
import '../core/features/biblioteca/view/biblioteca_view.dart';
import '../core/features/estatisticas/binding/estatisticas_binding.dart';
import '../core/features/estatisticas/view/estatisticas_view.dart';
import '../core/features/execucao/binding/execucao_binding.dart';
import '../core/features/execucao/view/execucao_view.dart';
import '../core/features/execucao/view/treino_concluido_view.dart';
import '../core/features/exercicio_detalhe/binding/exercicio_detalhe_binding.dart';
import '../core/features/exercicio_detalhe/view/exercicio_detalhe_view.dart';
import '../core/features/exercicio_form/binding/exercicio_form_binding.dart';
import '../core/features/exercicio_form/view/exercicio_form_view.dart';
import '../core/features/historico/binding/historico_binding.dart';
import '../core/features/historico/view/historico_view.dart';
import '../core/features/home/binding/home_binding.dart';
import '../core/features/home/view/home_view.dart';
import '../core/features/perfil/binding/perfil_binding.dart';
import '../core/features/perfil/view/perfil_view.dart';
import '../core/features/splash/binding/splash_binding.dart';
import '../core/features/splash/view/splash_view.dart';
import '../core/features/treino_form/binding/exercicios_binding.dart';
import '../core/features/treino_form/binding/treino_form_binding.dart';
import '../core/features/treino_form/view/exercicio_configurar_view.dart';
import '../core/features/treino_form/view/exercicios_view.dart';
import '../core/features/treino_form/view/grupos_view.dart';
import '../core/features/treino_form/view/treino_form_view.dart';
import '../core/features/treino_form/view/treino_revisar_view.dart';
import '../core/features/treinos/binding/treinos_binding.dart';
import '../core/features/treinos/view/treinos_view.dart';
import '../enum/pages_routes.dart';

/// Mapeamento unico de rotas do app (GetPages + bindings por rota).
abstract class AppPages {
  static const Transition _transition = Transition.cupertino;
  static const Duration _duration = Duration(milliseconds: 260);

  static final List<GetPage<dynamic>> pages = <GetPage<dynamic>>[
    GetPage<void>(
      name: PagesRoutes.splash.path,
      page: () => const SplashView(),
      binding: SplashBinding(),
      transition: Transition.fade,
    ),
    GetPage<void>(
      name: PagesRoutes.login.path,
      page: () => const LoginView(),
      transition: Transition.fadeIn,
      transitionDuration: _duration,
    ),
    GetPage<void>(
      name: PagesRoutes.cadastro.path,
      page: () => const CadastroView(),
      transition: _transition,
      transitionDuration: _duration,
    ),
    GetPage<void>(
      name: PagesRoutes.esqueciSenha.path,
      page: () => const EsqueciSenhaView(),
      transition: _transition,
      transitionDuration: _duration,
    ),
    GetPage<void>(
      name: PagesRoutes.home.path,
      page: () => const HomeView(),
      binding: HomeBinding(),
      transition: Transition.fadeIn,
      transitionDuration: _duration,
    ),
    GetPage<void>(
      name: PagesRoutes.treinos.path,
      page: () => const TreinosView(),
      binding: TreinosBinding(),
      transition: Transition.fadeIn,
      transitionDuration: _duration,
    ),
    GetPage<void>(
      name: PagesRoutes.treinoNovo.path,
      page: () => const TreinoFormView(),
      binding: TreinoFormBinding(),
      transition: _transition,
      transitionDuration: _duration,
    ),
    GetPage<void>(
      name: PagesRoutes.treinoRevisar.path,
      page: () => const TreinoRevisarView(),
      binding: TreinoFormBinding(),
      transition: _transition,
      transitionDuration: _duration,
    ),
    GetPage<void>(
      name: PagesRoutes.grupos.path,
      page: () => const GruposView(),
      transition: _transition,
      transitionDuration: _duration,
    ),
    GetPage<void>(
      name: PagesRoutes.exercicios.path,
      page: () => const ExerciciosView(),
      binding: ExerciciosBinding(),
      transition: _transition,
      transitionDuration: _duration,
    ),
    GetPage<void>(
      name: PagesRoutes.exercicioConfigurar.path,
      page: () => const ExercicioConfigurarView(),
      transition: _transition,
      transitionDuration: _duration,
    ),
    GetPage<void>(
      name: PagesRoutes.execucao.path,
      page: () => const ExecucaoView(),
      binding: ExecucaoBinding(),
      transition: Transition.downToUp,
      transitionDuration: _duration,
    ),
    GetPage<void>(
      name: PagesRoutes.execucaoConcluido.path,
      page: () => const TreinoConcluidoView(),
      transition: Transition.fadeIn,
      transitionDuration: _duration,
    ),
    GetPage<void>(
      name: PagesRoutes.historico.path,
      page: () => const HistoricoView(),
      binding: HistoricoBinding(),
      transition: _transition,
      transitionDuration: _duration,
    ),
    GetPage<void>(
      name: PagesRoutes.estatisticas.path,
      page: () => const EstatisticasView(),
      binding: EstatisticasBinding(),
      transition: _transition,
      transitionDuration: _duration,
    ),
    GetPage<void>(
      name: PagesRoutes.biblioteca.path,
      page: () => const BibliotecaView(),
      binding: BibliotecaBinding(),
      transition: Transition.fadeIn,
      transitionDuration: _duration,
    ),
    GetPage<void>(
      name: PagesRoutes.exercicioDetalhe.path,
      page: () => const ExercicioDetalheView(),
      binding: ExercicioDetalheBinding(),
      transition: _transition,
      transitionDuration: _duration,
    ),
    GetPage<void>(
      name: PagesRoutes.exercicioNovo.path,
      page: () => const ExercicioFormView(),
      binding: ExercicioFormBinding(),
      transition: _transition,
      transitionDuration: _duration,
    ),
    GetPage<void>(
      name: PagesRoutes.exercicioEditar.path,
      page: () => const ExercicioFormView(),
      binding: ExercicioFormBinding(),
      transition: _transition,
      transitionDuration: _duration,
    ),
    GetPage<void>(
      name: PagesRoutes.perfil.path,
      page: () => const PerfilView(),
      binding: PerfilBinding(),
      transition: Transition.fadeIn,
      transitionDuration: _duration,
    ),
  ];
}
