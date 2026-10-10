import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../components/buttons/app_button.dart';
import '../../../../components/chips/app_chip.dart';
import '../../../../components/common/gap.dart';
import '../../../../components/feedback/app_confirm_dialog.dart';
import '../../../../components/inputs/app_text_field.dart';
import '../../../../components/navbars/app_navbar.dart';
import '../../../../components/scaffolds/app_scaffold.dart';
import '../../../../enum/grupo_muscular.dart';
import '../../../theme/tokens/color_tokens.dart';
import '../../../theme/tokens/spacing_tokens.dart';
import '../../../theme/tokens/typography_tokens.dart';
import '../../../utils/validators.dart';
import '../abstracts/exercicio_form_controller_interface.dart';

/// Formulario de exercicio: cria um exercicio do usuario ou edita (e exclui)
/// um que ele ja criou. Abre a partir da Biblioteca (novo) e do Detalhe do
/// Exercicio (editar).
class ExercicioFormView extends StatefulWidget {
  const ExercicioFormView({super.key});

  @override
  State<ExercicioFormView> createState() => _ExercicioFormViewState();
}

class _ExercicioFormViewState extends State<ExercicioFormView> {
  final ExercicioFormControllerInterface _controller = Get.find();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomeController;
  late final TextEditingController _equipamentoController;

  /// Um campo de texto por passo. A quantidade acompanha
  /// `_controller.instrucoes`; os textos sao enviados ao controller a cada
  /// alteracao.
  final List<TextEditingController> _passos = <TextEditingController>[];

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: _controller.nome.value);
    _equipamentoController = TextEditingController(
      text: _controller.equipamento.value,
    );
    _sincronizarPassos();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _equipamentoController.dispose();
    for (final TextEditingController passo in _passos) {
      passo.dispose();
    }
    super.dispose();
  }

  void _sincronizarPassos() {
    while (_passos.length < _controller.instrucoes.length) {
      _passos.add(
        TextEditingController(text: _controller.instrucoes[_passos.length]),
      );
    }
    while (_passos.length > _controller.instrucoes.length) {
      _passos.removeLast().dispose();
    }
  }

  void _adicionarPasso() {
    _controller.adicionarInstrucao();
    setState(_sincronizarPassos);
  }

  void _removerPasso(int indice) {
    _passos.removeAt(indice).dispose();
    _controller.removerInstrucao(indice);
    setState(_sincronizarPassos);
  }

  void _usarEquipamento(String equipamento) {
    _equipamentoController.text = equipamento;
    _controller.equipamento.value = equipamento;
  }

  Future<void> _salvar() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    await _controller.salvar();
  }

  Future<void> _confirmarExclusao() async {
    final bool confirmado = await showAppConfirmDialog(
      title: 'Excluir exercício?',
      message: '"${_controller.nome.value}" sai da sua biblioteca e dos '
          'treinos que o usam. O histórico de treinos já feitos é mantido.',
      confirmLabel: 'Excluir',
      danger: true,
    );
    if (confirmado) {
      await _controller.excluir();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      navbar: AppNavbar(
        title: _controller.edicao ? 'Editar exercício' : 'Novo exercício',
      ),
      footer: Obx(
        () => AppButton(
          label: 'Salvar exercício',
          loading: _controller.salvando.value,
          onPressed: _controller.podeSalvar && !_controller.salvando.value
              ? () => unawaited(_salvar())
              : null,
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Gap(SpacingTokens.md),
              AppTextField(
                label: 'Nome do exercício',
                controller: _nomeController,
                hint: 'Ex.: Remada unilateral',
                textCapitalization: TextCapitalization.sentences,
                validator: (String? valor) =>
                    Validators.obrigatorio(valor, campo: 'O nome'),
                onChanged: (String valor) => _controller.nome.value = valor,
              ),
              const Gap(SpacingTokens.lg),
              const Text(
                'Grupo muscular principal',
                style: TypographyTokens.label,
              ),
              const Gap(SpacingTokens.sm),
              _GruposPrimarios(controller: _controller),
              const Gap(SpacingTokens.lg),
              const Text(
                'Também trabalha (opcional)',
                style: TypographyTokens.label,
              ),
              const Gap(SpacingTokens.sm),
              _GruposSecundarios(controller: _controller),
              const Gap(SpacingTokens.lg),
              AppTextField(
                label: 'Equipamento',
                controller: _equipamentoController,
                hint: 'Ex.: Barra, halteres, máquina',
                textCapitalization: TextCapitalization.sentences,
                onChanged: (String valor) =>
                    _controller.equipamento.value = valor,
              ),
              const Gap(SpacingTokens.sm),
              Wrap(
                spacing: SpacingTokens.sm,
                runSpacing: SpacingTokens.sm,
                children: <Widget>[
                  for (final String sugestao
                      in _controller.equipamentosSugeridos)
                    AppChip(
                      label: sugestao,
                      dense: true,
                      onTap: () => _usarEquipamento(sugestao),
                    ),
                ],
              ),
              const Gap(SpacingTokens.lg),
              const Text(
                'Passo a passo (opcional)',
                style: TypographyTokens.label,
              ),
              const Gap(SpacingTokens.sm),
              for (int i = 0; i < _passos.length; i++) ...<Widget>[
                _CampoDoPasso(
                  numero: i + 1,
                  controller: _passos[i],
                  onChanged: (String texto) =>
                      _controller.atualizarInstrucao(i, texto),
                  onRemover: () => _removerPasso(i),
                ),
                const Gap(SpacingTokens.sm),
              ],
              AppButton(
                label: 'Adicionar passo',
                variant: AppButtonVariant.outline,
                icon: Icons.add_rounded,
                size: AppButtonSize.small,
                onPressed: _adicionarPasso,
              ),
              if (_controller.edicao) ...<Widget>[
                const Gap(SpacingTokens.xl),
                AppButton(
                  label: 'Excluir exercício',
                  variant: AppButtonVariant.danger,
                  icon: Icons.delete_outline_rounded,
                  onPressed: () => unawaited(_confirmarExclusao()),
                ),
              ],
              const Gap(SpacingTokens.xl),
            ],
          ),
        ),
      ),
    );
  }
}

/// Escolha unica do grupo principal.
class _GruposPrimarios extends StatelessWidget {
  const _GruposPrimarios({required this.controller});

  final ExercicioFormControllerInterface controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final GrupoMuscular selecionado = controller.grupoPrimario.value;
      return Wrap(
        spacing: SpacingTokens.sm,
        runSpacing: SpacingTokens.sm,
        children: <Widget>[
          for (final GrupoMuscular grupo in GrupoMuscular.reais)
            AppChip(
              label: grupo.label,
              selected: grupo == selecionado,
              dense: true,
              onTap: () => controller.selecionarGrupoPrimario(grupo),
            ),
        ],
      );
    });
  }
}

/// Escolha multipla dos grupos secundarios; o grupo principal fica de fora.
class _GruposSecundarios extends StatelessWidget {
  const _GruposSecundarios({required this.controller});

  final ExercicioFormControllerInterface controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final GrupoMuscular primario = controller.grupoPrimario.value;
      final List<GrupoMuscular> selecionados =
          controller.gruposSecundarios.toList();
      return Wrap(
        spacing: SpacingTokens.sm,
        runSpacing: SpacingTokens.sm,
        children: <Widget>[
          for (final GrupoMuscular grupo in GrupoMuscular.reais)
            if (grupo != primario)
              AppChip(
                label: grupo.label,
                selected: selecionados.contains(grupo),
                dense: true,
                onTap: () => controller.alternarGrupoSecundario(grupo),
              ),
        ],
      );
    });
  }
}

/// Um passo numerado, com campo de texto e botao de remover.
class _CampoDoPasso extends StatelessWidget {
  const _CampoDoPasso({
    required this.numero,
    required this.controller,
    required this.onChanged,
    required this.onRemover,
  });

  final int numero;
  final TextEditingController controller;
  final void Function(String texto) onChanged;
  final VoidCallback onRemover;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 28,
          height: 28,
          margin: const EdgeInsets.only(top: SpacingTokens.sm),
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: ColorTokens.accent,
            shape: BoxShape.circle,
          ),
          child: Text(
            '$numero',
            style: TypographyTokens.bodyStrong.copyWith(
              color: ColorTokens.textOnAccent,
            ),
          ),
        ),
        const Gap.horizontal(SpacingTokens.sm),
        Expanded(
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            maxLines: 3,
            minLines: 1,
            textCapitalization: TextCapitalization.sentences,
            style: TypographyTokens.body,
            cursorColor: ColorTokens.accent,
            decoration: const InputDecoration(hintText: 'Descreva o passo'),
          ),
        ),
        IconButton(
          onPressed: onRemover,
          tooltip: 'Remover passo',
          icon: const Icon(
            Icons.close_rounded,
            color: ColorTokens.textSecondary,
          ),
        ),
      ],
    );
  }
}
