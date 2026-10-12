import 'package:flutter/material.dart';

import '../../core/theme/tokens/color_tokens.dart';
import '../../core/theme/tokens/spacing_tokens.dart';
import '../../core/theme/tokens/typography_tokens.dart';

/// Campo de selecao (dropdown) com o mesmo visual do [AppTextField]: label
/// acima, superficie `bgSurfaceAlt`, raio 12, altura 52.
class AppDropdownField<T> extends StatelessWidget {
  const AppDropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    super.key,
    this.hint,
  });

  final String label;
  final T value;
  final List<T> items;
  final String Function(T) itemLabel;
  final void Function(T?) onChanged;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: TypographyTokens.fieldLabel),
        const SizedBox(height: SpacingTokens.sm),
        Container(
          height: SpacingTokens.inputHeight,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.md),
          decoration: BoxDecoration(
            color: ColorTokens.bgSurfaceAlt,
            borderRadius: BorderRadius.circular(SpacingTokens.radiusButton),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButtonFormField<T>(
              value: value,
              isExpanded: true,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: ColorTokens.textSecondary,
              ),
              dropdownColor: ColorTokens.bgSurface,
              borderRadius: BorderRadius.circular(SpacingTokens.radiusButton),
              style: TypographyTokens.body,
              hint: hint == null
                  ? null
                  : Text(
                      hint!,
                      style: TypographyTokens.body.copyWith(
                        color: ColorTokens.textSecondary,
                      ),
                    ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              items: items
                  .map(
                    (T item) => DropdownMenuItem<T>(
                      value: item,
                      child: Text(
                        itemLabel(item),
                        overflow: TextOverflow.ellipsis,
                        style: TypographyTokens.body,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
