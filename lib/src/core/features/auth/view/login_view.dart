import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../components/buttons/app_button.dart';
import '../../../../components/buttons/app_social_button.dart';
import '../../../../components/common/gap.dart';
import '../../../../components/inputs/app_text_field.dart';
import '../../../../components/scaffolds/app_scaffold.dart';
import '../../../../constants/app_assets.dart';
import '../../../../enum/pages_routes.dart';
import '../../../theme/tokens/color_tokens.dart';
import '../../../theme/tokens/spacing_tokens.dart';
import '../../../theme/tokens/typography_tokens.dart';
import '../../../utils/validators.dart';
import '../abstracts/auth_controller_interface.dart';
import 'widgets/ds_logo.dart';

/// Tela de login: marca com o lema, e-mail e senha, *Entrar*, e os botoes de
/// entrar por Google, Apple e Facebook — que por enquanto so avisam que vem em
/// breve. Sem navbar. O botao *Entrar* fica sempre ativo: os campos sao
/// validados ao tocar nele, e os erros aparecem sob cada campo.
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

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
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
      backgroundImage: AppAssets.loginBackground,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              const Gap(SpacingTokens.xxl),
              const DsLogo(size: 52, mostrarLema: true),
              const Gap(SpacingTokens.xxl),
              AppTextField(
                controller: _emailController,
                hint: 'E-mail',
                prefixIcon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                validator: Validators.email,
              ),
              const Gap(SpacingTokens.md),
              AppTextField(
                controller: _senhaController,
                hint: 'Senha',
                prefixIcon: Icons.lock_outline_rounded,
                isPassword: true,
                validator: Validators.senha,
              ),
              const Gap(SpacingTokens.lg),
              Obx(
                () => AppButton(
                  label: 'Entrar',
                  loading: _controller.carregando.value,
                  onPressed:
                      _controller.carregando.value ? null : () => _entrar(),
                ),
              ),
              const Gap(SpacingTokens.sm + 4),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => Get.toNamed<void>(PagesRoutes.esqueciSenha.path),
                  child: Text(
                    'Esqueceu sua senha?',
                    style: TypographyTokens.label.copyWith(
                      color: ColorTokens.textPrimary,
                      decoration: TextDecoration.underline,
                      decorationColor: ColorTokens.textPrimary,
                    ),
                  ),
                ),
              ),
              const Gap(SpacingTokens.xl),
              const Text('Ou entre com', style: TypographyTokens.bodyMuted),
              const Gap(SpacingTokens.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  AppSocialButton(
                    icon: Icons.g_mobiledata_rounded,
                    semanticsLabel: 'Entrar com o Google',
                    onTap: () => _controller.loginComGoogle(),
                  ),
                  const Gap.horizontal(SpacingTokens.md),
                  AppSocialButton(
                    icon: Icons.apple,
                    semanticsLabel: 'Entrar com a Apple',
                    onTap: () => _controller.loginComApple(),
                  ),
                  const Gap.horizontal(SpacingTokens.md),
                  AppSocialButton(
                    icon: Icons.facebook,
                    iconColor: ColorTokens.info,
                    semanticsLabel: 'Entrar com o Facebook',
                    onTap: () => _controller.loginComFacebook(),
                  ),
                ],
              ),
              const Gap(SpacingTokens.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    'Ainda não tem uma conta? ',
                    style: TypographyTokens.bodyMuted,
                  ),
                  GestureDetector(
                    onTap: () => Get.toNamed<void>(PagesRoutes.cadastro.path),
                    child: Text(
                      'Cadastre-se',
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
