import 'package:ds_fitness/src/core/services/format_service.dart';
import 'package:ds_fitness/src/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FormatService', () {
    final FormatService format = FormatService();

    test('cronometro formata mm:ss', () {
      expect(format.cronometro(2905), '48:25');
      expect(format.cronometro(59), '00:59');
      expect(format.cronometro(-10), '00:00');
    });

    test('duracao usa horas quando passa de 60 min', () {
      expect(format.duracao(37500), '10h 25m');
      expect(format.duracao(2700), '45 min');
    });

    test('descanso descreve segundos e minutos', () {
      expect(format.descanso(60), '1 min');
      expect(format.descanso(45), '45 segundos');
      expect(format.descanso(90), '1 min 30s');
    });
  });

  group('Validators', () {
    test('email valida formato', () {
      expect(Validators.email('david@dsfitness.com'), isNull);
      expect(Validators.email('david'), isNotNull);
      expect(Validators.email(''), isNotNull);
    });

    test('senha exige 6 caracteres', () {
      expect(Validators.senha('123456'), isNull);
      expect(Validators.senha('123'), isNotNull);
    });

    test('senha de conta nova exige 8 caracteres, como o servidor', () {
      expect(Validators.senhaNova('12345678'), isNull);
      expect(Validators.senhaNova('1234567'), isNotNull);
      expect(Validators.senhaNova(''), isNotNull);
    });

    test('data de nascimento exige idade minima de 16 anos', () {
      final DateTime hoje = DateTime.now();
      final String maiorDeIdade = '01/01/${hoje.year - 20}';
      final String menorDeIdade = '01/01/${hoje.year - 10}';
      expect(Validators.dataNascimento(maiorDeIdade), isNull);
      expect(Validators.dataNascimento(menorDeIdade), isNotNull);
      expect(Validators.dataNascimento('31/02/2000'), isNotNull);
    });
  });
}
