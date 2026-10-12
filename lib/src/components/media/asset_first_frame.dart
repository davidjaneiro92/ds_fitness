import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Mostra, parado, o primeiro quadro de uma imagem animada dos assets (GIF ou
/// WebP animado).
///
/// As miniaturas dos exercicios sao animacoes curtas, mas nas listas a imagem
/// deve ficar fixa: so o primeiro quadro e decodificado. Cada arquivo e
/// decodificado uma vez e o quadro fica guardado na memoria — o catalogo e
/// pequeno e a miniatura tem 128 px, entao o cache nao precisa de limite.
class AssetFirstFrame extends StatefulWidget {
  const AssetFirstFrame({
    required this.asset,
    super.key,
    this.largura = 128,
    this.fit = BoxFit.cover,
    this.fallback,
  });

  /// Caminho do arquivo nos assets.
  final String asset;

  /// Largura, em pixels, em que o quadro e decodificado.
  final int largura;

  final BoxFit fit;

  /// Mostrado enquanto o quadro carrega e se o arquivo nao existir.
  final Widget? fallback;

  /// Esvazia o cache — para os testes.
  @visibleForTesting
  static void limparCache() => _AssetFirstFrameState._cache.clear();

  @override
  State<AssetFirstFrame> createState() => _AssetFirstFrameState();
}

class _AssetFirstFrameState extends State<AssetFirstFrame> {
  static final Map<String, Future<ui.Image?>> _cache =
      <String, Future<ui.Image?>>{};

  late Future<ui.Image?> _quadro;

  @override
  void initState() {
    super.initState();
    _quadro = _carregar(widget.asset, widget.largura);
  }

  @override
  void didUpdateWidget(covariant AssetFirstFrame antigo) {
    super.didUpdateWidget(antigo);
    if (antigo.asset != widget.asset || antigo.largura != widget.largura) {
      _quadro = _carregar(widget.asset, widget.largura);
    }
  }

  static Future<ui.Image?> _carregar(String asset, int largura) {
    return _cache.putIfAbsent('$asset@$largura', () async {
      try {
        final ByteData bytes = await rootBundle.load(asset);
        final ui.Codec codec = await ui.instantiateImageCodec(
          bytes.buffer.asUint8List(),
          targetWidth: largura,
        );
        final ui.FrameInfo quadro = await codec.getNextFrame();
        codec.dispose();
        return quadro.image;
      } on Object {
        return null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ui.Image?>(
      future: _quadro,
      builder: (BuildContext context, AsyncSnapshot<ui.Image?> resultado) {
        final ui.Image? imagem = resultado.data;
        if (imagem == null) {
          return widget.fallback ?? const SizedBox.shrink();
        }
        return RawImage(
          image: imagem,
          fit: widget.fit,
          filterQuality: FilterQuality.medium,
        );
      },
    );
  }
}
