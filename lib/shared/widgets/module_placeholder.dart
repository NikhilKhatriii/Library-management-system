import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import 'empty_state.dart';

/// Marks a feature module that is scaffolded in navigation but not yet
/// implemented in this build phase (see project README → Roadmap).
///
/// This is a deliberate, visible placeholder — not a silent stub — so it's
/// obvious in the running app which modules are next on the roadmap
/// (Book Management, Issue/Return, Members, Fines, Reports, Admin Panel...).
class ModulePlaceholder extends StatelessWidget {
  const ModulePlaceholder({
    super.key,
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: EmptyState(
          icon: Icons.construction_rounded,
          title: 'Coming in the next build',
          message: description,
        ),
      ),
    );
  }
}
