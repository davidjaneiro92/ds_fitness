import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../components/chips/dia_semana_chips.dart';
import '../../../../../components/common/gap.dart';
import '../../../../../components/inputs/app_dropdown_field.dart';
import '../../../../../components/inputs/app_text_field.dart';
import '../../../../../core/theme/tokens/spacing_tokens.dart';
import '../../../../../core/theme/tokens/typography_tokens.dart';
import '../../../../../enum/objetivo_treino.dart';
import '../../abstracts/treino_form_controller_interface.dart';

/// Os dados do treino — dia da semana, nome, objetivo e descricao —, ligados ao
/// [TreinoFormControllerInterface]. Serve a tela *Novo treino* e ao *sheet* de
/// editar os dados na tela de revisao.
class TreinoDadosForm extends StatefulWidget {
  const TreinoDadosForm({super.key});

  @override
  State<TreinoDadosForm> createState() => _TreinoDadosFormState();
}

class _TreinoDadosFormState extends State<TreinoDadosForm> {
  final TreinoFormControllerInterface _controller = Get.find();

  late final TextEditingController _nomeCtrl;
  late final TextEditingController _descricaoCtrl;
  Worker? _workerNome;
  Worker? _workerDescricao;

  @override
  void initState() {
    super.initState();
    _nomeCtrl = TextEditingController(text: _controller.nome.value);
    _descricaoCtrl = TextEditingController(text: _controller.descricao.value);
    // O treino pode terminar de carregar depois da tela abrir: o campo
    // acompanha o estado, sem sobrescrever o que o usuario esta digitando.
    _workerNome = ever<String>(_controller.nome, (String valor) {
      if (_nomeCtrl.text != valor) {
        _nomeCtrl.text = valor;
      }
    });
    _workerDescricao = ever<String>(_controller.descricao, (String valor) {
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text('Dia da semana', style: TypographyTokens.fieldLabel),
        const Gap(SpacingTokens.sm),
        Obx(
          () => DiaSemanaChips(
            selecionado: _controller.dia.value,
            onSelecionar: _controller.escolherDia,
          ),
        ),
        const Gap(SpacingTokens.md),
        AppTextField(
          label: 'Nome do treino',
          controller: _nomeCtrl,
          hint: 'Ex.: Treino A',
          textCapitalization: TextCapitalization.sentences,
          onChanged: (String valor) => _controller.nome.value = valor,
        ),
        const Gap(SpacingTokens.md),
        Obx(
          () => AppDropdownField<ObjetivoTreino>(
            label: 'Objetivo (opcional)',
            value: _controller.objetivo.value,
            items: ObjetivoTreino.values,
            itemLabel: (ObjetivoTreino o) => o.label,
            onChanged: (ObjetivoTreino? o) {
              if (o != null) {
                _controller.objetivo.value = o;
              }
            },
          ),
        ),
        const Gap(SpacingTokens.md),
        AppTextField(
          label: 'Descrição (opcional)',
          controller: _descricaoCtrl,
          hint: 'Ex.: foco em exercícios compostos para membros superiores.',
          maxLines: 4,
          maxLength: TreinoFormControllerInterface.limiteDaDescricao,
          textCapitalization: TextCapitalization.sentences,
          onChanged: (String valor) => _controller.descricao.value = valor,
        ),
      ],
    );
  }
}
