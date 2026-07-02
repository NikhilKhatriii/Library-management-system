import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

/// A frosted-glass surface: subtle blur + translucent fill + soft border.
/// Used for hero panels, auth cards, and floating overlays where a card
/// should feel elevated without a hard shadow.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.borderRadius = AppRadius.lg,
    this.blurSigma = 20,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double blurSigma;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fill = isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white.withValues(alpha: 0.55);
    final border = isDark ? Colors.white.withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.7);

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: border, width: 1),
          ),
          child: child,
        ),
      ),
    );
  }
}
