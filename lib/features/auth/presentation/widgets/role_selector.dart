import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/models/user_role.dart';

/// A horizontally-scrolling set of role chips used to pick the account type
/// during login/registration.
class RoleSelector extends StatelessWidget {
  const RoleSelector({super.key, required this.selected, required this.onChanged});

  final UserRole selected;
  final ValueChanged<UserRole> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: UserRole.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final role = UserRole.values[index];
          final isSelected = role == selected;
          return GestureDetector(
            onTap: () => onChanged(role),
            child: AnimatedContainer(
              duration: AppDurations.fast,
              width: 92,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: isSelected
                    ? role.color.withValues(alpha: 0.12)
                    : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: isSelected ? role.color : Theme.of(context).dividerColor,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(role.icon, color: role.color, size: 22),
                  const SizedBox(height: 6),
                  Text(
                    role.label,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: isSelected ? role.color : null,
                          fontSize: 12,
                        ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
