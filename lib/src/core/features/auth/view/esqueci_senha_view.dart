import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../components/buttons/app_button.dart';
import '../../../../components/common/gap.dart';
import '../../../../components/inputs/app_text_field.dart';
import '../../../../components/navbars/app_navbar.dart';
import '../../../../components/scaffolds/app_scaffold.dart';
import '../../../../enum/pages_routes.dart';
import '../../../theme/tokens/color_tokens.dart';
import '../../../theme/tokens/spacing_tokens.dart';
import '../../../theme/tokens/typography_tokens.dart';
import '../../../utils/validators.dart';
import '../abstracts/auth_controller_interface.dart';

/// Solicita o envio das instruções de redefinição para o e-mail informado.
class EsqueciSenhaView extends StatefulWidget {
  const EsqueciSenhaView({super.key});

  @override
  State<EsqueciSenhaView> createState() => _EsqueciSenhaViewState();
}

class _EsqueciSenhaViewState extends State<EsqueciSenhaView> {
  final AuthControllerInterface _controller = Get.find();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codigoController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _confirmacaoController = TextEditingController();
  final RxBool _solicitado = false.obs;

  @override
  void dispose() {
    _emailController.dispose();
    _codigoController.dispose();
    _senhaController.dispose();
    _confirmacaoController.dispose();
    super.dispose();
  }

  Future<void> _solicitar() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final bool sucesso = await _controller.solicitarRecuperacaoSenha(
      email: _emailController.text.trim(),
    );
    if (sucesso) _solicitado.value = true;
  }

  Future<void> _redefinir() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final bool sucesso = await _controller.redefinirSenha(
      email: _emailController.text.trim(),
      codigo: _codigoController.text.trim(),
      novaSenha: _senhaController.text,
    );
    if (sucesso) Get.offAllNamed<void>(PagesRoutes.login.path);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      navbar: const AppNavbar(showBack: true),
      body: Obx(
        () => SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Gap(SpacingTokens.xl),
                const Icon(Icons.lock_reset_rounded,
                    size: 44, color: ColorTokens.accent),
                const Gap(SpacingTokens.lg),
                Text(
                  _solicitado.value ? 'Crie uma nova senha' : 'Esqueceu sua senha?',
                  style: TypographyTokens.screenTitle.copyWith(fontSize: 24),
                ),
                const Gap(SpacingTokens.sm),
                Text(
                  _solicitado.value
                      ? 'Enviamos um código de verificação para o endereço informado. Digite-o abaixo para escolher uma nova senha.'
                      : 'Informe o e-mail usado no cadastro para receber as instruções de recuperação.',
                  style: TypographyTokens.bodyMuted,
                ),
                if (!_solicitado.value) ...<Widget>[
                  const Gap(SpacingTokens.xl),
                  AppTextField(
                    label: 'E-mail',
                    controller: _emailController,
                    hint: 'seu@email.com',
                    prefixIcon: Icons.mail_outline_rounded,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                  ),
                  const Gap(SpacingTokens.xl),
                  AppButton(
                    label: 'Enviar instruções',
                    loading: _controller.carregando.value,
                    onPressed: _controller.carregando.value ? null : _solicitar,
                  ),
                ] else ...<Widget>[
                  const Gap(SpacingTokens.xl),
                  AppTextField(
                    label: 'Código enviado por e-mail',
                    controller: _codigoController,
                    hint: 'Código de 6 dígitos',
                    keyboardType: TextInputType.number,
                    validator: (valor) => valor == null || valor.trim().length != 6
                        ? 'Informe o código de 6 dígitos.'
                        : null,
                  ),
                  const Gap(SpacingTokens.md),
                  AppTextField(
                    label: 'Nova senha',
                    controller: _senhaController,
                    isPassword: true,
                    validator: Validators.senhaNova,
                  ),
                  const Gap(SpacingTokens.md),
                  AppTextField(
                    label: 'Confirmar nova senha',
                    controller: _confirmacaoController,
                    isPassword: true,
                    validator: (valor) => valor != _senhaController.text
                        ? 'As senhas não coincidem.'
                        : null,
                  ),
                  const Gap(SpacingTokens.xl),
                  AppButton(
                    label: 'Redefinir senha',
                    loading: _controller.carregando.value,
                    onPressed: _controller.carregando.value ? null : _redefinir,
                  ),
                  Center(
                    child: TextButton(
                      onPressed: () => _solicitado.value = false,
                      child: const Text('Trocar e-mail ou reenviar código'),
                    ),
                  ),
                ],
                const Gap(SpacingTokens.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
