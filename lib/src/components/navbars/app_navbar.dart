import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/tokens/color_tokens.dart';
import '../../core/theme/tokens/spacing_tokens.dart';
import '../../core/theme/tokens/typography_tokens.dart';

/// Topo padrao: botao voltar, titulo centralizado e acao opcional a direita.
class AppNavbar extends StatelessWidget implements PreferredSizeWidget {
  const AppNavbar({
    super.key,
    this.title,
    this.subtitle,
    this.showBack = true,
    this.onBack,
    this.action,
    this.leading,
    this.centerTitle = true,
  });

  final String? title;
  final String? subtitle;
  final bool showBack;
  final VoidCallback? onBack;
  final Widget? action;
  final Widget? leading;
  final bool centerTitle;

  @override
  Size get preferredSize => const Size.fromHeight(SpacingTokens.navBarHeight);

  @override
  Widget build(BuildContext context) {
    final Widget? titleWidget = title == null
        ? null
        : Column(
            crossAxisAlignment: centerTitle
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                title!,
                style: TypographyTokens.screenTitle,
                overflow: TextOverflow.ellipsis,
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: TypographyTokens.caption,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          );

    final Widget? leadingWidget = leading ??
        (showBack
            ? _NavbarIconButton(
                icon: Icons.arrow_back_rounded,
                onTap: onBack ?? () => Get.back<void>(),
              )
            : null);

    // Stack em vez de Row: a acao pode ser mais larga que 48px (ex.: o
    // cronometro da execucao) sem estourar o titulo.
    return SizedBox(
      height: SpacingTokens.navBarHeight,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 64),
            child: Align(
              alignment:
                  centerTitle ? Alignment.center : Alignment.centerLeft,
              child: titleWidget ?? const SizedBox.shrink(),
            ),
          ),
          if (leadingWidget != null)
            Align(alignment: Alignment.centerLeft, child: leadingWidget),
          if (action != null)
            Align(alignment: Alignment.centerRight, child: action),
        ],
      ),
    );
  }
}

/// Botao circular usado na navbar (voltar, editar, fechar...).
class NavbarAction extends StatelessWidget {
  const NavbarAction({
    required this.icon,
    required this.onTap,
    super.key,
    this.color,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return _NavbarIconButton(icon: icon, onTap: onTap, color: color);
  }
}

class _NavbarIconButton extends StatelessWidget {
  const _NavbarIconButton({
    required this.icon,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
        child: Padding(
          padding: const EdgeInsets.all(SpacingTokens.sm),
          child: Icon(
            icon,
            size: 24,
            color: color ?? ColorTokens.textPrimary,
          ),
        ),
      ),
    );
  }
}
