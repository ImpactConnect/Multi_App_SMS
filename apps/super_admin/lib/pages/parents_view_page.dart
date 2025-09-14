import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_core/school_core.dart';
import 'parent_profile_page.dart';

class ParentsViewPage extends ConsumerStatefulWidget {
  const ParentsViewPage({super.key});

  @override
  ConsumerState<ParentsViewPage> createState() => _ParentsViewPageState();
}

class _ParentsViewPageState extends ConsumerState<ParentsViewPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedSchool;
  List<Map<String, dynamic>> _parents = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _currentPage = 1;
  final int _itemsPerPage = 15;

  @override
  void initState() {
    super.initState();
    _loadParents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadParents() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Fetch parent users from local database
      final parentUsers = await SQLiteDatabaseService.getUsersByRole(
        UserRole.parent,
      );
      
      // Debug: Print all users and their roles
      final allUsers = await SQLiteDatabaseService.getAllUsers();
      print('🔍 DEBUG: Total users in database: ${allUsers.length}');
      for (final user in allUsers) {
        print('🔍 DEBUG: User ${user.firstName} ${user.lastName} (${user.email}) - Role: ${user.role}');
      }
      print('🔍 DEBUG: Found ${parentUsers.length} parent users');
      for (final parent in parentUsers) {
        print('🔍 DEBUG: Parent: ${parent.firstName} ${parent.lastName} (${parent.email}) - Role: ${parent.role}');
      }

      // Convert User objects to the expected format
      final parentData = <Map<String, dynamic>>[];
      for (final user in parentUsers) {
        // Get children for this parent
        final allStudents = await SQLiteDatabaseService.getAllStudents();
        final children = allStudents
            .where((Student student) => student.parentIds.contains(user.id))
            .map(
              (Student student) => {
                'id': student.id,
                'name': '${student.firstName} ${student.lastName}',
                'class': student.classId, // TODO: Get actual class name
                'school': student.schoolId, // TODO: Get actual school name
              },
            )
            .toList();

        parentData.add({
          'id': user.id,
          'firstName': user.firstName,
          'lastName': user.lastName,
          'email': user.email,
          'phone': user.phoneNumber ?? '',
          'children': children,
          'createdAt': user.createdAt,
        });
      }

      setState(() {
        _parents = parentData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load parents: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredParents {
    var filtered = _parents.where((Map<String, dynamic> parent) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          (parent['firstName'] as String).toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          (parent['lastName'] as String).toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          (parent['email'] as String).toLowerCase().contains(_searchQuery.toLowerCase());

      return matchesSearch;
    }).toList();

    return filtered;
  }

  List<Map<String, dynamic>> get _paginatedParents {
    final filtered = _filteredParents;
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, filtered.length);
    return filtered.sublist(startIndex, endIndex);
  }

  int get _totalPages {
    return (_filteredParents.length / _itemsPerPage).ceil();
  }

  void _showParentDetails(Map<String, dynamic> parent) {
    showDialog(
      context: context,
      builder: (context) => ParentDetailsDialog(parent: parent),
    );
  }

  Widget _buildSearchAndFilters() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Search parents...',
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
          ],
        ),
      ),
    );
  }

  Widget _buildParentsTable() {
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
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
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
                    'Email',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Phone',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Children',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Joined',
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
          // Scrollable Table Body
          SizedBox(
            height: 400, // Fixed height for scrollable area
            child: _paginatedParents.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text('No parents found'),
                    ),
                  )
                : ListView.builder(
                    itemCount: _paginatedParents.length,
                    itemBuilder: (context, index) {
                      final parent = _paginatedParents[index];
                      final children =
                          parent['children'] as List<Map<String, dynamic>>;

                      return InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  ParentProfilePage(parent: parent),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16.0),
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
                              Expanded(
                                flex: 2,
                                child: Text(
                                  '${parent['firstName']} ${parent['lastName']}',
                                ),
                              ),
                              Expanded(flex: 2, child: Text(parent['email'])),
                              Expanded(child: Text(parent['phone'])),
                              Expanded(
                                child: Text(
                                  '${children.length} child${children.length != 1 ? 'ren' : ''}',
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  '${(parent['createdAt'] as DateTime).day}/${(parent['createdAt'] as DateTime).month}/${(parent['createdAt'] as DateTime).year}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                              SizedBox(
                                width: 80,
                                child: IconButton(
                                  icon: const Icon(Icons.visibility, size: 18),
                                  onPressed: () => _showParentDetails(parent),
                                  tooltip: 'View Details',
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          // Pagination
          if (_totalPages > 1)
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).dividerColor,
                    width: 0.5,
                  ),
                ),
              ),
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

  Widget _buildMetricsSection() {
    final totalParents = _parents.length;
    final totalChildren = _parents.fold<int>(
      0,
      (sum, parent) => sum + (parent['children'] as List).length,
    );
    final activeParents = _parents
        .where((p) => true)
        .length; // All are active in mock data
    final avgChildrenPerParent = totalParents > 0
        ? (totalChildren / totalParents).toStringAsFixed(1)
        : '0';

    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            'Total Parents',
            totalParents.toString(),
            Icons.people,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            'Total Children',
            totalChildren.toString(),
            Icons.child_care,
            Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            'Active Parents',
            activeParents.toString(),
            Icons.check_circle,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            'Avg Children/Parent',
            avgChildrenPerParent,
            Icons.analytics,
            Colors.purple,
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
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 24),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 16),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontWeight: FontWeight.w500,
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
            ElevatedButton(onPressed: _loadParents, child: const Text('Retry')),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadParents,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Parents View',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'View parent accounts and their linked student relationships',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            _buildMetricsSection(),
            const SizedBox(height: 24),
            _buildSearchAndFilters(),
            const SizedBox(height: 16),
            _buildParentsTable(),
          ],
        ),
      ),
    );
  }
}

class ParentDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> parent;

  const ParentDetailsDialog({super.key, required this.parent});

  @override
  Widget build(BuildContext context) {
    final children = parent['children'] as List<Map<String, dynamic>>;

    return AlertDialog(
      title: Text('${parent['firstName']} ${parent['lastName']}'),
      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Email', parent['email']),
            _buildDetailRow('Phone', parent['phone']),
            _buildDetailRow('Parent ID', parent['id']),
            _buildDetailRow(
              'Joined',
              '${(parent['createdAt'] as DateTime).day}/${(parent['createdAt'] as DateTime).month}/${(parent['createdAt'] as DateTime).year}',
            ),
            const SizedBox(height: 16),
            const Text(
              'Children:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            ...children.map(
              (child) => Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        child['name'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text('Class: ${child['class']}'),
                      Text('School: ${child['school']}'),
                    ],
                  ),
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
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
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
}
