import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// The four roles supported by LibreFlow. Each role maps to its own
/// dashboard, navigation shell, and permission set.
enum UserRole {
  admin,
  librarian,
  student,
  teacher;

  String get label => switch (this) {
        UserRole.admin => 'Admin',
        UserRole.librarian => 'Librarian',
        UserRole.student => 'Student',
        UserRole.teacher => 'Teacher',
      };

  String get description => switch (this) {
        UserRole.admin => 'Full system access & configuration',
        UserRole.librarian => 'Manage catalog, issues & members',
        UserRole.student => 'Browse, borrow & track your books',
        UserRole.teacher => 'Browse, reserve & manage class sets',
      };

  IconData get icon => switch (this) {
        UserRole.admin => Icons.admin_panel_settings_rounded,
        UserRole.librarian => Icons.local_library_rounded,
        UserRole.student => Icons.school_rounded,
        UserRole.teacher => Icons.co_present_rounded,
      };

  Color get color => switch (this) {
        UserRole.admin => AppColors.secondary,
        UserRole.librarian => AppColors.primary,
        UserRole.student => AppColors.accent,
        UserRole.teacher => const Color(0xFFF59E0B),
      };
}
