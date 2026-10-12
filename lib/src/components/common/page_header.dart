import 'package:flutter/material.dart';

import '../../core/theme/tokens/spacing_tokens.dart';
import '../../core/theme/tokens/typography_tokens.dart';

/// Cabecalho das telas do fluxo: titulo grande a esquerda, logo abaixo da seta
/// de voltar da `AppNavbar`, com um subtitulo opcional e uma acao a direita.
class PageHeader extends StatelessWidget {
  const PageHeader({
    required this.title,
    super.key,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: SpacingTokens.xs,
        bottom: SpacingTokens.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: TypographyTokens.pageTitle),
                if (subtitle != null) ...<Widget>[
                  const SizedBox(height: SpacingTokens.xs),
                  Text(subtitle!, style: TypographyTokens.bodyMuted),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
