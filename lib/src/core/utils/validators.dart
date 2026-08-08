/// Validadores de formulario (mensagens em pt-BR).
abstract class Validators {
  static final RegExp _email = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');

  static String? obrigatorio(String? valor, {String campo = 'Campo'}) {
    if (valor == null || valor.trim().isEmpty) {
      return '$campo é obrigatório';
    }
    return null;
  }

  static String? email(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Informe seu e-mail';
    }
    if (!_email.hasMatch(valor.trim())) {
      return 'E-mail inválido';
    }
    return null;
  }

  static String? senha(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'Informe sua senha';
    }
    if (valor.length < 6) {
      return 'A senha deve ter no mínimo 6 caracteres';
    }
    return null;
  }

  static String? nomeCompleto(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Informe seu nome completo';
    }
    if (valor.trim().split(' ').where((String p) => p.isNotEmpty).length < 2) {
      return 'Informe nome e sobrenome';
    }
    return null;
  }

  /// Aceita `dd/mm/aaaa` e exige idade minima de 16 anos.
  static String? dataNascimento(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Informe sua data de nascimento';
    }
    final DateTime? data = parseData(valor);
    if (data == null) {
      return 'Data inválida (dd/mm/aaaa)';
    }
    if (idadeEm(data) < 16) {
      return 'Idade mínima de 16 anos';
    }
    return null;
  }

  /// Converte `dd/mm/aaaa` em [DateTime]; devolve `null` se invalida.
  static DateTime? parseData(String valor) {
    final List<String> partes = valor.split('/');
    if (partes.length != 3) {
      return null;
    }
    final int? dia = int.tryParse(partes[0]);
    final int? mes = int.tryParse(partes[1]);
    final int? ano = int.tryParse(partes[2]);
    if (dia == null || mes == null || ano == null) {
      return null;
    }
    if (mes < 1 || mes > 12 || dia < 1 || dia > 31 || ano < 1900) {
      return null;
    }
    final DateTime data = DateTime(ano, mes, dia);
    if (data.day != dia || data.month != mes) {
      return null;
    }
    return data;
  }

  static int idadeEm(DateTime nascimento) {
    final DateTime hoje = DateTime.now();
    int idade = hoje.year - nascimento.year;
    final bool aniversarioPassou = hoje.month > nascimento.month ||
        (hoje.month == nascimento.month && hoje.day >= nascimento.day);
    if (!aniversarioPassou) {
      idade--;
    }
    return idade;
  }
}
