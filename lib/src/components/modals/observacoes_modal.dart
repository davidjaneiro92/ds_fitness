import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/tokens/color_tokens.dart';
import '../../core/theme/tokens/spacing_tokens.dart';
import '../../core/theme/tokens/typography_tokens.dart';
import '../buttons/app_button.dart';
import '../inputs/app_text_field.dart';
import 'app_modal_sheet.dart';

/// Resultado devolvido pelo modal de observacoes (tela 24).
class ObservacaoResultado {
  const ObservacaoResultado({required this.texto, required this.dificuldade});

  final String texto;
  final int dificuldade;
}

/// Abre o modal "Observações" (tela 24): texto livre sobre a execucao e
/// avaliacao de dificuldade em 5 estrelas.
Future<ObservacaoResultado?> showObservacoesModal({
  String? textoInicial,
  int dificuldadeInicial = 0,
}) {
  return showAppModalSheet<ObservacaoResultado>(
    title: 'Observações',
    child: _ObservacoesContent(
      textoInicial: textoInicial,
      dificuldadeInicial: dificuldadeInicial,
    ),
  );
}

class _ObservacoesContent extends StatefulWidget {
  const _ObservacoesContent({this.textoInicial, this.dificuldadeInicial = 0});

  final String? textoInicial;
  final int dificuldadeInicial;

  @override
  State<_ObservacoesContent> createState() => _ObservacoesContentState();
}

class _ObservacoesContentState extends State<_ObservacoesContent> {
  late final TextEditingController _controller;
  late int _dificuldade;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.textoInicial);
    _dificuldade = widget.dificuldadeInicial;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        AppTextField(
          label: 'Como foi a execução?',
          controller: _controller,
          hint: 'Ex.: Boa execução, senti mais foco na parte superior do peito...',
          maxLines: 4,
        ),
        const SizedBox(height: SpacingTokens.lg),
        const Text('Dificuldade', style: TypographyTokens.label),
        const SizedBox(height: SpacingTokens.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List<Widget>.generate(5, (int index) {
            final int valor = index + 1;
            final bool preenchida = valor <= _dificuldade;
            return InkWell(
              onTap: () => setState(() => _dificuldade = valor),
              borderRadius: BorderRadius.circular(SpacingTokens.radiusXs),
              child: Padding(
                padding: const EdgeInsets.all(SpacingTokens.xxs),
                child: Icon(
                  preenchida ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: 32,
                  color: ColorTokens.warning,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: SpacingTokens.lg),
        AppButton(
          label: 'Salvar',
          onPressed: () => Get.back<ObservacaoResultado>(
            result: ObservacaoResultado(texto: _controller.text, dificuldade: _dificuldade),
          ),
        ),
      ],
    );
  }
}
