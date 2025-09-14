import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:school_core/school_core.dart';
import 'package:uuid/uuid.dart';
import '../pages/dashboard_page.dart';
import '../pages/user_management_page.dart';
import '../pages/students_view_page.dart';
import '../pages/parents_view_page.dart';
import '../pages/classes_view_page.dart';
import '../pages/subjects_view_page.dart';
import '../pages/payments_reports_page.dart';
import '../pages/analytics_dashboard_page.dart';
import '../pages/audit_log_page.dart';
import '../pages/settings_page.dart';
import '../pages/teachers_view_page.dart';
import '../pages/schools_view_page.dart';
import '../pages/sync_page.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _selectedPage = 'dashboard';

  final Map<String, Widget> _pages = {
    'dashboard': const DashboardPage(),
    'schools': const SchoolsViewPage(),
    'users': const UserManagementPage(),
    'students': const StudentsViewPage(),
    'parents': const ParentsViewPage(),
    'teachers': const TeachersViewPage(),
    'classes': const ClassesViewPage(),
    'subjects': const SubjectsViewPage(),
    'payments': const PaymentsReportsPage(),
    'analytics': const AnalyticsDashboardPage(),
    'audit': const AuditLogPage(),
    'sync': const SyncPage(),
    'settings': const SettingsPage(),
  };

  Future<void> _handleLogout() async {
    try {
      final authService = ref.read(authServiceProvider);
      await authService.signOut();
      ref.read(currentUserProvider.notifier).state = null;
      if (mounted) {
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed: ${e.toString()}')),
        );
      }
    }
  }

  Widget _buildSidebar(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);

    return Column(
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
                icon: Icons.dashboard_outlined,
                selectedIcon: Icons.dashboard,
                title: 'Dashboard',
                pageKey: 'dashboard',
              ),
              _buildSidebarItem(
                icon: Icons.school_outlined,
                selectedIcon: Icons.school,
                title: 'School Management',
                pageKey: 'schools',
              ),
              _buildSidebarItem(
                icon: Icons.people_outline,
                selectedIcon: Icons.people,
                title: 'User Management',
                pageKey: 'users',
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
                icon: Icons.person_outline,
                selectedIcon: Icons.person,
                title: 'Students View',
                pageKey: 'students',
              ),
              _buildSidebarItem(
                icon: Icons.family_restroom_outlined,
                selectedIcon: Icons.family_restroom,
                title: 'Parents View',
                pageKey: 'parents',
              ),
              _buildSidebarItem(
                icon: Icons.person_4_outlined,
                selectedIcon: Icons.person_4,
                title: 'Teachers View',
                pageKey: 'teachers',
              ),
              _buildSidebarItem(
                icon: Icons.class_outlined,
                selectedIcon: Icons.class_,
                title: 'Classes View',
                pageKey: 'classes',
              ),
              _buildSidebarItem(
                icon: Icons.subject_outlined,
                selectedIcon: Icons.subject,
                title: 'Subjects View',
                pageKey: 'subjects',
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
                icon: Icons.payment_outlined,
                selectedIcon: Icons.payment,
                title: 'Payments Reports',
                pageKey: 'payments',
              ),
              _buildSidebarItem(
                icon: Icons.analytics_outlined,
                selectedIcon: Icons.analytics,
                title: 'Analytics Dashboard',
                pageKey: 'analytics',
              ),
              _buildSidebarItem(
                icon: Icons.history_outlined,
                selectedIcon: Icons.history,
                title: 'Audit Log',
                pageKey: 'audit',
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Divider(),
              ),
              _buildSidebarItem(
                icon: Icons.sync_outlined,
                selectedIcon: Icons.sync,
                title: 'Data Sync',
                pageKey: 'sync',
              ),
              _buildSidebarItem(
                icon: Icons.settings_outlined,
                selectedIcon: Icons.settings,
                title: 'Settings',
                pageKey: 'settings',
              ),
            ],
          ),
        ),
        const Divider(),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: _handleLogout,
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
    );
  }

  Widget _buildSidebarItem({
    required IconData icon,
    required IconData selectedIcon,
    required String title,
    required String pageKey,
  }) {
    final isSelected = _selectedPage == pageKey;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            setState(() {
              _selectedPage = pageKey;
            });
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
                Text(
                  title,
                  style: TextStyle(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey[700],
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getPageTitle() {
    switch (_selectedPage) {
      case 'dashboard':
        return 'Dashboard';
      case 'schools':
        return 'School Management';
      case 'users':
        return 'User Management';
      case 'students':
        return 'Students View';
      case 'parents':
        return 'Parents View';
      case 'teachers':
        return 'Teachers View';
      case 'classes':
        return 'Classes View';
      case 'subjects':
        return 'Subjects View';
      case 'payments':
        return 'Payments Reports';
      case 'analytics':
        return 'Analytics Dashboard';
      case 'audit':
        return 'Audit Log';
      case 'sync':
        return 'Data Sync';
      case 'settings':
        return 'Settings';
      default:
        return 'Super Admin';
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      body: Row(
        children: [
          // Persistent Sidebar
          Container(
            width: 280,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                right: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: _buildSidebar(context),
          ),
          // Main Content Area
          Expanded(
            child: Column(
              children: [
                // Top App Bar
                Container(
                  height: 64,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).dividerColor,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 24),
                      Text(
                        _getPageTitle(),
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined),
                        onPressed: () {
                          // TODO: Show notifications
                        },
                      ),
                      if (currentUser != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Center(
                            child: Text(
                              '${currentUser.firstName} ${currentUser.lastName}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                      IconButton(
                        icon: const Icon(Icons.logout),
                        onPressed: _handleLogout,
                        tooltip: 'Logout',
                      ),
                      const SizedBox(width: 16),
                    ],
                  ),
                ),
                // Page Content
                Expanded(
                  child:
                      _pages[_selectedPage] ??
                      const Center(child: Text('Page not found')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  Map<String, dynamic> _dashboardData = {};
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // TODO: Replace with actual service calls when available
      // Simulating data loading for now
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _dashboardData = {
          'totalSchools': 12,
          'totalUsers': 245,
          'activeStudents': 1850,
          'totalTeachers': 89,
          'recentActivity': [
            {'action': 'New school registered', 'time': '2 hours ago'},
            {'action': 'User account created', 'time': '4 hours ago'},
            {'action': 'System backup completed', 'time': '1 day ago'},
          ],
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load dashboard data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? subtitle,
  }) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivityCard() {
    final activities =
        _dashboardData['recentActivity'] as List<Map<String, String>>? ?? [];

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.history, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  'Recent Activity',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (activities.isEmpty)
              const Text('No recent activity')
            else
              ...activities.map(
                (activity) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      const Icon(Icons.circle, size: 8, color: Colors.blue),
                      const SizedBox(width: 12),
                      Expanded(child: Text(activity['action'] ?? '')),
                      Text(
                        activity['time'] ?? '',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadDashboardData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dashboard Overview',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // Metrics Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                _buildMetricCard(
                  title: 'Total Schools',
                  value: _dashboardData['totalSchools']?.toString() ?? '0',
                  icon: Icons.school,
                  color: Colors.blue,
                  subtitle: 'Registered institutions',
                ),
                _buildMetricCard(
                  title: 'Total Users',
                  value: _dashboardData['totalUsers']?.toString() ?? '0',
                  icon: Icons.people,
                  color: Colors.green,
                  subtitle: 'System users',
                ),
                _buildMetricCard(
                  title: 'Active Students',
                  value: _dashboardData['activeStudents']?.toString() ?? '0',
                  icon: Icons.school_outlined,
                  color: Colors.purple,
                  subtitle: 'Enrolled students',
                ),
                _buildMetricCard(
                  title: 'Teachers',
                  value: _dashboardData['totalTeachers']?.toString() ?? '0',
                  icon: Icons.person_outline,
                  color: Colors.orange,
                  subtitle: 'Active educators',
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Recent Activity Section
            _buildRecentActivityCard(),

            const SizedBox(height: 24),

            // Quick Actions
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.flash_on, color: Colors.amber),
                        SizedBox(width: 8),
                        Text(
                          'Quick Actions',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            // TODO: Navigate to add school
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Add School'),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            // TODO: Navigate to user management
                          },
                          icon: const Icon(Icons.person_add),
                          label: const Text('Add User'),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            // TODO: Generate reports
                          },
                          icon: const Icon(Icons.assessment),
                          label: const Text('Generate Report'),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            // TODO: System backup
                          },
                          icon: const Icon(Icons.backup),
                          label: const Text('System Backup'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SchoolManagementPage extends ConsumerStatefulWidget {
  const SchoolManagementPage({super.key});

  @override
  ConsumerState<SchoolManagementPage> createState() =>
      _SchoolManagementPageState();
}

class _SchoolManagementPageState extends ConsumerState<SchoolManagementPage> {
  List<Map<String, dynamic>> _schools = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSchools();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSchools() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // TODO: Replace with actual service calls
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _schools = [
          {
            'id': '1',
            'name': 'Greenwood High School',
            'address': '123 Main St, City, State',
            'phone': '+1 (555) 123-4567',
            'email': 'admin@greenwood.edu',
            'students': 850,
            'teachers': 45,
            'status': 'Active',
            'createdAt': '2023-01-15',
          },
          {
            'id': '2',
            'name': 'Riverside Elementary',
            'address': '456 Oak Ave, City, State',
            'phone': '+1 (555) 987-6543',
            'email': 'contact@riverside.edu',
            'students': 320,
            'teachers': 18,
            'status': 'Active',
            'createdAt': '2023-03-22',
          },
          {
            'id': '3',
            'name': 'Mountain View Academy',
            'address': '789 Pine Rd, City, State',
            'phone': '+1 (555) 456-7890',
            'email': 'info@mountainview.edu',
            'students': 1200,
            'teachers': 72,
            'status': 'Inactive',
            'createdAt': '2022-09-10',
          },
        ];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load schools: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredSchools {
    if (_searchQuery.isEmpty) return _schools;
    return _schools.where((school) {
      final name = school['name']?.toString().toLowerCase() ?? '';
      final address = school['address']?.toString().toLowerCase() ?? '';
      final email = school['email']?.toString().toLowerCase() ?? '';
      final query = _searchQuery.toLowerCase();
      return name.contains(query) ||
          address.contains(query) ||
          email.contains(query);
    }).toList();
  }

  void _showAddSchoolDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddSchoolDialog(
        onSchoolAdded: (school) {
          setState(() {
            _schools.add(school);
          });
        },
      ),
    );
  }

  void _showEditSchoolDialog(Map<String, dynamic> school) {
    showDialog(
      context: context,
      builder: (context) => _AddSchoolDialog(
        school: school,
        onSchoolAdded: (updatedSchool) {
          setState(() {
            final index = _schools.indexWhere((s) => s['id'] == school['id']);
            if (index != -1) {
              _schools[index] = updatedSchool;
            }
          });
        },
      ),
    );
  }

  void _deleteSchool(String schoolId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete School'),
        content: const Text(
          'Are you sure you want to delete this school? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _schools.removeWhere((school) => school['id'] == schoolId);
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('School deleted successfully')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(_errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadSchools, child: const Text('Retry')),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'School Management',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: _showAddSchoolDialog,
                icon: const Icon(Icons.add),
                label: const Text('Add School'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Search Bar
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Search schools...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 16),

          // Schools List
          Expanded(
            child: _filteredSchools.isEmpty
                ? const Center(
                    child: Text(
                      'No schools found',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredSchools.length,
                    itemBuilder: (context, index) {
                      final school = _filteredSchools[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: school['status'] == 'Active'
                                ? Colors.green
                                : Colors.grey,
                            child: Text(
                              school['name']
                                      ?.toString()
                                      .substring(0, 1)
                                      .toUpperCase() ??
                                  'S',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            school['name'] ?? 'Unknown School',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(school['address'] ?? ''),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.people,
                                    size: 16,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text('${school['students']} students'),
                                  const SizedBox(width: 16),
                                  Icon(
                                    Icons.person,
                                    size: 16,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text('${school['teachers']} teachers'),
                                ],
                              ),
                            ],
                          ),
                          trailing: PopupMenuButton(
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit),
                                    SizedBox(width: 8),
                                    Text('Edit'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            onSelected: (value) {
                              if (value == 'edit') {
                                _showEditSchoolDialog(school);
                              } else if (value == 'delete') {
                                _deleteSchool(school['id']);
                              }
                            },
                          ),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _AddSchoolDialog extends StatefulWidget {
  final Map<String, dynamic>? school;
  final Function(Map<String, dynamic>) onSchoolAdded;

  const _AddSchoolDialog({this.school, required this.onSchoolAdded});

  @override
  State<_AddSchoolDialog> createState() => _AddSchoolDialogState();
}

class _AddSchoolDialogState extends State<_AddSchoolDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  String _status = 'Active';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.school?['name'] ?? '');
    _addressController = TextEditingController(
      text: widget.school?['address'] ?? '',
    );
    _phoneController = TextEditingController(
      text: widget.school?['phone'] ?? '',
    );
    _emailController = TextEditingController(
      text: widget.school?['email'] ?? '',
    );
    _status = widget.school?['status'] ?? 'Active';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _saveSchool() {
    if (_formKey.currentState!.validate()) {
      final school = {
        'id': widget.school?['id'] ?? const Uuid().v4(),
        'name': _nameController.text,
        'address': _addressController.text,
        'phone': _phoneController.text,
        'email': _emailController.text,
        'status': _status,
        'students': widget.school?['students'] ?? 0,
        'teachers': widget.school?['teachers'] ?? 0,
        'createdAt':
            widget.school?['createdAt'] ??
            DateTime.now().toString().split(' ')[0],
      };

      widget.onSchoolAdded(school);
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.school == null
                ? 'School added successfully'
                : 'School updated successfully',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.school == null ? 'Add School' : 'Edit School'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'School Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter school name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Active', child: Text('Active')),
                  DropdownMenuItem(value: 'Inactive', child: Text('Inactive')),
                ],
                onChanged: (value) {
                  setState(() {
                    _status = value!;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveSchool,
          child: Text(widget.school == null ? 'Add' : 'Update'),
        ),
      ],
    );
  }
}

class SystemSettingsPage extends StatelessWidget {
  const SystemSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('System Settings - Coming Soon'));
  }
}
