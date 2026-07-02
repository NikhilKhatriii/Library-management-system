import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../auth/application/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final themeMode = ref.watch(themeModeProvider);
    final theme = Theme.of(context);

    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: user.role.color.withValues(alpha: 0.15),
                  child: Text(
                    user.initials,
                    style: theme.textTheme.headlineSmall?.copyWith(color: user.role.color),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(user.name, style: theme.textTheme.titleLarge),
                const SizedBox(height: 2),
                Text(user.email, style: theme.textTheme.bodyMedium),
                const SizedBox(height: AppSpacing.sm),
                Chip(
                  avatar: Icon(user.role.icon, size: 16, color: user.role.color),
                  label: Text(user.role.label),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _SectionCard(
            title: 'Appearance',
            children: [
              _SettingsTile(
                icon: Icons.brightness_6_rounded,
                title: 'Theme',
                trailing: SegmentedButton<ThemeMode>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.light_mode_rounded, size: 16)),
                    ButtonSegment(value: ThemeMode.system, icon: Icon(Icons.brightness_auto_rounded, size: 16)),
                    ButtonSegment(value: ThemeMode.dark, icon: Icon(Icons.dark_mode_rounded, size: 16)),
                  ],
                  selected: {themeMode},
                  onSelectionChanged: (s) =>
                      ref.read(themeModeProvider.notifier).setThemeMode(s.first),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const _SectionCard(
            title: 'Account',
            children: [
              _SettingsTile(icon: Icons.edit_outlined, title: 'Edit profile'),
              _SettingsTile(icon: Icons.lock_outline_rounded, title: 'Change password'),
              _SettingsTile(icon: Icons.notifications_none_rounded, title: 'Notifications'),
              _SettingsTile(icon: Icons.privacy_tip_outlined, title: 'Privacy'),
              _SettingsTile(icon: Icons.history_rounded, title: 'Activity log'),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          OutlinedButton.icon(
            onPressed: () => ref.read(authProvider.notifier).logout(),
            icon: const Icon(Icons.logout_rounded, color: AppColors.error),
            label: const Text('Log out', style: TextStyle(color: AppColors.error)),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              side: const BorderSide(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: AppSpacing.sm),
          child: Text(title, style: Theme.of(context).textTheme.labelLarge),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Column(children: children),
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({required this.icon, required this.title, this.trailing});
  final IconData icon;
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: 20),
      title: Text(title),
      trailing: trailing ?? const Icon(Icons.chevron_right_rounded, size: 18),
    );
  }
}
