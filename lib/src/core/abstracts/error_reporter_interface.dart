/// Natureza de um erro enviado ao log remoto.
enum TipoDeErro {
  /// Resposta de erro (ou falta de resposta) da API.
  requisicao('requisicao'),

  /// Qualquer outro erro do app (excecao, falha de tela, erro do Flutter).
  aplicativo('aplicativo');

  const TipoDeErro(this.valor);

  final String valor;
}

/// Um erro pronto para ir ao log remoto (`POST /api/v1/log/erros`).
class ErroRegistrado {
  ErroRegistrado({
    required this.tipo,
    required this.mensagem,
    String? detalhe,
    this.contexto,
    this.metodo,
    this.caminho,
    this.statusHttp,
    this.duracaoMs,
    DateTime? ocorreuEm,
  })  : detalhe = _cortar(detalhe),
        ocorreuEm = (ocorreuEm ?? DateTime.now()).toUtc();

  factory ErroRegistrado.deJson(Map<String, dynamic> json) {
    return ErroRegistrado(
      tipo: json['tipo'] == TipoDeErro.requisicao.valor
          ? TipoDeErro.requisicao
          : TipoDeErro.aplicativo,
      mensagem: json['mensagem'] as String,
      detalhe: json['detalhe'] as String?,
      contexto: json['contexto'] as String?,
      metodo: json['metodo'] as String?,
      caminho: json['caminho'] as String?,
      statusHttp: json['statusHttp'] as int?,
      duracaoMs: json['duracaoMs'] as int?,
      ocorreuEm: DateTime.tryParse(json['ocorreuEm'] as String? ?? ''),
    );
  }

  /// Limite do detalhe, para a fila local nao crescer sem controle.
  static const int _limiteDoDetalhe = 8000;

  static String? _cortar(String? texto) {
    if (texto == null || texto.length <= _limiteDoDetalhe) {
      return texto;
    }
    return texto.substring(0, _limiteDoDetalhe);
  }

  final TipoDeErro tipo;
  final String mensagem;

  /// Stack trace, corpo da resposta ou qualquer detalhe longo.
  final String? detalhe;

  /// Onde aconteceu: a tela ou a operacao.
  final String? contexto;
  final String? metodo;
  final String? caminho;
  final int? statusHttp;
  final int? duracaoMs;
  final DateTime ocorreuEm;

  Map<String, dynamic> paraJson() {
    return <String, dynamic>{
      'tipo': tipo.valor,
      'mensagem': mensagem,
      'detalhe': detalhe,
      'contexto': contexto,
      'metodo': metodo,
      'caminho': caminho,
      'statusHttp': statusHttp,
      'duracaoMs': duracaoMs,
      'ocorreuEm': ocorreuEm.toIso8601String(),
    };
  }
}

/// Envia erros do app para a tabela de log da API.
///
/// Fire-and-forget: nunca lanca, nunca mostra loading nem dialogo. Quando a
/// API nao responde, o erro fica numa fila local e sai na proxima tentativa.
abstract class ErrorReporterInterface {
  void registrar(ErroRegistrado erro);

  /// Tenta enviar o que ficou na fila (ex.: na abertura do app).
  Future<void> reenviarPendentes();
}
