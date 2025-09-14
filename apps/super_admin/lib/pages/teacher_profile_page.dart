import 'package:flutter/material.dart';
import 'package:school_core/school_core.dart';

class TeacherProfilePage extends StatefulWidget {
  final Map<String, dynamic> teacher;

  const TeacherProfilePage({super.key, required this.teacher});

  @override
  State<TeacherProfilePage> createState() => _TeacherProfilePageState();
}

class _TeacherProfilePageState extends State<TeacherProfilePage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;

  // Mock data
  List<Map<String, dynamic>> _lessonPlans = [];
  List<Map<String, dynamic>> _activities = [];
  List<Map<String, dynamic>> _schedule = [];
  List<Map<String, dynamic>> _paymentHistory = [];
  List<Map<String, dynamic>> _assignedClasses = [];
  Map<String, dynamic> _teacherStats = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    _loadTeacherData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTeacherData() async {
    setState(() => _isLoading = true);

    // TODO: Fetch actual lesson plans and activities from database
    // For now, show empty data since no actual data exists in database
    setState(() {
      _lessonPlans = <Map<String, dynamic>>[];
      _activities = <Map<String, dynamic>>[];

      _schedule = <Map<String, dynamic>>[];
      _paymentHistory = <Map<String, dynamic>>[];
      _assignedClasses = <Map<String, dynamic>>[];

      _teacherStats = {
        'totalClasses': 0,
        'totalStudents': 0,
        'totalLessonPlans': _lessonPlans.length,
        'completedActivities': _activities
            .where((a) => a['status'] == 'Completed')
            .length,
        'averageClassGrade':
            _assignedClasses.fold<double>(
              0,
              (sum, c) => sum + (c['averageGrade'] as double),
            ) /
            _assignedClasses.length,
        'averageAttendance':
            _assignedClasses.fold<double>(
              0,
              (sum, c) => sum + (c['attendance'] as double),
            ) /
            _assignedClasses.length,
      };

      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Row(
              children: [
                // Sidebar
                Container(
                  width: 280,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(1, 0),
                      ),
                    ],
                  ),
                  child: _buildSidebar(),
                ),
                // Main content
                Expanded(
                  child: Container(
                    color: const Color(0xFFF8FAFC),
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildOverviewTab(),
                        _buildProfileTab(),
                        _buildSubjectsTab(),
                        _buildLessonPlansTab(),
                        _buildActivitiesTab(),
                        _buildScheduleTab(),
                        _buildPaymentTab(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSidebar() {
    return Column(
      children: [
        // Teacher Header
        Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [const Color(0xFF1E40AF), const Color(0xFF3B82F6)],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 35,
                backgroundColor: Colors.white,
                child: Text(
                  '${widget.teacher['firstName'][0]}${widget.teacher['lastName'][0]}',
                  style: const TextStyle(
                    color: Color(0xFF1E40AF),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${widget.teacher['firstName']} ${widget.teacher['lastName']}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                widget.teacher['employeeId'],
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: widget.teacher['status'] == 'Active'
                      ? Colors.green.withOpacity(0.8)
                      : Colors.orange.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.teacher['status'].toString().toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
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
                title: 'Overview',
                tabIndex: 0,
              ),
              _buildSidebarItem(
                icon: Icons.person_outline,
                selectedIcon: Icons.person,
                title: 'Profile Info',
                tabIndex: 1,
              ),
              _buildSidebarItem(
                icon: Icons.book_outlined,
                selectedIcon: Icons.book,
                title: 'Subjects & Classes',
                tabIndex: 2,
              ),
              _buildSidebarItem(
                icon: Icons.assignment_outlined,
                selectedIcon: Icons.assignment,
                title: 'Lesson Plans',
                tabIndex: 3,
              ),
              _buildSidebarItem(
                icon: Icons.task_outlined,
                selectedIcon: Icons.task,
                title: 'Activities',
                tabIndex: 4,
              ),
              _buildSidebarItem(
                icon: Icons.schedule_outlined,
                selectedIcon: Icons.schedule,
                title: 'Schedule',
                tabIndex: 5,
              ),
              _buildSidebarItem(
                icon: Icons.payment_outlined,
                selectedIcon: Icons.payment,
                title: 'Payment History',
                tabIndex: 6,
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
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: const Row(
                  children: [
                    Icon(Icons.arrow_back, size: 20, color: Colors.red),
                    SizedBox(width: 12),
                    Text(
                      'Back to Teachers',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSidebarItem({
    required IconData icon,
    required IconData selectedIcon,
    required String title,
    required int tabIndex,
  }) {
    final isSelected = _tabController.index == tabIndex;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            _tabController.animateTo(tabIndex);
            setState(() {});
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF1E40AF).withOpacity(0.1)
                  : null,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  isSelected ? selectedIcon : icon,
                  size: 20,
                  color: isSelected
                      ? const Color(0xFF1E40AF)
                      : Colors.grey[600],
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    color: isSelected
                        ? const Color(0xFF1E40AF)
                        : Colors.grey[700],
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Teacher Overview',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Summary Cards
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Total Classes',
                  '${_teacherStats['totalClasses']}',
                  Icons.class_,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  'Total Students',
                  '${_teacherStats['totalStudents']}',
                  Icons.people,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  'Lesson Plans',
                  '${_teacherStats['totalLessonPlans']}',
                  Icons.assignment,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  'Avg. Grade',
                  '${_teacherStats['averageClassGrade']?.toStringAsFixed(1)}%',
                  Icons.grade,
                  Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Recent Activities
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recent Activities',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ...(_activities
                      .take(5)
                      .map((activity) => _buildActivityItem(activity))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Personal Information',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildInfoRow(
                    'Full Name',
                    '${widget.teacher['firstName']} ${widget.teacher['lastName']}',
                  ),
                  _buildInfoRow('Employee ID', widget.teacher['employeeId']),
                  _buildInfoRow('Email', widget.teacher['email']),
                  _buildInfoRow('Phone Number', widget.teacher['phoneNumber']),
                  _buildInfoRow('Department', widget.teacher['department']),
                  _buildInfoRow(
                    'Qualification',
                    widget.teacher['qualification'],
                  ),
                  _buildInfoRow('Experience', widget.teacher['experience']),
                  _buildInfoRow('Join Date', widget.teacher['joinDate']),
                  _buildInfoRow('Status', widget.teacher['status']),
                  if (widget.teacher['isClassTeacher'])
                    _buildInfoRow(
                      'Assigned Class',
                      widget.teacher['assignedClass'] ?? 'N/A',
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Subjects & Classes',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Subjects
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Teaching Subjects',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (widget.teacher['subjects'] as List<String>)
                        .map(
                          (subject) => Chip(
                            label: Text(subject),
                            backgroundColor: Colors.blue[100],
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Assigned Classes
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Assigned Classes',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ..._assignedClasses.map(
                    (classInfo) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  classInfo['name'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text('${classInfo['students']} students'),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Avg Grade: ${classInfo['averageGrade'].toStringAsFixed(1)}%',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              Text(
                                'Attendance: ${classInfo['attendance'].toStringAsFixed(1)}%',
                                style: TextStyle(color: Colors.grey[600]),
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
          ),
        ],
      ),
    );
  }

  Widget _buildLessonPlansTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lesson Plans',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          ..._lessonPlans.map(
            (lesson) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            lesson['topic'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(lesson['status']),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            lesson['status'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.book, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(lesson['subject']),
                        const SizedBox(width: 16),
                        Icon(Icons.class_, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(lesson['class']),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(lesson['duration']),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Date: ${_formatDate(lesson['date'])}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitiesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Activities & Assignments',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          ..._activities.map(
            (activity) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getActivityTypeColor(activity['type']),
                  child: Icon(
                    _getActivityIcon(activity['type']),
                    color: Colors.white,
                  ),
                ),
                title: Text(activity['title']),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${activity['subject']} - ${activity['class']}'),
                    Text('Due: ${_formatDate(activity['dueDate'])}'),
                    Text(
                      'Submissions: ${activity['submissions']}/${activity['totalStudents']}',
                    ),
                  ],
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(activity['status']),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    activity['status'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleTab() {
    final groupedSchedule = <String, List<Map<String, dynamic>>>{};
    for (final item in _schedule) {
      final day = item['day'] as String;
      if (!groupedSchedule.containsKey(day)) {
        groupedSchedule[day] = [];
      }
      groupedSchedule[day]!.add(item);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Class Schedule',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          ...groupedSchedule.entries.map(
            (entry) => Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...entry.value.map(
                      (schedule) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                schedule['time'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Expanded(flex: 2, child: Text(schedule['subject'])),
                            Expanded(flex: 2, child: Text(schedule['class'])),
                            Expanded(child: Text(schedule['room'])),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                schedule['type'],
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.blue[800],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment History',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          Card(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Month')),
                  DataColumn(label: Text('Basic Salary')),
                  DataColumn(label: Text('Allowances')),
                  DataColumn(label: Text('Deductions')),
                  DataColumn(label: Text('Net Salary')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Payment Date')),
                ],
                rows: _paymentHistory.map((payment) {
                  return DataRow(
                    cells: [
                      DataCell(Text(_formatMonth(payment['month']))),
                      DataCell(Text('₹${payment['basicSalary']}')),
                      DataCell(Text('₹${payment['allowances']}')),
                      DataCell(Text('₹${payment['deductions']}')),
                      DataCell(Text('₹${payment['netSalary']}')),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: payment['status'] == 'Paid'
                                ? Colors.green[100]
                                : Colors.orange[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            payment['status'],
                            style: TextStyle(
                              color: payment['status'] == 'Paid'
                                  ? Colors.green[800]
                                  : Colors.orange[800],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          payment['paymentDate'] != null
                              ? _formatDate(payment['paymentDate'])
                              : 'Pending',
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: _getActivityTypeColor(activity['type']),
            child: Icon(
              _getActivityIcon(activity['type']),
              size: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['title'],
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  '${activity['subject']} - ${activity['class']}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Text(
            _formatDate(activity['date']),
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          const Text(': '),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'paid':
        return Colors.green;
      case 'in progress':
      case 'active':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      case 'overdue':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getActivityTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'assignment':
        return Colors.blue;
      case 'test':
      case 'quiz':
        return Colors.red;
      case 'project':
        return Colors.green;
      case 'presentation':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getActivityIcon(String type) {
    switch (type.toLowerCase()) {
      case 'assignment':
        return Icons.assignment;
      case 'test':
      case 'quiz':
        return Icons.quiz;
      case 'project':
        return Icons.work;
      case 'presentation':
        return Icons.present_to_all;
      default:
        return Icons.task;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatMonth(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}
