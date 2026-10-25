import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../components/cards/app_card.dart';
import '../../../../components/common/gap.dart';
import '../../../../components/scaffolds/app_scaffold.dart';
import '../../../../constants/app_assets.dart';
import '../../../../core/theme/tokens/color_tokens.dart';
import '../../../../core/theme/tokens/spacing_tokens.dart';
import '../../../../core/theme/tokens/typography_tokens.dart';
import '../../../../enum/pages_routes.dart';
import '../../../../models/usuario.dart';
import '../abstracts/treino_ia_controller_interface.dart';
import 'widgets/treino_ia_widgets.dart';

/// Etapa 2: objetivo do perfil, nível e local do treino.
class TreinoIaPreferenciasView extends GetView<TreinoIaControllerInterface> {
  const TreinoIaPreferenciasView({super.key});

  @override
  Widget build(BuildContext context) {
    final TreinoIaControllerInterface estado = controller;
    return AppScaffold(
      navbar: PreferredSize(
        preferredSize: const Size.fromHeight(SpacingTokens.navBarHeight),
        child: Obx(
          () => TreinoIaProgressHeader(
            etapaAtual: 2,
            totalEtapas: estado.totalEtapas,
          ),
        ),
      ),
      body: TreinoIaContentFrame(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: SpacingTokens.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const TreinoIaStepTitle(titulo: 'Personalize seu treino'),
              Obx(() => _ObjetivoCard(usuario: estado.usuario.value)),
              const Gap(SpacingTokens.md),
              const _Secao(titulo: 'Nível de experiência'),
              Obx(
                () => Row(
                  children: <Widget>[
                    Expanded(
                      child: _NivelCard(
                        icon: Icons.directions_run_rounded,
                        titulo: 'Iniciante',
                        selecionado: estado.nivel.value == 'iniciante',
                        onTap: () => estado.selecionarNivel('iniciante'),
                      ),
                    ),
                    const SizedBox(width: SpacingTokens.sm),
                    Expanded(
                      child: _NivelCard(
                        icon: Icons.bar_chart_rounded,
                        titulo: 'Intermediário',
                        selecionado: estado.nivel.value == 'intermediario',
                        onTap: () => estado.selecionarNivel('intermediario'),
                      ),
                    ),
                    const SizedBox(width: SpacingTokens.sm),
                    Expanded(
                      child: _NivelCard(
                        icon: Icons.fitness_center_rounded,
                        titulo: 'Avançado',
                        selecionado: estado.nivel.value == 'avancado',
                        onTap: () => estado.selecionarNivel('avancado'),
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(SpacingTokens.md),
              const _Secao(titulo: 'Onde vai treinar?'),
              Obx(
                () => Row(
                  children: <Widget>[
                    Expanded(
                      child: _LocalCard(
                        titulo: 'Academia',
                        asset: AppAssets.iaAcademia,
                        selecionado: estado.local.value == 'academia',
                        onTap: () => estado.selecionarLocal('academia'),
                      ),
                    ),
                    const SizedBox(width: SpacingTokens.sm),
                    Expanded(
                      child: _LocalCard(
                        titulo: 'Em casa',
                        asset: AppAssets.iaCasa,
                        selecionado: estado.local.value == 'casa',
                        onTap: () => estado.selecionarLocal('casa'),
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(SpacingTokens.sm),
              const _InfoNote(
                texto: 'Na academia, consideramos os equipamentos padrão. '
                    'Em casa, você escolhe o que tem disponível.',
              ),
            ],
          ),
        ),
      ),
      footer: Obx(() {
        final bool treinaEmCasa = estado.local.value == 'casa';
        return TreinoIaStepFooter(
          label: 'Continuar',
          onPressed: () => Get.toNamed<void>(
            treinaEmCasa
                ? PagesRoutes.treinoIaEquipamentos.path
                : PagesRoutes.treinoIaLesoes.path,
          ),
        );
      }),
    );
  }
}

class _ObjetivoCard extends StatelessWidget {
  const _ObjetivoCard({required this.usuario});

  final Usuario? usuario;

  @override
  Widget build(BuildContext context) {
    final Usuario? perfil = usuario;
    return AppCard(
      onTap: () => Get.toNamed<void>(PagesRoutes.perfil.path),
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: Row(
        children: <Widget>[
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: ColorTokens.bgAccentSurface,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.fitness_center_rounded,
              color: ColorTokens.accent,
            ),
          ),
          const SizedBox(width: SpacingTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  perfil?.objetivo.label ?? 'Objetivo de treino',
                  style: TypographyTokens.cardTitle,
                ),
                const SizedBox(height: SpacingTokens.xxs),
                Text(
                  perfil == null
                      ? 'Seu perfil define a frequência semanal'
                      : '${perfil.metaTreinosSemana} dias por semana',
                  style: TypographyTokens.bodyMuted,
                ),
              ],
            ),
          ),
          const SizedBox(width: SpacingTokens.sm),
          const Icon(
            Icons.chevron_right_rounded,
            color: ColorTokens.textSecondary,
          ),
        ],
      ),
    );
  }
}

class _Secao extends StatelessWidget {
  const _Secao({required this.titulo});

  final String titulo;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: SpacingTokens.sm),
        child: Text(titulo, style: TypographyTokens.cardTitle),
      );
}

class _NivelCard extends StatelessWidget {
  const _NivelCard({
    required this.icon,
    required this.titulo,
    required this.selecionado,
    required this.onTap,
  });

  final IconData icon;
  final String titulo;
  final bool selecionado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      highlighted: selecionado,
      background: selecionado ? ColorTokens.bgAccentSurface : null,
      padding: const EdgeInsets.all(SpacingTokens.xs),
      child: SizedBox(
        height: 92,
        child: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.topRight,
              child: Icon(
                selecionado
                    ? Icons.check_circle_rounded
                    : Icons.circle_outlined,
                color: selecionado
                    ? ColorTokens.accent
                    : ColorTokens.textSecondary,
                size: 18,
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    icon,
                    size: 34,
                    color: selecionado
                        ? ColorTokens.accent
                        : ColorTokens.textSecondary,
                  ),
                  const SizedBox(height: SpacingTokens.xs),
                  Text(
                    titulo,
                    style: TypographyTokens.caption.copyWith(
                      color: selecionado
                          ? ColorTokens.textPrimary
                          : ColorTokens.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocalCard extends StatelessWidget {
  const _LocalCard({
    required this.titulo,
    required this.asset,
    required this.selecionado,
    required this.onTap,
  });

  final String titulo;
  final String asset;
  final bool selecionado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      highlighted: selecionado,
      background: selecionado ? ColorTokens.bgAccentSurface : null,
      padding: const EdgeInsets.all(SpacingTokens.xs),
      child: SizedBox(
        height: 120,
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              bottom: 22,
              child: Padding(
                padding: const EdgeInsets.all(SpacingTokens.xs),
                child: Image.asset(
                  asset,
                  fit: BoxFit.contain,
                  cacheWidth: 360,
                  errorBuilder: (
                    BuildContext context,
                    Object erro,
                    StackTrace? stackTrace,
                  ) =>
                      const Icon(
                    Icons.fitness_center_rounded,
                    color: ColorTokens.accent,
                    size: 48,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: Icon(
                selecionado
                    ? Icons.check_circle_rounded
                    : Icons.circle_outlined,
                color: selecionado
                    ? ColorTokens.accent
                    : ColorTokens.textSecondary,
                size: 18,
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Text(titulo, style: TypographyTokens.bodyStrong),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoNote extends StatelessWidget {
  const _InfoNote({required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      background: ColorTokens.bgSurface,
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.md,
        vertical: SpacingTokens.sm,
      ),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.info_rounded,
            color: ColorTokens.textSecondary,
            size: 20,
          ),
          const SizedBox(width: SpacingTokens.sm),
          Expanded(child: Text(texto, style: TypographyTokens.caption)),
        ],
      ),
    );
  }
}
