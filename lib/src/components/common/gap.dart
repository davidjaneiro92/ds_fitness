import 'package:flutter/widgets.dart';

/// Espacador vertical (padrao) ou horizontal, sempre em multiplos do grid 8.
class Gap extends StatelessWidget {
  const Gap(this.size, {super.key}) : _horizontal = false;

  const Gap.horizontal(this.size, {super.key}) : _horizontal = true;

  final double size;
  final bool _horizontal;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _horizontal ? null : size,
      width: _horizontal ? size : null,
    );
  }
}
