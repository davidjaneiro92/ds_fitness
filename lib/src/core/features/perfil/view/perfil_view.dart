import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../components/buttons/app_button.dart';
import '../../../../components/cards/app_card.dart';
import '../../../../components/common/gap.dart';
import '../../../../components/feedback/app_confirm_dialog.dart';
import '../../../../components/feedback/app_snackbar.dart';
import '../../../../components/modals/app_modal_sheet.dart';
import '../../../../components/navbars/app_bottom_nav.dart';
import '../../../../components/navbars/app_navbar.dart';
import '../../../../components/scaffolds/app_scaffold.dart';
import '../../../../enum/app_tab.dart';
import '../../../../enum/objetivo_treino.dart';
import '../../../../enum/pages_routes.dart';
import '../../../../models/registro_carga.dart';
import '../../../../models/usuario.dart';
import '../../../abstracts/format_service_interface.dart';
import '../../../theme/tokens/color_tokens.dart';
import '../../../theme/tokens/spacing_tokens.dart';
import '../../../theme/tokens/typography_tokens.dart';
import '../abstracts/perfil_controller_interface.dart';
import 'widgets/perfil_menu_item.dart';

/// Tela 20 — Perfil.
class PerfilView extends GetView<PerfilControllerInterface> {
  const PerfilView({super.key});

  void _abrirMeusDados(Usuario usuario) {
    final FormatServiceInterface format = Get.find();
    showAppModalSheet<void>(
      title: 'Meus dados',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _LinhaDado(label: 'Nome', valor: usuario.nome),
          _LinhaDado(label: 'E-mail', valor: usuario.email),
          _LinhaDado(
            label: 'Nascimento',
            valor: usuario.dataNascimento == null
                ? '—'
                : format.data(usuario.dataNascimento!),
          ),
          _LinhaDado(label: 'Sexo', valor: usuario.sexo),
          _LinhaDado(
            label: 'Peso',
            valor: '${usuario.peso.toStringAsFixed(0)} kg',
          ),
          _LinhaDado(
            label: 'Altura',
            valor:
                '${usuario.altura.toStringAsFixed(2).replaceAll('.', ',')} m',
          ),
          const Gap(SpacingTokens.lg),
          AppButton(label: 'Fechar', onPressed: () => Get.back<void>()),
        ],
      ),
    );
  }

  void _abrirObjetivos(ObjetivoTreino atual) {
    showAppModalSheet<void>(
      title: 'Objetivos',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (final ObjetivoTreino objetivo in ObjetivoTreino.values)
            _OpcaoObjetivo(
              objetivo: objetivo,
              selecionado: objetivo == atual,
              onTap: () => _selecionarObjetivo(objetivo),
            ),
        ],
      ),
    );
  }

  Future<void> _selecionarObjetivo(ObjetivoTreino objetivo) async {
    Get.back<void>();
    final bool salvo = await controller.salvarObjetivo(objetivo);
    if (salvo) {
      AppSnackbar.success('Objetivo atualizado');
    }
  }

  void _abrirMedidas() {
    showAppModalSheet<void>(
      title: 'Medidas corporais',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (controller.medidas.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: SpacingTokens.lg),
              child: Text(
                'Nenhuma medida registrada ainda.',
                textAlign: TextAlign.center,
                style: TypographyTokens.bodyMuted,
              ),
            )
          else
            for (final MedidaCorporal medida in controller.medidas)
              _LinhaMedida(medida: medida),
        ],
      ),
    );
  }

  Future<void> _sair() async {
    final bool confirmado = await showAppConfirmDialog(
      title: 'Sair da conta?',
      confirmLabel: 'Sair',
      danger: true,
    );
    if (!confirmado) {
      return;
    }
    await controller.sair();
    await Get.offAllNamed<void>(PagesRoutes.login.path);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      navbar: const AppNavbar(showBack: false),
      bottomNav: const AppBottomNav(current: AppTab.perfil),
      body: Obx(() {
        if (controller.carregando.value) {
          return const Center(
            child: CircularProgressIndicator(color: ColorTokens.accent),
          );
        }
        final Usuario usuario = controller.usuario.value;
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Gap(SpacingTokens.lg),
              _Cabecalho(usuario: usuario),
              const Gap(SpacingTokens.xl),
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: <Widget>[
                    PerfilMenuItem(
                      icon: Icons.person_outline_rounded,
                      label: 'Meus dados',
                      onTap: () => _abrirMeusDados(usuario),
                    ),
                    const Divider(height: 1, color: ColorTokens.divider),
                    PerfilMenuItem(
                      icon: Icons.flag_outlined,
                      label: 'Objetivos',
                      value: usuario.objetivo.label,
                      onTap: () => _abrirObjetivos(usuario.objetivo),
                    ),
                    const Divider(height: 1, color: ColorTokens.divider),
                    PerfilMenuItem(
                      icon: Icons.grid_view_rounded,
                      label: 'Biblioteca de exercícios',
                      onTap: () =>
                          Get.toNamed<void>(PagesRoutes.biblioteca.path),
                    ),
                    const Divider(height: 1, color: ColorTokens.divider),
                    PerfilMenuItem(
                      icon: Icons.show_chart_rounded,
                      label: 'Minha evolução',
                      onTap: () =>
                          Get.toNamed<void>(PagesRoutes.estatisticas.path),
                    ),
                    const Divider(height: 1, color: ColorTokens.divider),
                    PerfilMenuItem(
                      icon: Icons.photo_camera_outlined,
                      label: 'Fotos de progresso',
                      onTap: () => AppSnackbar.info('Em breve'),
                    ),
                    const Divider(height: 1, color: ColorTokens.divider),
                    PerfilMenuItem(
                      icon: Icons.straighten_rounded,
                      label: 'Medidas corporais',
                      onTap: _abrirMedidas,
                    ),
                    const Divider(height: 1, color: ColorTokens.divider),
                    PerfilMenuItem(
                      icon: Icons.logout_rounded,
                      label: 'Sair',
                      onTap: _sair,
                    ),
                  ],
                ),
              ),
              const Gap(SpacingTokens.xl),
              const Text(
                'DS Fitness · v1.0.0',
                textAlign: TextAlign.center,
                style: TypographyTokens.caption,
              ),
              const Gap(SpacingTokens.lg),
            ],
          ),
        );
      }),
    );
  }
}

/// Cabecalho do perfil: avatar com botao de camera, nome e resumo fisico.
class _Cabecalho extends StatelessWidget {
  const _Cabecalho({required this.usuario});

  final Usuario usuario;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
          width: 96,
          height: 96,
          child: Stack(
            children: <Widget>[
              Container(
                width: 96,
                height: 96,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: ColorTokens.accentSoft,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  usuario.iniciais,
                  style: TypographyTokens.displaySm
                      .copyWith(color: ColorTokens.accent),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: InkWell(
                  onTap: () => AppSnackbar.info('Em breve'),
                  borderRadius:
                      BorderRadius.circular(SpacingTokens.radiusPill),
                  child: Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: ColorTokens.accent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      size: 16,
                      color: ColorTokens.textOnAccent,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Gap(SpacingTokens.md),
        Text(usuario.nome, style: TypographyTokens.screenTitle),
        const Gap(SpacingTokens.xs),
        Text(usuario.resumoFisico, style: TypographyTokens.bodyMuted),
      ],
    );
  }
}

/// Linha de dado somente-leitura no sheet "Meus dados".
class _LinhaDado extends StatelessWidget {
  const _LinhaDado({required this.label, required this.valor});

  final String label;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SpacingTokens.xs),
      child: Row(
        children: <Widget>[
          Text(label, style: TypographyTokens.label),
          const Spacer(),
          Text(valor, style: TypographyTokens.bodyStrong),
        ],
      ),
    );
  }
}

/// Opcao selecionavel no sheet "Objetivos".
class _OpcaoObjetivo extends StatelessWidget {
  const _OpcaoObjetivo({
    required this.objetivo,
    required this.selecionado,
    required this.onTap,
  });

  final ObjetivoTreino objetivo;
  final bool selecionado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: SpacingTokens.sm),
        child: Row(
          children: <Widget>[
            Icon(
              selecionado
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              size: 20,
              color:
                  selecionado ? ColorTokens.accent : ColorTokens.textSecondary,
            ),
            const Gap.horizontal(SpacingTokens.sm),
            Text(objetivo.label, style: TypographyTokens.body),
          ],
        ),
      ),
    );
  }
}

/// Linha de uma medida corporal no sheet "Medidas corporais".
class _LinhaMedida extends StatelessWidget {
  const _LinhaMedida({required this.medida});

  final MedidaCorporal medida;

  @override
  Widget build(BuildContext context) {
    final bool positiva = medida.variacao >= 0;
    final Color corVariacao = medida.variacao == 0
        ? ColorTokens.textSecondary
        : (positiva ? ColorTokens.accent : ColorTokens.danger);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SpacingTokens.xs),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(medida.nome, style: TypographyTokens.body),
          ),
          Text(
            '${medida.valor.toStringAsFixed(1)} ${medida.unidade}',
            style: TypographyTokens.bodyStrong,
          ),
          if (medida.variacao != 0) ...<Widget>[
            const Gap.horizontal(SpacingTokens.xs),
            Icon(
              positiva
                  ? Icons.arrow_upward_rounded
                  : Icons.arrow_downward_rounded,
              size: 14,
              color: corVariacao,
            ),
            Text(
              medida.variacao.abs().toStringAsFixed(1),
              style: TypographyTokens.caption.copyWith(color: corVariacao),
            ),
          ],
        ],
      ),
    );
  }
}
