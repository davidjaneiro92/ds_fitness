import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../components/anatomy/grupo_muscular_icon.dart';
import '../../../../components/cards/app_card.dart';
import '../../../../components/navbars/app_navbar.dart';
import '../../../../components/scaffolds/app_scaffold.dart';
import '../../../../core/theme/tokens/color_tokens.dart';
import '../../../../core/theme/tokens/spacing_tokens.dart';
import '../../../../core/theme/tokens/typography_tokens.dart';
import '../../../../enum/grupo_muscular.dart';
import '../controller/grupos_controller.dart';

/// Tela 7 — selecao de grupo muscular (`/grupos`).
class GruposView extends GetView<GruposController> {
  const GruposView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<GrupoMuscular> grupos = controller.grupos;

    return AppScaffold(
      navbar: const AppNavbar(title: 'Selecionar grupo'),
      body: GridView.builder(
        padding: const EdgeInsets.only(
          top: SpacingTokens.sm,
          bottom: SpacingTokens.lg,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: SpacingTokens.sm + 4,
          mainAxisSpacing: SpacingTokens.sm + 4,
          childAspectRatio: 0.95,
        ),
        itemCount: grupos.length,
        itemBuilder: (BuildContext context, int index) {
          final GrupoMuscular grupo = grupos[index];
          return AppCard(
            padding: const EdgeInsets.all(SpacingTokens.sm),
            onTap: () => controller.selecionar(grupo),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                GrupoMuscularIcon(grupo: grupo, size: 40),
                const SizedBox(height: SpacingTokens.sm),
                Text(
                  grupo.label,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TypographyTokens.label.copyWith(
                    color: ColorTokens.textPrimary,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
