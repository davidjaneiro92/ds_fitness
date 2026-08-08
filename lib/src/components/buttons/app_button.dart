import 'package:flutter/material.dart';

import '../../core/theme/tokens/color_tokens.dart';
import '../../core/theme/tokens/spacing_tokens.dart';
import '../../core/theme/tokens/typography_tokens.dart';

/// Variantes visuais do [AppButton].
enum AppButtonVariant { primary, outline, ghost, danger, surface }

/// Tamanhos do [AppButton].
enum AppButtonSize { small, medium }

/// Botao padrao do app — verde solido, contorno, fantasma ou perigo.
class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    super.key,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.icon,
    this.loading = false,
    this.expanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? icon;
  final bool loading;
  final bool expanded;

  bool get _enabled => onPressed != null && !loading;

  Color get _background {
    if (!_enabled) {
      return variant == AppButtonVariant.primary
          ? ColorTokens.bgSurfaceAlt
          : Colors.transparent;
    }
    switch (variant) {
      case AppButtonVariant.primary:
        return ColorTokens.accent;
      case AppButtonVariant.danger:
        return ColorTokens.danger;
      case AppButtonVariant.surface:
        return ColorTokens.bgSurfaceAlt;
      case AppButtonVariant.outline:
      case AppButtonVariant.ghost:
        return Colors.transparent;
    }
  }

  Color get _foreground {
    if (!_enabled) {
      return ColorTokens.textDisabled;
    }
    switch (variant) {
      case AppButtonVariant.primary:
        return ColorTokens.textOnAccent;
      case AppButtonVariant.danger:
        return ColorTokens.textPrimary;
      case AppButtonVariant.surface:
        return ColorTokens.textPrimary;
      case AppButtonVariant.outline:
        return ColorTokens.accent;
      case AppButtonVariant.ghost:
        return ColorTokens.textSecondary;
    }
  }

  BorderSide get _border {
    if (variant != AppButtonVariant.outline) {
      return BorderSide.none;
    }
    return BorderSide(
      color: _enabled ? ColorTokens.accent : ColorTokens.divider,
      width: 1.4,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double height = size == AppButtonSize.small
        ? SpacingTokens.buttonHeightSm
        : SpacingTokens.buttonHeight;

    final Widget content = loading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              valueColor: AlwaysStoppedAnimation<Color>(_foreground),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (icon != null) ...<Widget>[
                Icon(icon, size: size == AppButtonSize.small ? 16 : 18),
                const SizedBox(width: SpacingTokens.sm),
              ],
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TypographyTokens.button.copyWith(
                    color: _foreground,
                    fontSize: size == AppButtonSize.small ? 13 : 15,
                  ),
                ),
              ),
            ],
          );

    return SizedBox(
      height: height,
      width: expanded ? double.infinity : null,
      child: Material(
        color: _background,
        borderRadius: BorderRadius.circular(SpacingTokens.radiusButton),
        child: InkWell(
          onTap: _enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(SpacingTokens.radiusButton),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(SpacingTokens.radiusButton),
              border: Border.fromBorderSide(_border),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: expanded ? SpacingTokens.md : SpacingTokens.lg,
              ),
              child: Center(
                child: IconTheme(
                  data: IconThemeData(color: _foreground),
                  child: content,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
