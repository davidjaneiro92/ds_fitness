import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../components/buttons/app_button.dart';
import '../../../../components/cards/treino_card.dart';
import '../../../../components/empty_states/empty_state.dart';
import '../../../../components/feedback/app_confirm_dialog.dart';
import '../../../../components/modals/app_modal_sheet.dart';
import '../../../../components/navbars/app_bottom_nav.dart';
import '../../../../components/navbars/app_navbar.dart';
import '../../../../components/scaffolds/app_scaffold.dart';
import '../../../../core/theme/tokens/color_tokens.dart';
import '../../../../core/theme/tokens/spacing_tokens.dart';
import '../../../../core/theme/tokens/typography_tokens.dart';
import '../../../../enum/app_tab.dart';
import '../../../../enum/pages_routes.dart';
import '../../../../models/treino.dart';
import '../../../../routes/route_args.dart';
import '../abstracts/treinos_controller_interface.dart';

/// Tela 5 — Meus Treinos (planejamento §5): lista de treinos com acoes de
/// duplicar/excluir e atalho para criar um novo treino.
class TreinosView extends StatelessWidget {
  const TreinosView({super.key});

  @override
  Widget build(BuildContext context) {
    final TreinosControllerInterface controller = Get.find();

    return AppScaffold(
      navbar: AppNavbar(
        title: 'Meus Treinos',
        onBack: () => Get.offAllNamed<void>(PagesRoutes.home.path),
      ),
      bottomNav: const AppBottomNav(current: AppTab.treinos),
      footer: AppButton(
        label: 'Novo treino',
        icon: Icons.add_rounded,
        onPressed: () => _abrirNovoTreino(controller),
      ),
      body: Obx(() {
        if (controller.carregando.value) {
          return const Center(
            child: CircularProgressIndicator(color: ColorTokens.accent),
          );
        }
        if (controller.treinos.isEmpty) {
          return EmptyState(
            icon: Icons.fitness_center_rounded,
            title: 'Você ainda não criou nenhum treino',
            message:
                'Monte seu primeiro treino e comece a acompanhar sua evolução.',
            actionLabel: 'Criar treino',
            onAction: () => _abrirNovoTreino(controller),
          );
        }
        final String? idDoDia = controller.treinoDoDia.value?.id;
        return ListView.separated(
          padding: const EdgeInsets.only(
            top: SpacingTokens.md,
            bottom: SpacingTokens.md,
          ),
          itemCount: controller.treinos.length,
          separatorBuilder: (BuildContext context, int index) =>
              const SizedBox(height: SpacingTokens.sm),
          itemBuilder: (BuildContext context, int index) {
            final Treino treino = controller.treinos[index];
            return TreinoCard(
              treino: treino,
              destaque: treino.id == idDoDia,
              onTap: () => _abrirEdicao(controller, treino),
              onLongPress: () => _abrirOpcoes(controller, treino),
            );
          },
        );
      }),
    );
  }

  Future<void> _abrirNovoTreino(TreinosControllerInterface controller) async {
    await Get.toNamed<void>(
      PagesRoutes.treinoNovo.path,
      arguments: const TreinoFormArgs(),
    );
    await controller.carregar();
  }

  Future<void> _abrirEdicao(
    TreinosControllerInterface controller,
    Treino treino,
  ) async {
    await Get.toNamed<void>(
      PagesRoutes.treinoEditar.path,
      arguments: TreinoFormArgs(treinoId: treino.id),
    );
    await controller.carregar();
  }

  Future<void> _abrirOpcoes(
    TreinosControllerInterface controller,
    Treino treino,
  ) async {
    await showAppModalSheet<void>(
      title: treino.nome,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _OpcaoTreino(
            icon: Icons.copy_rounded,
            label: 'Duplicar',
            onTap: () async {
              Get.back<void>();
              await controller.duplicar(treino.id);
            },
          ),
          _OpcaoTreino(
            icon: Icons.delete_outline_rounded,
            label: 'Excluir',
            color: ColorTokens.danger,
            onTap: () async {
              Get.back<void>();
              final bool confirmar = await showAppConfirmDialog(
                title: 'Excluir treino?',
                message: 'Essa ação não pode ser desfeita.',
                confirmLabel: 'Excluir',
                danger: true,
              );
              if (confirmar) {
                await controller.excluir(treino.id);
              }
            },
          ),
        ],
      ),
    );
  }
}

class _OpcaoTreino extends StatelessWidget {
  const _OpcaoTreino({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final Color cor = color ?? ColorTokens.textPrimary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(SpacingTokens.radiusSm),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: SpacingTokens.sm),
          child: Row(
            children: <Widget>[
              Icon(icon, size: 20, color: cor),
              const SizedBox(width: SpacingTokens.sm),
              Text(label, style: TypographyTokens.body.copyWith(color: cor)),
            ],
          ),
        ),
      ),
    );
  }
}
