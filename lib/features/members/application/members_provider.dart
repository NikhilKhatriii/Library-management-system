import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:library_managementsystem/core/utils/result.dart';
import 'package:library_managementsystem/features/members/domain/models/member_model.dart';
import 'package:library_managementsystem/features/members/domain/repositories/member_repository.dart';
import 'package:library_managementsystem/features/members/data/repositories/mock_member_repository.dart';

part 'members_provider.g.dart';

@Riverpod(keepAlive: true)
MemberRepository memberRepository(MemberRepositoryRef ref) {
  return MockMemberRepository();
}

class MembersState {
  final List<MemberModel> members;
  final bool isLoading;
  final String? errorMessage;
  final bool hasMore;

  const MembersState({
    this.members = const [],
    this.isLoading = false,
    this.errorMessage,
    this.hasMore = true,
  });

  MembersState copyWith({
    List<MemberModel>? members,
    bool? isLoading,
    String? errorMessage,
    bool? hasMore,
  }) {
    return MembersState(
      members: members ?? this.members,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

@riverpod
class MembersNotifier extends _$MembersNotifier {
  @override
  MembersState build() {
    return const MembersState();
  }

  Future<void> fetchMembers({bool refresh = false}) async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await ref.read(memberRepositoryProvider).getMembers();
    if (result is Success<List<MemberModel>>) {
      state = state.copyWith(
        members: result.data,
        isLoading: false,
        hasMore: result.data.length >= 20,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: (result as Failure).message,
      );
    }
  }

  Future<void> searchMembers(String query) async {
    state = state.copyWith(isLoading: true, members: []);
    final result = await ref.read(memberRepositoryProvider).getMembers(query: query);
    if (result is Success<List<MemberModel>>) {
      state = state.copyWith(members: result.data, isLoading: false);
    }
  }
}
