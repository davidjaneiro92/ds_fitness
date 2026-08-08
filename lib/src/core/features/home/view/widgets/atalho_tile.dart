import 'package:flutter/material.dart';

import '../../../../../components/cards/app_card.dart';
import '../../../../../core/theme/tokens/color_tokens.dart';
import '../../../../../core/theme/tokens/spacing_tokens.dart';
import '../../../../../core/theme/tokens/typography_tokens.dart';

/// Tile do grid de atalhos da Home: icone verde em circulo + label.
class AtalhoTile extends StatelessWidget {
  const AtalhoTile({
    required this.icon,
    required this.label,
    super.key,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(SpacingTokens.sm),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            height: 40,
            width: 40,
            decoration: const BoxDecoration(
              color: ColorTokens.accentSoft,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 24, color: ColorTokens.accent),
          ),
          const SizedBox(height: SpacingTokens.xs),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TypographyTokens.label.copyWith(color: ColorTokens.textPrimary),
          ),
        ],
      ),
    );
  }
}
