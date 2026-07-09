import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import '../../../auth/domain/models/user_role.dart';

part 'staff_model.g.dart';

@HiveType(typeId: 11)
class StaffModel extends Equatable {
  const StaffModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.department,
    this.photoUrl,
    required this.lastLogin,
    this.isOnline = false,
  });

  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String email;
  @HiveField(3)
  final UserRole role;
  @HiveField(4)
  final String? department;
  @HiveField(5)
  final String? photoUrl;
  @HiveField(6)
  final DateTime lastLogin;
  @HiveField(7)
  final bool isOnline;

  @override
  List<Object?> get props => [id, name, email, role, department, isOnline];
}
