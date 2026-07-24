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
      child: Row(
        children: UserRole.values.map((role) {
          final isSelected = role == selected;
          final isLast = role == UserRole.values.last;
          
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: isLast ? 0 : AppSpacing.sm),
              child: GestureDetector(
                onTap: () => onChanged(role),
                child: AnimatedContainer(
                  duration: AppDurations.fast,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm, horizontal: 2),
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
                      Expanded(
                        child: Text(
                          role.label,
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: isSelected ? role.color : null,
                                fontSize: 11,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
