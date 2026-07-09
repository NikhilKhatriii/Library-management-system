import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/application/auth_provider.dart';
import '../../features/auth/domain/models/user_role.dart';

/// The persistent navigation shell wrapping every authenticated
/// route. Built on [StatefulShellRoute].
class AppScaffold extends ConsumerWidget {
  const AppScaffold({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;
    final theme = Theme.of(context);
    final isAdminOrLibrarian = user?.role == UserRole.admin || user?.role == UserRole.librarian;

    if (isDesktop) {
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
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final bool isAdminOrLibrarian;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 260,
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
          const Divider(indent: 20, endIndent: 20),
          _SidebarItem(
            icon: Icons.settings_outlined,
            label: 'Settings',
            onTap: () {},
          ),
          _SidebarItem(
            icon: Icons.logout_rounded,
            label: 'Log out',
            color: theme.colorScheme.error,
            onTap: () {},
          ),
          const SizedBox(height: 24),
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
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? activeColor : (color ?? theme.colorScheme.onSurface),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
