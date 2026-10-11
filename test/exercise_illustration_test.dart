import 'package:cached_network_image/cached_network_image.dart';
import 'package:ds_fitness/src/components/media/exercise_illustration.dart';
import 'package:ds_fitness/src/enum/grupo_muscular.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _tela(Widget filho) {
  return MaterialApp(home: Scaffold(body: Center(child: filho)));
}

void main() {
  group('ExerciseIllustration', () {
    testWidgets('sem link, mostra a ilustracao generica', (WidgetTester tester) async {
      await tester.pumpWidget(
        _tela(
          const ExerciseIllustration(
            nome: 'Exercicio do usuario',
            grupo: GrupoMuscular.peito,
          ),
        ),
      );

      expect(find.byType(CachedNetworkImage), findsNothing);
      expect(find.byIcon(Icons.sports_gymnastics_rounded), findsOneWidget);
    });

    testWidgets('na lista usa a miniatura, e nao o GIF', (WidgetTester tester) async {
      await tester.pumpWidget(
        _tela(
          const ExerciseIllustration(
            nome: 'Supino Reto',
            grupo: GrupoMuscular.peito,
            compact: true,
            gifUrl: 'https://exemplo.test/supino.gif',
          ),
        ),
      );

      expect(
        find.byType(CachedNetworkImage),
        findsNothing,
        reason: 'so o GIF foi informado: a lista nao carrega o arquivo pesado',
      );
    });

    testWidgets('com link, pede a imagem pela rede', (WidgetTester tester) async {
      await tester.pumpWidget(
        _tela(
          const ExerciseIllustration(
            nome: 'Supino Reto',
            grupo: GrupoMuscular.peito,
            gifUrl: 'https://exemplo.test/supino.gif',
          ),
        ),
      );

      final CachedNetworkImage imagem =
          tester.widget<CachedNetworkImage>(find.byType(CachedNetworkImage));
      expect(imagem.imageUrl, 'https://exemplo.test/supino.gif');
    });
  });
}
