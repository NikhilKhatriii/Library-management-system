import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/application/auth_provider.dart';
import '../../features/auth/domain/models/user_role.dart';
import '../../core/utils/responsive_utils.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';

class AppScaffold extends ConsumerWidget {
  const AppScaffold({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final width = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);
    final isAdminOrLibrarian = user?.role == UserRole.admin || user?.role == UserRole.librarian;

    if (width >= ResponsiveBreakpoints.desktop) {
      final isWide = width >= ResponsiveBreakpoints.wide;
      return Scaffold(
        body: Row(
          children: [
            _DesktopSidebar(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: (index) => navigationShell.goBranch(
                index,
                initialLocation: index == navigationShell.currentIndex,
              ),
              isAdminOrLibrarian: isAdminOrLibrarian,
              isWide: isWide,
              userEmail: user?.email ?? '',
              userName: user?.name ?? '',
              initials: user?.initials ?? '?',
            ),
            VerticalDivider(width: 1, thickness: 1, color: theme.dividerColor),
            Expanded(child: navigationShell),
          ],
        ),
      );
    }

    if (width >= ResponsiveBreakpoints.mobile) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: (index) => navigationShell.goBranch(
                index,
                initialLocation: index == navigationShell.currentIndex,
              ),
              labelType: NavigationRailLabelType.selected,
              destinations: [
                const NavigationRailDestination(
                  icon: Icon(Icons.grid_view_outlined),
                  selectedIcon: Icon(Icons.grid_view_rounded),
                  label: Text('Dashboard'),
                ),
                const NavigationRailDestination(
                  icon: Icon(Icons.auto_stories_outlined),
                  selectedIcon: Icon(Icons.auto_stories_rounded),
                  label: Text('Catalog'),
                ),
                const NavigationRailDestination(
                  icon: Icon(Icons.swap_horiz_rounded),
                  selectedIcon: Icon(Icons.swap_horizontal_circle_rounded),
                  label: Text('Activity'),
                ),
                const NavigationRailDestination(
                  icon: Icon(Icons.person_outline_rounded),
                  selectedIcon: Icon(Icons.person_rounded),
                  label: Text('Profile'),
                ),
                if (isAdminOrLibrarian) ...[
                  const NavigationRailDestination(
                    icon: Icon(Icons.people_outline_rounded),
                    selectedIcon: Icon(Icons.people_rounded),
                    label: Text('Members'),
                  ),
                  const NavigationRailDestination(
                    icon: Icon(Icons.analytics_outlined),
                    selectedIcon: Icon(Icons.analytics_rounded),
                    label: Text('Reports'),
                  ),
                ],
              ],
            ),
            VerticalDivider(width: 1, thickness: 1, color: theme.dividerColor),
            Expanded(child: navigationShell),
          ],
        ),
      );
    }

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view_rounded),
            label: 'Dashboard',
          ),
          const NavigationDestination(
            icon: Icon(Icons.auto_stories_outlined),
            selectedIcon: Icon(Icons.auto_stories_rounded),
            label: 'Catalog',
          ),
          const NavigationDestination(
            icon: Icon(Icons.swap_horiz_rounded),
            selectedIcon: Icon(Icons.swap_horizontal_circle_rounded),
            label: 'Activity',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
          if (isAdminOrLibrarian) ...[
            const NavigationDestination(
              icon: Icon(Icons.people_outline_rounded),
              selectedIcon: Icon(Icons.people_rounded),
              label: 'Members',
            ),
            const NavigationDestination(
              icon: Icon(Icons.analytics_outlined),
              selectedIcon: Icon(Icons.analytics_rounded),
              label: 'Reports',
            ),
          ],
        ],
      ),
    );
  }
}

class _DesktopSidebar extends StatelessWidget {
  const _DesktopSidebar({
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.isAdminOrLibrarian,
    required this.isWide,
    required this.userName,
    required this.userEmail,
    required this.initials,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final bool isAdminOrLibrarian;
  final bool isWide;
  final String userName;
  final String userEmail;
  final String initials;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = isWide ? 280.0 : 240.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: width,
      color: theme.scaffoldBackgroundColor,
      child: Column(
        children: [
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.auto_stories_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  'LibreFlow',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'MAIN',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.hintColor,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
          _SidebarItem(
            icon: Icons.grid_view_outlined,
            selectedIcon: Icons.grid_view_rounded,
            label: 'Dashboard',
            isSelected: selectedIndex == 0,
            onTap: () => onDestinationSelected(0),
          ),
          _SidebarItem(
            icon: Icons.auto_stories_outlined,
            selectedIcon: Icons.auto_stories_rounded,
            label: 'Catalog',
            isSelected: selectedIndex == 1,
            onTap: () => onDestinationSelected(1),
          ),
          _SidebarItem(
            icon: Icons.swap_horiz_rounded,
            selectedIcon: Icons.swap_horizontal_circle_rounded,
            label: 'Activity',
            isSelected: selectedIndex == 2,
            onTap: () => onDestinationSelected(2),
          ),
          _SidebarItem(
            icon: Icons.person_outline_rounded,
            selectedIcon: Icons.person_rounded,
            label: 'Profile',
            isSelected: selectedIndex == 3,
            onTap: () => onDestinationSelected(3),
          ),
          if (isAdminOrLibrarian) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'MANAGEMENT',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.hintColor,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
            _SidebarItem(
              icon: Icons.people_outline_rounded,
              selectedIcon: Icons.people_rounded,
              label: 'Members',
              isSelected: selectedIndex == 4,
              onTap: () => onDestinationSelected(4),
            ),
            _SidebarItem(
              icon: Icons.analytics_outlined,
              selectedIcon: Icons.analytics_rounded,
              label: 'Reports',
              isSelected: selectedIndex == 5,
              onTap: () => onDestinationSelected(5),
            ),
          ],
          const Spacer(),
          if (isWide) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Card(
                elevation: 0,
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                        child: Text(
                          initials,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName,
                              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              userEmail,
                              style: theme.textTheme.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          const Divider(indent: 20, endIndent: 20),
          _SidebarItem(
            icon: Icons.settings_outlined,
            label: 'Settings',
            onTap: () {},
          ),
          if (isWide)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'LibreFlow v1.0.0',
                style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor),
              ),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.icon,
    this.selectedIcon,
    required this.label,
    this.isSelected = false,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final IconData? selectedIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = color ?? theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        hoverColor: activeColor.withValues(alpha: 0.05),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? activeColor.withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                isSelected ? (selectedIcon ?? icon) : icon,
                color: isSelected ? activeColor : (color ?? theme.hintColor),
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? activeColor : (color ?? theme.colorScheme.onSurface),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
