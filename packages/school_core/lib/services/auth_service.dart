import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import 'supabase_service.dart';
import 'offline_auth_service.dart';
import 'sqlite_database_service.dart';

// Cloud-first authentication service with local caching
class AuthService {
  final SupabaseService _supabaseService;
  final OfflineCacheService _cacheService;
  User? _currentUser;
  bool _offlineOnly = false;

  AuthService(this._supabaseService, this._cacheService);

  User? get currentUser => _offlineOnly
      ? _currentUser
      : (_currentUser ?? _supabaseService.getCurrentUser());
  bool get isAuthenticated => currentUser != null;
  bool get isOfflineOnly => _offlineOnly;

  /// Get the supabase service (for provider access)
  SupabaseService get supabaseService => _supabaseService;

  /// Initialize the auth service
  Future<void> initialize({bool offlineOnly = false}) async {
    _offlineOnly = offlineOnly;

    // Initialize cache service first to restore sessions
    await _cacheService.initialize();

    if (!_offlineOnly) {
      await _supabaseService.initialize();
      _currentUser = _supabaseService.getCurrentUser();
    } else {
      print('DEBUG: AuthService initialized in offline-only mode');
    }

    // Restore cached session if user was previously logged in
    await _restoreCachedSession();
  }

  /// Sign in with access code (cloud-first with local caching)
  Future<AuthResult> signInWithAccessCode(
    String accessCode, [
    String? password, // Optional for compatibility
  ]) async {
    if (_offlineOnly) {
      print(
        '🔐 DEBUG: AuthService - Offline-only mode: authenticating against local database',
      );
      return await _authenticateLocally(
        accessCode: accessCode,
        password: password,
      );
    }

    print('🔐 DEBUG: AuthService - Starting cloud-first signInWithAccessCode');

    try {
      // Attempt cloud authentication first
      final result = await _supabaseService.signInWithAccessCode(accessCode);

      if (result.success && result.user != null) {
        print(
          '✅ DEBUG: AuthService - Cloud authentication successful, caching user data',
        );

        // Cache user data locally after successful cloud auth
        await _cacheService.cacheUserAfterAuth(result.user!);
        _currentUser = result.user;

        return result;
      } else {
        print(
          '❌ DEBUG: AuthService - Cloud authentication failed: ${result.message}',
        );
        return result;
      }
    } catch (e) {
      print(
        '💥 DEBUG: AuthService - Exception in signInWithAccessCode: ${e.toString()}',
      );
      return AuthResult(
        success: false,
        message: 'Authentication error: ${e.toString()}',
      );
    }
  }

  /// Sign in with email and password (cloud-first with local caching)
  Future<AuthResult> signInWithEmail(String email, String password) async {
    if (_offlineOnly) {
      print(
        '🔐 DEBUG: AuthService - Offline-only mode: authenticating against local database',
      );
      return await _authenticateLocally(email: email, password: password);
    }

    print('🔐 DEBUG: AuthService - Starting cloud-first signInWithEmail');

    try {
      // Attempt cloud authentication first
      final result = await _supabaseService.signInWithEmail(email, password);

      if (result.success && result.user != null) {
        print(
          '✅ DEBUG: AuthService - Cloud authentication successful, caching user data',
        );

        // Cache user data locally after successful cloud auth
        await _cacheService.cacheUserAfterAuth(result.user!);
        _currentUser = result.user;

        return result;
      } else {
        print(
          '❌ DEBUG: AuthService - Cloud authentication failed: ${result.message}',
        );
        return result;
      }
    } catch (e) {
      print(
        '💥 DEBUG: AuthService - Exception in signInWithEmail: ${e.toString()}',
      );
      return AuthResult(
        success: false,
        message: 'Authentication error: ${e.toString()}',
      );
    }
  }

  /// Sign in with username and password (cloud-first with local caching)
  Future<AuthResult> signInWithUsername(
    String username,
    String password,
  ) async {
    if (_offlineOnly) {
      print(
        '🔐 DEBUG: AuthService - Offline-only mode: authenticating against local database',
      );
      return await _authenticateLocally(username: username, password: password);
    }

    print('🔐 DEBUG: AuthService - Starting cloud-first signInWithUsername');

    try {
      // Attempt cloud authentication first
      final result = await _supabaseService.signInWithUsername(
        username,
        password,
      );

      if (result.success && result.user != null) {
        print(
          '✅ DEBUG: AuthService - Cloud authentication successful, caching user data',
        );

        // Cache user data locally after successful cloud auth
        await _cacheService.cacheUserAfterAuth(result.user!);
        _currentUser = result.user;

        return result;
      } else {
        print(
          '❌ DEBUG: AuthService - Cloud authentication failed: ${result.message}',
        );
        return result;
      }
    } catch (e) {
      print(
        '💥 DEBUG: AuthService - Exception in signInWithUsername: ${e.toString()}',
      );
      return AuthResult(
        success: false,
        message: 'Authentication error: ${e.toString()}',
      );
    }
  }

  /// Sign out current user (cloud and clear local cache)
  Future<void> signOut() async {
    print('🚪 DEBUG: AuthService - Signing out user');

    try {
      // Sign out from Supabase cloud
      await _supabaseService.signOut();

      // Clear local cache
      await _cacheService.clearCache();

      _currentUser = null;
      print('✅ DEBUG: AuthService - User signed out and cache cleared');
    } catch (e) {
      print('❌ DEBUG: AuthService - Error during sign out: ${e.toString()}');
      // Still clear local state even if cloud sign out fails
      _currentUser = null;
    }
  }

  /// Check if user is authenticated
  Future<bool> isUserAuthenticated() async {
    return isAuthenticated;
  }

  /// Change user password (placeholder - implement with Supabase auth)
  Future<AuthResult> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    // TODO: Implement with Supabase auth.updateUser
    return AuthResult(success: false, message: 'Not implemented yet');
  }

  /// Update user profile (placeholder - implement with Supabase auth)
  Future<AuthResult> updateProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? profileImageUrl,
  }) async {
    // TODO: Implement with Supabase auth.updateUser
    return AuthResult(success: false, message: 'Not implemented yet');
  }

  // Check if user has permission for specific role
  bool hasRole(UserRole role) {
    return currentUser?.role == role;
  }

  bool hasAnyRole(List<UserRole> roles) {
    return currentUser != null && roles.contains(currentUser!.role);
  }

  /// Authenticate against local SQLite database in offline mode
  Future<AuthResult> _authenticateLocally({
    String? accessCode,
    String? email,
    String? username,
    String? password,
  }) async {
    try {
      print('🔐 DEBUG: AuthService - Starting local authentication');

      User? user;

      // Try to find user by access code, email, or username
      if (accessCode != null) {
        print(
          '🔍 DEBUG: AuthService - Looking up user by access code: $accessCode',
        );
        user = await SQLiteDatabaseService.getUserByAccessCode(accessCode);
      } else if (email != null) {
        print('🔍 DEBUG: AuthService - Looking up user by email: $email');
        user = await SQLiteDatabaseService.getUserByEmail(email);
      } else if (username != null) {
        print('🔍 DEBUG: AuthService - Looking up user by username: $username');
        user = await SQLiteDatabaseService.getUserByUsername(username);
      }

      if (user == null) {
        print('❌ DEBUG: AuthService - User not found in local database');
        return AuthResult(
          success: false,
          message: 'User not found. Please check your credentials.',
        );
      }

      // Check if user is active
      if (!user.isActive) {
        print('❌ DEBUG: AuthService - User account is inactive');
        return AuthResult(
          success: false,
          message: 'User account is inactive. Please contact administrator.',
        );
      }

      // Verify password if provided (for email/username login)
      // Skip password verification for access code login
      if (password != null && user.password != null && accessCode == null) {
        if (user.password != password) {
          print('❌ DEBUG: AuthService - Password verification failed');
          return AuthResult(
            success: false,
            message: 'Invalid password. Please try again.',
          );
        }
      }

      // Authentication successful
      _currentUser = user;

      // Cache user session for persistence
      await _cacheService.cacheUserAfterAuth(user);

      print(
        '✅ DEBUG: AuthService - Local authentication successful for user: ${user.fullName}',
      );

      return AuthResult(
        success: true,
        message: 'Authentication successful',
        user: user,
      );
    } catch (e) {
      print(
        '💥 DEBUG: AuthService - Exception in local authentication: ${e.toString()}',
      );
      return AuthResult(
        success: false,
        message: 'Authentication error: ${e.toString()}',
      );
    }
  }

  /// Restore cached session if user was previously logged in
  Future<void> _restoreCachedSession() async {
    try {
      // Check if cache service has a logged-in user
      if (_cacheService.isAuthenticated && _cacheService.currentUser != null) {
        _currentUser = _cacheService.currentUser;
        print(
          '✅ DEBUG: AuthService - Restored cached session for user: ${_currentUser?.fullName}',
        );
      } else {
        print('🔍 DEBUG: AuthService - No cached session found');
      }
    } catch (e) {
      print(
        '❌ DEBUG: AuthService - Failed to restore cached session: ${e.toString()}',
      );
    }
  }
}

// Authentication result wrapper
// AuthResult is now imported from offline_auth_service.dart

// Riverpod providers
final authServiceProvider = Provider<AuthService>((ref) {
  final supabaseService = ref.read(supabaseServiceProvider);
  final cacheService = ref.read(offlineCacheServiceProvider);
  return AuthService(supabaseService, cacheService);
});

final currentUserProvider = StateProvider<User?>((ref) {
  final authService = ref.read(authServiceProvider);
  return authService.currentUser;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(currentUserProvider) != null;
});
