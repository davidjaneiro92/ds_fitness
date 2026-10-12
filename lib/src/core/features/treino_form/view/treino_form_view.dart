import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../components/buttons/app_button.dart';
import '../../../../components/common/page_header.dart';
import '../../../../components/feedback/app_confirm_dialog.dart';
import '../../../../components/navbars/app_navbar.dart';
import '../../../../components/scaffolds/app_scaffold.dart';
import '../../../../enum/pages_routes.dart';
import '../abstracts/treino_form_controller_interface.dart';
import 'widgets/treino_dados_form.dart';

/// Passo 1 do fluxo — *Novo treino* (`/treinos/novo`): dia da semana, nome,
/// objetivo e descricao. *Continuar* segue para a escolha dos grupos
/// musculares.
class TreinoFormView extends StatefulWidget {
  const TreinoFormView({super.key});

  @override
  State<TreinoFormView> createState() => _TreinoFormViewState();
}

class _TreinoFormViewState extends State<TreinoFormView> {
  // Guardado ao criar a tela (e nao procurado a cada uso, como faz o GetView):
  // sair do fluxo remove o controller do registro com a tela ainda animando a
  // saida. Ver `TreinoFormControllerInterface`.
  final TreinoFormControllerInterface _controller = Get.find();

  /// Sair com algo preenchido pede confirmacao: o rascunho todo se perde.
  Future<void> _tentarSair() async {
    if (!_controller.alterado) {
      _controller.encerrar();
      Get.back<void>();
      return;
    }
    final bool confirmar = await showAppConfirmDialog(
      title: 'Descartar treino?',
      message: 'O que você preencheu neste treino será perdido.',
      confirmLabel: 'Descartar',
      danger: true,
    );
    if (confirmar) {
      _controller.encerrar();
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
        unawaited(_tentarSair());
      },
      child: AppScaffold(
        navbar: AppNavbar(onBack: () => unawaited(_tentarSair())),
        body: Obx(() {
          if (_controller.carregando.value) {
            return const Center(child: CircularProgressIndicator());
          }
          return const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                PageHeader(title: 'Novo treino'),
                TreinoDadosForm(),
              ],
            ),
          );
        }),
        footer: Obx(
          () => AppButton(
            label: 'Continuar',
            onPressed: _controller.podeContinuar
                ? () => Get.toNamed<void>(PagesRoutes.grupos.path)
                : null,
          ),
        ),
      ),
    );
  }
}
