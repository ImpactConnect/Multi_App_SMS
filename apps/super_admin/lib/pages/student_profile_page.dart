import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_core/school_core.dart';

class StudentProfilePage extends ConsumerStatefulWidget {
  final Student student;

  const StudentProfilePage({super.key, required this.student});

  @override
  ConsumerState<StudentProfilePage> createState() => _StudentProfilePageState();
}

class _StudentProfilePageState extends ConsumerState<StudentProfilePage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  String? _errorMessage;

  // Mock data - replace with actual service calls
  List<Map<String, dynamic>> _academicRecords = [];
  List<Map<String, dynamic>> _paymentRecords = [];
  List<Map<String, dynamic>> _parentInfo = [];
  Map<String, dynamic>? _attendanceData;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadStudentData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadStudentData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // TODO: Replace with actual service calls
      await Future.delayed(const Duration(seconds: 1));

      // Mock academic records
      _academicRecords = List.generate(
        6,
        (index) => {
          'subject': [
            'Mathematics',
            'English',
            'Science',
            'History',
            'Geography',
            'Art',
          ][index],
          'grade': ['A', 'B+', 'A-', 'B', 'A', 'B+'][index],
          'score': [95, 87, 92, 83, 96, 89][index],
          'term': 'Term ${(index % 3) + 1}',
          'year': '2024',
          'teacher': 'Teacher ${index + 1}',
        },
      );

      // Mock payment records
      _paymentRecords = List.generate(
        4,
        (index) => {
          'description': [
            'Tuition Fee',
            'Library Fee',
            'Sports Fee',
            'Exam Fee',
          ][index],
          'amount': [5000, 500, 300, 200][index],
          'dueDate': DateTime.now().add(Duration(days: (index + 1) * 30)),
          'paidDate': index < 2
              ? DateTime.now().subtract(Duration(days: index * 15))
              : null,
          'status': index < 2 ? 'Paid' : 'Pending',
        },
      );

      // Mock parent info
      _parentInfo = [
        {
          'name': 'John Doe',
          'relationship': 'Father',
          'phone': '+1234567890',
          'email': 'john.doe@email.com',
          'occupation': 'Engineer',
          'address': widget.student.address,
        },
        {
          'name': 'Jane Doe',
          'relationship': 'Mother',
          'phone': '+1234567891',
          'email': 'jane.doe@email.com',
          'occupation': 'Teacher',
          'address': widget.student.address,
        },
      ];

      // Mock attendance data
      _attendanceData = {
        'totalDays': 180,
        'presentDays': 165,
        'absentDays': 15,
        'attendanceRate': 91.7,
        'recentAttendance': List.generate(
          10,
          (index) => {
            'date': DateTime.now().subtract(Duration(days: index)),
            'status': index % 7 == 0 ? 'Absent' : 'Present',
          },
        ),
      };

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load student data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 280,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(1, 0),
                ),
              ],
            ),
            child: _buildSidebar(context),
          ),
          // Main Content
          Expanded(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _errorMessage != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _errorMessage!,
                                style: TextStyle(color: Colors.grey[600]),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadStudentData,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : AnimatedBuilder(
                          animation: _tabController,
                          builder: (context, child) {
                            switch (_tabController.index) {
                              case 0:
                                return _buildBioTab();
                              case 1:
                                return _buildParentTab();
                              case 2:
                                return _buildAcademicTab();
                              case 3:
                                return _buildPaymentTab();
                              case 4:
                                return _buildAttendanceTab();
                              default:
                                return _buildBioTab();
                            }
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Column(
      children: [
        // Student Header
        Container(
          height: 200,
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
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white,
                backgroundImage: widget.student.profileImageUrl != null
                    ? NetworkImage(widget.student.profileImageUrl!)
                    : null,
                child: widget.student.profileImageUrl == null
                    ? Text(
                        widget.student.firstName.isNotEmpty
                            ? widget.student.firstName[0].toUpperCase()
                            : 'S',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: 12),
              Text(
                '${widget.student.firstName} ${widget.student.lastName}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                widget.student.studentId,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: widget.student.isActive
                      ? Colors.green.withOpacity(0.8)
                      : Colors.red.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.student.isActive ? 'ACTIVE' : 'INACTIVE',
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
                icon: Icons.person_outline,
                selectedIcon: Icons.person,
                title: 'Bio & Details',
                tabIndex: 0,
              ),
              _buildSidebarItem(
                icon: Icons.family_restroom_outlined,
                selectedIcon: Icons.family_restroom,
                title: 'Parent Info',
                tabIndex: 1,
              ),
              _buildSidebarItem(
                icon: Icons.school_outlined,
                selectedIcon: Icons.school,
                title: 'Academic Records',
                tabIndex: 2,
              ),
              _buildSidebarItem(
                icon: Icons.payment_outlined,
                selectedIcon: Icons.payment,
                title: 'Payment Records',
                tabIndex: 3,
              ),
              _buildSidebarItem(
                icon: Icons.calendar_today_outlined,
                selectedIcon: Icons.calendar_today,
                title: 'Attendance',
                tabIndex: 4,
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
                      'Back to Students',
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
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
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

  Widget _buildTopBar() {
    final age =
        DateTime.now().difference(widget.student.dateOfBirth).inDays ~/ 365;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.student.firstName} ${widget.student.lastName}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: widget.student.gender == Gender.male
                            ? Colors.blue.withOpacity(0.1)
                            : Colors.pink.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        widget.student.gender.name.toUpperCase(),
                        style: TextStyle(
                          color: widget.student.gender == Gender.male
                              ? Colors.blue
                              : Colors.pink,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$age years old',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Class ${(widget.student.id.hashCode % 10) + 1} • School ${(widget.student.id.hashCode % 5) + 1}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              // TODO: Implement actions
              switch (value) {
                case 'edit':
                  // Edit student
                  break;
                case 'export':
                  // Export student data
                  break;
                case 'print':
                  // Print student profile
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 18),
                    SizedBox(width: 8),
                    Text('Edit Student'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download, size: 18),
                    SizedBox(width: 8),
                    Text('Export Data'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'print',
                child: Row(
                  children: [
                    Icon(Icons.print, size: 18),
                    SizedBox(width: 8),
                    Text('Print Profile'),
                  ],
                ),
              ),
            ],
            child: const Icon(Icons.more_vert),
          ),
        ],
      ),
    );
  }

  Widget _buildBioTab() {
    final age =
        DateTime.now().difference(widget.student.dateOfBirth).inDays ~/ 365;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard(
            title: 'Personal Information',
            icon: Icons.person,
            children: [
              _buildInfoRow(
                'Full Name',
                '${widget.student.firstName} ${widget.student.lastName}',
              ),
              _buildInfoRow('Student ID', widget.student.studentId),
              _buildInfoRow(
                'Date of Birth',
                _formatDate(widget.student.dateOfBirth),
              ),
              _buildInfoRow('Age', '$age years'),
              _buildInfoRow('Gender', widget.student.gender.name.toUpperCase()),
              _buildInfoRow('Address', widget.student.address),
              _buildInfoRow(
                'Admission Date',
                _formatDate(widget.student.admissionDate),
              ),
              _buildInfoRow(
                'Status',
                widget.student.isActive ? 'Active' : 'Inactive',
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSectionCard(
            title: 'Academic Information',
            icon: Icons.school,
            children: [
              _buildInfoRow(
                'School',
                'School ${(widget.student.id.hashCode % 5) + 1}',
              ),
              _buildInfoRow(
                'Class',
                'Class ${(widget.student.id.hashCode % 10) + 1}',
              ),
              _buildInfoRow(
                'Section',
                'Section ${String.fromCharCode(65 + (widget.student.id.hashCode % 3))}',
              ),
              _buildInfoRow(
                'Roll Number',
                '${(widget.student.id.hashCode % 50) + 1}',
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSectionCard(
            title: 'Emergency Information',
            icon: Icons.emergency,
            children: [
              _buildInfoRow(
                'Emergency Contact',
                widget.student.emergencyContact ?? 'Not provided',
              ),
              _buildInfoRow(
                'Medical Information',
                widget.student.medicalInfo ?? 'None',
              ),
              _buildInfoRow('Blood Group', 'O+'), // Mock data
              _buildInfoRow('Allergies', 'None'), // Mock data
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildParentTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Parent/Guardian Information',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          ..._parentInfo.map(
            (parent) => Column(
              children: [
                _buildSectionCard(
                  title: parent['name'],
                  icon: Icons.person,
                  children: [
                    _buildInfoRow('Relationship', parent['relationship']),
                    _buildInfoRow('Phone', parent['phone']),
                    _buildInfoRow('Email', parent['email']),
                    _buildInfoRow('Occupation', parent['occupation']),
                    _buildInfoRow('Address', parent['address']),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcademicTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Academic Records',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Card(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Subject',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Grade',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Score',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Term',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Teacher',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                ..._academicRecords.asMap().entries.map((entry) {
                  final index = entry.key;
                  final record = entry.value;
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Theme.of(context).dividerColor,
                          width: 0.5,
                        ),
                      ),
                      color: index.isEven
                          ? null
                          : Theme.of(
                              context,
                            ).colorScheme.surfaceVariant.withOpacity(0.3),
                    ),
                    child: Row(
                      children: [
                        Expanded(flex: 2, child: Text(record['subject'])),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getGradeColor(
                                record['grade'],
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              record['grade'],
                              style: TextStyle(
                                color: _getGradeColor(record['grade']),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Expanded(child: Text('${record['score']}%')),
                        Expanded(child: Text(record['term'])),
                        Expanded(child: Text(record['teacher'])),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Records',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          // Payment Summary
          Row(
            children: [
              Expanded(
                child: _buildPaymentSummaryCard(
                  'Total Paid',
                  '\$${_paymentRecords.where((p) => p['status'] == 'Paid').fold<int>(0, (sum, p) => sum + (p['amount'] as int))}',
                  Colors.green,
                  Icons.check_circle,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildPaymentSummaryCard(
                  'Total Pending',
                  '\$${_paymentRecords.where((p) => p['status'] == 'Pending').fold<int>(0, (sum, p) => sum + (p['amount'] as int))}',
                  Colors.orange,
                  Icons.pending,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Payment Records Table
          Card(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Description',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Amount',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Due Date',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Status',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                ..._paymentRecords.asMap().entries.map((entry) {
                  final index = entry.key;
                  final record = entry.value;
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Theme.of(context).dividerColor,
                          width: 0.5,
                        ),
                      ),
                      color: index.isEven
                          ? null
                          : Theme.of(
                              context,
                            ).colorScheme.surfaceVariant.withOpacity(0.3),
                    ),
                    child: Row(
                      children: [
                        Expanded(flex: 2, child: Text(record['description'])),
                        Expanded(child: Text('\$${record['amount']}')),
                        Expanded(child: Text(_formatDate(record['dueDate']))),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: record['status'] == 'Paid'
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              record['status'],
                              style: TextStyle(
                                color: record['status'] == 'Paid'
                                    ? Colors.green
                                    : Colors.orange,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceTab() {
    if (_attendanceData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Attendance Records',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          // Attendance Summary
          Row(
            children: [
              Expanded(
                child: _buildAttendanceSummaryCard(
                  'Total Days',
                  '${_attendanceData!['totalDays']}',
                  Colors.blue,
                  Icons.calendar_today,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildAttendanceSummaryCard(
                  'Present Days',
                  '${_attendanceData!['presentDays']}',
                  Colors.green,
                  Icons.check_circle,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildAttendanceSummaryCard(
                  'Absent Days',
                  '${_attendanceData!['absentDays']}',
                  Colors.red,
                  Icons.cancel,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildAttendanceSummaryCard(
                  'Attendance Rate',
                  '${_attendanceData!['attendanceRate']}%',
                  Colors.purple,
                  Icons.trending_up,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Recent Attendance
          Card(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Date',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Status',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                ...(_attendanceData!['recentAttendance'] as List)
                    .asMap()
                    .entries
                    .map((entry) {
                      final index = entry.key;
                      final record = entry.value;
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Theme.of(context).dividerColor,
                              width: 0.5,
                            ),
                          ),
                          color: index.isEven
                              ? null
                              : Theme.of(
                                  context,
                                ).colorScheme.surfaceVariant.withOpacity(0.3),
                        ),
                        child: Row(
                          children: [
                            Expanded(child: Text(_formatDate(record['date']))),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: record['status'] == 'Present'
                                      ? Colors.green.withOpacity(0.1)
                                      : Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  record['status'],
                                  style: TextStyle(
                                    color: record['status'] == 'Present'
                                        ? Colors.green
                                        : Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
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
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(width: 16),
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

  Widget _buildPaymentSummaryCard(
    String title,
    String amount,
    Color color,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              amount,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceSummaryCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getGradeColor(String grade) {
    switch (grade.toUpperCase()) {
      case 'A':
      case 'A+':
        return Colors.green;
      case 'A-':
      case 'B+':
        return Colors.blue;
      case 'B':
      case 'B-':
        return Colors.orange;
      case 'C+':
      case 'C':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
