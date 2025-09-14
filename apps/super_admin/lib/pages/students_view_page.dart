import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_core/school_core.dart';
import 'student_profile_page.dart';

class StudentsViewPage extends ConsumerStatefulWidget {
  const StudentsViewPage({super.key});

  @override
  ConsumerState<StudentsViewPage> createState() => _StudentsViewPageState();
}

class _StudentsViewPageState extends ConsumerState<StudentsViewPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedSchool;
  String? _selectedClass;
  List<Student> _students = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _currentPage = 1;
  final int _itemsPerPage = 15;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadStudents() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Fetch students from local database
      final students = await SQLiteDatabaseService.getAllStudents();

      setState(() {
        _students = students;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load students: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  List<Student> get _filteredStudents {
    var filtered = _students.where((student) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          student.firstName.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          student.lastName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          student.studentId.toLowerCase().contains(_searchQuery.toLowerCase());

      // TODO: Add school and class filtering when data is available

      return matchesSearch;
    }).toList();

    return filtered;
  }

  List<Student> get _paginatedStudents {
    final filtered = _filteredStudents;
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, filtered.length);
    return filtered.sublist(startIndex, endIndex);
  }

  int get _totalPages {
    return (_filteredStudents.length / _itemsPerPage).ceil();
  }

  void _showStudentDetails(Student student) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StudentProfilePage(student: student),
      ),
    );
  }

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
                      labelText: 'Search students...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                        _currentPage = 1;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedSchool,
                    decoration: const InputDecoration(
                      labelText: 'Filter by School',
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
                        _currentPage = 1;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedClass,
                    decoration: const InputDecoration(
                      labelText: 'Filter by Class',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('All Classes'),
                      ),
                      ...List.generate(
                        10,
                        (index) => DropdownMenuItem(
                          value: 'class_$index',
                          child: Text('Class ${index + 1}'),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedClass = value;
                        _currentPage = 1;
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

  Widget _buildStudentsTable() {
    return Card(
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.all(16.0),
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
                    'Name',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Student ID',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Gender',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Age',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    'School',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: Text(
                    'Actions',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          // Table Body
          if (_paginatedStudents.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32.0),
              child: Text('No students found'),
            )
          else
            ...(_paginatedStudents.asMap().entries.map((entry) {
              final index = entry.key;
              final student = entry.value;
              final age =
                  DateTime.now().difference(student.dateOfBirth).inDays ~/ 365;

              return Container(
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
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _showStudentDetails(student),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              '${student.firstName} ${student.lastName}',
                            ),
                          ),
                          Expanded(flex: 2, child: Text(student.studentId)),
                          Expanded(
                            child: Chip(
                              label: Text(
                                student.gender.name.toUpperCase(),
                                style: const TextStyle(fontSize: 12),
                              ),
                              backgroundColor: student.gender == Gender.male
                                  ? Colors.blue.withOpacity(0.2)
                                  : Colors.pink.withOpacity(0.2),
                            ),
                          ),
                          Expanded(child: Text('$age years')),
                          Expanded(
                            child: Text(
                              'School ${(student.id.hashCode % 5) + 1}',
                            ),
                          ),
                          SizedBox(
                            width: 80,
                            child: Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            })),
          // Pagination
          if (_totalPages > 1)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Page $_currentPage of $_totalPages'),
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
              onPressed: _loadStudents,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadStudents,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Students View',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Read-only view of all students across schools',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            _buildSearchAndFilters(),
            const SizedBox(height: 16),
            _buildStudentsTable(),
          ],
        ),
      ),
    );
  }
}
