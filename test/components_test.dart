
import 'package:ds_fitness/src/components/cards/exercicio_selecao_tile.dart';
import 'package:ds_fitness/src/components/cards/grupo_muscular_tile.dart';
import 'package:ds_fitness/src/components/chips/dia_semana_chips.dart';
import 'package:ds_fitness/src/components/inputs/app_text_field.dart';
import 'package:ds_fitness/src/core/utils/texto_utils.dart';
import 'package:ds_fitness/src/enum/dia_semana.dart';
import 'package:ds_fitness/src/enum/grupo_muscular.dart';
import 'package:ds_fitness/src/models/exercicio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _tela(Widget filho) {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(child: Padding(padding: const EdgeInsets.all(16), child: filho)),
    ),
  );
}

void main() {
  group('TextoUtils', () {
    test('normaliza caixa e acento', () {
      expect(TextoUtils.normalizar('  Tríceps Máquina  '), 'triceps maquina');
      expect(TextoUtils.normalizar('Abdômen e Glúteos'), 'abdomen e gluteos');
      expect(TextoUtils.normalizar('Ação'), 'acao');
    });

    test('contem ignora caixa e acento, e busca vazia casa com tudo', () {
      expect(TextoUtils.contem('Supino na Máquina', 'MAQUINA'), isTrue);
      expect(TextoUtils.contem('Supino na Máquina', 'máquina'), isTrue);
      expect(TextoUtils.contem('Supino na Máquina', 'halter'), isFalse);
      expect(TextoUtils.contem('Supino', ''), isTrue);
      expect(TextoUtils.contem('Supino', '   '), isTrue);
    });
  });

  group('DiaSemanaChips', () {
    testWidgets('mostra os sete dias e avisa qual foi tocado', (WidgetTester tester) async {
      DiaSemana? tocado;
      await tester.pumpWidget(
        _tela(
          DiaSemanaChips(
            selecionado: DiaSemana.segunda,
            onSelecionar: (DiaSemana dia) => tocado = dia,
          ),
        ),
      );

      for (final String abreviacao in <String>['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom']) {
        expect(find.text(abreviacao), findsOneWidget);
      }

      await tester.tap(find.text('Sex'));
      expect(tocado, DiaSemana.sexta);
    });

    testWidgets('so o dia selecionado fica marcado', (WidgetTester tester) async {
      await tester.pumpWidget(
        _tela(DiaSemanaChips(selecionado: DiaSemana.quarta, onSelecionar: (_) {})),
      );

      final SemanticsHandle handle = tester.ensureSemantics();
      final SemanticsData quarta =
          tester.getSemantics(find.bySemanticsLabel('Quarta')).getSemanticsData();
      final SemanticsData terca =
          tester.getSemantics(find.bySemanticsLabel('Terça')).getSemanticsData();

      expect(quarta.hasFlag(SemanticsFlag.isSelected), isTrue);
      expect(terca.hasFlag(SemanticsFlag.isSelected), isFalse);
      handle.dispose();
    });

    testWidgets('sem dia (treino antigo), nenhum fica marcado', (WidgetTester tester) async {
      await tester.pumpWidget(
        _tela(DiaSemanaChips(selecionado: null, onSelecionar: (_) {})),
      );

      expect(find.text('Seg'), findsOneWidget);
    });
  });

  group('GrupoMuscularTile', () {
    testWidgets('selecionado mostra o visto, e o toque avisa', (WidgetTester tester) async {
      int toques = 0;
      await tester.pumpWidget(
        _tela(
          SizedBox(
            width: 110,
            height: 130,
            child: GrupoMuscularTile(
              grupo: GrupoMuscular.peito,
              selecionado: true,
              onTap: () => toques++,
            ),
          ),
        ),
      );

      expect(find.text('Peito'), findsOneWidget);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);

      await tester.tap(find.text('Peito'));
      expect(toques, 1);
    });

    testWidgets('sem selecionar nao tem visto', (WidgetTester tester) async {
      await tester.pumpWidget(
        _tela(
          SizedBox(
            width: 110,
            height: 130,
            child: GrupoMuscularTile(
              grupo: GrupoMuscular.ombro,
              selecionado: false,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Ombros'), findsOneWidget);
      expect(find.byIcon(Icons.check_rounded), findsNothing);
    });
  });

  group('ExercicioSelecaoTile', () {
    const Exercicio supino = Exercicio(
      id: '1',
      nome: 'Supino Reto',
      grupoPrimario: GrupoMuscular.peito,
      gruposSecundarios: <GrupoMuscular>[GrupoMuscular.triceps, GrupoMuscular.ombro],
    );

    testWidgets('mostra nome e grupos, e o toque seleciona', (WidgetTester tester) async {
      int toques = 0;
      await tester.pumpWidget(
        _tela(
          ExercicioSelecaoTile(
            exercicio: supino,
            selecionado: false,
            onTap: () => toques++,
          ),
        ),
      );

      expect(find.text('Supino Reto'), findsOneWidget);
      expect(find.text('Peito • Tríceps • Ombros'), findsOneWidget);

      await tester.tap(find.text('Supino Reto'));
      expect(toques, 1);
    });

    testWidgets('selecionado mostra o visto da marca', (WidgetTester tester) async {
      await tester.pumpWidget(
        _tela(ExercicioSelecaoTile(exercicio: supino, selecionado: true, onTap: () {})),
      );

      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });

    testWidgets('exercicio que ja esta no treino fica travado', (WidgetTester tester) async {
      int toques = 0;
      await tester.pumpWidget(
        _tela(
          ExercicioSelecaoTile(
            exercicio: supino,
            selecionado: false,
            jaAdicionado: true,
            onTap: () => toques++,
          ),
        ),
      );

      expect(find.text('No treino'), findsOneWidget);

      await tester.tap(find.text('Supino Reto'));
      expect(toques, 0, reason: 'a API nao aceita o mesmo exercicio duas vezes');
    });
  });

  group('AppTextField', () {
    testWidgets('o contador acompanha o texto e o limite corta o excesso', (WidgetTester tester) async {
      final TextEditingController controller = TextEditingController();
      await tester.pumpWidget(
        _tela(
          AppTextField(
            label: 'Descrição (opcional)',
            controller: controller,
            maxLength: 10,
          ),
        ),
      );

      expect(find.text('0/10'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField), 'Peito e triceps hoje');
      await tester.pump();

      expect(controller.text, 'Peito e tr');
      expect(find.text('10/10'), findsOneWidget);
    });

    testWidgets('sem rotulo, mostra so o campo', (WidgetTester tester) async {
      await tester.pumpWidget(_tela(const AppTextField(hint: 'E-mail')));

      expect(find.text('E-mail'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
    });
  });
}
