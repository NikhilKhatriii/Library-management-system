import '../../features/auth/domain/models/user_role.dart';

/// Granular permissions for the Library Management System.
enum AppPermission {
  // User Management
  manageStudents,
  manageTeachers,
  manageLibrarians,
  manageStaff,
  resetUserPasswords,
  assignRoles,
  viewActivityLogs,

  // Library Management
  manageCampuses,
  manageDepartments,
  manageShelves,
  
  // Book Management
  addBooks,
  editBooks,
  deleteBooks,
  bulkImportBooks,
  generateIdentifiers,
  manageDigitalResources,

  // Borrowing
  issueBooks,
  returnBooks,
  renewBooks,
  approveReservations,
  overrideDueDate,

  // Fines
  waiveFines,
  manageFineRules,
  processRefunds,

  // Inventory
  performStockAudit,
  markBooksLost,
  
  // Reports
  viewFinancialReports,
  exportData,
  viewAiInsights,

  // System
  modifySystemSettings,
  manageGateways,
  backupDatabase,
}

abstract final class PermissionService {
  static bool hasPermission(UserRole role, AppPermission permission) {
    return switch (role) {
      UserRole.librarian => true, // Librarian now has full control
      UserRole.teacher => _teacherPermissions.contains(permission),
      UserRole.student => _studentPermissions.contains(permission),
    };
  }

  static const _teacherPermissions = {
    AppPermission.renewBooks,
    AppPermission.manageDigitalResources,
  };

  static const _studentPermissions = {
    AppPermission.manageDigitalResources,
  };
}
