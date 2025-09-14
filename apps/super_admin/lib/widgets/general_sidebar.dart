import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:school_core/school_core.dart';

class GeneralSidebar extends ConsumerWidget {
  const GeneralSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final currentRoute = GoRouterState.of(context).uri.path;

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Sidebar Header
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withOpacity(0.8),
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.white24,
                  child: Icon(
                    Icons.admin_panel_settings,
                    size: 25,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Super Admin',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (currentUser != null)
                  Text(
                    '${currentUser.firstName} ${currentUser.lastName}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
              ],
            ),
          ),

          // Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildSidebarItem(
                  context: context,
                  icon: Icons.dashboard_outlined,
                  selectedIcon: Icons.dashboard,
                  title: 'Dashboard',
                  route: '/home',
                  currentRoute: currentRoute,
                ),
                _buildSidebarItem(
                  context: context,
                  icon: Icons.sync_outlined,
                  selectedIcon: Icons.sync,
                  title: 'Data Sync',
                  route: '/sync',
                  currentRoute: currentRoute,
                ),
                _buildSidebarItem(
                  context: context,
                  icon: Icons.school_outlined,
                  selectedIcon: Icons.school,
                  title: 'School Management',
                  route: '/schools',
                  currentRoute: currentRoute,
                ),
                _buildSidebarItem(
                  context: context,
                  icon: Icons.people_outline,
                  selectedIcon: Icons.people,
                  title: 'User Management',
                  route: '/users',
                  currentRoute: currentRoute,
                ),

                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'DATA VIEWS',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                _buildSidebarItem(
                  context: context,
                  icon: Icons.person_outline,
                  selectedIcon: Icons.person,
                  title: 'Students View',
                  route: '/students',
                  currentRoute: currentRoute,
                ),
                _buildSidebarItem(
                  context: context,
                  icon: Icons.family_restroom_outlined,
                  selectedIcon: Icons.family_restroom,
                  title: 'Parents View',
                  route: '/parents',
                  currentRoute: currentRoute,
                ),
                _buildSidebarItem(
                  context: context,
                  icon: Icons.person_4_outlined,
                  selectedIcon: Icons.person_4,
                  title: 'Teachers View',
                  route: '/teachers',
                  currentRoute: currentRoute,
                ),
                _buildSidebarItem(
                  context: context,
                  icon: Icons.class_outlined,
                  selectedIcon: Icons.class_,
                  title: 'Classes View',
                  route: '/classes',
                  currentRoute: currentRoute,
                ),
                _buildSidebarItem(
                  context: context,
                  icon: Icons.subject_outlined,
                  selectedIcon: Icons.subject,
                  title: 'Subjects View',
                  route: '/subjects',
                  currentRoute: currentRoute,
                ),

                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'REPORTS & ANALYTICS',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                _buildSidebarItem(
                  context: context,
                  icon: Icons.payment_outlined,
                  selectedIcon: Icons.payment,
                  title: 'Payments Reports',
                  route: '/payments',
                  currentRoute: currentRoute,
                ),
                _buildSidebarItem(
                  context: context,
                  icon: Icons.analytics_outlined,
                  selectedIcon: Icons.analytics,
                  title: 'Analytics Dashboard',
                  route: '/analytics',
                  currentRoute: currentRoute,
                ),
                _buildSidebarItem(
                  context: context,
                  icon: Icons.history_outlined,
                  selectedIcon: Icons.history,
                  title: 'Audit Log',
                  route: '/audit',
                  currentRoute: currentRoute,
                ),

                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Divider(),
                ),

                _buildSidebarItem(
                  context: context,
                  icon: Icons.settings_outlined,
                  selectedIcon: Icons.settings,
                  title: 'Settings',
                  route: '/settings',
                  currentRoute: currentRoute,
                ),
              ],
            ),
          ),

          // Logout Section
          const Divider(),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _handleLogout(context, ref),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.logout, size: 20, color: Colors.red),
                      SizedBox(width: 12),
                      Text(
                        'Logout',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSidebarItem({
    required BuildContext context,
    required IconData icon,
    required IconData selectedIcon,
    required String title,
    required String route,
    required String currentRoute,
  }) {
    final isSelected = currentRoute == route;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            if (!isSelected) {
              context.go(route);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.3),
                      width: 1,
                    )
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  isSelected ? selectedIcon : icon,
                  size: 20,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey[600],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey[700],
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    try {
      final authService = ref.read(authServiceProvider);
      await authService.signOut();

      if (context.mounted) {
        context.go('/login');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
