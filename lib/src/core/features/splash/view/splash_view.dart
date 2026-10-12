import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../components/common/gap.dart';
import '../../../../components/scaffolds/app_scaffold.dart';
import '../../../theme/tokens/color_tokens.dart';
import '../../../theme/tokens/spacing_tokens.dart';
import '../../../theme/tokens/typography_tokens.dart';
import '../../auth/view/widgets/ds_logo.dart';
import '../abstracts/splash_controller_interface.dart';

/// Tela de splash (planejamento §3.1) — marca, slogan e loader. A navegacao
/// inicial (verifica sessao) e disparada pelo [SplashControllerInterface].
class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _escala;

  @override
  void initState() {
    super.initState();
    // Instancia o controller (lazyPut) e dispara a checagem de sessao.
    Get.find<SplashControllerInterface>();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _escala = Tween<double>(begin: 0.85, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _escala,
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                DsLogo(size: 56),
                Gap(SpacingTokens.lg),
                Text.rich(
                  TextSpan(
                    style: TypographyTokens.bodyStrong,
                    children: <InlineSpan>[
                      TextSpan(text: 'Sua jornada, '),
                      TextSpan(
                        text: 'seus resultados!',
                        style: TextStyle(color: ColorTokens.accent),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                Gap(SpacingTokens.xxl),
                SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      ColorTokens.accent,
                    ),
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
