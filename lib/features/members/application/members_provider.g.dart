// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'members_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$memberRepositoryHash() => r'1a8f3009c956f2ab3704bc478fd8467eea593932';

/// See also [memberRepository].
@ProviderFor(memberRepository)
final memberRepositoryProvider = Provider<MemberRepository>.internal(
  memberRepository,
  name: r'memberRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$memberRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef MemberRepositoryRef = ProviderRef<MemberRepository>;
String _$membersNotifierHash() => r'c9b1e993d75c3560a2e0665b1441c2360c570859';

/// See also [MembersNotifier].
@ProviderFor(MembersNotifier)
final membersNotifierProvider =
    AutoDisposeNotifierProvider<MembersNotifier, MembersState>.internal(
  MembersNotifier.new,
  name: r'membersNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$membersNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$MembersNotifier = AutoDisposeNotifier<MembersState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
