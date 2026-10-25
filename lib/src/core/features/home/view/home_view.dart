import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../components/cards/app_card.dart';
import '../../../../components/scaffolds/app_scaffold.dart';
import '../../../../core/theme/tokens/color_tokens.dart';
import '../../../../core/theme/tokens/spacing_tokens.dart';
import '../../../../core/theme/tokens/typography_tokens.dart';
import '../../../../enum/pages_routes.dart';
import '../abstracts/home_controller_interface.dart';

/// Página inicial pós-login: criação manual, criação com IA ou treino.
class HomeView extends GetView<HomeControllerInterface> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      bottomNav: const _HomeBottomNav(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          top: SpacingTokens.xl,
          bottom: SpacingTokens.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('Olá!', style: TypographyTokens.displaySm),
            const SizedBox(height: SpacingTokens.xs),
            Text(
              'O que você quer fazer?',
              style: TypographyTokens.screenTitle.copyWith(
                fontSize: 21,
                color: ColorTokens.textPrimary,
              ),
            ),
            const SizedBox(height: SpacingTokens.xl),
            _HomeChoiceCard(
              icon: Icons.fitness_center_rounded,
              title: 'Montar meu treino',
              description: 'Crie e organize cada exercício manualmente',
              onTap: controller.montarTreino,
            ),
            const SizedBox(height: SpacingTokens.md),
            _HomeChoiceCard(
              icon: Icons.psychology_rounded,
              title: 'Montar meu treino com IA',
              description: 'Receba uma sugestão semanal personalizada',
              highlighted: true,
              onTap: controller.montarTreinoIa,
            ),
            const SizedBox(height: SpacingTokens.md),
            _HomeChoiceCard(
              icon: Icons.directions_run_rounded,
              title: 'Treinar',
              description: 'Acesse seus treinos e comece agora',
              onTap: controller.treinar,
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeChoiceCard extends StatelessWidget {
  const _HomeChoiceCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
    this.highlighted = false,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      highlighted: highlighted,
      background: highlighted ? ColorTokens.bgAccentSurface : null,
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: SizedBox(
        height: 122,
        child: Row(
          children: <Widget>[
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: ColorTokens.bgAccentSurface,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: ColorTokens.accent),
            ),
            const SizedBox(width: SpacingTokens.md),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (highlighted) ...<Widget>[
                    const Text(
                      'Montar meu treino',
                      style: TypographyTokens.cardTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: SpacingTokens.xxs),
                    const Row(
                      children: <Widget>[
                        Text('com IA', style: TypographyTokens.cardTitle),
                        SizedBox(width: SpacingTokens.sm),
                        _AutomaticBadge(),
                      ],
                    ),
                  ] else
                    Text(
                      title,
                      style: TypographyTokens.cardTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: SpacingTokens.xs),
                  Text(
                    description,
                    style: TypographyTokens.bodyMuted,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: SpacingTokens.sm),
            const Icon(
              Icons.chevron_right_rounded,
              color: ColorTokens.textPrimary,
              size: 26,
            ),
          ],
        ),
      ),
    );
  }
}

class _AutomaticBadge extends StatelessWidget {
  const _AutomaticBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.sm,
        vertical: SpacingTokens.xxs,
      ),
      decoration: BoxDecoration(
        color: ColorTokens.accent,
        borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
      ),
      child: const Text(
        'AUTOMÁTICO',
        style: TextStyle(
          color: ColorTokens.textOnAccent,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

/// Navegação inferior da Home conforme o mockup aprovado.
class _HomeBottomNav extends StatelessWidget {
  const _HomeBottomNav();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: ColorTokens.bgSurface,
        border: Border(top: BorderSide(color: ColorTokens.divider)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: SpacingTokens.bottomNavHeight,
          child: Row(
            children: <Widget>[
              const Expanded(
                child: _HomeNavItem(
                  icon: Icons.home_rounded,
                  label: 'Início',
                  selected: true,
                ),
              ),
              Expanded(
                child: _HomeNavItem(
                  icon: Icons.bar_chart_rounded,
                  label: 'Histórico',
                  onTap: () =>
                      Get.offAllNamed<void>(PagesRoutes.historico.path),
                ),
              ),
              Expanded(
                child: _HomeNavItem(
                  icon: Icons.person_outline_rounded,
                  label: 'Perfil',
                  onTap: () => Get.offAllNamed<void>(PagesRoutes.perfil.path),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeNavItem extends StatelessWidget {
  const _HomeNavItem({
    required this.icon,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color color =
        selected ? ColorTokens.accent : ColorTokens.textSecondary;
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(icon, size: 24, color: color),
          const SizedBox(height: SpacingTokens.xs),
          Text(
            label,
            style: TypographyTokens.caption.copyWith(
              color: color,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
