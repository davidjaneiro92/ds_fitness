import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../components/buttons/app_button.dart';
import '../../../../../core/theme/tokens/color_tokens.dart';
import '../../../../../core/theme/tokens/spacing_tokens.dart';
import '../../../../../core/theme/tokens/typography_tokens.dart';

/// Barra superior compartilhada pelas quatro etapas do gerador.
class TreinoIaProgressHeader extends StatelessWidget
    implements PreferredSizeWidget {
  const TreinoIaProgressHeader({
    required this.etapaAtual,
    super.key,
    this.onBack,
    this.totalEtapas = 4,
  });

  final int etapaAtual;
  final int totalEtapas;
  final VoidCallback? onBack;

  @override
  Size get preferredSize => const Size.fromHeight(SpacingTokens.navBarHeight);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints:
            const BoxConstraints(maxWidth: TreinoIaContentFrame.maxWidth),
        child: SizedBox(
          height: preferredSize.height,
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 40,
                child: IconButton(
                  tooltip: 'Voltar',
                  onPressed: onBack ?? () => Get.back<void>(),
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
              ),
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: SpacingTokens.md),
                  child: Row(
                    children: <Widget>[
                      for (int etapa = 1;
                          etapa <= totalEtapas;
                          etapa++) ...<Widget>[
                        if (etapa > 1)
                          Expanded(
                            child: Container(
                              height: 2,
                              color: etapa <= etapaAtual
                                  ? ColorTokens.accent
                                  : ColorTokens.divider,
                            ),
                          ),
                        Container(
                          width: 11,
                          height: 11,
                          decoration: BoxDecoration(
                            color: etapa <= etapaAtual
                                ? ColorTokens.accent
                                : ColorTokens.bgSurfaceAlt,
                            shape: BoxShape.circle,
                            border: etapa <= etapaAtual
                                ? null
                                : Border.all(color: ColorTokens.textSecondary),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 40,
                child: Text(
                  '$etapaAtual/$totalEtapas',
                  textAlign: TextAlign.end,
                  style: TypographyTokens.caption,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Mantém a largura do gerador próxima à proporção de uma tela de celular,
/// inclusive quando o app é aberto em uma janela desktop larga.
class TreinoIaContentFrame extends StatelessWidget {
  const TreinoIaContentFrame({required this.child, super.key});

  static const double maxWidth = 430;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: maxWidth),
        child: SizedBox(width: double.infinity, child: child),
      ),
    );
  }
}

class TreinoIaStepTitle extends StatelessWidget {
  const TreinoIaStepTitle({
    required this.titulo,
    super.key,
    this.etapa,
    this.descricao,
  });

  final String titulo;
  final String? etapa;
  final String? descricao;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: SpacingTokens.xs,
        bottom: SpacingTokens.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (etapa != null && etapa!.isNotEmpty) ...<Widget>[
            Text(
              etapa!.toUpperCase(),
              style: TypographyTokens.caption.copyWith(
                color: ColorTokens.accent,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: SpacingTokens.xs),
          ],
          Text(
            titulo,
            style: TypographyTokens.pageTitle.copyWith(fontSize: 24),
          ),
          if (descricao != null && descricao!.isNotEmpty) ...<Widget>[
            const SizedBox(height: SpacingTokens.xs),
            Text(descricao!, style: TypographyTokens.bodyMuted),
          ],
        ],
      ),
    );
  }
}

class TreinoIaStepFooter extends StatelessWidget {
  const TreinoIaStepFooter({
    required this.label,
    required this.onPressed,
    super.key,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) => TreinoIaContentFrame(
        child: AppButton(
          label: label,
          icon: Icons.arrow_forward_rounded,
          onPressed: onPressed,
          loading: loading,
        ),
      );
}
