import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'sqlite_database_service.dart';
import 'offline_database_service.dart';
import 'offline_auth_service.dart';
import 'seed_data_service.dart';
import 'auth_service.dart';
import 'supabase_service.dart';

class AppInitializationService {
  final OfflineCacheService _cacheService;
  final AuthService _authService;
  final SupabaseService _supabaseService;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  AppInitializationService(
    this._cacheService,
    this._authService,
    this._supabaseService,
  );

  /// Initialize the entire app for offline-first functionality
  Future<InitializationResult> initialize({
    bool seedDevelopmentData = true,
    bool forceReseed = false,
    bool offlineOnly = false,
  }) async {
    try {
      print('Starting app initialization...');

      // Step 1: Load environment variables
      print('Loading environment variables...');
      await dotenv.load(fileName: ".env");

      // Step 2: Initialize Supabase (skip if offline-only mode)
      if (!offlineOnly) {
        print('Initializing Supabase...');
        await _initializeSupabase();
      } else {
        print('Skipping Supabase initialization (offline-only mode)');
      }

      // Step 3: Initialize SQLite database
      print('Initializing offline database...');
      await SQLiteDatabaseService.database;

      // Step 3.1: Seed super admin for offline mode
      print('Seeding super admin credentials...');
      await SQLiteDatabaseService.seedSuperAdmin();

      // Step 3.5: Initialize SQLite database service
      print('Initializing SQLite database...');
      await OfflineDatabaseService.instance.initialize();

      // Step 4: Initialize cache service
      print('Initializing cache service...');
      await _cacheService.initialize();

      // Step 5: Initialize authentication service
      print('Initializing authentication service...');
      await _authService.initialize(offlineOnly: offlineOnly);

      // Step 6: Initialize Supabase service (skip if offline-only mode)
      if (!offlineOnly) {
        print('Initializing Supabase service...');
        await _supabaseService.initialize();
      } else {
        print('Skipping Supabase service initialization (offline-only mode)');
      }

      // Step 7: Seed development data if requested (DISABLED)
      // if (seedDevelopmentData) {
      //   final shouldSeed = await _shouldSeedDevelopmentData();
      //   if (shouldSeed || forceReseed) {
      // Seed development data if needed
      if (await _shouldSeedDevelopmentData()) {
        print('Seeding development data...');
        final seedService = SeedDataService(
          OfflineDatabaseService.instance,
          _supabaseService,
        );

        if (forceReseed) {
          await seedService.clearDevelopmentData();
        }

        final seedResult = await seedService.seedDevelopmentData();
        if (!seedResult) {
          print('Warning: Failed to seed development data');
        }
      } else {
        print('Skipping development data seeding - real data exists');
      }
      print('Development data seeding completed');

      _isInitialized = true;
      print('App initialization completed successfully!');

      return InitializationResult(
        success: true,
        message: 'App initialized successfully',
        statistics: await _getInitializationStatistics(),
      );
    } catch (e) {
      print('App initialization failed: $e');
      return InitializationResult(
        success: false,
        message: 'Initialization failed: ${e.toString()}',
      );
    }
  }

  /// Initialize Supabase client
  Future<void> _initializeSupabase() async {
    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

    if (supabaseUrl == null || supabaseAnonKey == null) {
      throw Exception('Supabase configuration missing in .env file');
    }

    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        debug: dotenv.env['DEBUG_MODE'] == 'true',
      );
    } catch (e) {
      if (e.toString().contains('already initialized')) {
        print('Supabase already initialized, skipping...');
        return;
      }
      rethrow;
    }
  }

  /// Check if we should seed development data
  Future<bool> _shouldSeedDevelopmentData() async {
    try {
      // Check if we're in demo mode
      final isDemoMode = dotenv.env['DEMO_MODE'] == 'true';
      if (isDemoMode) {
        return true;
      }

      // Check if we have any real data in Supabase
      final hasRealData = await _supabaseService.hasAnyData();
      if (hasRealData) {
        return false;
      }

      // Check if we have local data
      final users = await SQLiteDatabaseService.getAllUsers();
      final students = await SQLiteDatabaseService.getAllStudents();
      final schools = await SQLiteDatabaseService.getAllSchools();

      return users.isEmpty && students.isEmpty && schools.isEmpty;
    } catch (e) {
      print('Error checking if should seed data: $e');
      return true; // Default to seeding if we can't determine
    }
  }

  /// Get initialization statistics
  Future<Map<String, dynamic>> _getInitializationStatistics() async {
    final users = await SQLiteDatabaseService.getAllUsers();
    final students = await SQLiteDatabaseService.getAllStudents();
    final schools = await SQLiteDatabaseService.getAllSchools();

    // Safely check auth status without accessing uninitialized Supabase
    bool authReady = false;
    try {
      authReady = await _authService.isUserAuthenticated();
    } catch (e) {
      print('DEBUG: Could not check auth status in offline mode: $e');
      authReady = false;
    }

    return {
      'database_initialized': true,
      'cache_initialized': _cacheService.isInitialized,
      'auth_ready': authReady,
      'total_users': users.length,
      'total_students': students.length,
      'total_schools': schools.length,
      'total_classes': 0, // TODO: Add class count when implemented
      'initialization_time': DateTime.now().toIso8601String(),
    };
  }

  /// Reset the app to initial state
  Future<bool> resetApp() async {
    try {
      print('Resetting app...');

      // Sign out current user
      await _authService.signOut();

      // Clear all data
      await SQLiteDatabaseService.clearAllData();
      await _cacheService.clearCache();

      // Re-initialize
      _isInitialized = false;
      final result = await initialize();

      print('App reset completed');
      return result.success;
    } catch (e) {
      print('App reset failed: $e');
      return false;
    }
  }

  /// Get development credentials for easy access
  Map<String, dynamic> getDevelopmentCredentials() {
    // Return hardcoded development credentials since we no longer store them locally
    return {
      'super_admin': {
        'email': 'superadmin@schoolsystem.dev',
        'access_code': 'SUPER_ADMIN_001',
        'password': 'dev123456',
      },
      'admin': {
        'email': 'admin@demohighschool.edu',
        'access_code': 'AD001',
        'password': 'admin123',
      },
      'teacher': {
        'email': 'math.teacher@demohighschool.edu',
        'access_code': 'TC001',
        'password': 'teacher123',
      },
    };
  }

  /// Check if the app is ready for use
  bool isAppReady() {
    return _isInitialized;
  }

  /// Get app status information
  Future<Map<String, dynamic>> getAppStatus() async {
    return {
      'is_initialized': _isInitialized,
      'database_ready': true,
      'cache_ready': _cacheService.isInitialized,
      'user_authenticated': _authService.isUserAuthenticated(),
      'current_user': _authService.currentUser?.toJson(),
      'statistics': await _getInitializationStatistics(),
    };
  }
}

class InitializationResult {
  final bool success;
  final String message;
  final Map<String, dynamic>? statistics;

  InitializationResult({
    required this.success,
    required this.message,
    this.statistics,
  });
}

// Riverpod provider
final appInitializationServiceProvider =
    riverpod.Provider<AppInitializationService>((ref) {
      final cacheService = ref.watch(offlineCacheServiceProvider);
      final authService = ref.watch(authServiceProvider);
      final supabaseService = ref.watch(supabaseServiceProvider);

      return AppInitializationService(
        cacheService,
        authService,
        supabaseService,
      );
    });
