import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../components/scaffolds/app_scaffold.dart';
import '../../../../constants/app_assets.dart';
import '../../../../core/theme/tokens/color_tokens.dart';
import '../../../../core/theme/tokens/spacing_tokens.dart';
import '../../../../core/theme/tokens/typography_tokens.dart';
import '../../../../enum/pages_routes.dart';
import '../abstracts/treino_ia_controller_interface.dart';
import 'widgets/treino_ia_widgets.dart';

/// Etapa 3/4: regiões com lesões ou limitações marcadas no mapa corporal.
class TreinoIaLesoesView extends GetView<TreinoIaControllerInterface> {
  const TreinoIaLesoesView({super.key});

  static const List<_LesaoAnchor> _ancoras = <_LesaoAnchor>[
    _LesaoAnchor('Pescoço', 0.16, _LadoMapa.esquerdo),
    _LesaoAnchor('Ombros', 0.29, _LadoMapa.esquerdo),
    _LesaoAnchor('Cotovelos', 0.43, _LadoMapa.esquerdo),
    _LesaoAnchor('Punhos', 0.55, _LadoMapa.esquerdo),
    _LesaoAnchor('Joelhos', 0.75, _LadoMapa.esquerdo),
    _LesaoAnchor('Tornozelos', 0.90, _LadoMapa.esquerdo),
    _LesaoAnchor('Costas', 0.37, _LadoMapa.direito),
    _LesaoAnchor('Lombar', 0.53, _LadoMapa.direito),
    _LesaoAnchor('Quadril', 0.65, _LadoMapa.direito),
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      navbar: PreferredSize(
        preferredSize: const Size.fromHeight(SpacingTokens.navBarHeight),
        child: Obx(() {
          final bool treinaEmCasa = controller.local.value == 'casa';
          return TreinoIaProgressHeader(
            etapaAtual: treinaEmCasa ? 3 : 2,
            totalEtapas: treinaEmCasa ? 4 : 3,
          );
        }),
      ),
      body: TreinoIaContentFrame(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const TreinoIaStepTitle(
              titulo: 'Alguma região precisa de cuidado?',
              descricao: 'Marque as áreas que quer proteger no treino.',
            ),
            Expanded(
              child: Obx(() {
                final Set<String> selecionadas =
                    controller.areasComLesao.toSet();
                return LayoutBuilder(builder: _buildMapa(selecionadas));
              }),
            ),
            Center(
              child: TextButton(
                onPressed: controller.limparLesoes,
                style: TextButton.styleFrom(
                  foregroundColor: ColorTokens.textSecondary,
                  padding: const EdgeInsets.symmetric(
                    vertical: SpacingTokens.xs,
                    horizontal: SpacingTokens.md,
                  ),
                ),
                child: const Text(
                  'Não tenho restrições',
                  style: TextStyle(decoration: TextDecoration.underline),
                ),
              ),
            ),
          ],
        ),
      ),
      footer: TreinoIaStepFooter(
        label: 'Continuar',
        onPressed: () => Get.toNamed<void>(PagesRoutes.treinoIaFoco.path),
      ),
    );
  }

  Widget Function(BuildContext, BoxConstraints) _buildMapa(
    Set<String> selecionadas,
  ) {
    return (BuildContext context, BoxConstraints constraints) => Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            Positioned.fill(
              child: Image.asset(
                AppAssets.iaMapaCorporal,
                fit: BoxFit.contain,
                cacheWidth: 900,
                errorBuilder: (
                  BuildContext context,
                  Object erro,
                  StackTrace? stackTrace,
                ) =>
                    const Icon(
                  Icons.accessibility_new_rounded,
                  size: 180,
                  color: ColorTokens.textSecondary,
                ),
              ),
            ),
            for (final _LesaoAnchor ancora in _ancoras)
              Positioned(
                left: ancora.lado == _LadoMapa.esquerdo ? 0 : null,
                right: ancora.lado == _LadoMapa.direito ? 0 : null,
                top: constraints.maxHeight * ancora.posicaoVertical,
                child: _LesaoMarker(
                  nome: ancora.nome,
                  lado: ancora.lado,
                  selecionada: selecionadas.contains(ancora.nome),
                  onTap: () => controller.alternarLesao(ancora.nome),
                ),
              ),
          ],
        );
  }
}

enum _LadoMapa { esquerdo, direito }

class _LesaoAnchor {
  const _LesaoAnchor(this.nome, this.posicaoVertical, this.lado);

  final String nome;
  final double posicaoVertical;
  final _LadoMapa lado;
}

class _LesaoMarker extends StatelessWidget {
  const _LesaoMarker({
    required this.nome,
    required this.lado,
    required this.selecionada,
    required this.onTap,
  });

  final String nome;
  final _LadoMapa lado;
  final bool selecionada;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color cor =
        selecionada ? ColorTokens.accent : ColorTokens.textSecondary;
    final Widget rotulo = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.sm,
        vertical: SpacingTokens.xs,
      ),
      decoration: BoxDecoration(
        color:
            selecionada ? ColorTokens.bgAccentSurface : ColorTokens.bgSurface,
        borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
        border: Border.all(
            color: selecionada ? ColorTokens.accent : ColorTokens.divider),
      ),
      child: Text(
        nome,
        style: TypographyTokens.caption.copyWith(
          color: selecionada ? ColorTokens.accent : ColorTokens.textPrimary,
        ),
      ),
    );
    final Widget ponto = Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: ColorTokens.bgPrimary,
        shape: BoxShape.circle,
        border: Border.all(color: cor, width: 2),
      ),
      child: Center(
        child: Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(color: cor, shape: BoxShape.circle),
        ),
      ),
    );
    final Widget ligacao = Container(
      width: 9,
      height: 1,
      color: selecionada ? ColorTokens.accent : ColorTokens.textSecondary,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: SpacingTokens.xxs),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: lado == _LadoMapa.esquerdo
                ? <Widget>[rotulo, ligacao, ponto]
                : <Widget>[ponto, ligacao, rotulo],
          ),
        ),
      ),
    );
  }
}
