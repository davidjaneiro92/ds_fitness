import 'package:ds_fitness/src/components/anatomy/grupo_muscular_imagem.dart';
import 'package:ds_fitness/src/components/media/asset_first_frame.dart';
import 'package:ds_fitness/src/components/media/exercise_illustration.dart';
import 'package:ds_fitness/src/constants/app_assets.dart';
import 'package:ds_fitness/src/enum/grupo_muscular.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Chave de um exercicio do catalogo, com os dois arquivos declarados no
/// `pubspec.yaml`.
const String _supino = 'pectorals/barbell-bench-press';

Widget _tela(Widget filho) {
  return MaterialApp(home: Scaffold(body: Center(child: filho)));
}

void main() {
  setUp(AssetFirstFrame.limparCache);

  group('AppAssets', () {
    test('monta o caminho de cada imagem a partir da chave', () {
      expect(
        AppAssets.gifDoExercicio(_supino),
        'assets/img/gifs/pectorals/barbell-bench-press.gif',
      );
      expect(
        AppAssets.miniaturaDoExercicio(_supino),
        'assets/img/imagens_estaticas/pectorals/barbell-bench-press.thumb.webp',
      );
      expect(
        AppAssets.musculo(GrupoMuscular.triceps),
        'assets/img/muscles/triceps.png',
      );
    });
  });

  group('ExerciseIllustration', () {
    testWidgets('sem imagem, mostra a ilustracao generica', (WidgetTester tester) async {
      await tester.pumpWidget(
        _tela(
          const ExerciseIllustration(
            imagem: '',
            grupo: GrupoMuscular.peito,
          ),
        ),
      );

      expect(find.byType(Image), findsNothing);
      expect(find.byType(AssetFirstFrame), findsNothing);
      expect(find.byIcon(Icons.sports_gymnastics_rounded), findsOneWidget);
    });

    testWidgets('em tela cheia, anima o GIF dos assets', (WidgetTester tester) async {
      await tester.pumpWidget(
        _tela(
          const ExerciseIllustration(
            imagem: _supino,
            grupo: GrupoMuscular.peito,
          ),
        ),
      );

      final Image imagem = tester.widget<Image>(find.byType(Image));
      final AssetImage provider = imagem.image as AssetImage;
      expect(provider.assetName, AppAssets.gifDoExercicio(_supino));
    });

    testWidgets('na lista usa a miniatura parada, e nao o GIF', (WidgetTester tester) async {
      await tester.pumpWidget(
        _tela(
          const ExerciseIllustration(
            imagem: _supino,
            grupo: GrupoMuscular.peito,
            compact: true,
          ),
        ),
      );

      final AssetFirstFrame miniatura =
          tester.widget<AssetFirstFrame>(find.byType(AssetFirstFrame));
      expect(miniatura.asset, AppAssets.miniaturaDoExercicio(_supino));
      expect(
        find.byType(Image),
        findsNothing,
        reason: 'a lista nao carrega o GIF pesado nem anima a miniatura',
      );
    });

    testWidgets('se o arquivo nao existe, cai na ilustracao generica', (WidgetTester tester) async {
      await tester.pumpWidget(
        _tela(
          const ExerciseIllustration(
            imagem: 'pasta-que-nao-existe/arquivo',
            grupo: GrupoMuscular.costas,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.rowing_rounded), findsOneWidget);
    });
  });

  group('AssetFirstFrame', () {
    testWidgets('decodifica o primeiro quadro da miniatura animada', (WidgetTester tester) async {
      await tester.pumpWidget(
        _tela(
          SizedBox(
            width: 56,
            height: 56,
            child: AssetFirstFrame(
              asset: AppAssets.miniaturaDoExercicio(_supino),
            ),
          ),
        ),
      );

      // A decodificacao usa I/O e codec reais, que o relogio falso do teste nao
      // faz andar sozinho: espera o quadro aparecer, com um limite largo para a
      // maquina carregada.
      for (int i = 0; i < 100 && find.byType(RawImage).evaluate().isEmpty; i++) {
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
        await tester.pump();
      }

      expect(find.byType(RawImage), findsOneWidget);
    });

    testWidgets('mostra o substituto enquanto carrega e se o arquivo nao existe', (WidgetTester tester) async {
      await tester.pumpWidget(
        _tela(
          const AssetFirstFrame(
            asset: 'assets/img/nao-existe.webp',
            fallback: Text('substituto'),
          ),
        ),
      );
      expect(find.text('substituto'), findsOneWidget);

      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
      await tester.pump();

      expect(find.text('substituto'), findsOneWidget);
      expect(find.byType(RawImage), findsNothing);
    });
  });

  group('GrupoMuscularImagem', () {
    testWidgets('mostra a imagem do grupo em cores quando destacado', (WidgetTester tester) async {
      await tester.pumpWidget(
        _tela(const GrupoMuscularImagem(grupo: GrupoMuscular.peito)),
      );

      final Image imagem = tester.widget<Image>(find.byType(Image));
      expect((imagem.image as ResizeImage).imageProvider, isA<AssetImage>());
      expect(find.byType(ColorFiltered), findsNothing);
    });

    testWidgets('fica em tons de cinza quando o grupo nao esta escolhido', (WidgetTester tester) async {
      await tester.pumpWidget(
        _tela(
          const GrupoMuscularImagem(
            grupo: GrupoMuscular.peito,
            destacado: false,
          ),
        ),
      );

      expect(find.byType(ColorFiltered), findsOneWidget);
    });

    testWidgets('"Todos" nao e um grupo: mostra so o icone', (WidgetTester tester) async {
      await tester.pumpWidget(
        _tela(const GrupoMuscularImagem(grupo: GrupoMuscular.todos)),
      );

      expect(find.byType(Image), findsNothing);
      expect(find.byIcon(Icons.fitness_center_rounded), findsOneWidget);
    });
  });
}
