import 'dart:convert';
// import 'package:hive/hive.dart'; // Hive disabled
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import 'offline_database_service.dart';
import 'offline_auth_service.dart';
import 'supabase_service.dart';

/// Result class for sync operations
class SyncResult {
  final bool success;
  final String message;
  final DateTime? syncedAt;
  final int? recordsProcessed;

  SyncResult({
    required this.success,
    required this.message,
    this.syncedAt,
    this.recordsProcessed,
  });

  factory SyncResult.success(
    String message, {
    DateTime? syncedAt,
    int? recordsProcessed,
  }) {
    return SyncResult(
      success: true,
      message: message,
      syncedAt: syncedAt ?? DateTime.now(),
      recordsProcessed: recordsProcessed,
    );
  }

  factory SyncResult.failure(String message) {
    return SyncResult(success: false, message: message);
  }
}

/// Enhanced sync service with bidirectional synchronization and history tracking
class SyncService {
  final SupabaseService _supabaseService;
  final OfflineDatabaseService _localDbService;
  final List<SyncHistory> _syncHistory = [];

  static const String _syncHistoryKey = 'sync_history';
  static const int _maxHistoryRecords = 50;

  SyncService(this._supabaseService, this._localDbService) {
    _loadSyncHistory();
  }

  /// Get sync history
  List<SyncHistory> get syncHistory => List.unmodifiable(_syncHistory);

  /// Get the latest sync history record
  SyncHistory? get latestSync =>
      _syncHistory.isNotEmpty ? _syncHistory.first : null;

  /// Perform full bidirectional synchronization
  Future<SyncHistory> performFullSync() async {
    print('🔄 DEBUG: SyncService - Starting full synchronization');

    final syncRecord = SyncHistory(syncStartTime: DateTime.now());

    _addSyncHistory(syncRecord);

    try {
      // Define tables to sync in order of dependencies
      final tablesToSync = [
        'schools',
        'users',
        'classes',
        'subjects',
        'students',
        // Add more tables as needed
      ];

      for (final tableName in tablesToSync) {
        print('🔄 DEBUG: SyncService - Syncing table: $tableName');
        final tableResult = await _syncTable(tableName);
        syncRecord.tableResults.add(tableResult);
      }

      syncRecord.markCompleted();
      print('✅ DEBUG: SyncService - Full sync completed successfully');
      print(
        '📊 DEBUG: SyncService - Total records processed: ${syncRecord.totalRecordsProcessed}',
      );
    } catch (e) {
      print('❌ DEBUG: SyncService - Sync failed: ${e.toString()}');
      syncRecord.markFailed(e.toString());
    }

    await _saveSyncHistory();
    return syncRecord;
  }

  /// Sync a specific table bidirectionally
  Future<SyncTableResult> _syncTable(String tableName) async {
    final result = SyncTableResult(tableName: tableName);

    try {
      // Step 1: Upload local records created by super admin to cloud
      await _uploadLocalRecords(tableName, result);

      // Step 2: Fetch cloud records and update local database
      await _fetchCloudRecords(tableName, result);

      print('✅ DEBUG: SyncService - Table $tableName sync completed');
      print(
        '📊 DEBUG: SyncService - $tableName: ${result.recordsUploaded} uploaded, ${result.recordsFetched} fetched, ${result.recordsUpdated} updated',
      );
    } catch (e) {
      print(
        '❌ DEBUG: SyncService - Error syncing table $tableName: ${e.toString()}',
      );
      result.errors.add('Error syncing $tableName: ${e.toString()}');
    }

    return result;
  }

  /// Upload local records to cloud
  Future<void> _uploadLocalRecords(
    String tableName,
    SyncTableResult result,
  ) async {
    try {
      List<Map<String, dynamic>> localRecords;

      switch (tableName) {
        case 'users':
          final usersList = await _localDbService.getAllUsers();
          localRecords = usersList
              .map((user) => user.toJson())
              .toList();
          break;
        case 'schools':
          final schoolsList = await _localDbService.getAllSchools();
          localRecords = schoolsList
              .map((school) => school.toJson())
              .toList();
          break;
        case 'students':
          final studentsList = await _localDbService.getAllStudents();
          localRecords = studentsList
              .map((student) => student.toJson())
              .toList();
          break;
        case 'classes':
          final classesList = await _localDbService.getAllClasses();
          localRecords = classesList
              .map((cls) => cls.toJson())
              .toList();
          break;
        case 'subjects':
          final subjectsList = await _localDbService.getAllSubjects();
          localRecords = subjectsList
              .map((subject) => subject.toJson())
              .toList();
          break;
        default:
          print('⚠️ DEBUG: SyncService - Unknown table for upload: $tableName');
          return;
      }

      if (localRecords.isEmpty) {
        print(
          'ℹ️ DEBUG: SyncService - No local records to upload for $tableName',
        );
        return;
      }

      // Upload records to Supabase
      for (final record in localRecords) {
        try {
          // Check if record exists in cloud
          final existingRecord = await _supabaseService.getRecordById(
            tableName,
            record['id'],
          );

          if (existingRecord != null) {
            // Compare timestamps and update if local is newer
            final localUpdatedAt = DateTime.parse(record['updatedAt']);
            final cloudUpdatedAt = DateTime.parse(
              existingRecord['updated_at'] ?? existingRecord['updatedAt'],
            );

            if (localUpdatedAt.isAfter(cloudUpdatedAt)) {
              await _supabaseService.updateRecord(
                tableName,
                record['id'],
                record,
              );
              result.recordsUpdated++;
              result.conflictsResolved++;
              print(
                '🔄 DEBUG: SyncService - Updated cloud record ${record['id']} in $tableName',
              );
            }
          } else {
            // Insert new record
            await _supabaseService.insertRecord(tableName, record);
            result.recordsUploaded++;
            print(
              '⬆️ DEBUG: SyncService - Uploaded new record ${record['id']} to $tableName',
            );
          }
        } catch (e) {
          print(
            '❌ DEBUG: SyncService - Failed to upload record ${record['id']}: ${e.toString()}',
          );
          result.errors.add(
            'Failed to upload ${record['id']}: ${e.toString()}',
          );
        }
      }
    } catch (e) {
      print(
        '❌ DEBUG: SyncService - Error uploading local records for $tableName: ${e.toString()}',
      );
      result.errors.add('Upload error: ${e.toString()}');
    }
  }

  /// Fetch cloud records and update local database
  Future<void> _fetchCloudRecords(
    String tableName,
    SyncTableResult result,
  ) async {
    try {
      // Get all records from cloud
      final cloudRecords = await _supabaseService.getAllRecords(tableName);

      if (cloudRecords.isEmpty) {
        print(
          'ℹ️ DEBUG: SyncService - No cloud records to fetch for $tableName',
        );
        return;
      }

      for (final cloudRecord in cloudRecords) {
        try {
          final recordId = cloudRecord['id'] as String;

          // Check if record exists locally
          final localRecord = await _getLocalRecordById(tableName, recordId);

          if (localRecord != null) {
            // Compare timestamps and update if cloud is newer
            final cloudUpdatedAt = DateTime.parse(
              cloudRecord['updated_at'] ?? cloudRecord['updatedAt'],
            );
            final localUpdatedAt = DateTime.parse(localRecord['updatedAt']);

            if (cloudUpdatedAt.isAfter(localUpdatedAt)) {
              await _updateLocalRecord(tableName, cloudRecord);
              result.recordsUpdated++;
              result.conflictsResolved++;
              print(
                '🔄 DEBUG: SyncService - Updated local record $recordId in $tableName',
              );
            }
          } else {
            // Insert new record locally
            await _insertLocalRecord(tableName, cloudRecord);
            result.recordsFetched++;
            print(
              '⬇️ DEBUG: SyncService - Fetched new record $recordId to $tableName',
            );
          }
        } catch (e) {
          print(
            '❌ DEBUG: SyncService - Failed to process cloud record: ${e.toString()}',
          );
          result.errors.add('Failed to process cloud record: ${e.toString()}');
        }
      }
    } catch (e) {
      print(
        '❌ DEBUG: SyncService - Error fetching cloud records for $tableName: ${e.toString()}',
      );
      result.errors.add('Fetch error: ${e.toString()}');
    }
  }

  /// Get local record by ID
  Future<Map<String, dynamic>?> _getLocalRecordById(String tableName, String id) async {
    switch (tableName) {
      case 'users':
        final user = await _localDbService.getUser(id);
        return user?.toJson();
      case 'schools':
        final school = await _localDbService.getSchool(id);
        return school?.toJson();
      case 'students':
        final student = await _localDbService.getStudent(id);
        return student?.toJson();
      case 'classes':
        final cls = await _localDbService.getClass(id);
        return cls?.toJson();
      case 'subjects':
        final subject = await _localDbService.getSubject(id);
        return subject?.toJson();
      default:
        return null;
    }
  }

  /// Update local record
  Future<void> _updateLocalRecord(
    String tableName,
    Map<String, dynamic> record,
  ) async {
    // Convert snake_case fields from cloud to camelCase for local models
    final convertedRecord = _convertToCamelCase(record);
    
    switch (tableName) {
      case 'users':
        final user = User.fromJson(convertedRecord);
        await _localDbService.saveUser(user);
        break;
      case 'schools':
        final school = School.fromJson(convertedRecord);
        await _localDbService.saveSchool(school);
        break;
      case 'students':
        final student = Student.fromJson(convertedRecord);
        await _localDbService.saveStudent(student);
        break;
      case 'classes':
        final cls = SchoolClass.fromJson(convertedRecord);
        await _localDbService.saveClass(cls);
        break;
      case 'subjects':
        final subject = Subject.fromJson(convertedRecord);
        await _localDbService.saveSubject(subject);
        break;
    }
  }

  /// Insert local record
  Future<void> _insertLocalRecord(
    String tableName,
    Map<String, dynamic> record,
  ) async {
    await _updateLocalRecord(tableName, record); // Same logic for insert/update
  }

  /// Add sync history record
  void _addSyncHistory(SyncHistory syncRecord) {
    _syncHistory.insert(0, syncRecord);

    // Keep only the latest records
    if (_syncHistory.length > _maxHistoryRecords) {
      _syncHistory.removeRange(_maxHistoryRecords, _syncHistory.length);
    }
  }

  /// Load sync history from local storage
  Future<void> _loadSyncHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_syncHistoryKey);

      if (historyJson != null) {
        final historyList = jsonDecode(historyJson) as List<dynamic>;
        _syncHistory.clear();
        _syncHistory.addAll(
          historyList.map(
            (json) => SyncHistory.fromJson(json as Map<String, dynamic>),
          ),
        );
        print(
          '📚 DEBUG: SyncService - Loaded ${_syncHistory.length} sync history records',
        );
      }
    } catch (e) {
      print(
        '❌ DEBUG: SyncService - Failed to load sync history: ${e.toString()}',
      );
    }
  }

  /// Save sync history to local storage
  Future<void> _saveSyncHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = jsonEncode(
        _syncHistory.map((history) => history.toJson()).toList(),
      );
      await prefs.setString(_syncHistoryKey, historyJson);
      print('💾 DEBUG: SyncService - Saved sync history');
    } catch (e) {
      print(
        '❌ DEBUG: SyncService - Failed to save sync history: ${e.toString()}',
      );
    }
  }

  /// Convert snake_case field names to camelCase for local models
  Map<String, dynamic> _convertToCamelCase(Map<String, dynamic> data) {
    final converted = <String, dynamic>{};
    
    for (final entry in data.entries) {
      final camelKey = _snakeToCamel(entry.key);
      converted[camelKey] = entry.value;
    }
    
    return converted;
  }
  
  /// Convert snake_case string to camelCase
  String _snakeToCamel(String snakeCase) {
    return snakeCase.replaceAllMapped(
      RegExp(r'_([a-z])'),
      (match) => match.group(1)!.toUpperCase(),
    );
  }

  /// Clear all sync history
  Future<void> clearSyncHistory() async {
    _syncHistory.clear();
    await _saveSyncHistory();
    print('🗑️ DEBUG: SyncService - Cleared sync history');
  }

  /// Get sync statistics
  Map<String, dynamic> getSyncStatistics() {
    if (_syncHistory.isEmpty) {
      return {
        'totalSyncs': 0,
        'successfulSyncs': 0,
        'failedSyncs': 0,
        'lastSyncTime': null,
        'averageSyncDuration': null,
      };
    }

    final completedSyncs = _syncHistory
        .where((sync) => sync.status == SyncStatus.completed)
        .toList();
    final failedSyncs = _syncHistory
        .where((sync) => sync.status == SyncStatus.failed)
        .toList();

    Duration? averageDuration;
    if (completedSyncs.isNotEmpty) {
      final totalDuration = completedSyncs
          .where((sync) => sync.syncDuration != null)
          .fold<Duration>(
            Duration.zero,
            (sum, sync) => sum + sync.syncDuration!,
          );
      averageDuration = Duration(
        milliseconds: totalDuration.inMilliseconds ~/ completedSyncs.length,
      );
    }

    return {
      'totalSyncs': _syncHistory.length,
      'successfulSyncs': completedSyncs.length,
      'failedSyncs': failedSyncs.length,
      'lastSyncTime': _syncHistory.first.syncStartTime,
      'averageSyncDuration': averageDuration,
    };
  }
}

class OfflineSyncService {
  // Hive functionality disabled - this is now a stub service
  final OfflineDatabaseService _dbService;
  final SupabaseService _supabaseService;

  bool _isInitialized = false;
  bool _isSyncing = false;

  OfflineSyncService(this._dbService, this._supabaseService);

  Future<void> initialize() async {
    if (_isInitialized) return;
    print('DEBUG: OfflineSyncService initialization skipped (Hive disabled)');
    _isInitialized = true;
  }

  // Save data locally and sync to cloud (offline-first approach)
  Future<void> saveUserLocally(User user) async {
    await _dbService.saveUser(user);
    await _markForFutureSync('user', user.id, 'upsert', user.toJson());

    // Try immediate sync if online
    if (await _isOnline()) {
      await _syncSingleUser(user);
    }
  }

  Future<void> saveStudentLocally(Student student) async {
    await _dbService.saveStudent(student);
    await _markForFutureSync('student', student.id, 'upsert', student.toJson());

    // Try immediate sync if online
    if (await _isOnline()) {
      await _syncSingleStudent(student);
    }
  }

  Future<void> saveSchoolLocally(School school) async {
    await _dbService.saveSchool(school);
    await _markForFutureSync('school', school.id, 'upsert', school.toJson());

    // Try immediate sync if online
    if (await _isOnline()) {
      await _syncSingleSchool(school);
    }
  }

  Future<void> saveClassLocally(SchoolClass schoolClass) async {
    await _dbService.saveClass(schoolClass);
    await _markForFutureSync(
      'class',
      schoolClass.id,
      'upsert',
      schoolClass.toJson(),
    );

    // Try immediate sync if online
    if (await _isOnline()) {
      await _syncSingleClass(schoolClass);
    }
  }

  // Mark data for future sync (when online sync is implemented)
  Future<void> _markForFutureSync(
    String table,
    String id,
    String operation,
    Map<String, dynamic> data,
  ) async {
    // Stub implementation - sync functionality disabled
  }

  // Export data for backup or transfer
  Future<Map<String, dynamic>> exportAllData() async {
    final users = await _dbService.getAllUsers();
    final students = await _dbService.getAllStudents();
    final schools = await _dbService.getAllSchools();
    final classes = await _dbService.getAllClasses();
    
    return {
      'users': users.map((u) => u.toJson()).toList(),
      'students': students.map((s) => s.toJson()).toList(),
      'schools': schools.map((s) => s.toJson()).toList(),
      'classes': classes.map((c) => c.toJson()).toList(),
      'exported_at': DateTime.now().toIso8601String(),
    };
  }

  // Import data from backup
  Future<bool> importData(Map<String, dynamic> data) async {
    try {
      // Clear existing data
      await _dbService.clearAllData();

      // Import users
      if (data['users'] != null) {
        for (final userData in data['users']) {
          final user = User.fromJson(userData);
          await _dbService.saveUser(user);
        }
      }

      // Import students
      if (data['students'] != null) {
        for (final studentData in data['students']) {
          final student = Student.fromJson(studentData);
          await _dbService.saveStudent(student);
        }
      }

      // Import schools
      if (data['schools'] != null) {
        for (final schoolData in data['schools']) {
          final school = School.fromJson(schoolData);
          await _dbService.saveSchool(school);
        }
      }

      // Import classes
      if (data['classes'] != null) {
        for (final classData in data['classes']) {
          final schoolClass = SchoolClass.fromJson(classData);
          await _dbService.saveClass(schoolClass);
        }
      }

      await _updateLastSyncTime();
      return true;
    } catch (e) {
      print('Import failed: $e');
      return false;
    }
  }

  // New sync methods for Supabase integration

  /// Check if device is online
  Future<bool> _isOnline() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return false;
      }

      // Additional check with Supabase
      return await _supabaseService.isConnected();
    } catch (e) {
      return false;
    }
  }

  /// Sync single entities immediately
  Future<bool> _syncSingleUser(User user) async {
    try {
      return await _supabaseService.saveUser(user);
    } catch (e) {
      print('Failed to sync user: $e');
      return false;
    }
  }

  Future<bool> _syncSingleStudent(Student student) async {
    try {
      return await _supabaseService.saveStudent(student);
    } catch (e) {
      print('Failed to sync student: $e');
      return false;
    }
  }

  Future<bool> _syncSingleSchool(School school) async {
    try {
      return await _supabaseService.saveSchool(school);
    } catch (e) {
      print('Failed to sync school: $e');
      return false;
    }
  }

  Future<bool> _syncSingleClass(SchoolClass schoolClass) async {
    try {
      return await _supabaseService.saveClass(schoolClass);
    } catch (e) {
      print('Failed to sync class: $e');
      return false;
    }
  }

  /// Full synchronization with Supabase
  Future<SyncResult> syncWithSupabase() async {
    if (_isSyncing) {
      return SyncResult.failure('Sync already in progress');
    }

    if (!await _isOnline()) {
      return SyncResult.failure('No internet connection');
    }

    _isSyncing = true;

    try {
      print('Starting full sync with Supabase...');

      // Step 1: Push local changes to Supabase
      await _pushPendingChanges();

      // Step 2: Pull latest data from Supabase
      await _pullFromSupabase();

      // Step 3: Clear pending changes (stub - Hive disabled)
      // Step 4: Update sync status (stub - Hive disabled)

      print('Full sync completed successfully');

      return SyncResult.success('Sync completed successfully');
    } catch (e) {
      print('Sync failed: $e');
      return SyncResult.failure('Sync failed: ${e.toString()}');
    } finally {
      _isSyncing = false;
    }
  }

  /// Push pending changes to Supabase
  Future<void> _pushPendingChanges() async {
    // Stub implementation - Hive disabled
    print('Push pending changes skipped (Hive disabled)');
  }

  /// Pull latest data from Supabase
  Future<void> _pullFromSupabase() async {
    try {
      // Pull users
      final users = await _supabaseService.getAllUsers();
      for (final user in users) {
        await _dbService.saveUser(user);
      }

      // Pull students
      final students = await _supabaseService.getAllStudents();
      for (final student in students) {
        await _dbService.saveStudent(student);
      }

      // Pull schools
      final schools = await _supabaseService.getAllSchools();
      for (final school in schools) {
        await _dbService.saveSchool(school);
      }

      // Pull classes
      final classes = await _supabaseService.getAllClasses();
      for (final schoolClass in classes) {
        await _dbService.saveClass(schoolClass);
      }
    } catch (e) {
      print('Failed to pull from Supabase: $e');
      throw e;
    }
  }

  /// Get sync status
  Map<String, dynamic> getSyncStatus() {
    return {
      'last_sync': null,
      'pending_changes': 0,
      'is_syncing': _isSyncing,
      'is_online': false, // Will be updated by periodic check
    };
  }

  /// Force sync all local data to Supabase
  Future<SyncResult> forceUploadAllData() async {
    if (!await _isOnline()) {
      return SyncResult.failure('No internet connection');
    }

    try {
      print('Force uploading all local data...');

      // Upload all users
      final users = await _dbService.getAllUsers();
      for (final user in users) {
        await _supabaseService.saveUser(user);
      }

      // Upload all students
      final students = await _dbService.getAllStudents();
      for (final student in students) {
        await _supabaseService.saveStudent(student);
      }

      // Upload all schools
      final schools = await _dbService.getAllSchools();
      for (final school in schools) {
        await _supabaseService.saveSchool(school);
      }

      // Upload all classes
      final classes = await _dbService.getAllClasses();
      for (final schoolClass in classes) {
        await _supabaseService.saveClass(schoolClass);
      }

      print('Force upload completed');

      return SyncResult.success('All data uploaded successfully');
    } catch (e) {
      print('Force upload failed: $e');
      return SyncResult.failure('Upload failed: ${e.toString()}');
    }
  }

  /// Add pending change for later sync
  Future<void> _addPendingChange(
    String table,
    String operation,
    Map<String, dynamic> data,
  ) async {
    // Stub implementation - Hive disabled
    print('Add pending change skipped (Hive disabled)');
  }

  // Backup data to local file system
  Future<String?> createBackup() async {
    try {
      final data = await exportAllData();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = 'school_backup_$timestamp.json';

      // In a real implementation, you would save this to a file
      // For now, we just mark it as created
      await _updateLastBackupTime();

      return filename;
    } catch (e) {
      print('Backup failed: $e');
      return null;
    }
  }

  // Get local data methods
  Future<List<User>> getLocalUsers() async {
    return await _dbService.getAllUsers();
  }

  Future<List<Student>> getLocalStudents() async {
    return await _dbService.getAllStudents();
  }

  Future<List<School>> getLocalSchools() async {
    return await _dbService.getAllSchools();
  }

  Future<List<SchoolClass>> getLocalClasses() async {
    return await _dbService.getAllClasses();
  }

  // Save local data methods
  Future<void> saveUser(User user) async {
    await _dbService.saveUser(user);
  }

  Future<void> saveStudent(Student student) async {
    await _dbService.saveStudent(student);
  }

  Future<void> saveSchool(School school) async {
    await _dbService.saveSchool(school);
  }

  Future<void> saveClass(SchoolClass schoolClass) async {
    await _dbService.saveClass(schoolClass);
  }

  // Delete methods
  Future<void> deleteUser(String id) async {
    await _dbService.deleteUser(id);
  }

  Future<void> deleteStudent(String id) async {
    await _dbService.deleteStudent(id);
  }

  Future<void> deleteSchool(String id) async {
    await _dbService.deleteSchool(id);
  }

  Future<void> deleteClass(String id) async {
    await _dbService.deleteClass(id);
  }

  // Clear all local data
  Future<void> clearLocalData() async {
    await _dbService.clearAllData();
  }

  Future<void> _updateLastSyncTime() async {
    // Stub implementation - Hive disabled
  }

  Future<void> _updateLastBackupTime() async {
    // Stub implementation - Hive disabled
  }

  DateTime? getLastSyncTime() {
    return null; // Hive disabled
  }

  DateTime? getLastBackupTime() {
    return null; // Hive disabled
  }

  int getPendingChangesCount() {
    return 0; // Hive disabled
  }

  // Clear all pending changes
  Future<void> clearPendingChanges() async {
    // Stub implementation - Hive disabled
  }

  // Get statistics
  Future<Map<String, int>> getDataStatistics() async {
    final users = await _dbService.getAllUsers();
    final students = await _dbService.getAllStudents();
    final schools = await _dbService.getAllSchools();
    final classes = await _dbService.getAllClasses();

    return {
      'users': users.length,
      'students': students.length,
      'schools': schools.length,
      'classes': classes.length,
      'pending_changes': 0, // Hive disabled
    };
  }
}

// Riverpod providers
final syncServiceProvider = Provider<SyncService>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  final localDbService = ref.watch(offlineDatabaseServiceProvider);
  return SyncService(supabaseService, localDbService);
});

final offlineSyncServiceProvider = Provider<OfflineSyncService>((ref) {
  final dbService = ref.watch(offlineDatabaseServiceProvider);
  final supabaseService = ref.watch(supabaseServiceProvider);
  return OfflineSyncService(dbService, supabaseService);
});

final syncStatusProvider = StateProvider<SyncStatus>((ref) {
  return SyncStatus.inProgress;
});
