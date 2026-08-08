import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/tokens/color_tokens.dart';
import '../../core/theme/tokens/spacing_tokens.dart';
import '../../core/theme/tokens/typography_tokens.dart';

/// Abre um [AppModalSheet] como bottom sheet, respeitando teclado e altura
/// maxima de 85% da tela.
Future<T?> showAppModalSheet<T>({
  required String title,
  required Widget child,
  VoidCallback? onClose,
  bool isScrollControlled = true,
}) {
  return Get.bottomSheet<T>(
    AppModalSheet(title: title, onClose: onClose, child: child),
    isScrollControlled: isScrollControlled,
    backgroundColor: Colors.transparent,
  );
}

/// Superficie padrao de bottom sheet: handle, header com titulo e botao de
/// fechar, divisor e conteudo rolavel.
class AppModalSheet extends StatelessWidget {
  const AppModalSheet({
    required this.title,
    required this.child,
    super.key,
    this.onClose,
  });

  final String title;
  final Widget child;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final double alturaMaxima = MediaQuery.of(context).size.height * 0.85;
    final double inset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: inset),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: alturaMaxima),
        child: Container(
          decoration: const BoxDecoration(
            color: ColorTokens.bgSurface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(SpacingTokens.radiusLg + 4),
              topRight: Radius.circular(SpacingTokens.radiusLg + 4),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(height: SpacingTokens.sm),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: ColorTokens.divider,
                    borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    SpacingTokens.md,
                    SpacingTokens.md,
                    SpacingTokens.md,
                    SpacingTokens.sm,
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          title,
                          style: TypographyTokens.cardTitle,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      InkWell(
                        borderRadius: BorderRadius.circular(SpacingTokens.radiusXs),
                        onTap: onClose ?? () => Get.back<void>(),
                        child: const Padding(
                          padding: EdgeInsets.all(SpacingTokens.xs),
                          child: Icon(
                            Icons.close_rounded,
                            size: 20,
                            color: ColorTokens.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: ColorTokens.divider),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      SpacingTokens.md,
                      SpacingTokens.md,
                      SpacingTokens.md,
                      SpacingTokens.lg,
                    ),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
