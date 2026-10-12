import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../components/buttons/app_button.dart';
import '../../../../components/cards/app_add_card.dart';
import '../../../../components/cards/exercicio_resumo_tile.dart';
import '../../../../components/common/gap.dart';
import '../../../../components/common/page_header.dart';
import '../../../../components/feedback/app_confirm_dialog.dart';
import '../../../../components/feedback/app_snackbar.dart';
import '../../../../components/modals/app_modal_sheet.dart';
import '../../../../components/navbars/app_navbar.dart';
import '../../../../components/scaffolds/app_scaffold.dart';
import '../../../../core/theme/tokens/spacing_tokens.dart';
import '../../../../enum/pages_routes.dart';
import '../../../../models/treino_exercicio.dart';
import '../../../../routes/route_args.dart';
import '../abstracts/treino_form_controller_interface.dart';
import 'widgets/treino_dados_form.dart';

/// Passo 5 do fluxo — *Revisar e salvar* (`/treinos/revisar`): o titulo
/// ("Treino A • Segunda"), os exercicios ja configurados e o convite para
/// acrescentar mais.
///
/// E tambem a tela de um treino que ja existe (aberto pela lista de treinos):
/// ali o botao principal e *Iniciar treino*, e *Salvar treino* so se habilita
/// quando algo mudou.
class TreinoRevisarView extends StatefulWidget {
  const TreinoRevisarView({super.key});

  @override
  State<TreinoRevisarView> createState() => _TreinoRevisarViewState();
}

class _TreinoRevisarViewState extends State<TreinoRevisarView> {
  // Guardado ao criar a tela (e nao procurado a cada uso, como faz o GetView):
  // salvar encerra o fluxo e tira o controller do registro com esta tela ainda
  // animando a saida — e ela se reconstroi nesse meio tempo, porque salvar
  // acabou de mexer na lista. Ver `TreinoFormControllerInterface`.
  final TreinoFormControllerInterface _controller = Get.find();

  /// Treino novo: volta ao formulario, que guarda o que foi preenchido. Treino
  /// que ja existe: sai do fluxo, pedindo confirmacao se ha mudanca.
  Future<void> _voltar() async {
    if (!_controller.existente) {
      Get.back<void>();
      return;
    }
    if (_controller.alterado) {
      final bool confirmar = await showAppConfirmDialog(
        title: 'Descartar alterações?',
        message: 'As mudanças feitas neste treino serão perdidas.',
        confirmLabel: 'Descartar',
        danger: true,
      );
      if (!confirmar) {
        return;
      }
    }
    _controller.encerrar();
    Get.back<void>();
  }

  Future<void> _salvar() async {
    if (!await _controller.salvar()) {
      return;
    }
    final bool voltarALista = _controller.partiuDaLista;
    _controller.encerrar();
    if (voltarALista) {
      // A lista de treinos continua na pilha e recarrega quando a tela que a
      // abriu volta.
      Get.until(
        (Route<dynamic> rota) => rota.settings.name == PagesRoutes.treinos.path,
      );
    } else {
      unawaited(Get.offAllNamed<void>(PagesRoutes.treinos.path));
    }
    // Depois de navegar: com um snackbar aberto, o Get.back() so o fecha.
    AppSnackbar.success('Treino salvo!');
  }

  Future<void> _iniciar() async {
    if (!await _controller.salvar()) {
      return;
    }
    final String? id = _controller.treinoId;
    _controller.encerrar();
    if (id != null) {
      unawaited(
        Get.offNamed<void>(
          PagesRoutes.execucao.path,
          arguments: ExecucaoArgs(treinoId: id),
        ),
      );
    }
  }

  void _adicionar() => Get.toNamed<void>(PagesRoutes.grupos.path);

  void _editar(TreinoExercicio item) {
    _controller.iniciarEdicaoDe(item);
    Get.toNamed<void>(PagesRoutes.exercicioConfigurar.path);
  }

  Future<void> _remover(TreinoExercicio item) async {
    final bool confirmar = await showAppConfirmDialog(
      title: 'Remover exercício?',
      message: '"${item.exercicio.nome}" será removido deste treino.',
      confirmLabel: 'Remover',
      danger: true,
    );
    if (confirmar) {
      _controller.removerExercicio(item.id);
    }
  }

  Future<void> _editarDados() async {
    await showAppModalSheet<void>(
      title: 'Dados do treino',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const TreinoDadosForm(),
          const Gap(SpacingTokens.lg),
          Obx(
            () => AppButton(
              label: 'Concluir',
              onPressed: _controller.podeContinuar
                  ? () => Get.back<void>()
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) {
          return;
        }
        unawaited(_voltar());
      },
      child: AppScaffold(
        navbar: AppNavbar(
          onBack: () => unawaited(_voltar()),
          action: NavbarAction(
            icon: Icons.edit_rounded,
            onTap: () => unawaited(_editarDados()),
          ),
        ),
        body: Obx(() {
          if (_controller.carregando.value) {
            return const Center(child: CircularProgressIndicator());
          }
          final List<TreinoExercicio> lista = _controller.exercicios;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              PageHeader(title: _controller.titulo),
              Expanded(
                child: ReorderableListView.builder(
                  buildDefaultDragHandles: false,
                  padding: const EdgeInsets.only(bottom: SpacingTokens.md),
                  itemCount: lista.length,
                  onReorder: _controller.reordenar,
                  footer: Padding(
                    padding: const EdgeInsets.only(top: SpacingTokens.xs),
                    child: AppAddCard(
                      label: 'Adicionar exercício',
                      onTap: _adicionar,
                    ),
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    final TreinoExercicio item = lista[index];
                    return Padding(
                      key: ValueKey<String>(item.id),
                      padding: const EdgeInsets.only(bottom: SpacingTokens.sm),
                      child: ReorderableDelayedDragStartListener(
                        index: index,
                        child: ExercicioResumoTile(
                          item: item,
                          onEditar: () => _editar(item),
                          onRemover: () => unawaited(_remover(item)),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }),
        footer: Obx(() {
          final bool salvando = _controller.salvando.value;
          if (!_controller.existente) {
            return AppButton(
              label: 'Salvar treino',
              loading: salvando,
              onPressed:
                  _controller.podeSalvar ? () => unawaited(_salvar()) : null,
            );
          }
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              AppButton(
                label: 'Iniciar treino',
                loading: salvando,
                onPressed:
                    _controller.podeSalvar ? () => unawaited(_iniciar()) : null,
              ),
              const Gap(SpacingTokens.sm),
              AppButton(
                label: 'Salvar treino',
                variant: AppButtonVariant.outline,
                onPressed: _controller.podeSalvar && _controller.alterado
                    ? () => unawaited(_salvar())
                    : null,
              ),
            ],
          );
        }),
      ),
    );
  }
}
