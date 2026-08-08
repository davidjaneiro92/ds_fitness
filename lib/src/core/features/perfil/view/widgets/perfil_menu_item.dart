import 'package:flutter/material.dart';

import '../../../../../components/common/gap.dart';
import '../../../../theme/tokens/color_tokens.dart';
import '../../../../theme/tokens/spacing_tokens.dart';
import '../../../../theme/tokens/typography_tokens.dart';

/// Item de menu do Perfil: icone + label + valor opcional + chevron.
class PerfilMenuItem extends StatelessWidget {
  const PerfilMenuItem({
    required this.icon,
    required this.label,
    super.key,
    this.value,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.md,
          vertical: SpacingTokens.md,
        ),
        child: Row(
          children: <Widget>[
            Icon(icon, size: 20, color: ColorTokens.textSecondary),
            const Gap.horizontal(SpacingTokens.sm),
            Expanded(
              child: Text(label, style: TypographyTokens.body),
            ),
            if (value != null) ...<Widget>[
              Text(value!, style: TypographyTokens.bodyMuted),
              const Gap.horizontal(SpacingTokens.sm),
            ],
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: ColorTokens.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
