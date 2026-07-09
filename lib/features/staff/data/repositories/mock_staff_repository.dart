import '../../../../core/utils/result.dart';
import '../../../auth/domain/models/user_role.dart';
import '../domain/models/staff_model.dart';

abstract interface class StaffRepository {
  Future<Result<List<StaffModel>>> getStaff();
}

class MockStaffRepository implements StaffRepository {
  @override
  Future<Result<List<StaffModel>>> getStaff() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return Success([
      StaffModel(
        id: 's1',
        name: 'Alice Johnson',
        email: 'alice.j@library.edu',
        role: UserRole.librarian,
        department: 'Main Branch',
        lastLogin: DateTime.now().subtract(const Duration(hours: 2)),
        isOnline: true,
      ),
      StaffModel(
        id: 's2',
        name: 'Bob Miller',
        email: 'bob.m@library.edu',
        role: UserRole.admin,
        department: 'IT Infrastructure',
        lastLogin: DateTime.now().subtract(const Duration(days: 1)),
        isOnline: false,
      ),
    ]);
  }
}
