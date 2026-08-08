import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/tokens/color_tokens.dart';
import '../../core/theme/tokens/spacing_tokens.dart';
import '../../core/theme/tokens/typography_tokens.dart';
import '../buttons/app_button.dart';

/// Dialogo de confirmacao padrao. Sempre devolve `bool` — o dismiss (tocar
/// fora ou back) e tratado como `false`.
Future<bool> showAppConfirmDialog({
  required String title,
  String? message,
  String confirmLabel = 'Confirmar',
  String cancelLabel = 'Cancelar',
  bool danger = false,
}) async {
  final bool? resultado = await Get.dialog<bool>(
    Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: SpacingTokens.lg),
      child: Container(
        padding: const EdgeInsets.all(SpacingTokens.md),
        decoration: BoxDecoration(
          color: ColorTokens.bgSurface,
          borderRadius: BorderRadius.circular(SpacingTokens.radiusCard),
          border: Border.all(color: ColorTokens.divider),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: TypographyTokens.cardTitle),
            if (message != null) ...<Widget>[
              const SizedBox(height: SpacingTokens.sm),
              Text(message, style: TypographyTokens.bodyMuted),
            ],
            const SizedBox(height: SpacingTokens.lg),
            Row(
              children: <Widget>[
                Expanded(
                  child: AppButton(
                    label: cancelLabel,
                    variant: AppButtonVariant.ghost,
                    onPressed: () => Get.back<bool>(result: false),
                  ),
                ),
                const SizedBox(width: SpacingTokens.sm),
                Expanded(
                  child: AppButton(
                    label: confirmLabel,
                    variant:
                        danger ? AppButtonVariant.danger : AppButtonVariant.primary,
                    onPressed: () => Get.back<bool>(result: true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  return resultado ?? false;
}
