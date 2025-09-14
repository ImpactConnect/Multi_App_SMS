import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_core/school_core.dart';

class AuditLogPage extends ConsumerStatefulWidget {
  const AuditLogPage({super.key});

  @override
  ConsumerState<AuditLogPage> createState() => _AuditLogPageState();
}

class _AuditLogPageState extends ConsumerState<AuditLogPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedUser;
  String? _selectedAction;
  String? _selectedSchool;
  DateTime? _startDate;
  DateTime? _endDate;
  List<AuditLogEntry> _auditLogs = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _currentPage = 1;
  final int _itemsPerPage = 20;

  @override
  void initState() {
    super.initState();
    _loadAuditLogs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAuditLogs() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // TODO: Replace with actual service calls
      await Future.delayed(const Duration(seconds: 1));

      // Mock data for demonstration
      final actions = [
        'User Login',
        'User Logout',
        'Student Created',
        'Student Updated',
        'Student Deleted',
        'Teacher Created',
        'Teacher Updated',
        'Teacher Deleted',
        'Class Created',
        'Class Updated',
        'Payment Processed',
        'Report Generated',
        'Settings Changed',
        'Data Export',
        'Data Import',
        'Password Reset',
        'Permission Changed',
        'School Created',
        'School Updated',
        'Backup Created',
      ];

      final users = [
        'Admin User',
        'John Doe',
        'Jane Smith',
        'Mike Johnson',
        'Sarah Wilson',
      ];
      final ipAddresses = [
        '192.168.1.100',
        '10.0.0.50',
        '172.16.0.25',
        '192.168.0.200',
        '10.1.1.75',
      ];

      setState(() {
        _auditLogs = List.generate(100, (index) {
          final actionIndex = index % actions.length;
          final userIndex = index % users.length;
          final ipIndex = index % ipAddresses.length;

          return AuditLogEntry(
            id: 'audit_$index',
            userId: 'user_$userIndex',
            userName: users[userIndex],
            action: actions[actionIndex],
            resource: _getResourceForAction(actions[actionIndex]),
            resourceId: 'resource_${index % 50}',
            timestamp: DateTime.now().subtract(Duration(minutes: index * 15)),
            ipAddress: ipAddresses[ipIndex],
            userAgent:
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
            details: _getDetailsForAction(actions[actionIndex], index),
            schoolId: 'school_${index % 5}',
            schoolName: 'School ${(index % 5) + 1}',
          );
        });
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load audit logs: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  String _getResourceForAction(String action) {
    if (action.contains('Student')) return 'Student';
    if (action.contains('Teacher')) return 'Teacher';
    if (action.contains('Class')) return 'Class';
    if (action.contains('Payment')) return 'Payment';
    if (action.contains('School')) return 'School';
    if (action.contains('User')) return 'User';
    return 'System';
  }

  Map<String, dynamic> _getDetailsForAction(String action, int index) {
    switch (action) {
      case 'Student Created':
        return {
          'studentName': 'Student ${index + 1}',
          'grade': 'Grade ${(index % 12) + 1}',
        };
      case 'Payment Processed':
        return {
          'amount': (100 + (index * 25)).toDouble(),
          'method': 'Bank Transfer',
        };
      case 'Settings Changed':
        return {
          'setting': 'Notification Settings',
          'oldValue': 'Enabled',
          'newValue': 'Disabled',
        };
      case 'Data Export':
        return {
          'format': 'CSV',
          'records': index * 10,
          'fileSize': '${(index * 0.5).toStringAsFixed(1)} MB',
        };
      default:
        return {'description': 'Action performed successfully'};
    }
  }

  List<AuditLogEntry> get _filteredLogs {
    var filtered = _auditLogs.where((log) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          log.action.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          log.userName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          log.resource.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesUser =
          _selectedUser == null || log.userName == _selectedUser;
      final matchesAction =
          _selectedAction == null || log.action == _selectedAction;
      final matchesSchool =
          _selectedSchool == null || log.schoolName == _selectedSchool;

      final matchesDateRange =
          (_startDate == null || log.timestamp.isAfter(_startDate!)) &&
          (_endDate == null ||
              log.timestamp.isBefore(_endDate!.add(const Duration(days: 1))));

      return matchesSearch &&
          matchesUser &&
          matchesAction &&
          matchesSchool &&
          matchesDateRange;
    }).toList();

    // Sort by timestamp (newest first)
    filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return filtered;
  }

  List<AuditLogEntry> get _paginatedLogs {
    final filtered = _filteredLogs;
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, filtered.length);
    return filtered.sublist(startIndex, endIndex);
  }

  int get _totalPages {
    return (_filteredLogs.length / _itemsPerPage).ceil();
  }

  void _showLogDetails(AuditLogEntry log) {
    showDialog(
      context: context,
      builder: (context) => AuditLogDetailsDialog(log: log),
    );
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _currentPage = 1;
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _selectedUser = null;
      _selectedAction = null;
      _selectedSchool = null;
      _startDate = null;
      _endDate = null;
      _currentPage = 1;
    });
    _searchController.clear();
  }

  Widget _buildFiltersCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Filters',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _clearFilters,
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Search logs...',
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
                    value: _selectedUser,
                    decoration: const InputDecoration(
                      labelText: 'User',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('All Users'),
                      ),
                      ...[
                        'Admin User',
                        'John Doe',
                        'Jane Smith',
                        'Mike Johnson',
                        'Sarah Wilson',
                      ].map(
                        (user) =>
                            DropdownMenuItem(value: user, child: Text(user)),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedUser = value;
                        _currentPage = 1;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedAction,
                    decoration: const InputDecoration(
                      labelText: 'Action',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('All Actions'),
                      ),
                      ...[
                        'User Login',
                        'Student Created',
                        'Payment Processed',
                        'Settings Changed',
                        'Data Export',
                      ].map(
                        (action) => DropdownMenuItem(
                          value: action,
                          child: Text(action),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedAction = value;
                        _currentPage = 1;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
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
                          value: 'School ${index + 1}',
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
                  child: OutlinedButton.icon(
                    onPressed: _selectDateRange,
                    icon: const Icon(Icons.date_range),
                    label: Text(
                      _startDate != null && _endDate != null
                          ? '${_startDate!.day}/${_startDate!.month} - ${_endDate!.day}/${_endDate!.month}'
                          : 'Select Date Range',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(child: Container()), // Spacer
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuditLogsTable() {
    if (_paginatedLogs.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Center(child: Text('No audit logs found')),
        ),
      );
    }

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
                    'Timestamp',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'User',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Action',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Resource',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    'School',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    'IP Address',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: Text(
                    'Details',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          // Table Body
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _paginatedLogs.length,
            itemBuilder: (context, index) {
              final log = _paginatedLogs[index];

              return Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade200, width: 1),
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
                            '${log.timestamp.day}/${log.timestamp.month}/${log.timestamp.year}',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            '${log.timestamp.hour.toString().padLeft(2, '0')}:${log.timestamp.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            log.userName,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            log.userId,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getActionColor(log.action).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getActionColor(log.action).withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          log.action,
                          style: TextStyle(
                            color: _getActionColor(log.action),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        log.resource,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        log.schoolName,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        log.ipAddress,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 80,
                      child: IconButton(
                        onPressed: () => _showLogDetails(log),
                        icon: const Icon(Icons.visibility),
                        tooltip: 'View Details',
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          // Pagination
          if (_totalPages > 1)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Page $_currentPage of $_totalPages (${_filteredLogs.length} total entries)',
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

  Color _getActionColor(String action) {
    if (action.contains('Login') || action.contains('Created'))
      return Colors.green;
    if (action.contains('Updated') || action.contains('Changed'))
      return Colors.blue;
    if (action.contains('Deleted')) return Colors.red;
    if (action.contains('Export') || action.contains('Import'))
      return Colors.purple;
    return Colors.grey;
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
              onPressed: _loadAuditLogs,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAuditLogs,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Audit Log',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Comprehensive tracking of all system actions and user activities',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            _buildFiltersCard(),
            const SizedBox(height: 16),
            _buildAuditLogsTable(),
          ],
        ),
      ),
    );
  }
}

class AuditLogEntry {
  final String id;
  final String userId;
  final String userName;
  final String action;
  final String resource;
  final String resourceId;
  final DateTime timestamp;
  final String ipAddress;
  final String userAgent;
  final Map<String, dynamic> details;
  final String schoolId;
  final String schoolName;

  AuditLogEntry({
    required this.id,
    required this.userId,
    required this.userName,
    required this.action,
    required this.resource,
    required this.resourceId,
    required this.timestamp,
    required this.ipAddress,
    required this.userAgent,
    required this.details,
    required this.schoolId,
    required this.schoolName,
  });
}

class AuditLogDetailsDialog extends StatelessWidget {
  final AuditLogEntry log;

  const AuditLogDetailsDialog({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Audit Log Details'),
      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Log ID', log.id),
            _buildDetailRow(
              'Timestamp',
              '${log.timestamp.day}/${log.timestamp.month}/${log.timestamp.year} ${log.timestamp.hour.toString().padLeft(2, '0')}:${log.timestamp.minute.toString().padLeft(2, '0')}:${log.timestamp.second.toString().padLeft(2, '0')}',
            ),
            _buildDetailRow('User', '${log.userName} (${log.userId})'),
            _buildDetailRow('Action', log.action),
            _buildDetailRow('Resource', '${log.resource} (${log.resourceId})'),
            _buildDetailRow('School', log.schoolName),
            _buildDetailRow('IP Address', log.ipAddress),
            _buildDetailRow('User Agent', log.userAgent),
            const SizedBox(height: 16),
            const Text(
              'Additional Details:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: log.details.entries
                    .map(
                      (entry) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          '${entry.key}: ${entry.value}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    )
                    .toList(),
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
}
