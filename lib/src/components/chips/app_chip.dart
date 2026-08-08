import 'package:flutter/material.dart';

import '../../core/theme/tokens/color_tokens.dart';
import '../../core/theme/tokens/spacing_tokens.dart';

/// Chip / pill selecionavel (filtros, informacoes de estado).
class AppChip extends StatelessWidget {
  const AppChip({
    required this.label,
    super.key,
    this.selected = false,
    this.onTap,
    this.icon,
    this.color,
    this.dense = false,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final IconData? icon;

  /// Cor do texto/icone quando nao selecionado (default: textSecondary).
  final Color? color;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final Color foreground = selected
        ? ColorTokens.textOnAccent
        : (color ?? ColorTokens.textSecondary);

    return Material(
      color: selected ? ColorTokens.accent : ColorTokens.bgSurfaceAlt,
      borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: dense ? SpacingTokens.sm + 4 : SpacingTokens.md,
            vertical: dense ? SpacingTokens.xs + 2 : SpacingTokens.sm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (icon != null) ...<Widget>[
                Icon(icon, size: 14, color: foreground),
                const SizedBox(width: SpacingTokens.xs + 2),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: dense ? 11 : 12,
                  fontWeight: FontWeight.w600,
                  color: foreground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Linha horizontal de chips de filtro (Todos · Treinos · Exercícios).
class AppChipBar extends StatelessWidget {
  const AppChipBar({
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
    super.key,
  });

  final List<String> labels;
  final int selectedIndex;
  final void Function(int index) onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List<Widget>.generate(labels.length, (int i) {
          return Padding(
            padding: EdgeInsets.only(
              right: i == labels.length - 1 ? 0 : SpacingTokens.sm,
            ),
            child: AppChip(
              label: labels[i],
              selected: i == selectedIndex,
              onTap: () => onSelected(i),
            ),
          );
        }),
      ),
    );
  }
}
