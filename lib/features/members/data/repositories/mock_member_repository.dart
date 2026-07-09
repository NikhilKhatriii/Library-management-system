import '../../../../core/utils/result.dart';
import '../models/member_model.dart';
import '../models/member_repository.dart'; // I will fix this name bug below

class MockMemberRepository implements MemberRepository {
  final List<MemberModel> _members = _generateMockMembers();

  @override
  Future<Result<List<MemberModel>>> getMembers({
    String? query,
    MemberType? type,
    MemberStatus? status,
    int page = 1,
    int pageSize = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));
    var filtered = _members;
    
    if (query != null && query.isNotEmpty) {
      filtered = filtered.where((m) => 
        m.name.toLowerCase().contains(query.toLowerCase()) || 
        m.membershipNumber.contains(query)
      ).toList();
    }
    
    if (type != null) {
      filtered = filtered.where((m) => m.type == type).toList();
    }
    
    if (status != null) {
      filtered = filtered.where((m) => m.status == status).toList();
    }

    final start = (page - 1) * pageSize;
    if (start >= filtered.length) return const Success([]);
    
    final end = (start + pageSize) > filtered.length ? filtered.length : (start + pageSize);
    return Success(filtered.sublist(start, end));
  }

  @override
  Future<Result<MemberModel>> getMemberById(String id) async {
    try {
      final member = _members.firstWhere((m) => m.id == id);
      return Success(member);
    } catch (e) {
      return const Failure('Member not found');
    }
  }

  @override
  Future<Result<void>> addMember(MemberModel member) async {
    _members.insert(0, member);
    return const Success(null);
  }

  @override
  Future<Result<void>> updateMember(MemberModel member) async {
    final idx = _members.indexWhere((m) => m.id == member.id);
    if (idx != -1) {
      _members[idx] = member;
      return const Success(null);
    }
    return const Failure('Member not found');
  }

  @override
  Future<Result<void>> deleteMember(String id) async {
    _members.removeWhere((m) => m.id == id);
    return const Success(null);
  }

  @override
  Future<Result<void>> suspendMember(String id) async {
    final idx = _members.indexWhere((m) => m.id == id);
    if (idx != -1) {
      _members[idx] = _members[idx].copyWith(status: MemberStatus.suspended);
      return const Success(null);
    }
    return const Failure('Member not found');
  }

  @override
  Future<Result<void>> activateMember(String id) async {
    final idx = _members.indexWhere((m) => m.id == id);
    if (idx != -1) {
      _members[idx] = _members[idx].copyWith(status: MemberStatus.active);
      return const Success(null);
    }
    return const Failure('Member not found');
  }

  static List<MemberModel> _generateMockMembers() {
    return [
      MemberModel(
        id: 'm1',
        name: 'John Doe',
        email: 'john.doe@university.edu',
        membershipNumber: 'LIB-2024-001',
        type: MemberType.student,
        joinedDate: DateTime(2023, 9, 1),
        department: 'Computer Science',
        totalBorrowed: 15,
        photoUrl: 'https://i.pravatar.cc/150?u=m1',
      ),
      MemberModel(
        id: 'm2',
        name: 'Prof. Sarah Smith',
        email: 's.smith@university.edu',
        membershipNumber: 'LIB-FAC-102',
        type: MemberType.teacher,
        joinedDate: DateTime(2022, 1, 15),
        department: 'Mathematics',
        totalBorrowed: 42,
        photoUrl: 'https://i.pravatar.cc/150?u=m2',
      ),
      // ... generate 20 more
      for (int i = 3; i <= 25; i++)
        MemberModel(
          id: 'm$i',
          name: 'Member $i',
          email: 'member$i@example.com',
          membershipNumber: 'LIB-2024-0$i',
          type: MemberType.values[i % 5],
          joinedDate: DateTime(2024, 1, i),
          status: i % 10 == 0 ? MemberStatus.suspended : MemberStatus.active,
          totalBorrowed: i * 2,
          photoUrl: 'https://i.pravatar.cc/150?u=m$i',
        ),
    ];
  }
}
