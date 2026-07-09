import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'member_model.g.dart';

@HiveType(typeId: 8)
enum MemberStatus {
  @HiveField(0)
  active,
  @HiveField(1)
  suspended,
  @HiveField(2)
  expired,
  @HiveField(3)
  pendingApproval,
}

@HiveType(typeId: 9)
enum MemberType {
  @HiveField(0)
  student,
  @HiveField(1)
  teacher,
  @HiveField(2)
  staff,
  @HiveField(3)
  alumni,
  @HiveField(4)
  guest,
}

@HiveType(typeId: 10)
class MemberModel extends Equatable {
  const MemberModel({
    required this.id,
    required this.name,
    required this.email,
    required this.membershipNumber,
    required this.type,
    this.status = MemberStatus.active,
    this.photoUrl,
    this.phoneNumber,
    this.department,
    this.address,
    required this.joinedDate,
    this.expiryDate,
    this.totalBorrowed = 0,
    this.currentBorrowed = 0,
    this.outstandingFines = 0.0,
  });

  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String email;
  @HiveField(3)
  final String membershipNumber;
  @HiveField(4)
  final MemberType type;
  @HiveField(5)
  final MemberStatus status;
  @HiveField(6)
  final String? photoUrl;
  @HiveField(7)
  final String? phoneNumber;
  @HiveField(8)
  final String? department;
  @HiveField(9)
  final String? address;
  @HiveField(10)
  final DateTime joinedDate;
  @HiveField(11)
  final DateTime? expiryDate;
  @HiveField(12)
  final int totalBorrowed;
  @HiveField(13)
  final int currentBorrowed;
  @HiveField(14)
  final double outstandingFines;

  MemberModel copyWith({
    String? id,
    String? name,
    String? email,
    String? membershipNumber,
    MemberType? type,
    MemberStatus? status,
    String? photoUrl,
    String? phoneNumber,
    String? department,
    String? address,
    DateTime? joinedDate,
    DateTime? expiryDate,
    int? totalBorrowed,
    int? currentBorrowed,
    double? outstandingFines,
  }) {
    return MemberModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      membershipNumber: membershipNumber ?? this.membershipNumber,
      type: type ?? this.type,
      status: status ?? this.status,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      department: department ?? this.department,
      address: address ?? this.address,
      joinedDate: joinedDate ?? this.joinedDate,
      expiryDate: expiryDate ?? this.expiryDate,
      totalBorrowed: totalBorrowed ?? this.totalBorrowed,
      currentBorrowed: currentBorrowed ?? this.currentBorrowed,
      outstandingFines: outstandingFines ?? this.outstandingFines,
    );
  }

  @override
  List<Object?> get props => [id, name, email, membershipNumber, type, status, totalBorrowed, outstandingFines];
}
