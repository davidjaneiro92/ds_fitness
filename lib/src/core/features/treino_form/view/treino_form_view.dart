import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../components/buttons/app_button.dart';
import '../../../../components/common/gap.dart';
import '../../../../components/common/section_header.dart';
import '../../../../components/feedback/app_confirm_dialog.dart';
import '../../../../components/feedback/app_snackbar.dart';
import '../../../../components/inputs/app_dropdown_field.dart';
import '../../../../components/inputs/app_text_field.dart';
import '../../../../components/navbars/app_navbar.dart';
import '../../../../components/scaffolds/app_scaffold.dart';
import '../../../../core/theme/tokens/color_tokens.dart';
import '../../../../core/theme/tokens/spacing_tokens.dart';
import '../../../../core/theme/tokens/typography_tokens.dart';
import '../../../../enum/objetivo_treino.dart';
import '../../../../enum/pages_routes.dart';
import '../../../../models/treino_exercicio.dart';
import '../abstracts/treino_form_controller_interface.dart';
import 'widgets/exercicio_ordenavel_tile.dart';

/// Tela 6 — criacao de treino (`/treinos/novo`).
class TreinoFormView extends StatefulWidget {
  const TreinoFormView({super.key});

  @override
  State<TreinoFormView> createState() => _TreinoFormViewState();
}

class _TreinoFormViewState extends State<TreinoFormView> {
  final TreinoFormControllerInterface controller = Get.find();

  late final TextEditingController _nomeCtrl;
  late final TextEditingController _descricaoCtrl;
  Worker? _workerNome;
  Worker? _workerDescricao;

  @override
  void initState() {
    super.initState();
    _nomeCtrl = TextEditingController(text: controller.nome.value);
    _descricaoCtrl = TextEditingController(text: controller.descricao.value);
    _workerNome = ever<String>(controller.nome, (String valor) {
      if (_nomeCtrl.text != valor) {
        _nomeCtrl.text = valor;
      }
    });
    _workerDescricao = ever<String>(controller.descricao, (String valor) {
      if (_descricaoCtrl.text != valor) {
        _descricaoCtrl.text = valor;
      }
    });
  }

  @override
  void dispose() {
    _workerNome?.dispose();
    _workerDescricao?.dispose();
    _nomeCtrl.dispose();
    _descricaoCtrl.dispose();
    super.dispose();
  }

  bool get _possuiConteudo =>
      controller.nome.value.trim().isNotEmpty ||
      controller.descricao.value.trim().isNotEmpty ||
      controller.exercicios.isNotEmpty;

  Future<void> _tentarSair() async {
    if (!_possuiConteudo) {
      controller.encerrar();
      Get.back<void>();
      return;
    }
    final bool confirmar = await showAppConfirmDialog(
      title: 'Descartar treino?',
      message: 'As alterações feitas neste treino serão perdidas.',
      confirmLabel: 'Descartar',
      danger: true,
    );
    if (confirmar) {
      controller.encerrar();
      Get.back<void>();
    }
  }

  Future<void> _salvar() async {
    final bool sucesso = await controller.salvar();
    if (!sucesso) {
      AppSnackbar.erro('Não foi possível salvar o treino.');
      return;
    }
    AppSnackbar.success('Treino salvo!');
    controller.encerrar();
    Get.back<void>();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) {
          return;
        }
        unawaited(_tentarSair());
      },
      child: AppScaffold(
        navbar: AppNavbar(
          title: 'Novo Treino',
          onBack: () => unawaited(_tentarSair()),
        ),
        body: Obx(() {
          if (controller.carregando.value) {
            return const Center(
              child: CircularProgressIndicator(color: ColorTokens.accent),
            );
          }
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                AppTextField(
                  label: 'Nome do treino',
                  controller: _nomeCtrl,
                  hint: 'Ex.: Treino A — Peito e Tríceps',
                  onChanged: (String v) => controller.nome.value = v,
                ),
                const Gap(SpacingTokens.md),
                AppDropdownField<ObjetivoTreino>(
                  label: 'Objetivo',
                  value: controller.objetivo.value,
                  items: ObjetivoTreino.values,
                  itemLabel: (ObjetivoTreino o) => o.label,
                  onChanged: (ObjetivoTreino? o) {
                    if (o != null) {
                      controller.objetivo.value = o;
                    }
                  },
                ),
                const Gap(SpacingTokens.md),
                AppTextField(
                  label: 'Descrição (opcional)',
                  controller: _descricaoCtrl,
                  hint: 'Observações sobre este treino...',
                  maxLines: 3,
                  onChanged: (String v) => controller.descricao.value = v,
                ),
                const Gap(SpacingTokens.lg),
                SectionHeader(
                  title: 'Exercícios',
                  trailing: Text(
                    controller.exercicios.length == 1
                        ? '1 exercício adicionado'
                        : '${controller.exercicios.length} exercícios '
                            'adicionados',
                    style: TypographyTokens.label,
                  ),
                ),
                if (controller.exercicios.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: SpacingTokens.sm),
                    child: Text(
                      'Nenhum exercício adicionado ainda',
                      style: TypographyTokens.bodyMuted,
                    ),
                  )
                else
                  ...controller.exercicios.asMap().entries.map(
                        (MapEntry<int, TreinoExercicio> entry) => Padding(
                          padding: const EdgeInsets.only(
                            bottom: SpacingTokens.sm,
                          ),
                          child: ExercicioOrdenavelTile(
                            item: entry.value,
                            indice: entry.key,
                            onRemover: () =>
                                controller.removerExercicio(entry.value.id),
                          ),
                        ),
                      ),
                const Gap(SpacingTokens.md),
                AppButton(
                  label: 'Adicionar exercício',
                  variant: AppButtonVariant.outline,
                  icon: Icons.add_rounded,
                  onPressed: () =>
                      Get.toNamed<void>(PagesRoutes.grupos.path),
                ),
                const Gap(SpacingTokens.xl),
              ],
            ),
          );
        }),
        footer: Obx(
          () => AppButton(
            label: 'Salvar treino',
            onPressed:
                controller.podeSalvar ? () => unawaited(_salvar()) : null,
          ),
        ),
      ),
    );
  }
}
