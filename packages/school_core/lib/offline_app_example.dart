import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'services/services.dart';
import 'models/models.dart';

/// Example of how to initialize and use the offline-first school management app
class OfflineAppExample extends ConsumerStatefulWidget {
  const OfflineAppExample({super.key});

  @override
  ConsumerState<OfflineAppExample> createState() => _OfflineAppExampleState();
}

class _OfflineAppExampleState extends ConsumerState<OfflineAppExample> {
  bool _isInitializing = true;
  String _initializationMessage = 'Initializing app...';
  Map<String, dynamic>? _credentials;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      final initService = ref.read(appInitializationServiceProvider);

      setState(() {
        _initializationMessage = 'Setting up offline database...';
      });

      final result = await initService.initialize(
        seedDevelopmentData: true,
        forceReseed: false,
      );

      if (result.success) {
        _credentials = initService.getDevelopmentCredentials();
        setState(() {
          _initializationMessage = 'App ready for offline use!';
          _isInitializing = false;
        });
      } else {
        setState(() {
          _initializationMessage = 'Initialization failed: ${result.message}';
          _isInitializing = false;
        });
      }
    } catch (e) {
      setState(() {
        _initializationMessage = 'Error: ${e.toString()}';
        _isInitializing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                _initializationMessage,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline School Management'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'App Status',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(_initializationMessage),
                    const SizedBox(height: 8),
                    _buildStatusInfo(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_credentials != null) _buildCredentialsCard(),
            const SizedBox(height: 16),
            _buildDataStatistics(),
            const SizedBox(height: 16),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusInfo() {
    final initService = ref.read(appInitializationServiceProvider);
    final status = initService.getAppStatus();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStatusRow('Database Ready', status['database_ready'] ?? false),
        _buildStatusRow('App Initialized', status['is_initialized'] ?? false),
        _buildStatusRow(
          'User Authenticated',
          status['user_authenticated'] ?? false,
        ),
      ],
    );
  }

  Widget _buildStatusRow(String label, bool status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            status ? Icons.check_circle : Icons.cancel,
            color: status ? Colors.green : Colors.red,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildCredentialsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Development Login Credentials',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Use these credentials to test different user roles:',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            ..._credentials!.entries.map(
              (entry) => _buildCredentialRow(
                entry.key.replaceAll('_', ' ').toUpperCase(),
                entry.value['access_code'],
                entry.value['password'],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCredentialRow(String role, String accessCode, String password) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              role,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
          Text('Code: $accessCode'),
          const SizedBox(width: 16),
          Text('Pass: $password'),
        ],
      ),
    );
  }

  Widget _buildDataStatistics() {
    final dbService = ref.read(offlineDatabaseServiceProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Data Statistics',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            _buildStatRow('Users', dbService.getAllUsers().length),
            _buildStatRow('Students', dbService.getAllStudents().length),
            _buildStatRow('Schools', dbService.getAllSchools().length),
            _buildStatRow('Classes', dbService.getAllClasses().length),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            count.toString(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Actions', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _resetApp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Reset App'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _testLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Test Login'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _resetApp() async {
    setState(() {
      _isInitializing = true;
      _initializationMessage = 'Resetting app...';
    });

    final initService = ref.read(appInitializationServiceProvider);
    final success = await initService.resetApp();

    if (success) {
      _credentials = initService.getDevelopmentCredentials();
      setState(() {
        _initializationMessage = 'App reset successfully!';
        _isInitializing = false;
      });
    } else {
      setState(() {
        _initializationMessage = 'Reset failed!';
        _isInitializing = false;
      });
    }
  }

  Future<void> _testLogin() async {
    if (_credentials == null) return;

    final authService = ref.read(authServiceProvider);
    final adminCreds = _credentials!['admin'];

    final result = await authService.signInWithAccessCode(
      adminCreds['access_code'],
      adminCreds['password'],
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.success
                ? 'Login successful as ${result.user?.firstName} ${result.user?.lastName}'
                : 'Login failed: ${result.message}',
          ),
          backgroundColor: result.success ? Colors.green : Colors.red,
        ),
      );
    }

    // Sign out after test
    if (result.success) {
      await Future.delayed(const Duration(seconds: 2));
      await authService.signOut();
    }
  }
}
