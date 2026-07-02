import 'package:equatable/equatable.dart';
import 'user_role.dart';

/// Represents an authenticated LibreFlow user.
///
/// This is a plain domain model, deliberately free of any persistence or
/// networking concerns (Clean Architecture: Domain layer). Serialization
/// lives in the Data layer once a real backend is wired in.
class UserModel extends Equatable {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.photoUrl,
    this.membershipNumber,
    this.department,
  });

  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? photoUrl;
  final String? membershipNumber;
  final String? department;

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
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      photoUrl: photoUrl ?? this.photoUrl,
      membershipNumber: membershipNumber ?? this.membershipNumber,
      department: department ?? this.department,
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
    );
  }

  @override
  List<Object?> get props => [id, name, email, role, photoUrl];
}
