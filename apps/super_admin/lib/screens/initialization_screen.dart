import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:school_core/school_core.dart';

/// Screen that handles app initialization and setup
class InitializationScreen extends ConsumerStatefulWidget {
  const InitializationScreen({super.key});

  @override
  ConsumerState<InitializationScreen> createState() =>
      _InitializationScreenState();
}

class _InitializationScreenState extends ConsumerState<InitializationScreen> {
  bool _isInitializing = true;
  String _initializationMessage = 'Initializing Super Admin App...';
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      final initService = ref.read(appInitializationServiceProvider);

      setState(() {
        _initializationMessage = 'Checking connectivity...';
      });

      // Check internet connectivity
      final connectivityResult = await Connectivity().checkConnectivity();
      final bool hasInternet = connectivityResult != ConnectivityResult.none;
      final bool offlineOnly = !hasInternet;
      
      setState(() {
        _initializationMessage = hasInternet 
            ? 'Setting up cloud database...' 
            : 'Setting up offline database...';
      });

      // Note: Not clearing database to preserve cached user sessions
      
      print('DEBUG: Connectivity check - hasInternet: $hasInternet, offlineOnly: $offlineOnly');
      print('DEBUG: Starting initialization with seedDevelopmentData: true, forceReseed: false, offlineOnly: $offlineOnly');
      final result = await initService.initialize(
        seedDevelopmentData: true,
        forceReseed: false,
        offlineOnly: offlineOnly,
      );
      print('DEBUG: Initialization completed with result: ${result.success}');

      if (result.success) {
        setState(() {
          _initializationMessage = 'Super Admin app ready!';
          _isInitializing = false;
        });

        // Check if user is already authenticated
        final authService = ref.read(authServiceProvider);
        final isAuthenticated = authService.isAuthenticated;
        
        // Navigate based on authentication status after a brief delay
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          if (isAuthenticated) {
            print('✅ DEBUG: User already authenticated, navigating to home');
            context.go('/home');
          } else {
            print('🔍 DEBUG: No authenticated user, navigating to login');
            context.go('/login');
          }
        }
      } else {
        setState(() {
          _initializationMessage = 'Initialization failed';
          _errorMessage = result.message;
          _hasError = true;
          _isInitializing = false;
        });
      }
    } catch (e) {
      setState(() {
        _initializationMessage = 'Initialization error';
        _errorMessage = e.toString();
        _hasError = true;
        _isInitializing = false;
      });
    }
  }

  Future<void> _retryInitialization() async {
    setState(() {
      _isInitializing = true;
      _hasError = false;
      _errorMessage = null;
      _initializationMessage = 'Retrying initialization...';
    });

    await _initializeApp();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade50,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo/Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.deepPurple,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.admin_panel_settings,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),

              // App Title
              Text(
                'Super Admin',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'School Management System',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.deepPurple.shade300,
                ),
              ),
              const SizedBox(height: 48),

              // Initialization Status
              if (_isInitializing) ...[
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  _initializationMessage,
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ] else if (_hasError) ...[
                Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  _initializationMessage,
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _errorMessage!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.red.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _retryInitialization,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('Retry'),
                ),
              ] else ...[
                Icon(Icons.check_circle_outline, color: Colors.green, size: 48),
                const SizedBox(height: 16),
                Text(
                  _initializationMessage,
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: Colors.green),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
