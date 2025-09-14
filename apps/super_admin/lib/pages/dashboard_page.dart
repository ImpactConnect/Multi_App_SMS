import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_core/school_core.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  String? _selectedSchoolId;
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

      // Fetch actual data from local database
      final schools = await SQLiteDatabaseService.getAllSchools();
      final allUsers = await SQLiteDatabaseService.getAllUsers();
      final students = await SQLiteDatabaseService.getAllStudents();
      final teachers = await SQLiteDatabaseService.getUsersByRole(
        UserRole.teacher,
      );
      final parents = await SQLiteDatabaseService.getUsersByRole(
        UserRole.parent,
      );
      final classes = await SQLiteDatabaseService.getAllClasses();
      final subjects = await SQLiteDatabaseService.getAllSubjects();

      setState(() {
        _dashboardData = {
          'totalSchools': schools.length,
          'totalUsers': allUsers.length,
          'activeStudents': students.length,
          'totalTeachers': teachers.length,
          'totalParents': parents.length,
          'totalClasses': classes.length,
          'totalSubjects': subjects.length,
          'monthlyRevenue': 0, // TODO: Calculate from actual payment data
          'recentActivity':
              <Map<String, String>>[], // TODO: Get from actual activity logs
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

  Widget _buildSchoolSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'School Filter',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedSchoolId,
              decoration: const InputDecoration(
                labelText: 'Select School',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.school),
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('All Schools')),
                ...List.generate(
                  5,
                  (index) => DropdownMenuItem(
                    value: 'school_$index',
                    child: Text('School ${index + 1}'),
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedSchoolId = value;
                });
                _loadDashboardData();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
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
              ...activities
                  .take(5)
                  .map(
                    (activity) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _getActivityColor(activity['type']),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Text(activity['action'] ?? '')),
                          Text(
                            activity['time'] ?? '',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                // TODO: Navigate to audit log
              },
              child: const Text('View All Activity'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getActivityColor(String? type) {
    switch (type) {
      case 'school':
        return Colors.blue;
      case 'user':
        return Colors.green;
      case 'payment':
        return Colors.orange;
      case 'system':
        return Colors.purple;
      default:
        return Colors.grey;
    }
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
            const SizedBox(height: 16),

            // School Selector
            _buildSchoolSelector(),
            const SizedBox(height: 24),

            // Metrics Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 4 : 2,
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
                  subtitle: 'Active accounts',
                ),
                _buildMetricCard(
                  title: 'Active Students',
                  value: _dashboardData['activeStudents']?.toString() ?? '0',
                  icon: Icons.person,
                  color: Colors.orange,
                  subtitle: 'Enrolled students',
                ),
                _buildMetricCard(
                  title: 'Total Teachers',
                  value: _dashboardData['totalTeachers']?.toString() ?? '0',
                  icon: Icons.person_outline,
                  color: Colors.purple,
                  subtitle: 'Teaching staff',
                ),
                _buildMetricCard(
                  title: 'Total Parents',
                  value: _dashboardData['totalParents']?.toString() ?? '0',
                  icon: Icons.family_restroom,
                  color: Colors.teal,
                  subtitle: 'Parent accounts',
                ),
                _buildMetricCard(
                  title: 'Total Classes',
                  value: _dashboardData['totalClasses']?.toString() ?? '0',
                  icon: Icons.class_,
                  color: Colors.indigo,
                  subtitle: 'Active classes',
                ),
                _buildMetricCard(
                  title: 'Total Subjects',
                  value: _dashboardData['totalSubjects']?.toString() ?? '0',
                  icon: Icons.book,
                  color: Colors.brown,
                  subtitle: 'Available subjects',
                ),
                _buildMetricCard(
                  title: 'Monthly Revenue',
                  value:
                      '₦${(_dashboardData['monthlyRevenue'] ?? 0).toString()}',
                  icon: Icons.attach_money,
                  color: Colors.green[700]!,
                  subtitle: 'This month',
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Recent Activity
            _buildRecentActivityCard(),
          ],
        ),
      ),
    );
  }
}
