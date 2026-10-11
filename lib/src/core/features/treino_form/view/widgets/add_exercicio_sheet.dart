import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../components/anatomy/muscle_chip.dart';
import '../../../../../components/buttons/app_button.dart';
import '../../../../../components/feedback/app_snackbar.dart';
import '../../../../../components/inputs/app_dropdown_field.dart';
import '../../../../../components/inputs/app_text_field.dart';
import '../../../../../components/inputs/stepper_field.dart';
import '../../../../../components/media/exercise_illustration.dart';
import '../../../../../core/theme/tokens/spacing_tokens.dart';
import '../../../../../models/exercicio.dart';
import '../../../../../models/treino_exercicio.dart';
import '../../../../abstracts/format_service_interface.dart';
import '../../abstracts/treino_form_controller_interface.dart';

/// Bottom sheet de adicionar/editar exercicio no treino (tela 9).
///
/// Funciona em dois modos: adicao (quando [existente] e `null`) e edicao
/// (pre-preenche os valores de [existente] e troca o texto do botao).
/// Mantem estado local — nao polui o [TreinoFormControllerInterface].
class AddExercicioSheet extends StatefulWidget {
  const AddExercicioSheet({
    required this.exercicio,
    super.key,
    this.existente,
  });

  final Exercicio exercicio;
  final TreinoExercicio? existente;

  @override
  State<AddExercicioSheet> createState() => _AddExercicioSheetState();
}

class _AddExercicioSheetState extends State<AddExercicioSheet> {
  static const List<int> _opcoesDescanso = <int>[30, 45, 60, 90, 120, 180];

  final TreinoFormControllerInterface _controller = Get.find();
  final FormatServiceInterface _format = Get.find();

  late num _series;
  late num _repeticoes;
  late num _carga;
  late int _descansoSeg;
  late final TextEditingController _observacaoCtrl;

  bool get _emEdicao => widget.existente != null;

  @override
  void initState() {
    super.initState();
    final TreinoExercicio? existente = widget.existente;
    _series = existente?.series ?? 4;
    _repeticoes = existente?.repeticoes ?? 12;
    _carga = existente?.cargaInicial ?? 20;
    _descansoSeg = existente?.descansoSeg ?? 60;
    _observacaoCtrl = TextEditingController(text: existente?.observacao ?? '');
  }

  @override
  void dispose() {
    _observacaoCtrl.dispose();
    super.dispose();
  }

  void _confirmar() {
    if (_emEdicao) {
      _controller.atualizarExercicio(
        widget.existente!,
        series: _series.toInt(),
        repeticoes: _repeticoes.toInt(),
        carga: _carga.toDouble(),
        descansoSeg: _descansoSeg,
        observacao: _observacaoCtrl.text.trim(),
      );
    } else {
      _controller.adicionarExercicio(
        widget.exercicio,
        series: _series.toInt(),
        repeticoes: _repeticoes.toInt(),
        carga: _carga.toDouble(),
        descansoSeg: _descansoSeg,
        observacao: _observacaoCtrl.text.trim(),
      );
    }
    Get.back<void>();
    AppSnackbar.success(
      _emEdicao ? 'Alterações salvas' : 'Exercício adicionado',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ExerciseIllustration(
          nome: widget.exercicio.nome,
          grupo: widget.exercicio.grupoPrimario,
          height: 150,
          gifUrl: widget.exercicio.gifUrl,
        ),
        const SizedBox(height: SpacingTokens.md),
        MuscleChipsRow(grupos: widget.exercicio.todosGrupos),
        const SizedBox(height: SpacingTokens.lg),
        StepperField(
          label: 'Séries',
          value: _series,
          min: 1,
          max: 10,
          onChanged: (num valor) => setState(() => _series = valor),
        ),
        const SizedBox(height: SpacingTokens.md),
        StepperField(
          label: 'Repetições',
          value: _repeticoes,
          min: 1,
          max: 50,
          onChanged: (num valor) => setState(() => _repeticoes = valor),
        ),
        const SizedBox(height: SpacingTokens.md),
        StepperField(
          label: 'Carga inicial (kg)',
          value: _carga,
          min: 0,
          max: 500,
          step: 2.5,
          suffix: 'kg',
          onChanged: (num valor) => setState(() => _carga = valor),
        ),
        const SizedBox(height: SpacingTokens.md),
        AppDropdownField<int>(
          label: 'Descanso',
          value: _descansoSeg,
          items: _opcoesDescanso,
          itemLabel: _format.descanso,
          onChanged: (int? segundos) {
            if (segundos != null) {
              setState(() => _descansoSeg = segundos);
            }
          },
        ),
        const SizedBox(height: SpacingTokens.md),
        AppTextField(
          label: 'Observação (opcional)',
          controller: _observacaoCtrl,
          hint: 'Ex.: Execução controlada...',
          maxLines: 2,
        ),
        const SizedBox(height: SpacingTokens.lg),
        AppButton(
          label: _emEdicao ? 'Salvar alterações' : 'Adicionar ao treino',
          onPressed: _confirmar,
        ),
      ],
    );
  }
}
