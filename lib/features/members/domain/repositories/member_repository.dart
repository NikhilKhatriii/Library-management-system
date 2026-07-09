import '../../../../core/utils/result.dart';
import '../models/member_model.dart';

abstract interface class MemberRepository {
  Future<Result<List<MemberModel>>> getMembers({
    String? query,
    MemberType? type,
    MemberStatus? status,
    int page = 1,
    int pageSize = 20,
  });

  Future<Result<MemberModel>> getMemberById(String id);
  Future<Result<void>> addMember(MemberModel member);
  Future<Result<void>> updateMember(MemberModel member);
  Future<Result<void>> deleteMember(String id);
  Future<Result<void>> suspendMember(String id);
  Future<Result<void>> activateMember(String id);
}
