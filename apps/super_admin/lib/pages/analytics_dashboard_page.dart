import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_core/school_core.dart';

class AnalyticsDashboardPage extends ConsumerStatefulWidget {
  const AnalyticsDashboardPage({super.key});

  @override
  ConsumerState<AnalyticsDashboardPage> createState() =>
      _AnalyticsDashboardPageState();
}

class _AnalyticsDashboardPageState
    extends ConsumerState<AnalyticsDashboardPage> {
  String? _selectedSchool;
  String _selectedTimeframe = 'month';
  String _selectedMetric = 'enrollment';
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic> _analyticsData = {};

  @override
  void initState() {
    super.initState();
    _loadAnalyticsData();
  }

  Future<void> _loadAnalyticsData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // TODO: Replace with actual service calls
      await Future.delayed(const Duration(seconds: 1));

      // Mock data for demonstration
      setState(() {
        _analyticsData = {
          'overview': {
            'totalStudents': 2450,
            'totalTeachers': 180,
            'totalSchools': 5,
            'totalRevenue': 125000.0,
            'growthRate': 12.5,
            'attendanceRate': 94.2,
          },
          'enrollmentTrend': List.generate(
            12,
            (index) => {
              'month': DateTime.now()
                  .subtract(Duration(days: (11 - index) * 30))
                  .month,
              'students': 2000 + (index * 50) + (index % 3 * 100),
              'teachers': 150 + (index * 3) + (index % 2 * 5),
            },
          ),
          'schoolPerformance': List.generate(
            5,
            (index) => {
              'school': 'School ${index + 1}',
              'students': 400 + (index * 100),
              'teachers': 30 + (index * 8),
              'attendance': 90.0 + (index * 1.5),
              'revenue': (20000 + (index * 5000)).toDouble(),
              'satisfaction': 4.2 + (index * 0.1),
            },
          ),
          'attendanceData': List.generate(
            7,
            (index) => {
              'day': DateTime.now().subtract(Duration(days: 6 - index)),
              'present': 2200 + (index * 20),
              'absent': 250 - (index * 10),
              'rate': 88.0 + (index * 1.0),
            },
          ),
          'subjectPopularity': [
            {'subject': 'Mathematics', 'students': 2100, 'percentage': 85.7},
            {'subject': 'English', 'students': 2000, 'percentage': 81.6},
            {'subject': 'Science', 'students': 1850, 'percentage': 75.5},
            {'subject': 'Social Studies', 'students': 1700, 'percentage': 69.4},
            {
              'subject': 'Physical Education',
              'students': 1600,
              'percentage': 65.3,
            },
            {'subject': 'Art', 'students': 1200, 'percentage': 49.0},
          ],
          'paymentAnalytics': {
            'onTime': 78.5,
            'late': 15.2,
            'pending': 6.3,
            'monthlyRevenue': List.generate(
              6,
              (index) => {
                'month': DateTime.now().subtract(
                  Duration(days: (5 - index) * 30),
                ),
                'amount': (18000 + (index * 2000) + (index % 2 * 3000))
                    .toDouble(),
              },
            ),
          },
          'teacherWorkload': List.generate(
            5,
            (index) => {
              'teacher': 'Teacher ${index + 1}',
              'classes': 4 + (index % 3),
              'students': 120 + (index * 15),
              'subjects': 2 + (index % 2),
              'workloadScore': 70.0 + (index * 5.0),
            },
          ),
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load analytics data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Widget _buildFiltersCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedSchool,
                decoration: const InputDecoration(
                  labelText: 'School',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('All Schools'),
                  ),
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
                    _selectedSchool = value;
                  });
                  _loadAnalyticsData();
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedTimeframe,
                decoration: const InputDecoration(
                  labelText: 'Timeframe',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'week', child: Text('Last Week')),
                  DropdownMenuItem(value: 'month', child: Text('Last Month')),
                  DropdownMenuItem(
                    value: 'quarter',
                    child: Text('Last Quarter'),
                  ),
                  DropdownMenuItem(value: 'year', child: Text('Last Year')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedTimeframe = value!;
                  });
                  _loadAnalyticsData();
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedMetric,
                decoration: const InputDecoration(
                  labelText: 'Primary Metric',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'enrollment',
                    child: Text('Enrollment'),
                  ),
                  DropdownMenuItem(
                    value: 'attendance',
                    child: Text('Attendance'),
                  ),
                  DropdownMenuItem(value: 'revenue', child: Text('Revenue')),
                  DropdownMenuItem(
                    value: 'performance',
                    child: Text('Performance'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedMetric = value!;
                  });
                  _loadAnalyticsData();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCards() {
    final overview = _analyticsData['overview'] as Map<String, dynamic>? ?? {};

    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            'Total Students',
            '${overview['totalStudents'] ?? 0}',
            Icons.school,
            Colors.blue,
            '+${overview['growthRate']?.toStringAsFixed(1) ?? '0'}%',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            'Total Teachers',
            '${overview['totalTeachers'] ?? 0}',
            Icons.person,
            Colors.green,
            'Active',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            'Schools',
            '${overview['totalSchools'] ?? 0}',
            Icons.business,
            Colors.orange,
            'Managed',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            'Attendance Rate',
            '${overview['attendanceRate']?.toStringAsFixed(1) ?? '0'}%',
            Icons.check_circle,
            Colors.purple,
            'This month',
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnrollmentChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enrollment Trend',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.trending_up, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    Text(
                      'Enrollment Trend Chart',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Interactive chart showing student enrollment over time',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
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

  Widget _buildAttendanceChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Attendance Analytics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.pie_chart, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    Text(
                      'Attendance Distribution',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Daily attendance rates and patterns',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
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

  Widget _buildSchoolPerformance() {
    final schools =
        _analyticsData['schoolPerformance'] as List<Map<String, dynamic>>? ??
        [];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'School Performance Comparison',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1),
                3: FlexColumnWidth(1),
                4: FlexColumnWidth(1),
              },
              children: [
                const TableRow(
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey)),
                  ),
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'School',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Students',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Teachers',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Attendance',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Revenue',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                ...schools.map(
                  (school) => TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(school['school']),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('${school['students']}'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('${school['teachers']}'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '${school['attendance'].toStringAsFixed(1)}%',
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '\$${school['revenue'].toStringAsFixed(0)}',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectPopularity() {
    final subjects =
        _analyticsData['subjectPopularity'] as List<Map<String, dynamic>>? ??
        [];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Subject Popularity',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...subjects.map(
              (subject) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          subject['subject'],
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          '${subject['students']} students (${subject['percentage'].toStringAsFixed(1)}%)',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: subject['percentage'] / 100,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
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

  Widget _buildPaymentAnalytics() {
    final payments =
        _analyticsData['paymentAnalytics'] as Map<String, dynamic>? ?? {};

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Analytics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildPaymentStatusCard(
                    'On Time',
                    '${payments['onTime']?.toStringAsFixed(1) ?? '0'}%',
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildPaymentStatusCard(
                    'Late',
                    '${payments['late']?.toStringAsFixed(1) ?? '0'}%',
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildPaymentStatusCard(
                    'Pending',
                    '${payments['pending']?.toStringAsFixed(1) ?? '0'}%',
                    Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentStatusCard(String title, String percentage, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            percentage,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 12, color: color)),
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
            Text(
              _errorMessage!,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadAnalyticsData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAnalyticsData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Analytics Dashboard',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Interactive charts and comprehensive analytics across all schools',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            _buildFiltersCard(),
            const SizedBox(height: 16),
            _buildOverviewCards(),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: _buildEnrollmentChart()),
                const SizedBox(width: 16),
                Expanded(child: _buildAttendanceChart()),
              ],
            ),
            const SizedBox(height: 16),
            _buildSchoolPerformance(),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildSubjectPopularity()),
                const SizedBox(width: 16),
                Expanded(child: _buildPaymentAnalytics()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
