import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_core/school_core.dart';

class SubjectProfilePage extends ConsumerStatefulWidget {
  final Subject subject;

  const SubjectProfilePage({super.key, required this.subject});

  @override
  ConsumerState<SubjectProfilePage> createState() => _SubjectProfilePageState();
}

class _SubjectProfilePageState extends ConsumerState<SubjectProfilePage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _selectedSidebarIndex = 0;

  // Mock data - replace with actual data fetching
  late Map<String, dynamic> _subjectData;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _initializeMockData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _initializeMockData() {
    _subjectData = {
      'overview': {
        'totalTeachers': 3,
        'totalClasses': 8,
        'totalStudents': 240,
        'averageGrade': 'B+',
        'passRate': '92%',
        'curriculum': 'Cambridge IGCSE',
        'department': 'Science',
        'credits': 4,
      },
      'teachers': [
        {
          'id': '1',
          'name': 'Dr. Sarah Johnson',
          'email': 'sarah.johnson@school.edu',
          'qualification': 'Ph.D. Mathematics',
          'experience': '12 years',
          'classes': ['Grade 10A', 'Grade 11B', 'Grade 12A'],
          'isHeadOfDepartment': true,
        },
        {
          'id': '2',
          'name': 'Mr. John Smith',
          'email': 'john.smith@school.edu',
          'qualification': 'M.Sc. Mathematics',
          'experience': '8 years',
          'classes': ['Grade 9A', 'Grade 10B'],
          'isHeadOfDepartment': false,
        },
        {
          'id': '3',
          'name': 'Ms. Emily Davis',
          'email': 'emily.davis@school.edu',
          'qualification': 'M.Ed. Mathematics',
          'experience': '6 years',
          'classes': ['Grade 8A', 'Grade 9B'],
          'isHeadOfDepartment': false,
        },
      ],
      'classes': [
        {
          'name': 'Grade 8A',
          'teacher': 'Ms. Emily Davis',
          'students': 28,
          'schedule': 'Mon, Wed, Fri - 9:00 AM',
          'room': 'Room 201',
          'averageGrade': 'B',
        },
        {
          'name': 'Grade 9A',
          'teacher': 'Mr. John Smith',
          'students': 32,
          'schedule': 'Tue, Thu - 10:30 AM',
          'room': 'Room 203',
          'averageGrade': 'B+',
        },
        {
          'name': 'Grade 10A',
          'teacher': 'Dr. Sarah Johnson',
          'students': 30,
          'schedule': 'Mon, Wed, Fri - 11:00 AM',
          'room': 'Room 205',
          'averageGrade': 'A-',
        },
      ],
      'curriculum': {
        'framework': 'Cambridge IGCSE',
        'topics': [
          'Algebra and Functions',
          'Geometry and Trigonometry',
          'Statistics and Probability',
          'Calculus Basics',
          'Number Theory',
        ],
        'assessments': [
          {'type': 'Written Exam', 'weight': '70%'},
          {'type': 'Coursework', 'weight': '20%'},
          {'type': 'Practical Assessment', 'weight': '10%'},
        ],
      },
      'lessonPlans': [
        {
          'title': 'Introduction to Quadratic Equations',
          'grade': 'Grade 10',
          'duration': '45 minutes',
          'objectives': ['Understand quadratic form', 'Solve by factoring'],
          'teacher': 'Dr. Sarah Johnson',
          'date': '2024-01-15',
        },
        {
          'title': 'Trigonometric Ratios',
          'grade': 'Grade 11',
          'duration': '50 minutes',
          'objectives': ['Define sin, cos, tan', 'Apply to right triangles'],
          'teacher': 'Dr. Sarah Johnson',
          'date': '2024-01-16',
        },
      ],
      'resources': [
        {
          'title': 'Mathematics Textbook - Grade 10',
          'type': 'Textbook',
          'author': 'Cambridge University Press',
          'availability': 'Available',
        },
        {
          'title': 'Graphing Calculator Set',
          'type': 'Equipment',
          'quantity': '30 units',
          'availability': 'Available',
        },
        {
          'title': 'Interactive Whiteboard',
          'type': 'Technology',
          'location': 'All Math Classrooms',
          'availability': 'Available',
        },
      ],
      'performance': {
        'gradeDistribution': {'A': 25, 'B': 45, 'C': 20, 'D': 8, 'F': 2},
        'monthlyProgress': [
          {'month': 'Sep', 'average': 78},
          {'month': 'Oct', 'average': 82},
          {'month': 'Nov', 'average': 85},
          {'month': 'Dec', 'average': 87},
        ],
      },
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 280,
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(2, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildSidebarHeader(),
                Expanded(child: _buildSidebarMenu()),
                _buildSidebarFooter(),
              ],
            ),
          ),
          // Main Content
          Expanded(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(child: _buildMainContent()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarHeader() {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade600, Colors.blue.shade800],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white,
                child: Text(
                  widget.subject.name.substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    color: Colors.blue.shade600,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.subject.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _subjectData['overview']['department'],
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarMenu() {
    final menuItems = [
      {'icon': Icons.dashboard, 'title': 'Overview', 'index': 0},
      {'icon': Icons.people, 'title': 'Teachers', 'index': 1},
      {'icon': Icons.class_, 'title': 'Classes', 'index': 2},
      {'icon': Icons.book, 'title': 'Curriculum', 'index': 3},
      {'icon': Icons.assignment, 'title': 'Lesson Plans', 'index': 4},
      {'icon': Icons.library_books, 'title': 'Resources', 'index': 5},
      {'icon': Icons.analytics, 'title': 'Performance', 'index': 6},
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final item = menuItems[index];
        final isSelected = _selectedSidebarIndex == item['index'];

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          child: ListTile(
            leading: Icon(
              item['icon'] as IconData,
              color: isSelected ? Colors.blue.shade600 : Colors.grey.shade600,
            ),
            title: Text(
              item['title'] as String,
              style: TextStyle(
                color: isSelected ? Colors.blue.shade600 : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            selected: isSelected,
            selectedTileColor: Colors.blue.shade50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            onTap: () {
              setState(() {
                _selectedSidebarIndex = item['index'] as int;
              });
            },
          ),
        );
      },
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey, width: 0.2)),
      ),
      child: Row(
        children: [
          Text(
            _getPageTitle(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.print),
            tooltip: 'Print Report',
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, size: 18),
          label: const Text('Back to Subjects'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade100,
            foregroundColor: Colors.grey.shade700,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }

  String _getPageTitle() {
    switch (_selectedSidebarIndex) {
      case 0:
        return '${widget.subject.name} - Overview';
      case 1:
        return '${widget.subject.name} - Teachers';
      case 2:
        return '${widget.subject.name} - Classes';
      case 3:
        return '${widget.subject.name} - Curriculum';
      case 4:
        return '${widget.subject.name} - Lesson Plans';
      case 5:
        return '${widget.subject.name} - Resources';
      case 6:
        return '${widget.subject.name} - Performance';
      default:
        return widget.subject.name;
    }
  }

  Widget _buildMainContent() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: _getContentForIndex(_selectedSidebarIndex),
    );
  }

  Widget _getContentForIndex(int index) {
    switch (index) {
      case 0:
        return _buildOverviewTab();
      case 1:
        return _buildTeachersTab();
      case 2:
        return _buildClassesTab();
      case 3:
        return _buildCurriculumTab();
      case 4:
        return _buildLessonPlansTab();
      case 5:
        return _buildResourcesTab();
      case 6:
        return _buildPerformanceTab();
      default:
        return _buildOverviewTab();
    }
  }

  Widget _buildOverviewTab() {
    final overview = _subjectData['overview'];
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Cards
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Total Teachers',
                  overview['totalTeachers'].toString(),
                  Icons.people,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  'Total Classes',
                  overview['totalClasses'].toString(),
                  Icons.class_,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  'Total Students',
                  overview['totalStudents'].toString(),
                  Icons.school,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  'Pass Rate',
                  overview['passRate'],
                  Icons.trending_up,
                  Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Subject Details
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Subject Information',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoRow(
                          'Subject Name',
                          widget.subject.name,
                        ),
                      ),
                      Expanded(
                        child: _buildInfoRow(
                          'Department',
                          overview['department'],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoRow(
                          'Curriculum',
                          overview['curriculum'],
                        ),
                      ),
                      Expanded(
                        child: _buildInfoRow(
                          'Credits',
                          overview['credits'].toString(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    'Description',
                    widget.subject.description ?? 'No description available',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeachersTab() {
    final teachers = _subjectData['teachers'] as List;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Assigned Teachers',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...teachers.map(
            (teacher) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.blue.shade100,
                      child: Text(
                        teacher['name'].split(' ').map((n) => n[0]).join(),
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                teacher['name'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (teacher['isHeadOfDepartment'])
                                Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'HOD',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.amber,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          Text(
                            teacher['email'],
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${teacher['qualification']} • ${teacher['experience']}',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${teacher['classes'].length} Classes',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 4,
                          children: (teacher['classes'] as List<String>)
                              .take(2)
                              .map(
                                (className) => Chip(
                                  label: Text(
                                    className,
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              )
                              .toList(),
                        ),
                      ],
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

  Widget _buildClassesTab() {
    final classes = _subjectData['classes'] as List;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Classes Taking This Subject',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...classes.map(
            (classData) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.class_, color: Colors.green.shade700),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            classData['name'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Teacher: ${classData['teacher']}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'Room: ${classData['room']}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${classData['students']} Students',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Avg: ${classData['averageGrade']}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          classData['schedule'],
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 11,
                          ),
                        ),
                      ],
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

  Widget _buildCurriculumTab() {
    final curriculum = _subjectData['curriculum'];
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Curriculum Details',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('Framework', curriculum['framework']),
                  const SizedBox(height: 20),
                  const Text(
                    'Topics Covered',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ...((curriculum['topics'] as List<String>).map(
                    (topic) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green.shade600,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(topic),
                        ],
                      ),
                    ),
                  )),
                  const SizedBox(height: 20),
                  const Text(
                    'Assessment Structure',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ...((curriculum['assessments'] as List).map(
                    (assessment) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(assessment['type']),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              assessment['weight'],
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonPlansTab() {
    final lessonPlans = _subjectData['lessonPlans'] as List;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Lesson Plans',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...lessonPlans.map(
            (plan) => Card(
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
                            plan['title'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            plan['grade'],
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.person,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          plan['teacher'],
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          plan['duration'],
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          plan['date'],
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Learning Objectives:',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    ...((plan['objectives'] as List<String>).map(
                      (objective) => Padding(
                        padding: const EdgeInsets.only(left: 16, bottom: 2),
                        child: Row(
                          children: [
                            Icon(
                              Icons.arrow_right,
                              size: 16,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Expanded(child: Text(objective)),
                          ],
                        ),
                      ),
                    )),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourcesTab() {
    final resources = _subjectData['resources'] as List;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Learning Resources',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...resources.map(
            (resource) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: _getResourceColor(
                          resource['type'],
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getResourceIcon(resource['type']),
                        color: _getResourceColor(resource['type']),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            resource['title'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            resource['type'],
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                          if (resource['author'] != null)
                            Text(
                              'By: ${resource['author']}',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          if (resource['quantity'] != null)
                            Text(
                              'Quantity: ${resource['quantity']}',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          if (resource['location'] != null)
                            Text(
                              'Location: ${resource['location']}',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        resource['availability'],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w500,
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

  Widget _buildPerformanceTab() {
    final performance = _subjectData['performance'];
    final gradeDistribution =
        performance['gradeDistribution'] as Map<String, int>;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Performance Analytics',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Grade Distribution',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...gradeDistribution.entries.map(
                          (entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: _getGradeColor(entry.key),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Center(
                                    child: Text(
                                      entry.key,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text('${entry.value} students'),
                                ),
                                Text(
                                  '${((entry.value / gradeDistribution.values.reduce((a, b) => a + b)) * 100).toStringAsFixed(1)}%',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
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
              const SizedBox(width: 16),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Monthly Progress',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...((performance['monthlyProgress'] as List).map(
                          (month) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                Text(
                                  month['month'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: LinearProgressIndicator(
                                    value: month['average'] / 100,
                                    backgroundColor: Colors.grey.shade300,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.blue.shade600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${month['average']}%',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )),
                      ],
                    ),
                  ),
                ),
              ),
            ],
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
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
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

  IconData _getResourceIcon(String type) {
    switch (type.toLowerCase()) {
      case 'textbook':
        return Icons.book;
      case 'equipment':
        return Icons.build;
      case 'technology':
        return Icons.computer;
      default:
        return Icons.library_books;
    }
  }

  Color _getResourceColor(String type) {
    switch (type.toLowerCase()) {
      case 'textbook':
        return Colors.blue;
      case 'equipment':
        return Colors.orange;
      case 'technology':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'A':
        return Colors.green;
      case 'B':
        return Colors.blue;
      case 'C':
        return Colors.orange;
      case 'D':
        return Colors.red;
      case 'F':
        return Colors.red.shade800;
      default:
        return Colors.grey;
    }
  }
}
