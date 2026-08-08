import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../components/cards/app_card.dart';
import '../../../../components/common/gap.dart';
import '../../../../components/common/section_header.dart';
import '../../../../components/feedback/app_snackbar.dart';
import '../../../../components/navbars/app_bottom_nav.dart';
import '../../../../components/scaffolds/app_scaffold.dart';
import '../../../../core/theme/tokens/color_tokens.dart';
import '../../../../core/theme/tokens/spacing_tokens.dart';
import '../../../../core/theme/tokens/typography_tokens.dart';
import '../../../../enum/app_tab.dart';
import '../../../../enum/pages_routes.dart';
import '../../../../models/usuario.dart';
import '../abstracts/home_controller_interface.dart';
import 'widgets/atalho_tile.dart';
import 'widgets/treino_do_dia_card.dart';

/// Tela 4 — Home (planejamento §4): saudacao, treino do dia, progresso
/// semanal e grid de atalhos.
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeControllerInterface controller = Get.find();

    return AppScaffold(
      bottomNav: const AppBottomNav(current: AppTab.home),
      body: Obx(() {
        if (controller.carregando.value) {
          return const Center(
            child: CircularProgressIndicator(color: ColorTokens.accent),
          );
        }
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Gap(SpacingTokens.md),
              _Saudacao(usuario: controller.usuario.value),
              const Gap(SpacingTokens.lg),
              TreinoDoDiaCard(
                treino: controller.treinoDoDia.value,
                onIniciar: controller.iniciarTreino,
              ),
              const Gap(SpacingTokens.lg),
              _ProgressoSemanal(
                atual: controller.treinosNaSemana.value,
                meta: controller.metaSemanal.value,
              ),
              const Gap(SpacingTokens.lg),
              const SectionHeader(title: 'Atalhos'),
              const _GridAtalhos(),
              const Gap(SpacingTokens.lg),
            ],
          ),
        );
      }),
    );
  }
}

class _Saudacao extends StatelessWidget {
  const _Saudacao({required this.usuario});

  final Usuario usuario;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Olá, ${usuario.primeiroNome}! 👋',
                style: TypographyTokens.screenTitle,
              ),
              const Gap(SpacingTokens.xxs),
              const Text('Bora treinar hoje?', style: TypographyTokens.bodyMuted),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => Get.toNamed<void>(PagesRoutes.perfil.path),
          child: Container(
            height: 44,
            width: 44,
            decoration: const BoxDecoration(
              color: ColorTokens.accentSoft,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              usuario.iniciais,
              style: TypographyTokens.bodyStrong.copyWith(
                color: ColorTokens.accent,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProgressoSemanal extends StatelessWidget {
  const _ProgressoSemanal({required this.atual, required this.meta});

  final int atual;
  final int meta;

  @override
  Widget build(BuildContext context) {
    final double progresso = meta == 0 ? 0 : atual / meta;
    return AppCard(
      onTap: () => Get.toNamed<void>(PagesRoutes.estatisticas.path),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Progresso semanal',
                  style: TypographyTokens.cardTitle,
                ),
                const Gap(SpacingTokens.xs),
                Text('$atual de $meta treinos', style: TypographyTokens.bodyStrong),
                const Gap(SpacingTokens.sm),
                AppProgressBar(value: progresso),
              ],
            ),
          ),
          const Gap.horizontal(SpacingTokens.sm),
          const Icon(
            Icons.chevron_right_rounded,
            color: ColorTokens.textSecondary,
          ),
        ],
      ),
    );
  }
}

class _GridAtalhos extends StatelessWidget {
  const _GridAtalhos();

  static const double _espacamento = SpacingTokens.sm + SpacingTokens.xs;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: _espacamento,
      crossAxisSpacing: _espacamento,
      childAspectRatio: 1,
      children: <Widget>[
        AtalhoTile(
          icon: Icons.fitness_center_rounded,
          label: 'Meus Treinos',
          onTap: () => Get.toNamed<void>(PagesRoutes.treinos.path),
        ),
        AtalhoTile(
          icon: Icons.history_rounded,
          label: 'Histórico',
          onTap: () => Get.toNamed<void>(PagesRoutes.historico.path),
        ),
        AtalhoTile(
          icon: Icons.grid_view_rounded,
          label: 'Exercícios',
          onTap: () => Get.toNamed<void>(PagesRoutes.biblioteca.path),
        ),
        AtalhoTile(
          icon: Icons.insights_rounded,
          label: 'Estatísticas',
          onTap: () => Get.toNamed<void>(PagesRoutes.estatisticas.path),
        ),
        AtalhoTile(
          icon: Icons.monitor_weight_outlined,
          label: 'Peso',
          onTap: () => AppSnackbar.info('Em breve'),
        ),
        AtalhoTile(
          icon: Icons.calendar_month_rounded,
          label: 'Calendário',
          onTap: () => AppSnackbar.info('Em breve'),
        ),
      ],
    );
  }
}
