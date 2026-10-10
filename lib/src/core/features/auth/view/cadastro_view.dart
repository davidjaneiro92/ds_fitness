import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../components/buttons/app_button.dart';
import '../../../../components/chips/app_chip.dart';
import '../../../../components/common/gap.dart';
import '../../../../components/inputs/app_text_field.dart';
import '../../../../components/navbars/app_navbar.dart';
import '../../../../components/scaffolds/app_scaffold.dart';
import '../../../theme/tokens/color_tokens.dart';
import '../../../theme/tokens/spacing_tokens.dart';
import '../../../theme/tokens/typography_tokens.dart';
import '../../../utils/validators.dart';
import '../abstracts/auth_controller_interface.dart';

/// Tela de cadastro (planejamento §3.3). Login automatico apos concluir.
class CadastroView extends StatefulWidget {
  const CadastroView({super.key});

  @override
  State<CadastroView> createState() => _CadastroViewState();
}

class _CadastroViewState extends State<CadastroView> {
  final AuthControllerInterface _controller = Get.find();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _dataController = TextEditingController();
  final Rx<String?> _sexo = Rx<String?>(null);
  final RxBool _formValido = false.obs;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _dataController.dispose();
    super.dispose();
  }

  void _validar() {
    final bool valido =
        Validators.nomeCompleto(_nomeController.text) == null &&
            Validators.email(_emailController.text) == null &&
            Validators.senhaNova(_senhaController.text) == null &&
            Validators.dataNascimento(_dataController.text) == null &&
            _sexo.value != null;
    _formValido.value = valido;
  }

  void _selecionarSexo(String valor) {
    _sexo.value = valor;
    _validar();
  }

  Future<void> _selecionarData() async {
    final DateTime agora = DateTime.now();
    // O tema do app e sempre dark (AppTheme.dark), entao o date picker ja
    // herda o mesmo visual sem necessidade de um Theme extra aqui.
    final DateTime? escolhida = await showDatePicker(
      context: context,
      initialDate: DateTime(agora.year - 20, agora.month, agora.day),
      firstDate: DateTime(agora.year - 100),
      lastDate: agora,
    );
    if (escolhida == null) {
      return;
    }
    _dataController.text = DateFormat('dd/MM/yyyy').format(escolhida);
    _validar();
  }

  Future<void> _criarConta() async {
    final bool formularioValido = _formKey.currentState?.validate() ?? false;
    final DateTime? dataNascimento = Validators.parseData(
      _dataController.text,
    );
    if (!formularioValido || _sexo.value == null || dataNascimento == null) {
      return;
    }
    await _controller.cadastrar(
      nome: _nomeController.text.trim(),
      email: _emailController.text.trim(),
      senha: _senhaController.text,
      dataNascimento: dataNascimento,
      sexo: _sexo.value!,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      navbar: const AppNavbar(showBack: true),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Gap(SpacingTokens.md),
              Text(
                'Criar conta',
                style: TypographyTokens.screenTitle.copyWith(fontSize: 24),
              ),
              const Gap(SpacingTokens.xs),
              const Text('Vamos começar!', style: TypographyTokens.bodyMuted),
              const Gap(SpacingTokens.xl),
              AppTextField(
                label: 'Nome completo',
                controller: _nomeController,
                hint: 'Seu nome e sobrenome',
                textCapitalization: TextCapitalization.words,
                validator: Validators.nomeCompleto,
                onChanged: (_) => _validar(),
              ),
              const Gap(SpacingTokens.md),
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
                validator: Validators.senhaNova,
                onChanged: (_) => _validar(),
              ),
              const Gap(SpacingTokens.xs),
              const Text(
                'Mínimo de 8 caracteres',
                style: TypographyTokens.caption,
              ),
              const Gap(SpacingTokens.md),
              AppTextField(
                label: 'Data de nascimento',
                controller: _dataController,
                hint: 'dd/mm/aaaa',
                readOnly: true,
                onTap: _selecionarData,
                validator: Validators.dataNascimento,
                suffixIcon: const Icon(
                  Icons.calendar_today_rounded,
                  size: 18,
                  color: ColorTokens.textSecondary,
                ),
              ),
              const Gap(SpacingTokens.md),
              const Text('Sexo', style: TypographyTokens.label),
              const Gap(SpacingTokens.sm),
              Obx(
                () => Row(
                  children: <Widget>[
                    AppChip(
                      label: 'Masculino',
                      selected: _sexo.value == 'Masculino',
                      onTap: () => _selecionarSexo('Masculino'),
                    ),
                    const Gap.horizontal(SpacingTokens.sm),
                    AppChip(
                      label: 'Feminino',
                      selected: _sexo.value == 'Feminino',
                      onTap: () => _selecionarSexo('Feminino'),
                    ),
                  ],
                ),
              ),
              const Gap(SpacingTokens.xl),
              Obx(
                () => AppButton(
                  label: 'Criar conta',
                  loading: _controller.carregando.value,
                  onPressed:
                      (_formValido.value && !_controller.carregando.value)
                          ? () => _criarConta()
                          : null,
                ),
              ),
              const Gap(SpacingTokens.xl),
            ],
          ),
        ),
      ),
    );
  }
}
