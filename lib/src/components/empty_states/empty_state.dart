import 'package:flutter/material.dart';

import '../../core/theme/tokens/color_tokens.dart';
import '../../core/theme/tokens/spacing_tokens.dart';
import '../../core/theme/tokens/typography_tokens.dart';
import '../buttons/app_button.dart';

/// Estado vazio padrao: icone em circulo, titulo, mensagem e CTA opcional.
class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.icon,
    required this.title,
    super.key,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              height: 88,
              width: 88,
              decoration: const BoxDecoration(
                color: ColorTokens.bgSurface,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 38, color: ColorTokens.accent),
            ),
            const SizedBox(height: SpacingTokens.lg),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TypographyTokens.cardTitle,
            ),
            if (message != null) ...<Widget>[
              const SizedBox(height: SpacingTokens.sm),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: TypographyTokens.bodyMuted,
              ),
            ],
            if (actionLabel != null) ...<Widget>[
              const SizedBox(height: SpacingTokens.lg),
              AppButton(
                label: actionLabel!,
                onPressed: onAction,
                expanded: false,
                icon: Icons.add_rounded,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
