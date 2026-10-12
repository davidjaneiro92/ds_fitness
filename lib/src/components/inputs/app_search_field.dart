import 'package:flutter/material.dart';

import '../../core/theme/tokens/color_tokens.dart';
import '../../core/theme/tokens/spacing_tokens.dart';
import '../../core/theme/tokens/typography_tokens.dart';

/// Campo de busca em formato pill: lupa a esquerda, botao limpar quando
/// ha texto digitado.
class AppSearchField extends StatefulWidget {
  const AppSearchField({
    required this.onChanged,
    super.key,
    this.hint = 'Pesquisar exercício',
    this.controller,
  });

  final void Function(String) onChanged;
  final String hint;
  final TextEditingController? controller;

  @override
  State<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> {
  late final TextEditingController _controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onTextChanged() => setState(() {});

  void _clear() {
    _controller.clear();
    widget.onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: SpacingTokens.inputHeight,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: ColorTokens.bgSurfaceAlt,
        borderRadius: BorderRadius.circular(SpacingTokens.radiusButton),
      ),
      child: TextField(
        controller: _controller,
        onChanged: widget.onChanged,
        style: TypographyTokens.body,
        cursorColor: ColorTokens.accent,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: TypographyTokens.body.copyWith(
            color: ColorTokens.textSecondary,
          ),
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            vertical: SpacingTokens.md,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            size: 20,
            color: ColorTokens.textSecondary,
          ),
          suffixIcon: _controller.text.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: ColorTokens.textSecondary,
                  ),
                  onPressed: _clear,
                ),
        ),
      ),
    );
  }
}
