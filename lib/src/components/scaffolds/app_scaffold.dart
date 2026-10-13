import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens/color_tokens.dart';
import '../../core/theme/tokens/spacing_tokens.dart';

/// Scaffold padrao: fundo dark, safe area, navbar opcional, rodape fixo
/// opcional e bottom nav opcional.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    required this.body,
    super.key,
    this.navbar,
    this.bottomNav,
    this.footer,
    this.padding = const EdgeInsets.symmetric(
      horizontal: SpacingTokens.screenPadding,
    ),
    this.backgroundColor,
    this.backgroundImage,
    this.resizeToAvoidBottomInset = true,
  });

  final Widget body;
  final PreferredSizeWidget? navbar;
  final Widget? bottomNav;

  /// Area fixa acima do bottom nav (ex.: botao "Iniciar treino").
  final Widget? footer;
  final EdgeInsets padding;
  final Color? backgroundColor;
  final String? backgroundImage;
  final bool resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.systemOverlay,
      child: Scaffold(
        backgroundColor: backgroundColor ?? ColorTokens.bgPrimary,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        body: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            if (backgroundImage != null) ...<Widget>[
              Positioned.fill(
                child: Image.asset(backgroundImage!, fit: BoxFit.cover),
              ),
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[
                        Color.fromRGBO(0, 0, 0, 0.18),
                        Color.fromRGBO(0, 0, 0, 0.42),
                        Color.fromRGBO(0, 0, 0, 0.32),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            SafeArea(
              bottom: false,
              child: Column(
                children: <Widget>[
                  if (navbar != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: SpacingTokens.sm,
                      ),
                      child: navbar,
                    ),
                  Expanded(
                    child: Padding(padding: padding, child: body),
                  ),
                  if (footer != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        SpacingTokens.screenPadding,
                        SpacingTokens.sm,
                        SpacingTokens.screenPadding,
                        SpacingTokens.sm,
                      ),
                      child: SafeArea(
                        top: false,
                        bottom: bottomNav == null,
                        child: footer!,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: bottomNav,
      ),
    );
  }
}
