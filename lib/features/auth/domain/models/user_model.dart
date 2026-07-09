import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'user_role.dart';

part 'user_model.g.dart';

/// Represents an authenticated LibreFlow user.
///
/// This is a plain domain model, deliberately free of any persistence or
/// networking concerns (Clean Architecture: Domain layer). Serialization
/// lives in the Data layer once a real backend is wired in.
@HiveType(typeId: 1)
class UserModel extends Equatable {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.photoUrl,
    this.membershipNumber,
    this.department,
    this.isApproved = true,
    this.createdAt,
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
  final String? photoUrl;
  @HiveField(5)
  final String? membershipNumber;
  @HiveField(6)
  final String? department;
  @HiveField(7)
  final bool isApproved;
  @HiveField(8)
  final DateTime? createdAt;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? role,
    String? photoUrl,
    String? membershipNumber,
    String? department,
    bool? isApproved,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      photoUrl: photoUrl ?? this.photoUrl,
      membershipNumber: membershipNumber ?? this.membershipNumber,
      department: department ?? this.department,
      isApproved: isApproved ?? this.isApproved,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role.name,
        'photoUrl': photoUrl,
        'membershipNumber': membershipNumber,
        'department': department,
        'isApproved': isApproved,
        'createdAt': createdAt?.toIso8601String(),
      };

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: UserRole.values.firstWhere((r) => r.name == json['role']),
      photoUrl: json['photoUrl'] as String?,
      membershipNumber: json['membershipNumber'] as String?,
      department: json['department'] as String?,
      isApproved: json['isApproved'] as bool? ?? true,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
    );
  }

  @override
  List<Object?> get props => [id, name, email, role, photoUrl, isApproved, createdAt];
}
