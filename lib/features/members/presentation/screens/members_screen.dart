import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:library_managementsystem/core/constants/app_constants.dart';
import 'package:library_managementsystem/core/constants/app_colors.dart';
import 'package:library_managementsystem/shared/widgets/empty_state.dart';
import 'package:library_managementsystem/shared/widgets/skeleton_loader.dart';
import 'package:library_managementsystem/features/members/domain/models/member_model.dart';
import 'package:library_managementsystem/features/members/application/members_provider.dart';

class MembersScreen extends ConsumerStatefulWidget {
  const MembersScreen({super.key});

  @override
  ConsumerState<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends ConsumerState<MembersScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(membersNotifierProvider.notifier).fetchMembers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(membersNotifierProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Member Directory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_rounded),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.file_download_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => ref.read(membersNotifierProvider.notifier).searchMembers(v),
              decoration: InputDecoration(
                hintText: 'Search by name or ID...',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: theme.cardColor,
              ),
            ),
          ),
          Expanded(
            child: state.isLoading && state.members.isEmpty
                ? _buildLoadingList()
                : state.members.isEmpty
                    ? const EmptyState(
                        icon: Icons.people_outline_rounded,
                        title: 'No members found',
                        message: 'Check your search query or add a new member.',
                      )
                    : _buildMemberList(state.members),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingList() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: 8,
      itemBuilder: (context, index) => const Padding(
        padding: EdgeInsets.only(bottom: AppSpacing.md),
        child: SkeletonBox(height: 80, borderRadius: AppRadius.md),
      ),
    );
  }

  Widget _buildMemberList(List<MemberModel> members) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: members.length,
      itemBuilder: (context, index) {
        final member = members[index];
        return _MemberCard(member: member, index: index);
      },
    );
  }
}

class _MemberCard extends StatelessWidget {
  final MemberModel member;
  final int index;
  const _MemberCard({required this.member, required this.index});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getMemberTypeColor(member.type);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 8),
        leading: Hero(
          tag: 'member-${member.id}',
          child: CircleAvatar(
            radius: 24,
            backgroundImage: member.photoUrl != null ? NetworkImage(member.photoUrl!) : null,
            child: member.photoUrl == null ? Text(member.name[0]) : null,
          ),
        ),
        title: Row(
          children: [
            Text(member.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            _StatusBadge(status: member.status),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(member.membershipNumber, style: theme.textTheme.bodySmall),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    member.type.name.toUpperCase(),
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.import_contacts_rounded, size: 14),
                const SizedBox(width: 4),
                Text('${member.totalBorrowed} borrowed', style: theme.textTheme.bodySmall),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () {},
      ),
    ).animate(delay: (50 * index).ms).fadeIn().slideX(begin: 0.1, end: 0);
  }

  Color _getMemberTypeColor(MemberType type) {
    return switch (type) {
      MemberType.student => AppColors.royalBlue,
      MemberType.teacher => Colors.purple,
      MemberType.staff => Colors.orange,
      MemberType.alumni => Colors.teal,
      MemberType.guest => Colors.grey,
    };
  }
}

class _StatusBadge extends StatelessWidget {
  final MemberStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      MemberStatus.active => AppColors.accent,
      MemberStatus.suspended => AppColors.error,
      MemberStatus.expired => Colors.grey,
      MemberStatus.pendingApproval => AppColors.warning,
    };

    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
