import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../components/buttons/app_button.dart';
import '../../../../components/common/gap.dart';
import '../../../../components/empty_states/empty_state.dart';
import '../../../../components/feedback/app_confirm_dialog.dart';
import '../../../../components/inputs/app_text_field.dart';
import '../../../../components/modals/app_modal_sheet.dart';
import '../../../../components/navbars/app_navbar.dart';
import '../../../../components/scaffolds/app_scaffold.dart';
import '../../../../core/theme/tokens/color_tokens.dart';
import '../../../../core/theme/tokens/spacing_tokens.dart';
import '../../../../enum/pages_routes.dart';
import '../../../../models/treino_exercicio.dart';
import '../../../../routes/route_args.dart';
import '../abstracts/treino_form_controller_interface.dart';
import 'widgets/add_exercicio_sheet.dart';
import 'widgets/exercicio_ordenavel_tile.dart';

/// Tela 10 — meu treino / edicao (`/treinos/editar`).
class TreinoEditarView extends GetView<TreinoFormControllerInterface> {
  const TreinoEditarView({super.key});

  String? get _treinoId {
    final Object? args = Get.arguments;
    return args is TreinoFormArgs ? args.treinoId : null;
  }

  Future<void> _sairSalvando() async {
    final bool sucesso = await controller.salvar();
    if (!sucesso) {
      // O controller ja avisou o motivo; sair agora perderia a edicao.
      return;
    }
    controller.encerrar();
    Get.back<void>();
  }

  Future<void> _abrirRenomear() async {
    await showAppModalSheet<void>(
      title: 'Renomear treino',
      child: _RenomearSheetContent(controller: controller),
    );
  }

  Future<void> _abrirSheet(TreinoExercicio item) async {
    await showAppModalSheet<void>(
      title: item.exercicio.nome,
      child: AddExercicioSheet(exercicio: item.exercicio, existente: item),
    );
  }

  Future<void> _confirmarRemover(TreinoExercicio item) async {
    final bool confirmar = await showAppConfirmDialog(
      title: 'Remover exercício?',
      message: '"${item.exercicio.nome}" será removido deste treino.',
      confirmLabel: 'Remover',
      danger: true,
    );
    if (confirmar) {
      controller.removerExercicio(item.id);
    }
  }

  Future<void> _iniciarTreino() async {
    final bool sucesso = await controller.salvar();
    if (!sucesso) {
      return;
    }
    final String? id = _treinoId;
    controller.encerrar();
    if (id != null) {
      await Get.offNamed<void>(
        PagesRoutes.execucao.path,
        arguments: ExecucaoArgs(treinoId: id),
      );
    } else {
      Get.back<void>();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) {
          return;
        }
        unawaited(_sairSalvando());
      },
      child: AppScaffold(
        navbar: _ObxNavbar(
          builder: () => AppNavbar(
            title: controller.nome.value,
            subtitle: '${controller.exercicios.length} exercícios',
            onBack: () => unawaited(_sairSalvando()),
            action: NavbarAction(
              icon: Icons.edit_rounded,
              onTap: () => unawaited(_abrirRenomear()),
            ),
          ),
        ),
        body: Obx(() {
          if (controller.carregando.value) {
            return const Center(
              child: CircularProgressIndicator(color: ColorTokens.accent),
            );
          }
          final List<TreinoExercicio> lista = controller.exercicios;
          if (lista.isEmpty) {
            return const EmptyState(
              icon: Icons.fitness_center_rounded,
              title: 'Nenhum exercício adicionado',
              message: 'Adicione exercícios para montar este treino.',
            );
          }
          return ReorderableListView.builder(
            padding: const EdgeInsets.only(bottom: SpacingTokens.md),
            itemCount: lista.length,
            onReorder: controller.reordenar,
            itemBuilder: (BuildContext context, int index) {
              final TreinoExercicio item = lista[index];
              return Padding(
                key: ValueKey<String>(item.id),
                padding: const EdgeInsets.only(bottom: SpacingTokens.sm),
                child: ExercicioOrdenavelTile(
                  item: item,
                  indice: index,
                  arrastavel: true,
                  onTap: () => unawaited(_abrirSheet(item)),
                  onRemover: () => unawaited(_confirmarRemover(item)),
                ),
              );
            },
          );
        }),
        footer: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AppButton(
              label: 'Adicionar exercício',
              variant: AppButtonVariant.outline,
              icon: Icons.add_rounded,
              onPressed: () => Get.toNamed<void>(PagesRoutes.grupos.path),
            ),
            const Gap(SpacingTokens.sm),
            AppButton(
              label: 'Iniciar treino',
              onPressed: () => unawaited(_iniciarTreino()),
            ),
          ],
        ),
      ),
    );
  }
}

/// Envelope [PreferredSizeWidget] para permitir um [AppNavbar] reativo
/// (titulo/subtitulo derivados de valores `Rx`) no slot `navbar` do
/// [AppScaffold].
class _ObxNavbar extends StatelessWidget implements PreferredSizeWidget {
  const _ObxNavbar({required this.builder});

  final Widget Function() builder;

  @override
  Size get preferredSize => const Size.fromHeight(SpacingTokens.navBarHeight);

  @override
  Widget build(BuildContext context) => Obx(builder);
}

/// Conteudo do bottom sheet de renomear treino (acao da navbar da tela 10).
class _RenomearSheetContent extends StatefulWidget {
  const _RenomearSheetContent({required this.controller});

  final TreinoFormControllerInterface controller;

  @override
  State<_RenomearSheetContent> createState() => _RenomearSheetContentState();
}

class _RenomearSheetContentState extends State<_RenomearSheetContent> {
  late final TextEditingController _nomeCtrl;

  @override
  void initState() {
    super.initState();
    _nomeCtrl = TextEditingController(text: widget.controller.nome.value);
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    super.dispose();
  }

  void _salvar() {
    final String texto = _nomeCtrl.text.trim();
    if (texto.isEmpty) {
      return;
    }
    widget.controller.nome.value = texto;
    Get.back<void>();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        AppTextField(
          label: 'Nome do treino',
          controller: _nomeCtrl,
          autofocus: true,
        ),
        const Gap(SpacingTokens.lg),
        AppButton(label: 'Salvar', onPressed: _salvar),
      ],
    );
  }
}
