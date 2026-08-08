import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../components/buttons/app_button.dart';
import '../../../../components/common/gap.dart';
import '../../../../components/feedback/app_snackbar.dart';
import '../../../../components/inputs/app_text_field.dart';
import '../../../../components/scaffolds/app_scaffold.dart';
import '../../../../enum/pages_routes.dart';
import '../../../theme/tokens/color_tokens.dart';
import '../../../theme/tokens/spacing_tokens.dart';
import '../../../theme/tokens/typography_tokens.dart';
import '../../../utils/validators.dart';
import '../abstracts/auth_controller_interface.dart';
import 'widgets/ds_logo.dart';

/// Tela de login (planejamento §3.2). Sem navbar, formulario reativo.
class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final AuthControllerInterface _controller = Get.find();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final RxBool _formValido = false.obs;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  void _validar() {
    final bool valido = Validators.email(_emailController.text) == null &&
        Validators.senha(_senhaController.text) == null;
    _formValido.value = valido;
  }

  Future<void> _entrar() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    await _controller.login(
      email: _emailController.text.trim(),
      senha: _senhaController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              const Gap(SpacingTokens.xxl),
              const DsLogo(size: 72),
              const Gap(SpacingTokens.xl),
              const Text('Bem-vindo!', style: TypographyTokens.screenTitle),
              const Gap(SpacingTokens.xs),
              const Text(
                'Faça login para continuar',
                style: TypographyTokens.bodyMuted,
              ),
              const Gap(SpacingTokens.xl),
              AppTextField(
                label: 'E-mail',
                controller: _emailController,
                hint: 'seu@email.com',
                prefixIcon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                validator: Validators.email,
                onChanged: (_) => _validar(),
              ),
              const Gap(SpacingTokens.md),
              AppTextField(
                label: 'Senha',
                controller: _senhaController,
                isPassword: true,
                validator: Validators.senha,
                onChanged: (_) => _validar(),
              ),
              const Gap(SpacingTokens.sm),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => AppSnackbar.info('Em breve'),
                  child: Text(
                    'Esqueci minha senha',
                    style: TypographyTokens.label.copyWith(
                      color: ColorTokens.accent,
                    ),
                  ),
                ),
              ),
              const Gap(SpacingTokens.lg),
              Obx(
                () => AppButton(
                  label: 'Entrar',
                  loading: _controller.carregando.value,
                  onPressed:
                      (_formValido.value && !_controller.carregando.value)
                          ? () => _entrar()
                          : null,
                ),
              ),
              const Gap(SpacingTokens.lg),
              const Row(
                children: <Widget>[
                  Expanded(child: Divider(color: ColorTokens.divider)),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: SpacingTokens.sm,
                    ),
                    child: Text('ou', style: TypographyTokens.bodyMuted),
                  ),
                  Expanded(child: Divider(color: ColorTokens.divider)),
                ],
              ),
              const Gap(SpacingTokens.lg),
              Obx(
                () => AppButton(
                  label: 'Entrar com Google',
                  variant: AppButtonVariant.surface,
                  icon: Icons.g_mobiledata_rounded,
                  loading: _controller.carregando.value,
                  onPressed: _controller.carregando.value
                      ? null
                      : () => _controller.loginComGoogle(),
                ),
              ),
              const Gap(SpacingTokens.xxl),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    'Ainda não tem conta? ',
                    style: TypographyTokens.bodyMuted,
                  ),
                  GestureDetector(
                    onTap: () => Get.toNamed<void>(PagesRoutes.cadastro.path),
                    child: Text(
                      'Criar conta',
                      style: TypographyTokens.bodyStrong.copyWith(
                        color: ColorTokens.accent,
                      ),
                    ),
                  ),
                ],
              ),
              const Gap(SpacingTokens.lg),
            ],
          ),
        ),
      ),
    );
  }
}
