import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_core/school_core.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

class UserManagementPage extends ConsumerStatefulWidget {
  const UserManagementPage({super.key});

  @override
  ConsumerState<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends ConsumerState<UserManagementPage>
    with SingleTickerProviderStateMixin {
  List<User> _users = [];
  bool _isLoading = true;
  String _searchQuery = '';
  int _currentPage = 0;
  final int _itemsPerPage = 10;
  late TabController _tabController;

  final List<UserRole> _userCategories = [
    UserRole.accountant,
    UserRole.admin,
    UserRole.teacher,
    UserRole.otherStaff,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _userCategories.length, vsync: this);
    _loadUsers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // DEBUG: Check data source
      print('DEBUG: Loading users from SQLite database...');

      // Load users from local database
      // Using SQLite database service directly
      _users = await SQLiteDatabaseService.getAllUsers();

      // DEBUG: Log loaded data
      print('DEBUG: Loaded ${_users.length} users from database');
      for (int i = 0; i < _users.length && i < 5; i++) {
        print(
          'DEBUG: User $i: ${_users[i].firstName} ${_users[i].lastName} (${_users[i].email}) - Role: ${_users[i].role}',
        );
      }
      if (_users.length > 5) {
        print('DEBUG: ... and ${_users.length - 5} more users');
      }

      // No mock data creation - show empty list if no users exist
    } catch (e) {
      // Handle error
      print('DEBUG: Error loading users: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading users: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  List<User> get _filteredUsers {
    final currentRole = _userCategories[_tabController.index];
    var filtered = _users.where((user) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          user.firstName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.lastName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.username.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesRole = user.role == currentRole;

      return matchesSearch && matchesRole;
    }).toList();

    return filtered;
  }

  List<User> get _paginatedUsers {
    final startIndex = _currentPage * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(
      0,
      _filteredUsers.length,
    );
    return _filteredUsers.sublist(startIndex, endIndex);
  }

  int get _totalPages => (_filteredUsers.length / _itemsPerPage).ceil();

  Future<void> _showUserDialog({User? user}) async {
    final currentRole = _userCategories[_tabController.index];
    final result = await showDialog<User>(
      context: context,
      builder: (context) =>
          UserFormDialog(user: user, defaultRole: user?.role ?? currentRole),
    );

    if (result != null) {
      if (user == null) {
        await _createUser(result);
      } else {
        await _updateUser(result);
      }
    }
  }

  Future<void> _showUserProfile(User user) async {
    await showDialog(
      context: context,
      builder: (context) => UserProfileDialog(
        user: user,
        onEdit: () {
          Navigator.of(context).pop();
          _showUserDialog(user: user);
        },
        onResetPassword: () => _resetPassword(user),
      ),
    );
  }

  Future<String> _generateUsername(UserRole role, String? schoolId) async {
    // Get school acronym
    String schoolAcronym = 'DHS'; // Default to Demo High School
    if (schoolId != null) {
      // Using SQLite database service directly
      final schools = await SQLiteDatabaseService.getAllSchools();
      final school = schools.firstWhere(
        (s) => s.id == schoolId,
        orElse: () => School(
          id: 'default',
          name: 'Demo High School',
          address: '',
          phoneNumber: '',
          email: '',
          principalName: '',
          establishedDate: DateTime(2000),
          type: SchoolType.secondary,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      // Generate acronym from school name
      final words = school.name.split(' ');
      schoolAcronym = words
          .map((word) => word.isNotEmpty ? word[0].toUpperCase() : '')
          .join('');
      if (schoolAcronym.length > 4) {
        schoolAcronym = schoolAcronym.substring(0, 4);
      }
    }

    // Get role prefix
    String rolePrefix;
    switch (role) {
      case UserRole.admin:
        rolePrefix = 'ADMIN';
        break;
      case UserRole.teacher:
        rolePrefix = 'TEACH';
        break;
      case UserRole.accountant:
        rolePrefix = 'ACCT';
        break;
      case UserRole.otherStaff:
        rolePrefix = 'STAFF';
        break;
      default:
        rolePrefix = 'USER';
    }

    // Count existing users with same role and school to generate sequence number
    final existingCount = _users
        .where((u) => u.role == role && u.schoolId == schoolId)
        .length;
    final sequenceNumber = (existingCount + 1).toString().padLeft(3, '0');

    return '$schoolAcronym-$rolePrefix-$sequenceNumber';
  }

  String _generateRandomPassword() {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#\$%^&*';
    final random = DateTime.now().millisecondsSinceEpoch;
    var password = '';

    for (int i = 0; i < 12; i++) {
      password += chars[(random + i) % chars.length];
    }

    return password;
  }

  Future<void> _showCredentialsDialog(String username, String password) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 12),
            Text('User Created Successfully!'),
          ],
        ),
        content: Container(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Login credentials have been generated:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 20),
              _buildCredentialField('Username', username),
              const SizedBox(height: 16),
              _buildCredentialField('Password', password),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Please save these credentials securely. The password cannot be retrieved later.',
                        style: TextStyle(fontSize: 14),
                      ),
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

  Widget _buildCredentialField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey.withOpacity(0.05),
          ),
          child: Row(
            children: [
              Expanded(
                child: SelectableText(
                  value,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy, size: 20),
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: value));
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('$label copied to clipboard')),
                    );
                  }
                },
                tooltip: 'Copy $label',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _createUser(User user) async {
    try {
      // Generate username and password for new users
      final generatedUsername = await _generateUsername(
        user.role,
        user.schoolId,
      );
      final generatedPassword = _generateRandomPassword();

      // Create user with generated credentials
      final userWithCredentials = user.copyWith(
        username: generatedUsername,
        password: _hashPassword(generatedPassword),
      );

      // Save to local database using SQLiteDatabaseService
      await SQLiteDatabaseService.saveUser(userWithCredentials);

      // Initialize and save to sync service for future online sync
      final syncService = ref.read(offlineSyncServiceProvider);
      await syncService.initialize();
      await syncService.saveUserLocally(userWithCredentials);

      setState(() {
        _users.add(userWithCredentials);
      });

      // Show credentials dialog
      await _showCredentialsDialog(generatedUsername, generatedPassword);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error creating user: $e')));
    }
  }

  Future<void> _updateUser(User user) async {
    try {
      // Save to local database
      // Using SQLite database service directly
      await SQLiteDatabaseService.saveUser(user);

      // Update local list
      setState(() {
        final index = _users.indexWhere((u) => u.id == user.id);
        if (index != -1) {
          _users[index] = user;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating user: $e')));
    }
  }

  Future<void> _deleteUser(User user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text(
          'Are you sure you want to delete ${user.firstName} ${user.lastName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // Delete from local database
        // Using SQLite database service directly
        await SQLiteDatabaseService.deleteUser(user.id);

        // Update local list
        setState(() {
          _users.removeWhere((u) => u.id == user.id);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User deleted successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting user: $e')));
      }
    }
  }

  Future<void> _resetPassword(User user) async {
    final newPassword = await showDialog<String>(
      context: context,
      builder: (context) => _PasswordResetDialog(user: user),
    );

    if (newPassword != null) {
      try {
        final updatedUser = user.copyWith(password: _hashPassword(newPassword));
        await _updateUser(updatedUser);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error resetting password: $e')));
      }
    }
  }

  Widget _buildSearchAndFilters() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Search users...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                    _currentPage = 0;
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: () => _showUserDialog(),
              icon: const Icon(Icons.add),
              label: Text(
                'Add ${_userCategories[_tabController.index].name.toUpperCase()}',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersTable() {
    if (_filteredUsers.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No ${_userCategories[_tabController.index].name.toLowerCase()}s found',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Try adjusting your search or add a new user',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
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
                    'Username',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Department',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Status',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  width: 120,
                  child: Text(
                    'Actions',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          // Table Body
          ...(_paginatedUsers.asMap().entries.map((entry) {
            final index = entry.key;
            final user = entry.value;
            return InkWell(
              onTap: () => _showUserProfile(user),
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
                      child: Text('${user.firstName} ${user.lastName}'),
                    ),
                    Expanded(flex: 2, child: Text(user.email)),
                    Expanded(child: Text(user.username)),
                    Expanded(child: Text(user.department ?? 'N/A')),
                    Expanded(
                      child: Chip(
                        label: Text(
                          user.isActive ? 'Active' : 'Inactive',
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor: user.isActive
                            ? Colors.green.withOpacity(0.2)
                            : Colors.red.withOpacity(0.2),
                      ),
                    ),
                    SizedBox(
                      width: 120,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.visibility, size: 18),
                            onPressed: () => _showUserProfile(user),
                            tooltip: 'View Profile',
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, size: 18),
                            onPressed: () => _showUserDialog(user: user),
                            tooltip: 'Edit User',
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              size: 18,
                              color: Colors.red,
                            ),
                            onPressed: () => _deleteUser(user),
                            tooltip: 'Delete User',
                          ),
                        ],
                      ),
                    ),
                  ],
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
                  Text('Page ${_currentPage + 1} of $_totalPages'),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _currentPage > 0
                            ? () {
                                setState(() {
                                  _currentPage--;
                                });
                              }
                            : null,
                        icon: const Icon(Icons.chevron_left),
                      ),
                      IconButton(
                        onPressed: _currentPage < _totalPages - 1
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

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.superAdmin:
        return Colors.red.withOpacity(0.2);
      case UserRole.admin:
        return Colors.orange.withOpacity(0.2);
      case UserRole.teacher:
        return Colors.blue.withOpacity(0.2);
      case UserRole.accountant:
        return Colors.green.withOpacity(0.2);
      case UserRole.parent:
        return Colors.purple.withOpacity(0.2);
      case UserRole.otherStaff:
        return Colors.grey.withOpacity(0.2);
    }
  }

  String _getRoleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.teacher:
        return 'Teacher';
      case UserRole.accountant:
        return 'Accountant';
      case UserRole.otherStaff:
        return 'Other Staff';
      default:
        return role.name;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Text(
                  'User Management',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => _showUserDialog(),
                  icon: const Icon(Icons.add),
                  label: Text(
                    'Add ${_getRoleDisplayName(_userCategories[_tabController.index])}',
                  ),
                ),
              ],
            ),
          ),
          // Tabs
          TabBar(
            controller: _tabController,
            tabs: _userCategories
                .map((role) => Tab(text: '${_getRoleDisplayName(role)}s'))
                .toList(),
            onTap: (index) {
              setState(() {
                _currentPage = 0;
                _searchQuery = '';
              });
            },
          ),
          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _userCategories
                  .map(
                    (role) => RefreshIndicator(
                      onRefresh: _loadUsers,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            _buildSearchAndFilters(),
                            const SizedBox(height: 16),
                            _buildUsersTable(),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class UserFormDialog extends StatefulWidget {
  final User? user;
  final UserRole defaultRole;

  const UserFormDialog({super.key, this.user, required this.defaultRole});

  @override
  State<UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<UserFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentPage = 0;

  // Basic Info Controllers
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  // Username and password will be auto-generated
  // late TextEditingController _usernameController;
  // late TextEditingController _passwordController;

  // Bio Info Controllers
  late TextEditingController _addressController;
  late TextEditingController _nationalIdController;
  late TextEditingController _emergencyContactController;
  late TextEditingController _emergencyContactRelationController;
  late TextEditingController _qualificationController;
  late TextEditingController _departmentController;
  late TextEditingController _positionController;
  late TextEditingController _bloodGroupController;
  late TextEditingController _medicalInfoController;
  late TextEditingController _notesController;

  UserRole _selectedRole = UserRole.teacher;
  Gender? _selectedGender;
  DateTime? _dateOfBirth;
  DateTime? _joinDate;
  bool _isActive = true;
  String? _selectedSchoolId;
  List<School> _schools = [];

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.user?.role ?? widget.defaultRole;
    _selectedSchoolId = widget.user?.schoolId;
    _loadSchools();

    // Initialize controllers
    _firstNameController = TextEditingController(
      text: widget.user?.firstName ?? '',
    );
    _lastNameController = TextEditingController(
      text: widget.user?.lastName ?? '',
    );
    _emailController = TextEditingController(text: widget.user?.email ?? '');
    _phoneController = TextEditingController(
      text: widget.user?.phoneNumber ?? '',
    );
    // Auto-generated credentials, no need for controllers
    // _usernameController = TextEditingController(text: widget.user?.username ?? '');
    // _passwordController = TextEditingController();

    _addressController = TextEditingController(
      text: widget.user?.address ?? '',
    );
    _nationalIdController = TextEditingController(
      text: widget.user?.nationalId ?? '',
    );
    _emergencyContactController = TextEditingController(
      text: widget.user?.emergencyContact ?? '',
    );
    _emergencyContactRelationController = TextEditingController(
      text: widget.user?.emergencyContactRelation ?? '',
    );
    _qualificationController = TextEditingController(
      text: widget.user?.qualification ?? '',
    );
    _departmentController = TextEditingController(
      text: widget.user?.department ?? '',
    );
    _positionController = TextEditingController(
      text: widget.user?.position ?? '',
    );
    _bloodGroupController = TextEditingController(
      text: widget.user?.bloodGroup ?? '',
    );
    _medicalInfoController = TextEditingController(
      text: widget.user?.medicalInfo ?? '',
    );
    _notesController = TextEditingController(text: widget.user?.notes ?? '');

    _selectedGender = widget.user?.gender;
    _dateOfBirth = widget.user?.dateOfBirth;
    _joinDate = widget.user?.joinDate;
    _isActive = widget.user?.isActive ?? true;
  }

  Future<void> _loadSchools() async {
    final schools = await SQLiteDatabaseService.getAllSchools();
    setState(() {
      _schools = schools;
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    // No controllers to dispose for auto-generated credentials
    // _usernameController.dispose();
    // _passwordController.dispose();
    _addressController.dispose();
    _nationalIdController.dispose();
    _emergencyContactController.dispose();
    _emergencyContactRelationController.dispose();
    _qualificationController.dispose();
    _departmentController.dispose();
    _positionController.dispose();
    _bloodGroupController.dispose();
    _medicalInfoController.dispose();
    _notesController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      final user = User(
        id: widget.user?.id ?? const Uuid().v4(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        role: _selectedRole,
        isActive: _isActive,
        createdAt: widget.user?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        accessCode:
            widget.user?.accessCode ??
            'AC${const Uuid().v4().substring(0, 8).toUpperCase()}',
        username: widget.user?.username ?? '', // Will be set by auto-generation
        password: widget.user?.password ?? '', // Will be set by auto-generation
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        dateOfBirth: _dateOfBirth,
        gender: _selectedGender,
        nationalId: _nationalIdController.text.trim().isEmpty
            ? null
            : _nationalIdController.text.trim(),
        emergencyContact: _emergencyContactController.text.trim().isEmpty
            ? null
            : _emergencyContactController.text.trim(),
        emergencyContactRelation:
            _emergencyContactRelationController.text.trim().isEmpty
            ? null
            : _emergencyContactRelationController.text.trim(),
        qualification: _qualificationController.text.trim().isEmpty
            ? null
            : _qualificationController.text.trim(),
        department: _departmentController.text.trim().isEmpty
            ? null
            : _departmentController.text.trim(),
        position: _positionController.text.trim().isEmpty
            ? null
            : _positionController.text.trim(),
        joinDate: _joinDate,
        bloodGroup: _bloodGroupController.text.trim().isEmpty
            ? null
            : _bloodGroupController.text.trim(),
        medicalInfo: _medicalInfoController.text.trim().isEmpty
            ? null
            : _medicalInfoController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        schoolId: _selectedSchoolId,
      );

      Navigator.of(context).pop(user);
    }
  }

  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 800,
        height: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              widget.user == null ? 'Add New User' : 'Edit User',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Page Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildPageIndicator(0, 'Basic Info'),
                const SizedBox(width: 16),
                _buildPageIndicator(1, 'Bio & Details'),
              ],
            ),
            const SizedBox(height: 24),

            // Form Content
            Expanded(
              child: Form(
                key: _formKey,
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  children: [_buildBasicInfoPage(), _buildBioDetailsPage()],
                ),
              ),
            ),

            // Navigation Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                Row(
                  children: [
                    if (_currentPage > 0)
                      TextButton(
                        onPressed: () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: const Text('Previous'),
                      ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _currentPage == 1
                          ? _handleSave
                          : () {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                      child: Text(
                        _currentPage == 1
                            ? (widget.user == null
                                  ? 'Create User'
                                  : 'Update User')
                            : 'Next',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator(int page, String title) {
    final isActive = _currentPage == page;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? Theme.of(context).primaryColor : Colors.grey[300],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: isActive ? Colors.white : Colors.grey[600],
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildBasicInfoPage() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'First Name *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter first name';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(
                    labelText: 'Last Name *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter last name';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Username and password will be auto-generated
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Username and password will be automatically generated after user creation.',
                    style: TextStyle(color: Colors.blue.shade700),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<UserRole>(
                  value: _selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Role *',
                    border: OutlineInputBorder(),
                  ),
                  items: UserRole.values.map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(_getRoleDisplayName(role)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedRole = value;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SwitchListTile(
                  title: const Text('Active'),
                  value: _isActive,
                  onChanged: (value) {
                    setState(() {
                      _isActive = value;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // School Assignment (for all staff roles except superAdmin)
          if (_selectedRole != UserRole.superAdmin)
            DropdownButtonFormField<String>(
              value: _selectedSchoolId,
              decoration: InputDecoration(
                labelText: 'Assign to School *',
                border: const OutlineInputBorder(),
                hintText:
                    'Select a school for this ${_getRoleDisplayName(_selectedRole).toLowerCase()}',
              ),
              items: _schools.map((school) {
                return DropdownMenuItem(
                  value: school.id,
                  child: Text(school.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSchoolId = value;
                });
              },
              validator: (value) {
                if (_selectedRole != UserRole.superAdmin &&
                    (value == null || value.isEmpty)) {
                  return 'Please select a school';
                }
                return null;
              },
            ),
        ],
      ),
    );
  }

  Widget _buildBioDetailsPage() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<Gender>(
                  value: _selectedGender,
                  decoration: const InputDecoration(
                    labelText: 'Gender',
                    border: OutlineInputBorder(),
                  ),
                  items: Gender.values.map((gender) {
                    return DropdownMenuItem(
                      value: gender,
                      child: Text(gender.name.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _nationalIdController,
                  decoration: const InputDecoration(
                    labelText: 'National ID',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _dateOfBirth ?? DateTime(1990),
                      firstDate: DateTime(1950),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() {
                        _dateOfBirth = date;
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date of Birth',
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      _dateOfBirth != null
                          ? '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}'
                          : 'Select date',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _joinDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() {
                        _joinDate = date;
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Join Date',
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      _joinDate != null
                          ? '${_joinDate!.day}/${_joinDate!.month}/${_joinDate!.year}'
                          : 'Select date',
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _addressController,
            decoration: const InputDecoration(
              labelText: 'Address',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _emergencyContactController,
                  decoration: const InputDecoration(
                    labelText: 'Emergency Contact',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _emergencyContactRelationController,
                  decoration: const InputDecoration(
                    labelText: 'Relation',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _qualificationController,
                  decoration: const InputDecoration(
                    labelText: 'Qualification',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _bloodGroupController,
                  decoration: const InputDecoration(
                    labelText: 'Blood Group',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _departmentController,
                  decoration: const InputDecoration(
                    labelText: 'Department',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _positionController,
                  decoration: const InputDecoration(
                    labelText: 'Position',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _medicalInfoController,
            decoration: const InputDecoration(
              labelText: 'Medical Information',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: 'Additional Notes',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  String _getRoleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.teacher:
        return 'Teacher';
      case UserRole.accountant:
        return 'Accountant';
      case UserRole.otherStaff:
        return 'Other Staff';
      default:
        return role.name;
    }
  }
}

class UserProfileDialog extends StatelessWidget {
  final User user;
  final VoidCallback onEdit;
  final VoidCallback onResetPassword;

  const UserProfileDialog({
    super.key,
    required this.user,
    required this.onEdit,
    required this.onResetPassword,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 700,
        height: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: _getRoleColor(user.role),
                  child: Text(
                    '${user.firstName[0]}${user.lastName[0]}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${user.firstName} ${user.lastName}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        user.email,
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Chip(
                            label: Text(
                              _getRoleDisplayName(user.role),
                              style: const TextStyle(fontSize: 12),
                            ),
                            backgroundColor: _getRoleColor(user.role),
                          ),
                          const SizedBox(width: 8),
                          Chip(
                            label: Text(
                              user.isActive ? 'Active' : 'Inactive',
                              style: const TextStyle(fontSize: 12),
                            ),
                            backgroundColor: user.isActive
                                ? Colors.green.withOpacity(0.2)
                                : Colors.red.withOpacity(0.2),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: onResetPassword,
                      icon: const Icon(Icons.lock_reset),
                      label: const Text('Reset Password'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection('Basic Information', [
                      _buildInfoRow('Username', user.username),
                      _buildInfoRow('Phone', user.phoneNumber),
                      _buildInfoRow('Access Code', user.accessCode),
                      _buildInfoRow('Department', user.department ?? 'N/A'),
                      _buildInfoRow('Position', user.position ?? 'N/A'),
                    ]),

                    const SizedBox(height: 24),

                    _buildSection('Personal Details', [
                      _buildInfoRow(
                        'Gender',
                        user.gender?.name.toUpperCase() ?? 'N/A',
                      ),
                      _buildInfoRow(
                        'Date of Birth',
                        user.dateOfBirth != null
                            ? '${user.dateOfBirth!.day}/${user.dateOfBirth!.month}/${user.dateOfBirth!.year}'
                            : 'N/A',
                      ),
                      _buildInfoRow('National ID', user.nationalId ?? 'N/A'),
                      _buildInfoRow('Blood Group', user.bloodGroup ?? 'N/A'),
                      _buildInfoRow('Address', user.address ?? 'N/A'),
                    ]),

                    const SizedBox(height: 24),

                    _buildSection('Emergency Contact', [
                      _buildInfoRow('Contact', user.emergencyContact ?? 'N/A'),
                      _buildInfoRow(
                        'Relation',
                        user.emergencyContactRelation ?? 'N/A',
                      ),
                    ]),

                    const SizedBox(height: 24),

                    _buildSection('Professional Details', [
                      _buildInfoRow(
                        'Qualification',
                        user.qualification ?? 'N/A',
                      ),
                      _buildInfoRow(
                        'Join Date',
                        user.joinDate != null
                            ? '${user.joinDate!.day}/${user.joinDate!.month}/${user.joinDate!.year}'
                            : 'N/A',
                      ),
                    ]),

                    if (user.medicalInfo != null || user.notes != null) ...[
                      const SizedBox(height: 24),
                      _buildSection('Additional Information', [
                        if (user.medicalInfo != null)
                          _buildInfoRow('Medical Info', user.medicalInfo!),
                        if (user.notes != null)
                          _buildInfoRow('Notes', user.notes!),
                      ]),
                    ],

                    const SizedBox(height: 24),

                    _buildSection('System Information', [
                      _buildInfoRow(
                        'Created',
                        '${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}',
                      ),
                      _buildInfoRow(
                        'Last Updated',
                        '${user.updatedAt.day}/${user.updatedAt.month}/${user.updatedAt.year}',
                      ),
                    ]),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.superAdmin:
        return Colors.red.withOpacity(0.7);
      case UserRole.admin:
        return Colors.orange.withOpacity(0.7);
      case UserRole.teacher:
        return Colors.blue.withOpacity(0.7);
      case UserRole.accountant:
        return Colors.green.withOpacity(0.7);
      case UserRole.parent:
        return Colors.purple.withOpacity(0.7);
      default:
        return Colors.grey.withOpacity(0.7);
    }
  }

  String _getRoleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.teacher:
        return 'Teacher';
      case UserRole.accountant:
        return 'Accountant';
      case UserRole.otherStaff:
        return 'Other Staff';
      default:
        return role.name;
    }
  }
}

class _PasswordResetDialog extends StatefulWidget {
  final User user;

  const _PasswordResetDialog({required this.user});

  @override
  State<_PasswordResetDialog> createState() => _PasswordResetDialogState();
}

class _PasswordResetDialogState extends State<_PasswordResetDialog> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Reset Password for ${widget.user.firstName} ${widget.user.lastName}',
      ),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                obscureText: _obscurePassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),
                obscureText: _obscureConfirmPassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm the password';
                  }
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.of(context).pop(_passwordController.text);
            }
          },
          child: const Text('Reset Password'),
        ),
      ],
    );
  }
}
