import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/tokens/color_tokens.dart';
import '../../core/theme/tokens/spacing_tokens.dart';
import '../../core/theme/tokens/typography_tokens.dart';

/// Campo de texto padrao: label opcional acima, superficie `bgSurfaceAlt`, sem
/// borda em repouso e borda verde no foco.
///
/// Com [maxLength], o texto e limitado e o contador (`12/200`) aparece dentro
/// do campo, no canto de baixo.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.label,
    this.controller,
    this.hint,
    this.isPassword = false,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.suffixIcon,
    this.prefixIcon,
    this.readOnly = false,
    this.onTap,
    this.inputFormatters,
    this.maxLines = 1,
    this.maxLength,
    this.errorText,
    this.autofocus = false,
    this.textCapitalization = TextCapitalization.none,
  });

  /// Rotulo acima do campo; sem ele, o campo fica so com o [hint].
  final String? label;
  final TextEditingController? controller;
  final String? hint;
  final bool isPassword;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final Widget? suffixIcon;
  final IconData? prefixIcon;
  final bool readOnly;
  final VoidCallback? onTap;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;

  /// Limite de caracteres; mostra o contador dentro do campo.
  final int? maxLength;
  final String? errorText;
  final bool autofocus;
  final TextCapitalization textCapitalization;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscure = true;
  int _tamanho = 0;

  @override
  void initState() {
    super.initState();
    _tamanho = widget.controller?.text.length ?? 0;
    widget.controller?.addListener(_sincronizarTamanho);
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_sincronizarTamanho);
    super.dispose();
  }

  /// O texto pode mudar por fora (o formulario preenche o campo): o contador
  /// acompanha o controller, e nao so o que o usuario digita.
  void _sincronizarTamanho() {
    final int atual = widget.controller?.text.length ?? 0;
    if (atual != _tamanho) {
      setState(() => _tamanho = atual);
    }
  }

  void _alterou(String valor) {
    if (widget.controller == null && widget.maxLength != null) {
      setState(() => _tamanho = valor.length);
    }
    widget.onChanged?.call(valor);
  }

  @override
  Widget build(BuildContext context) {
    final int? limite = widget.maxLength;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (widget.label != null) ...<Widget>[
          Text(widget.label!, style: TypographyTokens.fieldLabel),
          const SizedBox(height: SpacingTokens.sm),
        ],
        Stack(
          children: <Widget>[
            TextFormField(
              controller: widget.controller,
              obscureText: widget.isPassword && _obscure,
              keyboardType: widget.keyboardType,
              validator: widget.validator,
              onChanged: _alterou,
              onFieldSubmitted: widget.onSubmitted,
              readOnly: widget.readOnly,
              onTap: widget.onTap,
              autofocus: widget.autofocus,
              inputFormatters: <TextInputFormatter>[
                ...?widget.inputFormatters,
                if (limite != null) LengthLimitingTextInputFormatter(limite),
              ],
              maxLines: widget.isPassword ? 1 : widget.maxLines,
              textCapitalization: widget.textCapitalization,
              style: TypographyTokens.body,
              cursorColor: ColorTokens.accent,
              decoration: InputDecoration(
                hintText: widget.hint,
                errorText: widget.errorText,
                contentPadding: limite == null
                    ? null
                    : const EdgeInsets.fromLTRB(
                        SpacingTokens.md,
                        SpacingTokens.md,
                        SpacingTokens.md,
                        SpacingTokens.xl,
                      ),
                prefixIcon: widget.prefixIcon == null
                    ? null
                    : Icon(
                        widget.prefixIcon,
                        size: 20,
                        color: ColorTokens.textSecondary,
                      ),
                suffixIcon: widget.isPassword
                    ? IconButton(
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          size: 20,
                          color: ColorTokens.textSecondary,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      )
                    : widget.suffixIcon,
              ),
            ),
            if (limite != null)
              Positioned(
                right: SpacingTokens.md,
                bottom: SpacingTokens.sm,
                child: IgnorePointer(
                  child: Text(
                    '$_tamanho/$limite',
                    style: TypographyTokens.caption,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
