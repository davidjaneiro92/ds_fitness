import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../components/cards/app_card.dart';
import '../../../../components/common/gap.dart';
import '../../../../components/inputs/app_text_field.dart';
import '../../../../components/scaffolds/app_scaffold.dart';
import '../../../../core/theme/tokens/color_tokens.dart';
import '../../../../core/theme/tokens/spacing_tokens.dart';
import '../../../../core/theme/tokens/typography_tokens.dart';
import '../abstracts/treino_ia_controller_interface.dart';
import 'widgets/treino_ia_widgets.dart';

/// Etapa 1: peso e altura. O IMC aparece na hora e decide quanto o treino é
/// adaptado (volume, descanso, cardio, impacto). Vem preenchido com o perfil e
/// o que for digitado volta para o perfil.
class TreinoIaDadosView extends StatefulWidget {
  const TreinoIaDadosView({super.key});

  @override
  State<TreinoIaDadosView> createState() => _TreinoIaDadosViewState();
}

class _TreinoIaDadosViewState extends State<TreinoIaDadosView> {
  final TreinoIaControllerInterface _controller = Get.find();
  final TextEditingController _pesoController = TextEditingController();
  final TextEditingController _alturaController = TextEditingController();
  late final Worker _aoCarregarPerfil;

  @override
  void initState() {
    super.initState();
    _preencherCampos();
    // O perfil chega depois da primeira montagem da tela.
    _aoCarregarPerfil =
        ever<bool>(_controller.carregandoPerfil, (bool carregando) {
      if (!carregando) _preencherCampos();
    });
  }

  @override
  void dispose() {
    _aoCarregarPerfil.dispose();
    _pesoController.dispose();
    _alturaController.dispose();
    super.dispose();
  }

  void _preencherCampos() {
    final double peso = _controller.peso.value;
    final double altura = _controller.altura.value;
    if (_pesoController.text.isEmpty && peso > 0) {
      _pesoController.text = _formatar(peso);
    }
    if (_alturaController.text.isEmpty && altura > 0) {
      _alturaController.text = (altura * 100).round().toString();
    }
  }

  String _formatar(double valor) {
    final bool inteiro = valor == valor.roundToDouble();
    return (inteiro ? valor.toStringAsFixed(0) : valor.toStringAsFixed(1))
        .replaceAll('.', ',');
  }

  double _numero(String texto) =>
      double.tryParse(texto.trim().replaceAll(',', '.')) ?? 0;

  @override
  Widget build(BuildContext context) {
    final TreinoIaControllerInterface estado = _controller;
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) estado.descartarAoSair();
      },
      child: AppScaffold(
        navbar: PreferredSize(
          preferredSize: const Size.fromHeight(SpacingTokens.navBarHeight),
          child: Obx(
            () => TreinoIaProgressHeader(
              etapaAtual: 1,
              totalEtapas: estado.totalEtapas,
              onBack: estado.cancelar,
            ),
          ),
        ),
        body: TreinoIaContentFrame(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: SpacingTokens.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const TreinoIaStepTitle(
                  titulo: 'Seus dados',
                  descricao: 'Com peso e altura calculamos seu IMC e adaptamos '
                      'o volume, o descanso e o cardio do treino ao seu corpo.',
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: AppTextField(
                        label: 'Peso (kg)',
                        hint: 'Ex.: 78,5',
                        controller: _pesoController,
                        prefixIcon: Icons.monitor_weight_outlined,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d{0,3}([.,]\d{0,1})?'),
                          ),
                        ],
                        onChanged: (String texto) =>
                            estado.definirPeso(_numero(texto)),
                      ),
                    ),
                    const SizedBox(width: SpacingTokens.sm),
                    Expanded(
                      child: AppTextField(
                        label: 'Altura (cm)',
                        hint: 'Ex.: 175',
                        controller: _alturaController,
                        prefixIcon: Icons.height_rounded,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(3),
                        ],
                        onChanged: (String texto) =>
                            estado.definirAltura(_numero(texto) / 100),
                      ),
                    ),
                  ],
                ),
                const Gap(SpacingTokens.md),
                Obx(
                  () => _ImcCard(
                    imc: estado.imc,
                    classificacao: estado.classificacaoImc,
                  ),
                ),
              ],
            ),
          ),
        ),
        footer: Obx(
          () => TreinoIaStepFooter(
            label: 'Continuar',
            loading: estado.salvandoDados.value,
            onPressed: estado.salvandoDados.value
                ? null
                : () => unawaited(estado.confirmarDados()),
          ),
        ),
      ),
    );
  }
}

/// Mostra o IMC, a faixa (OMS) e uma frase sobre o que muda no treino.
class _ImcCard extends StatelessWidget {
  const _ImcCard({required this.imc, required this.classificacao});

  final double? imc;
  final String? classificacao;

  @override
  Widget build(BuildContext context) {
    final double? valor = imc;
    if (valor == null) {
      return const AppCard(
        background: ColorTokens.bgSurface,
        padding: EdgeInsets.all(SpacingTokens.md),
        child: Row(
          children: <Widget>[
            Icon(Icons.info_rounded, color: ColorTokens.textSecondary),
            SizedBox(width: SpacingTokens.sm),
            Expanded(
              child: Text(
                'Preencha peso e altura para ver seu IMC.',
                style: TypographyTokens.bodyMuted,
              ),
            ),
          ],
        ),
      );
    }

    final Color cor = _cor(valor);
    return AppCard(
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('Seu IMC', style: TypographyTokens.caption),
          const SizedBox(height: SpacingTokens.xxs),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                valor.toStringAsFixed(1).replaceAll('.', ','),
                style: TypographyTokens.displaySm.copyWith(color: cor),
              ),
              const SizedBox(width: SpacingTokens.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: SpacingTokens.sm,
                  vertical: SpacingTokens.xxs,
                ),
                decoration: BoxDecoration(
                  color: cor.withAlpha(38),
                  borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
                ),
                child: Text(
                  classificacao ?? '',
                  style: TypographyTokens.label.copyWith(color: cor),
                ),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.sm),
          Text(_efeito(valor), style: TypographyTokens.bodyMuted),
        ],
      ),
    );
  }

  Color _cor(double valor) {
    if (valor < 18.5) return ColorTokens.info;
    if (valor < 25) return ColorTokens.accent;
    if (valor < 30) return ColorTokens.warning;
    return ColorTokens.danger;
  }

  String _efeito(double valor) {
    if (valor < 18.5) {
      return 'O treino prioriza ganho de massa: sem cardio e com descanso '
          'maior entre as séries.';
    }
    if (valor < 25) {
      return 'Treino padrão para o seu objetivo e nível.';
    }
    if (valor < 30) {
      return 'Incluímos cardio em todos os treinos, com um pouco menos de '
          'volume e mais repetições.';
    }
    return 'Treino adaptado: sem exercícios de alto impacto, cardio de baixo '
        'impacto em todos os dias, menos séries e mais descanso.';
  }
}
