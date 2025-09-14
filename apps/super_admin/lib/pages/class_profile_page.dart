import 'package:flutter/material.dart';
import 'package:school_core/school_core.dart';

class ClassProfilePage extends StatefulWidget {
  final SchoolClass schoolClass;

  const ClassProfilePage({super.key, required this.schoolClass});

  @override
  State<ClassProfilePage> createState() => _ClassProfilePageState();
}

class _ClassProfilePageState extends State<ClassProfilePage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;

  // Mock data
  List<Map<String, dynamic>> _students = [];
  List<Map<String, dynamic>> _subjects = [];
  List<Map<String, dynamic>> _activities = [];
  List<Map<String, dynamic>> _paymentRecords = [];
  Map<String, dynamic>? _classTeacher;
  Map<String, dynamic> _classStats = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _loadClassData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadClassData() async {
    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // Mock data generation
    final studentCount = (widget.schoolClass.id.hashCode % 30) + 15;
    final subjectCount = (widget.schoolClass.id.hashCode % 8) + 5;

    setState(() {
      _students = List.generate(
        studentCount,
        (index) => {
          'id': 'student_${index + 1}',
          'name': 'Student ${index + 1}',
          'rollNumber':
              '${widget.schoolClass.grade.replaceAll('Grade ', '')}${(index + 1).toString().padLeft(3, '0')}',
          'gender': index % 2 == 0 ? 'Male' : 'Female',
          'age': 12 + (index % 6),
          'attendance': 85 + (index % 15),
          'totalFees': 5000 + (index % 1000),
          'paidFees': 3000 + (index % 2000),
          'pendingFees': 2000 - (index % 1000),
        },
      );

      _subjects = List.generate(
        subjectCount,
        (index) => {
          'id': 'subject_${index + 1}',
          'name': [
            'Mathematics',
            'English',
            'Science',
            'History',
            'Geography',
            'Art',
            'Physical Education',
            'Computer Science',
          ][index],
          'teacher': 'Teacher ${index + 1}',
          'totalClasses': 40 + (index % 20),
          'completedClasses': 25 + (index % 15),
          'averageScore': 75 + (index % 20),
        },
      );

      _activities = List.generate(
        10,
        (index) => {
          'id': 'activity_${index + 1}',
          'title': 'Activity ${index + 1}',
          'type': ['Assignment', 'Test', 'Project', 'Presentation'][index % 4],
          'date': DateTime.now().subtract(Duration(days: index * 3)),
          'status': ['Completed', 'In Progress', 'Pending'][index % 3],
          'participants': studentCount - (index % 5),
        },
      );

      _paymentRecords = List.generate(
        studentCount,
        (index) => {
          'studentId': 'student_${index + 1}',
          'studentName': 'Student ${index + 1}',
          'totalAmount': 5000 + (index % 1000),
          'paidAmount': 3000 + (index % 2000),
          'pendingAmount': 2000 - (index % 1000),
          'lastPayment': DateTime.now().subtract(Duration(days: index % 30)),
          'status': (2000 - (index % 1000)) <= 0 ? 'Paid' : 'Pending',
        },
      );

      _classTeacher = {
        'id': 'teacher_1',
        'name': 'Ms. Sarah Johnson',
        'email': 'sarah.johnson@school.edu',
        'phone': '+1 234 567 8900',
        'experience': '8 years',
        'qualification': 'M.Ed in Elementary Education',
        'subjects': ['Mathematics', 'Science'],
      };

      _classStats = {
        'totalStudents': studentCount,
        'averageAttendance': 87.5,
        'averageGrade': 78.2,
        'totalSubjects': subjectCount,
        'completedActivities': _activities
            .where((a) => a['status'] == 'Completed')
            .length,
        'totalFees': _paymentRecords.fold<int>(
          0,
          (sum, p) => sum + (p['totalAmount'] as int),
        ),
        'collectedFees': _paymentRecords.fold<int>(
          0,
          (sum, p) => sum + (p['paidAmount'] as int),
        ),
        'pendingFees': _paymentRecords.fold<int>(
          0,
          (sum, p) => sum + (p['pendingAmount'] as int),
        ),
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
                        _buildStudentsTab(),
                        _buildSubjectsTab(),
                        _buildActivitiesTab(),
                        _buildTeacherTab(),
                        _buildPaymentsTab(),
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
        // Class Header
        Container(
          height: 160,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [const Color(0xFF6B46C1), const Color(0xFF8B5CF6)],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                child: Text(
                  widget.schoolClass.name.isNotEmpty
                      ? widget.schoolClass.name[0].toUpperCase()
                      : 'C',
                  style: const TextStyle(
                    color: Color(0xFF6B46C1),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.schoolClass.name,
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
                '${widget.schoolClass.grade} • ${widget.schoolClass.section}',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'ACTIVE',
                  style: TextStyle(
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
                icon: Icons.info_outline,
                selectedIcon: Icons.info,
                title: 'Overview',
                tabIndex: 0,
              ),
              _buildSidebarItem(
                icon: Icons.people_outline,
                selectedIcon: Icons.people,
                title: 'Students',
                tabIndex: 1,
              ),
              _buildSidebarItem(
                icon: Icons.book_outlined,
                selectedIcon: Icons.book,
                title: 'Subjects',
                tabIndex: 2,
              ),
              _buildSidebarItem(
                icon: Icons.assignment_outlined,
                selectedIcon: Icons.assignment,
                title: 'Activities',
                tabIndex: 3,
              ),
              _buildSidebarItem(
                icon: Icons.person_outline,
                selectedIcon: Icons.person,
                title: 'Teacher',
                tabIndex: 4,
              ),
              _buildSidebarItem(
                icon: Icons.payment_outlined,
                selectedIcon: Icons.payment,
                title: 'Payments',
                tabIndex: 5,
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
                      'Back to Classes',
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

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Class Overview',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Summary Cards
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Total Students',
                  '${_classStats['totalStudents']}',
                  Icons.people,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  'Average Attendance',
                  '${_classStats['averageAttendance']?.toStringAsFixed(1)}%',
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  'Average Grade',
                  '${_classStats['averageGrade']?.toStringAsFixed(1)}%',
                  Icons.grade,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  'Total Subjects',
                  '${_classStats['totalSubjects']}',
                  Icons.book,
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

  Widget _buildStudentsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Students List',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                'Total: ${_students.length} students',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Card(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Roll No.')),
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Gender')),
                  DataColumn(label: Text('Age')),
                  DataColumn(label: Text('Attendance')),
                  DataColumn(label: Text('Fee Status')),
                ],
                rows: _students.map((student) {
                  final feeStatus = student['pendingFees'] <= 0
                      ? 'Paid'
                      : 'Pending';
                  return DataRow(
                    cells: [
                      DataCell(Text(student['rollNumber'])),
                      DataCell(Text(student['name'])),
                      DataCell(Text(student['gender'])),
                      DataCell(Text('${student['age']}')),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: student['attendance'] >= 80
                                ? Colors.green[100]
                                : Colors.red[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${student['attendance']}%',
                            style: TextStyle(
                              color: student['attendance'] >= 80
                                  ? Colors.green[800]
                                  : Colors.red[800],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: feeStatus == 'Paid'
                                ? Colors.green[100]
                                : Colors.orange[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            feeStatus,
                            style: TextStyle(
                              color: feeStatus == 'Paid'
                                  ? Colors.green[800]
                                  : Colors.orange[800],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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

  Widget _buildSubjectsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Subjects & Progress',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
            ),
            itemCount: _subjects.length,
            itemBuilder: (context, index) {
              final subject = _subjects[index];
              final progress =
                  (subject['completedClasses'] / subject['totalClasses']) * 100;

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.book,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              subject['name'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Teacher: ${subject['teacher']}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 12),
                      Text('Progress: ${progress.toStringAsFixed(1)}%'),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: progress / 100,
                        backgroundColor: Colors.grey[300],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${subject['completedClasses']}/${subject['totalClasses']} classes',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      Text(
                        'Avg Score: ${subject['averageScore']}%',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              );
            },
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
            'Class Activities',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          ..._activities.map(
            (activity) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getActivityColor(activity['type']),
                  child: Icon(
                    _getActivityIcon(activity['type']),
                    color: Colors.white,
                  ),
                ),
                title: Text(activity['title']),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Type: ${activity['type']}'),
                    Text('Date: ${_formatDate(activity['date'])}'),
                    Text('Participants: ${activity['participants']} students'),
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

  Widget _buildTeacherTab() {
    if (_classTeacher == null) {
      return const Center(child: Text('No class teacher assigned'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Class Teacher',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: const Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _classTeacher!['name'],
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow('Email', _classTeacher!['email']),
                        _buildInfoRow('Phone', _classTeacher!['phone']),
                        _buildInfoRow(
                          'Experience',
                          _classTeacher!['experience'],
                        ),
                        _buildInfoRow(
                          'Qualification',
                          _classTeacher!['qualification'],
                        ),
                        _buildInfoRow(
                          'Subjects',
                          (_classTeacher!['subjects'] as List).join(', '),
                        ),
                      ],
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

  Widget _buildPaymentsTab() {
    final totalAmount = _paymentRecords.fold<int>(
      0,
      (sum, p) => sum + (p['totalAmount'] as int),
    );
    final paidAmount = _paymentRecords.fold<int>(
      0,
      (sum, p) => sum + (p['paidAmount'] as int),
    );
    final pendingAmount = _paymentRecords.fold<int>(
      0,
      (sum, p) => sum + (p['pendingAmount'] as int),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Report',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Payment Summary Cards
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Total Fees',
                  '₹$totalAmount',
                  Icons.account_balance_wallet,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  'Collected',
                  '₹$paidAmount',
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  'Pending',
                  '₹$pendingAmount',
                  Icons.pending,
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Payment Details Table
          Card(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Student Name')),
                  DataColumn(label: Text('Total Amount')),
                  DataColumn(label: Text('Paid Amount')),
                  DataColumn(label: Text('Pending Amount')),
                  DataColumn(label: Text('Last Payment')),
                  DataColumn(label: Text('Status')),
                ],
                rows: _paymentRecords.map((payment) {
                  return DataRow(
                    cells: [
                      DataCell(Text(payment['studentName'])),
                      DataCell(Text('₹${payment['totalAmount']}')),
                      DataCell(Text('₹${payment['paidAmount']}')),
                      DataCell(Text('₹${payment['pendingAmount']}')),
                      DataCell(Text(_formatDate(payment['lastPayment']))),
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

  Widget _buildSidebarItem({
    required IconData icon,
    required IconData selectedIcon,
    required String title,
    required int tabIndex,
    VoidCallback? onTap,
  }) {
    final isSelected = _tabController.index == tabIndex;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap:
              onTap ??
              () {
                _tabController.animateTo(tabIndex);
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
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper widgets
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: Colors.grey[600])),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildPaymentStat(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: _getActivityColor(activity['type']),
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
                  '${activity['type']} • ${_formatDate(activity['date'])}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: _getStatusColor(activity['status']),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              activity['status'],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _getActivityColor(String type) {
    switch (type) {
      case 'Assignment':
        return Colors.blue;
      case 'Test':
        return Colors.red;
      case 'Project':
        return Colors.green;
      case 'Presentation':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'Assignment':
        return Icons.assignment;
      case 'Test':
        return Icons.quiz;
      case 'Project':
        return Icons.work;
      case 'Presentation':
        return Icons.present_to_all;
      default:
        return Icons.event;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Completed':
        return Colors.green;
      case 'In Progress':
        return Colors.orange;
      case 'Pending':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
