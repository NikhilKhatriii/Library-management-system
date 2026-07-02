import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Animates a number counting up from 0 to [value] whenever it changes.
class AnimatedCounter extends StatelessWidget {
  const AnimatedCounter({
    super.key,
    required this.value,
    this.style,
    this.isCurrency = false,
    this.duration = const Duration(milliseconds: 900),
  });

  final num value;
  final TextStyle? style;
  final bool isCurrency;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final formatter =
        isCurrency ? NumberFormat.simpleCurrency(decimalDigits: 0) : NumberFormat.decimalPattern();

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.toDouble()),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, _) {
        return Text(formatter.format(animatedValue), style: style);
      },
    );
  }
}
