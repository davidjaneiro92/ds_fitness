import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../components/cards/app_card.dart';
import '../../../../components/common/gap.dart';
import '../../../../components/common/page_header.dart';
import '../../../../components/navbars/app_bottom_nav.dart';
import '../../../../components/scaffolds/app_scaffold.dart';
import '../../../../core/theme/tokens/color_tokens.dart';
import '../../../../core/theme/tokens/spacing_tokens.dart';
import '../../../../core/theme/tokens/typography_tokens.dart';
import '../../../../enum/app_tab.dart';
import '../../../../models/usuario.dart';
import '../abstracts/home_controller_interface.dart';

/// Pagina inicial pos-login: a saudacao e duas escolhas — *Montar meu treino*
/// (abre o fluxo de criar um treino) e *Treinar* (a lista de treinos, de onde se
/// inicia um).
class HomeView extends GetView<HomeControllerInterface> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      bottomNav: const AppBottomNav(current: AppTab.home),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Gap(SpacingTokens.lg),
            Obx(() {
              final Usuario usuario = controller.usuario.value;
              return PageHeader(
                title: usuario.nome.trim().isEmpty
                    ? 'Olá!'
                    : 'Olá, ${usuario.primeiroNome}!',
                subtitle: 'O que você quer fazer?',
              );
            }),
            const Gap(SpacingTokens.md),
            _OpcaoCard(
              icon: Icons.assignment_outlined,
              titulo: 'Montar meu treino',
              descricao: 'Crie um treino personalizado do zero',
              onTap: controller.montarTreino,
            ),
            const Gap(SpacingTokens.md),
            _OpcaoCard(
              icon: Icons.fitness_center_rounded,
              titulo: 'Treinar',
              descricao: 'Acessar meus treinos e iniciar um treino',
              onTap: controller.treinar,
            ),
            const Gap(SpacingTokens.lg),
          ],
        ),
      ),
    );
  }
}

/// Uma das escolhas da pagina inicial: icone, titulo, descricao e seta.
class _OpcaoCard extends StatelessWidget {
  const _OpcaoCard({
    required this.icon,
    required this.titulo,
    required this.descricao,
    required this.onTap,
  });

  final IconData icon;
  final String titulo;
  final String descricao;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(SpacingTokens.lg - 4),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 44, color: ColorTokens.accent),
          const Gap.horizontal(SpacingTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(titulo, style: TypographyTokens.cardTitle),
                const Gap(SpacingTokens.xs),
                Text(descricao, style: TypographyTokens.bodyMuted),
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
