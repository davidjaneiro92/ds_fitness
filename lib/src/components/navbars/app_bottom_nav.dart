import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/tokens/color_tokens.dart';
import '../../core/theme/tokens/spacing_tokens.dart';
import '../../enum/app_tab.dart';

/// Barra inferior com 4 abas: Home · Treinos · Exercícios · Perfil.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({required this.current, super.key});

  final AppTab current;

  static const Map<AppTab, IconData> _icons = <AppTab, IconData>{
    AppTab.home: Icons.home_rounded,
    AppTab.treinos: Icons.fitness_center_rounded,
    AppTab.exercicios: Icons.grid_view_rounded,
    AppTab.perfil: Icons.person_rounded,
  };

  void _onTap(AppTab tab) {
    if (tab == current) {
      return;
    }
    Get.offAllNamed<void>(tab.route.path);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: ColorTokens.bgSurface,
        border: Border(
          top: BorderSide(color: ColorTokens.divider),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: SpacingTokens.bottomNavHeight,
          child: Row(
            children: AppTab.values.map((AppTab tab) {
              final bool active = tab == current;
              return Expanded(
                child: InkWell(
                  onTap: () => _onTap(tab),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        _icons[tab],
                        size: 24,
                        color: active
                            ? ColorTokens.accent
                            : ColorTokens.textSecondary,
                      ),
                      const SizedBox(height: SpacingTokens.xs),
                      Text(
                        tab.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight:
                              active ? FontWeight.w700 : FontWeight.w500,
                          color: active
                              ? ColorTokens.accent
                              : ColorTokens.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
