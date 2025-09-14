import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_core/school_core.dart';

import 'user_management_page.dart';

class SchoolProfilePage extends ConsumerStatefulWidget {
  final School school;

  const SchoolProfilePage({super.key, required this.school});

  @override
  ConsumerState<SchoolProfilePage> createState() => _SchoolProfilePageState();
}

class _SchoolProfilePageState extends ConsumerState<SchoolProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<User> _staff = [];
  List<SchoolClass> _classes = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadSchoolData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSchoolData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final staff = await SQLiteDatabaseService.getUsersBySchool(
        widget.school.id,
      );
      final classes = await SQLiteDatabaseService.getClassesBySchool(
        widget.school.id,
      );

      setState(() {
        _staff = staff;
        _classes = classes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load school data: $e';
        _isLoading = false;
      });
    }
  }

  void _navigateToAddUser(UserRole role) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(builder: (context) => const UserManagementPage()),
        )
        .then((_) => _loadSchoolData());
  }

  Widget _buildSidebar(BuildContext context) {
    return Column(
      children: [
        // Sidebar Header
        Container(
          height: 120,
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
                radius: 25,
                backgroundColor: Colors.white,
                child: Text(
                  widget.school.name.isNotEmpty
                      ? widget.school.name[0].toUpperCase()
                      : 'S',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.school.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                widget.school.type.name.toUpperCase(),
                style: const TextStyle(color: Colors.white70, fontSize: 12),
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
                title: 'Staff Members',
                tabIndex: 1,
              ),
              _buildSidebarItem(
                icon: Icons.class_outlined,
                selectedIcon: Icons.class_,
                title: 'Classes',
                tabIndex: 2,
              ),
              _buildSidebarItem(
                icon: Icons.settings_outlined,
                selectedIcon: Icons.settings,
                title: 'Settings',
                tabIndex: 3,
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Divider(),
              ),
              _buildSidebarItem(
                icon: Icons.edit_outlined,
                selectedIcon: Icons.edit,
                title: 'Edit School',
                tabIndex: -1,
                onTap: () {
                  // TODO: Implement edit school functionality
                },
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
                      'Back to Schools',
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
                if (tabIndex >= 0) {
                  _tabController.animateTo(tabIndex);
                }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Persistent Sidebar
          Container(
            width: 280,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                right: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: _buildSidebar(context),
          ),
          // Main Content Area
          Expanded(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _errorMessage != null
                      ? _buildErrorWidget()
                      : _buildTabBarView(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                ),
              ),
              const SizedBox(width: 16),
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                child: Text(
                  widget.school.name.isNotEmpty
                      ? widget.school.name[0].toUpperCase()
                      : 'S',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.school.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.school.type.name.toUpperCase()} SCHOOL',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Colors.white.withOpacity(0.8),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            widget.school.address,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: widget.school.isActive
                      ? Colors.green.withOpacity(0.2)
                      : Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: widget.school.isActive ? Colors.green : Colors.red,
                    width: 1,
                  ),
                ),
                child: Text(
                  widget.school.isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                    color: widget.school.isActive ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildStatCard(
                icon: Icons.people,
                title: 'Staff Members',
                value: '${_staff.length}',
                color: Colors.blue,
              ),
              const SizedBox(width: 16),
              _buildStatCard(
                icon: Icons.class_,
                title: 'Classes',
                value: '${_classes.length}',
                color: Colors.orange,
              ),
              const SizedBox(width: 16),
              _buildStatCard(
                icon: Icons.school,
                title: 'Students',
                value: '${(widget.school.id.hashCode % 500) + 100}',
                color: Colors.green,
              ),
              const SizedBox(width: 16),
              _buildStatCard(
                icon: Icons.calendar_today,
                title: 'Established',
                value: '${widget.school.establishedDate.year}',
                color: Colors.purple,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
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
                  widget.school.name,
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
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        widget.school.type.name.toUpperCase(),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
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
                        color: widget.school.isActive
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        widget.school.isActive ? 'ACTIVE' : 'INACTIVE',
                        style: TextStyle(
                          color: widget.school.isActive
                              ? Colors.green
                              : Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  widget.school.address,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              // TODO: Implement school actions menu
            },
            icon: const Icon(Icons.more_vert),
            tooltip: 'More actions',
          ),
        ],
      ),
    );
  }

  Widget _buildTabBarView() {
    return AnimatedBuilder(
      animation: _tabController,
      builder: (context, child) {
        switch (_tabController.index) {
          case 0:
            return _buildOverviewTab();
          case 1:
            return _buildStaffTab();
          case 2:
            return _buildClassesTab();
          case 3:
            return _buildSettingsTab();
          default:
            return _buildOverviewTab();
        }
      },
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoSection(),
          const SizedBox(height: 24),
          _buildContactSection(),
          const SizedBox(height: 24),
          _buildDescriptionSection(),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'School Information',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('School ID', widget.school.id),
            _buildInfoRow('School Type', widget.school.type.name.toUpperCase()),
            _buildInfoRow('Principal', widget.school.principalName),
            _buildInfoRow(
              'Established',
              '${widget.school.establishedDate.day}/${widget.school.establishedDate.month}/${widget.school.establishedDate.year}',
            ),
            _buildInfoRow(
              'Status',
              widget.school.isActive ? 'Active' : 'Inactive',
            ),
            _buildInfoRow(
              'Created',
              '${widget.school.createdAt.day}/${widget.school.createdAt.month}/${widget.school.createdAt.year}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact Information',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Address', widget.school.address),
            _buildInfoRow('Phone', widget.school.phoneNumber),
            _buildInfoRow('Email', widget.school.email),
            if (widget.school.website != null)
              _buildInfoRow('Website', widget.school.website!),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionSection() {
    if (widget.school.description == null ||
        widget.school.description!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Description',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              widget.school.description!,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
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
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Text(
                'Staff Members (${_staff.length})',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              PopupMenuButton<UserRole>(
                onSelected: _navigateToAddUser,
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: UserRole.admin,
                    child: Row(
                      children: [
                        Icon(Icons.admin_panel_settings),
                        SizedBox(width: 8),
                        Text('Add Admin'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: UserRole.teacher,
                    child: Row(
                      children: [
                        Icon(Icons.school),
                        SizedBox(width: 8),
                        Text('Add Teacher'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: UserRole.accountant,
                    child: Row(
                      children: [
                        Icon(Icons.account_balance),
                        SizedBox(width: 8),
                        Text('Add Accountant'),
                      ],
                    ),
                  ),
                ],
                child: ElevatedButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Staff'),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _staff.isEmpty ? _buildEmptyStaffState() : _buildStaffList(),
        ),
      ],
    );
  }

  Widget _buildEmptyStaffState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No staff members assigned',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Add staff members to manage this school',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffList() {
    final groupedStaff = <UserRole, List<User>>{};
    for (final staff in _staff) {
      groupedStaff.putIfAbsent(staff.role, () => []).add(staff);
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      children: groupedStaff.entries.map((entry) {
        return _buildStaffGroup(entry.key, entry.value);
      }).toList(),
    );
  }

  Widget _buildStaffGroup(UserRole role, List<User> staff) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getRoleIcon(role),
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '${role.name.toUpperCase()}S (${staff.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...staff.map((user) => _buildStaffTile(user)),
          ],
        ),
      ),
    );
  }

  Widget _buildStaffTile(User user) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Text(
          '${user.firstName[0]}${user.lastName[0]}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text('${user.firstName} ${user.lastName}'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(user.email),
          Text(
            user.username,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: user.isActive
              ? Colors.green.withOpacity(0.1)
              : Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          user.isActive ? 'Active' : 'Inactive',
          style: TextStyle(
            color: user.isActive ? Colors.green : Colors.red,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Icons.admin_panel_settings;
      case UserRole.teacher:
        return Icons.school;
      case UserRole.accountant:
        return Icons.account_balance;
      default:
        return Icons.person;
    }
  }

  Widget _buildClassesTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Text(
                'Classes (${_classes.length})',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implement add class functionality
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Class'),
              ),
            ],
          ),
        ),
        Expanded(
          child: _classes.isEmpty
              ? _buildEmptyClassesState()
              : _buildClassesList(),
        ),
      ],
    );
  }

  Widget _buildEmptyClassesState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.class_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No classes created',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Create classes to organize students and subjects',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassesList() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: _classes.length,
      itemBuilder: (context, index) {
        final schoolClass = _classes[index];
        return _buildClassCard(schoolClass);
      },
    );
  }

  Widget _buildClassCard(SchoolClass schoolClass) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              schoolClass.name,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              'Grade ${schoolClass.grade} - Section ${schoolClass.section}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Icon(
                  Icons.people,
                  size: 16,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  '${schoolClass.capacity} capacity',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            if (schoolClass.classroom != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.room,
                    size: 16,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    schoolClass.classroom!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'School Settings',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.edit),
                    title: const Text('Edit School Information'),
                    subtitle: const Text(
                      'Update school details and contact information',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Implement edit school functionality
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.image),
                    title: const Text('School Logo'),
                    subtitle: const Text('Upload or change school logo'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Implement logo upload functionality
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('Academic Settings'),
                    subtitle: const Text(
                      'Configure academic year, grading system',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Implement academic settings
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(
                      widget.school.isActive
                          ? Icons.pause_circle
                          : Icons.play_circle,
                      color: widget.school.isActive
                          ? Colors.orange
                          : Colors.green,
                    ),
                    title: Text(
                      widget.school.isActive
                          ? 'Deactivate School'
                          : 'Activate School',
                    ),
                    subtitle: Text(
                      widget.school.isActive
                          ? 'Temporarily disable this school'
                          : 'Reactivate this school',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Implement activate/deactivate functionality
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadSchoolData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
