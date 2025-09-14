import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import 'offline_database_service.dart';
import 'sqlite_database_service.dart';

/// Cache-only service for storing user data locally after successful cloud authentication
/// This service does NOT perform authentication - it only manages local user cache
class OfflineCacheService {
  static const String _currentUserKey = 'current_user_id';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _cachedUserDataKey = 'cached_user_data';

  final OfflineDatabaseService _dbService;
  User? _currentUser;

  OfflineCacheService(this._dbService);

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isInitialized =>
      true; // Cache service is always considered initialized

  /// Initialize auth service and restore session
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
    final currentUserId = prefs.getString(_currentUserKey);

    if (isLoggedIn && currentUserId != null) {
      _currentUser = await SQLiteDatabaseService.getUser(currentUserId);
      if (_currentUser != null) {
        print(
          '🔍 DEBUG: AuthService - Cached session restored for user: ${_currentUser!.email}',
        );
      } else {
        print('🔍 DEBUG: AuthService - No cached session found');
      }
    } else {
      print('🔍 DEBUG: AuthService - No cached session found');
    }
  }

  /// Cache user data locally after successful cloud authentication
  Future<void> cacheUserAfterAuth(User user) async {
    try {
      print('💾 DEBUG: Caching user data locally: ${user.email}');

      // Save user to local database for offline access
      await _dbService.saveUser(user);

      // Set current user and save session
      _currentUser = user;
      await _saveSession(user.id);

      // Cache user data in SharedPreferences as JSON backup
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cachedUserDataKey, jsonEncode(user.toJson()));

      print('✅ DEBUG: User data cached successfully');
    } catch (e) {
      print('❌ DEBUG: Failed to cache user data: ${e.toString()}');
    }
  }

  /// Get cached user data for offline access
  Future<User?> getCachedUser(String userId) async {
    try {
      // First try to get from local database
      final user = await SQLiteDatabaseService.getUser(userId);
      if (user != null) {
        return user;
      }

      // Fallback to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final cachedUserJson = prefs.getString(_cachedUserDataKey);
      if (cachedUserJson != null) {
        final userData = jsonDecode(cachedUserJson);
        return User.fromJson(userData);
      }

      return null;
    } catch (e) {
      print('❌ DEBUG: Failed to get cached user: ${e.toString()}');
      return null;
    }
  }

  /// Check if user data is cached locally
  Future<bool> isUserCached(String userId) async {
    final cachedUser = await getCachedUser(userId);
    return cachedUser != null;
  }

  /// Sign out current user
  Future<void> signOut() async {
    _currentUser = null;
    await _clearSession();
  }

  /// Update cached user profile data
  Future<void> updateCachedProfile(User updatedUser) async {
    try {
      print('💾 DEBUG: Updating cached user profile: ${updatedUser.email}');

      // Update in local database
      await _dbService.saveUser(updatedUser);

      // Update current user reference
      _currentUser = updatedUser;

      // Update cached JSON in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _cachedUserDataKey,
        jsonEncode(updatedUser.toJson()),
      );

      print('✅ DEBUG: Cached user profile updated successfully');
    } catch (e) {
      print('❌ DEBUG: Failed to update cached profile: ${e.toString()}');
    }
  }

  /// Clear all cached user data
  Future<void> clearCache() async {
    try {
      print('🗑️ DEBUG: Clearing all cached user data');

      // Clear current user
      _currentUser = null;

      // Clear session
      await _clearSession();

      // Clear cached JSON data
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cachedUserDataKey);

      print('✅ DEBUG: All cached data cleared successfully');
    } catch (e) {
      print('❌ DEBUG: Failed to clear cache: ${e.toString()}');
    }
  }

  /// Check if user has specific role
  bool hasRole(UserRole role) {
    return _currentUser?.role == role;
  }

  /// Check if user has any of the specified roles
  bool hasAnyRole(List<UserRole> roles) {
    return _currentUser != null && roles.contains(_currentUser!.role);
  }

  /// Sync user data from cloud to local cache
  Future<void> syncUserFromCloud(User cloudUser) async {
    try {
      print('🔄 DEBUG: Syncing user data from cloud to local cache');

      // Update local database with cloud data
      await _dbService.saveUser(cloudUser);

      // Update current user if it's the same user
      if (_currentUser?.id == cloudUser.id) {
        _currentUser = cloudUser;
      }

      // Update cached JSON data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cachedUserDataKey, jsonEncode(cloudUser.toJson()));

      print('✅ DEBUG: User data synced from cloud successfully');
    } catch (e) {
      print('❌ DEBUG: Failed to sync user from cloud: ${e.toString()}');
    }
  }

  // Private helper methods for session management

  Future<void> _saveSession(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, true);
    await prefs.setString(_currentUserKey, userId);
  }

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_isLoggedInKey);
    await prefs.remove(_currentUserKey);
  }
}

// AuthResult is now imported from models/auth_result.dart

// Riverpod providers
final offlineCacheServiceProvider = Provider<OfflineCacheService>((ref) {
  final dbService = ref.watch(offlineDatabaseServiceProvider);
  return OfflineCacheService(dbService);
});

// Keep the old provider name for backward compatibility but mark as deprecated
@Deprecated('Use offlineCacheServiceProvider instead')
final offlineAuthServiceProvider = Provider<OfflineCacheService>((ref) {
  final dbService = ref.watch(offlineDatabaseServiceProvider);
  return OfflineCacheService(dbService);
});

final offlineDatabaseServiceProvider = Provider<OfflineDatabaseService>((ref) {
  return OfflineDatabaseService.instance;
});
