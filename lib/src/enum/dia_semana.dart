/// Dia da semana de um treino, na numeracao da API: 1 = segunda ... 7 = domingo.
enum DiaSemana {
  segunda(1, 'Seg', 'Segunda'),
  terca(2, 'Ter', 'Terça'),
  quarta(3, 'Qua', 'Quarta'),
  quinta(4, 'Qui', 'Quinta'),
  sexta(5, 'Sex', 'Sexta'),
  sabado(6, 'Sáb', 'Sábado'),
  domingo(7, 'Dom', 'Domingo');

  const DiaSemana(this.numero, this.abreviacao, this.nome);

  /// Numero que a API usa (1 a 7).
  final int numero;

  /// Ex.: "Seg" — nos botoes de escolha do dia.
  final String abreviacao;

  /// Ex.: "Segunda" — nos titulos.
  final String nome;

  /// `null` quando o treino nao tem dia marcado (ou o numero e invalido).
  static DiaSemana? deNumero(int? numero) {
    for (final DiaSemana dia in DiaSemana.values) {
      if (dia.numero == numero) {
        return dia;
      }
    }
    return null;
  }

  /// O dia de hoje, no calendario do aparelho.
  static DiaSemana hoje() => deNumero(DateTime.now().weekday)!;
}
