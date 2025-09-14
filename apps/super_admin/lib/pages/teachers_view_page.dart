import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_core/school_core.dart';
import 'teacher_profile_page.dart';

class TeachersViewPage extends ConsumerStatefulWidget {
  const TeachersViewPage({super.key});

  @override
  ConsumerState<TeachersViewPage> createState() => _TeachersViewPageState();
}

class _TeachersViewPageState extends ConsumerState<TeachersViewPage> {
  List<Map<String, dynamic>> _teachers = [];
  List<Map<String, dynamic>> _filteredTeachers = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
  String? _selectedSubject;
  String? _selectedStatus;
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 1;
  final int _itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _loadTeachers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTeachers() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Fetch teacher users from local database
      final teacherUsers = await SQLiteDatabaseService.getUsersByRole(
        UserRole.teacher,
      );

      // Convert User objects to the expected format
      final teacherData = <Map<String, dynamic>>[];
      for (final user in teacherUsers) {
        teacherData.add({
          'id': user.id,
          'firstName': user.firstName,
          'lastName': user.lastName,
          'email': user.email,
          'phoneNumber': user.phoneNumber ?? '',
          'subjects': <String>[], // TODO: Get actual subjects from database
          'classes': <String>[], // TODO: Get actual classes from database
          'employeeId': user.accessCode ?? '',
          'department': '', // TODO: Get actual department from database
          'status': user.isActive ? 'Active' : 'Inactive',
          'joinDate': user.createdAt.toString().split(' ')[0],
          'qualification': '', // TODO: Get actual qualification from database
          'experience': '', // TODO: Get actual experience from database
          'isClassTeacher': false, // TODO: Get actual class teacher status
          'assignedClass': null, // TODO: Get actual assigned class
        });
      }

      setState(() {
        _teachers = teacherData;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load teachers: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    _filteredTeachers = _teachers.where((teacher) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          '${teacher['firstName']} ${teacher['lastName']}'
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          teacher['email'].toString().toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          teacher['employeeId'].toString().toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );

      final matchesSubject =
          _selectedSubject == null ||
          (teacher['subjects'] as List<String>).any(
            (subject) => subject == _selectedSubject,
          );

      final matchesStatus =
          _selectedStatus == null || teacher['status'] == _selectedStatus;

      return matchesSearch && matchesSubject && matchesStatus;
    }).toList();
  }

  List<Map<String, dynamic>> get _paginatedTeachers {
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;
    return _filteredTeachers.sublist(
      startIndex,
      endIndex > _filteredTeachers.length ? _filteredTeachers.length : endIndex,
    );
  }

  int get _totalPages => (_filteredTeachers.length / _itemsPerPage).ceil();

  Widget _buildSearchAndFilters() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Search teachers...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                        _currentPage = 1;
                        _applyFilters();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedSubject,
                    decoration: const InputDecoration(
                      labelText: 'Filter by Subject',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('All Subjects'),
                      ),
                      ...{
                        'Mathematics',
                        'Physics',
                        'English Literature',
                        'Creative Writing',
                        'History',
                        'Geography',
                        'Biology',
                        'Chemistry',
                      }.map(
                        (subject) => DropdownMenuItem(
                          value: subject,
                          child: Text(subject),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedSubject = value;
                        _currentPage = 1;
                        _applyFilters();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Filter by Status',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('All Status')),
                      DropdownMenuItem(value: 'Active', child: Text('Active')),
                      DropdownMenuItem(
                        value: 'On Leave',
                        child: Text('On Leave'),
                      ),
                      DropdownMenuItem(
                        value: 'Inactive',
                        child: Text('Inactive'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value;
                        _currentPage = 1;
                        _applyFilters();
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeachersTable() {
    return Card(
      child: Column(
        children: [
          // Sticky Table Header
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Name',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Employee ID',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Department',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Subjects',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Classes',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Status',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Actions',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          // Scrollable Table Body
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  if (_paginatedTeachers.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text(
                        'No teachers found',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  else
                    ...List.generate(_paginatedTeachers.length, (index) {
                      final teacher = _paginatedTeachers[index];
                      return InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  TeacherProfilePage(teacher: teacher),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.grey.shade300,
                                width: 0.5,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${teacher['firstName']} ${teacher['lastName']}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      teacher['email'],
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(teacher['employeeId']),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(teacher['department']),
                              ),
                              Expanded(
                                flex: 2,
                                child: Wrap(
                                  spacing: 4,
                                  runSpacing: 4,
                                  children:
                                      (teacher['subjects'] as List<String>)
                                          .map(
                                            (subject) => Chip(
                                              label: Text(
                                                subject,
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                ),
                                              ),
                                              materialTapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                            ),
                                          )
                                          .toList(),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ...(teacher['classes'] as List<String>).map(
                                      (className) => Text(
                                        className,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                    if (teacher['isClassTeacher'])
                                      Container(
                                        margin: const EdgeInsets.only(top: 4),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade100,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: const Text(
                                          'Class Teacher',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.blue,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: teacher['status'] == 'Active'
                                        ? Colors.green.shade100
                                        : teacher['status'] == 'On Leave'
                                        ? Colors.orange.shade100
                                        : Colors.red.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    teacher['status'],
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: teacher['status'] == 'Active'
                                          ? Colors.green.shade700
                                          : teacher['status'] == 'On Leave'
                                          ? Colors.orange.shade700
                                          : Colors.red.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: PopupMenuButton(
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'view',
                                      child: Row(
                                        children: [
                                          Icon(Icons.visibility),
                                          SizedBox(width: 8),
                                          Text('View Details'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'activities',
                                      child: Row(
                                        children: [
                                          Icon(Icons.assignment),
                                          SizedBox(width: 8),
                                          Text('View Activities'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'schedule',
                                      child: Row(
                                        children: [
                                          Icon(Icons.schedule),
                                          SizedBox(width: 8),
                                          Text('View Schedule'),
                                        ],
                                      ),
                                    ),
                                  ],
                                  onSelected: (value) {
                                    _handleTeacherAction(
                                      value.toString(),
                                      teacher,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleTeacherAction(String action, Map<String, dynamic> teacher) {
    switch (action) {
      case 'view':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => TeacherProfilePage(teacher: teacher),
          ),
        );
        break;
      case 'activities':
        _showTeacherActivities(teacher);
        break;
      case 'schedule':
        _showTeacherSchedule(teacher);
        break;
    }
  }

  void _showTeacherDetails(Map<String, dynamic> teacher) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${teacher['firstName']} ${teacher['lastName']}'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Employee ID', teacher['employeeId']),
              _buildDetailRow('Email', teacher['email']),
              _buildDetailRow('Phone', teacher['phoneNumber']),
              _buildDetailRow('Department', teacher['department']),
              _buildDetailRow('Qualification', teacher['qualification']),
              _buildDetailRow('Experience', teacher['experience']),
              _buildDetailRow('Join Date', teacher['joinDate']),
              _buildDetailRow('Status', teacher['status']),
              if (teacher['isClassTeacher'])
                _buildDetailRow('Assigned Class', teacher['assignedClass']),
              const SizedBox(height: 8),
              const Text(
                'Subjects:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Wrap(
                spacing: 4,
                children: (teacher['subjects'] as List<String>)
                    .map((subject) => Chip(label: Text(subject)))
                    .toList(),
              ),
              const SizedBox(height: 8),
              const Text(
                'Classes:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Wrap(
                spacing: 4,
                children: (teacher['classes'] as List<String>)
                    .map((className) => Chip(label: Text(className)))
                    .toList(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTeacherActivities(Map<String, dynamic> teacher) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '${teacher['firstName']} ${teacher['lastName']} - Activities',
        ),
        content: SizedBox(
          width: 500,
          height: 400,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Recent Activities:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    _buildActivityItem(
                      'Submitted lesson plan for Mathematics Grade 10A',
                      '2 hours ago',
                      Icons.assignment_turned_in,
                      Colors.green,
                    ),
                    _buildActivityItem(
                      'Conducted parent-teacher meeting',
                      '1 day ago',
                      Icons.people,
                      Colors.blue,
                    ),
                    _buildActivityItem(
                      'Updated student grades for Physics',
                      '2 days ago',
                      Icons.grade,
                      Colors.orange,
                    ),
                    _buildActivityItem(
                      'Attended faculty meeting',
                      '3 days ago',
                      Icons.meeting_room,
                      Colors.purple,
                    ),
                    _buildActivityItem(
                      'Submitted monthly report',
                      '1 week ago',
                      Icons.report,
                      Colors.teal,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTeacherSchedule(Map<String, dynamic> teacher) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '${teacher['firstName']} ${teacher['lastName']} - Schedule',
        ),
        content: SizedBox(
          width: 600,
          height: 400,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Weekly Schedule:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Table(
                    border: TableBorder.all(color: Colors.grey.shade300),
                    columnWidths: const {
                      0: FlexColumnWidth(1),
                      1: FlexColumnWidth(2),
                      2: FlexColumnWidth(2),
                      3: FlexColumnWidth(2),
                      4: FlexColumnWidth(2),
                      5: FlexColumnWidth(2),
                    },
                    children: [
                      TableRow(
                        decoration: BoxDecoration(color: Colors.grey.shade100),
                        children: const [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Time',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Monday',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Tuesday',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Wednesday',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Thursday',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Friday',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      ...[
                        [
                          '8:00-9:00',
                          'Math 10A',
                          'Physics 11B',
                          'Math 10A',
                          'Physics 11B',
                          'Free',
                        ],
                        [
                          '9:00-10:00',
                          'Physics 11B',
                          'Math 10A',
                          'Physics 11B',
                          'Math 10A',
                          'Faculty Meeting',
                        ],
                        [
                          '10:00-11:00',
                          'Break',
                          'Break',
                          'Break',
                          'Break',
                          'Break',
                        ],
                        [
                          '11:00-12:00',
                          'Math 10A',
                          'Physics 11B',
                          'Math 10A',
                          'Physics 11B',
                          'Math 10A',
                        ],
                        [
                          '12:00-1:00',
                          'Lunch',
                          'Lunch',
                          'Lunch',
                          'Lunch',
                          'Lunch',
                        ],
                        [
                          '1:00-2:00',
                          'Physics 11B',
                          'Math 10A',
                          'Physics 11B',
                          'Math 10A',
                          'Physics 11B',
                        ],
                        [
                          '2:00-3:00',
                          'Free',
                          'Free',
                          'Parent Meeting',
                          'Free',
                          'Free',
                        ],
                      ].map(
                        (row) => TableRow(
                          children: row
                              .map(
                                (cell) => Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    cell,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
    String activity,
    String time,
    IconData icon,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(activity, style: const TextStyle(fontSize: 14)),
        subtitle: Text(
          time,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        dense: true,
      ),
    );
  }

  Widget _buildPagination() {
    if (_totalPages <= 1) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Showing ${(_currentPage - 1) * _itemsPerPage + 1}-${_currentPage * _itemsPerPage > _filteredTeachers.length ? _filteredTeachers.length : _currentPage * _itemsPerPage} of ${_filteredTeachers.length} teachers',
            ),
            Row(
              children: [
                IconButton(
                  onPressed: _currentPage > 1
                      ? () {
                          setState(() {
                            _currentPage--;
                          });
                        }
                      : null,
                  icon: const Icon(Icons.chevron_left),
                ),
                Text('Page $_currentPage of $_totalPages'),
                IconButton(
                  onPressed: _currentPage < _totalPages
                      ? () {
                          setState(() {
                            _currentPage++;
                          });
                        }
                      : null,
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
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
              onPressed: _loadTeachers,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTeachers,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Teachers Management',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'View and manage teacher information, activities, and schedules',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            _buildSearchAndFilters(),
            const SizedBox(height: 16),
            Expanded(child: _buildTeachersTable()),
            const SizedBox(height: 16),
            _buildPagination(),
          ],
        ),
      ),
    );
  }
}
